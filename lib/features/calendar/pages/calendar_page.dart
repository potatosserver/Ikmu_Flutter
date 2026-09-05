// 行事曆頁面
// 完整實作：月/週/日檢視、事件管理、1小時快取、Riverpod 狀態管理
// 包含事件詳細資訊頁面

import 'package:flutter/material.dart' hide DateUtils;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'dart:ui' as ui;

import '../../../core.dart';

/// 自動判斷是否需要跑馬燈的文字組件
/// 使用 LayoutBuilder 量測文字實際寬度，超過容器寬度才啟動跑馬燈
class AutoMarquee extends StatelessWidget {
  const AutoMarquee({
    super.key,
    required this.text,
    required this.style,
    this.velocity = 30.0,
    this.blankSpace = 20.0,
  });

  final String text;
  final TextStyle? style;
  final double velocity;
  final double blankSpace;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 使用 TextPainter 量測文字實際寬度
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: ui.TextDirection.ltr,
        )..layout(minWidth: 0, maxWidth: double.infinity);

        final textWidth = textPainter.width;
        final containerWidth = constraints.maxWidth;

        // 文字寬度超過容器寬度才啟動跑馬燈
        if (textWidth > containerWidth) {
          return Marquee(
            text: text,
            style: style,
            scrollAxis: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            blankSpace: blankSpace,
            velocity: velocity,
            pauseAfterRound: Duration.zero,
            startPadding: 0.0,
            accelerationDuration: Duration.zero,
            accelerationCurve: Curves.linear,
            decelerationDuration: Duration.zero,
            decelerationCurve: Curves.linear,
          );
        }

        // 文字未溢出，正常顯示
        return Text(
          text,
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}

/// 行事曆檢視模式
enum CalendarView { month, week, day }

/// 行事曆狀態
@immutable
class CalendarState {
  const CalendarState({
    this.events = const [],
    this.selectedDate,
    this.view = CalendarView.month,
    this.currentMonth,
    this.isLoading = false,
    this.error,
  });

  final List<CalendarEvent> events;
  final DateTime? selectedDate;
  final CalendarView view;
  final DateTime? currentMonth;
  final bool isLoading;
  final String? error;

