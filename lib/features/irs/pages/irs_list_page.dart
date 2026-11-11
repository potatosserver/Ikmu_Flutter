// IRS 問卷列表頁面

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core.dart';
import '../providers/irs_providers.dart';

class IrsListPage extends ConsumerWidget {
  const IrsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(irsProvider);
    final notifier = ref.read(irsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IRS 答題系統'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: notifier.refresh,
            tooltip: '重新整理',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).pushNamed(RoutePaths.irsHistory),
            tooltip: '歷史記錄',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: notifier.refresh,
        child: state.isLoading && state.questionnaires.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
                ? _buildError(context, state.error!, notifier)
                : state.questionnaires.isEmpty
                    ? _buildEmptyState(context)
                    : _buildListView(context, state, notifier),
      ),
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
              onPressed: notifier.refresh,
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
            Icons.quiz_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '目前無可用問卷',
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

  Widget _buildListView(BuildContext context, IrsState state, IrsNotifier notifier) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.questionnaires.length,
      itemBuilder: (context, index) {
        final questionnaire = state.questionnaires[index];
        return _QuestionnaireCard(
          questionnaire: questionnaire,
          onTap: () => notifier.loadQuestionnaireDetail(questionnaire.id).then((_) {
            if (context.mounted) {
              Navigator.of(context).pushNamed('${RoutePaths.irs}/detail');
            }
          }),
        );
      },
    );
  }
}

/// 問卷卡片
class _QuestionnaireCard extends StatelessWidget {
  const _QuestionnaireCard({
    required this.questionnaire,
    required this.onTap,
  });

  final IrsQuestionnaire questionnaire;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSubmitted = questionnaire.isSubmitted;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isSubmitted ? null : onTap,
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
                      questionnaire.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isSubmitted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '已完成',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                questionnaire.description,
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
                    icon: Icons.help_outline,
                    label: '${questionnaire.questionCount} 題',
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.access_time,
                    label: _formatTimeRange(questionnaire.startTime, questionnaire.endTime),
                    color: theme.colorScheme.secondary,
                  ),
                  if (questionnaire.category != null) ...[
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.category_outlined,
                      label: questionnaire.category!,
                      color: theme.colorScheme.tertiary,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeRange(String start, String end) {
    // 簡單格式化：只顯示日期部分
    try {
      final startDate = DateTime.parse(start);
      final endDate = DateTime.parse(end);
      return '${startDate.month}/${startDate.day} - ${endDate.month}/${endDate.day}';
    } catch (_) {
      return '$start - $end';
    }
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