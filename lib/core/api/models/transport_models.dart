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
    // YouBike 2.0 API 原始欄位
    String? stationNo,
    String? sna,
    String? ar,
    String? act,
    String? mday,
    String? sarea,
    int? tot,
    int? sbi,
    int? bemp,
    int? yb2,
    int? eyb,
  }) = _BikeStation;

  factory BikeStation.fromJson(Map<String, dynamic> json) {
    // 處理 YouBike 2.0 API 回傳格式
    // { "station_no": "501202036", "parking_spaces": 39, "available_spaces": 11,
    //   "available_spaces_detail": { "yb2": 11, "eyb": 0 },
    //   "empty_spaces": 27, "forbidden_spaces": 0, "available_spaces_level": 80,
    //   "lat": "22.61435", "lng": "120.30466", "status": 1 }
    // 也相容舊版 YouBike 1.0 格式 (有 sna, name, ar, sarea, mday, act)
    final stationNo = json['station_no']?.toString() ?? json['sno']?.toString() ?? json['id']?.toString() ?? '';
    final sna = json['sna']?.toString() ?? json['name']?.toString() ?? stationNo; // 2.0 沒有站名，用 stationNo 當預設
    // lat/lng 可能是 String 或 double，需安全轉換
    final lat = _parseDouble(json['lat'] ?? json['latitude']);
    final lng = _parseDouble(json['lng'] ?? json['longitude']);
    final tot = _parseInt(json['parking_spaces'] ?? json['tot'] ?? json['totalDocks']);
    final sbi = _parseInt(json['available_spaces'] ?? json['sbi'] ?? json['availableBikes']);
    final bemp = _parseInt(json['empty_spaces'] ?? json['bemp'] ?? json['availableDocks']);
    final yb2 = _parseInt(json['available_spaces_detail']?['yb2'] ?? json['yb2']);
    final eyb = _parseInt(json['available_spaces_detail']?['eyb'] ?? json['eyb']);
    // status: 1=正常, 2=維護/關閉
    final statusRaw = json['status']?.toString() ?? json['act']?.toString() ?? '1';
    final status = statusRaw == '2' ? 'closed' : 'normal';

    return BikeStation(
      id: stationNo,
      name: sna,
      latitude: lat,
      longitude: lng,
      totalDocks: tot,
      availableBikes: sbi,
      availableDocks: bemp,
      address: json['ar']?.toString() ?? json['address']?.toString(),
      status: status,
      updatedAt: json['mday']?.toString() ?? json['updatedAt']?.toString(),
      area: json['sarea']?.toString() ?? json['area']?.toString(),
      stationNo: stationNo,
      sna: sna,
      ar: json['ar']?.toString(),
      act: statusRaw,
      mday: json['mday']?.toString(),
      sarea: json['sarea']?.toString(),
      tot: tot,
      sbi: sbi,
      bemp: bemp,
      yb2: yb2,
      eyb: eyb,
    );
  }

  static double _parseDouble(value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
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

  /// 序列化為 JSON (供 Hive 快取使用)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'totalDocks': totalDocks,
      'availableBikes': availableBikes,
      'availableDocks': availableDocks,
      'address': address,
      'status': status,
      'updatedAt': updatedAt,
      'area': area,
      'stationNo': stationNo,
      'sna': sna,
      'ar': ar,
      'act': act,
      'mday': mday,
      'sarea': sarea,
      'tot': tot,
      'sbi': sbi,
      'bemp': bemp,
      'yb2': yb2,
      'eyb': eyb,
    };
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

/// 捷運站點 (高雄捷運 紅/橘線)
@freezed
abstract class MetroStation with _$MetroStation {
  const factory MetroStation({
    required String id,
    required String name,
    required String nameEn,
    required double latitude,
    required double longitude,
    required String line, // 'red', 'orange'
    required int sequence,
    String? address,
    String? transfer, // 轉乘資訊
  }) = _MetroStation;

  factory MetroStation.fromJson(Map<String, dynamic> json) => _$MetroStationFromJson(json);
}

/// 輕軌站點 (環狀輕軌)
@freezed
abstract class LRTStation with _$LRTStation {
  const factory LRTStation({
    required String id,
    required String name,
    required String nameEn,
    required double latitude,
    required double longitude,
    required int sequence,
    String? address,
  }) = _LRTStation;

  factory LRTStation.fromJson(Map<String, dynamic> json) => _$LRTStationFromJson(json);
}

/// 交通狀態 (Riverpod 管理)
@freezed
abstract class TransportState with _$TransportState {
  const factory TransportState({
    @Default([]) List<BusRoute> busRoutes,
    @Default([]) List<BusRealtime> busRealtime,
    @Default([]) List<BikeStation> bikeStations,
    @Default([]) List<TrafficInfo> trafficInfos,
    @Default([]) List<MetroStation> metroStations,
    @Default([]) List<LRTStation> lrtStations,
    String? selectedRouteId,
    String? selectedStopId,
    @Default(false) bool isLoadingRoutes,
    @Default(false) bool isLoadingRealtime,
    @Default(false) bool isLoadingBikes,
    @Default(false) bool isLoadingTraffic,
    @Default(false) bool isLoadingMetro,
    @Default(false) bool isLoadingLRT,
    String? error,
  }) = _TransportState;

  factory TransportState.initial() => const TransportState();
}