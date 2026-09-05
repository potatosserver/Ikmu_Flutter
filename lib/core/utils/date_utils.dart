// 日期時間工具類
// 用於行事曆、週起始計算、格式化顯示

import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// 初始化時區資料 (App 啟動時呼叫一次)
void initializeTimeZones() {
  tz_data.initializeTimeZones();
  // 設定預設時區為台北時間
  tz.setLocalLocation(tz.getLocation('Asia/Taipei'));
}

/// 星期映射 (週日在最左邊)
class WeekdayMap {
  static const List<String> fullName = [
    '星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六',
  ];
  
  static const List<String> shortName = [
    '日', '一', '二', '三', '四', '五', '六',
  ];
  
  static const List<String> enShortName = [
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat',
  ];

  // 舊版相容：週一在最左邊
  static const List<String> fullNameMonFirst = [
    '星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日',
  ];
  
  static const List<String> shortNameMonFirst = [
    '一', '二', '三', '四', '五', '六', '日',
  ];
}

/// 日期時間工具類
class DateUtils {
  DateUtils._();

  // 為了向後相容，暴露 WeekdayMap 的靜態常數
  static const List<String> weekdayShortNames = WeekdayMap.shortName;
  
  // ===========================================
  // 格式化器
  // ===========================================
  
  static final DateFormat _ymd = DateFormat('yyyy-MM-dd');
  static final DateFormat _ym = DateFormat('yyyy-MM');
  static final DateFormat _md = DateFormat('MM/dd');
  static final DateFormat _chineseYmd = DateFormat('yyyy 年 M 月 d 日');
  static final DateFormat _chineseYm = DateFormat('yyyy 年 M 月');
  static final DateFormat _chineseMd = DateFormat('M 月 d 日');
  static final DateFormat _timeHm = DateFormat('HH:mm');
  static final DateFormat _fullDateTime = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat _isoDateTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
  
  // ===========================================
  // 基礎轉換
  // ===========================================
  
  /// DateTime -> YYYY-MM-DD 字串
  static String toYmd(DateTime date) => _ymd.format(date);
  
  /// DateTime -> YYYY-MM 字串
  static String toYm(DateTime date) => _ym.format(date);
  
  /// DateTime -> MM/dd 字串
  static String toMd(DateTime date) => _md.format(date);
  
  /// DateTime -> 中文完整日期
  static String toChineseYmd(DateTime date) => _chineseYmd.format(date);
  
  /// DateTime -> 中文年月
  static String toChineseYm(DateTime date) => _chineseYm.format(date);
  
  /// DateTime -> 中文月日
  static String toChineseMd(DateTime date) => _chineseMd.format(date);
  
  /// DateTime -> HH:mm
  static String toHm(DateTime date) => _timeHm.format(date);
  
  /// DateTime -> ISO 8601 (不含時區)
  static String toIsoString(DateTime date) => _isoDateTime.format(date);
  
  /// DateTime -> 完整日期時間
  static String toFullDateTime(DateTime date) => _fullDateTime.format(date);
  
  /// 字串 YYYY-MM-DD -> DateTime (本地時間 00:00)
  static DateTime fromYmd(String ymd) {
    return _ymd.parse(ymd);
  }
  
  /// 字串 YYYY-MM -> DateTime (該月第一天 00:00)
  static DateTime fromYm(String ym) {
    return _ym.parse(ym);
  }
  
  /// ISO 字串 -> DateTime
  static DateTime fromIsoString(String iso) {
    return _isoDateTime.parse(iso);
  }
  
  // ===========================================
  // 週相關計算
  // ===========================================
  
  /// 取得該日期所在週的起始日期 (週日 00:00:00)
  /// 對應 Python: getWeekStart(date) - 週日為週起始
  static DateTime getWeekStart(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    // DateTime.weekday: 1=Mon, 2=Tue, ..., 6=Sat, 7=Sun
    // 我們要週日=0, 週一=1, ..., 週六=6
    final sundayBasedWeekday = d.weekday % 7; // 7%7=0 (Sun), 1%7=1 (Mon), ..., 6%7=6 (Sat)
    return d.subtract(Duration(days: sundayBasedWeekday));
  }
  
  /// 取得該日期所在週的結束日期 (週六 23:59:59)
  static DateTime getWeekEnd(DateTime date) {
    final start = getWeekStart(date);
    return DateTime(start.year, start.month, start.day + 6, 23, 59, 59);
  }
  
