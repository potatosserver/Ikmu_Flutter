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
                      : _buildRecordsList(context, state, notifier),
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

  Widget _buildRecordsList(BuildContext context, IrsState state, IrsNotifier notifier) {
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
                        _showExamDetailDialog(context, state, record);
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
/// 設計參考: M3 Dialog/Sheet 規格，動態色彩、語意容器、緊湊佈局
void _showExamDetailDialog(BuildContext context, IrsState state, IrsAnswerRecord record) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final examDetail = state.examDetail;
  final isExamPaper = record.isExamPaper;
  final isCorrect = record.correct == true;
  final bool hasScore = record.totalScore > 0;

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        // M3: 標準對話框最大寬度 560dp，平板上收斂至 560-640dp
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28), // M3 Extra Large 圓角
        ),
        backgroundColor: colorScheme.surfaceContainerHigh, // M3 Surface 層級
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600), // M3 建議最大寬度
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: 標題 + 狀態 Chip + 關閉按鈕
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            record.answerTime ?? record.askTime ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 狀態 Chip (如: 不計分 / 練習題)
                    if (!hasScore)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '不計分',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? colorScheme.tertiaryContainer
                              : (record.correct == false
                                  ? colorScheme.errorContainer
                                  : colorScheme.primaryContainer),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isCorrect
                                  ? Icons.check_circle
                                  : (record.correct == false ? Icons.cancel : Icons.help_outline),
                              size: 14,
                              color: isCorrect
                                  ? colorScheme.onTertiaryContainer
                                  : (record.correct == false
                                      ? colorScheme.onErrorContainer
                                      : colorScheme.onPrimaryContainer),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isCorrect
                                  ? '答對'
                                  : (record.correct == false ? '答錯' : '${record.myScore}/${record.totalScore}'),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isCorrect
                                    ? colorScheme.onTertiaryContainer
                                    : (record.correct == false
                                        ? colorScheme.onErrorContainer
                                        : colorScheme.onPrimaryContainer),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close),
                      iconSize: 20,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      tooltip: '關閉',
                    ),
                  ],
                ),
              ),

              // 內容區
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      // 題目卡片 (M3 Surface Container Lowest / 白底)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16), // M3 Large 圓角
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          record.title ?? record.description ?? '',
                          style: theme.textTheme.titleMedium?.copyWith(
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                            fontSize: 18, // M3 Title Medium
                          ),
                          softWrap: true,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 單題模式：選項列表
                      if (!isExamPaper && record.options != null && record.options!.isNotEmpty)
                        _buildOptionsListM3(context, theme, colorScheme, record),

                      // 試卷模式：子題列表
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
                          return _buildSubQuestionCardM3(context, theme, colorScheme, index, sub);
                        }),
                      ],

                      const SizedBox(height: 16),

                      // 標準答案
                      if (record.stdAnswer?.isNotEmpty == true)
                        _buildInfoRow(
                          context: context,
                          icon: Icons.verified,
                          iconColor: Colors.blue,
                          text: '標準答案：${record.stdAnswer}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                      // 分數說明
                      if (record.scoreDesc?.isNotEmpty == true)
                        _buildInfoRow(
                          context: context,
                          icon: Icons.info_outline,
                          iconColor: Colors.grey,
                          text: record.scoreDesc!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),

                      // 圖片
                      if (record.imgPath?.isNotEmpty == true)
                        _buildInfoRow(
                          context: context,
                          icon: Icons.image_outlined,
                          iconColor: Colors.grey,
                          text: '含圖片：${record.imgPath}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),

                      // 底部操作列: 時間資訊 + 關閉按鈕
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 作答時間/進度
                          Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                record.answerTime?.isNotEmpty == true
                                    ? '作答時間：${record.answerTime}'
                                    : '耗時：${record.ansTime ?? record.askTime ?? '--'}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          // M3 Filled Tonal Button (膠囊狀)
                          FilledButton.tonal(
                            onPressed: () => Navigator.pop(context),
                            style: FilledButton.styleFrom(
                              shape: const StadiumBorder(), // 全圓角膠囊
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              minimumSize: const Size(88, 44),
                            ),
                            child: Text(
                              '關閉',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

/// 建立 M3 風格的選項列表 (單題模式)
Widget _buildOptionsListM3(
  BuildContext context,
  ThemeData theme,
  ColorScheme colorScheme,
  IrsAnswerRecord record,
) {
  final options = record.options!;
  final userAnswer = record.myAnswer ?? '';
  final isCorrect = record.correct == true;

  return Column(
    children: options.asMap().entries.map((entry) {
      final opt = entry.value;
      final optKey = opt['optKey']?.toString() ?? '';
      final optVal = opt['optVal']?.toString() ?? '';
      final optCorrect = opt['correct'] as bool? ?? false;
      final isSelected = userAnswer == optKey;
      final isThisCorrect = optCorrect;
      final shouldHighlight = isSelected && isCorrect;

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          // 答對且為用戶選擇：使用 Tonal Container (語意綠)
          color: shouldHighlight
              ? colorScheme.tertiaryContainer.withValues(alpha: 0.8)
              : colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12), // M3 Medium 圓角
          border: Border.all(
            color: shouldHighlight
                ? colorScheme.tertiary
                : (isSelected && !isThisCorrect
                    ? colorScheme.error
                    : colorScheme.outlineVariant.withValues(alpha: 0.5)),
            width: shouldHighlight || isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // M3 Radio Button 風格指示器
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: shouldHighlight
                      ? colorScheme.tertiary
                      : (isSelected
                          ? colorScheme.primary
                          : Colors.transparent),
                  border: Border.all(
                    color: shouldHighlight
                        ? colorScheme.tertiary
                        : (isSelected
                            ? colorScheme.primary
                            : colorScheme.outlineVariant),
                    width: 2,
                  ),
                ),
                child: shouldHighlight || isSelected
                    ? Icon(
                        shouldHighlight ? Icons.check : Icons.radio_button_checked,
                        size: 16,
                        color: shouldHighlight
                            ? colorScheme.onTertiary
                            : colorScheme.onPrimary,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // 選項文字
              Expanded(
                child: Text(
                  '$optKey. $optVal',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: shouldHighlight
                        ? colorScheme.onTertiaryContainer
                        : colorScheme.onSurface,
                    fontWeight: shouldHighlight ? FontWeight.w600 : FontWeight.w400,
                    height: 1.4,
                  ),
                  softWrap: true,
                ),
              ),
              // 狀態標籤
              if (shouldHighlight) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '答對',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onTertiary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ] else if (isSelected && !isThisCorrect) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '答錯',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ] else if (isThisCorrect && !isSelected) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '正確答案',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }).toList(),
  );
}

/// 建立 M3 風格的試卷子題卡片
Widget _buildSubQuestionCardM3(
  BuildContext context,
  ThemeData theme,
  ColorScheme colorScheme,
  int index,
  IrsSubQuestion sub,
) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 0,
    color: colorScheme.surfaceContainerLowest,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: colorScheme.outlineVariant.withValues(alpha: 0.3),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 子題標題
          Text(
            '${index + 1}. ${sub.description}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15,
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
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _buildSubQuestionDetailM3(theme, colorScheme, sub),
        ],
      ),
    ),
  );
}

