// 課表頁面
// 學期切換、週課表網格、課程詳情、Riverpod 狀態管理

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core.dart' hide DateUtils;

/// 課表狀態
@immutable
class ScheduleState {
  const ScheduleState({
    this.semesters = const [],
    this.currentSemester,
    this.courses = const [],
    this.scheduleData,
    this.selectedWeekday,
    this.isLoading = false,
    this.error,
  });

  final List<SemesterInfo> semesters;
  final String? currentSemester;
  final List<Course> courses;
  final ScheduleData? scheduleData;
  final int? selectedWeekday; // 1-7 (Mon-Sun)
  final bool isLoading;
  final String? error;

  ScheduleState copyWith({
    List<SemesterInfo>? semesters,
    String? currentSemester,
    List<Course>? courses,
    ScheduleData? scheduleData,
    int? selectedWeekday,
    bool? isLoading,
    String? error,
  }) {
    return ScheduleState(
      semesters: semesters ?? this.semesters,
      currentSemester: currentSemester ?? this.currentSemester,
      courses: courses ?? this.courses,
      scheduleData: scheduleData ?? this.scheduleData,
      selectedWeekday: selectedWeekday ?? this.selectedWeekday,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 課表 Notifier
class ScheduleNotifier extends AutoDisposeNotifier<ScheduleState> {
  late final Endpoints _endpoints;
  late final CacheService _cache;

  @override
  ScheduleState build() {
    _endpoints = ref.read(endpointsProvider);
    _cache = ref.read(cacheServiceProvider);

    // 延遲載入，避免在 build 階段修改 state
    Future.microtask(() => _loadSchedule());
    return const ScheduleState(isLoading: true);
  }

  /// 載入課表
  Future<void> _loadSchedule() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      const cacheKey = 'schedule_data';
      final cached = _cache.getSimple<Map<dynamic, dynamic>>(CacheBoxes.courses, cacheKey);

      if (cached != null && cached['_schedule_data'] == true) {
        // Cache 存的是 Map 格式，需要轉換 (Hive 回傳 Map<dynamic, dynamic>)
        final data = ScheduleData.fromJson(Map<String, dynamic>.from(cached['data'] as Map<dynamic, dynamic>));
        _processScheduleData(data);
        return;
      }

      // 取得當前登入的使用者憑證
      final credentials = ref.read(currentUserCredentialsProvider);
      if (credentials == null) {
        throw Exception('請先登入');
      }

      final userId = credentials['userId']!;
      final password = credentials['password']!;

      // 取得學期清單
      final semesters = await _endpoints.courses.getSemesters(
        userId: userId,
        password: password,
      );
      print('[ScheduleNotifier] 學期清單: ${semesters.length} 筆');

      // 取得課表 (Python: myclass_list 只要 id, pw，不需要 semester_id)
      final response = await _endpoints.courses.getSchedule(
        userId: userId,
        password: password,
      );

      if (response != null && response.success && response.data != null) {
        final data = response.data!;
        // 避免 Hive 無法序列化 freezed 類型，存為 Map
        try {
          await _cache.setSimple(
            CacheBoxes.courses,
            cacheKey,
            {'_schedule_data': true, 'data': data.toJson()},
            ttl: CacheTTL.courses,
          );
        } catch (_) {}
        _processScheduleData(data, semesters);
      } else {
        throw Exception(response?.message ?? 'Unknown error');
      }
    } catch (e) {
      print('[ScheduleNotifier] 載入課表失敗: $e');
      state = state.copyWith(
        isLoading: false,
        error: '載入課表失敗: $e',
      );
    }
  }

  void _processScheduleData(ScheduleData data, [List<SemesterInfo>? semesters]) {
    final sems = semesters ?? state.semesters;
    // 去除重複 semester (用 id 去重)
    final uniqueSemesters = <String, SemesterInfo>{};
    for (final s in sems) {
      if (!uniqueSemesters.containsKey(s.id)) {
        uniqueSemesters[s.id] = s;
      }
    }
    final uniqueList = uniqueSemesters.values.toList();

    // 預設選擇「有課程的第一個星期」而不是「今天」
    int? defaultWeekday;
    for (int day = 1; day <= 7; day++) {
      if (data.courses.any((c) => c.weekday == day)) {
        defaultWeekday = day;
        break;
      }
    }
    // 如果完全沒課程，defaultWeekday 保持 null (顯示「請選擇星期」)

    state = state.copyWith(
      semesters: uniqueList,
      currentSemester: data.semester ?? (uniqueList.isNotEmpty ? uniqueList.first.id : null),
      courses: data.courses,
      scheduleData: data,
      selectedWeekday: defaultWeekday,
      isLoading: false,
      error: null,
    );
  }

  /// 取得指定星期的課程
  List<Course> getCoursesForWeekday(int weekday) {
    return state.courses.where((c) => c.weekday == weekday).toList()
      ..sort((a, b) => a.parsedStartTime?.compareTo(b.parsedStartTime ?? DateTime.now()) ?? 0);
  }

  /// 刷新
  Future<void> refresh() async {
    await _cache.remove(CacheBoxes.courses, 'schedule_data');
    await _loadSchedule();
  }

  /// 顯示課程詳細資料 Dialog
  void showCourseDetail(BuildContext context, Course course) {
    // 從 course.id 解析 seqno (格式: year-sem-seqno)
    final parts = course.id.split('-');
    final seq = parts.length >= 3 ? parts[2].trim() : '';

    // 預先抓取詳細資料
    late final Future<Map<String, dynamic>?> detailFuture;
    if (seq.isNotEmpty) {
      final credentials = ref.read(currentUserCredentialsProvider);
      if (credentials != null) {
        detailFuture = _endpoints.courses.getClassDetail(
          seq: seq,
          userId: credentials['userId']!,
          password: credentials['password']!,
        );
      } else {
        detailFuture = Future.value(null);
      }
    } else {
      detailFuture = Future.value(null);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FutureBuilder<Map<String, dynamic>?>(
        future: detailFuture,
        builder: (context, snapshot) {
          final detail = snapshot.data;
          final d = detail ?? {};
          final outline = (d['outline'] as List?)?.isNotEmpty == true ? d['outline'][0] as Map<String, dynamic>? : null;

          final textbooks = (d['textbook'] as List?)?.isNotEmpty == true
              ? d['textbook'].map((t) => t.toString()).join('\n')
              : '無指定教科書 / 隨堂發放講義';

          return AlertDialog(
            title: Text(d['chineseco']?.toString() ?? course.name),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else ...[
                      // 基本資訊
                      _buildSection(context, '基本資訊', [
                        _DetailRow('課程名稱 (中)', d['chineseco']?.toString() ?? '-'),
                        _DetailRow('課程名稱 (英)', d['englishco']?.toString() ?? '-'),
                        _DetailRow('開課單位', d['deptnam']?.toString() ?? d['edeptnam']?.toString() ?? '-'),
                        _DetailRow('授課教師', d['teafnam']?.toString() ?? d['teafenam']?.toString() ?? '-'),
                        _DetailRow('修習別 / 學分', '${_getTypeBadge(d['sm']?.toString() ?? '')} ${d['credit']?.toString() ?? '0'} 學分'),
                        _DetailRow('學年 / 學期 / 年級', '${d['year']?.toString() ?? ''} 學年第 ${d['sem']?.toString() ?? ''} 學期 ( ${d['grade']?.toString() ?? '1'}年級 )'),
                        _DetailRow('課程代碼 / 課號', '${d['cono']?.toString() ?? ''} / ${d['seqno']?.toString().trim() ?? ''}'),
                        _DetailRow('教室 / 上課時間', '${d['roomNo']?.toString() ?? '依課表公告'} ${_formatWk(d['wk']?.toString())}'),
                      ]),
                      
                      // 🎯 課程目標
                      if (outline?['purpos']?.toString().isNotEmpty == true)
                        _buildSection(context, '🎯 課程目標', [
                          _DetailRow('', outline!['purpos'].toString(), isMultiline: true),
                          if (outline['ePurpos']?.toString().isNotEmpty == true)
                            _DetailRow('', outline['ePurpos'].toString(), isMultiline: true, isEnglish: true),
                        ]),

                      // 📖 授課方式
                      if (outline?['method']?.toString().isNotEmpty == true)
                        _buildSection(context, '📖 授課方式', [
                          _DetailRow('', outline!['method'].toString(), isMultiline: true),
                          if (outline['eMethod']?.toString().isNotEmpty == true)
                            _DetailRow('', outline['eMethod'].toString(), isMultiline: true, isEnglish: true),
                        ]),

                      // 📅 課程大綱與進度
                      if (outline?['syllabn']?.toString().isNotEmpty == true)
                        _buildSection(context, '📅 課程大綱與進度', [
                          _DetailRow('', outline!['syllabn'].toString(), isMultiline: true),
                          if (outline['eSyllabn']?.toString().isNotEmpty == true)
                            _DetailRow('', outline['eSyllabn'].toString(), isMultiline: true, isEnglish: true),
                        ]),

                      // ⚠️ 上課規範與注意事項
                      if (outline?['seqnir']?.toString().isNotEmpty == true)
                        _buildSection(context, '⚠️ 上課規範與注意事項', [
                          _DetailRow('', outline!['seqnir'].toString(), isMultiline: true),
                          if (outline['eSeqnir']?.toString().isNotEmpty == true)
                            _DetailRow('', outline['eSeqnir'].toString(), isMultiline: true, isEnglish: true),
                        ], isWarning: true),

                      // ✉️ Office Hour / 諮詢聯絡
                      if (outline?['officehour']?.toString().isNotEmpty == true)
                        _buildSection(context, '✉️ Office Hour / 諮詢聯絡', [
                          _DetailRow('', outline!['officehour'].toString(), isMultiline: true),
                        ], isInfo: true),

                      // 📚 教材與參考書目
                      _buildSection(context, '📚 教材與參考書目', [
                        _DetailRow('', textbooks, isMultiline: true),
                      ]),

                      // 📝 備註
                      if (d['remark']?.toString().isNotEmpty == true)
                        _buildSection(context, '📝 備註', [
                          _DetailRow('', d['remark'].toString(), isMultiline: true),
                        ]),
                    ],
                  ],
                ),
              ),
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('關閉'))],
          );
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children, {bool isWarning = false, bool isInfo = false}) {
    final theme = Theme.of(context);
    final bgColor = isWarning 
        ? theme.colorScheme.errorContainer.withValues(alpha: 0.3)
        : isInfo
            ? theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3)
            : Colors.transparent;
    final borderColor = isWarning 
        ? theme.colorScheme.error
        : isInfo
            ? theme.colorScheme.tertiary
            : Colors.transparent;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        border: borderColor != Colors.transparent
            ? Border(
                left: BorderSide(color: borderColor, width: 4),
                top: BorderSide(color: borderColor, width: 1),
                right: BorderSide(color: borderColor, width: 1),
                bottom: BorderSide(color: borderColor, width: 1),
              )
            : Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  String _getTypeBadge(String sm) {
    if (sm.contains('必修')) return '必修';
    if (sm.contains('選修')) return '選修';
    if (sm.contains('通識')) return '通識';
    return sm;
  }

  String _formatWk(String? wk) {
    if (wk == null || wk.isEmpty || wk == '0') return '';
    // Python API: 0=Sunday, 1=Monday, ..., 6=Saturday
    // Flutter: 1=Monday, ..., 7=Sunday
    const names = ['週一', '週二', '週三', '週四', '週五', '週六', '週日'];
    return '(星期' + wk.split(',').map((s) {
      final n = int.tryParse(s.trim()) ?? 0;
      if (n == 0) return '週日'; // Python 0=Sunday
      if (n >= 1 && n <= 6) return names[n - 1]; // Python 1-6=Monday-Saturday
      return s;
    }).join('、') + ')';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value, {this.isMultiline = false, this.isEnglish = false});
  final String label;
  final String value;
  final bool isMultiline;
  final bool isEnglish;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w500,
      fontStyle: isEnglish ? FontStyle.italic : FontStyle.normal,
      color: isEnglish ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface,
      fontSize: isEnglish ? 13 : 14,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            SizedBox(width: 100, child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
          Expanded(
            child: Text(
              value,
              style: style,
              maxLines: isMultiline ? null : 1,
              overflow: isMultiline ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// 課表頁面
class MySchedulePage extends ConsumerWidget {
  const MySchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduleProvider);
    final notifier = ref.read(scheduleProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的課表'),
        actions: [
          if (state.semesters.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: DropdownButton<String>(
                value: state.currentSemester,
                items: state.semesters
                    .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    notifier.state = state.copyWith(currentSemester: value);
                  }
                },
                underline: const SizedBox(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
        ],
      ),
      body: state.isLoading && state.courses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
                      const SizedBox(height: 16),
                      Text(state.error!, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => notifier.refresh(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('重試'),
                      ),
                    ],
                  ),
                )
              : _buildScheduleView(context, state, notifier),
    );
  }

  Widget _buildScheduleView(BuildContext context, ScheduleState state, ScheduleNotifier notifier) {
    // 檢查是否選了學期
    if (state.currentSemester == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 80, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('請先選擇學期', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 學期資訊 + 星期選單
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.semesters.isNotEmpty
                    ? state.semesters.firstWhere((s) => s.id == state.currentSemester, orElse: () => state.semesters.first).name
                    : '載入中...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(7, (i) => i + 1).map((day) {
                  final isSelected = state.selectedWeekday == day;
                  return FilterChip(
                    label: Text(WeekdayMap.shortName[day - 1]),
                    selected: isSelected,
                    onSelected: (_) => notifier.state = state.copyWith(selectedWeekday: day),
                    selectedColor: Theme.of(context).colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : null,
                      fontWeight: isSelected ? FontWeight.w600 : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        // 課程列表
        Expanded(
          child: state.selectedWeekday == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_available, size: 80, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text('請選擇星期', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                )
              : _buildWeekdayDetail(context, state, notifier),
        ),
      ],
    );
  }

  Widget _buildWeekdayDetail(BuildContext context, ScheduleState state, ScheduleNotifier notifier) {
    final courses = notifier.getCoursesForWeekday(state.selectedWeekday!);

    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 80, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('今日無課程', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('請選擇其他星期', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => notifier.showCourseDetail(context, course),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          course.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${course.credit.toStringAsFixed(course.credit.truncateToDouble() == course.credit ? 0 : 1)} 學分',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(child: Text(course.teacher ?? '未指定', style: Theme.of(context).textTheme.bodyMedium)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.meeting_room, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(child: Text(course.classroom ?? '未指定', style: Theme.of(context).textTheme.bodyMedium)),
                    ],
                  ),
                  if (course.department != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.school, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(child: Text(course.department!, style: Theme.of(context).textTheme.bodyMedium)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.arrow_forward_ios, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('點擊查看詳細資料', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 課表 Provider
final scheduleProvider = AutoDisposeNotifierProvider<ScheduleNotifier, ScheduleState>(() {
  return ScheduleNotifier();
});