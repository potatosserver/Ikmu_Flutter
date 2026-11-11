// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campus_info_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NewsListResponseImpl _$$NewsListResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$NewsListResponseImpl(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$NewsListResponseImplToJson(
        _$NewsListResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

_$NewsDetailResponseImpl _$$NewsDetailResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$NewsDetailResponseImpl(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$NewsDetailResponseImplToJson(
        _$NewsDetailResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

_$POIResponseImpl _$$POIResponseImplFromJson(Map<String, dynamic> json) =>
    _$POIResponseImpl(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] as List<dynamic>? ?? const [],
    );

Map<String, dynamic> _$$POIResponseImplToJson(_$POIResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

_$GalleryResponseImpl _$$GalleryResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$GalleryResponseImpl(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] as List<dynamic>? ?? const [],
    );

Map<String, dynamic> _$$GalleryResponseImplToJson(
        _$GalleryResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };
