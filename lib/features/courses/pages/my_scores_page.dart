// 成績頁面
// 學期切換、GPA 趨勢圖、科目列表、成績詳情、Riverpod 狀態管理

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core.dart' hide DateUtils;

/// 成績狀態
@immutable
class ScoresState {
  const ScoresState({
    this.semesters = const [],
    this.currentSemester,
    this.subjects = const [],
    this.gpaTrend = const [],
    this.isLoading = false,
    this.error,
  });

  final List<SemesterInfo> semesters;
  final String? currentSemester;
  final List<ScoreSubject> subjects;
  final List<GPATrendPoint> gpaTrend;
  final bool isLoading;
  final String? error;

  ScoresState copyWith({
    List<SemesterInfo>? semesters,
    String? currentSemester,
    List<ScoreSubject>? subjects,
    List<GPATrendPoint>? gpaTrend,
    bool? isLoading,
    String? error,
  }) {
    return ScoresState(
      semesters: semesters ?? this.semesters,
      currentSemester: currentSemester ?? this.currentSemester,
      subjects: subjects ?? this.subjects,
      gpaTrend: gpaTrend ?? this.gpaTrend,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 成績 Notifier
class ScoresNotifier extends AutoDisposeNotifier<ScoresState> {
  late final Endpoints _endpoints;
  late final CacheService _cache;

  @override
  ScoresState build() {
    _endpoints = ref.read(endpointsProvider);
    _cache = ref.read(cacheServiceProvider);

    // 延遲載入，避免在 build 階段修改 state
    Future.microtask(() => _loadScores());
    return const ScoresState();
  }

  /// 載入成績
  Future<void> _loadScores() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      const cacheKey = 'scores_data';
      final cached = await _cache.getSimple<ScoresData>(CacheBoxes.courses, cacheKey);

      if (cached != null) {
        _processScoresData(cached);
        return;
      }

      // 取得當前登入的使用者憑證
      final credentials = ref.read(currentUserCredentialsProvider);
      if (credentials == null) {
        throw Exception('請先登入');
      }

      final userId = credentials['userId']!;
      final password = credentials['password']!;

      // 1. 取得學期清單 (Python: getMyAllSem)
      final semesters = await _endpoints.courses.getSemesters(
        userId: userId,
        password: password,
      );
      debugPrint('[ScoresNotifier] 學期清單: ${semesters.length} 筆');

      // 2. 選擇當前學期 (取第一個或當前學期)
      String year = '';
      String sem = '';
      if (semesters.isNotEmpty) {
        final currentSem = semesters.firstWhere(
          (s) => s.isCurrent,
          orElse: () => semesters.first,
        );
        // SemesterInfo.id 格式可能是 "115-1"，拆分 year/sem
        final parts = currentSem.id.split('-');
        if (parts.length >= 2) {
          year = parts[0];
          sem = parts[1];
        } else {
          year = currentSem.id;
        }
        debugPrint('[ScoresNotifier] 使用學期: ${currentSem.name} (year=$year, sem=$sem)');
      }

      if (year.isEmpty || sem.isEmpty) {
        throw Exception('無法取得學期資訊');
      }

      // 3. 取得成績 (Python: myscore_his)
      final response = await _endpoints.courses.getScores(
        year: year,
        sem: sem,
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
            {'_scores_data': true, 'data': data.toJson()},
            ttl: CacheTTL.courses,
          );
        } catch (_) {}
        _processScoresData(data, semesters);
      } else {
        throw Exception(response?.message ?? 'Unknown error');
      }
    } catch (e) {
      debugPrint('[ScoresNotifier] 載入成績失敗: $e');
      state = state.copyWith(
        isLoading: false,
        error: '載入成績失敗: $e',
      );
    }
  }

  void _processScoresData(ScoresData data, [List<SemesterInfo>? semesters]) {
    final sems = semesters ?? data.semesters;
    state = state.copyWith(
      semesters: sems,
      currentSemester: data.currentSemester ?? (sems.isNotEmpty ? sems.first.id : null),
      subjects: data.subjects,
      gpaTrend: data.gpaTrend,
      isLoading: false,
    );
  }

  /// 切換學期
  void changeSemester(String semester) {
    state = state.copyWith(currentSemester: semester);
  }

  /// 取得當前學期科目
  List<ScoreSubject> get currentSemesterSubjects {
    if (state.currentSemester == null) return state.subjects;
    return state.subjects.where((s) => s.semester == state.currentSemester).toList();
  }

  /// 刷新
  Future<void> refresh() async {
    await _cache.delete(CacheBoxes.courses, 'scores_data');
    await _loadScores();
  }
}

