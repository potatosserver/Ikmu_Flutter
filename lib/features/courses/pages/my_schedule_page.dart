// 課表頁面
// 學期切換、週課表網格、課程詳情、Riverpod 狀態管理

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core.dart' hide DateUtils;
import '../../../core/api/services/wac_course_catalog.dart';

/// 週課表表格視圖 (節次=列, 星期=欄) - 對齊 reference/kmucoursequery_wac.py PERIOD_MAP
/// 高醫節次：1~9 (日間), A~D (夜間)；星期：一~五 (移除週六)
class WeekScheduleGrid extends StatelessWidget {
  const WeekScheduleGrid({
    required this.courses, required this.onCourseTap, super.key,
  });

  final List<Course> courses;
  final void Function(Course) onCourseTap;

  static const List<KmuPeriod> _periods = KmuPeriod.all;
  static const List<String> _weekdayLabels = ['一', '二', '三', '四', '五']; // 移除週六
  static const double _timeColumnWidth = 64.0; // 增加時間欄寬度以容納 節次 + 時間範圍
  static const double _headerHeight = 44.0;
  static const double _rowHeight = 60.0; // 增加行高以容納課名+教授+教室

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
      // 支援 weekday 1-5 (週一~週五) - 移除週六
      if (course.weekday < 1 || course.weekday > 5) continue;
      if (course.periods.isEmpty) continue;

      final firstPeriod = course.periods.first.toUpperCase();
      final startIdx = periodIndex[firstPeriod];
      if (startIdx == null) continue;

