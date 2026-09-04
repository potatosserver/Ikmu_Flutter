// 課表頁面
// 學期切換、週課表網格、課程詳情、Riverpod 狀態管理

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core.dart' hide DateUtils;

/// 週課表網格視圖 - 以時間為 Y 軸、星期為 X 軸 (週日在最左)
/// 高醫標準節次：1=08:10-09:00, 2=09:10-10:00, 3=10:10-11:00, 4=11:10-12:00,
/// 5=13:10-14:00, 6=14:10-15:00, 7=15:10-16:00, 8=16:10-17:00, 9=17:10-18:00,
/// 10=18:30-19:20, 11=19:25-20:15, 12=20:20-21:10
///
/// 注意: KMU 課表 API (getMyClassList) 不提供節次/上課時間，只有 wk (星期)。
/// 因此本網格採用「日欄垂直堆疊」模式：左側時間軸供參考，右側各星期欄位
/// 將該天所有課程由上而下排列，不強制對齊特定節次。
class WeekScheduleGrid extends StatelessWidget {
  const WeekScheduleGrid({
    super.key,
    required this.courses,
    required this.onCourseTap,
  });

  final List<Course> courses;
  final void Function(Course) onCourseTap;

  static const List<String> _weekdayLabels = ['週日', '週一', '週二', '週三', '週四', '週五', '週六'];
  static const List<String> _periodLabels = [
    '', // 0 佔位
    '08:10-09:00', // 1
    '09:10-10:00', // 2
    '10:10-11:00', // 3
    '11:10-12:00', // 4
    '13:10-14:00', // 5
    '14:10-15:00', // 6
    '15:10-16:00', // 7
    '16:10-17:00', // 8
    '17:10-18:00', // 9
    '18:30-19:20', // 10
    '19:25-20:15', // 11
    '20:20-21:10', // 12
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const periodCount = 12; // 高醫標準 12 節

    // 依星期分組課程
    final coursesByWeekday = <int, List<Course>>{
      for (int i = 1; i <= 7; i++) i: [],
    };
    for (final course in courses) {
      coursesByWeekday[course.weekday]?.add(course);
    }

    // 各星期內部按課程名稱排序 (或可依序號 seqno)
    for (final list in coursesByWeekday.values) {
      list.sort((a, b) => a.name.compareTo(b.name));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const timeColumnWidth = 70.0;
        final availableWidth = constraints.maxWidth - timeColumnWidth;
        final dayColumnWidth = availableWidth / 7;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Column(
                children: [
                  // 標題列：時間欄 + 7 天
                  _buildHeaderRow(theme, timeColumnWidth, dayColumnWidth),
                  // 節次列 (空白格，僅供時間參考)
                  ...List.generate(periodCount, (i) {
                    final period = i + 1;
                    return _buildEmptyPeriodRow(
                      theme,
                      period,
                      timeColumnWidth,
                      dayColumnWidth,
                    );
                  }),
                  // 實際課程區：置底固定高度區塊，各星期垂直堆疊
                  _buildCoursesSection(theme, timeColumnWidth, dayColumnWidth, coursesByWeekday),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderRow(ThemeData theme, double timeWidth, double dayWidth) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          // 時間欄標題
          Container(
            width: timeWidth,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              border: Border(
                right: BorderSide(color: theme.dividerColor, width: 0.5),
                bottom: BorderSide(color: theme.dividerColor, width: 0.5),
              ),
            ),
            child: Text(
              '節次',
              style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          // 7 天標題 (週日在最左)
          ...List.generate(7, (i) {
            final isToday = _isToday(i);
            return Container(
              width: dayWidth,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isToday 
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                    : theme.colorScheme.surfaceContainerHighest,
                border: Border(
                  right: BorderSide(color: theme.dividerColor, width: 0.5),
                  bottom: BorderSide(color: theme.dividerColor, width: 0.5),
                ),
              ),
              child: Text(
                _weekdayLabels[i],
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isToday ? theme.colorScheme.primary : null,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  bool _isToday(int gridWeekday) {
    final now = DateTime.now();
    // Dart: 1=Mon...7=Sun, Grid: 0=Sun, 1=Mon...6=Sat
    final todayGrid = now.weekday == 7 ? 0 : now.weekday;
    return gridWeekday == todayGrid;
  }

  Widget _buildEmptyPeriodRow(
    ThemeData theme,
    int period,
    double timeWidth,
    double dayWidth,
  ) {
    const rowHeight = 40.0;
    final timeLabel = _periodLabels[period];

    return SizedBox(
      height: rowHeight,
      child: Row(
        children: [
          // 時間標籤欄
          Container(
            width: timeWidth,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              border: Border(
                right: BorderSide(color: theme.dividerColor, width: 0.5),
                bottom: BorderSide(color: theme.dividerColor, width: 0.5),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$period',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  timeLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // 7 天的空白格
          ...List.generate(7, (dayIdx) {
            return Container(
              width: dayWidth,
              height: rowHeight,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: theme.dividerColor, width: 0.5),
                  bottom: BorderSide(color: theme.dividerColor, width: 0.5),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCoursesSection(
    ThemeData theme,
    double timeWidth,
    double dayWidth,
    Map<int, List<Course>> coursesByWeekday,
  ) {
    // 計算每欄需要的高度 (每門課約 56px + 間距)
    const courseCardHeight = 56.0;
    const courseSpacing = 4.0;
    
    int maxCoursesInDay = 0;
    for (final list in coursesByWeekday.values) {
      if (list.length > maxCoursesInDay) maxCoursesInDay = list.length;
    }
    
    final sectionHeight = maxCoursesInDay * (courseCardHeight + courseSpacing) + 16;

    return SizedBox(
      height: sectionHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左側空白時間欄 (佔位)
          Container(
            width: timeWidth,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
              border: Border(
                right: BorderSide(color: theme.dividerColor, width: 0.5),
              ),
            ),
          ),
          // 7 天的課程堆疊
          ...List.generate(7, (dayIdx) {
            // Grid index 0=Sun -> Flutter weekday 7; 1=Mon -> 1...
            final flutterWeekday = dayIdx == 0 ? 7 : dayIdx;
            final dayCourses = coursesByWeekday[flutterWeekday] ?? [];
            
            return SizedBox(
              width: dayWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: dayCourses.asMap().entries.map((entry) {
                  final course = entry.value;
                  final colorIndex = _getColorIndex(course);
                  final colors = _courseColors;
                  
                  return Padding(
                    padding: EdgeInsets.only(
                      left: 4,
                      right: 4,
                      top: entry.key == 0 ? 8 : courseSpacing,
                      bottom: entry.key == dayCourses.length - 1 ? 8 : 0,
                    ),
                    child: Material(
                      color: colors[colorIndex].withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () => onCourseTap(course),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                course.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colors[colorIndex].computeLuminance() > 0.5 
                                      ? Colors.black87 
                                      : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  if (course.classroom != null) ...[
                                    Icon(
                                      Icons.meeting_room,
                                      size: 12,
                                      color: colors[colorIndex].computeLuminance() > 0.5 
                                          ? Colors.black54 
                                          : Colors.white70,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        course.classroom!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: colors[colorIndex].computeLuminance() > 0.5 
                                              ? Colors.black54 
                                              : Colors.white70,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (course.credit > 0) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      '${course.credit.toStringAsFixed(course.credit.truncateToDouble() == course.credit ? 0 : 1)} 學分',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: colors[colorIndex].computeLuminance() > 0.5 
                                            ? Colors.black54 
                                            : Colors.white70,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  int _getColorIndex(Course course) {
    // 根據課程 ID 穩定分配顏色
    return course.id.hashCode.abs() % _courseColors.length;
  }

  static const List<Color> _courseColors = [
    Color(0xFFE3F2FD), // Blue 50
    Color(0xFFE8F5E9), // Green 50
    Color(0xFFF3E5F5), // Purple 50
    Color(0xFFFFF3E0), // Orange 50
    Color(0xFFE0F2F1), // Teal 50
    Color(0xFFFAF3DD), // Amber 50
    Color(0xFFFCE4EC), // Pink 50
    Color(0xFFF1F8E9), // Light Green 50
    Color(0xFFEDE7F6), // Deep Purple 50
    Color(0xFFE1F5FE), // Light Blue 50
  ];
}

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

    final allCourses = state.courses;

    return Column(
      children: [
        // 學期資訊 + 星期快速跳轉
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
              // 星期快速跳轉 - 點擊自動滾動到對應欄
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(7, (i) {
                    final day = i + 1;
                    final hasCourse = allCourses.any((c) => c.weekday == day);
                    final isSelected = state.selectedWeekday == day;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(WeekdayMap.shortName[day - 1]),
                        selected: isSelected,
                        onSelected: (_) => notifier.state = state.copyWith(selectedWeekday: day),
                        selectedColor: Theme.of(context).colorScheme.primaryContainer,
                        labelStyle: TextStyle(
                          color: isSelected 
                              ? Theme.of(context).colorScheme.onPrimaryContainer 
                              : hasCourse 
                                  ? Theme.of(context).colorScheme.primary 
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        backgroundColor: hasCourse 
                            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                            : null,
                        side: hasCourse && !isSelected
                            ? BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5))
                            : null,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),

        // 週課表網格 (主視圖)
        Expanded(
          child: WeekScheduleGrid(
            courses: allCourses,
            onCourseTap: (course) => notifier.showCourseDetail(context, course),
          ),
        ),
      ],
    );
  }
}

/// 課表 Provider
final scheduleProvider = AutoDisposeNotifierProvider<ScheduleNotifier, ScheduleState>(() {
  return ScheduleNotifier();
});