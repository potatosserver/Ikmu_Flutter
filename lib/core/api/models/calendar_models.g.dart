// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarEvent _$CalendarEventFromJson(Map<String, dynamic> json) =>
    CalendarEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      typeCode: json['typeCode'] as String,
      typeName: json['typeName'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      allDay: json['allDay'] as bool? ?? false,
      location: json['location'] as String?,
      info: json['info'] as String?,
      extendedInfo: json['extendedInfo'] as String?,
      color: json['color'] as String?,
      sequence: (json['sequence'] as num?)?.toInt(),
      date: json['date'] as String?,
    );

Map<String, dynamic> _$CalendarEventToJson(CalendarEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'typeCode': instance.typeCode,
      'typeName': instance.typeName,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'allDay': instance.allDay,
      'location': instance.location,
      'info': instance.info,
      'extendedInfo': instance.extendedInfo,
      'color': instance.color,
      'sequence': instance.sequence,
      'date': instance.date,
    };

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
      event: CalendarEvent.fromJson(json['event'] as Map<String, dynamic>),
      dateStr: json['dateStr'] as String,
      allDayEvents: (json['allDayEvents'] as List<dynamic>)
          .map((e) => CalendarEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$EventDetailDataImplToJson(
        _$EventDetailDataImpl instance) =>
    <String, dynamic>{
      'event': instance.event,
      'dateStr': instance.dateStr,
      'allDayEvents': instance.allDayEvents,
    };
