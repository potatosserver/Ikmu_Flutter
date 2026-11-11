// 課表頁面
// 學期切換、週課表網格、課程詳情、Riverpod 狀態管理

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/api/models/course_models.dart';
import '../../../core/api/models/common_models.dart';
import '../../../core/api/services/wac_course_catalog.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/providers.dart';

/// Intent for Ctrl+R (normal refresh)
class _RefreshIntent extends Intent {
  const _RefreshIntent();
}

/// Intent for Ctrl+Shift+R (force refresh with WAC)
class _ForceRefreshIntent extends Intent {
  const _ForceRefreshIntent();
}

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
  static const double _timeColumnWidth = 64.0;
  static const double _headerHeight = 44.0;
  static const double _rowHeight = 60.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 建立課表查找表: weekday (1-5) -> periodCode -> List<Course>
    final Map<int, Map<String, List<Course>>> scheduleMap = {};
    for (final course in courses) {
      for (final periodCode in course.periods) {
        if (course.weekday >= 1 && course.weekday <= 5) {
          scheduleMap
              .putIfAbsent(course.weekday, () => {})
              .putIfAbsent(periodCode, () => [])
              .add(course);
        }
      }
    }

    // 合併相同課程的連續節次為一個大方塊
    // 回傳: weekday -> periodCode -> List<MergedCourseBlock>
    final Map<int, Map<String, List<_MergedCourseBlock>>> mergedMap = {};
    for (final entry1 in scheduleMap.entries) {
      final weekday = entry1.key;
      final periodMap = entry1.value;
      mergedMap[weekday] = {};
      // 收集該節次下的所有課程 (去重，同一課程可能在多個節次出現)
      final Map<String, Course> courseById = {};
      for (final entry2 in periodMap.entries) {
        for (final course in entry2.value) {
          courseById[course.id] = course;
        }
      }
      // 對每個課程，找出其佔用的連續節次
      for (final course in courseById.values) {
        final coursePeriods = course.periods.where((p) => periodMap.containsKey(p)).toList();
        if (coursePeriods.isEmpty) continue;
        // 將連續節次分組
        final periodIndexMap = {for (int i = 0; i < _periods.length; i++) _periods[i].code: i};
        final sortedPeriods = coursePeriods..sort((a, b) => (periodIndexMap[a] ?? 0).compareTo(periodIndexMap[b] ?? 0));
        int groupStart = 0;
        for (int i = 1; i <= sortedPeriods.length; i++) {
          final isLast = i == sortedPeriods.length;
          final isNotConsecutive = isLast ||
              (periodIndexMap[sortedPeriods[i]] ?? 0) !=
                  (periodIndexMap[sortedPeriods[i - 1]] ?? 0) + 1;
          if (isNotConsecutive) {
            final group = sortedPeriods.sublist(groupStart, i);
            final startCode = group.first;
            final endCode = group.last;
            mergedMap[weekday]!.putIfAbsent(startCode, () => []);
            mergedMap[weekday]![startCode]!.add(_MergedCourseBlock(
              course: course,
              startPeriod: startCode,
              endPeriod: endCode,
              spanPeriods: group.length,
            ));
            groupStart = i;
          }
        }
      }
    }

    return Column(
            children: [
              // 表頭：時間欄 + 星期標題
              Container(
                height: _headerHeight,
                color: theme.colorScheme.surfaceContainerHighest,
                child: Row(
                  children: [
                    SizedBox(
                      width: _timeColumnWidth,
                      child: Center(
                        child: Text('節次', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    ..._weekdayLabels.map((label) {
                      return Expanded(
                        child: Center(
                          child: Text(
                            '星期$label',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              // 表身：各節次列
              ..._periods.map((period) {
                final periodCode = period.code;
                final timeParts = period.timeRange.split('-');

                return Container(
                  height: _rowHeight,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 時間欄
                      SizedBox(
                        width: _timeColumnWidth,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  timeParts[0],
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const RotatedBox(
                                  quarterTurns: 1,
                                  child: Text(
                                    '~',
                                    style: TextStyle(fontSize: 14, height: 1.2),
                                  ),
                                ),
                                Text(
                                  timeParts[1],
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // 星期欄位
                      ..._weekdayLabels.asMap().entries.map((entry) {
                        final weekday = entry.key + 1; // 1~5
                        final mergedBlocks = mergedMap[weekday]?[periodCode] ?? [];

                        return Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
                              ),
                            ),
                            child: Stack(
                              children: mergedBlocks.asMap().entries.map((blockEntry) {
                                final block = blockEntry.value;
                                final isStartBlock = block.startPeriod == periodCode;
                                if (!isStartBlock) return const SizedBox.shrink();
                                final colorValue = int.tryParse(block.course.color?.replaceFirst('#', '') ?? '2196F3', radix: 16) ?? 0xFF2196F3;
                                final cardColor = Color(colorValue | 0xFF000000);

                                return Positioned(
                                  top: 0.0,
                                  left: 2.0,
                                  right: 2.0,
                                  bottom: 2.0,
                                  child: SizedBox(
                                    height: block.spanPeriods * _rowHeight - 4.0,
                                    child: Material(
                                      color: cardColor.withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(6),
                                      child: InkWell(
                                        onTap: () => onCourseTap(block.course),
                                        borderRadius: BorderRadius.circular(6),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                block.course.name,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme.textTheme.labelMedium?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 11,
                                                  shadows: const [Shadow(blurRadius: 2, color: Colors.black54)],
                                                ),
                                              ),
                                              if (block.course.teacher?.isNotEmpty == true)
                                                Text(
                                                  block.course.teacher!,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: theme.textTheme.labelSmall?.copyWith(
                                                    color: Colors.white.withValues(alpha: 0.9),
                                                    fontSize: 9,
                                                  ),
                                                ),
                                              if (block.course.classroom?.isNotEmpty == true)
                                                Text(
                                                  block.course.classroom!,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: theme.textTheme.labelSmall?.copyWith(
                                                    color: Colors.white.withValues(alpha: 0.8),
                                                    fontSize: 9,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
            ],
          );
  }
}

/// 合併後的課程區塊 (跨多個連續節次)
class _MergedCourseBlock {
  const _MergedCourseBlock({
    required this.course,
    required this.startPeriod,
    required this.endPeriod,
    required this.spanPeriods,
  });

  final Course course;
  final String startPeriod;
  final String endPeriod;
  final int spanPeriods;
}

/// 課表狀態
@immutable
class ScheduleState {
  const ScheduleState({
    this.courses = const [],
    this.semesters = const [],
    this.currentSemester,
    this.isLoading = true,
    this.error,
  });

  final List<Course> courses;
  final List<SemesterInfo> semesters;
  final String? currentSemester;
  final bool isLoading;
  final String? error;

  ScheduleState copyWith({
    List<Course>? courses,
    List<SemesterInfo>? semesters,
    String? currentSemester,
    bool? isLoading,
    String? error,
  }) {
    return ScheduleState(
      courses: courses ?? this.courses,
      semesters: semesters ?? this.semesters,
      currentSemester: currentSemester ?? this.currentSemester,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 課表 Notifier
class ScheduleNotifier extends AutoDisposeNotifier<ScheduleState> {
  @override
  ScheduleState build() {
    debugPrint('[ScheduleNotifier] build() — 排程 _loadSchedule');
    scheduleMicrotask(() async {
      try {
        await _loadSchedule();
      } catch (e, st) {
        debugPrint('[ScheduleNotifier] microtask error: $e\n$st');
      }
    });
    return const ScheduleState(isLoading: true);
  }

  /// 載入課表
  Future<void> _loadSchedule() async {
    final endpoints = ref.read(endpointsProvider);
    final cache = ref.read(cacheServiceProvider);
    debugPrint('[ScheduleNotifier] _loadSchedule 開始');

    state = state.copyWith(isLoading: true, error: null);

    try {
      const cacheKey = 'schedule_data';
      final cached = await cache.getSimple<Map<dynamic, dynamic>>(CacheBoxes.courses, cacheKey);
      debugPrint('[ScheduleNotifier] cache hit: ${cached != null}');

      if (cached != null && cached['_schedule_data'] == true) {
        debugPrint('[ScheduleNotifier] 解析 cache data...');
        final ScheduleData data;
        try {
          data = ScheduleData.fromJson(Map<String, dynamic>.from(cached['data'] as Map<dynamic, dynamic>));
        } catch (e, st) {
          debugPrint('[ScheduleNotifier] cache 解析失敗，清除: $e\n$st');
          await cache.delete(CacheBoxes.courses, cacheKey);
          state = state.copyWith(isLoading: true, error: null);
          return await _loadSchedule();
        }
        debugPrint('[ScheduleNotifier] cache 解析完成: ${data.courses.length} 門課');
        final hasPeriods = data.courses.any((c) => c.periods.isNotEmpty);
        debugPrint('[ScheduleNotifier] hasPeriods: $hasPeriods');
        final hasValidYearSem = data.courses.any((c) {
          final parts = c.id.split('-');
          return parts.length >= 2 && parts[0] != '0' && parts[1] != '0';
        });
        debugPrint('[ScheduleNotifier] hasValidYearSem: $hasValidYearSem');
        if (data.courses.isEmpty || (!hasPeriods && data.courses.isNotEmpty) || !hasValidYearSem) {
          if (data.courses.isEmpty) {
            debugPrint('[ScheduleNotifier] cache 課程為空，清除並重新載入');
          } else if (!hasValidYearSem) {
            debugPrint('[ScheduleNotifier] cache year/sem 無效 (0-0)，清除並重新載入');
          } else {
            debugPrint('[ScheduleNotifier] 舊 cache 沒有節次資料，清除並重新載入');
          }
          await cache.delete(CacheBoxes.courses, cacheKey);
          state = state.copyWith(isLoading: true, error: null);
        } else {
          await _enrichWithWacCatalog(data);
          return;
        }
      }

      final credentials = ref.read(currentUserCredentialsProvider);
      if (credentials == null) {
        throw Exception('請先登入');
      }

      final userId = credentials['userId']!;
      final password = credentials['password']!;

      final semesters = await endpoints.courses.getSemesters(
        userId: userId,
        password: password,
      );
      debugPrint('[ScheduleNotifier] 學期清單: ${semesters.length} 筆');

      final response = await endpoints.courses.getSchedule(
        userId: userId,
        password: password,
      );

      if (response != null && response.success && response.data != null) {
        final data = response.data!;
        try {
          await cache.setSimple(
            CacheBoxes.courses,
            cacheKey,
            {
              '_schedule_data': true,
              'data': data.toJson(),
            },
            ttl: CacheTTL.courses,
          );
        } catch (e) {
          debugPrint('[ScheduleNotifier] 快取寫入失敗: $e');
        }

        final currentSem = semesters.firstWhere((s) => s.isCurrent, orElse: () => semesters.first).id;

        state = state.copyWith(
          courses: data.courses,
          semesters: semesters,
          currentSemester: currentSem,
          isLoading: false,
          error: null,
        );
        debugPrint('[ScheduleNotifier] state 更新: courses=${state.courses.length}, currentSemester=${state.currentSemester}, isLoading=${state.isLoading}');

        await _enrichWithWacCatalog(data);
      } else {
        throw Exception(response?.message ?? '取得課表失敗');
      }
    } catch (e) {
      debugPrint('[ScheduleNotifier] 載入課表失敗: $e');
      state = state.copyWith(
        isLoading: false,
        error: '載入課表失敗: $e',
      );
    }
  }

  /// 用 wac 全校課表 CSV 補齊節次/星期/教室
  Future<void> _enrichWithWacCatalog(ScheduleData data) async {
    final cache = ref.read(cacheServiceProvider);

    if (data.courses.isEmpty) {
      _processScheduleData(data, state.semesters);
      return;
    }

    final firstId = data.courses.first.id;
    final idParts = firstId.split('-');
    final year = idParts.isNotEmpty ? idParts[0] : '';
    final sem = idParts.length > 1 ? idParts[1] : '';

    if (year.isEmpty || sem.isEmpty) {
      _processScheduleData(data, state.semesters);
      return;
    }

    final catalogCacheKey = 'wac_catalog_${year}_$sem';
    WacCourseCatalog? catalog;

    final cachedCatalog = await cache.getSimple<Map<dynamic, dynamic>>(CacheBoxes.courses, catalogCacheKey);
    if (cachedCatalog != null) {
      catalog = WacCourseCatalog.fromJson(Map<String, dynamic>.from(cachedCatalog));
      if (catalog.length == 0) {
        debugPrint('[ScheduleNotifier] 快取目錄為空，清除並重新下載');
        await cache.delete(CacheBoxes.courses, catalogCacheKey);
        catalog = null;
      } else {
        debugPrint('[ScheduleNotifier] wac 目錄從快取載入: ${catalog.length} 筆');
      }
    }

    if (catalog == null) {
      try {
        debugPrint('[ScheduleNotifier] 正在下載 wac 課表目錄: $year-$sem');
        catalog = await WacCourseCatalog.load(year, sem).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            debugPrint('[ScheduleNotifier] wac 目錄下載 timeout');
            throw TimeoutException('wac 下載超時', const Duration(seconds: 30));
          },
        );
        debugPrint('[ScheduleNotifier] wac 目錄載入完成: ${catalog.length} 筆');
        if (catalog.length > 0) {
          await cache.setSimple(
            CacheBoxes.courses,
            catalogCacheKey,
            catalog.toJson(),
            ttl: CacheTTL.courses,
          );
        } else {
          debugPrint('[ScheduleNotifier] wac 目錄為空，不寫入快取');
        }
      } catch (e) {
        debugPrint('[ScheduleNotifier] wac 目錄下載失敗: $e — 將以無節次模式顯示課表');
        catalog = null;
      }
    }

    if (catalog == null) {
      _processScheduleData(data, state.semesters);
      return;
    }

    debugPrint('[ScheduleNotifier] 開始 join seqno: ${data.courses.length} 門課, wac 有 ${catalog.length} 筆');
    final enrichedCourses = <Course>[];
    int matched = 0;
    for (final course in data.courses) {
      if (course.seqno == null || course.seqno!.isEmpty) {
        enrichedCourses.add(course);
        continue;
      }
      final seqnoTrimmed = course.seqno!.trim();
      final wacEntries = catalog.findBySeqno(seqnoTrimmed);
      if (wacEntries.isEmpty) {
        enrichedCourses.add(course);
        continue;
      }
      matched++;

      final wac = wacEntries.first;
      final periods = wac.expandedPeriods;

      enrichedCourses.add(course.copyWith(
        weekday: int.tryParse(wac.weekday) ?? course.weekday,
        startTime: KmuPeriod.startTimeOf(periods.first) ?? course.startTime,
        endTime: KmuPeriod.endTimeOf(periods.last) ?? course.endTime,
        periods: periods,
        classroom: wac.room.isNotEmpty ? wac.room : course.classroom,
        periodCode: periods.isNotEmpty ? periods.first : null,
      ));
    }

    debugPrint('[ScheduleNotifier] join 完成: matched=$matched, enriched=${enrichedCourses.length}');
    _processScheduleData(ScheduleData(courses: enrichedCourses), state.semesters);
  }

  void _processScheduleData(ScheduleData data, List<SemesterInfo> semesters) {
    final currentSem = semesters.firstWhere((s) => s.isCurrent, orElse: () => semesters.first).id;

    state = state.copyWith(
      courses: data.courses,
      semesters: semesters,
      currentSemester: currentSem,
      isLoading: false,
      error: null,
    );
    debugPrint('[ScheduleNotifier] state 更新: courses=${state.courses.length}, currentSemester=${state.currentSemester}, isLoading=${state.isLoading}');
  }

  /// 刷新
  /// [forceWacRefresh] 為 true 時同時清除 WAC 全校課表 CSV 快取
  Future<void> refresh({bool forceWacRefresh = false}) async {
    final cache = ref.read(cacheServiceProvider);
    await cache.delete(CacheBoxes.courses, 'schedule_data');
    if (forceWacRefresh) {
      final currentState = state;
      if (currentState.currentSemester != null) {
        final parts = currentState.currentSemester!.split('-');
        if (parts.length >= 2) {
          final year = parts[0];
          final sem = parts[1];
          final catalogCacheKey = 'wac_catalog_${year}_$sem';
          await cache.delete(CacheBoxes.courses, catalogCacheKey);
          debugPrint('[ScheduleNotifier] 強制清除 WAC 目錄快取: $catalogCacheKey');
        }
      }
    }
    await _loadSchedule();
  }

  /// 顯示課程詳細資料 Dialog
  void showCourseDetail(BuildContext context, Course course) {
    final endpoints = ref.read(endpointsProvider);
    final parts = course.id.split('-');
    final seq = parts.length >= 3 ? parts[2].trim() : '';

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
            final detail = snapshot.data as Map<String, dynamic>;
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
                    ..._buildOutlineList(detail['outline'] as List),
                  ],
                  if (detail['textbook'] != null && detail['textbook'] is List) ...[
                    const SizedBox(height: 12),
                    const Text('教科書', style: TextStyle(fontWeight: FontWeight.bold)),
                    ..._buildTextbookList(detail['textbook'] as List),
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

/// 將 outline list 轉為 Text widgets
List<Widget> _buildOutlineList(List outlineList) {
  return outlineList.map((item) {
    final m = item as Map?;
    return Text(m?['syllabn']?.toString() ?? '');
  }).toList();
}

/// 將 textbook list 轉為 Text widgets
List<Widget> _buildTextbookList(List textbookList) {
  return textbookList.map((item) {
    final t = item as Map?;
    return Text('${t?['title']} (${t?['author']}, ${t?['pub']})');
  }).toList();
}

/// 課表頁面
class MySchedulePage extends ConsumerWidget {
  const MySchedulePage({super.key});

  @override
    Widget build(BuildContext context, WidgetRef ref) {
      final state = ref.watch(scheduleProvider);
      final notifier = ref.read(scheduleProvider.notifier);

      return FocusScope(
        autofocus: true,
        child: Shortcuts(
          shortcuts: <LogicalKeySet, Intent>{
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyR): const _RefreshIntent(),
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.shift, LogicalKeyboardKey.keyR): const _ForceRefreshIntent(),
          },
          child: Actions(
            actions: <Type, Action<Intent>>{
              _RefreshIntent: CallbackAction<_RefreshIntent>(onInvoke: (_) {
                debugPrint('[MySchedulePage] Ctrl+R triggered');
                notifier.refresh();
                return null;
              }),
              _ForceRefreshIntent: CallbackAction<_ForceRefreshIntent>(onInvoke: (_) {
                debugPrint('[MySchedulePage] Ctrl+Shift+R triggered');
                notifier.refresh(forceWacRefresh: true);
                return null;
              }),
            },
            child: Scaffold(
              appBar: AppBar(
                title: const Text('我的課表'),
                actions: [
                  if (state.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: '重新整理課表 (長按/Shift+點擊同時更新全校課表 CSV)',
                    onPressed: () => notifier.refresh(),
                    onLongPress: () => notifier.refresh(forceWacRefresh: true),
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
                      : RefreshIndicator(
                          onRefresh: () => notifier.refresh(),
                          child: _buildScheduleView(context, state, notifier),
                        ),
            ),
          ),
        ),
      );
  }

  Widget _buildScheduleView(BuildContext context, ScheduleState state, ScheduleNotifier notifier) {
    final allCourses = state.courses;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        WeekScheduleGrid(
          courses: allCourses,
          onCourseTap: (course) => notifier.showCourseDetail(context, course),
        ),
      ],
    );
  }
}

/// 課表 Provider
final scheduleProvider = AutoDisposeNotifierProvider<ScheduleNotifier, ScheduleState>(() {
  return ScheduleNotifier();
});