  CalendarState copyWith({
    List<CalendarEvent>? events,
    DateTime? selectedDate,
    CalendarView? view,
    DateTime? currentMonth,
    bool? isLoading,
    String? error,
  }) {
    return CalendarState(
      events: events ?? this.events,
      selectedDate: selectedDate ?? this.selectedDate,
      view: view ?? this.view,
      currentMonth: currentMonth ?? this.currentMonth,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 行事曆 Notifier
class CalendarNotifier extends AutoDisposeNotifier<CalendarState> {
  late final Endpoints _endpoints;
  late final CacheService _cache;

  @override
  CalendarState build() {
    _endpoints = ref.read(endpointsProvider);
    _cache = ref.read(cacheServiceProvider);

    final now = DateTime.now();
    
    // 在 Microtask 中觸發初次載入
    Future.microtask(() => _loadEventsForView());

    return CalendarState(
      selectedDate: now,
      currentMonth: DateTime(now.year, now.month),
      isLoading: true, // 初始設為載入中
    );
  }

  /// 取得該日期所在週的起始日期 (週日 00:00:00)
  static DateTime getWeekStart(DateTime date) {
    return DateUtils.getWeekStart(date);
  }

  /// 檢查兩個日期是否為同一天
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// 切換檢視模式
  void setView(CalendarView view) {
    final oldView = state.view;
    state = state.copyWith(view: view);
    
    // 只有在真正需要不同資料範圍時才重新載入
    // 月->週/日、週->日 可能需要更精確的資料，但月快取已包含所有
    // 週<->日 同一月份可共用快取
    final currentMonth = state.currentMonth;
    final selectedDate = state.selectedDate;
    
    bool shouldReload = false;
    
    if (oldView == CalendarView.month && view != CalendarView.month) {
      // 月檢視切換到週/日：若當月快取存在，不需重載
      if (currentMonth != null) {
        final cacheKey = 'calendar_month_${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}';
        final cached = _cache.get<List<dynamic>>(
          CacheBoxes.calendar,
          cacheKey,
          fromJson: (json) => json as List<dynamic>,
        );
        shouldReload = cached == null;
      } else {
        shouldReload = true;
      }
    } else if ((oldView == CalendarView.week || oldView == CalendarView.day) && view == CalendarView.month) {
      // 週/日切換到月：可能需要不同月份資料
      shouldReload = true;
    } else if ((oldView == CalendarView.week && view == CalendarView.day) || 
               (oldView == CalendarView.day && view == CalendarView.week)) {
      // 週<->日切換：同一月份可共用快取
      if (currentMonth != null && selectedDate != null) {
        final cacheKey = 'calendar_month_${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}';
        final cached = _cache.get<List<dynamic>>(
          CacheBoxes.calendar,
          cacheKey,
          fromJson: (json) => json as List<dynamic>,
        );
        shouldReload = cached == null;
      } else {
        shouldReload = true;
      }
    }
    
    if (shouldReload) {
      _loadEventsForView();
    }
  }

  /// 選擇日期
  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  /// 切換月份
  void changeMonth(int delta) {
    final current = state.currentMonth ?? DateTime.now();
    final newMonth = DateTime(current.year, current.month + delta);
    state = state.copyWith(currentMonth: newMonth);
    _loadEventsForView();
  }

  /// 切換週
  void changeWeek(int delta) {
    final selected = state.selectedDate ?? DateTime.now();
    final newDate = selected.add(Duration(days: 7 * delta));
    final currentMonth = state.currentMonth;
    final newMonth = DateTime(newDate.year, newDate.month);
    final isSameMonth = currentMonth != null &&
        currentMonth.year == newMonth.year &&
        currentMonth.month == newMonth.month;
    
    state = state.copyWith(selectedDate: newDate);
    
    // 只有月份改變且無快取時才重新載入
    if (!isSameMonth) {
      final cacheKey = 'calendar_month_${newMonth.year}-${newMonth.month.toString().padLeft(2, '0')}';
      final cached = _cache.get<List<dynamic>>(
        CacheBoxes.calendar,
        cacheKey,
        fromJson: (json) => json as List<dynamic>,
      );
      if (cached == null) {
        _loadEventsForView();
      }
    }
  }

  /// 切換日
  void changeDay(int delta) {
    final selected = state.selectedDate ?? DateTime.now();
    final newDate = selected.add(Duration(days: delta));
    final currentMonth = state.currentMonth;
    final newMonth = DateTime(newDate.year, newDate.month);
    final isSameMonth = currentMonth != null &&
        currentMonth.year == newMonth.year &&
        currentMonth.month == newMonth.month;
    
    state = state.copyWith(selectedDate: newDate);
    
    // 只有月份改變且無快取時才重新載入
    if (!isSameMonth) {
      final cacheKey = 'calendar_month_${newMonth.year}-${newMonth.month.toString().padLeft(2, '0')}';
      final cached = _cache.get<List<dynamic>>(
        CacheBoxes.calendar,
        cacheKey,
        fromJson: (json) => json as List<dynamic>,
      );
      if (cached == null) {
        _loadEventsForView();
      }
    }
  }

  /// 跳到今天
  void goToToday() {
    final now = DateTime.now();
    final currentMonth = state.currentMonth;
    final isSameMonth = currentMonth != null &&
        currentMonth.year == now.year &&
        currentMonth.month == now.month;
    
    state = state.copyWith(
      selectedDate: now,
      currentMonth: DateTime(now.year, now.month),
    );
    
    // 只有月份改變時才重新載入
    if (!isSameMonth) {
      _loadEventsForView();
    }
  }

  /// 根據目前檢視載入事件
  Future<void> _loadEventsForView() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      List<CalendarEvent> events = [];

      switch (state.view) {
        case CalendarView.month:
          events = await _loadMonthEvents();
          break;
        case CalendarView.week:
          events = await _loadWeekEvents();
          break;
        case CalendarView.day:
          events = await _loadDayEvents();
          break;
      }

      state = state.copyWith(
        events: events,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '載入行事曆失敗: $e',
      );
    }
  }

  /// 載入月份事件 (使用快取)
  Future<List<CalendarEvent>> _loadMonthEvents() async {
    final month = state.currentMonth ?? DateTime.now();
    final yearMonth = '${month.year}-${month.month.toString().padLeft(2, '0')}';
    final cacheKey = 'calendar_month_$yearMonth';

    // 檢查快取 (存的是 List<Map>，避免 Hive 序列化 freezed 類型)
    final cached = _cache.get<List<dynamic>>(
      CacheBoxes.calendar,
      cacheKey,
      fromJson: (json) => json as List<dynamic>,
    );
    if (cached != null) {
      // ✅ 使用 Map<String, dynamic>.from 進行深拷貝轉型
      return cached.map((e) => CalendarEvent.fromApi(Map<String, dynamic>.from(e as Map))).toList();
    }

    // 從 API 載入
    final events = await _endpoints.calendar.getMonthEvents(yearMonth: yearMonth);

    // 存入快取 (1小時) - 轉成 Map 列表避免 Hive 序列化 freezed
    // 注意：CalendarEvent.fromJson 期望 'atype' 鍵而非 'typeCode'，需與 API 回傳格式一致
    try {
      final serializable = events.map((e) => {
        'id': e.id,
        'title': e.title,
        'atype': e.typeCode,  // API 回傳鍵名為 'atype'
        'atype_name': e.typeName,
        'start_time': e.startTime,
        'end_time': e.endTime,
        'all_day': e.allDay,
        'location': e.location,
        'info': e.info,
        'einfo': e.extendedInfo,
        'color': e.color,
        'seq': e.sequence,
        'dateFrom': e.date,
      }).toList();
      await _cache.set(CacheBoxes.calendar, cacheKey, serializable,
          fromJson: (json) => json as List<dynamic>, ttl: CacheTTL.calendar);
    } catch (_) {}
    return events;
  }

  /// 載入週事件 (優先從已快取的整月資料提取，若無再抓取)
  Future<List<CalendarEvent>> _loadWeekEvents() async {
    final selected = state.selectedDate ?? DateTime.now();
    final yearMonth = '${selected.year}-${selected.month.toString().padLeft(2, '0')}';
    final weekStart = getWeekStart(selected);
    final weekStartStr = '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
    final weekCacheKey = 'calendar_week_$weekStartStr';

    // 1. 先嘗試讀取週快取
    final weekCached = _cache.get<List<dynamic>>(
      CacheBoxes.calendar,
      weekCacheKey,
      fromJson: (json) => json as List<dynamic>,
    );
    if (weekCached != null) {
      return weekCached.map((e) => CalendarEvent.fromApi(Map<String, dynamic>.from(e as Map))).toList();
    }

    // 2. 嘗試從月快取提取
    final monthCacheKey = 'calendar_month_$yearMonth';
    final monthCached = _cache.get<List<dynamic>>(
      CacheBoxes.calendar,
      monthCacheKey,
      fromJson: (json) => json as List<dynamic>,
    );
    if (monthCached != null) {
      final allEvents = monthCached.map((e) => CalendarEvent.fromApi(Map<String, dynamic>.from(e as Map))).toList();
      // 過濾該週事件並存入週快取
      final weekEvents = allEvents.where((e) {
        final ed = e.eventDate;
        return ed != null && !ed.isBefore(weekStart) && ed.isBefore(weekStart.add(const Duration(days: 7)));
      }).toList();
      // 存入週快取
      try {
        final serializable = weekEvents.map((e) => {
          'id': e.id, 'title': e.title, 'atype': e.typeCode, 'atype_name': e.typeName,
          'start_time': e.startTime, 'end_time': e.endTime, 'all_day': e.allDay,
          'location': e.location, 'info': e.info, 'einfo': e.extendedInfo,
          'color': e.color, 'seq': e.sequence, 'dateFrom': e.date,
        }).toList();
        await _cache.set(CacheBoxes.calendar, weekCacheKey, serializable,
            fromJson: (json) => json as List<dynamic>, ttl: CacheTTL.calendar);
      } catch (_) {}
      return weekEvents;
    }

    // 3. 從 API 載入該週 7 天
    final events = await _endpoints.calendar.getWeekEvents(weekStart: weekStartStr);
    // 存入週快取
    try {
      final serializable = events.map((e) => {
        'id': e.id, 'title': e.title, 'atype': e.typeCode, 'atype_name': e.typeName,
        'start_time': e.startTime, 'end_time': e.endTime, 'all_day': e.allDay,
        'location': e.location, 'info': e.info, 'einfo': e.extendedInfo,
        'color': e.color, 'seq': e.sequence, 'dateFrom': e.date,
      }).toList();
      await _cache.set(CacheBoxes.calendar, weekCacheKey, serializable,
          fromJson: (json) => json as List<dynamic>, ttl: CacheTTL.calendar);
    } catch (_) {}
    return events;
  }

  /// 載入日事件 (優先從已快取的整月/週資料提取)
  Future<List<CalendarEvent>> _loadDayEvents() async {
    final selected = state.selectedDate ?? DateTime.now();
    final yearMonth = '${selected.year}-${selected.month.toString().padLeft(2, '0')}';
    final dateStr = '${selected.year}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';
    final dayCacheKey = 'calendar_day_$dateStr';

    // 1. 先嘗試讀取日快取
    final dayCached = _cache.get<List<dynamic>>(
      CacheBoxes.calendar,
      dayCacheKey,
      fromJson: (json) => json as List<dynamic>,
    );
    if (dayCached != null) {
      return dayCached.map((e) => CalendarEvent.fromApi(Map<String, dynamic>.from(e as Map))).toList();
    }

    // 2. 嘗試從週快取提取
    final weekStart = getWeekStart(selected);
    final weekStartStr = '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
    final weekCacheKey = 'calendar_week_$weekStartStr';
    final weekCached = _cache.get<List<dynamic>>(
      CacheBoxes.calendar,
      weekCacheKey,
      fromJson: (json) => json as List<dynamic>,
    );
    if (weekCached != null) {
      final allEvents = weekCached.map((e) => CalendarEvent.fromApi(Map<String, dynamic>.from(e as Map))).toList();
      final dayEvents = allEvents.where((e) {
        final ed = e.eventDate;
        return ed != null && ed.year == selected.year && ed.month == selected.month && ed.day == selected.day;
      }).toList();
      // 存入日快取
      try {
        final serializable = dayEvents.map((e) => {
          'id': e.id, 'title': e.title, 'typeCode': e.typeCode, 'typeName': e.typeName,
          'startTime': e.startTime, 'endTime': e.endTime, 'allDay': e.allDay,
          'location': e.location, 'info': e.info, 'extendedInfo': e.extendedInfo,
          'color': e.color, 'sequence': e.sequence, 'date': e.date,
        }).toList();
        await _cache.set(CacheBoxes.calendar, dayCacheKey, serializable,
            fromJson: (json) => json as List<dynamic>, ttl: CacheTTL.calendar);
      } catch (_) {}
      return dayEvents;
    }

    // 3. 嘗試從月快取提取
    final monthCacheKey = 'calendar_month_$yearMonth';
    final monthCached = _cache.get<List<dynamic>>(
      CacheBoxes.calendar,
      monthCacheKey,
      fromJson: (json) => json as List<dynamic>,
    );
    if (monthCached != null) {
      final allEvents = monthCached.map((e) => CalendarEvent.fromApi(Map<String, dynamic>.from(e as Map))).toList();
      final dayEvents = allEvents.where((e) {
        final ed = e.eventDate;
        return ed != null && ed.year == selected.year && ed.month == selected.month && ed.day == selected.day;
      }).toList();
      // 存入日快取
      try {
        final serializable = dayEvents.map((e) => {
          'id': e.id, 'title': e.title, 'atype': e.typeCode, 'atype_name': e.typeName,
          'start_time': e.startTime, 'end_time': e.endTime, 'all_day': e.allDay,
          'location': e.location, 'info': e.info, 'einfo': e.extendedInfo,
          'color': e.color, 'seq': e.sequence, 'dateFrom': e.date,
        }).toList();
        await _cache.set(CacheBoxes.calendar, dayCacheKey, serializable,
            fromJson: (json) => json as List<dynamic>, ttl: CacheTTL.calendar);
      } catch (_) {}
      return dayEvents;
    }

    // 4. 從 API 載入單日
    final events = await _endpoints.calendar.getDayEvents(date: dateStr);
    // 存入日快取
    try {
      final serializable = events.map((e) => {
        'id': e.id, 'title': e.title, 'atype': e.typeCode, 'atype_name': e.typeName,
        'start_time': e.startTime, 'end_time': e.endTime, 'all_day': e.allDay,
        'location': e.location, 'info': e.info, 'einfo': e.extendedInfo,
        'color': e.color, 'seq': e.sequence, 'dateFrom': e.date,
      }).toList();
      await _cache.set(CacheBoxes.calendar, dayCacheKey, serializable,
          fromJson: (json) => json as List<dynamic>, ttl: CacheTTL.calendar);
    } catch (_) {}
    return events;
  }

  /// 刷新事件
  Future<void> refresh() async {
    // 清除相關快取
    final month = state.currentMonth ?? DateTime.now();
    await _cache.delete(CacheBoxes.calendar, 'calendar_month_${month.year}-${month.month.toString().padLeft(2, '0')}');

    final selected = state.selectedDate ?? DateTime.now();
    final weekStart = getWeekStart(selected);
    final weekStartStr = '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
    await _cache.delete(CacheBoxes.calendar, 'calendar_week_$weekStartStr');

    final dateStr = '${selected.year}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';
    await _cache.delete(CacheBoxes.calendar, 'calendar_day_$dateStr');

    await _loadEventsForView();
  }

  /// 取得指定日期的事件
  List<CalendarEvent> getEventsForDate(DateTime date) {
    return state.events
        .where((e) => e.eventDate != null && CalendarNotifier.isSameDay(e.eventDate!, date))
        .toList();
  }
}

/// 行事曆 Provider
final calendarProvider = AutoDisposeNotifierProvider<CalendarNotifier, CalendarState>(() {
  return CalendarNotifier();
});

/// 行事曆頁面
class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarProvider);
    final notifier = ref.read(calendarProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: _buildTitle(context, state),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              final now = DateTime.now();
              notifier.selectDate(now);
              notifier.goToToday();
              notifier._loadEventsForView();
            },
            tooltip: '今天',
          ),
          PopupMenuButton<CalendarView>(
            icon: const Icon(Icons.view_module),
            onSelected: notifier.setView,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: CalendarView.month,
                child: Text('月檢視'),
              ),
              const PopupMenuItem(
                value: CalendarView.week,
                child: Text('週檢視'),
              ),
              const PopupMenuItem(
                value: CalendarView.day,
                child: Text('日檢視'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: notifier.refresh,
            tooltip: '重新整理',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: notifier.refresh,
        child: state.isLoading && state.events.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
                ? _buildError(context, state.error!, notifier)
                : _buildCalendarView(context, state, notifier),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 新增事件
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('新增事件功能開發中')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, CalendarState state) {
    switch (state.view) {
      case CalendarView.month:
        final month = state.currentMonth ?? DateTime.now();
        return Text(DateFormat('yyyy 年 M 月', 'zh_TW').format(month));
      case CalendarView.week:
        final selected = state.selectedDate ?? DateTime.now();
        final weekStart = CalendarNotifier.getWeekStart(selected);
        final weekEnd = weekStart.add(const Duration(days: 6));
        return Text(
          '${DateFormat('M/d', 'zh_TW').format(weekStart)} - ${DateFormat('M/d', 'zh_TW').format(weekEnd)}',
        );
      case CalendarView.day:
        final selected = state.selectedDate ?? DateTime.now();
        return Text(DateFormat('yyyy 年 M 月 d 日 EEEE', 'zh_TW').format(selected));
    }
  }

  Widget _buildError(BuildContext context, String error, CalendarNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '載入失敗',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: notifier.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('重試'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView(BuildContext context, CalendarState state, CalendarNotifier notifier) {
    switch (state.view) {
      case CalendarView.month:
        return _MonthView(
          currentMonth: state.currentMonth ?? DateTime.now(),
          selectedDate: state.selectedDate,
          events: state.events,
          onDateSelected: notifier.selectDate,
          onMonthChanged: notifier.changeMonth,
          onEventTap: (event) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailPage(event: event),
              ),
            );
          },
        );
      case CalendarView.week:
        return _WeekView(
          selectedDate: state.selectedDate ?? DateTime.now(),
          events: state.events,
          onDateSelected: notifier.selectDate,
          onWeekChanged: notifier.changeWeek,
          onEventTap: (event) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailPage(event: event),
              ),
            );
          },
        );
      case CalendarView.day:
        return _DayView(
          selectedDate: state.selectedDate ?? DateTime.now(),
          events: state.events,
          onDayChanged: notifier.changeDay,
          onEventTap: (event) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailPage(event: event),
              ),
            );
          },
        );
    }
  }
}

