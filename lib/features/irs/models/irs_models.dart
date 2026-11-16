// ignore_for_file: invalid_annotation_target

// IRS 答題系統模型
// 對應 KMU IRS 系統 API 與原生 Android (IRSActivity / IRSRecordActivity)

import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'irs_models.freezed.dart';
part 'irs_models.g.dart';

// ===========================================
// 工具函數：對齊 Java JSONObject.getString() 行為
// 將任何型別 (int, bool, String, null) 安全轉為 String
// ===========================================
String? _asString(Object? value) {
  if (value == null) return null;
  return value.toString().trim();
}

int _asInt(Object? value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim()) ?? fallback;
}

bool _asBool(Object? value, [bool fallback = false]) {
  if (value == null) return fallback;
  if (value is bool) return value;
  final s = value.toString().trim().toLowerCase();
  if (s == 'true' || s == '1') return true;
  if (s == 'false' || s == '0') return false;
  return fallback;
}

List<IrsSubOption>? _parseSubOptionList(Object? raw) {
  if (raw == null) return null;
  Object? decoded = raw;
  if (raw is String) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed == 'null') return null;
    try {
      decoded = jsonDecode(trimmed);
    } catch (_) {
      return null;
    }
  }
  if (decoded is List) {
    return decoded
        .whereType<Map>()
        .map((e) => IrsSubOption.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  return null;
}

/// 自訂 JSON key 解析器：將任意值安全轉 String (nullable)
String? _parseStringKey(Object? value) => _asString(value);

/// 自訂 JSON key 解析器：將任意值安全轉 String (非 nullable，空字串作為預設)
String _parseStringKeyOrEmpty(Object? value) => _asString(value) ?? '';

/// 自訂 JSON key 解析器：將任意值安全轉 int
int _parseIntKey(Object? value) => _asInt(value);

/// 自訂 JSON key 解析器：將任意值安全轉 bool
bool? _parseBoolKey(Object? value) => _asBool(value);

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
    @Default({}) Map<String, List<String>> userAnswers,
    @Default({}) Map<String, String> userTextAnswers,
    // 學生歷史記錄
    @Default([]) List<IrsStudentClass> studentClasses,
    @Default([]) List<IrsAnswerRecord> answerRecords,
    @Default([]) List<IrsAnswerRecord> askRecords,
    @Default(0) int historyTab,
    String? selectedCourseId,
    // IRS 即時答題 & 詳情
    @Default([]) List<IrsRealtimeTeacher> availableTeachers,
    IrsExamDetail? examDetail,
    @Default(false) bool isLoadingHistory,
    @Default(false) bool isLoadingExamDetail,
    String? historyError,
  }) = _IrsState;

  factory IrsState.initial() => const IrsState();
}

// ===========================================
// 學生歷史記錄模型 (對齊 IRSRecordActivity.java)
// ===========================================

/// 學生課程 (對齊 irsCurrentClass/{userId} 回傳)
/// 欄位：classId, className, englishco, teafno, teafnam, seqno, teafenam, teacherList, classRoom
@freezed
abstract class IrsStudentClass with _$IrsStudentClass {
  const IrsStudentClass._();

  const factory IrsStudentClass({
    @JsonKey(name: 'classId') required String id,
    @JsonKey(name: 'className') required String name,
    @JsonKey(name: 'englishco') String? englishName,
    @JsonKey(name: 'teafno') String? teacherNo,
    @JsonKey(name: 'teafnam') String? teacherName,
    @JsonKey(name: 'seqno') String? seqno,
    @JsonKey(name: 'classRoom') String? classRoom,
    String? startTime,
    String? endTime,
    @JsonKey(name: 'teacherList') @Default([]) List<IrsRealtimeTeacher> teacherList,
  }) = _IrsStudentClass;

  factory IrsStudentClass.fromJson(Map<String, dynamic> json) =>
      _$IrsStudentClassFromJson(json);

  String get displayName {
    if (name.isNotEmpty) return name;
    if (englishName != null && englishName!.isNotEmpty) return englishName!;
    return id;
  }

