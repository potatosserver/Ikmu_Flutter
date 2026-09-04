// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CalendarEventTypeImpl _$$CalendarEventTypeImplFromJson(
        Map<String, dynamic> json) =>
    _$CalendarEventTypeImpl(
      code: json['code'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      icon: json['icon'] as String? ?? '',
    );

Map<String, dynamic> _$$CalendarEventTypeImplToJson(
        _$CalendarEventTypeImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'color': instance.color,
      'icon': instance.icon,
    };

_$CalendarMonthResponseImpl _$$CalendarMonthResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$CalendarMonthResponseImpl(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$CalendarMonthResponseImplToJson(
        _$CalendarMonthResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

_$EventDetailDataImpl _$$EventDetailDataImplFromJson(
        Map<String, dynamic> json) =>
    _$EventDetailDataImpl(
      event: json['event'],
      dateStr: json['dateStr'] as String,
      allDayEvents: json['allDayEvents'] as List<dynamic>,
    );

Map<String, dynamic> _$$EventDetailDataImplToJson(
        _$EventDetailDataImpl instance) =>
    <String, dynamic>{
      'event': instance.event,
      'dateStr': instance.dateStr,
      'allDayEvents': instance.allDayEvents,
    };
