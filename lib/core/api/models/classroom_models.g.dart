// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classroom_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClassroomUsageResponseImpl _$$ClassroomUsageResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ClassroomUsageResponseImpl(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'],
    );

Map<String, dynamic> _$$ClassroomUsageResponseImplToJson(
        _$ClassroomUsageResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };
