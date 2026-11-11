// IRS 問卷答題頁面 (詳情頁)

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core.dart';
import '../providers/irs_providers.dart';
import '../models/models.dart';

class IrsDetailPage extends ConsumerWidget {
  const IrsDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(irsProvider);
    final notifier = ref.read(irsProvider.notifier);

    final detail = state.currentQuestionnaire;
    if (detail == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('IRS 答題')),
        body: const Center(child: Text('問卷不存在')),
      );
    }

    final question = notifier.currentQuestion;
    final isLastQuestion = state.currentQuestionIndex == detail.questions.length - 1;
    final progress = (state.currentQuestionIndex + 1) / detail.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(detail.questionnaire.title),
        actions: [
          if (!detail.questionnaire.isSubmitted)
            TextButton.icon(
              onPressed: notifier.areAllRequiredAnswered() ? () => _submit(context, notifier) : null,
              icon: const Icon(Icons.send),
              label: const Text('提交'),
            ),
        ],
      ),
      body: Column(
        children: [
          // 進度條
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            color: Theme.of(context).colorScheme.primary,
            minHeight: 4,
          ),
          
          // 題號指示器
          _QuestionIndicator(
            totalQuestions: detail.questions.length,
            currentIndex: state.currentQuestionIndex,
            answeredMap: _buildAnsweredMap(detail, state),
            onTap: notifier.goToQuestion,
          ),

          // 題目內容
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : question != null
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: _QuestionContent(
                          question: question,
                          index: state.currentQuestionIndex,
                          total: detail.questions.length,
                          notifier: notifier,
                          state: state,
                        ),
                      )
                    : const Center(child: Text('無題目')),
          ),

          // 底部導航
          if (!detail.questionnaire.isSubmitted)
            _BottomNavigation(
              currentIndex: state.currentQuestionIndex,
              totalQuestions: detail.questions.length,
              isLastQuestion: isLastQuestion,
              canGoNext: notifier.isCurrentQuestionAnswered() || !question!.isRequired,
              onPrevious: notifier.previousQuestion,
              onNext: notifier.nextQuestion,
              onSubmit: isLastQuestion && notifier.areAllRequiredAnswered() 
                  ? () => _submit(context, notifier) 
                  : null,
            ),
        ],
      ),
    );
  }

  Map<int, bool> _buildAnsweredMap(IrsQuestionnaireDetail detail, IrsState state) {
    final map = <int, bool>{};
    for (int i = 0; i < detail.questions.length; i++) {
      final q = detail.questions[i];
      final answer = state.userAnswers[q.id];
      final textAnswer = state.userTextAnswers[q.id];
      
      bool answered = false;
      switch (q.type) {
        case IrsQuestionType.textInput:
          answered = textAnswer != null && textAnswer.isNotEmpty;
          break;
        case IrsQuestionType.singleChoice:
        case IrsQuestionType.multipleChoice:
        case IrsQuestionType.scale:
          answered = answer != null && answer.isNotEmpty;
          break;
      }
      map[i] = answered;
    }
    return map;
  }

  Future<void> _submit(BuildContext context, IrsNotifier notifier) async {
    final success = await notifier.submit();
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('提交成功！')),
        );
        Navigator.of(context).pop(); // 返回列表頁
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(notifier.error ?? '提交失敗')),
        );
      }
    }
  }
}

/// 題目內容組件
class _QuestionContent extends ConsumerWidget {
  const _QuestionContent({
    required this.question,
    required this.index,
    required this.total,
    required this.notifier,
    required this.state,
  });

  final IrsQuestion question;
  final int index;
  final int total;
  final IrsNotifier notifier;
  final IrsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentAnswer = notifier.getCurrentAnswer(question.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 題號與必填標記
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                question.content,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (question.isRequired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '必填',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),

        if (question.description != null && question.description!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            question.description!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],

        const SizedBox(height: 24),

        // 根據題型渲染不同輸入介面
        (switch (question.type) {
          IrsQuestionType.singleChoice => _SingleChoiceOptions(
              question: question,
              selectedOptionId: currentAnswer.isNotEmpty ? currentAnswer.first : null,
              onSelected: (optionId) {
                notifier.updateAnswer(question.id, [optionId]);
              },
            ),
          IrsQuestionType.multipleChoice => _MultipleChoiceOptions(
              question: question,
              selectedOptionIds: currentAnswer,
              onChanged: (optionIds) {
                notifier.updateAnswer(question.id, optionIds);
              },
            ),
          IrsQuestionType.textInput => _TextInput(
              question: question,
              onChanged: (text) {
                notifier.updateTextAnswer(question.id, text);
              },
            ),
          IrsQuestionType.scale => _ScaleInput(
              question: question,
              selectedValue: currentAnswer.isNotEmpty ? int.tryParse(currentAnswer.first) : null,
              onChanged: (value) {
                notifier.updateAnswer(question.id, [value.toString()]);
              },
            ),
        })
      ],
    );
  }
}

/// 單選選項
class _SingleChoiceOptions extends StatelessWidget {
  const _SingleChoiceOptions({
    required this.question,
    required this.selectedOptionId,
    required this.onSelected,
  });

