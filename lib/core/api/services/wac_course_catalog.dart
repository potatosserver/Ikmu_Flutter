// 高醫全校課表目錄服務 (wac.kmu.edu.tw)
// 一次下載整個學期 CSV、在本機用 seqno 搜尋 → 補上「節次/星期/教室」
// 對齊 reference/kmucoursequery_wac.py

import 'dart:convert';
import 'package:characters/characters.dart';

import 'package:dio/dio.dart';

import '../models/course_models.dart';

/// wac CSV 單筆 (key: CSV 表頭中文欄位)
class WacCatalogEntry {
  const WacCatalogEntry({
    required this.seqno,
    required this.year,
    required this.sem,
    required this.chineseco,
    required this.teacher,
    required this.weekday,
    required this.bcl,
    required this.ecl,
    required this.room,
  });

  final String seqno; // 開課序號 (對應 Course.seqno)
  final String year;
  final String sem;
  final String chineseco;
  final String teacher;
  final String weekday; // "1" ~ "6" (週一到週六)，可能為空
  final String bcl; // 起始節次 ("1" ~ "9" / "A" ~ "D")
  final String ecl; // 結束節次
  final String room;

  /// 展開成節次清單 (對齊 Python get_period_range)
  List<String> get expandedPeriods => KmuPeriod.expandRange(bcl, ecl);

  /// 完整鍵 (用於 dedupe)
  String get uniqueKey => '$seqno|$weekday|$bcl|$ecl|$room';

  factory WacCatalogEntry.fromCsv(Map<String, String> row) {
    String _strip(String? v) {
      if (v == null) return '';
      // 移除 HTML span 標籤
      return v
          .replaceAll(RegExp(r'<[^>]+>'), '')
          .trim();
    }

    return WacCatalogEntry(
      seqno: _strip(row['開課序號']),
      year: _strip(row['學年']),
      sem: _strip(row['學期']),
      chineseco: _strip(row['科目名稱']),
      teacher: _strip(row['教師姓名']),
      weekday: _strip(row['星期']),
      bcl: _strip(row['節次']).toUpperCase(),
      ecl: _strip(row['節次迄']).toUpperCase(),
      room: _strip(row['教室']),
    );
  }

  Map<String, dynamic> toMap() => {
        'seqno': seqno,
        'year': year,
        'sem': sem,
        'chineseco': chineseco,
        'teacher': teacher,
        'weekday': weekday,
        'bcl': bcl,
        'ecl': ecl,
        'room': room,
      };

  factory WacCatalogEntry.fromMap(Map<String, dynamic> m) => WacCatalogEntry(
        seqno: m['seqno'] as String? ?? '',
        year: m['year'] as String? ?? '',
        sem: m['sem'] as String? ?? '',
        chineseco: m['chineseco'] as String? ?? '',
        teacher: m['teacher'] as String? ?? '',
        weekday: m['weekday'] as String? ?? '',
        bcl: m['bcl'] as String? ?? '',
        ecl: m['ecl'] as String? ?? '',
        room: m['room'] as String? ?? '',
      );
}

/// 高醫全校課表目錄
/// 用法：
///   final catalog = await WacCourseCatalog.load('114', '2');
///   for (final entry in catalog.findBySeqno('0001001')) { ... }
class WacCourseCatalog {
  WacCourseCatalog._({
    required this.year,
    required this.sem,
    required List<WacCatalogEntry> entries,
  }) : _entries = entries;

  final String year;
  final String sem;
  final List<WacCatalogEntry> _entries;

  /// 全部條目數
  int get length => _entries.length;

  /// 用 seqno 查詢對應的所有時段 (一門課可能多時段 / 跨多週天)
  List<WacCatalogEntry> findBySeqno(String seqno) {
    if (seqno.isEmpty) return const [];
    return _entries.where((e) => e.seqno == seqno).toList();
  }

  /// 將 CSV 內容解析為條目清單
  static List<WacCatalogEntry> _parseCsv(String csvText) {
    final lines = const LineSplitter().convert(csvText);
    if (lines.isEmpty) return [];

    final headers = _parseCsvLine(lines.first);
    final out = <WacCatalogEntry>[];
    final seen = <String>{};

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) continue;
      final fields = _parseCsvLine(line);
      if (fields.length != headers.length) continue;

      final row = <String, String>{};
      for (var j = 0; j < headers.length; j++) {
        row[headers[j]] = fields[j];
      }

