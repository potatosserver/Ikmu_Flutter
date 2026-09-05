// 課表頁面
// 學期切換、週課表網格、課程詳情、Riverpod 狀態管理

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core.dart' hide DateUtils;
import '../../../core/api/services/wac_course_catalog.dart';

/// 週課表表格視圖 (節次=列, 星期=欄) - 對齊 reference/kmucoursequery_wac.py PERIOD_MAP
/// 高醫節次：1~9 (日間), A~D (夜間)；星期：一~六 (含週六)
class WeekScheduleGrid extends StatelessWidget {
  const WeekScheduleGrid({
    super.key,
    required this.courses,
    required this.onCourseTap,
  });

  final List<Course> courses;
  final void Function(Course) onCourseTap;

  static const List<KmuPeriod> _periods = KmuPeriod.all;
  static const List<String> _weekdayLabels = ['一', '二', '三', '四', '五', '六'];
  static const double _timeColumnWidth = 76.0;
  static const double _headerHeight = 44.0;
  static const double _rowHeight = 52.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 建立 periodCode -> index 映射 (用於計算 rowSpan)
    final periodIndex = <String, int>{};
    for (var i = 0; i < _periods.length; i++) {
      periodIndex[_periods[i].code] = i;
    }

    // 收集所有要顯示的課程卡片資訊
    final cards = <_CourseCardInfo>[];
    for (final course in courses) {
      // 支援 weekday 1-6 (週一~週六)
      if (course.weekday < 1 || course.weekday > 6) continue;
      if (course.periods.isEmpty) continue;

      final firstPeriod = course.periods.first.toUpperCase();
      final startIdx = periodIndex[firstPeriod];
      if (startIdx == null) continue;

      final periodSpan = course.periods.length;
      cards.add(_CourseCardInfo(
        course: course,
        weekday: course.weekday, // 1-6
        periodStartIdx: startIdx, // 0-based
        periodSpan: periodSpan,
      ));
    }

    // 計算總高度: Header (44) + 14 節 * 每節高度 (52) = 772.0
    final totalGridHeight = _headerHeight + _periods.length * _rowHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 設定最小總寬度，確保螢幕過窄時也能正常滑動
        const minGridWidth = _timeColumnWidth + 6 * 50.0;
        final gridWidth = constraints.maxWidth < minGridWidth ? minGridWidth : constraints.maxWidth;
        final dayColumnWidth = (gridWidth - _timeColumnWidth) / 6; // 6 天 (含週六)