  final IrsQuestion question;
  final String? selectedOptionId;
  final void Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = selectedOptionId == option.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelected(option.id),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.outlineVariant,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected 
                      ? theme.colorScheme.primaryContainer 
                      : theme.colorScheme.surface,
                ),
                child: Row(
                  children: [
                    // 選項字母
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.outlineVariant,
                          width: 2,
                        ),
                        color: isSelected 
                            ? theme.colorScheme.primary 
                            : Colors.transparent,
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + index), // A, B, C, D...
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isSelected 
                                ? theme.colorScheme.onPrimary 
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        option.content,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isSelected 
                              ? theme.colorScheme.onPrimaryContainer 
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// 多選選項
class _MultipleChoiceOptions extends StatelessWidget {
  const _MultipleChoiceOptions({
    required this.question,
    required this.selectedOptionIds,
    required this.onChanged,
  });

  final IrsQuestion question;
  final List<String> selectedOptionIds;
  final void Function(List<String>) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: question.options.asMap().entries.map((entry) {
        final option = entry.value;
        final isSelected = selectedOptionIds.contains(option.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                final newSelection = List<String>.from(selectedOptionIds);
                if (isSelected) {
                  newSelection.remove(option.id);
                } else {
                  // 檢查最大選擇數限制
                  if (question.maxSelections != null && newSelection.length >= question.maxSelections!) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('最多可選 ${question.maxSelections} 項')),
                    );
                    return;
                  }
                  newSelection.add(option.id);
                }
                onChanged(newSelection);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.outlineVariant,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected 
                      ? theme.colorScheme.primaryContainer 
                      : theme.colorScheme.surface,
                ),
                child: Row(
                  children: [
                    // 核取方塊
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.outlineVariant,
                          width: 2,
                        ),
                        color: isSelected 
                            ? theme.colorScheme.primary 
                            : Colors.transparent,
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 16,
                              color: theme.colorScheme.onPrimary,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        option.content,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isSelected 
                              ? theme.colorScheme.onPrimaryContainer 
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// 文字輸入
class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.question,
    required this.onChanged,
  });

  final IrsQuestion question;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      maxLines: question.maxSelections ?? 5, // 復用 maxSelections 當作行數限制
      minLines: 3,
      decoration: InputDecoration(
        hintText: '請輸入您的回答...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      ),
      onChanged: onChanged,
    );
  }
}

/// 量表輸入 (1-5 或 1-10)
class _ScaleInput extends StatelessWidget {
  const _ScaleInput({
    required this.question,
    required this.selectedValue,
    required this.onChanged,
  });

  final IrsQuestion question;
  final int? selectedValue;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // 預設 1-5 分，若選項有分數則用選項數量
    final maxValue = question.options.isNotEmpty 
        ? question.options.length 
        : 5;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(maxValue, (index) {
            final value = index + 1;
            final isSelected = selectedValue == value;
            
            return Expanded(
              child: InkWell(
                onTap: () => onChanged(value),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? theme.colorScheme.primary 
                          : theme.colorScheme.outlineVariant,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$value',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isSelected 
                            ? theme.colorScheme.onPrimary 
                            : theme.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        
        // 標籤說明
        if (question.options.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: question.options.asMap().entries.map((entry) {
              final option = entry.value;
              return Expanded(
                child: Text(
                  option.content,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

/// 題號指示器
class _QuestionIndicator extends StatelessWidget {
  const _QuestionIndicator({
    required this.totalQuestions,
    required this.currentIndex,
    required this.answeredMap,
    required this.onTap,
  });

  final int totalQuestions;
  final int currentIndex;
  final Map<int, bool> answeredMap;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '進度：${currentIndex + 1} / $totalQuestions',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(totalQuestions, (index) {
                final isCurrent = index == currentIndex;
                final isAnswered = answeredMap[index] ?? false;

                return GestureDetector(
                  onTap: () => onTap(index),
                  child: Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCurrent
                          ? theme.colorScheme.primary
                          : isAnswered
                              ? theme.colorScheme.secondaryContainer
                              : theme.colorScheme.surfaceContainerHighest,
                      border: Border.all(
                        color: isCurrent
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isAnswered && !isCurrent
                          ? Icon(
                              Icons.check,
                              size: 18,
                              color: theme.colorScheme.onSecondaryContainer,
                            )
                          : Text(
                              '${index + 1}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: isCurrent
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                              ),
                            ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// 底部導航
class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.currentIndex,
    required this.totalQuestions,
    required this.isLastQuestion,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
  });

  final int currentIndex;
  final int totalQuestions;
  final bool isLastQuestion;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          // 上一題
          if (currentIndex > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPrevious,
                icon: const Icon(Icons.chevron_left),
                label: const Text('上一題'),
              ),
            )
          else
            const Expanded(child: SizedBox()),

          const SizedBox(width: 12),

          // 下一題 / 提交
          Expanded(
            flex: 2,
            child: isLastQuestion
                ? FilledButton.icon(
                    onPressed: onSubmit,
                    icon: const Icon(Icons.send),
                    label: const Text('提交答卷'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  )
                : FilledButton.icon(
                    onPressed: canGoNext ? onNext : null,
                    icon: const Icon(Icons.chevron_right),
                    label: const Text('下一題'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}