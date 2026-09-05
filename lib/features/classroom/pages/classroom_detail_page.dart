// 場地查詢 - 詳情頁
// 垂直時間軸佈局、可用時段、預約流程 (不實際送出)

import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core.dart';

/// 場地詳情狀態
@immutable
class ClassroomDetailState {
  const ClassroomDetailState({
    this.room,
    this.usage = const [],
    this.selectedDate,
    this.isLoading = false,
    this.isBooking = false,
    this.error,
  });

  final ClassroomDetail? room;
  final List<ClassroomUsage> usage;
  final DateTime? selectedDate;
  final bool isLoading;
  final bool isBooking;
  final String? error;

  ClassroomDetailState copyWith({
    ClassroomDetail? room,
    List<ClassroomUsage>? usage,
    DateTime? selectedDate,
    bool? isLoading,
    bool? isBooking,
    String? error,
  }) {
    return ClassroomDetailState(
      room: room ?? this.room,
      usage: usage ?? this.usage,
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading,
      isBooking: isBooking ?? this.isBooking,
      error: error,
    );
  }
}

/// 場地詳情 Notifier
class ClassroomDetailNotifier extends AutoDisposeNotifier<ClassroomDetailState> {
  late final Endpoints _endpoints;
  late final CacheService _cache;

  @override
  ClassroomDetailState build() {
    _endpoints = ref.read(endpointsProvider);
    _cache = ref.read(cacheServiceProvider);

    return const ClassroomDetailState(selectedDate: null);
  }

  /// 初始化 - 載入場地詳情與使用情況
  Future<void> initialize(String roomId, {DateTime? initialDate}) async {
    state = state.copyWith(isLoading: true, error: null, selectedDate: initialDate ?? DateTime.now());

    await Future.wait([
      _loadRoom(roomId),
      _loadUsage(roomId),
    ]);

    state = state.copyWith(isLoading: false);
  }

  /// 載入場地基本資訊
  Future<void> _loadRoom(String roomId) async {
    try {
      final cacheKey = 'classroom_detail_$roomId';
      Map<dynamic, dynamic>? cached;
      
      try {
        cached = _cache.getSimple<Map<dynamic, dynamic>>(CacheBoxes.classroom, cacheKey);
      } catch (e) {
        debugPrint('讀取場地快取失敗: $e');
        await _cache.remove(CacheBoxes.classroom, cacheKey);
      }

      if (cached != null) {
        try {
          final room = ClassroomDetail.fromJson(Map<String, dynamic>.from(cached));
          state = state.copyWith(room: room);
          return;
        } catch (e, stack) {
          debugPrint('解析場地快取失敗: $e\n$stack');
          await _cache.remove(CacheBoxes.classroom, cacheKey);
        }
      }

      final room = await _endpoints.classroom.getRoomDetail(roomId: roomId);

      if (room != null) {
        try {
          await _cache.setSimple(CacheBoxes.classroom, cacheKey, room.toJson(), ttl: CacheTTL.classroom);
        } catch (_) {}
        state = state.copyWith(room: room);
      }
    } catch (e, stack) {
      debugPrint('載入場地詳情失敗: $e\n$stack');
    }
  }

  /// 載入場地使用情況
  Future<void> _loadUsage(String roomId) async {
    final date = state.selectedDate ?? DateTime.now();
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    try {
      final usageResponse = await _endpoints.classroom.getUsage(
        roomId: roomId,
        date: dateStr,
      );

      if (usageResponse != null && usageResponse.success && usageResponse.data != null) {
        final usage = (usageResponse.data as List).cast<ClassroomUsage>();
        state = state.copyWith(usage: usage);
      }
    } catch (e) {
      debugPrint('載入場地使用情況失敗: $e');
    }
  }

  /// 切換日期
  void changeDate(DateTime date) {
    if (state.selectedDate != null && DateUtils.isSameDay(state.selectedDate!, date)) {
      return;
    }
    state = state.copyWith(selectedDate: date);
    if (state.room != null) {
      _loadUsage(state.room!.id);
    }
  }

  /// 取得連續可用時段
  List<TimeSlot> getAvailableSlots(DateTime date) {
    final slots = <TimeSlot>[];
    final dayUsage = state.usage
        .where((u) => DateUtils.isSameDay(DateTime.tryParse(u.date) ?? date, date))
        .toList();

    const openHour = 8;
    const closeHour = 22;

    DateTime current = DateTime(date.year, date.month, date.day, openHour);
    final endOfDay = DateTime(date.year, date.month, date.day, closeHour);

    for (final usage in dayUsage) {
      for (final timeSlot in usage.timeSlots) {
        if (timeSlot.status == 'busy' || timeSlot.status == 'pending') {
          final slotStart = DateTime(
            date.year,
            date.month,
            date.day,
            int.parse(timeSlot.startTime.split(':')[0]),
            int.parse(timeSlot.startTime.split(':')[1]),
          );
          final slotEnd = DateTime(
            date.year,
            date.month,
            date.day,
            int.parse(timeSlot.endTime.split(':')[0]),
            int.parse(timeSlot.endTime.split(':')[1]),
          );

          if (current.isBefore(slotStart)) {
            slots.add(TimeSlot(
              start: current,
              end: slotStart,
              isAvailable: true,
            ));
          }
          slots.add(TimeSlot(
            start: slotStart,
            end: slotEnd,
            isAvailable: false,
          ));
          current = slotEnd.isAfter(current) ? slotEnd : current;
        }
      }
    }

    if (current.isBefore(endOfDay)) {
      slots.add(TimeSlot(
        start: current,
        end: endOfDay,
        isAvailable: true,
      ));
    }

    return slots;
  }