        // Table 只畫格線 + 標籤列 + 星期標題，不放課程內容
        final gridTable = Table(
          columnWidths: {
            0: const FixedColumnWidth(_timeColumnWidth),
            for (var i = 1; i <= 6; i++) i: FixedColumnWidth(dayColumnWidth),
          },
          // ❌ 移除這行: defaultVerticalAlignment: TableCellVerticalAlignment.fill,
          border: TableBorder(
            horizontalInside: BorderSide(color: theme.dividerColor, width: 0.5),
            verticalInside: BorderSide(color: theme.dividerColor, width: 0.5),
            top: BorderSide(color: theme.dividerColor, width: 0.5),
            bottom: BorderSide(color: theme.dividerColor, width: 0.5),
            left: BorderSide(color: theme.dividerColor, width: 0.5),
            right: BorderSide(color: theme.dividerColor, width: 0.5),
          ),
          children: [
            // 標題列 (高 _headerHeight)
            TableRow(
              decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest),
              children: [
                SizedBox(
                  height: _headerHeight,
                  child: _buildTimeHeaderCell(theme, '節次'),
                ),
                ...List.generate(
                  6,
                  (i) => SizedBox(
                    height: _headerHeight,
                    child: _buildDayHeaderCell(theme, _weekdayLabels[i], i + 1),
                  ),
                ),
              ],
            ),
            // 14 節次列 (每列高 _rowHeight)
            ..._periods.map((p) => TableRow(
              children: [
                SizedBox(
                  height: _rowHeight,
                  child: _buildTimeLabelCell(theme, p),
                ),
                ...List.generate(
                  6,
                  (_) => const SizedBox(height: _rowHeight),
                ),
              ],
            )),
          ],
        );

        // 疊加課程卡片 (用 SizedBox 給予明確的長寬約束，解決 Stack 的 size.isFinite 錯誤)
        final courseStack = SizedBox(
          width: gridWidth,
          height: totalGridHeight,
          child: Stack(
            children: cards.map((card) {
              final left = _timeColumnWidth + (card.weekday - 1) * dayColumnWidth;
              final top = _headerHeight + card.periodStartIdx * _rowHeight;
              final height = card.periodSpan * _rowHeight;

              return Positioned(
                left: left,
                top: top,
                width: dayColumnWidth,
                height: height,
                child: _buildCourseCard(theme, card.course),
              );
            }).toList(),
          ),
        );

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SizedBox(
              width: gridWidth,
              height: totalGridHeight,
              child: Stack(
                children: [
                  gridTable,
                  courseStack,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeHeaderCell(ThemeData theme, String text) {
    return Center(
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildDayHeaderCell(ThemeData theme, String text, int weekday) {
    final now = DateTime.now();
    final isToday = now.weekday == weekday && now.weekday <= 6;
    return Container(
      alignment: Alignment.center,
      color: isToday ? theme.colorScheme.primaryContainer.withOpacity(0.3) : Colors.transparent,
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: isToday ? theme.colorScheme.primary : null,
        ),
      ),
    );
  }

  Widget _buildTimeLabelCell(ThemeData theme, KmuPeriod period) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 8),
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            period.code,
            style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            period.timeRange,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(ThemeData theme, Course course) {
    final colors = _courseColors;
    final colorIndex = _getColorIndex(course);
    final bgColor = colors[colorIndex].withOpacity(0.9);
    final textColor = colors[colorIndex].computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
    final subTextColor = colors[colorIndex].computeLuminance() > 0.5 ? Colors.black54 : Colors.white70;

    return Container(
      margin: const EdgeInsets.all(2), // 與格線留 2px 間隙
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onCourseTap(course),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  course.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: textColor,
                  ),
                ),
                if (course.classroom != null && course.classroom!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.meeting_room, size: 10, color: subTextColor),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          course.classroom!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 9,
                            color: subTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getColorIndex(Course course) {
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

class _CourseCardInfo {
  const _CourseCardInfo({
    required this.course,
    required this.weekday,
    required this.periodStartIdx,
    required this.periodSpan,
  });
  final Course course;
  final int weekday; // 1-6
  final int periodStartIdx; // 0-based
  final int periodSpan;
}

/// 課表狀態
@immutable
class ScheduleState {
  const ScheduleState({
    this.semesters = const [],
    this.currentSemester,
    this.courses = const [],
    this.scheduleData,
    this.isLoading = false,
    this.error,
  });

  final List<SemesterInfo> semesters;
  final String? currentSemester;
  final List<Course> courses;
  final ScheduleData? scheduleData;
  final bool isLoading;
  final String? error;

  ScheduleState copyWith({
    List<SemesterInfo>? semesters,
    String? currentSemester,
    List<Course>? courses,
    ScheduleData? scheduleData,
    bool? isLoading,
    String? error,
  }) {
    return ScheduleState(
      semesters: semesters ?? this.semesters,
      currentSemester: currentSemester ?? this.currentSemester,
      courses: courses ?? this.courses,
      scheduleData: scheduleData ?? this.scheduleData,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 課表 Notifier
class ScheduleNotifier extends AutoDisposeNotifier<ScheduleState> {
  @override
  ScheduleState build() {
    print('[ScheduleNotifier] build() — 排程 _loadSchedule');
    // 用 scheduleMicrotask 確保在 build 完成後才執行
    scheduleMicrotask(() async {
      try {
        // 主動清除舊版本 cache（包含舊格式無節次資料的 schedule_data）
        final cache = ref.read(cacheServiceProvider);
        await cache.remove(CacheBoxes.courses, 'schedule_data');
        await cache.remove(CacheBoxes.courses, 'wac_catalog_115_1');
        print('[ScheduleNotifier] 舊 cache 已清除');
        await _loadSchedule();
      } catch (e, st) {
        print('[ScheduleNotifier] microtask error: $e\n$st');
      }
    });
    return const ScheduleState(isLoading: true);
  }

  /// 載入課表
  Future<void> _loadSchedule() async {
    // 在 method 內讀取依賴，避免 late final 在 dispose 後的問題
    final endpoints = ref.read(endpointsProvider);
    final cache = ref.read(cacheServiceProvider);
    print('[ScheduleNotifier] _loadSchedule 開始');

    state = state.copyWith(isLoading: true, error: null);

    try {
      const cacheKey = 'schedule_data';
      final cached = cache.getSimple<Map<dynamic, dynamic>>(CacheBoxes.courses, cacheKey);
      print('[ScheduleNotifier] cache hit: ${cached != null}');

      if (cached != null && cached['_schedule_data'] == true) {
        // Cache 存的是 Map 格式，需要轉換 (Hive 回傳 Map<dynamic, dynamic>)
        print('[ScheduleNotifier] 解析 cache data...');
        final ScheduleData data;
        try {
          data = ScheduleData.fromJson(Map<String, dynamic>.from(cached['data'] as Map<dynamic, dynamic>));
        } catch (e, st) {
          print('[ScheduleNotifier] cache 解析失敗，清除: $e\n$st');
          await cache.remove(CacheBoxes.courses, cacheKey);
          state = state.copyWith(isLoading: true, error: null);
          return _loadSchedule();
        }
        print('[ScheduleNotifier] cache 解析完成: ${data.courses.length} 門課');
        // 檢查 cache 是否包含新欄位 (periods / periodCode)
        final hasPeriods = data.courses.any((c) => c.periods.isNotEmpty);
        print('[ScheduleNotifier] hasPeriods: $hasPeriods');
        if (!hasPeriods && data.courses.isNotEmpty) {
          print('[ScheduleNotifier] 舊 cache 沒有節次資料，清除並重新載入');
          await cache.remove(CacheBoxes.courses, cacheKey);
          state = state.copyWith(isLoading: true, error: null);
          // 不 return，讓下面走 network 流程
        } else {
          await _enrichWithWacCatalog(data);
          return;
        }
      }

      // 取得當前登入的使用者憑證
      final credentials = ref.read(currentUserCredentialsProvider);
      if (credentials == null) {
        throw Exception('請先登入');
      }

      final userId = credentials['userId']!;
      final password = credentials['password']!;

      // 取得學期清單
      final semesters = await endpoints.courses.getSemesters(
        userId: userId,
        password: password,
      );
      print('[ScheduleNotifier] 學期清單: ${semesters.length} 筆');

      // 取得課表 (Python: myclass_list 只要 id, pw，不需要 semester_id)
      final response = await endpoints.courses.getSchedule(
        userId: userId,
        password: password,
      );

      if (response != null && response.success && response.data != null) {
        final data = response.data!;
        // 避免 Hive 無法序列化 freezed 類型，存為 Map
        try {
          await cache.setSimple(
            CacheBoxes.courses,
            cacheKey,
            {'_schedule_data': true, 'data': data.toJson()},
            ttl: CacheTTL.courses,
          );
        } catch (_) {}
        await _enrichWithWacCatalog(data, semesters);
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

  /// 用 wac 全校課表 CSV 補齊節次/星期/教室
  Future<void> _enrichWithWacCatalog(ScheduleData data, [List<SemesterInfo>? semesters]) async {
    final cache = ref.read(cacheServiceProvider);
    if (data.courses.isEmpty) {
      _processScheduleData(data, semesters);
      return;
    }

    // 從第一門課程取得學年學期
    final firstCourse = data.courses.first;
    final idParts = firstCourse.id.split('-');
    final year = idParts.isNotEmpty ? idParts[0] : '';
    final sem = idParts.length > 1 ? idParts[1] : '';

    if (year.isEmpty || sem.isEmpty) {
      _processScheduleData(data, semesters);
      return;
    }

    // 嘗試從快取讀取 wac catalog
    final catalogCacheKey = 'wac_catalog_${year}_$sem';
    WacCourseCatalog? catalog;

    final cachedCatalog = cache.getSimple<Map<dynamic, dynamic>>(CacheBoxes.courses, catalogCacheKey);
    if (cachedCatalog != null) {
      catalog = WacCourseCatalog.fromJson(Map<String, dynamic>.from(cachedCatalog));
      print('[ScheduleNotifier] wac 目錄從快取載入: ${catalog.length} 筆');
    } else {
      // 下載並解析 wac CSV (帶 timeout 避免卡死整個 UI)
      try {
        print('[ScheduleNotifier] 正在下載 wac 課表目錄: $year-$sem');
        catalog = await WacCourseCatalog.load(year, sem).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            print('[ScheduleNotifier] wac 目錄下載 timeout');
            throw TimeoutException('wac 下載超時', const Duration(seconds: 30));
          },
        );
        print('[ScheduleNotifier] wac 目錄載入完成: ${catalog.length} 筆');
        // 快取 wac catalog (較長 TTL)
        await cache.setSimple(
          CacheBoxes.courses,
          catalogCacheKey,
          catalog.toJson(),
          ttl: CacheTTL.courses,
        );
      } catch (e) {
        print('[ScheduleNotifier] wac 目錄下載失敗: $e — 將以無節次模式顯示課表');
        catalog = null;
      }
    }

    // 若 catalog 為 null（離線/失敗），仍以基礎資料顯示課表（星期會由 myclass API 的 wk 提供，節次會是空）
    if (catalog == null) {
      _processScheduleData(data, semesters);
      return;
    }

    // 用 seqno join wac 資料
    print('[ScheduleNotifier] 開始 join seqno: ${data.courses.length} 門課, wac 有 ${catalog.length} 筆');
    final enrichedCourses = <Course>[];
    int matched = 0;
    for (final course in data.courses) {
      if (course.seqno == null || course.seqno!.isEmpty) {
        enrichedCourses.add(course);
        continue;
      }
      // trim 處理 myclass 回傳 seqno 可能有尾端空格
      final seqnoTrimmed = course.seqno!.trim();
      final wacEntries = catalog.findBySeqno(seqnoTrimmed);
      if (wacEntries.isEmpty) {
        enrichedCourses.add(course);
        continue;
      }
      matched++;

      // 取第一個匹配的 wac entry (通常一門課只有一個固定時段)
      final wac = wacEntries.first;
      final periods = wac.expandedPeriods;

      // 更新 weekday: wac 的 weekday (1-6) 對應 Flutter (1-5, 7=Sun)
      int newWeekday = course.weekday;
      if (wac.weekday.isNotEmpty) {
        final wacWeekday = int.tryParse(wac.weekday);
        if (wacWeekday != null && wacWeekday >= 1 && wacWeekday <= 6) {
          newWeekday = wacWeekday; // Python 1=Mon → Flutter 1=Mon
        }
      }

      enrichedCourses.add(course.copyWith(
        weekday: newWeekday,
        periodCode: periods.isNotEmpty ? periods.first : null,
        periods: periods,
        classroom: wac.room.isNotEmpty ? wac.room : course.classroom,
        teacher: wac.teacher.isNotEmpty ? wac.teacher : course.teacher,
      ));
    }
    print('[ScheduleNotifier] seqno join 完成: matched=$matched / total=${data.courses.length}');
    // 印出前 3 筆 enriched 課程的 weekday/periods 供診斷
    for (final c in enrichedCourses.take(3)) {
      print('  - ${c.name} weekday=${c.weekday} periods=${c.periods} room=${c.classroom}');
    }

    _processScheduleData(data.copyWith(courses: enrichedCourses), semesters);
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

    state = state.copyWith(
      semesters: uniqueList,
      currentSemester: data.semester ?? (uniqueList.isNotEmpty ? uniqueList.first.id : null),
      courses: data.courses,
      scheduleData: data,
      isLoading: false,
      error: null,
    );
    print('[ScheduleNotifier] state 更新: courses=${state.courses.length}, currentSemester=${state.currentSemester}, isLoading=${state.isLoading}');
  }

  /// 刷新
  Future<void> refresh() async {
    final cache = ref.read(cacheServiceProvider);
    await cache.remove(CacheBoxes.courses, 'schedule_data');
    await _loadSchedule();
  }

  /// 顯示課程詳細資料 Dialog
  void showCourseDetail(BuildContext context, Course course) {
    final endpoints = ref.read(endpointsProvider);
    // 從 course.id 解析 seqno (格式: year-sem-seqno)
    final parts = course.id.split('-');
    final seq = parts.length >= 3 ? parts[2].trim() : '';

    // 預先抓取詳細資料
    late final Future<Map<String, dynamic>?> detailFuture;
    if (seq.isNotEmpty) {
      final credentials = ref.read(currentUserCredentialsProvider);
      if (credentials != null) {
        detailFuture = endpoints.courses.getClassDetail(
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
        ? theme.colorScheme.errorContainer.withOpacity(0.3)
        : isInfo
            ? theme.colorScheme.tertiaryContainer.withOpacity(0.3)
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
            Icon(Icons.calendar_today, size: 80, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('請先選擇學期', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    final allCourses = state.courses;
    final semesterName = state.semesters.isNotEmpty
        ? state.semesters.firstWhere((s) => s.id == state.currentSemester, orElse: () => state.semesters.first).name
        : '載入中...';

    return Column(
      children: [
        // 學期資訊
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              Text(
                semesterName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (state.scheduleData?.totalCredits != null)
                Text(
                  '共 ${state.scheduleData!.totalCredits!.toStringAsFixed(state.scheduleData!.totalCredits!.truncateToDouble() == state.scheduleData!.totalCredits! ? 0 : 1)} 學分',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
            ],
          ),
        ),

        // 週課表表格 (主視圖)
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