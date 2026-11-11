// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'irs_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IrsQuestionnaireImpl _$$IrsQuestionnaireImplFromJson(
        Map<String, dynamic> json) =>
    _$IrsQuestionnaireImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      isActive: json['isActive'] as bool,
      questionCount: (json['questionCount'] as num).toInt(),
      category: json['category'] as String?,
      targetAudience: json['targetAudience'] as String?,
      isSubmitted: json['isSubmitted'] as bool? ?? false,
    );

Map<String, dynamic> _$$IrsQuestionnaireImplToJson(
        _$IrsQuestionnaireImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'isActive': instance.isActive,
      'questionCount': instance.questionCount,
      'category': instance.category,
      'targetAudience': instance.targetAudience,
      'isSubmitted': instance.isSubmitted,
    };

_$IrsQuestionImpl _$$IrsQuestionImplFromJson(Map<String, dynamic> json) =>
    _$IrsQuestionImpl(
      id: json['id'] as String,
      questionnaireId: json['questionnaireId'] as String,
      sequence: (json['sequence'] as num).toInt(),
      content: json['content'] as String,
      type: $enumDecode(_$IrsQuestionTypeEnumMap, json['type']),
      options: (json['options'] as List<dynamic>)
          .map((e) => IrsOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      isRequired: json['isRequired'] as bool,
      description: json['description'] as String?,
      maxSelections: (json['maxSelections'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$IrsQuestionImplToJson(_$IrsQuestionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'questionnaireId': instance.questionnaireId,
      'sequence': instance.sequence,
      'content': instance.content,
      'type': _$IrsQuestionTypeEnumMap[instance.type]!,
      'options': instance.options,
      'isRequired': instance.isRequired,
      'description': instance.description,
      'maxSelections': instance.maxSelections,
    };

const _$IrsQuestionTypeEnumMap = {
  IrsQuestionType.singleChoice: 'single',
  IrsQuestionType.multipleChoice: 'multiple',
  IrsQuestionType.textInput: 'text',
  IrsQuestionType.scale: 'scale',
};

_$IrsOptionImpl _$$IrsOptionImplFromJson(Map<String, dynamic> json) =>
    _$IrsOptionImpl(
      id: json['id'] as String,
      content: json['content'] as String,
      score: (json['score'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$IrsOptionImplToJson(_$IrsOptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'score': instance.score,
    };

_$IrsSubmissionRequestImpl _$$IrsSubmissionRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$IrsSubmissionRequestImpl(
      questionnaireId: json['questionnaireId'] as String,
      answers: (json['answers'] as List<dynamic>)
          .map((e) => IrsAnswer.fromJson(e as Map<String, dynamic>))
          .toList(),
      userId: json['userId'] as String?,
    );

Map<String, dynamic> _$$IrsSubmissionRequestImplToJson(
        _$IrsSubmissionRequestImpl instance) =>
    <String, dynamic>{
      'questionnaireId': instance.questionnaireId,
      'answers': instance.answers,
      'userId': instance.userId,
    };

_$IrsAnswerImpl _$$IrsAnswerImplFromJson(Map<String, dynamic> json) =>
    _$IrsAnswerImpl(
      questionId: json['questionId'] as String,
      optionIds:
          (json['optionIds'] as List<dynamic>).map((e) => e as String).toList(),
      textAnswer: json['textAnswer'] as String?,
    );

Map<String, dynamic> _$$IrsAnswerImplToJson(_$IrsAnswerImpl instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'optionIds': instance.optionIds,
      'textAnswer': instance.textAnswer,
    };

_$IrsSubmissionResponseImpl _$$IrsSubmissionResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$IrsSubmissionResponseImpl(
      success: json['success'] as bool,
      message: json['message'] as String,
      submissionId: json['submissionId'] as String?,
      score: (json['score'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$IrsSubmissionResponseImplToJson(
        _$IrsSubmissionResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'submissionId': instance.submissionId,
      'score': instance.score,
    };

_$IrsQuestionnaireDetailImpl _$$IrsQuestionnaireDetailImplFromJson(
        Map<String, dynamic> json) =>
    _$IrsQuestionnaireDetailImpl(
      questionnaire: IrsQuestionnaire.fromJson(
          json['questionnaire'] as Map<String, dynamic>),
      questions: (json['questions'] as List<dynamic>)
          .map((e) => IrsQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$IrsQuestionnaireDetailImplToJson(
        _$IrsQuestionnaireDetailImpl instance) =>
    <String, dynamic>{
      'questionnaire': instance.questionnaire,
      'questions': instance.questions,
    };

_$IrsStudentClassImpl _$$IrsStudentClassImplFromJson(
        Map<String, dynamic> json) =>
    _$IrsStudentClassImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      englishName: json['englishName'] as String?,
    );

Map<String, dynamic> _$$IrsStudentClassImplToJson(
        _$IrsStudentClassImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'englishName': instance.englishName,
    };

_$IrsAnswerRecordImpl _$$IrsAnswerRecordImplFromJson(
        Map<String, dynamic> json) =>
    _$IrsAnswerRecordImpl(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      courseName: json['courseName'] as String,
      title: json['title'] as String,
      answerTime: json['answerTime'] as String,
      myScore: (json['myScore'] as num).toInt(),
      totalScore: (json['totalScore'] as num).toInt(),
      imagePath: json['imagePath'] as String?,
      stdAnswer: json['stdAnswer'] as String?,
      myAnswer: json['myAnswer'] as String?,
    );

Map<String, dynamic> _$$IrsAnswerRecordImplToJson(
        _$IrsAnswerRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'courseId': instance.courseId,
      'courseName': instance.courseName,
      'title': instance.title,
      'answerTime': instance.answerTime,
      'myScore': instance.myScore,
      'totalScore': instance.totalScore,
      'imagePath': instance.imagePath,
      'stdAnswer': instance.stdAnswer,
      'myAnswer': instance.myAnswer,
    };

_$IrsExamDetailImpl _$$IrsExamDetailImplFromJson(Map<String, dynamic> json) =>
    _$IrsExamDetailImpl(
      answerTime: json['answerTime'] as String,
      teacherName: json['teacherName'] as String,
      question: json['question'] as String,
      myScore: (json['myScore'] as num).toInt(),
      totalScore: (json['totalScore'] as num).toInt(),
      subQuestions: (json['subQuestions'] as List<dynamic>)
          .map((e) => IrsSubQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$IrsExamDetailImplToJson(_$IrsExamDetailImpl instance) =>
    <String, dynamic>{
      'answerTime': instance.answerTime,
      'teacherName': instance.teacherName,
      'question': instance.question,
      'myScore': instance.myScore,
      'totalScore': instance.totalScore,
      'subQuestions': instance.subQuestions,
    };

_$IrsSubQuestionImpl _$$IrsSubQuestionImplFromJson(Map<String, dynamic> json) =>
    _$IrsSubQuestionImpl(
      questionType: json['questionType'] as String,
      description: json['description'] as String,
      scoreDesc: json['scoreDesc'] as String,
      myAnswer: json['myAnswer'] as String,
      stdAnswer: json['stdAnswer'] as String?,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => IrsSubOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      imagePath: json['imagePath'] as String?,
    );

Map<String, dynamic> _$$IrsSubQuestionImplToJson(
        _$IrsSubQuestionImpl instance) =>
    <String, dynamic>{
      'questionType': instance.questionType,
      'description': instance.description,
      'scoreDesc': instance.scoreDesc,
      'myAnswer': instance.myAnswer,
      'stdAnswer': instance.stdAnswer,
      'options': instance.options,
      'imagePath': instance.imagePath,
    };

_$IrsSubOptionImpl _$$IrsSubOptionImplFromJson(Map<String, dynamic> json) =>
    _$IrsSubOptionImpl(
      key: json['key'] as String,
      value: json['value'] as String,
      isCorrect: json['isCorrect'] as bool? ?? false,
    );

Map<String, dynamic> _$$IrsSubOptionImplToJson(_$IrsSubOptionImpl instance) =>
    <String, dynamic>{
      'key': instance.key,
      'value': instance.value,
      'isCorrect': instance.isCorrect,
    };