  /// 取得該週的日期範圍字串
  /// 格式：2025 年 9 月 1 日 ~ 2025 年 9 月 7 日
  static String formatWeekRange(DateTime weekStart) {
    final end = DateTime(weekStart.year, weekStart.month, weekStart.day + 6);
    return '${toChineseMd(weekStart)} ~ ${toChineseMd(end)}';
  }
  
  /// 取得該週所有日期字串列表 (YYYY-MM-DD)
  static List<String> getWeekDates(DateTime weekStart) {
    return List.generate(7, (i) {
      final d = DateTime(weekStart.year, weekStart.month, weekStart.day + i);
      return toYmd(d);
    });
  }
  
  /// 檢查兩個日期是否在同一週
  static bool isSameWeek(DateTime date1, DateTime date2) {
    return getWeekStart(date1) == getWeekStart(date2);
  }
  
  // ===========================================
  // 月相關計算
  // ===========================================
  
  /// 取得該月第一天
  static DateTime getMonthStart(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
  
  /// 取得該月最後一天
  static DateTime getMonthEnd(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }
  
  /// 取得該月天數
  static int getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }
  
  /// 取得該月第一天是星期幾 (0=週日, 1=週一...)
  static int getFirstWeekdayOfMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    return firstDay.weekday % 7;
  }
  
  /// 取得該月所有日期字串列表 (YYYY-MM-DD)
  static List<String> getMonthDates(DateTime date) {
    final days = getDaysInMonth(date);
    return List.generate(days, (i) {
      final d = DateTime(date.year, date.month, i + 1);
      return toYmd(d);
    });
  }
  
  /// 上個月
  static DateTime previousMonth(DateTime date) {
    return DateTime(date.year, date.month - 1, 1);
  }
  
  /// 下個月
  static DateTime nextMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 1);
  }
  
  // ===========================================
  // 日相關計算
  // ===========================================
  
  /// 上一天
  static DateTime previousDay(DateTime date) {
    return DateTime(date.year, date.month, date.day - 1);
  }
  
  /// 下一天
  static DateTime nextDay(DateTime date) {
    return DateTime(date.year, date.month, date.day + 1);
  }
  
  /// 檢查是否為今天
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  /// 檢查兩個日期是否為同一天
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }
  
  // ===========================================
  // 顯示用格式化
  // ===========================================
  
  /// 行事曆標題：月檢視
  /// 格式：2025 年 9 月
  static String formatMonthTitle(DateTime date) => toChineseYm(date);
  
  /// 行事曆標題：週檢視
  /// 格式：2025 年 9 月 1 日 ~ 2025 年 9 月 7 日
  static String formatWeekTitle(DateTime weekStart) => formatWeekRange(weekStart);
  
  /// 行事曆標題：日檢視
  /// 格式：2025 年 9 月 2 日 星期二 (今天)
  static String formatDayTitle(DateTime date) {
    final weekday = WeekdayMap.fullName[date.weekday - 1];
    final isToday = DateUtils.isToday(date);
    return '${toChineseYmd(date)} $weekday${isToday ? ' (今天)' : ''}';
  }
  
  /// 月曆格子：日期數字
  static String formatDayNumber(DateTime date) => date.day.toString();
  
  /// 週曆標題列：一\n09/01
  static String formatWeekHeader(DateTime date) {
    return '${WeekdayMap.shortName[date.weekday - 1]}\n${toMd(date)}';
  }
  
  /// 事件時間顯示：HH:mm-HH:mm
  static String formatEventTime(DateTime start, DateTime end) {
    return '${toHm(start)}-${toHm(end)}';
  }
  
  /// 相對時間：剛剛、X分鐘前、X小時前、X天前
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inSeconds < 60) return '剛剛';
    if (diff.inMinutes < 60) return '${diff.inMinutes} 分鐘前';
    if (diff.inHours < 24) return '${diff.inHours} 小時前';
    if (diff.inDays < 7) return '${diff.inDays} 天前';
    return toChineseYmd(date);
  }
  
  // ===========================================
  // 時區處理
  // ===========================================
  
  /// 確保 DateTime 在台北時區
    static DateTime ensureTaipeiTime(DateTime date) {
      final location = tz.getLocation('Asia/Taipei');
      if (date.isUtc) {
        return tz.TZDateTime.from(date, location);
      }
      // 假設無時區資訊的 DateTime 為本地時間
      return tz.TZDateTime.from(
        DateTime(date.year, date.month, date.day,
                 date.hour, date.minute, date.second,
                 date.millisecond, date.microsecond),
        location,
      );
    }
  
  /// 取得當前台北時間
  static tz.TZDateTime nowInTaipei() {
    return tz.TZDateTime.now(tz.getLocation('Asia/Taipei'));
  }
}