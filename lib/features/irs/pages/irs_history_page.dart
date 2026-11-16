// IRS 學生歷史記錄頁面
// 對應 KMU IRS 學生端：作答記錄 / 提問記錄 / 考試詳情
// 完整對齊 IRSRecordActivity.java：getQAData + show99View

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core.dart';
import '../providers/irs_providers.dart';
import '../utils/irs_debug_log.dart';

class IrsHistoryPage extends ConsumerWidget {
  const IrsHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(irsProvider);
    final notifier = ref.read(irsProvider.notifier);

    // 進入頁面時自動載入課程列表
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.studentClasses.isEmpty && !state.isLoadingHistory) {
        IrsDebugLog.log('[IRS_HISTORY] 進入頁面，載入課程列表');
        notifier.loadStudentClasses();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('IRS 作答/提問記錄'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              IrsDebugLog.log('[IRS_HISTORY] 手動重新整理課程');
              notifier.loadStudentClasses();
            },
            tooltip: '重新整理課程',
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () => context.push(RoutePaths.irsDebugLog),
            tooltip: '除錯日誌',
          ),
        ],
      ),
      body: state.isLoadingHistory && state.studentClasses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.historyError != null
              ? _buildError(context, state.historyError!, notifier)
              : state.studentClasses.isEmpty
                  ? _buildEmptyState(context)
                  : _buildCourseSelector(context, state, notifier, ref),
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

  Widget _buildCourseSelector(BuildContext context, IrsState state, IrsNotifier notifier, WidgetRef ref) {
    return Column(
      children: [
        // 課程選擇（下拉選單）
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
              DropdownButtonFormField<String>(
                initialValue: state.selectedCourseId?.isNotEmpty == true ? state.selectedCourseId : null,
                items: state.studentClasses.map((course) {
                  return DropdownMenuItem<String>(
                    value: course.id,
                    child: Text(course.displayName),
                  );
                }).toList(),
                onChanged: (courseId) {
                  if (courseId != null) {
                    notifier.setSelectedCourseId(courseId);
                    _loadRecords(context, notifier, courseId);
                  }
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '請選擇課程',
                  prefixIcon: Icon(Icons.school, size: 20),
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
                      ? _buildNoRecordsState(context, state.historyTab)
                      : _buildRecordsList(context, state, notifier, ref),
        ),
      ],
    );
  }

  void _loadRecords(BuildContext context, IrsNotifier notifier, String courseId) {
    IrsDebugLog.log('[IRS_HISTORY] 選擇課程: $courseId，載入作答/提問記錄');
    notifier.loadAnswerRecords(courseId);
    notifier.loadAskRecords(courseId);
  }

  Widget _buildNoRecordsState(BuildContext context, int historyTab) {
    final isAskTab = historyTab == 1;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isAskTab ? Icons.question_answer_outlined : Icons.assignment_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isAskTab ? '目前無提問記錄' : '目前無作答記錄',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            isAskTab
                ? '該課程尚無提問紀錄'
                : '選擇課程後會顯示作答記錄',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList(BuildContext context, IrsState state, IrsNotifier notifier, WidgetRef ref) {
    final records = state.historyTab == 0 ? state.answerRecords : state.askRecords;
    final tabTitle = state.historyTab == 0 ? '作答記錄' : '提問記錄';
    final selectedCourseId = state.selectedCourseId;

    return RefreshIndicator(
      onRefresh: () {
        if (selectedCourseId != null && selectedCourseId.isNotEmpty) {
          if (state.historyTab == 0) {
            return notifier.loadAnswerRecords(selectedCourseId);
          } else {
            return notifier.loadAskRecords(selectedCourseId);
          }
        }
        return Future.value();
      },
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return _RecordCard(
                  record: record,
                  onTap: () async {
                    try {
                      await notifier.loadExamDetail(record);
                      if (context.mounted) {
                        // 重新讀取最新 state，確保 examDetail 已更新
                        final latestState = ref.read(irsProvider);
                        _showExamDetailDialog(context, latestState, record);
                      }
                    } catch (e) {
                      IrsDebugLog.log('[IRS_HISTORY] 載入詳情失敗: $e');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('載入詳情失敗：$e')),
                        );
                      }
                    }
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              records.isEmpty ? '目前無 $tabTitle' : '共 ${records.length} 筆 $tabTitle',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
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
            selected: state.historyTab == 0,
            label: const Text('作答記錄'),
            onSelected: (_) => notifier.setHistoryTab(0),
            avatar: const Icon(Icons.check_circle, size: 16),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilterChip(
            selected: state.historyTab == 1,
            label: const Text('提問記錄'),
            onSelected: (_) => notifier.setHistoryTab(1),
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
                      record.courseName ?? '',
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
                record.title ?? '',
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
                    label: record.answerTime ?? record.askTime ?? '',
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

/// 歷史記錄詳情對話框 (M3 風格，對應原版 show99View / IRSRecordActivity.GetExamData)
/// - questionType == "99" (試卷): 顯示 examDetail.subQuestions (subquList)
/// - 單題 ("1"/"2"/"3"/"4"): 顯示該筆記錄的選項與分數
void _showExamDetailDialog(BuildContext context, IrsState state, IrsAnswerRecord record) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final examDetail = state.examDetail;
  final isExamPaper = record.isExamPaper;

  // M3: 決定狀態 Chip
  final bool hasScore = record.totalScore > 0;
  final bool isCorrect = record.correct == true;
  final bool isWrong = record.correct == false;
  Widget statusChip;
  if (!hasScore) {
    statusChip = Chip(
      label: Text('不計分', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
      backgroundColor: colorScheme.surfaceContainerHighest,
      side: BorderSide(color: colorScheme.outlineVariant),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  } else if (isCorrect) {
    statusChip = Chip(
      label: Text('答對', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onTertiaryContainer)),
      backgroundColor: colorScheme.tertiaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  } else if (isWrong) {
    statusChip = Chip(
      label: Text('答錯', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onErrorContainer)),
      backgroundColor: colorScheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  } else {
    statusChip = Chip(
      label: Text('${record.myScore}/${record.totalScore} 分', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
      backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      side: BorderSide(color: colorScheme.outlineVariant),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.92,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // M3 Header: 標題 + 狀態 Chip + 關閉按鈕
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.courseName?.isNotEmpty == true
                                ? record.courseName!
                                : (record.courseId?.isNotEmpty == true
                                    ? record.courseId!
                                    : 'IRS 作答記錄'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            record.answerTime ?? record.askTime ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    statusChip,
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close),
                      iconSize: 20,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // 內容區
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 得分 (M3: 移到 Header 狀態 Chip，這裡保留作為詳細顯示)
                      if (hasScore) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '得分：${record.myScore} / ${record.totalScore}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onPrimaryContainer,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 題目
                      Text(
                        '題目',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // M3 題目卡片: surfaceContainerLowest + 16dp 圓角 + outlineVariant 邊框
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.outlineVariant,
                          ),
                        ),
                        child: Text(
                          record.title ?? record.description ?? '',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                          softWrap: true,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 我的答案 / 正確性
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '我的答案：${record.myAnswer?.isEmpty == true ? '未作答' : record.myAnswer ?? ''} ${record.correct == true ? '✅ 答對' : (record.correct == false ? '❌ 答錯' : '')}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: record.correct == true
                                    ? Colors.green.shade700
                                    : (record.correct == false
                                        ? Colors.red.shade700
                                        : theme.colorScheme.onSurfaceVariant),
                                fontWeight: FontWeight.w500,
                              ),
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 試卷子題列表 (questionType == 99)
                      if (isExamPaper && examDetail != null && examDetail.subQuestions.isNotEmpty) ...[
                        Text(
                          '試卷詳情 (共 ${examDetail.subQuestions.length} 小題)',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...examDetail.subQuestions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final sub = entry.value;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${index + 1}. ${sub.description}',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (sub.imgPath != null && sub.imgPath!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        // TODO: 圖片預覽
                                      },
                                      icon: const Icon(Icons.image, size: 18),
                                      label: const Text('查看子題圖片'),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  _buildSubQuestionDetail(theme, sub),
                                ],
                              ),
                            ),
                          );
                        }),
                      ] else if (!isExamPaper && record.options != null && record.options!.isNotEmpty) ...[
                        // 單題：M3 風格選項卡片
                        Text(
                          '選項',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...record.options!.asMap().entries.map((entry) {
                          final opt = entry.value as Map<String, dynamic>;
                          final optKey = opt['optKey']?.toString() ?? '';
                          final optVal = opt['optVal']?.toString() ?? '';
                          final bool optCorrect = opt['correct'] as bool? ?? false;
                          final bool isSelected = record.myAnswer == optKey;

                          // M3: 決定選項狀態與樣式
                          Color bgColor;
                          Color borderColor;
                          Widget? statusChip;

                          if (optCorrect) {
                            // 正確答案（無論是否被選中）
                            bgColor = colorScheme.tertiaryContainer;
                            borderColor = colorScheme.tertiary;
                            statusChip = Chip(
                              label: Text(isSelected ? '答對' : '正確答案',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onTertiaryContainer,
                                  )),
                              backgroundColor: colorScheme.tertiaryContainer,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            );
                          } else if (isSelected) {
                            // 我選的但錯誤
                            bgColor = colorScheme.errorContainer;
                            borderColor = colorScheme.error;
                            statusChip = Chip(
                              label: Text('答錯',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onErrorContainer,
                                  )),
                              backgroundColor: colorScheme.errorContainer,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            );
                          } else {
                            // 普通未選選項
                            bgColor = colorScheme.surfaceContainerLowest;
                            borderColor = colorScheme.outlineVariant;
                            statusChip = null;
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: bgColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: borderColor, width: 1.5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  // 選項標記圓圈
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: optCorrect || isSelected
                                          ? borderColor
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: borderColor,
                                        width: 2,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: (optCorrect || isSelected)
                                        ? Icon(
                                            optCorrect ? Icons.check : Icons.close,
                                            size: 14,
                                            color: optCorrect
                                                ? colorScheme.onTertiaryContainer
                                                : colorScheme.onErrorContainer,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  // 選項文字
                                  Expanded(
                                    child: Text(
                                      '$optKey. $optVal',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurface,
                                      ),
                                      softWrap: true,
                                    ),
                                  ),
                                  // 狀態 Chip
                                  if (statusChip != null) statusChip,
                                ],
                              ),
                            ),
                          );
                        }),
                      ],

                      const SizedBox(height: 16),

                      // 標準答案
                      if (record.stdAnswer?.isNotEmpty == true) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.verified,
                              size: 16,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '標準答案：${record.stdAnswer}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 分數說明
                      if (record.scoreDesc?.isNotEmpty == true) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                record.scoreDesc!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 圖片
                      if (record.imgPath?.isNotEmpty == true) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.image_outlined,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '含圖片：${record.imgPath}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),

              // 底部按鈕
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '關閉',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildSubQuestionDetail(ThemeData theme, IrsSubQuestion sub) {
  switch (sub.questionType) {
    case 2: // 單選
      if (sub.optionList is List && sub.optionList!.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sub.optionList!.map<Widget>((opt) {
            final isSelected = sub.myAnswer == opt.optKey;
            final isCorrect = opt.correct;
            return Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? theme.colorScheme.primary
                          : (isSelected
                              ? Colors.orange
                              : Colors.transparent),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: isCorrect || isSelected
                        ? Icon(
                            isCorrect ? Icons.check : Icons.close,
                            size: 12,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${opt.optKey}. ${opt.optVal}',
                      style: theme.textTheme.bodySmall,
                      softWrap: true,
                    ),
                  ),
                  if (isCorrect)
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green.shade700,
                    ),
                ],
              ),
            );
          }).toList(),
        );
      }
      return const SizedBox.shrink();
    case 3: // 多選
      if (sub.optionList is List && sub.optionList!.isNotEmpty) {
        final myAnswers = sub.myAnswer?.split('_') ?? <String>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sub.optionList!.map<Widget>((opt) {
            final key = opt.optKey;
            final isSelected = myAnswers.contains(key);
            final isCorrect = opt.correct;
            return Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? theme.colorScheme.primary
                          : (isSelected
                              ? Colors.orange
                              : Colors.transparent),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: isCorrect || isSelected
                        ? Icon(
                            isCorrect ? Icons.check : Icons.close,
                            size: 12,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$key. ${opt.optVal}',
                      style: theme.textTheme.bodySmall,
                      softWrap: true,
                    ),
                  ),
                  if (isCorrect)
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green.shade700,
                    ),
                ],
              ),
            );
          }).toList(),
        );
      }
      return const SizedBox.shrink();
    case 4: // 填空
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            '我的填空：${sub.myAnswer?.isEmpty == true ? '未作答' : sub.myAnswer}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          if (sub.stdAnswer?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              '標準答案：${sub.stdAnswer}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ],
      );
    default:
      return const SizedBox.shrink();
  }
}