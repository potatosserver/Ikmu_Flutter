// IRS Notifier
// 管理 IRS 答題系統狀態

import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core.dart';
import '../utils/irs_debug_log.dart';

class IrsNotifier extends Notifier<IrsState> {
  late final Endpoints _endpoints;

  @override
  IrsState build() {
    _endpoints = ref.read(endpointsProvider);

    final authState = ref.read(authControllerProvider);
    final uid = authState.userId;
    if (uid != null && uid.isNotEmpty) {
      _endpoints.irs.userId = uid;
    }

    unawaited(Future<void>.microtask(loadQuestionnaires));

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
    state = state.copyWith(
      isLoading: true,
      error: null,
      examDetail: null,
    );

    try {
      final detail = await _endpoints.irs.getQuestionnaireDetail(questionnaireId);
      if (detail != null) {
        state = state.copyWith(
          currentQuestionnaire: detail,
          examDetail: null,
          currentQuestionIndex: 0,
          userAnswers: const <String, List<String>>{},
          userTextAnswers: const <String, String>{},
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
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
      );
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
    return state.userAnswers[questionId] ?? const <String>[];
  }

  /// 目前錯誤訊息（供頁面顯示使用）
  String? get error => state.error;
  String? get historyError => state.historyError;

  /// 設定當前使用者 ID (供學生端 API 使用)
  set userId(String value) {
    _endpoints.irs.userId = value;
  }

  /// 載入學生課程列表
  Future<void> loadStudentClasses() async {
    IrsDebugLog.log('[IRS_PROVIDER] loadStudentClasses 開始');
    state = state.copyWith(isLoadingHistory: true, historyError: null);

    try {
      final authState = ref.read(authControllerProvider);
      final userId = authState.userId;
      IrsDebugLog.log('[IRS_PROVIDER] userId=$userId');
      if (userId == null || userId.isEmpty) {
        throw Exception('使用者 ID 為空，請先登入');
      }

      _endpoints.irs.userId = userId;
      final classes = await _endpoints.irs.getStudentClasses(userId: userId);
      IrsDebugLog.log('[IRS_PROVIDER] 載入課程完成: ${classes.length} 筆');
      for (final c in classes) {
        IrsDebugLog.log('[IRS_PROVIDER]   課程: id=${c.id}, name=${c.displayName}');
      }
      state = state.copyWith(
        studentClasses: classes,
        isLoadingHistory: false,
      );
    } catch (e) {
      IrsDebugLog.log('[IRS_PROVIDER] 載入課程失敗: $e');
      state = state.copyWith(
        isLoadingHistory: false,
        historyError: '載入課程失敗: $e',
      );
    }
  }

  /// 載入課程下的老師列表 (IRS 即時答題使用)
  /// 優先從已載入課程的 teacherList 取得，若為空則呼叫 irs/stu/teacher_class (classid)
  Future<void> loadTeacherClasses(String classId) async {
    IrsDebugLog.log('[IRS_PROVIDER] loadTeacherClasses: classId=$classId');

    IrsStudentClass? selectedClass;
    for (final c in state.studentClasses) {
      if (c.id == classId) {
        selectedClass = c;
        break;
      }
    }

    if (selectedClass != null && selectedClass.teacherList.isNotEmpty) {
      final teachers = selectedClass.teacherList;
      IrsDebugLog.log(
        '[IRS_PROVIDER] 從課程 teacherList 載入: ${teachers.length} 筆',
      );
      state = state.copyWith(availableTeachers: teachers);
      return;
    }

    try {
      final teachers =
          await _endpoints.irs.getTeacherClasses(classId: classId);
      IrsDebugLog.log(
        '[IRS_PROVIDER] 從 API teacher_class 載入: ${teachers.length} 筆',
      );
      state = state.copyWith(availableTeachers: teachers);
    } catch (e) {
      IrsDebugLog.log('[IRS_PROVIDER] 載入老師列表失敗: $e');
      state = state.copyWith(availableTeachers: const <IrsRealtimeTeacher>[]);
    }
  }

  /// 載入學生作答記錄
  Future<void> loadAnswerRecords(String courseId) async {
    IrsDebugLog.log('[IRS_PROVIDER] loadAnswerRecords: courseId=$courseId');
    state = state.copyWith(isLoadingHistory: true, historyError: null);

    try {
      final authState = ref.read(authControllerProvider);
      final uid = authState.userId;
      if (uid != null && uid.isNotEmpty) {
        _endpoints.irs.userId = uid;
      }

      final records = await _endpoints.irs.getAnswerRecords(courseId);
      IrsDebugLog.log('[IRS_PROVIDER] 載入作答記錄完成: ${records.length} 筆');
      state = state.copyWith(
        answerRecords: records,
        isLoadingHistory: false,
      );
    } catch (e) {
      IrsDebugLog.log('[IRS_PROVIDER] 載入作答記錄失敗: $e');
      state = state.copyWith(
        isLoadingHistory: false,
        historyError: '載入作答記錄失敗: $e',
      );
    }
  }

  /// 載入學生提問記錄
  Future<void> loadAskRecords(String courseId) async {
    IrsDebugLog.log('[IRS_PROVIDER] loadAskRecords: courseId=$courseId');
    state = state.copyWith(isLoadingHistory: true, historyError: null);

    try {
      final authState = ref.read(authControllerProvider);
      final uid = authState.userId;
      if (uid != null && uid.isNotEmpty) {
        _endpoints.irs.userId = uid;
      }

      final records = await _endpoints.irs.getAskRecords(courseId);
      IrsDebugLog.log('[IRS_PROVIDER] 載入提問記錄完成: ${records.length} 筆');
      state = state.copyWith(
        askRecords: records,
        isLoadingHistory: false,
      );
    } catch (e) {
      IrsDebugLog.log('[IRS_PROVIDER] 載入提問記錄失敗: $e');
      state = state.copyWith(
        isLoadingHistory: false,
        historyError: '載入提問記錄失敗: $e',
      );
    }
  }

  /// 載入考試詳情 (對齊 IRSRecordActivity.GetExamData + show99View)
  /// - questionType == "99" (試卷): 呼叫 irs/stu/examDetail (stuno, quid) 解析 items 物件與 subquList
  /// - 單題作答記錄 ("1"/"2"/"3"/"4"): 直接由該筆 qaList 欄位建構 IrsExamDetail
  Future<void> loadExamDetail(IrsAnswerRecord record) async {
    state = state.copyWith(
      isLoadingHistory: true,
      historyError: null,
      currentQuestionnaire: null,
      examDetail: null,
    );

    try {
      final authState = ref.read(authControllerProvider);
      final userId = authState.userId ?? '';

      if (record.isExamPaper &&
          (record.questionId ?? '').isNotEmpty &&
          userId.isNotEmpty) {
        final detail = await _endpoints.irs.getExamDetail(
          userId: userId,
          quid: record.questionId!,
        );
        if (detail != null) {
          state = state.copyWith(
            examDetail: detail,
            isLoadingHistory: false,
          );
          return;
        }
      }

      // 單題記錄或 examDetail 無子題時的備援建構
      final fallbackDetail = IrsExamDetail(
        description: record.description ?? record.askDesc ?? '',
        teacherno: record.teafNam ?? '',
        teafNam: record.teafNam ?? '',
        teafEnam: record.teafEnam,
        ansTime: record.ansTime ?? record.askTime ?? '',
        totalScore: record.totalScore,
        myScore: record.myScore,
        hideAns: record.hideAns ?? false,
        subquList: <IrsSubQuestion>[
          IrsSubQuestion(
            questionId: record.questionId,
            questionType: int.tryParse(record.questionType?.toString() ?? '2') ?? 2,
            description: record.description ?? record.askDesc ?? '',
            optionList: record.optionList,
            stdAnswer: record.stdAnswer,
            myAnswer: record.myAnswer,
            score: 0,
            correct: record.correct ?? false,
            hideAns: record.hideAns ?? false,
            scoreDesc: record.scoreDesc ?? '${record.myScore}/${record.totalScore}',
            imgPath: record.imgPath,
          ),
        ],
      );

      state = state.copyWith(
        examDetail: fallbackDetail,
        isLoadingHistory: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingHistory: false,
        historyError: '載入考試詳情失敗: $e',
      );
    }
  }

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
      case IrsQuestionType.multipleChoice:
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
            answered = (textAnswer ?? '').isNotEmpty;
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

  /// 提交靜態問卷答題
  Future<bool> submit() async {
    final detail = state.currentQuestionnaire;
    if (detail == null) return false;

    final authState = ref.read(authControllerProvider);
    final userId = authState.userId;

    final answers = <IrsAnswer>[];
    for (final question in detail.questions) {
      final optionIds = state.userAnswers[question.id] ?? const <String>[];
      final textAnswer = state.userTextAnswers[question.id];

      answers.add(
        IrsAnswer(
          questionId: question.id,
          optionIds: optionIds,
          textAnswer: textAnswer,
        ),
      );
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
      examDetail: null,
      currentQuestionIndex: 0,
      userAnswers: const <String, List<String>>{},
      userTextAnswers: const <String, String>{},
      error: null,
    );
  }

  /// IRS 即時答題：送出多題連答/填空答案 (irs/stu/paperFill)
  Future<bool> submitPaperFill({
    required String classId,
    required String studentId,
    required String teacherNo,
    required String secno,
    required String username,
    required Object answers,
  }) async {
    state = state.copyWith(isSubmitting: true, historyError: null);

    try {
      final response = await _endpoints.irs.submitPaperFill(
        classId: classId,
        studentId: studentId,
        teacherNo: teacherNo,
        secno: secno,
        username: username,
        answers: answers,
      );

      if (response != null && response['success'] == true) {
        state = state.copyWith(isSubmitting: false);
        return true;
      } else {
        state = state.copyWith(
          isSubmitting: false,
          historyError: '送出失敗：${response?['message'] ?? '未知錯誤'}',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        historyError: '送出錯誤：$e',
      );
      return false;
    }
  }

  /// IRS 學生登入 (irs/stu/applogin)
  Future<Map<String, dynamic>?> irsStuApplogin({
    required String classId,
    required String studentId,
    required String teacherNo,
    required String bt,
  }) async {
    final authState = ref.read(authControllerProvider);
    final userId = authState.userId;
    final stuno =
        studentId.isNotEmpty ? studentId : (userId ?? '');
    if (stuno.isEmpty) {
      throw Exception('使用者 ID 為空，請先登入');
    }

    return _endpoints.irs.irsStuApplogin(
      classId: classId,
      studentId: stuno,
      teacherNo: teacherNo,
      bt: bt,
    );
  }

  /// IRS 取得當前狀態 (irs/stu/current)
  Future<Map<String, dynamic>?> getIRSCurrentData({
    required String classId,
    required String studentId,
    required String teacherNo,
  }) async {
    final authState = ref.read(authControllerProvider);
    final userId = authState.userId;
    final stuno =
        studentId.isNotEmpty ? studentId : (userId ?? '');
    if (stuno.isEmpty) {
      throw Exception('使用者 ID 為空，請先登入');
    }

    return _endpoints.irs.getIRSCurrentData(
      classId: classId,
      studentId: stuno,
      teacherNo: teacherNo,
    );
  }

  /// IRS 即時答題：取得當前題目 (irs/stu/current_qu)
  Future<Map<String, dynamic>?> getCurrentQuestion({
    required String classId,
    required String studentId,
    required String teacherNo,
  }) async {
    final authState = ref.read(authControllerProvider);
    final userId = authState.userId;
    final stuno =
        studentId.isNotEmpty ? studentId : (userId ?? '');
    if (stuno.isEmpty) {
      throw Exception('使用者 ID 為空，請先登入');
    }

    return _endpoints.irs.getCurrentQuestion(
      classId: classId,
      studentId: stuno,
      teacherNo: teacherNo,
    );
  }

  /// IRS 即時答題：透過後端 HTTP POST 轉發 MQTT 訊息
  Future<bool> sendMqttMessage({
    required String topic,
    required String msg,
    required String quid,
  }) async {
    return _endpoints.irs.sendMqttMessage(
      topic: topic,
      msg: msg,
      quid: quid,
    );
  }

  /// IRS 異常/逾時/離開回報
  Future<bool> sendAbnormal({
    required String quid,
    required String status,
    required String studentId,
  }) async {
    return _endpoints.irs.sendAbnormal(
      quid: quid,
      status: status,
      studentId: studentId,
    );
  }

  /// 刷新問卷列表
  Future<void> refresh() async {
    await loadQuestionnaires();
  }

  /// 切換歷史記錄 tab (0=作答記錄, 1=提問記錄)
  void setHistoryTab(int tab) {
    state = state.copyWith(historyTab: tab);
  }

  /// 設定歷史記錄選中的課程
  void setSelectedCourseId(String? courseId) {
    state = state.copyWith(selectedCourseId: courseId);
  }
}

final irsProvider = NotifierProvider<IrsNotifier, IrsState>(() {
  return IrsNotifier();
});