/// 月檢視
class _MonthView extends StatelessWidget {
  const _MonthView({
    required this.currentMonth,
    required this.selectedDate,
    required this.events,
    required this.onDateSelected,
    required this.onMonthChanged,
    required this.onEventTap,
  });

  final DateTime currentMonth;
  final DateTime? selectedDate;
  final List<CalendarEvent> events;
  final void Function(DateTime) onDateSelected;
  final void Function(int) onMonthChanged;
  final void Function(CalendarEvent) onEventTap;

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    // 週日為起始: 0=Sun, 1=Mon, ..., 6=Sat
    final firstWeekday = firstDayOfMonth.weekday % 7; 
    final daysInMonth = lastDayOfMonth.day;

    final today = DateTime.now();
    final isCurrentMonth = currentMonth.year == today.year && currentMonth.month == today.month;

    // 事件按日期分組 - 使用 eventDate 取代 parsedStartTime
    final eventsByDate = <DateTime, List<CalendarEvent>>{};
    for (final event in events) {
      final eventDay = event.eventDate;
      if (eventDay != null) {
        final date = DateTime(eventDay.year, eventDay.month, eventDay.day);
        eventsByDate.putIfAbsent(date, () => []).add(event);
      }
    }

    // 7x6 固定 42 格 (6 週 x 7 天)
    const int totalCells = 42;
    // 週日在最左邊的星期標題
    final weekdayNames = WeekdayMap.shortName;