  // 相容舊欄位名
  String? get courseId => id;
  String? get courseName => name;
  String? get courseSeqno => seqno;
}

/// 學生作答/提問記錄
/// 對齊 IRSRecordActivity.java parseList 與 IRSRecordListViewAdapter.java
/// 14 欄位：qseq, ques, ans, correct, hideAns, ansUsrId, ansTime, isMulti, score, scoreType, qType, subquList, optionList, imgPath
/// 關鍵：所有欄位在 Java 端均以 getString() 讀取，故這裡用自訂 parser 統一轉型
@freezed
abstract class IrsAnswerRecord with _$IrsAnswerRecord {
  const IrsAnswerRecord._();

  const factory IrsAnswerRecord({
    @JsonKey(name: 'myScore', fromJson: _parseIntKey) @Default(0) int myScore,
    @JsonKey(name: 'totalScore', fromJson: _parseIntKey) @Default(0) int totalScore,
    @JsonKey(name: 'questionId', fromJson: _parseStringKey) String? questionId,
    @JsonKey(name: 'cono', fromJson: _parseStringKey) String? cono,
    @JsonKey(name: 'courseName', fromJson: _parseStringKey) String? courseName,
    @JsonKey(name: 'questionType', fromJson: _parseStringKey) String? questionType,
    @JsonKey(name: 'description', fromJson: _parseStringKey) String? description,
    @JsonKey(name: 'ansTime', fromJson: _parseStringKey) String? ansTime,
    @JsonKey(name: 'teafNam', fromJson: _parseStringKey) String? teafNam,
    @JsonKey(name: 'teafEnam', fromJson: _parseStringKey) String? teafEnam,
    @JsonKey(name: 'imgPath', fromJson: _parseStringKey) String? imgPath,
    @JsonKey(name: 'stdAnswer', fromJson: _parseStringKey) String? stdAnswer,
    @JsonKey(name: 'myAnswer', fromJson: _parseStringKey) String? myAnswer,
    @JsonKey(name: 'correct', fromJson: _parseBoolKey) bool? correct,
    @JsonKey(name: 'hideAns', fromJson: _parseBoolKey) bool? hideAns,
    @JsonKey(name: 'scoreDesc', fromJson: _parseStringKey) String? scoreDesc,
    @JsonKey(name: 'optionList', fromJson: _parseSubOptionList) List<IrsSubOption>? optionList,
    // 提問記錄 (askList) 欄位
    @JsonKey(name: 'pid', fromJson: _parseStringKey) String? pid,
    @JsonKey(name: 'askTime', fromJson: _parseStringKey) String? askTime,
    @JsonKey(name: 'askDesc', fromJson: _parseStringKey) String? askDesc,
    @JsonKey(name: 'replyContent', fromJson: _parseStringKey) String? replyContent,
    @JsonKey(name: 'replied', fromJson: _parseBoolKey) bool? replied,
  }) = _IrsAnswerRecord;

  factory IrsAnswerRecord.fromJson(Map<String, dynamic> json) =>
      _$IrsAnswerRecordFromJson(json);

  bool get isAskRecord => pid != null && pid!.isNotEmpty;

  bool get isExamPaper => questionType == '99';

  // 相容舊欄位名
  String? get title => description;
  String? get answerTime => ansTime;
  String? get courseId => cono;
  List<Map<String, dynamic>>? get options => optionList?.map((e) => e.toJson()).toList();
}

/// 考試詳情 (對齊 irs/stu/examDetail 回應與 IRSRecordActivity.show99View)
/// 欄位：description, teacherno, teafNam, teafEnam, ansTime, totalScore, myScore, hideAns, subquList
@freezed
abstract class IrsExamDetail with _$IrsExamDetail {
  const IrsExamDetail._();

