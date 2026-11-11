// 行事曆相關模型

import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_models.freezed.dart';
part 'calendar_models.g.dart';

/// 行事曆檢視模式
enum CalendarView {
  @JsonValue('month')
  month,

  @JsonValue('week')
  week,

  @JsonValue('day')
  day,
}

/// 行事曆事件類型
@freezed
abstract class CalendarEventType with _$CalendarEventType {
  const factory CalendarEventType({
    required String code,
    required String name,
    required String color,
    @Default('') String icon,
  }) = _CalendarEventType;

  factory CalendarEventType.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventTypeFromJson(json);

  // 預定義類型常數
  static const CalendarEventType exam = CalendarEventType(
    code: 'EXAM',
    name: '考試',
    color: '#FF6B6B',
    icon: 'quiz',
  );

  static const CalendarEventType assignment = CalendarEventType(
    code: 'ASSIGNMENT',
    name: '作業',
    color: '#4ECDC4',
    icon: 'assignment',
  );

  static const CalendarEventType meeting = CalendarEventType(
    code: 'MEETING',
    name: '會議',
    color: '#45B7D1',
    icon: 'meeting_room',
  );

  static const CalendarEventType holiday = CalendarEventType(
    code: 'HOLIDAY',
    name: '假期',
    color: '#FFD93D',
    icon: 'celebration',
  );

  static const CalendarEventType other = CalendarEventType(
    code: 'OTHER',
    name: '其他',
    color: '#95A5A6',
    icon: 'event',
  );
}

/// 行事曆事件
/// Python API 欄位: sno(序號), atype(類型), atypeName, title, etitle,
///                 location, elocation, dateFrom(yyymmdd), dateTo(yyymmdd),
///                 info, einfo, ...
@JsonSerializable(explicitToJson: true)
class CalendarEvent {
  CalendarEvent({
    required this.id,
    required this.title,
    required this.typeCode,
    this.typeName,
    this.startTime,
    this.endTime,
    this.allDay = false,
    this.location,
    this.info,
    this.extendedInfo,
    this.color,
    this.sequence,
    this.date, // YYYY-MM-DD
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id']?.toString() ?? json['sno']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      typeCode: json['atype']?.toString() ?? '0',
      typeName: json['atype_name']?.toString() ?? json['atypeName']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      allDay: json['all_day'] as bool? ?? true,
      location: json['location']?.toString(),
      info: json['info']?.toString(),
      extendedInfo: json['einfo']?.toString() ?? json['extended_info']?.toString(),
      color: json['color']?.toString(),
      sequence: (json['seq'] as num?)?.toInt() ?? (json['sno'] as num?)?.toInt(),
      date: _parseRocDate(json['dateFrom']?.toString()) ?? json['date']?.toString(),
    );
  }

  /// 從 API 回應建立 (處理時間解析)
  factory CalendarEvent.fromApi(Map<String, dynamic> json) {
    return CalendarEvent.fromJson(json);
  }

  final String id;
  final String title;
  final String typeCode;
  final String? typeName;
  final String? startTime;
  final String? endTime;
  final bool allDay;
  final String? location;
  final String? info;
  final String? extendedInfo;
  final String? color;
  final int? sequence;
  final String? date;

  /// 解析 ROC 日期 (yyyymmdd 或 yymmdd) 為 YYYY-MM-DD
  static String? _parseRocDate(String? s) {
    if (s == null || s.isEmpty) return null;
    final digits = s.replaceAll(RegExp('[^0-9]'), '');
    if (digits.length == 7) {
      // yyyymmdd -> 西元 4 位年
      final y = digits.substring(0, 3);
      final m = digits.substring(3, 5);
      final d = digits.substring(5, 7);
      // ROC: yyy + 1911? 實務上 KMU 用民國年，這裡直接加 1911
      final rocY = int.tryParse(y) ?? 0;
      return '${rocY + 1911}-$m-$d';
    }
    if (digits.length == 6) {
      // yymmdd
      final rocY = int.tryParse(digits.substring(0, 2)) ?? 0;
      final m = digits.substring(2, 4);
      final d = digits.substring(4, 6);
      return '${rocY + 1911}-$m-$d';
    }
    return s;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'typeCode': typeCode,
      'typeName': typeName,
      'startTime': startTime,
      'endTime': endTime,
      'allDay': allDay,
      'location': location,
      'info': info,
      'extendedInfo': extendedInfo,
      'color': color,
      'sequence': sequence,
      'date': date,
    };
  }
}