      final entry = WacCatalogEntry.fromCsv(row);
      // 過濾：沒節次/沒星期的視為「無固定時段」(Block、實習...)
      // 仍保留條目但不會被加到課表格子上
      if (entry.bcl.isEmpty || entry.weekday.isEmpty) continue;

      final key = entry.uniqueKey;
      if (seen.add(key)) {
        out.add(entry);
      }
    }
    return out;
  }

  /// 簡易 CSV 行解析 (處理雙引號內逗號 / 雙引號跳脫)
  static List<String> _parseCsvLine(String line) {
    final result = <String>[];
    final buf = StringBuffer();
    var inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buf.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (ch == ',' && !inQuotes) {
        result.add(buf.toString());
        buf.clear();
      } else {
        buf.write(ch);
      }
    }
    result.add(buf.toString());
    return result;
  }

  /// 從 wac.kmu.edu.tw 下載整個學期 CSV 並解析
  static Future<WacCourseCatalog> load(
    String year,
    String sem, {
    Dio? dio,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final client = dio ?? Dio();
    final url = 'https://wac.kmu.edu.tw/qur/qurq0006.php';

    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
    };

    final payload = StringBuffer(
      '_CD_SYEAR=$year&_CD_SEM=$sem&_CD_DEPTNO=&_CD_GRADE=%25'
      '&_CD_SEQNO=&_CD_CHINESECO=&_CD_TEA=&_CD_ROOMNO=&_CD_CSK=&_CD_CLWEEK='
      '&_CD_LANG=&_CD_OPENYN=Y',
    );
    final fields = [
      'SYEAR', 'SEM', 'SEQNO', 'DEPTNO', 'MASTER', 'SECNAM', 'ACADNO', 'CONO',
      'OPENYN', 'NETYN', 'CHOOSEMAN', 'GRADE', 'CLASSCODE', 'SECQTY',
      'CHINESECO', 'SM', 'CREDIT', 'CSK', 'TEAFNAM', 'COKIND', 'CLWEEK',
      'BCL', 'ECL', 'ROOMNO', 'RMK',
    ];
    for (final f in fields) {
      payload.write('&m_SQR_FD%5B%5D=$f');
    }
    payload.write(
      '&m_SQR_OD1=&m_SQR_OD2=&m_SQR_OD3=&m_SQR_OD4=&m_SQR_OD5='
      '&m_Action=%BF%E9%A5X%C2%B2%B3t%AA%ED%28csv%29'
      '&m_CurRec=0&m_UPDMode=&m_InSearch=&m_SearchSQL=&m_InsSussTime=0'
      '&_CD_EMIYN=&lang=zh',
    );

    // Dio 對 String 會再做一次 encode，把 %25 變 %2525 → wac 回 HTML
    // 解法：用 FormData.fromMap 包成 raw form，並 disable URL encoding
    final response = await client.post<List<int>>(
      url,
      data: payload.toString(),
      options: Options(
        headers: headers,
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.bytes,
        sendTimeout: timeout,
        receiveTimeout: timeout,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    final rawBytes = response.data ?? <int>[];

    String? text;
    for (final enc in ['utf-8-sig', 'cp950', 'utf-8', 'big5']) {
      try {
        text = utf8.decode(rawBytes, allowMalformed: true);
        // 用編碼標記做啟發式偵測
        if (enc == 'utf-8-sig' && text.characters.first == '\uFEFF') {
          text = text.substring(1);
        }
        break;
      } catch (_) {
        continue;
      }
    }
    text ??= utf8.decode(rawBytes, allowMalformed: true);

    final entries = _parseCsv(text);
    return WacCourseCatalog._(year: year, sem: sem, entries: entries);
  }

  /// 序列化為可寫入 Hive 的 Map (避免 List<WacCatalogEntry> 寫進 Hive)
  Map<String, dynamic> toJson() => {
        'year': year,
        'sem': sem,
        'entries': _entries.map((e) => e.toMap()).toList(),
      };

  factory WacCourseCatalog.fromJson(Map<String, dynamic> json) {
    final raw = (json['entries'] as List?) ?? const [];
    return WacCourseCatalog._(
      year: json['year'] as String? ?? '',
      sem: json['sem'] as String? ?? '',
      entries: raw
          .whereType<Map<String, dynamic>>()
          .map(WacCatalogEntry.fromMap)
          .toList(),
    );
  }
}