  const factory IrsExamDetail({
    @JsonKey(name: 'description') required String description,
    @JsonKey(name: 'teacherno') required String teacherno,
    @JsonKey(name: 'teafNam') required String teafNam,
    @JsonKey(name: 'teafEnam') String? teafEnam,
    @JsonKey(name: 'ansTime') required String ansTime,
    @JsonKey(name: 'totalScore') required int totalScore,
    @JsonKey(name: 'myScore') required int myScore,
    @JsonKey(name: 'hideAns') @Default(false) bool hideAns,
    @JsonKey(name: 'subquList') @Default([]) List<IrsSubQuestion> subquList,
  }) = _IrsExamDetail;

  factory IrsExamDetail.fromJson(Map<String, dynamic> json) =>
      _$IrsExamDetailFromJson(json);

  // 相容舊欄位名 (供頁面與 Provider 使用)
  String get answerTime => ansTime;
  String get teacherName => teafNam;
  String? get teacherEnglishName => teafEnam;
  String get question => description;
  List<IrsSubQuestion> get subQuestions => subquList;
}

/// 子題目詳情 (對齊 IRSRecordActivity.show99View subquList 元素)
/// 欄位：questionId, questionType (int), description, optionList, imgPath, stdAnswer, myAnswer, score, correct, hideAns, scoreDesc
@freezed
abstract class IrsSubQuestion with _$IrsSubQuestion {
  const IrsSubQuestion._();

  const factory IrsSubQuestion({
    @JsonKey(name: 'questionId') String? questionId,
    @JsonKey(name: 'questionType', fromJson: _parseIntKey) @Default(2) int questionType,
    @JsonKey(name: 'description', fromJson: _parseStringKeyOrEmpty) @Default('') String description,
    @JsonKey(name: 'optionList') List<IrsSubOption>? optionList,
    @JsonKey(name: 'stdAnswer') String? stdAnswer,
    @JsonKey(name: 'myAnswer') String? myAnswer,
    @JsonKey(name: 'score') int? score,
    @JsonKey(name: 'correct') @Default(false) bool correct,
    @JsonKey(name: 'hideAns') @Default(false) bool hideAns,
    @JsonKey(name: 'scoreDesc') String? scoreDesc,
    @JsonKey(name: 'imgPath') String? imgPath,
  }) = _IrsSubQuestion;

  factory IrsSubQuestion.fromJson(Map<String, dynamic> json) =>
      _$IrsSubQuestionFromJson(json);
}

/// 子題目/歷史題目選項 (對齊 optionList: optKey, optVal, correct)
@freezed
abstract class IrsSubOption with _$IrsSubOption {
  const IrsSubOption._();

  const factory IrsSubOption({
    @JsonKey(name: 'optKey') required String optKey,
    @JsonKey(name: 'optVal') required String optVal,
    @JsonKey(name: 'correct') @Default(false) bool correct,
  }) = _IrsSubOption;

  factory IrsSubOption.fromJson(Map<String, dynamic> json) =>
      _$IrsSubOptionFromJson(json);
}

// ===========================================
// IRS 即時答題模型 (對齊 IRSActivity.java)
// ===========================================

/// IRS 即時試卷子題 (questionType == "99" 的 subQuList)
@freezed
abstract class IrsRealtimeSubQuestion with _$IrsRealtimeSubQuestion {
  const IrsRealtimeSubQuestion._();

  const factory IrsRealtimeSubQuestion({
    @JsonKey(name: 'subQuOrder') required int subQuOrder,
    @JsonKey(name: 'questionType') required String questionType,
    @JsonKey(name: 'description') required String description,
    @JsonKey(name: 'options') required List<IrsRealtimeOption> options,
    @JsonKey(name: 'imgPath') String? imgPath,
    @JsonKey(name: 'imgFile') String? imgFile,
  }) = _IrsRealtimeSubQuestion;

  factory IrsRealtimeSubQuestion.fromJson(Map<String, dynamic> json) =>
      _$IrsRealtimeSubQuestionFromJson(json);
}

/// IRS 即時題目
/// questionType: "1"=快問快答, "2"=單選, "3"=多選, "4"=文字/填空, "99"=試卷
@freezed
abstract class IrsRealtimeQuestion with _$IrsRealtimeQuestion {
  const IrsRealtimeQuestion._();