  /// 模擬預約 (不實際送出)
  Future<bool> simulateBooking({
    required DateTime date,
    required int startHour,
    required int startMinute,
    required int durationHours,
    required String purpose,
  }) async {
    state = state.copyWith(isBooking: true);
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(isBooking: false);
    return true;
  }
}

/// 時間段資料類 (UI 顯示專用)
class TimeSlot {
  const TimeSlot({
    required this.start,
    required this.end,
    required this.isAvailable,
  });

  final DateTime start;
  final DateTime end;
  final bool isAvailable;

  int get durationMinutes => end.difference(start).inMinutes;

  String get timeRange =>
      '${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}';
}

/// 場地詳情 Provider
final classroomDetailProvider = AutoDisposeNotifierProvider<ClassroomDetailNotifier, ClassroomDetailState>(() {
  return ClassroomDetailNotifier();
});

/// 場地詳情頁面
class ClassroomDetailPage extends HookConsumerWidget {
  const ClassroomDetailPage({
    super.key,
    required this.roomId,
    this.initialDate,
  });

  final String roomId;
  final String? initialDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(classroomDetailProvider);
    final notifier = ref.read(classroomDetailProvider.notifier);

    useEffect(() {
      final date = initialDate != null ? DateTime.tryParse(initialDate!) : null;
      Future.microtask(() => notifier.initialize(roomId, initialDate: date));
      return null;
    }, [roomId]);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.room?.name ?? '場地詳情'),
        actions: [
          if (state.room != null)
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => _showDatePicker(context, notifier, state),
              tooltip: '選擇日期',
            ),
        ],
      ),
      body: state.isLoading && state.room == null
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _buildError(context, state.error!, notifier)
              : state.room == null
                  ? _buildNotFound(context)
                  : _buildDetail(context, state, notifier),
    );
  }

  Widget _buildError(BuildContext context, String error, ClassroomDetailNotifier notifier) {
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
              onPressed: () => notifier.initialize(roomId),
              icon: const Icon(Icons.refresh),
              label: const Text('重試'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.meeting_room_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '找不到場地',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '場地 ID: $roomId 不存在',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, ClassroomDetailState state, ClassroomDetailNotifier notifier) {
    final room = state.room!;
    final selectedDate = state.selectedDate ?? DateTime.now();
    final availableSlots = notifier.getAvailableSlots(selectedDate);

    return CustomScrollView(
      slivers: [
        // 場地基本資訊
        SliverToBoxAdapter(
          child: _buildRoomInfo(context, room),
        ),

        // 日期選擇器
        SliverToBoxAdapter(
          child: _buildDateSelector(context, selectedDate, notifier),
        ),

        // 時間軸標題
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  '${DateFormat('yyyy 年 M 月 d 日 EEEE', 'zh_TW').format(selectedDate)} 時段表',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                Text(
                  '開放時間 08:00-22:00',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),

        // 時間軸
        if (availableSlots.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('查無時段資料')),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final slot = availableSlots[index];
                return _TimeSlotCard(
                  slot: slot,
                  onTap: slot.isAvailable
                      ? () => _showBookingDialog(context, notifier, state, selectedDate, slot)
                      : null,
                );
              },
              childCount: availableSlots.length,
            ),
          ),

        // 底部預約按鈕
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              icon: const Icon(Icons.calendar_month),
              label: const Text('我要預約'),
              onPressed: state.isBooking || availableSlots.where((s) => s.isAvailable).isEmpty
                  ? null
                  : () => _showBookingDialog(
                        context,
                        notifier,
                        state,
                        selectedDate,
                        availableSlots.firstWhere((s) => s.isAvailable,
                            orElse: () => TimeSlot(
                                  start: selectedDate,
                                  end: selectedDate.add(const Duration(hours: 1)),
                                  isAvailable: false,
                                ))),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomInfo(BuildContext context, ClassroomDetail room) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getRoomIcon(room),
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      '${room.building ?? ''} ${room.location != null && room.location!.isNotEmpty ? "• ${room.location}" : ""}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 基本資訊網格
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.category_outlined,
                  label: '分類',
                  value: room.categoryName ?? '一般教室',
                ),
              ),
              Expanded(
                child: _InfoItem(
                  icon: Icons.people_outline,
                  label: '容量',
                  value: room.capacity != null ? '${room.capacity} 人' : '未標示',
                ),
              ),
              const Expanded(
                child: _InfoItem(
                  icon: Icons.access_time_outlined,
                  label: '開放',
                  value: '08:00-22:00',
                ),
              ),
            ],
          ),

          if (room.equipments.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: room.equipments.map((eq) => Chip(
                label: Text(eq),
                avatar: Icon(Icons.check_circle, size: 16, color: theme.colorScheme.primary),
                backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
                labelStyle: TextStyle(color: theme.colorScheme.onPrimaryContainer),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateSelector(
      BuildContext context, DateTime selectedDate, ClassroomDetailNotifier notifier) {
    final theme = Theme.of(context);
    final today = DateTime.now();

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = today.add(Duration(days: index));
          final isSelected = DateUtils.isSameDay(date, selectedDate);
          final isToday = DateUtils.isSameDay(date, today);

          return GestureDetector(
            onTap: () => notifier.changeDate(date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: isToday && !isSelected
                    ? Border.all(color: theme.colorScheme.primary, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE', 'zh_TW').format(date),
                    style: theme.textTheme.labelSmall?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d').format(date),
                    style: theme.textTheme.titleMedium?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.onPrimaryContainer
                              : isToday
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDatePicker(BuildContext context, ClassroomDetailNotifier notifier, ClassroomDetailState state) {
    showDatePicker(
      context: context,
      initialDate: state.selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((date) {
      if (date != null) {
        notifier.changeDate(date);
      }
    });
  }

  void _showBookingDialog(
      BuildContext context,
      ClassroomDetailNotifier notifier,
      ClassroomDetailState state,
      DateTime date,
      TimeSlot slot) {
    final startHourController = TextEditingController(
        text: DateFormat('HH').format(slot.start));
    final startMinController = TextEditingController(
        text: DateFormat('mm').format(slot.start));
    final durationController = TextEditingController(text: '1');
    final purposeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('預約場地 (模擬)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '場地: ${state.room?.name ?? ''}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '日期: ${DateFormat('yyyy 年 M 月 d 日 EEEE', 'zh_TW').format(date)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startHourController,
                      decoration: const InputDecoration(labelText: '時'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: startMinController,
                      decoration: const InputDecoration(labelText: '分'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: '時長 (小時)',
                  suffixText: '小時',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: purposeController,
                decoration: const InputDecoration(
                  labelText: '使用目的',
                  hintText: '例如: 社團活動、課程練習、會議...',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '此為模擬預約功能，不會實際送出預約請求',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await notifier.simulateBooking(
                date: date,
                startHour: int.tryParse(startHourController.text) ?? slot.start.hour,
                startMinute: int.tryParse(startMinController.text) ?? slot.start.minute,
                durationHours: int.tryParse(durationController.text) ?? 1,
                purpose: purposeController.text,
              );
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('模擬預約成功！(實際不送出)')),
                );
              }
            },
            child: const Text('確認預約'),
          ),
        ],
      ),
    ).then((_) {
      startHourController.dispose();
      startMinController.dispose();
      durationController.dispose();
      purposeController.dispose();
    });
  }

  IconData _getRoomIcon(ClassroomDetail room) {
    final name = room.name.toLowerCase();
    if (name.contains('電腦') || name.contains('computer') || name.contains('程式')) {
      return Icons.computer;
    }
    if (name.contains('語言') || name.contains('language')) {
      return Icons.translate;
    }
    if (name.contains('會議') || name.contains('meeting') || name.contains('討論')) {
      return Icons.meeting_room;
    }
    if (name.contains('實驗') || name.contains('lab')) {
      return Icons.science;
    }
    if (name.contains('視聽') || name.contains('av') || name.contains('多媒體')) {
      return Icons.tv;
    }
    return Icons.class_;
  }
}

/// 資訊項目
class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

/// 時間段卡片 (垂直時間軸)
class _TimeSlotCard extends StatelessWidget {
  const _TimeSlotCard({
    required this.slot,
    this.onTap,
  });

  final TimeSlot slot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final durationHours = slot.durationMinutes / 60;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: slot.isAvailable
              ? theme.colorScheme.primaryContainer.withOpacity(0.3)
              : theme.colorScheme.errorContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: slot.isAvailable
                ? theme.colorScheme.primary.withOpacity(0.5)
                : theme.colorScheme.error.withOpacity(0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 時間軸線 (移除 Expanded，改用固定高度容器，防止無邊界高度崩潰)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: slot.isAvailable
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 2,
                  height: 20,
                  color: slot.isAvailable
                      ? theme.colorScheme.primary.withOpacity(0.5)
                      : theme.colorScheme.error.withOpacity(0.5),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: slot.isAvailable
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16),

            // 時段資訊
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.timeRange,
                    style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: slot.isAvailable
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        slot.isAvailable ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: slot.isAvailable
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        slot.isAvailable ? '可預約' : '已被佔用',
                        style: theme.textTheme.bodyMedium?.copyWith(
                              color: slot.isAvailable
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${durationHours.toStringAsFixed(durationHours == durationHours.roundToDouble() ? 0 : 1)} 小時',
                        style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 箭頭
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}