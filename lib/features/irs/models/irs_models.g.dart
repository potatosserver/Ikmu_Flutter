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
      id: json['classId'] as String,
      name: json['className'] as String,
      englishName: json['englishco'] as String?,
      teacherNo: json['teafno'] as String?,
      teacherName: json['teafnam'] as String?,
      seqno: json['seqno'] as String?,
      classRoom: json['classRoom'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      teacherList: (json['teacherList'] as List<dynamic>?)
              ?.map(
                  (e) => IrsRealtimeTeacher.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$IrsStudentClassImplToJson(
        _$IrsStudentClassImpl instance) =>
    <String, dynamic>{
      'classId': instance.id,
      'className': instance.name,
      'englishco': instance.englishName,
      'teafno': instance.teacherNo,
      'teafnam': instance.teacherName,
      'seqno': instance.seqno,
      'classRoom': instance.classRoom,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'teacherList': instance.teacherList,
    };

_$IrsAnswerRecordImpl _$$IrsAnswerRecordImplFromJson(
        Map<String, dynamic> json) =>
    _$IrsAnswerRecordImpl(
      myScore: json['myScore'] == null ? 0 : _parseIntKey(json['myScore']),
      totalScore:
          json['totalScore'] == null ? 0 : _parseIntKey(json['totalScore']),
      questionId: _parseStringKey(json['questionId']),
      cono: _parseStringKey(json['cono']),
      courseName: _parseStringKey(json['courseName']),
      questionType: _parseStringKey(json['questionType']),
      description: _parseStringKey(json['description']),
      ansTime: _parseStringKey(json['ansTime']),
      teafNam: _parseStringKey(json['teafNam']),
      teafEnam: _parseStringKey(json['teafEnam']),
      imgPath: _parseStringKey(json['imgPath']),
      stdAnswer: _parseStringKey(json['stdAnswer']),
      myAnswer: _parseStringKey(json['myAnswer']),
      correct: _parseBoolKey(json['correct']),
      hideAns: _parseBoolKey(json['hideAns']),
      scoreDesc: _parseStringKey(json['scoreDesc']),
      optionList: _parseSubOptionList(json['optionList']),
      pid: _parseStringKey(json['pid']),
      askTime: _parseStringKey(json['askTime']),
      askDesc: _parseStringKey(json['askDesc']),
      replyContent: _parseStringKey(json['replyContent']),
      replied: _parseBoolKey(json['replied']),
    );

Map<String, dynamic> _$$IrsAnswerRecordImplToJson(
        _$IrsAnswerRecordImpl instance) =>
    <String, dynamic>{
      'myScore': instance.myScore,
      'totalScore': instance.totalScore,
      'questionId': instance.questionId,
      'cono': instance.cono,
      'courseName': instance.courseName,
      'questionType': instance.questionType,
      'description': instance.description,
      'ansTime': instance.ansTime,
      'teafNam': instance.teafNam,
      'teafEnam': instance.teafEnam,
      'imgPath': instance.imgPath,
      'stdAnswer': instance.stdAnswer,
      'myAnswer': instance.myAnswer,
      'correct': instance.correct,
      'hideAns': instance.hideAns,
      'scoreDesc': instance.scoreDesc,
      'optionList': instance.optionList,
      'pid': instance.pid,
      'askTime': instance.askTime,
      'askDesc': instance.askDesc,
      'replyContent': instance.replyContent,
      'replied': instance.replied,
    };

_$IrsExamDetailImpl _$$IrsExamDetailImplFromJson(Map<String, dynamic> json) =>
    _$IrsExamDetailImpl(
      description: json['description'] as String,
      teacherno: json['teacherno'] as String,
      teafNam: json['teafNam'] as String,
      teafEnam: json['teafEnam'] as String?,
      ansTime: json['ansTime'] as String,
      totalScore: (json['totalScore'] as num).toInt(),
      myScore: (json['myScore'] as num).toInt(),
      hideAns: json['hideAns'] as bool? ?? false,
      subquList: (json['subquList'] as List<dynamic>)
          .map((e) => IrsSubQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$IrsExamDetailImplToJson(_$IrsExamDetailImpl instance) =>
    <String, dynamic>{
      'description': instance.description,
      'teacherno': instance.teacherno,
      'teafNam': instance.teafNam,
      'teafEnam': instance.teafEnam,
      'ansTime': instance.ansTime,
      'totalScore': instance.totalScore,
      'myScore': instance.myScore,
      'hideAns': instance.hideAns,
      'subquList': instance.subquList,
    };

_$IrsSubQuestionImpl _$$IrsSubQuestionImplFromJson(Map<String, dynamic> json) =>
    _$IrsSubQuestionImpl(
      questionId: json['questionId'] as String?,
      questionType: (json['questionType'] as num).toInt(),
      description: json['description'] as String,
      optionList: (json['optionList'] as List<dynamic>?)
          ?.map((e) => IrsSubOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      stdAnswer: json['stdAnswer'] as String?,
      myAnswer: json['myAnswer'] as String?,
      score: (json['score'] as num?)?.toInt(),
      correct: json['correct'] as bool? ?? false,
      hideAns: json['hideAns'] as bool? ?? false,
      scoreDesc: json['scoreDesc'] as String?,
      imgPath: json['imgPath'] as String?,
    );

Map<String, dynamic> _$$IrsSubQuestionImplToJson(
        _$IrsSubQuestionImpl instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'questionType': instance.questionType,
      'description': instance.description,
      'optionList': instance.optionList,
      'stdAnswer': instance.stdAnswer,
      'myAnswer': instance.myAnswer,
      'score': instance.score,
      'correct': instance.correct,
      'hideAns': instance.hideAns,
      'scoreDesc': instance.scoreDesc,
      'imgPath': instance.imgPath,
    };

_$IrsSubOptionImpl _$$IrsSubOptionImplFromJson(Map<String, dynamic> json) =>
    _$IrsSubOptionImpl(
      optKey: json['optKey'] as String,
      optVal: json['optVal'] as String,
      correct: json['correct'] as bool? ?? false,
    );

Map<String, dynamic> _$$IrsSubOptionImplToJson(_$IrsSubOptionImpl instance) =>
    <String, dynamic>{
      'optKey': instance.optKey,
      'optVal': instance.optVal,
      'correct': instance.correct,
    };

_$IrsRealtimeSubQuestionImpl _$$IrsRealtimeSubQuestionImplFromJson(
        Map<String, dynamic> json) =>
    _$IrsRealtimeSubQuestionImpl(
      subQuOrder: (json['subQuOrder'] as num).toInt(),
      questionType: json['questionType'] as String,
      description: json['description'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => IrsRealtimeOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      imgPath: json['imgPath'] as String?,
      imgFile: json['imgFile'] as String?,
    );

Map<String, dynamic> _$$IrsRealtimeSubQuestionImplToJson(
        _$IrsRealtimeSubQuestionImpl instance) =>
    <String, dynamic>{
      'subQuOrder': instance.subQuOrder,
      'questionType': instance.questionType,
      'description': instance.description,
      'options': instance.options,
      'imgPath': instance.imgPath,
      'imgFile': instance.imgFile,
    };

_$IrsRealtimeQuestionImpl _$$IrsRealtimeQuestionImplFromJson(
        Map<String, dynamic> json) =>
    _$IrsRealtimeQuestionImpl(
      id: json['questionId'] as String,
      content: json['content'] as String,
      type: (json['questionType'] as num).toInt(),
      options: (json['options'] as List<dynamic>)
          .map((e) => IrsRealtimeOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      secno: json['secno'] as String,
      answerTime: json['answerTime'] as String,
      imagePath: json['imagePath'] as String?,
      imgFile: json['imgFile'] as String?,
      subQuestions: (json['subQuestions'] as List<dynamic>?)
              ?.map((e) =>
                  IrsRealtimeSubQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      seqList: json['seqList'] as String?,
      period: (json['period'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$IrsRealtimeQuestionImplToJson(
        _$IrsRealtimeQuestionImpl instance) =>
    <String, dynamic>{
      'questionId': instance.id,
      'content': instance.content,
      'questionType': instance.type,
      'options': instance.options,
      'secno': instance.secno,
      'answerTime': instance.answerTime,
      'imagePath': instance.imagePath,
      'imgFile': instance.imgFile,
      'subQuestions': instance.subQuestions,
      'seqList': instance.seqList,
      'period': instance.period,
    };

_$IrsRealtimeOptionImpl _$$IrsRealtimeOptionImplFromJson(
        Map<String, dynamic> json) =>
    _$IrsRealtimeOptionImpl(
      key: json['optKey'] as String,
      value: json['optVal'] as String,
    );

Map<String, dynamic> _$$IrsRealtimeOptionImplToJson(
        _$IrsRealtimeOptionImpl instance) =>
    <String, dynamic>{
      'optKey': instance.key,
      'optVal': instance.value,
    };

_$IrsRealtimeTeacherImpl _$$IrsRealtimeTeacherImplFromJson(
        Map<String, dynamic> json) =>
    _$IrsRealtimeTeacherImpl(
      id: json['teacherNo'] as String,
      name: json['teacherName'] as String,
    );

Map<String, dynamic> _$$IrsRealtimeTeacherImplToJson(
        _$IrsRealtimeTeacherImpl instance) =>
    <String, dynamic>{
      'teacherNo': instance.id,
      'teacherName': instance.name,
    };

_$IrsRealtimeSubmitRequestImpl _$$IrsRealtimeSubmitRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$IrsRealtimeSubmitRequestImpl(
      classId: json['classId'] as String,
      studentId: json['studentId'] as String,
      teacherNo: json['teacherNo'] as String,
      secno: json['secno'] as String,
      username: json['username'] as String,
      answers: (json['answers'] as List<dynamic>)
          .map((e) => IrsRealtimeAnswer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$IrsRealtimeSubmitRequestImplToJson(
        _$IrsRealtimeSubmitRequestImpl instance) =>
    <String, dynamic>{
      'classId': instance.classId,
      'studentId': instance.studentId,
      'teacherNo': instance.teacherNo,
      'secno': instance.secno,
      'username': instance.username,
      'answers': instance.answers,
    };

_$IrsRealtimeAnswerImpl _$$IrsRealtimeAnswerImplFromJson(
        Map<String, dynamic> json) =>
    _$IrsRealtimeAnswerImpl(
      questionId: json['questionId'] as String,
      optionIds:
          (json['optionIds'] as List<dynamic>).map((e) => e as String).toList(),
      textAnswer: json['textAnswer'] as String?,
    );

Map<String, dynamic> _$$IrsRealtimeAnswerImplToJson(
        _$IrsRealtimeAnswerImpl instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'optionIds': instance.optionIds,
      'textAnswer': instance.textAnswer,
    };