/// M3 風格的子題詳情渲染 (單選/多選/填空)
Widget _buildSubQuestionDetailM3(ThemeData theme, ColorScheme colorScheme, IrsSubQuestion sub) {
  switch (sub.questionType) {
    case 2: // 單選
      if (sub.optionList != null && sub.optionList!.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sub.optionList!.map<Widget>((opt) {
            final isSelected = sub.myAnswer == opt.optKey;
            final isCorrect = opt.correct;
            final shouldHighlight = isSelected && isCorrect;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: shouldHighlight
                    ? colorScheme.tertiaryContainer.withValues(alpha: 0.6)
                    : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: shouldHighlight
                      ? colorScheme.tertiary.withValues(alpha: 0.5)
                      : colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: shouldHighlight
                          ? colorScheme.tertiary
                          : (isSelected
                              ? colorScheme.primary
                              : Colors.transparent),
                      border: Border.all(
                        color: shouldHighlight
                            ? colorScheme.tertiary
                            : (isSelected
                                ? colorScheme.primary
                                : colorScheme.outlineVariant),
                        width: 2,
                      ),
                    ),
                    child: shouldHighlight || isSelected
                        ? Icon(
                            shouldHighlight ? Icons.check : Icons.radio_button_checked,
                            size: 12,
                            color: shouldHighlight
                                ? colorScheme.onTertiary
                                : colorScheme.onPrimary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${opt.optKey}. ${opt.optVal}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: shouldHighlight
                            ? colorScheme.onTertiaryContainer
                            : colorScheme.onSurface,
                        fontWeight: shouldHighlight ? FontWeight.w600 : FontWeight.w400,
                      ),
                      softWrap: true,
                    ),
                  ),
                  if (shouldHighlight)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '答對',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onTertiary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else if (isCorrect && !isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '正確答案',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        );
      }
      return const SizedBox.shrink();

    case 3: // 多選
      if (sub.optionList != null && sub.optionList!.isNotEmpty) {
        final myAnswers = sub.myAnswer?.split('_') ?? <String>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sub.optionList!.map<Widget>((opt) {
            final key = opt.optKey;
            final isSelected = myAnswers.contains(key);
            final isCorrect = opt.correct;
            final shouldHighlight = isSelected && isCorrect;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: shouldHighlight
                    ? colorScheme.tertiaryContainer.withValues(alpha: 0.6)
                    : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: shouldHighlight
                      ? colorScheme.tertiary.withValues(alpha: 0.5)
                      : (isSelected ? colorScheme.primary.withValues(alpha: 0.5) : colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: shouldHighlight
                          ? colorScheme.tertiary
                          : (isSelected ? colorScheme.primary : Colors.transparent),
                      border: Border.all(
                        color: shouldHighlight
                            ? colorScheme.tertiary
                            : (isSelected ? colorScheme.primary : colorScheme.outlineVariant),
                        width: 2,
                      ),
                    ),
                    child: (shouldHighlight || isSelected)
                        ? Icon(
                            shouldHighlight ? Icons.check : Icons.check_box,
                            size: 12,
                            color: shouldHighlight
                                ? colorScheme.onTertiary
                                : colorScheme.onPrimary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$key. ${opt.optVal}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: shouldHighlight
                            ? colorScheme.onTertiaryContainer
                            : colorScheme.onSurface,
                        fontWeight: shouldHighlight ? FontWeight.w600 : FontWeight.w400,
                      ),
                      softWrap: true,
                    ),
                  ),
                  if (shouldHighlight)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '答對',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onTertiary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else if (isCorrect && !isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '正確答案',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '我的填空：${sub.myAnswer?.isEmpty == true ? '未作答' : sub.myAnswer}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (sub.stdAnswer?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    '標準答案：${sub.stdAnswer}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );

    default:
      return const SizedBox.shrink();
  }
}

/// 資訊列 (圖示 + 文字)
Widget _buildInfoRow({
  required BuildContext context,
  required IconData icon,
  required Color iconColor,
  required String text,
  required TextStyle? style,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 16, color: iconColor),
      const SizedBox(width: 8),
      Expanded(
        child: Text(text, style: style, softWrap: true),
      ),
    ],
  );
}