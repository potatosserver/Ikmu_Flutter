// IRS 學生歷史記錄頁面
// 對應 KMU IRS 學生端：作答記錄 / 提問記錄 / 考試詳情

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core.dart';
import '../providers/irs_providers.dart';

class IrsHistoryPage extends ConsumerWidget {
  const IrsHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(irsProvider);
    final notifier = ref.read(irsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IRS 作答/提問記錄'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.loadStudentClasses(),
            tooltip: '重新整理課程',
          ),
        ],
      ),
      body: state.isLoadingHistory && state.studentClasses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.historyError != null
              ? _buildError(context, state.historyError!, notifier)
              : state.studentClasses.isEmpty
                  ? _buildEmptyState(context)
                  : _buildCourseSelector(context, state, notifier),
    );
  }

  Widget _buildError(BuildContext context, String error, IrsNotifier notifier) {
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
              onPressed: () => notifier.loadStudentClasses(),
              icon: const Icon(Icons.refresh),
              label: const Text('重試'),
            ),
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
          Icon(
            Icons.class_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '目前無課程',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '請稍後再試或下拉重新整理',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseSelector(BuildContext context, IrsState state, IrsNotifier notifier) {
    return Column(
      children: [
        // 課程選擇
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '選擇課程',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 56,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.studentClasses.length,
                  itemBuilder: (context, index) {
                    final course = state.studentClasses[index];
                    final isSelected = state.studentClasses.isNotEmpty &&
                        index == 0; // 簡單處理：預設選第一個
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(course.name),
                        onSelected: (_) => _loadRecords(context, notifier, course.id),
                        avatar: const Icon(Icons.book, size: 18),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Tab
              _RecordTabs(
                state: state,
                notifier: notifier,
              ),
            ],
          ),
        ),
        // 記錄列表
        Expanded(
          child: state.isLoadingHistory
              ? const Center(child: CircularProgressIndicator())
              : state.historyError != null
                  ? Center(child: Text(state.historyError!))
                  : state.answerRecords.isEmpty && state.askRecords.isEmpty
                      ? _buildNoRecordsState(context)
                      : _buildRecordsList(context, state, notifier),
        ),
      ],
    );
  }

  void _loadRecords(BuildContext context, IrsNotifier notifier, String courseId) {
    notifier.loadAnswerRecords(courseId);
    notifier.loadAskRecords(courseId);
  }

  Widget _buildNoRecordsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '目前無記錄',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '選擇課程後會顯示作答與提問記錄',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList(BuildContext context, IrsState state, IrsNotifier notifier) {
    // 目前顯示作答記錄 (qaList)，可後續加 Tab 切換
    final records = state.answerRecords;

    return RefreshIndicator(
      onRefresh: () => notifier.loadAnswerRecords(state.studentClasses.isNotEmpty ? state.studentClasses.first.id : ''),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          return _RecordCard(
            record: record,
            onTap: () => notifier.loadExamDetail(record.id),
          );
        },
      ),
    );
  }
}

/// 記錄分頁標籤
class _RecordTabs extends ConsumerWidget {
  const _RecordTabs({
    required this.state,
    required this.notifier,
  });

  final IrsState state;
  final IrsNotifier notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: FilterChip(
            selected: true, // 預設顯示作答記錄
            label: const Text('作答記錄'),
            onSelected: (_) {},
            avatar: const Icon(Icons.check_circle, size: 16),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilterChip(
            selected: false,
            label: const Text('提問記錄'),
            onSelected: (_) {},
            avatar: const Icon(Icons.question_answer, size: 16),
          ),
        ),
      ],
    );
  }
}

/// 記錄卡片
class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.record,
    required this.onTap,
  });

  final IrsAnswerRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPassed = record.myScore >= (record.totalScore / 2);

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
                  Expanded(
                    child: Text(
                      record.courseName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPassed
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${record.myScore}/${record.totalScore} 分',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isPassed ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                record.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.access_time,
                    label: record.answerTime,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 資訊晶片
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
