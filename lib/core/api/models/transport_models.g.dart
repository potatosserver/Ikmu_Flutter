// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transport_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BusRouteImpl _$$BusRouteImplFromJson(Map<String, dynamic> json) =>
    _$BusRouteImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String?,
      color: json['color'] as String?,
      direction: json['direction'] as String?,
      stops: (json['stops'] as List<dynamic>?)
              ?.map((e) => BusStop.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      firstBus: json['firstBus'] as String?,
      lastBus: json['lastBus'] as String?,
      interval: (json['interval'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$BusRouteImplToJson(_$BusRouteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'shortName': instance.shortName,
      'color': instance.color,
      'direction': instance.direction,
      'stops': instance.stops,
      'firstBus': instance.firstBus,
      'lastBus': instance.lastBus,
      'interval': instance.interval,
    };

_$BusStopImpl _$$BusStopImplFromJson(Map<String, dynamic> json) =>
    _$BusStopImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      sequence: (json['sequence'] as num).toInt(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isMain: json['isMain'] as bool? ?? false,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$$BusStopImplToJson(_$BusStopImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sequence': instance.sequence,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'isMain': instance.isMain,
      'address': instance.address,
    };

_$BusRealtimeImpl _$$BusRealtimeImplFromJson(Map<String, dynamic> json) =>
    _$BusRealtimeImpl(
      routeId: json['routeId'] as String,
      stopId: json['stopId'] as String,
      stopName: json['stopName'] as String,
      estimateTime: (json['estimateTime'] as num?)?.toInt(),
      distance: (json['distance'] as num?)?.toInt(),
      busPlate: json['busPlate'] as String?,
      direction: json['direction'] as String?,
      updatedAt: json['updatedAt'] as String?,
      isArriving: json['isArriving'] as bool? ?? false,
    );

Map<String, dynamic> _$$BusRealtimeImplToJson(_$BusRealtimeImpl instance) =>
    <String, dynamic>{
      'routeId': instance.routeId,
      'stopId': instance.stopId,
      'stopName': instance.stopName,
      'estimateTime': instance.estimateTime,
      'distance': instance.distance,
      'busPlate': instance.busPlate,
      'direction': instance.direction,
      'updatedAt': instance.updatedAt,
      'isArriving': instance.isArriving,
    };

_$BusRouteResponseImpl _$$BusRouteResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$BusRouteResponseImpl(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] as List<dynamic>? ?? const [],
    );

Map<String, dynamic> _$$BusRouteResponseImplToJson(
        _$BusRouteResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

_$BusRealtimeResponseImpl _$$BusRealtimeResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$BusRealtimeResponseImpl(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] as List<dynamic>? ?? const [],
    );

Map<String, dynamic> _$$BusRealtimeResponseImplToJson(
        _$BusRealtimeResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

_$BusStopResponseImpl _$$BusStopResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$BusStopResponseImpl(
      success: json['success'] as bool,
      message: json['message'] as String,
      stops: (json['stops'] as List<dynamic>?)
              ?.map((e) => BusStop.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$BusStopResponseImplToJson(
        _$BusStopResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'stops': instance.stops,
    };

_$BikeStationImpl _$$BikeStationImplFromJson(Map<String, dynamic> json) =>
    _$BikeStationImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      totalDocks: (json['totalDocks'] as num).toInt(),
      availableBikes: (json['availableBikes'] as num).toInt(),
      availableDocks: (json['availableDocks'] as num).toInt(),
      address: json['address'] as String?,
      status: json['status'] as String?,
      updatedAt: json['updatedAt'] as String?,
      area: json['area'] as String?,
    );

Map<String, dynamic> _$$BikeStationImplToJson(_$BikeStationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'totalDocks': instance.totalDocks,
      'availableBikes': instance.availableBikes,
      'availableDocks': instance.availableDocks,
      'address': instance.address,
      'status': instance.status,
      'updatedAt': instance.updatedAt,
      'area': instance.area,
    };

_$BikeStationResponseImpl _$$BikeStationResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$BikeStationResponseImpl(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] as List<dynamic>? ?? const [],
    );

Map<String, dynamic> _$$BikeStationResponseImplToJson(
        _$BikeStationResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

_$TrafficInfoImpl _$$TrafficInfoImplFromJson(Map<String, dynamic> json) =>
    _$TrafficInfoImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: json['type'] as String?,
      location: json['location'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      severity: json['severity'] as String?,
      source: json['source'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$$TrafficInfoImplToJson(_$TrafficInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': instance.type,
      'location': instance.location,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'severity': instance.severity,
      'source': instance.source,
      'updatedAt': instance.updatedAt,
    };

_$TrafficInfoResponseImpl _$$TrafficInfoResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$TrafficInfoResponseImpl(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] as List<dynamic>? ?? const [],
    );

Map<String, dynamic> _$$TrafficInfoResponseImplToJson(
        _$TrafficInfoResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };
