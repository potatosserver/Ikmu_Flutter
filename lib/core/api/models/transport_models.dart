// 交通、公車、YouBike 相關模型

import 'package:freezed_annotation/freezed_annotation.dart';

part 'transport_models.freezed.dart';
part 'transport_models.g.dart';

/// 公車路線
@freezed
abstract class BusRoute with _$BusRoute {
  const factory BusRoute({
    required String id,
    required String name,
    String? shortName,
    String? color,
    String? direction, // go, return
    @Default([]) List<BusStop> stops,
    String? firstBus,
    String? lastBus,
    int? interval, // 分鐘
  }) = _BusRoute;

  factory BusRoute.fromJson(Map<String, dynamic> json) => _$BusRouteFromJson(json);
}

/// 公車站牌
@freezed
abstract class BusStop with _$BusStop {
  const factory BusStop({
    required String id,
    required String name,
    required int sequence,
    double? latitude,
    double? longitude,
    @Default(false) bool isMain,
    String? address,
  }) = _BusStop;

  factory BusStop.fromJson(Map<String, dynamic> json) => _$BusStopFromJson(json);
}

/// 即時到站資訊
@freezed
abstract class BusRealtime with _$BusRealtime {
  const factory BusRealtime({
    required String routeId,
    required String stopId,
    required String stopName,
    int? estimateTime, // 秒
    int? distance, // 公尺
    String? busPlate,
    String? direction,
    String? updatedAt,
    @Default(false) bool isArriving,
  }) = _BusRealtime;

  factory BusRealtime.fromJson(Map<String, dynamic> json) => _$BusRealtimeFromJson(json);
}

/// BusRealtime 擴展方法
extension BusRealtimeExtension on BusRealtime {
  /// 顯示用時間
  String get displayTime {
    if (estimateTime == null) return '無資料';
    if (estimateTime! < 60) return '即將到達';
    if (estimateTime! < 3600) return '${(estimateTime! / 60).ceil()} 分鐘';
    return '${(estimateTime! / 3600).floor()} 小時 ${((estimateTime! % 3600) / 60).ceil()} 分鐘';
  }
}

/// 公車路線回應
@freezed
abstract class BusRouteResponse with _$BusRouteResponse {
  const factory BusRouteResponse({
    required bool success,
    required String message,
    @Default([]) List<dynamic> data,
  }) = _BusRouteResponse;

  factory BusRouteResponse.fromJson(Map<String, dynamic> json) =>
      _$BusRouteResponseFromJson(json);
}

/// 即時到站回應
@freezed
abstract class BusRealtimeResponse with _$BusRealtimeResponse {
  const factory BusRealtimeResponse({
    required bool success,
    required String message,
    @Default([]) List<dynamic> data,
  }) = _BusRealtimeResponse;

  factory BusRealtimeResponse.fromJson(Map<String, dynamic> json) =>
      _$BusRealtimeResponseFromJson(json);
}

/// 公車站牌回應
@freezed
abstract class BusStopResponse with _$BusStopResponse {
  const factory BusStopResponse({
    required bool success,
    required String message,
    @Default([]) List<BusStop> stops,
  }) = _BusStopResponse;

  factory BusStopResponse.fromJson(Map<String, dynamic> json) => _$BusStopResponseFromJson(json);
}

/// YouBike 站點
@freezed
abstract class BikeStation with _$BikeStation {
  const factory BikeStation({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    required int totalDocks,
    required int availableBikes,
    required int availableDocks,
    String? address,
    String? status, // normal, maintenance, closed
    String? updatedAt,
    String? area,
  }) = _BikeStation;

  factory BikeStation.fromJson(Map<String, dynamic> json) => _$BikeStationFromJson(json);
}

/// BikeStation 擴展方法
extension BikeStationExtension on BikeStation {
  /// 可借率
  double get availabilityRatio => totalDocks > 0 ? availableBikes / totalDocks : 0;

  /// 狀態顏色
  String get statusColor {
    if (status == 'maintenance' || status == 'closed') return '#FF1744';
    if (availableBikes == 0) return '#FF1744';
    if (availabilityRatio < 0.2) return '#FFD600';
    return '#00C853';
  }

  /// 狀態標籤
  String get statusLabel {
    if (status == 'maintenance') return '維護中';
    if (status == 'closed') return '暫停營運';
    if (availableBikes == 0) return '無可借車輛';
    if (availabilityRatio < 0.2) return '車輛較少';
    return '正常營運';
  }
}

/// YouBike 站點回應
@freezed
abstract class BikeStationResponse with _$BikeStationResponse {
  const factory BikeStationResponse({
    required bool success,
    required String message,
    @Default([]) List<dynamic> data,
  }) = _BikeStationResponse;

  factory BikeStationResponse.fromJson(Map<String, dynamic> json) =>
      _$BikeStationResponseFromJson(json);
}

/// 交通資訊
@freezed
abstract class TrafficInfo with _$TrafficInfo {
  const factory TrafficInfo({
    required String id,
    required String title,
    String? description,
    String? type, // roadwork, accident, control, event
    String? location,
    String? startTime,
    String? endTime,
    String? severity, // low, medium, high
    String? source,
    String? updatedAt,
  }) = _TrafficInfo;

  factory TrafficInfo.fromJson(Map<String, dynamic> json) => _$TrafficInfoFromJson(json);
}

/// 交通資訊回應
@freezed
abstract class TrafficInfoResponse with _$TrafficInfoResponse {
  const factory TrafficInfoResponse({
    required bool success,
    required String message,
    @Default([]) List<dynamic> data,
  }) = _TrafficInfoResponse;

  factory TrafficInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$TrafficInfoResponseFromJson(json);
}

/// 交通狀態 (Riverpod 管理)
@freezed
abstract class TransportState with _$TransportState {
  const factory TransportState({
    @Default([]) List<BusRoute> busRoutes,
    @Default([]) List<BusRealtime> busRealtime,
    @Default([]) List<BikeStation> bikeStations,
    @Default([]) List<TrafficInfo> trafficInfos,
    String? selectedRouteId,
    String? selectedStopId,
    @Default(false) bool isLoadingRoutes,
    @Default(false) bool isLoadingRealtime,
    @Default(false) bool isLoadingBikes,
    @Default(false) bool isLoadingTraffic,
    String? error,
  }) = _TransportState;

  factory TransportState.initial() => const TransportState();
}