    return Column(
      children: [
        // 星期標題
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: weekdayNames.map((day) => Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    day,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ),
            )).toList(),
          ),
                  ),

                  // 日期格子 - 固定 6 週 (42 格)，高度平均填滿
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // 每列高度 = 可用高度 / 6
                        final cellHeight = constraints.maxHeight / 6;
                        final cellWidth = constraints.maxWidth / 7;
                        final aspectRatio = cellWidth / cellHeight;

                        return GridView.builder(
                          padding: const EdgeInsets.all(4),
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            childAspectRatio: aspectRatio,
                            mainAxisSpacing: 1,
                            crossAxisSpacing: 1,
                          ),
                          itemCount: totalCells,
                          itemBuilder: (context, index) {
                            // 計算該格子對應的日期
                            final dayOffset = index - firstWeekday;

                            if (dayOffset < 0) {
                              // 上個月的尾巴
                              final prevMonthLastDay = DateTime(currentMonth.year, currentMonth.month, 0).day;
                              final prevMonthDay = prevMonthLastDay + dayOffset + 1;
                              final date = DateTime(currentMonth.year, currentMonth.month - 1, prevMonthDay);
                              return _MonthDayCell(
                                date: date,
                                day: prevMonthDay,
                                isToday: false,
                                isSelected: false,
                                isCurrentMonth: false,
                                events: const [],
                                onTap: () => onDateSelected(date),
                                onEventTap: onEventTap,
                              );
                            } else if (dayOffset >= daysInMonth) {
                              // 下個月的開頭
                              final nextMonthDay = dayOffset - daysInMonth + 1;
                              final date = DateTime(currentMonth.year, currentMonth.month + 1, nextMonthDay);
                              return _MonthDayCell(
                                date: date,
                                day: nextMonthDay,
                                isToday: false,
                                isSelected: false,
                                isCurrentMonth: false,
                                events: const [],
                                onTap: () => onDateSelected(date),
                                onEventTap: onEventTap,
                              );
                            } else {
                              // 當月日期
                              final day = dayOffset + 1;
                              final date = DateTime(currentMonth.year, currentMonth.month, day);
                              final isToday = isCurrentMonth && day == today.day;
                              final isSelected = selectedDate != null && CalendarNotifier.isSameDay(date, selectedDate!);
                              final dayEvents = eventsByDate[date] ?? [];

                              return _MonthDayCell(
                                date: date,
                                day: day,
                                isToday: isToday,
                                isSelected: isSelected,
                                isCurrentMonth: true,
                                events: dayEvents,
                                onTap: () => onDateSelected(date),
                                onEventTap: onEventTap,
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          }

/// 月檢視日期格子
class _MonthDayCell extends StatelessWidget {
  const _MonthDayCell({
    required this.date,
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.isCurrentMonth,
    required this.events,
    required this.onTap,
    required this.onEventTap,
  });

  final DateTime date;
  final int day;
  final bool isToday;
  final bool isSelected;
  final bool isCurrentMonth;
  final List<CalendarEvent> events;
  final VoidCallback onTap;
  final void Function(CalendarEvent) onEventTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasEvents = events.isNotEmpty;
    final isDimmed = !isCurrentMonth;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.all(0.5),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : isToday
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : null,
          borderRadius: BorderRadius.circular(12),
          border: isToday && !isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: Opacity(
          opacity: isDimmed ? 0.4 : 1.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 日期數字
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '$day',
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w400,
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : isToday
                                ? theme.colorScheme.primary
                                : isDimmed
                                    ? theme.colorScheme.onSurfaceVariant
                                    : null,
                      ),
                ),
              ),

              // 事件指示器
              if (hasEvents) ...[
                const SizedBox(height: 2),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    itemCount: events.length.clamp(0, 4),
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return InkWell(
                        onTap: () => onEventTap(event),
                        borderRadius: BorderRadius.circular(3),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 0.5),
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                          decoration: BoxDecoration(
                            color: _getEventColor(event),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: SizedBox(
                          height: 16,
                          child: AutoMarquee(
                            text: event.title,
                            style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                            velocity: 30.0,
                            blankSpace: 15.0,
                          ),
                        ),
                        ),
                      );
                    },
                  ),
                ),
                if (events.length > 4)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      '+${events.length - 4}',
                      style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getEventColor(CalendarEvent event) {
    // 優先使用 API 回傳的 color 欄位
    if (event.color != null && event.color!.isNotEmpty) {
      try {
        final colorStr = event.color!.replaceAll('#', '');
        if (colorStr.length == 6 || colorStr.length == 8) {
          return Color(int.parse('FF$colorStr', radix: 16));
        }
      } catch (_) {}
    }
    // Fallback: 依據 KMU atype 代碼
    // '1'=一般活動, '2'=演講, '3'=活動, '4'=比賽, '5'=其他
    // 兼容舊版: EXAM, ASSIGNMENT, MEETING, HOLIDAY
    switch (event.typeCode) {
      case '1':
      case '2':
        return Colors.blue; // 演講/講座
      case '3':
      case '4':
        return Colors.green; // 活動/比賽
      case '5':
        return Colors.purple; // 其他
      case 'EXAM':
        return Colors.red;
      case 'ASSIGNMENT':
        return Colors.orange;
      case 'MEETING':
        return Colors.blue;
      case 'HOLIDAY':
        return Colors.green;
      default:
        return Colors.teal;
    }
  }
}

