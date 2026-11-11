// IRS Notifier
// 管理 IRS 答題系統狀態

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core.dart';

class IrsNotifier extends AutoDisposeNotifier<IrsState> {
  late final Endpoints _endpoints;

  @override
  IrsState build() {
    _endpoints = ref.read(endpointsProvider);
    
    // 延遲載入問卷列表
    Future.microtask(() => loadQuestionnaires());
    
    return const IrsState();
  }

  /// 載入問卷列表
  Future<void> loadQuestionnaires() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final questionnaires = await _endpoints.irs.getQuestionnaires();
      state = state.copyWith(
        questionnaires: questionnaires,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '載入問卷失敗: $e',
      );
    }
  }

  /// 載入問卷詳情 (包含題目)
  Future<void> loadQuestionnaireDetail(String questionnaireId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final detail = await _endpoints.irs.getQuestionnaireDetail(questionnaireId);
      if (detail != null) {
        state = state.copyWith(
          currentQuestionnaire: detail,
          currentQuestionIndex: 0,
          userAnswers: {},
          userTextAnswers: {},
          isLoading: false,
        );
      } else {
        throw Exception('問卷不存在');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '載入問卷詳情失敗: $e',
      );
    }
  }

  /// 更新單選/多選答案
  void updateAnswer(String questionId, List<String> optionIds) {
    final answers = Map<String, List<String>>.from(state.userAnswers);
    answers[questionId] = optionIds;
    state = state.copyWith(userAnswers: answers);
  }

  /// 更新文字答案
  void updateTextAnswer(String questionId, String text) {
    final answers = Map<String, String>.from(state.userTextAnswers);
    answers[questionId] = text;
    state = state.copyWith(userTextAnswers: answers);
  }

  /// 移動到下一題
  void nextQuestion() {
    final detail = state.currentQuestionnaire;
    if (detail == null) return;

    final nextIndex = state.currentQuestionIndex + 1;
    if (nextIndex < detail.questions.length) {
      state = state.copyWith(currentQuestionIndex: nextIndex);
    }
  }

  /// 移動到上一題
  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1);
    }
  }

  /// 跳轉到指定題目
  void goToQuestion(int index) {
    final detail = state.currentQuestionnaire;
    if (detail != null && index >= 0 && index < detail.questions.length) {
      state = state.copyWith(currentQuestionIndex: index);
    }
  }

  /// 取得當前題目
  IrsQuestion? get currentQuestion {
    final detail = state.currentQuestionnaire;
    if (detail == null) return null;
    if (state.currentQuestionIndex >= detail.questions.length) return null;
    return detail.questions[state.currentQuestionIndex];
  }

  /// 取得當前題目的已選答案
  List<String> getCurrentAnswer(String questionId) {
    return state.userAnswers[questionId] ?? const [];
  }

  /// 目前錯誤訊息（供頁面顯示使用）
  String? get error => state.error;

  /// 取得當前題目的文字答案
  String? getCurrentTextAnswer(String questionId) {
    return state.userTextAnswers[questionId];
  }

  /// 檢查當前題目是否已回答
  bool isCurrentQuestionAnswered() {
    final question = currentQuestion;
    if (question == null) return false;

    final answer = state.userAnswers[question.id];
    final textAnswer = state.userTextAnswers[question.id];

    switch (question.type) {
      case IrsQuestionType.textInput:
        return textAnswer != null && textAnswer.isNotEmpty;
      case IrsQuestionType.singleChoice:
        return answer != null && answer.isNotEmpty;
      case IrsQuestionType.multipleChoice:
        return answer != null && answer.isNotEmpty;
      case IrsQuestionType.scale:
        return answer != null && answer.isNotEmpty;
    }
  }

  /// 檢查所有必填題目是否都已回答
  bool areAllRequiredAnswered() {
    final detail = state.currentQuestionnaire;
    if (detail == null) return false;

    for (final question in detail.questions) {
      if (question.isRequired) {
        final answer = state.userAnswers[question.id];
        final textAnswer = state.userTextAnswers[question.id];

        bool answered = false;
        switch (question.type) {
          case IrsQuestionType.textInput:
            answered = textAnswer != null && textAnswer.isNotEmpty;
            break;
          case IrsQuestionType.singleChoice:
          case IrsQuestionType.multipleChoice:
          case IrsQuestionType.scale:
            answered = answer != null && answer.isNotEmpty;
            break;
        }

        if (!answered) return false;
      }
    }
    return true;
  }

  /// 提交答題
  Future<bool> submit() async {
    final detail = state.currentQuestionnaire;
    if (detail == null) return false;

    final authState = ref.read(authControllerProvider);
    final userId = authState.userId;

    // 建立答案列表
    final answers = <IrsAnswer>[];
    for (final question in detail.questions) {
      final optionIds = state.userAnswers[question.id] ?? const [];
      final textAnswer = state.userTextAnswers[question.id];
      
      // 即使未回答也要送出（後端驗證必填）
      answers.add(IrsAnswer(
        questionId: question.id,
        optionIds: optionIds,
        textAnswer: textAnswer,
      ));
    }

    final request = IrsSubmissionRequest(
      questionnaireId: detail.questionnaire.id,
      answers: answers,
      userId: userId,
    );

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final response = await _endpoints.irs.submitAnswers(request);
      
      if (response.success) {
        // 更新問卷列表中的提交狀態
        final updatedQuestionnaires = state.questionnaires.map((q) {
          if (q.id == detail.questionnaire.id) {
            return q.copyWith(isSubmitted: true);
          }
          return q;
        }).toList();

        state = state.copyWith(
          isSubmitting: false,
          questionnaires: updatedQuestionnaires,
          error: null,
        );
        return true;
      } else {
        state = state.copyWith(
          isSubmitting: false,
          error: response.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: '提交失敗: $e',
      );
      return false;
    }
  }

  /// 重置當前問卷狀態
  void resetCurrentQuestionnaire() {
    state = state.copyWith(
      currentQuestionnaire: null,
      currentQuestionIndex: 0,
      userAnswers: {},
      userTextAnswers: {},
      error: null,
    );
  }

  /// 刷新問卷列表
  Future<void> refresh() async {
    await loadQuestionnaires();
  }
}

final irsProvider = AutoDisposeNotifierProvider<IrsNotifier, IrsState>(() {
  return IrsNotifier();
});