/// 成績 Provider
final scoresProvider = AutoDisposeNotifierProvider<ScoresNotifier, ScoresState>(() {
  return ScoresNotifier();
});

/// 成績頁面
class MyScoresPage extends ConsumerWidget {
  const MyScoresPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scoresProvider);
    final notifier = ref.read(scoresProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的成績'),
        actions: [
          if (state.semesters.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.school),
              onSelected: notifier.changeSemester,
              itemBuilder: (context) => state.semesters.map((s) => PopupMenuItem(
                value: s.id,
                child: Row(
                  children: [
                    Text(s.name),
                    if (s.isCurrent) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.check, size: 16, color: Theme.of(context).colorScheme.primary),
                    ],
                  ],
                ),
              )).toList(),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: notifier.refresh,
            tooltip: '重新整理',
          ),
        ],
      ),
      body: state.isLoading && state.subjects.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _buildError(context, state.error!, notifier)
              : state.subjects.isEmpty
                  ? _buildEmptyState(context)
                  : _buildScoresView(context, state, notifier),
    );
  }

  Widget _buildError(BuildContext context, String error, ScoresNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text('載入失敗', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(error, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(onPressed: notifier.refresh, icon: const Icon(Icons.refresh), label: const Text('重試')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grade_outlined, size: 80, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('目前沒有成績資料', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('成績公布後將顯示在此', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildScoresView(BuildContext context, ScoresState state, ScoresNotifier notifier) {
    final currentSubjects = notifier.currentSemesterSubjects;
    final passedSubjects = currentSubjects.where((s) => s.isPassed).toList();
    final failedSubjects = currentSubjects.where((s) => s.score != null && !s.isPassed).toList();
    final pendingSubjects = currentSubjects.where((s) => s.score == null).toList();

    final semesterGpa = state.gpaTrend.isNotEmpty && state.currentSemester != null
        ? state.gpaTrend.firstWhere((g) => g.semester == state.currentSemester, orElse: () => const GPATrendPoint(semester: '', gpa: 0, credits: 0, subjectCount: 0)).gpa
        : state.cumulativeGpa;

    final cumulativeGpa = state.gpaTrend.isNotEmpty
        ? state.gpaTrend.last.gpa
        : state.cumulativeGpa;

    return CustomScrollView(
      slivers: [
        // GPA 概覽卡片
        SliverToBoxAdapter(
          child: _buildGpaOverview(context, state, semesterGpa, cumulativeGpa),
        ),

        // GPA 趨勢圖
        if (state.gpaTrend.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildGpaChart(context, state.gpaTrend),
          ),

        // 科目列表標題
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  state.currentSemester != null ? '${state.currentSemester} 成績' : '所有學期成績',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  '共 ${currentSubjects.length} 科 (已出分 ${passedSubjects.length + failedSubjects.length} 科)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),

        // 科目列表
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index < passedSubjects.length) {
                return _ScoreTile(subject: passedSubjects[index], status: ScoreStatus.passed);
              }
              index -= passedSubjects.length;
              if (index < failedSubjects.length) {
                return _ScoreTile(subject: failedSubjects[index], status: ScoreStatus.failed);
              }
              index -= failedSubjects.length;
              if (index < pendingSubjects.length) {
                return _ScoreTile(subject: pendingSubjects[index], status: ScoreStatus.pending);
              }
              return null;
            },
            childCount: passedSubjects.length + failedSubjects.length + pendingSubjects.length,
          ),
        ),

        // 底部間距
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildGpaOverview(BuildContext context, ScoresState state, double semesterGpa, double cumulativeGpa) {
    final theme = Theme.of(context);
    final currentSubjects = state.subjects.where((s) => s.semester == state.currentSemester).toList();
    final passedSubjects = currentSubjects.where((s) => s.isPassed).toList();
    final totalCredits = currentSubjects.fold<double>(0, (sum, s) => sum + s.credit);
    final earnedCredits = passedSubjects.fold<double>(0, (sum, s) => sum + s.credit);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _GpaCard(
                  label: '本學期 GPA',
                  value: semesterGpa.toStringAsFixed(2),
                  icon: Icons.trending_up,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GpaCard(
                  label: '累積 GPA',
                  value: cumulativeGpa.toStringAsFixed(2),
                  icon: Icons.analytics,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: '本學期學分',
                  value: '${earnedCredits.toStringAsFixed(1)} / ${totalCredits.toStringAsFixed(1)}',
                  icon: Icons.credit_card,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: '及格率',
                  value: currentSubjects.isEmpty ? '0%' : '${((passedSubjects.length / currentSubjects.length) * 100).toStringAsFixed(0)}%',
                  icon: Icons.check_circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGpaChart(BuildContext context, List<GPATrendPoint> trend) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GPA 趨勢', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 0.5,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < trend.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              trend[value.toInt()].semester,
                              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 0.5,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (trend.length - 1).toDouble(),
                minY: 0,
                maxY: 4.3,
                lineBarsData: [
                  LineChartBarData(
                    spots: trend.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.gpa)).toList(),
                    isCurved: true,
                    gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: theme.colorScheme.primary,
                        strokeWidth: 2,
                        strokeColor: theme.colorScheme.surface,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.3),
                          theme.colorScheme.secondary.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum ScoreStatus { passed, failed, pending }

/// 成績磚
class _ScoreTile extends StatelessWidget {
  const _ScoreTile({required this.subject, required this.status});

  final ScoreSubject subject;
  final ScoreStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasScore = subject.score != null;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case ScoreStatus.passed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = '及格';
        break;
      case ScoreStatus.failed:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = '不及格';
        break;
      case ScoreStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusText = '未出分';
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => _showScoreDetail(context, subject),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(statusText, style: theme.textTheme.labelSmall?.copyWith(color: statusColor, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (hasScore)
                    Text(
                      '${subject.score!.toStringAsFixed(1)} 分',
                      style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                    )
                  else
                    Text(
                      '未出分',
                      style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(subject.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (subject.teacher != null) ...[
                    Icon(Icons.person_outline, size: 14, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(subject.teacher!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(width: 16),
                  ],
                  Icon(Icons.credit_card, size: 14, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text('${subject.credit} 學分', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(width: 16),
                  if (subject.grade != null) ...[
                    Icon(Icons.grade, size: 14, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('等第: ${subject.grade}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
              if (hasScore && (subject.midterm != null || subject.finalExam != null || subject.homework != null)) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    if (subject.midterm != null)
                      _ScoreComponent(label: '期中', value: subject.midterm!),
                    if (subject.finalExam != null)
                      _ScoreComponent(label: '期末', value: subject.finalExam!),
                    if (subject.homework != null)
                      _ScoreComponent(label: '平時', value: subject.homework!),
                    if (subject.attendance != null)
                      _ScoreComponent(label: '出席', value: subject.attendance!),
                    if (subject.other != null)
                      _ScoreComponent(label: '其他', value: subject.other!),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showScoreDetail(BuildContext context, ScoreSubject subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(subject.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subject.score != null)
                _DetailRow('總分', '${subject.score!.toStringAsFixed(1)} 分', valueColor: subject.isPassed ? Colors.green : Colors.red),
              if (subject.grade != null) _DetailRow('等第', subject.grade!),
              _DetailRow('學分', '${subject.credit}'),
              _DetailRow('學期', subject.semester ?? '未知'),
              if (subject.type != null) _DetailRow('類型', subject.type!),
              if (subject.department != null) _DetailRow('開課系所', subject.department!),
              const Divider(),
              if (subject.midterm != null) _DetailRow('期中考', subject.midterm!.toStringAsFixed(1)),
              if (subject.finalExam != null) _DetailRow('期末考', subject.finalExam!.toStringAsFixed(1)),
              if (subject.homework != null) _DetailRow('平時作業', subject.homework!.toStringAsFixed(1)),
              if (subject.attendance != null) _DetailRow('出席率', '${subject.attendance!.toStringAsFixed(1)}%'),
              if (subject.other != null) _DetailRow('其他', subject.other!.toStringAsFixed(1)),
              if (subject.average != null) _DetailRow('班級平均', subject.average!.toStringAsFixed(1)),
              if (subject.rank != null && subject.totalStudents != null) _DetailRow('班排名', '${subject.rank} / ${subject.totalStudents}'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('關閉'))],
      ),
    );
  }
}

class _ScoreComponent extends StatelessWidget {
  const _ScoreComponent({required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        Text(value.toStringAsFixed(1), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value, {this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: valueColor))),
        ],
      ),
    );
  }
}

/// GPA 卡片
class _GpaCard extends StatelessWidget {
  const _GpaCard({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/// 統計卡片
class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// Extension for cumulativeGpa
extension ScoresStateExtension on ScoresState {
  double get cumulativeGpa {
    final passedSubjects = subjects.where((s) => s.score != null).toList();
    if (passedSubjects.isEmpty) return 0;
    double totalPoints = 0;
    double totalCredits = 0;
    for (final s in passedSubjects) {
      totalPoints += s.gradePoint * s.credit;
      totalCredits += s.credit;
    }
    return totalCredits > 0 ? totalPoints / totalCredits : 0;
  }
}