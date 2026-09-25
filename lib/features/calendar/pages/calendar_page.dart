// 行事曆頁面
// 完整實作：月/週/日檢視、事件管理、1小時快取、Riverpod 狀態管理
// 包含事件詳細資訊頁面

import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter/gestures.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'dart:ui' as ui;

import '../../../core.dart';

/// 自動判斷是否需要跑馬燈的文字組件
class AutoMarquee extends StatelessWidget {
  const AutoMarquee({
    required this.text, required this.style, super.key,
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
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: ui.TextDirection.ltr,
        )..layout(minWidth: 0, maxWidth: double.infinity);

        final textWidth = textPainter.width;
        final containerWidth = constraints.maxWidth;

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
    this.eventsByMonth = const {},
    this.selectedDate,
    this.view = CalendarView.month,
    this.currentMonth,
    this.isLoading = false,
    this.error,
  });

  /// 多月份事件池：key 為 'yyyy-MM'，value 為該月份的事件列表
  final Map<String, List<CalendarEvent>> eventsByMonth;
  final DateTime? selectedDate;
  final CalendarView view;
  final DateTime? currentMonth;
  final bool isLoading;
  final String? error;

  /// 取得指定月份的事件
  List<CalendarEvent> getEventsForMonth(DateTime month) {
    final key = '${month.year}-${month.month.toString().padLeft(2, '0')}';
    return eventsByMonth[key] ?? const [];
  }

  /// 取得當前檢視月份的事件 (向後相容)
  List<CalendarEvent> get currentMonthEvents {
    if (currentMonth == null) return const [];
    return getEventsForMonth(currentMonth!);
  }

  CalendarState copyWith({
    Map<String, List<CalendarEvent>>? eventsByMonth,
    DateTime? selectedDate,
    CalendarView? view,
    DateTime? currentMonth,
    bool? isLoading,
    String? error,
  }) {
    return CalendarState(
      eventsByMonth: eventsByMonth ?? this.eventsByMonth,
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
    Future.microtask(() => _loadEventsForView());

    return CalendarState(
      selectedDate: now,
      currentMonth: DateTime(now.year, now.month),
      isLoading: true,
    );
  }

  static DateTime getWeekStart(DateTime date) {
    return DateUtils.getWeekStart(date);
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void setView(CalendarView view) {
    final oldView = state.view;
    state = state.copyWith(view: view);

    final currentMonth = state.currentMonth;
    final selectedDate = state.selectedDate;
    bool shouldReload = false;

    if (oldView == CalendarView.month && view != CalendarView.month) {
      if (currentMonth != null) {
        final key = '${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}';
        // 檢查事件池中是否已有資料
        shouldReload = !state.eventsByMonth.containsKey(key);
      } else {
        shouldReload = true;
      }
    } else if ((oldView == CalendarView.week || oldView == CalendarView.day) &&
        view == CalendarView.month) {
      shouldReload = true;
    } else if ((oldView == CalendarView.week && view == CalendarView.day) ||
        (oldView == CalendarView.day && view == CalendarView.week)) {
      if (currentMonth != null && selectedDate != null) {
        final key = '${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}';
        // 檢查事件池中是否已有資料
        shouldReload = !state.eventsByMonth.containsKey(key);
      } else {
        shouldReload = true;
      }
    }

    if (shouldReload) {
      _loadEventsForView();
    }
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void changeMonth(int delta) {
    final current = state.currentMonth ?? DateTime.now();
    final newMonth = DateTime(current.year, current.month + delta);
    state = state.copyWith(currentMonth: newMonth);
    _loadEventsForView();
  }

  void changeWeek(int delta) {
    final selected = state.selectedDate ?? DateTime.now();
    final newDate = selected.add(Duration(days: 7 * delta));
    final currentMonth = state.currentMonth;
    final newMonth = DateTime(newDate.year, newDate.month);
    final isSameMonth = currentMonth != null &&
        currentMonth.year == newMonth.year &&
        currentMonth.month == newMonth.month;

    state = state.copyWith(
      selectedDate: newDate,
      currentMonth: newMonth,
    );

    if (!isSameMonth) {
      final key = '${newMonth.year}-${newMonth.month.toString().padLeft(2, '0')}';
      if (!state.eventsByMonth.containsKey(key)) {
        _loadEventsForView();
      }
    }
  }

  void changeDay(int delta) {
    final selected = state.selectedDate ?? DateTime.now();
    final newDate = selected.add(Duration(days: delta));
    final currentMonth = state.currentMonth;
    final newMonth = DateTime(newDate.year, newDate.month);
    final isSameMonth = currentMonth != null &&
        currentMonth.year == newMonth.year &&
        currentMonth.month == newMonth.month;

    state = state.copyWith(
      selectedDate: newDate,
      currentMonth: newMonth,
    );

    if (!isSameMonth) {
      final key = '${newMonth.year}-${newMonth.month.toString().padLeft(2, '0')}';
      if (!state.eventsByMonth.containsKey(key)) {
        _loadEventsForView();
      }
    }
  }

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

    if (!isSameMonth) {
      _loadEventsForView();
    }
  }

  Future<void> _loadEventsForView() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final Map<String, List<CalendarEvent>> newEventsByMonth = Map.from(state.eventsByMonth);

      switch (state.view) {
        case CalendarView.month:
          final month = state.currentMonth ?? DateTime.now();
          await _loadMonthIntoPool(month, newEventsByMonth);
          // Prefetch adjacent months
          await _loadMonthIntoPool(DateTime(month.year, month.month - 1), newEventsByMonth);
          await _loadMonthIntoPool(DateTime(month.year, month.month + 1), newEventsByMonth);
          break;
        case CalendarView.week:
          final selected = state.selectedDate ?? DateTime.now();
          final weekStart = getWeekStart(selected);
          final weekMonth = DateTime(weekStart.year, weekStart.month);
          await _loadMonthIntoPool(weekMonth, newEventsByMonth);
          // Prefetch adjacent months
          await _loadMonthIntoPool(DateTime(weekMonth.year, weekMonth.month - 1), newEventsByMonth);
          await _loadMonthIntoPool(DateTime(weekMonth.year, weekMonth.month + 1), newEventsByMonth);
          break;
        case CalendarView.day:
          final selected = state.selectedDate ?? DateTime.now();
          final dayMonth = DateTime(selected.year, selected.month);
          await _loadMonthIntoPool(dayMonth, newEventsByMonth);
          // Prefetch adjacent months
          await _loadMonthIntoPool(DateTime(dayMonth.year, dayMonth.month - 1), newEventsByMonth);
          await _loadMonthIntoPool(DateTime(dayMonth.year, dayMonth.month + 1), newEventsByMonth);
          break;
      }

      state = state.copyWith(
        eventsByMonth: newEventsByMonth,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '載入行事曆失敗: $e',
      );
    }
  }

  /// 載入指定月份到事件池 (若已存在則跳過)
  Future<void> _loadMonthIntoPool(DateTime month, Map<String, List<CalendarEvent>> pool) async {
    final key = '${month.year}-${month.month.toString().padLeft(2, '0')}';
    if (pool.containsKey(key)) return; // 已有快取

    try {
      final events = await _loadMonthEvents(month);
      pool[key] = events;
    } catch (e) {
      // 單月載入失敗不影響其他月份
      pool[key] = [];
    }
  }

  Future<List<CalendarEvent>> _loadMonthEvents(DateTime month) async {
    final yearMonth = '${month.year}-${month.month.toString().padLeft(2, '0')}';
    final cacheKey = 'calendar_month_$yearMonth';

    final cached = _cache.get<List<dynamic>>(
      CacheBoxes.calendar,
      cacheKey,
      fromJson: (json) => json as List<dynamic>,
    );
    if (cached != null) {
      return cached
          .map((e) => CalendarEvent.fromApi(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    final events = await _endpoints.calendar.getMonthEvents(yearMonth: yearMonth);

    try {
      final serializable = events
          .map((e) => {
                'id': e.id,
                'title': e.title,
                'atype': e.typeCode,
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
              })
          .toList();
      await _cache.set(CacheBoxes.calendar, cacheKey, serializable,
          fromJson: (json) => json as List<dynamic>, ttl: CacheTTL.calendar);
    } catch (_) {}
    return events;
  }

  Future<void> refresh() async {
    final month = state.currentMonth ?? DateTime.now();
    await _cache.delete(CacheBoxes.calendar,
        'calendar_month_${month.year}-${month.month.toString().padLeft(2, '0')}');

    final selected = state.selectedDate ?? DateTime.now();
    final weekStart = getWeekStart(selected);
    final weekStartStr =
        '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
    await _cache.delete(CacheBoxes.calendar, 'calendar_week_$weekStartStr');

    final dateStr =
        '${selected.year}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';
    await _cache.delete(CacheBoxes.calendar, 'calendar_day_$dateStr');

    // Also clear the eventsByMonth pool for current and adjacent months
    final newEventsByMonth = Map<String, List<CalendarEvent>>.from(state.eventsByMonth);
    final currentMonthKey = '${month.year}-${month.month.toString().padLeft(2, '0')}';
    final prevMonthKey = '${month.year}-${(month.month - 1).toString().padLeft(2, '0')}';
    final nextMonthKey = '${month.year}-${(month.month + 1).toString().padLeft(2, '0')}';
    newEventsByMonth.remove(currentMonthKey);
    newEventsByMonth.remove(prevMonthKey);
    newEventsByMonth.remove(nextMonthKey);
    state = state.copyWith(eventsByMonth: newEventsByMonth);

    await _loadEventsForView();
  }

  List<CalendarEvent> getEventsForDate(DateTime date) {
    final month = DateTime(date.year, date.month);
    final monthEvents = state.getEventsForMonth(month);
    return monthEvents
        .where((e) =>
            e.eventDate != null && CalendarNotifier.isSameDay(e.eventDate!, date))
        .toList();
  }
}

final calendarProvider =
    AutoDisposeNotifierProvider<CalendarNotifier, CalendarState>(() {
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
              notifier.goToToday();
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
        child: state.isLoading && state.eventsByMonth.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
                ? _buildError(context, state.error!, notifier)
                : _buildCalendarView(context, state, notifier),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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

  Widget _buildError(
      BuildContext context, String error, CalendarNotifier notifier) {
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

  Widget _buildCalendarView(
      BuildContext context, CalendarState state, CalendarNotifier notifier) {
    switch (state.view) {
      case CalendarView.month:
        return _MonthView(
          currentMonth: state.currentMonth ?? DateTime.now(),
          selectedDate: state.selectedDate,
          eventsByMonth: state.eventsByMonth,
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
          eventsByMonth: state.eventsByMonth,
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
          eventsByMonth: state.eventsByMonth,
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
class _MonthView extends StatefulWidget {
  const _MonthView({
    required this.currentMonth,
    required this.selectedDate,
    required this.eventsByMonth,
    required this.onDateSelected,
    required this.onMonthChanged,
    required this.onEventTap,
  });

  final DateTime currentMonth;
  final DateTime? selectedDate;
  final Map<String, List<CalendarEvent>> eventsByMonth;
  final void Function(DateTime) onDateSelected;
  final void Function(int) onMonthChanged;
  final void Function(CalendarEvent) onEventTap;

  @override
  State<_MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<_MonthView> {
  static const int _initialPage = 1000000;
  late final PageController _pageController;
  late int _currentPage;
  late final DateTime _baseMonth; // 固定錨點月份，避免漂移

  @override
  void initState() {
    super.initState();
    _currentPage = _initialPage;
    _baseMonth = DateTime(widget.currentMonth.year, widget.currentMonth.month);
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void didUpdateWidget(covariant _MonthView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 只有在外部主動變更月份時（非滑動造成）才做動畫切換
    final targetPage = _getPageFromMonth(widget.currentMonth);
    if (targetPage != _currentPage) {
      _currentPage = targetPage;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _getMonthFromPage(int page) {
    final delta = page - _initialPage;
    return DateTime(_baseMonth.year, _baseMonth.month + delta);
  }

  int _getPageFromMonth(DateTime month) {
    final delta = (month.year - _baseMonth.year) * 12 + (month.month - _baseMonth.month);
    return _initialPage + delta;
  }

  void _onPageChanged(int page) {
    if (page != _currentPage) {
      final delta = page - _currentPage;
      _currentPage = page;
      widget.onMonthChanged(delta);
    }
  }

  void _handleScroll(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      if (event.scrollDelta.dy.abs() > 20) {
        final direction = event.scrollDelta.dy > 0 ? 1 : -1;
        final targetPage = _currentPage + direction;
        _pageController.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  /// 從事件池取得指定月份的事件並按日期分組
  Map<DateTime, List<CalendarEvent>> _getEventsByDateForMonth(DateTime month) {
    final key = '${month.year}-${month.month.toString().padLeft(2, '0')}';
    final monthEvents = widget.eventsByMonth[key] ?? [];
    final eventsByDate = <DateTime, List<CalendarEvent>>{};
    for (final event in monthEvents) {
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
    const weekdayNames = WeekdayMap.shortName;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.5),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: weekdayNames
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        Expanded(
          child: Listener(
            onPointerSignal: _handleScroll,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const PageScrollPhysics(),
              itemBuilder: (context, pageIndex) {
                final month = _getMonthFromPage(pageIndex);
                return _buildMonthGrid(context, month);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthGrid(BuildContext context, DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    final today = DateTime.now();
    final isCurrentMonth =
        month.year == today.year && month.month == today.month;

    // 取得當前月份的事件
    final currentMonthEventsByDate = _getEventsByDateForMonth(month);
    // 取得上個月的事件 (用於邊緣格子)
    final prevMonth = DateTime(month.year, month.month - 1);
    final prevMonthEventsByDate = _getEventsByDateForMonth(prevMonth);
    // 取得下個月的事件 (用於邊緣格子)
    final nextMonth = DateTime(month.year, month.month + 1);
    final nextMonthEventsByDate = _getEventsByDateForMonth(nextMonth);

    const int totalCells = 42;

    return LayoutBuilder(
      builder: (context, constraints) {
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
            final dayOffset = index - firstWeekday;

            if (dayOffset < 0) {
              final prevMonthLastDay =
                  DateTime(month.year, month.month, 0).day;
              final prevMonthDay = prevMonthLastDay + dayOffset + 1;
              final date =
                  DateTime(month.year, month.month - 1, prevMonthDay);
              final prevMonthEvents = prevMonthEventsByDate[date] ?? [];
              return _MonthDayCell(
                date: date,
                day: prevMonthDay,
                isToday: false,
                isSelected: false,
                isCurrentMonth: false,
                events: prevMonthEvents,
                onTap: () => widget.onDateSelected(date),
                onEventTap: widget.onEventTap,
              );
            } else if (dayOffset >= daysInMonth) {
              final nextMonthDay = dayOffset - daysInMonth + 1;
              final date =
                  DateTime(month.year, month.month + 1, nextMonthDay);
              final nextMonthEvents = nextMonthEventsByDate[date] ?? [];
              return _MonthDayCell(
                date: date,
                day: nextMonthDay,
                isToday: false,
                isSelected: false,
                isCurrentMonth: false,
                events: nextMonthEvents,
                onTap: () => widget.onDateSelected(date),
                onEventTap: widget.onEventTap,
              );
            } else {
              final day = dayOffset + 1;
              final date = DateTime(month.year, month.month, day);
              final isToday = isCurrentMonth && day == today.day;
              final isSelected = widget.selectedDate != null &&
                  CalendarNotifier.isSameDay(date, widget.selectedDate!);
              final dayEvents = currentMonthEventsByDate[date] ?? [];

              return _MonthDayCell(
                date: date,
                day: day,
                isToday: isToday,
                isSelected: isSelected,
                isCurrentMonth: true,
                events: dayEvents,
                onTap: () => widget.onDateSelected(date),
                onEventTap: widget.onEventTap,
              );
            }
          },
        );
      },
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
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
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
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '$day',
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: isToday || isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 2, vertical: 1),
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
    if (event.color != null && event.color!.isNotEmpty) {
      try {
        final colorStr = event.color!.replaceAll('#', '');
        if (colorStr.length == 6 || colorStr.length == 8) {
          return Color(int.parse('FF$colorStr', radix: 16));
        }
      } catch (_) {}
    }
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

/// 週檢視
class _WeekView extends StatefulWidget {
  const _WeekView({
    required this.selectedDate,
    required this.eventsByMonth,
    required this.onDateSelected,
    required this.onWeekChanged,
    required this.onEventTap,
  });

  final DateTime selectedDate;
  final Map<String, List<CalendarEvent>> eventsByMonth;
  final void Function(DateTime) onDateSelected;
  final void Function(int) onWeekChanged;
  final void Function(CalendarEvent) onEventTap;

  @override
  State<_WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<_WeekView> {
  static const int _initialPage = 1000000;
  late final PageController _pageController;
  late int _currentPage;
  late final DateTime _baseWeekStart; // 固定錨點週

  @override
  void initState() {
    super.initState();
    _currentPage = _initialPage;
    _baseWeekStart = CalendarNotifier.getWeekStart(widget.selectedDate);
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void didUpdateWidget(covariant _WeekView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentWeekStart = CalendarNotifier.getWeekStart(widget.selectedDate);
    final targetPage = _getPageFromWeekStart(currentWeekStart);
    if (targetPage != _currentPage) {
      _currentPage = targetPage;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _getWeekStartFromPage(int page) {
    final delta = page - _initialPage;
    return _baseWeekStart.add(Duration(days: 7 * delta));
  }

  int _getPageFromWeekStart(DateTime weekStart) {
    final delta = (weekStart.difference(_baseWeekStart).inDays / 7).round();
    return _initialPage + delta;
  }

  void _onPageChanged(int page) {
    if (page != _currentPage) {
      final delta = page - _currentPage;
      _currentPage = page;
      widget.onWeekChanged(delta);
    }
  }

  void _handleScroll(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      if (event.scrollDelta.dy.abs() > 20) {
        final direction = event.scrollDelta.dy > 0 ? 1 : -1;
        final targetPage = _currentPage + direction;
        _pageController.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  List<DateTime> _getWeekDays(DateTime weekStart) {
    return List.generate(7, (i) => weekStart.add(Duration(days: i)));
  }

  /// 從事件池取得指定週的所有事件並按日期分組
  Map<DateTime, List<CalendarEvent>> _getEventsByDateForWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    // 可能跨越兩個月份
    final startMonth = DateTime(weekStart.year, weekStart.month);
    final endMonth = DateTime(weekEnd.year, weekEnd.month);
    
    final eventsByDate = <DateTime, List<CalendarEvent>>{};
    
    // 收集週範圍內所有月份的事件
    DateTime currentMonth = startMonth;
    while (currentMonth.isBefore(endMonth.add(const Duration(days: 1))) || 
           (currentMonth.year == endMonth.year && currentMonth.month == endMonth.month)) {
      final key = '${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}';
      final monthEvents = widget.eventsByMonth[key] ?? [];
      for (final event in monthEvents) {
        final eventDay = event.eventDate;
        if (eventDay != null) {
          final date = DateTime(eventDay.year, eventDay.month, eventDay.day);
          // 只保留本週範圍內的事件
          if (!date.isBefore(weekStart) && !date.isAfter(weekEnd)) {
            eventsByDate.putIfAbsent(date, () => []).add(event);
          }
        }
      }
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    }
    
    return eventsByDate;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Column(
      children: [
        Expanded(
          child: Listener(
            onPointerSignal: _handleScroll,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const PageScrollPhysics(),
              itemBuilder: (context, pageIndex) {
                final weekStart = _getWeekStartFromPage(pageIndex);
                final weekDays = _getWeekDays(weekStart);
                final eventsByDate = _getEventsByDateForWeek(weekStart);

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: weekDays.map((day) {
                    final isToday = CalendarNotifier.isSameDay(day, today);
                    final isSelected =
                        CalendarNotifier.isSameDay(day, widget.selectedDate);
                    final dayEvents = eventsByDate[day] ?? [];

                    return _WeekDayColumn(
                      date: day,
                      isToday: isToday,
                      isSelected: isSelected,
                      events: dayEvents,
                      onTap: () => widget.onDateSelected(day),
                      onEventTap: widget.onEventTap,
                      showDateHeader: true,
                    );
                  }).toList(),
                );
              },
            ),
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
    this.showDateHeader = true,
  });

  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final List<CalendarEvent> events;
  final VoidCallback onTap;
  final void Function(CalendarEvent) onEventTap;
  final bool showDateHeader;

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
            if (showDateHeader) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weekdayName,
                    style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: isToday || isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isToday ? theme.colorScheme.primary : null,
                        ),
                  ),
                  Text(
                    dayNumber,
                    style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: isToday || isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
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
            ],
            Expanded(
              child: events.isEmpty
                  ? const SizedBox()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: events
                          .map((event) => _EventChip(
                              event: event, onTap: () => onEventTap(event)))
                          .toList(),
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
    required this.eventsByMonth,
    required this.onDayChanged,
    required this.onEventTap,
  });

  final DateTime selectedDate;
  final Map<String, List<CalendarEvent>> eventsByMonth;
  final void Function(int) onDayChanged;
  final void Function(CalendarEvent) onEventTap;

  @override
  State<_DayView> createState() => _DayViewState();
}

class _DayViewState extends State<_DayView> {
  static const int _initialPage = 1000000;
  late final PageController _pageController;
  late int _currentPage;
  late final DateTime _baseDate; // 固定錨點日

  @override
  void initState() {
    super.initState();
    _currentPage = _initialPage;
    _baseDate = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void didUpdateWidget(covariant _DayView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final targetPage = _getPageFromDate(widget.selectedDate);
    if (targetPage != _currentPage) {
      _currentPage = targetPage;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _getDateFromPage(int page) {
    final delta = page - _initialPage;
    return _baseDate.add(Duration(days: delta));
  }

  int _getPageFromDate(DateTime date) {
    final cleanDate = DateTime(date.year, date.month, date.day);
    final delta = cleanDate.difference(_baseDate).inDays;
    return _initialPage + delta;
  }

  void _onPageChanged(int page) {
    if (page != _currentPage) {
      final delta = page - _currentPage;
      _currentPage = page;
      widget.onDayChanged(delta);
    }
  }

  void _handleScroll(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      if (event.scrollDelta.dy.abs() > 20) {
        final direction = event.scrollDelta.dy > 0 ? 1 : -1;
        final targetPage = _currentPage + direction;
        _pageController.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  /// 從事件池取得指定日期的事件
  List<CalendarEvent> _getDayEvents(DateTime date) {
    final month = DateTime(date.year, date.month);
    final key = '${month.year}-${month.month.toString().padLeft(2, '0')}';
    final monthEvents = widget.eventsByMonth[key] ?? [];
    
    return monthEvents
        .where((e) =>
            e.eventDate != null && CalendarNotifier.isSameDay(e.eventDate!, date))
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

    return Column(
      children: [
        Expanded(
          child: Listener(
            onPointerSignal: _handleScroll,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const PageScrollPhysics(),
              itemBuilder: (context, pageIndex) {
                final currentDate = _getDateFromPage(pageIndex);
                final isToday = CalendarNotifier.isSameDay(currentDate, today);
                final dayEvents = _getDayEvents(currentDate);

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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
    if (event.color != null && event.color!.isNotEmpty) {
      try {
        final colorStr = event.color!.replaceAll('#', '');
        if (colorStr.length == 6 || colorStr.length == 8) {
          return Color(int.parse('FF$colorStr', radix: 16));
        }
      } catch (_) {}
    }
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
  const EventDetailPage({required this.event, super.key});

  final CalendarEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = _getEventColor(event);
    final startTime = event.parsedStartTime != null
        ? DateFormat('HH:mm').format(event.parsedStartTime!)
        : null;
    final endTime = event.parsedEndTime != null
        ? DateFormat('HH:mm').format(event.parsedEndTime!)
        : null;
    final eventDate = event.eventDate;
    final dateStr = eventDate != null
        ? DateFormat('yyyy 年 M 月 d 日 EEEE', 'zh_TW').format(eventDate)
        : '';

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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.5)),
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
            Text(
              event.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
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
                      if (event.extendedInfo != null &&
                          event.extendedInfo!.isNotEmpty) ...[
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
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.5)),
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
    if (event.color != null && event.color!.isNotEmpty) {
      try {
        final colorStr = event.color!.replaceAll('#', '');
        if (colorStr.length == 6 || colorStr.length == 8) {
          return Color(int.parse('FF$colorStr', radix: 16));
        }
      } catch (_) {}
    }
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