      final periodSpan = course.periods.length;
      cards.add(_CourseCardInfo(
        course: course,
        weekday: course.weekday, // 1-5
        periodStartIdx: startIdx, // 0-based
        periodSpan: periodSpan,
      ));
    }

    // 計算總高度: Header (44) + 14 節 * 每節高度 (60) = 884
    final totalGridHeight = _headerHeight + 4 + _periods.length * _rowHeight; // +4 為標題列 bottom margin

    return LayoutBuilder(
      builder: (context, constraints) {
        // 設定最小總寬度，確保螢幕過窄時也能正常滑動
        const minGridWidth = _timeColumnWidth + 5 * 50.0; // 5 天 (移除週六)
        final gridWidth = constraints.maxWidth < minGridWidth ? minGridWidth : constraints.maxWidth;
        final dayColumnWidth = (gridWidth - _timeColumnWidth) / 5; // 5 天

        // 使用自定義佈局：更輕量、圓角、有間距的 M3 風格表格
        final gridTable = SizedBox(
          width: gridWidth, // 關鍵：給 Column 明確寬度約束，避免 Row Expanded 溢出
          child: Column(
            children: [
              // 標題列 - 獨立圓角容器，與下方完全分開
              Container(
                margin: const EdgeInsets.only(bottom: 4), // 與下方分開
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12), // 四角圓角
                ),
                child: SizedBox(
                  height: _headerHeight,
                  child: Row(
                    children: [
                      SizedBox(
                        width: _timeColumnWidth,
                        child: _buildTimeHeaderCell(theme, '節次'),
                      ),
                      ...List.generate(5, (i) => Expanded(
                        child: _buildDayHeaderCell(theme, _weekdayLabels[i], i + 1),
                      )),
                    ],
                  ),
                ),
              ),
              // 14 節次列
              ..._periods.asMap().entries.map((entry) {
              final p = entry.value;
              final rowIndex = entry.key;
              final isLastRow = rowIndex == _periods.length - 1;
              return SizedBox(
                height: _rowHeight,
                child: Stack(
                  children: [
                    // 背景 (斑馬紋)
                    Positioned.fill(
                      child: Row(
                        children: [
                          // 時間欄背景
                          SizedBox(
                            width: _timeColumnWidth,
                            child: Container(
                              color: rowIndex.isEven
                                  ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.05)
                                  : Colors.transparent,
                            ),
                          ),
                          // 5 天欄位背景
                          ...List.generate(5, (dayIndex) {
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0.5),
                                color: rowIndex.isEven
                                    ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.03)
                                    : Colors.transparent,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    // 底部橫線 - 在行的底部 (節次之間的分界線)
                    Positioned(
                      bottom: 0,
                      left: _timeColumnWidth,
                      right: 0,
                      child: Row(
                        children: List.generate(5, (dayIndex) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 0.5),
                            height: 0.5,
                            color: theme.dividerColor.withValues(alpha: 0.15),
                          ),
                        )),
                      ),
                    ),
                    // 內容層
                    Row(
                      children: [
                        // 時間欄
                        SizedBox(
                          width: _timeColumnWidth,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: isLastRow ? const Radius.circular(12) : Radius.zero,
                              ),
                            ),
                            child: _buildTimeLabelCell(theme, p),
                          ),
                        ),
                        // 5 天欄位
                        ...List.generate(5, (dayIndex) {
                          final isLastDay = dayIndex == 4;
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 0.5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomRight: isLastRow && isLastDay ? const Radius.circular(12) : Radius.zero,
                                ),
                              ),
                              child: const SizedBox.shrink(),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
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

        // 雙向滾動 + 隱藏捲軸
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
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
      color: isToday ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : Colors.transparent,
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
    // 解析時間範圍
    final parts = period.timeRange.split('-');
    final startTime = parts.isNotEmpty ? parts[0] : '';
    final endTime = parts.length > 1 ? parts[1] : '';

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 節次代碼
          Text(
            period.code,
            style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // 時間範圍：垂直堆疊 - 開始時間 / 直的 ~ / 結束時間
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                startTime,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 1),
              RotatedBox(
                quarterTurns: 3, // 逆時針 90 度 = 直的 ~
                child: Text(
                  '~',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 9,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                endTime,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(ThemeData theme, Course course) {
    const colors = _courseColors;
    final colorIndex = _getColorIndex(course);
    final bgColor = colors[colorIndex].withValues(alpha: 0.9);
    final textColor = colors[colorIndex].computeLuminance() > 0.5 ? Colors.black87 : Colors.white;

    // 解析教室與樓層
    final String? classroom = course.classroom;
    final String? building = course.building;
    String displayRoom = '';
    if (classroom != null && classroom.isNotEmpty) {
      displayRoom = classroom;
      if (building != null && building.isNotEmpty && !classroom.contains(building)) {
        displayRoom = '$building $classroom';
      }
    } else if (building != null && building.isNotEmpty) {
      displayRoom = building;
    }

    return Container(
      margin: const EdgeInsets.all(2), // 與格線留 2px 間隙
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8), // M3 圓角
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onCourseTap(course),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center, // 垂直置中
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  course.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: textColor,
                    height: 1.2,
                  ),
                ),
                // 教室 - 空一行
                if (displayRoom.isNotEmpty) ...[
                  const SizedBox(height: 6), // 空一行
                  Text(
                    displayRoom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontSize: 9,
                      color: textColor, // 深色
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                // 授課教授
                if (course.teacher != null && course.teacher!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    course.teacher!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
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
    Color(0xFFA8D8EA), // Macaron Blue
    Color(0xFFAAE3E2), // Macaron Mint
    Color(0xFFB8E0D2), // Macaron Seafoam
    Color(0xFFFFD3B6), // Macaron Peach
    Color(0xFFFFAAAA), // Macaron Salmon
    Color(0xFFFFB3BA), // Macaron Pink
    Color(0xFFFFDAC1), // Macaron Apricot
    Color(0xFFE2F0CB), // Macaron Pistachio
    Color(0xFFC7CEEA), // Macaron Lavender
    Color(0xFFD8B4E2), // Macaron Lilac
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
  final int weekday; // 1-5
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
        // 檢查 cache 是否有效 (year/sem 不為 0)
        final hasValidYearSem = data.courses.any((c) {
          final parts = c.id.split('-');
          return parts.length >= 2 && parts[0] != '0' && parts[1] != '0';
        });
        print('[ScheduleNotifier] hasValidYearSem: $hasValidYearSem');
        // 若無課程資料 或 缺節次欄位 或 year/sem 無效 → 清除快取重抓
        if (data.courses.isEmpty || (!hasPeriods && data.courses.isNotEmpty) || !hasValidYearSem) {
          if (data.courses.isEmpty) {
            print('[ScheduleNotifier] cache 課程為空，清除並重新載入');
          } else if (!hasValidYearSem) {
            print('[ScheduleNotifier] cache year/sem 無效 (0-0)，清除並重新載入');
          } else {
            print('[ScheduleNotifier] 舊 cache 沒有節次資料，清除並重新載入');
          }
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
      // 快取為空視為 miss，清除並重新下載
      if (catalog.length == 0) {
        print('[ScheduleNotifier] 快取目錄為空，清除並重新下載');
        await cache.remove(CacheBoxes.courses, catalogCacheKey);
        catalog = null;
      } else {
        print('[ScheduleNotifier] wac 目錄從快取載入: ${catalog.length} 筆');
      }
    }

    if (catalog == null) {
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
        // 快取 wac catalog (較長 TTL) - 只有非空才快取
        if (catalog.length > 0) {
          await cache.setSimple(
            CacheBoxes.courses,
            catalogCacheKey,
            catalog.toJson(),
            ttl: CacheTTL.courses,
          );
        } else {
          print('[ScheduleNotifier] wac 目錄為空，不寫入快取');
        }
      } catch (e) {
        print('[ScheduleNotifier] wac 目錄下載失敗: $e — 將以無節次模式顯示課表');
        catalog = null;
      }
    }

    // 最終若仍為 null，以基礎資料顯示
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
        // 更新中文課名 (優先用 WAC 的 chineseco)
        name: wac.chineseco.isNotEmpty ? wac.chineseco : course.name,
      ));
    }
    print('[ScheduleNotifier] seqno join 完成: matched=$matched / total=${data.courses.length}');
    // 印出前 3 筆 enriched 課程的 weekday/periods 供診斷
    for (final c in enrichedCourses.take(3)) {
      print('  - ${c.name} weekday=${c.weekday} periods=${c.periods} room=${c.classroom}');
    }

    _processScheduleData(data.copyWith(courses: enrichedCourses), semesters);
    // 將豐富後的資料（含 periods/教室/教授）寫回快取，下次直接讀取即有完整資料
    try {
      await cache.setSimple(
        CacheBoxes.courses,
        'schedule_data',
        {'_schedule_data': true, 'data': data.copyWith(courses: enrichedCourses).toJson()},
        ttl: CacheTTL.courses,
      );
      print('[ScheduleNotifier] 豐富後課表已寫入快取');
    } catch (_) {}
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
      builder: (context) => AlertDialog(
        title: Text(course.name),
        content: FutureBuilder<Map<String, dynamic>?>(
          future: detailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Text('無詳細資料');
            }
            final detail = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DetailRow('課程代碼', detail['cono']?.toString() ?? ''),
                  _DetailRow('學分', detail['credit']?.toString() ?? ''),
                  _DetailRow('必選修', detail['sm']?.toString() ?? ''),
                  _DetailRow('開課系所', detail['deptnam']?.toString() ?? ''),
                  _DetailRow('授課教師', detail['teafenam']?.toString() ?? ''),
                  _DetailRow('教室', detail['roomNo']?.toString() ?? ''),
                  if (detail['outline'] != null && detail['outline'] is List) ...[
                    const SizedBox(height: 12),
                    const Text('大綱', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...List.generate(
                      (detail['outline'] as List).length,
                      (i) => Text((detail['outline'] as List)[i]['syllabn']?.toString() ?? ''),
                    ),
                  ],
                  if (detail['textbook'] != null && detail['textbook'] is List) ...[
                    const SizedBox(height: 12),
                    const Text('教科書', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...List.generate(
                      (detail['textbook'] as List).length,
                      (i) {
                        final t = (detail['textbook'] as List)[i];
                        return Text('${t['title']} (${t['author']}, ${t['pub']})');
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('關閉')),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
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
    final allCourses = state.courses;

    return Column(
      children: [
        // 週課表表格 (主視圖) - 直接佔滿全螢幕
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