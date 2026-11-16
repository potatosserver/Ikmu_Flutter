// IRS Debug Log Collector
// 收集並提供複製功能的除錯日誌 (release 模式也能運作)

import 'dart:developer' as developer;

class IrsDebugLog {
  static final List<String> _logs = [];
  static const int _maxLogs = 500;

  static void log(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final entry = '[$timestamp] $message';
    _logs.add(entry);
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }
    // 使用 developer.log 在 release 模式也會輸出
    developer.log(entry, name: 'IRS_DEBUG');
    // 同時用 print 確保 release APK 也能看到
    print(entry);
  }

  static List<String> get logs => List.unmodifiable(_logs);

  static String get allLogs => _logs.join('\n');

  static void clear() {
    _logs.clear();
  }

  static String getLogsAsJson() {
    return '''
{
  "timestamp": "${DateTime.now().toIso8601String()}",
  "logCount": ${_logs.length},
  "logs": [
${_logs.map((l) => '    "$l"').join(',\n')}
  ]
}
''';
  }
}