/// 週檢視
class _WeekView extends StatefulWidget {
  const _WeekView({
    required this.selectedDate,
    required this.events,
    required this.onDateSelected,
    required this.onWeekChanged,
    required this.onEventTap,
  });

  final DateTime selectedDate;
  final List<CalendarEvent> events;
  final void Function(DateTime) onDateSelected;
  final void Function(int) onWeekChanged;
  final void Function(CalendarEvent) onEventTap;

  @override
  State<_WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<_WeekView> {
  late final PageController _pageController;
  late DateTime _currentWeekStart;

  @override
  void initState() {
    super.initState();
    _currentWeekStart = CalendarNotifier.getWeekStart(widget.selectedDate);
    _pageController = PageController(initialPage: 1000); // 大頁碼作為中心，可雙向無限滑動
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    final delta = page - 1000;
    if (delta != 0) {
      _currentWeekStart = _currentWeekStart.add(Duration(days: 7 * delta));
      widget.onWeekChanged(delta);
      // 重置到中心頁避免邊界問題
      _pageController.jumpToPage(1000);
    }
  }

  List<DateTime> _getWeekDays(DateTime weekStart) {
    return List.generate(7, (i) => weekStart.add(Duration(days: i)));
  }

  Map<DateTime, List<CalendarEvent>> _groupEventsByDate(List<CalendarEvent> events) {
    final eventsByDate = <DateTime, List<CalendarEvent>>{};
    for (final event in events) {
      final eventDay = event.eventDate;
      if (eventDay != null) {
        final date = DateTime(eventDay.year, eventDay.month, eventDay.day);
        eventsByDate.putIfAbsent(date, () => []).add(event);
      }
    }
    return eventsByDate;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final weekdayNames = WeekdayMap.shortName;

    return Column(
      children: [
        // 週標題列 - 固定在最上方，字體放大
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: List.generate(7, (i) {
              final day = _getWeekDays(_currentWeekStart)[i];
              final isToday = CalendarNotifier.isSameDay(day, today);
              final isSelected = CalendarNotifier.isSameDay(day, widget.selectedDate);
              return Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        weekdayNames[i],
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: isToday
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 20,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : isToday
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),

        // 事件列表 - 使用 PageView 實現左右滑動切換週
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const ClampingScrollPhysics(),
            itemBuilder: (context, pageIndex) {
              final weekStart = _currentWeekStart;
              final weekDays = _getWeekDays(weekStart);
              final eventsByDate = _groupEventsByDate(widget.events);

              return ListView(
                padding: const EdgeInsets.all(16),
                children: weekDays.map((day) {
                  final isToday = CalendarNotifier.isSameDay(day, today);
                  final isSelected = CalendarNotifier.isSameDay(day, widget.selectedDate);
                  final dayEvents = eventsByDate[day] ?? [];

                  return _WeekDayColumn(
                    date: day,
                    isToday: isToday,
                    isSelected: isSelected,
                    events: dayEvents,
                    onTap: () => widget.onDateSelected(day),
                    onEventTap: widget.onEventTap,
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 週檢視日期欄
class _WeekDayColumn extends StatelessWidget {
  const _WeekDayColumn({
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.events,
    required this.onTap,
    required this.onEventTap,
  });

  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final List<CalendarEvent> events;
  final VoidCallback onTap;
  final void Function(CalendarEvent) onEventTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekdayName = DateFormat('EEEE', 'zh_TW').format(date);
    final dayNumber = DateFormat('d').format(date);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withOpacity( 0.3)
              : isToday
                  ? theme.colorScheme.primary.withOpacity( 0.05)
                  : null,
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outlineVariant,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日期資訊
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weekdayName,
                  style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: isToday || isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isToday ? theme.colorScheme.primary : null,
                      ),
                ),
                Text(
                  dayNumber,
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w400,
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : isToday
                                ? theme.colorScheme.primary
                                : null,
                      ),
                ),
              ],
            ),

            const SizedBox(width: 16),

            // 事件列表
            Expanded(
              child: events.isEmpty
                  ? const SizedBox()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: events.map((event) => _EventChip(event: event, onTap: () => onEventTap(event))).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 日檢視
class _DayView extends StatefulWidget {
  const _DayView({
    required this.selectedDate,
    required this.events,
    required this.onDayChanged,
    required this.onEventTap,
  });

  final DateTime selectedDate;
  final List<CalendarEvent> events;
  final void Function(int) onDayChanged;
  final void Function(CalendarEvent) onEventTap;

  @override
  State<_DayView> createState() => _DayViewState();
}

class _DayViewState extends State<_DayView> {
  late final PageController _pageController;
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.selectedDate;
    _pageController = PageController(initialPage: 1000);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    final delta = page - 1000;
    if (delta != 0) {
      _currentDate = _currentDate.add(Duration(days: delta));
      widget.onDayChanged(delta);
      _pageController.jumpToPage(1000);
    }
  }

  List<CalendarEvent> _getDayEvents(DateTime date, List<CalendarEvent> events) {
    return events
        .where((e) => e.eventDate != null && CalendarNotifier.isSameDay(e.eventDate!, date))
        .toList()
      ..sort((a, b) {
        final aTime = a.parsedStartTime ?? a.eventDate;
        final bTime = b.parsedStartTime ?? b.eventDate;
        if (aTime == null || bTime == null) return 0;
        return aTime.compareTo(bTime);
      });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isToday = CalendarNotifier.isSameDay(_currentDate, today);

    return Column(
      children: [
        // 日期標題列 - 固定在最上方，字體放大，移除左右切換鈕
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('yyyy 年 M 月 d 日 EEEE', 'zh_TW').format(_currentDate),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: isToday ? Theme.of(context).colorScheme.primary : null,
                    ),
              ),
            ],
          ),
        ),

        // 事件時間軸 - 使用 PageView 實現左右滑動切換日
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const ClampingScrollPhysics(),
            itemBuilder: (context, pageIndex) {
              final dayEvents = _getDayEvents(_currentDate, widget.events);

              return dayEvents.isEmpty
                  ? _buildEmptyState(context, isToday)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: dayEvents.length,
                      itemBuilder: (context, index) {
                        final event = dayEvents[index];
                        return _EventCard(
                          event: event,
                          onTap: () => widget.onEventTap(event),
                        );
                      },
                    );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isToday) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isToday ? '今天沒有行程' : '這一天沒有行程',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '享受輕鬆的一天吧！',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

/// 事件卡片
class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, this.onTap});

  final CalendarEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getEventColor(event);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getEventTypeLabel(event.typeCode),
                      style: theme.textTheme.labelSmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 24,
                child: AutoMarquee(
                  text: event.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  velocity: 30.0,
                  blankSpace: 20.0,
                ),
              ),
              if (event.location != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getEventTypeLabel(String typeCode) {
    // KMU atype: '1'=一般活動, '2'=演講, '3'=活動, '4'=比賽, '5'=其他
    // 兼容舊版: EXAM, ASSIGNMENT, MEETING, HOLIDAY
    switch (typeCode) {
      case '1':
        return '一般活動';
      case '2':
        return '專案演講';
      case '3':
        return '校園活動';
      case '4':
        return '競賽活動';
      case '5':
        return '其他';
      case 'EXAM':
        return '考試';
      case 'ASSIGNMENT':
        return '作業';
      case 'MEETING':
        return '會議';
      case 'HOLIDAY':
        return '假期';
      default:
        return '活動';
    }
  }

  Color _getEventColor(CalendarEvent event) {
    // 優先使用 API 回傳的 color 欄位
    if (event.color != null && event.color!.isNotEmpty) {
      try {
        final colorStr = event.color!.replaceAll('#', '');
        if (colorStr.length == 6 || colorStr.length == 8) {
          return Color(int.parse('FF$colorStr', radix: 16));
        }
      } catch (_) {}
    }
    // Fallback: KMU atype 代碼映射
    switch (event.typeCode) {
      case '1':
      case '2':
        return Colors.blue;
      case '3':
      case '4':
        return Colors.green;
      case '5':
        return Colors.purple;
      case 'EXAM':
        return Colors.red;
      case 'ASSIGNMENT':
        return Colors.orange;
      case 'MEETING':
        return Colors.blue;
      case 'HOLIDAY':
        return Colors.green;
      default:
        return Colors.teal;
    }
  }
}


/// 事件詳細資訊頁面
class EventDetailPage extends ConsumerWidget {
  const EventDetailPage({super.key, required this.event});

  final CalendarEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = _getEventColor(event);
    final startTime = event.parsedStartTime != null ? DateFormat('HH:mm').format(event.parsedStartTime!) : null;
    final endTime = event.parsedEndTime != null ? DateFormat('HH:mm').format(event.parsedEndTime!) : null;
    final eventDate = event.eventDate;
    final dateStr = eventDate != null ? DateFormat('yyyy 年 M 月 d 日 EEEE', 'zh_TW').format(eventDate) : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(_getEventTypeLabel(event.typeCode)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 類型標籤
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event, size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(
                    _getEventTypeLabel(event.typeCode),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 標題
            Text(
              event.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),

            // 基本資訊卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '基本資訊',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      Icons.calendar_today,
                      '日期',
                      dateStr,
                    ),
                    if (startTime != null || endTime != null)
                      _buildInfoRow(
                        context,
                        Icons.access_time,
                        '時間',
                        '${startTime ?? '--:--'} - ${endTime ?? '--:--'}',
                      ),
                    if (event.location != null && event.location!.isNotEmpty)
                      _buildInfoRow(
                        context,
                        Icons.location_on,
                        '地點',
                        event.location!,
                      ),
                    if (event.typeName != null && event.typeName!.isNotEmpty)
                      _buildInfoRow(
                        context,
                        Icons.category,
                        '類型',
                        event.typeName!,
                      ),
                    if (event.allDay)
                      _buildInfoRow(
                        context,
                        Icons.all_inclusive,
                        '全天事件',
                        '是',
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 詳細說明
            if (event.info != null && event.info!.isNotEmpty ||
                event.extendedInfo != null && event.extendedInfo!.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '詳細說明',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (event.info != null && event.info!.isNotEmpty) ...[
                        Text(
                          event.info!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (event.extendedInfo != null && event.extendedInfo!.isNotEmpty) ...[
                        Text(
                          event.extendedInfo!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 系統資訊
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '系統資訊',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      Icons.fingerprint,
                      '事件 ID',
                      event.id,
                    ),
                    if (event.sequence != null)
                      _buildInfoRow(
                        context,
                        Icons.format_list_numbered,
                        '序號',
                        event.sequence.toString(),
                      ),
                    if (event.color != null && event.color!.isNotEmpty)
                      _buildInfoRow(
                        context,
                        Icons.palette,
                        '顏色代碼',
                        event.color!,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(CalendarEvent event) {
    // KMU atype: '1'=一般活動, '2'=演講, '3'=活動, '4'=比賽, '5'=其他
    // 兼容舊版: EXAM, ASSIGNMENT, MEETING, HOLIDAY
    switch (event.typeCode) {
      case '1':
      case '2':
        return Colors.blue;
      case '3':
      case '4':
        return Colors.green;
      case '5':
        return Colors.purple;
      case 'EXAM':
        return Colors.red;
      case 'ASSIGNMENT':
        return Colors.orange;
      case 'MEETING':
        return Colors.blue;
      case 'HOLIDAY':
        return Colors.green;
      default:
        return Colors.teal;
    }
  }

  String _getEventTypeLabel(String typeCode) {
    switch (typeCode) {
      case '1':
        return '一般活動';
      case '2':
        return '專案演講';
      case '3':
        return '校園活動';
      case '4':
        return '競賽活動';
      case '5':
        return '其他';
      case 'EXAM':
        return '考試';
      case 'ASSIGNMENT':
        return '作業';
      case 'MEETING':
        return '會議';
      case 'HOLIDAY':
        return '假期';
      default:
        return '活動';
    }
  }
}

/// 事件晶片 (週檢視用)
class _EventChip extends StatelessWidget {
  const _EventChip({required this.event, this.onTap});

  final CalendarEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getEventColor(event);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 20,
                              child: AutoMarquee(
                                text: event.title,
                                style: theme.textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: color,
                                    ),
                                velocity: 30.0,
                                blankSpace: 20.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Color _getEventColor(CalendarEvent event) {
    // 優先使用 API 回傳的 color 欄位
    if (event.color != null && event.color!.isNotEmpty) {
      try {
        final colorStr = event.color!.replaceAll('#', '');
        if (colorStr.length == 6 || colorStr.length == 8) {
          return Color(int.parse('FF$colorStr', radix: 16));
        }
      } catch (_) {}
    }
    // Fallback: 依據 KMU atype 代碼
    // '1'=一般活動, '2'=演講, '3'=活動, '4'=比賽, '5'=其他
    // 兼容舊版: EXAM, ASSIGNMENT, MEETING, HOLIDAY
    switch (event.typeCode) {
      case '1':
      case '2':
        return Colors.blue;
      case '3':
      case '4':
        return Colors.green;
      case '5':
        return Colors.purple;
      case 'EXAM':
        return Colors.red;
      case 'ASSIGNMENT':
        return Colors.orange;
      case 'MEETING':
        return Colors.blue;
      case 'HOLIDAY':
        return Colors.green;
      default:
        return Colors.teal;
    }
  }
}