// IRS 答題系統模型
// 對應 KMU IRS 系統 API

import 'package:freezed_annotation/freezed_annotation.dart';

part 'irs_models.freezed.dart';
part 'irs_models.g.dart';

/// IRS 問卷/答題活動
@freezed
abstract class IrsQuestionnaire with _$IrsQuestionnaire {
  const factory IrsQuestionnaire({
    required String id,
    required String title,
    required String description,
    required String startTime,
    required String endTime,
    required bool isActive,
    required int questionCount,
    String? category,
    String? targetAudience,
    @Default(false) bool isSubmitted,
  }) = _IrsQuestionnaire;

  factory IrsQuestionnaire.fromJson(Map<String, dynamic> json) =>
      _$IrsQuestionnaireFromJson(json);
}

/// IRS 題目
@freezed
abstract class IrsQuestion with _$IrsQuestion {
  const factory IrsQuestion({
    required String id,
    required String questionnaireId,
    required int sequence,
    required String content,
    required IrsQuestionType type,
    required List<IrsOption> options,
    required bool isRequired,
    String? description,
    int? maxSelections,
  }) = _IrsQuestion;

  factory IrsQuestion.fromJson(Map<String, dynamic> json) =>
      _$IrsQuestionFromJson(json);
}

/// IRS 題目類型
enum IrsQuestionType {
  @JsonValue('single')
  singleChoice,
  @JsonValue('multiple')
  multipleChoice,
  @JsonValue('text')
  textInput,
  @JsonValue('scale')
  scale,
}

/// IRS 選項
@freezed
abstract class IrsOption with _$IrsOption {
  const factory IrsOption({
    required String id,
    required String content,
    int? score,
  }) = _IrsOption;

  factory IrsOption.fromJson(Map<String, dynamic> json) =>
      _$IrsOptionFromJson(json);
}

/// IRS 答題提交請求
@freezed
abstract class IrsSubmissionRequest with _$IrsSubmissionRequest {
  const factory IrsSubmissionRequest({
    required String questionnaireId,
    required List<IrsAnswer> answers,
    String? userId,
  }) = _IrsSubmissionRequest;

  factory IrsSubmissionRequest.fromJson(Map<String, dynamic> json) =>
      _$IrsSubmissionRequestFromJson(json);
}

/// IRS 答案
@freezed
abstract class IrsAnswer with _$IrsAnswer {
  const factory IrsAnswer({
    required String questionId,
    required List<String> optionIds,
    String? textAnswer,
  }) = _IrsAnswer;

  factory IrsAnswer.fromJson(Map<String, dynamic> json) =>
      _$IrsAnswerFromJson(json);
}

/// IRS 提交回應
@freezed
abstract class IrsSubmissionResponse with _$IrsSubmissionResponse {
  const factory IrsSubmissionResponse({
    required bool success,
    required String message,
    String? submissionId,
    @Default(0) int score,
  }) = _IrsSubmissionResponse;

  factory IrsSubmissionResponse.fromJson(Map<String, dynamic> json) =>
      _$IrsSubmissionResponseFromJson(json);
}

/// IRS 問卷詳情 (包含題目)
@freezed
abstract class IrsQuestionnaireDetail with _$IrsQuestionnaireDetail {
  const factory IrsQuestionnaireDetail({
    required IrsQuestionnaire questionnaire,
    required List<IrsQuestion> questions,
  }) = _IrsQuestionnaireDetail;

  factory IrsQuestionnaireDetail.fromJson(Map<String, dynamic> json) =>
      _$IrsQuestionnaireDetailFromJson(json);
}

/// IRS 狀態
@freezed
abstract class IrsState with _$IrsState {
  const factory IrsState({
    @Default([]) List<IrsQuestionnaire> questionnaires,
    IrsQuestionnaireDetail? currentQuestionnaire,
    @Default(false) bool isLoading,
    @Default(false) bool isSubmitting,
    String? error,
    @Default(0) int currentQuestionIndex,
    @Default({}) Map<String, List<String>> userAnswers, // questionId -> optionIds
    @Default({}) Map<String, String> userTextAnswers, // questionId -> text
    // 學生歷史記錄
    @Default([]) List<IrsStudentClass> studentClasses,
    @Default([]) List<IrsAnswerRecord> answerRecords,
    @Default([]) List<IrsAnswerRecord> askRecords,
    IrsExamDetail? examDetail,
    @Default(false) bool isLoadingHistory,
    String? historyError,
  }) = _IrsState;

  factory IrsState.initial() => const IrsState();
}

/// ===========================================
// 學生歷史記錄模型
// ===========================================

/// 學生課程
@freezed
abstract class IrsStudentClass with _$IrsStudentClass {
  const factory IrsStudentClass({
    required String id, // cono
    required String name, // course name
    String? englishName,
  }) = _IrsStudentClass;

  factory IrsStudentClass.fromJson(Map<String, dynamic> json) =>
      _$IrsStudentClassFromJson(json);
}

/// 學生作答/提問記錄
@freezed
abstract class IrsAnswerRecord with _$IrsAnswerRecord {
  const factory IrsAnswerRecord({
    required String id, // quid
    required String courseId, // cono
    required String courseName,
    required String title, // 題目描述
    required String answerTime,
    required int myScore,
    required int totalScore,
    String? imagePath,
    String? stdAnswer,
    String? myAnswer,
  }) = _IrsAnswerRecord;

  factory IrsAnswerRecord.fromJson(Map<String, dynamic> json) =>
      _$IrsAnswerRecordFromJson(json);
}

/// 考試詳情
@freezed
abstract class IrsExamDetail with _$IrsExamDetail {
  const factory IrsExamDetail({
    required String answerTime,
    required String teacherName,
    required String question,
    required int myScore,
    required int totalScore,
    required List<IrsSubQuestion> subQuestions,
  }) = _IrsExamDetail;

  factory IrsExamDetail.fromJson(Map<String, dynamic> json) =>
      _$IrsExamDetailFromJson(json);
}

/// 子題目詳情
@freezed
abstract class IrsSubQuestion with _$IrsSubQuestion {
  const factory IrsSubQuestion({
    required String questionType, // 1=單選, 2=多選, 3=文字, 4=...
    required String description,
    required String scoreDesc,
    required String myAnswer,
    String? stdAnswer,
    List<IrsSubOption>? options,
    String? imagePath,
  }) = _IrsSubQuestion;

  factory IrsSubQuestion.fromJson(Map<String, dynamic> json) =>
      _$IrsSubQuestionFromJson(json);
}

/// 子題目選項
@freezed
abstract class IrsSubOption with _$IrsSubOption {
  const factory IrsSubOption({
    required String key,
    required String value,
    @Default(false) bool isCorrect,
  }) = _IrsSubOption;

  factory IrsSubOption.fromJson(Map<String, dynamic> json) =>
      _$IrsSubOptionFromJson(json);
}