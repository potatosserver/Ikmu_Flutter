// 快取服務 - 封裝 Hive 操作、TTL 管理、泛型支援

import 'package:hive_flutter/hive_flutter.dart';

import '../constants/api_constants.dart';

/// 快取項目包裝
class CacheItem<T> {
  CacheItem({
    required this.data,
    required this.timestamp,
    required this.ttl,
  });
  final T data;
  final int timestamp;
  final int ttl;

  /// 檢查是否過期
  bool get isExpired {
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - timestamp > ttl;
  }

  /// 轉為 Map 儲存
  Map<String, dynamic> toMap() {
    return {
      'data': data,
      'timestamp': timestamp,
      'ttl': ttl,
    };
  }

  /// 從 Map 還原
  static CacheItem<T> fromMap<T>(Map<dynamic, dynamic> map, T Function(Object?) fromJson) {
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

  bool _initialized = false;

  /// 初始化 Hive
  Future<void> initialize() async {
    if (_initialized) return;

    // 初始化 Hive Flutter
    await Hive.initFlutter();

    // 註冊 TypeAdapters (需先執行 build_runner 生成)
    // Hive.registerAdapter(CacheItemAdapter());
    // ... 其他 adapters

    // 開啟所有 Box
    await _openAllBoxes();

    _initialized = true;
  }

  /// 開啟所有預設 Box
  Future<void> _openAllBoxes() async {
    for (final boxName in CacheBoxes.values) {
      if (!Hive.isBoxOpen(boxName.name)) {
        await Hive.openBox<Map>(boxName.name);
      }
    }
  }

  /// 取得 Box
  Box<Map> _box(CacheBoxes box) {
    return Hive.box<Map>(box.name);
  }

  /// 寫入快取
  Future<void> set<T>(
    CacheBoxes box,
    String key,
    T data, {
    required T Function(Object?) fromJson,
    CacheTTL ttl = CacheTTL.generic,
  }) async {
    final item = CacheItem<T>(
      data: data,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      ttl: ttl.milliseconds,
    );
    await _box(box).put(key, item.toMap());
  }

  /// 讀取快取 (帶 fromJson)
  T? get<T>(
    CacheBoxes box,
    String key, {
    required T Function(Object?) fromJson,
  }) {
    final map = _box(box).get(key);
    if (map == null) return null;

    final item = CacheItem.fromMap(
      Map<String, dynamic>.from(map),
      fromJson,
    );

    if (item.isExpired) {
      _box(box).delete(key);
      return null;
    }

    return item.data;
  }

  /// 讀取快取 (簡化版，自動推斷類型)
  T? getSimple<T>(CacheBoxes box, String key) {
    final map = _box(box).get(key);
    if (map == null) return null;

    final item = CacheItem.fromMap(
      Map<String, dynamic>.from(map),
      (v) => v as T,
    );

    if (item.isExpired) {
      _box(box).delete(key);
      return null;
    }

    return item.data;
  }

  /// 寫入快取 (簡化版，自動序列化)
  Future<void> setSimple<T>(
    CacheBoxes box,
    String key,
    T data, {
    CacheTTL ttl = CacheTTL.generic,
  }) async {
    final item = CacheItem<T>(
      data: data,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      ttl: ttl.milliseconds,
    );
    await _box(box).put(key, item.toMap());
  }

  /// 刪除快取
  Future<void> delete(CacheBoxes box, String key) async {
    await _box(box).delete(key);
  }

  /// 移除快取 (別名)
  Future<void> remove(CacheBoxes box, String key) async {
    await _box(box).delete(key);
  }

  /// 清空 Box
  Future<void> clear(CacheBoxes box) async {
    await _box(box).clear();
  }

  /// 取得所有鍵
  List<String> keys(CacheBoxes box) {
    return _box(box).keys.cast<String>().toList();
  }

  /// 檢查鍵是否存在且未過期
  bool hasValid(CacheBoxes box, String key) {
    final map = _box(box).get(key);
    if (map == null) return false;

    final item = CacheItem.fromMap(
      Map<String, dynamic>.from(map),
      (v) => v,
    );

    if (item.isExpired) {
      _box(box).delete(key);
      return false;
    }

    return true;
  }

  /// 取得 Box 大小
  int length(CacheBoxes box) {
    return _box(box).length;
  }

  /// 關閉所有 Box
  Future<void> closeAll() async {
    for (final boxName in CacheBoxes.values) {
      if (Hive.isBoxOpen(boxName.name)) {
        await Hive.box<Map>(boxName.name).close();
      }
    }
    _initialized = false;
  }
}