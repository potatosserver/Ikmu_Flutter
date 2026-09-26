// 快取服務 - 使用 sqflite + shared_preferences (官方套件)
// 替代 Hive，提供結構化快取 + TTL 自動過期

import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/api_constants.dart';

/// 快取項目
class CacheItem<T> {
  CacheItem({
    required this.data,
    required this.timestamp,
    required this.ttl,
  });
  final T data;
  final int timestamp;
  final int ttl;

  bool get isExpired {
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - timestamp > ttl;
  }

  Map<String, dynamic> toMap() {
    return {
      'data': data,
      'timestamp': timestamp,
      'ttl': ttl,
    };
  }

  static CacheItem<T> fromMap<T>(
    Map<String, dynamic> map,
    T Function(Object?) fromJson,
  ) {
    return CacheItem<T>(
      data: fromJson(map['data']),
      timestamp: map['timestamp'] as int,
      ttl: map['ttl'] as int,
    );
  }
}

/// 快取服務單例
class CacheService {
  CacheService._();

  static final CacheService _instance = CacheService._();
  static CacheService get instance => _instance;

  Database? _db;
  SharedPreferences? _prefs;
  bool _initialized = false;

  /// 初始化快取服務
  Future<void> initialize() async {
    if (_initialized) return;

    // 初始化 SharedPreferences (偏好設定)
    _prefs = await SharedPreferences.getInstance();

    // 初始化 sqflite (結構化快取)
    final appDir = await getApplicationSupportDirectory();
    final dbPath = '${appDir.path}/cache.db';
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );

    // 啟動時清理過期資料
    await _cleanExpired();

    _initialized = true;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cache (
        box TEXT NOT NULL,
        key TEXT NOT NULL,
        value TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        ttl INTEGER NOT NULL,
        PRIMARY KEY (box, key)
      )
    ''');
    await db.execute('CREATE INDEX idx_cache_box ON cache(box)');
    await db.execute('CREATE INDEX idx_cache_timestamp ON cache(timestamp)');
  }

  /// 清理所有過期快取
  Future<void> _cleanExpired() async {
    if (_db == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db!.delete(
      'cache',
      where: 'timestamp + ttl < ?',
      whereArgs: [now],
    );
  }

  /// 取得 SharedPreferences 實例 (偏好設定用)
  SharedPreferences get prefs => _prefs!;

  /// 取得 sqflite 實例 (結構化快取用)
  Database get db => _db!;

  /// 寫入快取 (結構化資料)
  Future<void> set<T>(
    CacheBoxes box,
    String key,
    T data, {
    required T Function(Object?) fromJson,
    CacheTTL ttl = CacheTTL.generic,
  }) async {
    if (_db == null) return;
    final item = CacheItem<T>(
      data: data,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      ttl: ttl.milliseconds,
    );
    await _db!.insert(
      'cache',
      {
        'box': box.name,
        'key': key,
        'value': jsonEncode(item.toMap()),
        'timestamp': item.timestamp,
        'ttl': item.ttl,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 讀取快取 (結構化資料)
  T? get<T>(
    CacheBoxes box,
    String key, {
    required T Function(Object?) fromJson,
  }) {
    if (_db == null) return null;
    // 同步查詢不支援，需使用 getAsync
    return null;
  }

  /// 異步讀取快取 (結構化資料)
  Future<T?> getAsync<T>(
    CacheBoxes box,
    String key, {
    required T Function(Object?) fromJson,
  }) async {
    if (_db == null) return null;
    final maps = await _db!.query(
      'cache',
      where: 'box = ? AND key = ?',
      whereArgs: [box.name, key],
      limit: 1,
    );
    if (maps.isEmpty) return null;

    final map = maps.first;
    final valueMap = jsonDecode(map['value'] as String) as Map<String, dynamic>;
    final item = CacheItem.fromMap(valueMap, fromJson);

    if (item.isExpired) {
      await _db!.delete(
        'cache',
        where: 'box = ? AND key = ?',
        whereArgs: [box.name, key],
      );
      return null;
    }
    return item.data;
  }

  /// 簡化版寫入 (自動序列化為 JSON)
  Future<void> setSimple<T>(
    CacheBoxes box,
    String key,
    T data, {
    CacheTTL ttl = CacheTTL.generic,
  }) async {
    await set(box, key, data, fromJson: (v) => v as T, ttl: ttl);
  }

  /// 簡化版讀取 (自動反序列化)
  Future<T?> getSimple<T>(CacheBoxes box, String key) async {
    return getAsync<T>(box, key, fromJson: (v) => v as T);
  }

  /// 刪除快取
  Future<void> delete(CacheBoxes box, String key) async {
    if (_db == null) return;
    await _db!.delete(
      'cache',
      where: 'box = ? AND key = ?',
      whereArgs: [box.name, key],
    );
  }

  /// 清空 Box
  Future<void> clear(CacheBoxes box) async {
    if (_db == null) return;
    await _db!.delete(
      'cache',
      where: 'box = ?',
      whereArgs: [box.name],
    );
  }

  /// 取得所有鍵
  Future<List<String>> keys(CacheBoxes box) async {
    if (_db == null) return [];
    final maps = await _db!.query(
      'cache',
      where: 'box = ?',
      whereArgs: [box.name],
      columns: ['key'],
    );
    return maps.map((m) => m['key'] as String).toList();
  }

  /// 檢查鍵是否存在且未過期
  Future<bool> hasValid(CacheBoxes box, String key) async {
    final data = await getAsync(box, key, fromJson: (v) => v);
    return data != null;
  }

  /// 取得 Box 大小
  Future<int> length(CacheBoxes box) async {
    if (_db == null) return 0;
    final result = await _db!.rawQuery(
      'SELECT COUNT(*) as count FROM cache WHERE box = ?',
      [box.name],
    );
    return result.first['count'] as int;
  }

  /// 關閉資料庫
  Future<void> closeAll() async {
    await _db?.close();
    _db = null;
    _initialized = false;
  }

  // ========== SharedPreferences 偏好設定 API ==========

  /// 讀取偏好設定
  T? getPref<T>(String key) {
    if (_prefs == null) return null;
    if (T == String) return _prefs!.getString(key) as T?;
    if (T == int) return _prefs!.getInt(key) as T?;
    if (T == double) return _prefs!.getDouble(key) as T?;
    if (T == bool) return _prefs!.getBool(key) as T?;
    if (T == List<String>) return _prefs!.getStringList(key) as T?;
    return null;
  }

  /// 寫入偏好設定
  Future<bool> setPref<T>(String key, T value) {
    if (_prefs == null) return Future.value(false);
    if (T == String) return _prefs!.setString(key, value as String);
    if (T == int) return _prefs!.setInt(key, value as int);
    if (T == double) return _prefs!.setDouble(key, value as double);
    if (T == bool) return _prefs!.setBool(key, value as bool);
    if (T == List<String>) return _prefs!.setStringList(key, value as List<String>);
    return Future.value(false);
  }

  /// 刪除偏好設定
  Future<bool> removePref(String key) {
    if (_prefs == null) return Future.value(false);
    return _prefs!.remove(key);
  }
}