// 行事曆頁面
// 完整實作：月/週/日檢視、事件管理、1小時快取、Riverpod 狀態管理

import 'package:flutter/material.dart' hide DateUtils;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core.dart';

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
    return CalendarState(
      selectedDate: now,
      currentMonth: DateTime(now.year, now.month),
    );
  }

  /// 取得該日期所在週的起始日期 (週日 00:00:00)
  static DateTime getWeekStart(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final weekday = d.weekday % 7; // DateTime.weekday: 1=Mon, 7=Sun -> 0=Sun, 1=Mon...
    return d.subtract(Duration(days: weekday));
  }

  /// 檢查兩個日期是否為同一天
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// 切換檢視模式
  void setView(CalendarView view) {
    state = state.copyWith(view: view);
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
    state = state.copyWith(selectedDate: newDate);
    _loadEventsForView();
  }

  /// 切換日
  void changeDay(int delta) {
    final selected = state.selectedDate ?? DateTime.now();
    final newDate = selected.add(Duration(days: delta));
    state = state.copyWith(selectedDate: newDate);
    _loadEventsForView();
  }

  /// 跳到今天
  void goToToday() {
    final now = DateTime.now();
    state = state.copyWith(
      selectedDate: now,
      currentMonth: DateTime(now.year, now.month),
    );
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
      return cached.map((e) => CalendarEvent.fromApi(e as Map<String, dynamic>)).toList();
    }

    // 從 API 載入
    final events = await _endpoints.calendar.getMonthEvents(yearMonth: yearMonth);

    // 存入快取 (1小時) - 轉成 Map 列表避免 Hive 序列化 freezed
    try {
      final serializable = events.map((e) => {
        'id': e.id,
        'title': e.title,
        'typeCode': e.typeCode,
        'typeName': e.typeName,
        'startTime': e.startTime,
        'endTime': e.endTime,
        'allDay': e.allDay,
        'location': e.location,
        'info': e.info,
        'extendedInfo': e.extendedInfo,
        'color': e.color,
        'sequence': e.sequence,
        'date': e.date,
      }).toList();
      await _cache.set(CacheBoxes.calendar, cacheKey, serializable,
          fromJson: (json) => json as List<dynamic>, ttl: CacheTTL.calendar);
    } catch (_) {}
    return events;
  }

  /// 載入週事件 (使用快取)
  Future<List<CalendarEvent>> _loadWeekEvents() async {
    final selected = state.selectedDate ?? DateTime.now();
    final weekStart = getWeekStart(selected);
    final weekStartStr = '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
    final cacheKey = 'calendar_week_$weekStartStr';

    final cached = _cache.get<List<dynamic>>(
      CacheBoxes.calendar,
      cacheKey,
      fromJson: (json) => json as List<dynamic>,
    );
    if (cached != null) {
      return cached.map((e) => CalendarEvent.fromApi(e as Map<String, dynamic>)).toList();
    }

    final events = await _endpoints.calendar.getWeekEvents(weekStart: weekStartStr);

    try {
      final serializable = events.map((e) => {
        'id': e.id,
        'title': e.title,
        'typeCode': e.typeCode,
        'typeName': e.typeName,
        'startTime': e.startTime,
        'endTime': e.endTime,
        'allDay': e.allDay,
        'location': e.location,
        'info': e.info,
        'extendedInfo': e.extendedInfo,
        'color': e.color,
        'sequence': e.sequence,
        'date': e.date,
      }).toList();
      await _cache.set(CacheBoxes.calendar, cacheKey, serializable,
          fromJson: (json) => json as List<dynamic>, ttl: CacheTTL.calendar);
    } catch (_) {}
    return events;
  }

  /// 載入日事件 (使用快取)
  Future<List<CalendarEvent>> _loadDayEvents() async {
    final selected = state.selectedDate ?? DateTime.now();
    final dateStr = '${selected.year}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';
    final cacheKey = 'calendar_day_$dateStr';

    final cached = _cache.get<List<dynamic>>(
      CacheBoxes.calendar,
      cacheKey,
      fromJson: (json) => json as List<dynamic>,
    );
    if (cached != null) {
      return cached.map((e) => CalendarEvent.fromApi(e as Map<String, dynamic>)).toList();
    }

    final events = await _endpoints.calendar.getDayEvents(date: dateStr);

    try {
      final serializable = events.map((e) => {
        'id': e.id,
        'title': e.title,
        'typeCode': e.typeCode,
        'typeName': e.typeName,
        'startTime': e.startTime,
        'endTime': e.endTime,
        'allDay': e.allDay,
        'location': e.location,
        'info': e.info,
        'extendedInfo': e.extendedInfo,
        'color': e.color,
        'sequence': e.sequence,
        'date': e.date,
      }).toList();
      await _cache.set(CacheBoxes.calendar, cacheKey, serializable,
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
        .where((e) => e.parsedStartTime != null && CalendarNotifier.isSameDay(e.parsedStartTime!, date))
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
        );
      case CalendarView.week:
        return _WeekView(
          selectedDate: state.selectedDate ?? DateTime.now(),
          events: state.events,
          onDateSelected: notifier.selectDate,
          onWeekChanged: notifier.changeWeek,
        );
      case CalendarView.day:
        return _DayView(
          selectedDate: state.selectedDate ?? DateTime.now(),
          events: state.events,
          onDayChanged: notifier.changeDay,
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
  });

  final DateTime currentMonth;
  final DateTime? selectedDate;
  final List<CalendarEvent> events;
  final void Function(DateTime) onDateSelected;
  final void Function(int) onMonthChanged;

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0=Sunday
    final daysInMonth = lastDayOfMonth.day;

    final today = DateTime.now();
    final isCurrentMonth = currentMonth.year == today.year && currentMonth.month == today.month;

    // 事件按日期分組
    final eventsByDate = <DateTime, List<CalendarEvent>>{};
    for (final event in events) {
      final parsed = event.parsedStartTime;
      if (parsed != null) {
        final date = DateTime(parsed.year, parsed.month, parsed.day);
        eventsByDate.putIfAbsent(date, () => []).add(event);
      }
    }

    final weekdayNames = WeekdayMap.shortName;

    return Column(
      children: [
        // 月份導航
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => onMonthChanged(-1),
              ),
              Text(
                DateFormat('yyyy 年 M 月', 'zh_TW').format(currentMonth),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => onMonthChanged(1),
              ),
            ],
          ),
        ),

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

        // 日期格子
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: firstWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < firstWeekday) {
                return const SizedBox();
              }

              final day = index - firstWeekday + 1;
              final date = DateTime(currentMonth.year, currentMonth.month, day);
              final isToday = isCurrentMonth && day == today.day;
              final isSelected = selectedDate != null && CalendarNotifier.isSameDay(date, selectedDate!);
              final dayEvents = eventsByDate[date] ?? [];

              return _MonthDayCell(
                date: date,
                day: day,
                isToday: isToday,
                isSelected: isSelected,
                events: dayEvents,
                onTap: () => onDateSelected(date),
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
    required this.events,
    required this.onTap,
  });

  final DateTime date;
  final int day;
  final bool isToday;
  final bool isSelected;
  final List<CalendarEvent> events;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasEvents = events.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : isToday
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : null,
          borderRadius: BorderRadius.circular(12),
          border: isToday && !isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 日期數字
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '$day',
                style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w400,
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : isToday
                              ? theme.colorScheme.primary
                              : null,
                    ),
              ),
            ),

            // 事件指示器
            if (hasEvents) ...[
              const SizedBox(height: 4),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemCount: events.length.clamp(0, 3),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getEventColor(event),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        event.title,
                        style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              ),
              if (events.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '+${events.length - 3}',
                    style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getEventColor(CalendarEvent event) {
    // 根據事件類型返回顏色
    switch (event.typeCode) {
      case 'EXAM':
        return Colors.red;
      case 'ASSIGNMENT':
        return Colors.orange;
      case 'MEETING':
        return Colors.blue;
      case 'HOLIDAY':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }
}

/// 週檢視
class _WeekView extends StatelessWidget {
  const _WeekView({
    required this.selectedDate,
    required this.events,
    required this.onDateSelected,
    required this.onWeekChanged,
  });

  final DateTime selectedDate;
  final List<CalendarEvent> events;
  final void Function(DateTime) onDateSelected;
  final void Function(int) onWeekChanged;

  @override
  Widget build(BuildContext context) {
    final weekStart = CalendarNotifier.getWeekStart(selectedDate);
    final weekDays = List.generate(7, (i) => weekStart.add(Duration(days: i)));
    final today = DateTime.now();

    // 事件按日期分組
    final eventsByDate = <DateTime, List<CalendarEvent>>{};
    for (final event in events) {
      final parsed = event.parsedStartTime;
      if (parsed != null) {
        final date = DateTime(parsed.year, parsed.month, parsed.day);
        eventsByDate.putIfAbsent(date, () => []).add(event);
      }
    }

    return Column(
      children: [
        // 週導航
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => onWeekChanged(-1),
              ),
              Text(
                '${DateFormat('M/d', 'zh_TW').format(weekStart)} - ${DateFormat('M/d', 'zh_TW').format(weekStart.add(const Duration(days: 6)))}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => onWeekChanged(1),
              ),
            ],
          ),
        ),

        // 星期標題 + 事件列表
        Expanded(
          child: ListView(
            children: weekDays.map((day) {
              final isToday = CalendarNotifier.isSameDay(day, today);
              final isSelected = CalendarNotifier.isSameDay(day, selectedDate);
              final dayEvents = eventsByDate[day] ?? [];

              return _WeekDayColumn(
                date: day,
                isToday: isToday,
                isSelected: isSelected,
                events: dayEvents,
                onTap: () => onDateSelected(day),
              );
            }).toList(),
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
  });

  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final List<CalendarEvent> events;
  final VoidCallback onTap;

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
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : isToday
                  ? theme.colorScheme.primary.withValues(alpha: 0.05)
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
                      children: events.map((event) => _EventChip(event: event)).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 日檢視
class _DayView extends StatelessWidget {
  const _DayView({
    required this.selectedDate,
    required this.events,
    required this.onDayChanged,
  });

  final DateTime selectedDate;
  final List<CalendarEvent> events;
  final void Function(int) onDayChanged;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isToday = CalendarNotifier.isSameDay(selectedDate, today);

    // 過濾當日事件並按時間排序
    final dayEvents = events
        .where((e) => e.parsedStartTime != null && CalendarNotifier.isSameDay(e.parsedStartTime!, selectedDate))
        .toList()
      ..sort((a, b) {
        final aTime = a.parsedStartTime;
        final bTime = b.parsedStartTime;
        if (aTime == null || bTime == null) return 0;
        return aTime.compareTo(bTime);
      });

    return Column(
      children: [
        // 日導航
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => onDayChanged(-1),
              ),
              Column(
                children: [
                  Text(
                    DateFormat('EEEE', 'zh_TW').format(selectedDate),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  Text(
                    DateFormat('yyyy 年 M 月 d 日', 'zh_TW').format(selectedDate),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => onDayChanged(1),
              ),
            ],
          ),
        ),

        // 事件時間軸
        Expanded(
          child: dayEvents.isEmpty
              ? _buildEmptyState(context, isToday)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dayEvents.length,
                  itemBuilder: (context, index) {
                    final event = dayEvents[index];
                    return _EventCard(event: event);
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
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
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
  const _EventCard({required this.event});

  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final startTime = event.parsedStartTime != null ? DateFormat('HH:mm').format(event.parsedStartTime!) : '--:--';
    final endTime = event.parsedEndTime != null ? DateFormat('HH:mm').format(event.parsedEndTime!) : '--:--';
    final color = _getEventColor(event);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: 顯示事件詳情
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(event.title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('時間: $startTime - $endTime'),
                  if (event.location != null) Text('地點: ${event.location}'),
                  if (event.description != null) ...[
                    const SizedBox(height: 8),
                    Text('說明: ${event.description}'),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('關閉'),
                ),
              ],
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 時間 + 色條
              Column(
                children: [
                  Container(
                    width: 4,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              // 事件內容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
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
                        const Spacer(),
                        Text(
                          '$startTime - $endTime',
                          style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
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
            ],
          ),
        ),
      ),
    );
  }

  String _getEventTypeLabel(String typeCode) {
    switch (typeCode) {
      case 'EXAM':
        return '考試';
      case 'ASSIGNMENT':
        return '作業';
      case 'MEETING':
        return '會議';
      case 'HOLIDAY':
        return '假期';
      default:
        return '其他';
    }
  }

  Color _getEventColor(CalendarEvent event) {
    switch (event.typeCode) {
      case 'EXAM':
        return Colors.red;
      case 'ASSIGNMENT':
        return Colors.orange;
      case 'MEETING':
        return Colors.blue;
      case 'HOLIDAY':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }
}

/// 事件晶片 (週檢視用)
class _EventChip extends StatelessWidget {
  const _EventChip({required this.event});

  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final startTime = event.parsedStartTime != null ? DateFormat('HH:mm').format(event.parsedStartTime!) : '--:--';
    final color = _getEventColor(event);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  startTime,
                  style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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
    switch (event.typeCode) {
      case 'EXAM':
        return Colors.red;
      case 'ASSIGNMENT':
        return Colors.orange;
      case 'MEETING':
        return Colors.blue;
      case 'HOLIDAY':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }
}