  const factory IrsRealtimeQuestion({
    @JsonKey(name: 'questionId') required String id,
    @JsonKey(name: 'content') required String content,
    @JsonKey(name: 'questionType') required int type,
    @JsonKey(name: 'options') required List<IrsRealtimeOption> options,
    @JsonKey(name: 'secno') required String secno,
    @JsonKey(name: 'answerTime') required String answerTime,
    @JsonKey(name: 'imagePath') String? imagePath,
    @JsonKey(name: 'imgFile') String? imgFile,
    @JsonKey(name: 'subQuestions') @Default([]) List<IrsRealtimeSubQuestion> subQuestions,
    @JsonKey(name: 'seqList') String? seqList,
    @JsonKey(name: 'period') @Default(0) int period,
  }) = _IrsRealtimeQuestion;

  factory IrsRealtimeQuestion.fromJson(Map<String, dynamic> json) =>
      _$IrsRealtimeQuestionFromJson(json);

  // 相容舊欄位名
  List<IrsRealtimeSubQuestion> get subQuList => subQuestions;
}

/// IRS 即時選項
@freezed
abstract class IrsRealtimeOption with _$IrsRealtimeOption {
  const IrsRealtimeOption._();

  const factory IrsRealtimeOption({
    @JsonKey(name: 'optKey') required String key,
    @JsonKey(name: 'optVal') required String value,
  }) = _IrsRealtimeOption;

  factory IrsRealtimeOption.fromJson(Map<String, dynamic> json) =>
      _$IrsRealtimeOptionFromJson(json);
}

/// IRS 即時答題狀態
@freezed
abstract class IrsRealtimeState with _$IrsRealtimeState {
  const factory IrsRealtimeState({
    @Default([]) List<IrsStudentClass> availableClasses,
    @Default([]) List<IrsRealtimeTeacher> availableTeachers,
    IrsStudentClass? selectedClass,
    IrsRealtimeTeacher? selectedTeacher,
    IrsRealtimeQuestion? currentQuestion,
    @Default(false) bool isLoading,
    @Default(false) bool isSubmitting,
    String? error,
  }) = _IrsRealtimeState;

  factory IrsRealtimeState.initial() => const IrsRealtimeState();
}

/// IRS 老師資訊
@freezed
abstract class IrsRealtimeTeacher with _$IrsRealtimeTeacher {
  const IrsRealtimeTeacher._();

  const factory IrsRealtimeTeacher({
    @JsonKey(name: 'teacherNo') required String id,
    @JsonKey(name: 'teacherName') required String name,
  }) = _IrsRealtimeTeacher;

  factory IrsRealtimeTeacher.fromJson(Map<String, dynamic> json) =>
      _$IrsRealtimeTeacherFromJson(json);

  // 相容舊欄位名
  String get teacherNo => id;
  String get teacherName => name;
}

/// IRS 即時答題提交請求
@freezed
abstract class IrsRealtimeSubmitRequest with _$IrsRealtimeSubmitRequest {
  const factory IrsRealtimeSubmitRequest({
    required String classId,
    required String studentId,
    required String teacherNo,
    required String secno,
    required String username,
    required List<IrsRealtimeAnswer> answers,
  }) = _IrsRealtimeSubmitRequest;

  factory IrsRealtimeSubmitRequest.fromJson(Map<String, dynamic> json) =>
      _$IrsRealtimeSubmitRequestFromJson(json);
}

/// IRS 即時答題答案
@freezed
abstract class IrsRealtimeAnswer with _$IrsRealtimeAnswer {
  const factory IrsRealtimeAnswer({
    required String questionId,
    required List<String> optionIds,
    String? textAnswer,
  }) = _IrsRealtimeAnswer;

  factory IrsRealtimeAnswer.fromJson(Map<String, dynamic> json) =>
      _$IrsRealtimeAnswerFromJson(json);
}