/// CalendarEvent 擴展方法
extension CalendarEventExtension on CalendarEvent {
  /// 兼容 UI 代碼期望的 type getter
  String get type => typeCode;

  /// 兼容 UI 代碼期望的 description getter
  String? get description => info ?? extendedInfo;

  /// 取得該事件的所屬日期 (優先解析 date，若無則 fallback 到 startTime 或當天)
  DateTime? get eventDate {
    if (date != null && date!.isNotEmpty) {
      try {
        final parsed = DateTime.parse(date!);
        return DateTime(parsed.year, parsed.month, parsed.day);
      } catch (_) {}
    }
    if (parsedStartTime != null) {
      return DateTime(parsedStartTime!.year, parsedStartTime!.month, parsedStartTime!.day);
    }
    return null;
  }

  DateTime? get parsedStartTime {
    if (startTime != null && startTime!.isNotEmpty) {
      try {
        if (startTime!.contains(':')) {
          final parts = startTime!.split(':');
          if (parts.length >= 2) {
            final hour = int.tryParse(parts[0]) ?? 0;
            final minute = int.tryParse(parts[1]) ?? 0;
            final baseDate = eventDate ?? DateTime.now();
            return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
          }
        }
      } catch (_) {}
    }
    // 若無 startTime，但有 date，則預設為當天 00:00
    if (eventDate != null) {
      return eventDate;
    }
    return null;
  }

  DateTime? get parsedEndTime {
    if (endTime != null && endTime!.isNotEmpty) {
      try {
        final parts = endTime!.split(':');
        if (parts.length >= 2) {
          final hour = int.tryParse(parts[0]) ?? 0;
          final minute = int.tryParse(parts[1]) ?? 0;
          final baseDate = eventDate ?? DateTime.now();
          return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
        }
      } catch (_) {}
    }
    return parsedStartTime;
  }
}

/// 行事曆狀態 (Riverpod 管理)
@freezed
abstract class CalendarState with _$CalendarState {
  const factory CalendarState({
    @Default(CalendarView.month) CalendarView currentView,
    DateTime? currentMonth,      // 月檢視：當前月份 (第一天)
    DateTime? currentWeekStart,  // 週檢視：週起始日 (週日)
    DateTime? currentDay,        // 日檢視：當前日期
    @Default({}) Map<String, List<CalendarEvent>> eventsCache, // dateStr -> events
    @Default({}) Map<String, int> cacheTimestamps, // dateStr -> timestamp
    @Default(false) bool isLoading,
    String? error,
    @Default(false) bool isOffline,
  }) = _CalendarState;

  factory CalendarState.initial() => const CalendarState();
}

/// CalendarState 擴展方法
extension CalendarStateExtension on CalendarState {
  /// 取得指定日期的事件
  List<CalendarEvent> getEventsForDate(String dateStr) {
    return eventsCache[dateStr] ?? [];
  }

  /// 檢查快取是否有效 (1小時)
  bool isCacheValid(String dateStr) {
    final ts = cacheTimestamps[dateStr];
    if (ts == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - ts < 60 * 60 * 1000; // 1小時
  }

  /// 取得月份快取鍵
  String get monthCacheKey => currentMonth != null
      ? '${currentMonth!.year}-${currentMonth!.month.toString().padLeft(2, '0')}'
      : '';
}

/// 行事曆月份事件回應
@freezed
abstract class CalendarMonthResponse with _$CalendarMonthResponse {
  const factory CalendarMonthResponse({
    required bool success,
    required String message,
    Map<String, dynamic>? data,
  }) = _CalendarMonthResponse;

  factory CalendarMonthResponse.fromJson(Map<String, dynamic> json) =>
      _$CalendarMonthResponseFromJson(json);
}

/// 事件詳情 Modal 資料
@freezed
abstract class EventDetailData with _$EventDetailData {
  const factory EventDetailData({
    required CalendarEvent event,
    required String dateStr,
    required List<CalendarEvent> allDayEvents,
  }) = _EventDetailData;

  factory EventDetailData.fromJson(Map<String, dynamic> json) =>
      _$EventDetailDataFromJson(json);
}