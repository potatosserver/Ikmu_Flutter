// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transport_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BusRoute _$BusRouteFromJson(Map<String, dynamic> json) {
  return _BusRoute.fromJson(json);
}

/// @nodoc
mixin _$BusRoute {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get shortName => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  String? get direction => throw _privateConstructorUsedError; // go, return
  List<BusStop> get stops => throw _privateConstructorUsedError;
  String? get firstBus => throw _privateConstructorUsedError;
  String? get lastBus => throw _privateConstructorUsedError;
  int? get interval => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BusRouteCopyWith<BusRoute> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusRouteCopyWith<$Res> {
  factory $BusRouteCopyWith(BusRoute value, $Res Function(BusRoute) then) =
      _$BusRouteCopyWithImpl<$Res, BusRoute>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? shortName,
      String? color,
      String? direction,
      List<BusStop> stops,
      String? firstBus,
      String? lastBus,
      int? interval});
}

/// @nodoc
class _$BusRouteCopyWithImpl<$Res, $Val extends BusRoute>
    implements $BusRouteCopyWith<$Res> {
  _$BusRouteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? shortName = freezed,
    Object? color = freezed,
    Object? direction = freezed,
    Object? stops = null,
    Object? firstBus = freezed,
    Object? lastBus = freezed,
    Object? interval = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      shortName: freezed == shortName
          ? _value.shortName
          : shortName // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      direction: freezed == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as String?,
      stops: null == stops
          ? _value.stops
          : stops // ignore: cast_nullable_to_non_nullable
              as List<BusStop>,
      firstBus: freezed == firstBus
          ? _value.firstBus
          : firstBus // ignore: cast_nullable_to_non_nullable
              as String?,
      lastBus: freezed == lastBus
          ? _value.lastBus
          : lastBus // ignore: cast_nullable_to_non_nullable
              as String?,
      interval: freezed == interval
          ? _value.interval
          : interval // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BusRouteImplCopyWith<$Res>
    implements $BusRouteCopyWith<$Res> {
  factory _$$BusRouteImplCopyWith(
          _$BusRouteImpl value, $Res Function(_$BusRouteImpl) then) =
      __$$BusRouteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? shortName,
      String? color,
      String? direction,
      List<BusStop> stops,
      String? firstBus,
      String? lastBus,
      int? interval});
}

/// @nodoc
class __$$BusRouteImplCopyWithImpl<$Res>
    extends _$BusRouteCopyWithImpl<$Res, _$BusRouteImpl>
    implements _$$BusRouteImplCopyWith<$Res> {
  __$$BusRouteImplCopyWithImpl(
      _$BusRouteImpl _value, $Res Function(_$BusRouteImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? shortName = freezed,
    Object? color = freezed,
    Object? direction = freezed,
    Object? stops = null,
    Object? firstBus = freezed,
    Object? lastBus = freezed,
    Object? interval = freezed,
  }) {
    return _then(_$BusRouteImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      shortName: freezed == shortName
          ? _value.shortName
          : shortName // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      direction: freezed == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as String?,
      stops: null == stops
          ? _value._stops
          : stops // ignore: cast_nullable_to_non_nullable
              as List<BusStop>,
      firstBus: freezed == firstBus
          ? _value.firstBus
          : firstBus // ignore: cast_nullable_to_non_nullable
              as String?,
      lastBus: freezed == lastBus
          ? _value.lastBus
          : lastBus // ignore: cast_nullable_to_non_nullable
              as String?,
      interval: freezed == interval
          ? _value.interval
          : interval // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BusRouteImpl implements _BusRoute {
  const _$BusRouteImpl(
      {required this.id,
      required this.name,
      this.shortName,
      this.color,
      this.direction,
      final List<BusStop> stops = const [],
      this.firstBus,
      this.lastBus,
      this.interval})
      : _stops = stops;

  factory _$BusRouteImpl.fromJson(Map<String, dynamic> json) =>
      _$$BusRouteImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? shortName;
  @override
  final String? color;
  @override
  final String? direction;
// go, return
  final List<BusStop> _stops;
// go, return
  @override
  @JsonKey()
  List<BusStop> get stops {
    if (_stops is EqualUnmodifiableListView) return _stops;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stops);
  }

  @override
  final String? firstBus;
  @override
  final String? lastBus;
  @override
  final int? interval;

  @override
  String toString() {
    return 'BusRoute(id: $id, name: $name, shortName: $shortName, color: $color, direction: $direction, stops: $stops, firstBus: $firstBus, lastBus: $lastBus, interval: $interval)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusRouteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.shortName, shortName) ||
                other.shortName == shortName) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            const DeepCollectionEquality().equals(other._stops, _stops) &&
            (identical(other.firstBus, firstBus) ||
                other.firstBus == firstBus) &&
            (identical(other.lastBus, lastBus) || other.lastBus == lastBus) &&
            (identical(other.interval, interval) ||
                other.interval == interval));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      shortName,
      color,
      direction,
      const DeepCollectionEquality().hash(_stops),
      firstBus,
      lastBus,
      interval);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BusRouteImplCopyWith<_$BusRouteImpl> get copyWith =>
      __$$BusRouteImplCopyWithImpl<_$BusRouteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BusRouteImplToJson(
      this,
    );
  }
}

abstract class _BusRoute implements BusRoute {
  const factory _BusRoute(
      {required final String id,
      required final String name,
      final String? shortName,
      final String? color,
      final String? direction,
      final List<BusStop> stops,
      final String? firstBus,
      final String? lastBus,
      final int? interval}) = _$BusRouteImpl;

  factory _BusRoute.fromJson(Map<String, dynamic> json) =
      _$BusRouteImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get shortName;
  @override
  String? get color;
  @override
  String? get direction;
  @override // go, return
  List<BusStop> get stops;
  @override
  String? get firstBus;
  @override
  String? get lastBus;
  @override
  int? get interval;
  @override
  @JsonKey(ignore: true)
  _$$BusRouteImplCopyWith<_$BusRouteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BusStop _$BusStopFromJson(Map<String, dynamic> json) {
  return _BusStop.fromJson(json);
}

/// @nodoc
mixin _$BusStop {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get sequence => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  bool get isMain => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BusStopCopyWith<BusStop> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusStopCopyWith<$Res> {
  factory $BusStopCopyWith(BusStop value, $Res Function(BusStop) then) =
      _$BusStopCopyWithImpl<$Res, BusStop>;
  @useResult
  $Res call(
      {String id,
      String name,
      int sequence,
      double? latitude,
      double? longitude,
      bool isMain,
      String? address});
}

/// @nodoc
class _$BusStopCopyWithImpl<$Res, $Val extends BusStop>
    implements $BusStopCopyWith<$Res> {
  _$BusStopCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? sequence = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? isMain = null,
    Object? address = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sequence: null == sequence
          ? _value.sequence
          : sequence // ignore: cast_nullable_to_non_nullable
              as int,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      isMain: null == isMain
          ? _value.isMain
          : isMain // ignore: cast_nullable_to_non_nullable
              as bool,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BusStopImplCopyWith<$Res> implements $BusStopCopyWith<$Res> {
  factory _$$BusStopImplCopyWith(
          _$BusStopImpl value, $Res Function(_$BusStopImpl) then) =
      __$$BusStopImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      int sequence,
      double? latitude,
      double? longitude,
      bool isMain,
      String? address});
}

/// @nodoc
class __$$BusStopImplCopyWithImpl<$Res>
    extends _$BusStopCopyWithImpl<$Res, _$BusStopImpl>
    implements _$$BusStopImplCopyWith<$Res> {
  __$$BusStopImplCopyWithImpl(
      _$BusStopImpl _value, $Res Function(_$BusStopImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? sequence = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? isMain = null,
    Object? address = freezed,
  }) {
    return _then(_$BusStopImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sequence: null == sequence
          ? _value.sequence
          : sequence // ignore: cast_nullable_to_non_nullable
              as int,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      isMain: null == isMain
          ? _value.isMain
          : isMain // ignore: cast_nullable_to_non_nullable
              as bool,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BusStopImpl implements _BusStop {
  const _$BusStopImpl(
      {required this.id,
      required this.name,
      required this.sequence,
      this.latitude,
      this.longitude,
      this.isMain = false,
      this.address});

  factory _$BusStopImpl.fromJson(Map<String, dynamic> json) =>
      _$$BusStopImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final int sequence;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  @JsonKey()
  final bool isMain;
  @override
  final String? address;

  @override
  String toString() {
    return 'BusStop(id: $id, name: $name, sequence: $sequence, latitude: $latitude, longitude: $longitude, isMain: $isMain, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusStopImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sequence, sequence) ||
                other.sequence == sequence) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.isMain, isMain) || other.isMain == isMain) &&
            (identical(other.address, address) || other.address == address));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, sequence, latitude, longitude, isMain, address);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BusStopImplCopyWith<_$BusStopImpl> get copyWith =>
      __$$BusStopImplCopyWithImpl<_$BusStopImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BusStopImplToJson(
      this,
    );
  }
}

abstract class _BusStop implements BusStop {
  const factory _BusStop(
      {required final String id,
      required final String name,
      required final int sequence,
      final double? latitude,
      final double? longitude,
      final bool isMain,
      final String? address}) = _$BusStopImpl;

  factory _BusStop.fromJson(Map<String, dynamic> json) = _$BusStopImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  int get sequence;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  bool get isMain;
  @override
  String? get address;
  @override
  @JsonKey(ignore: true)
  _$$BusStopImplCopyWith<_$BusStopImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BusRealtime _$BusRealtimeFromJson(Map<String, dynamic> json) {
  return _BusRealtime.fromJson(json);
}

/// @nodoc
mixin _$BusRealtime {
  String get routeId => throw _privateConstructorUsedError;
  String get stopId => throw _privateConstructorUsedError;
  String get stopName => throw _privateConstructorUsedError;
  int? get estimateTime => throw _privateConstructorUsedError; // 秒
  int? get distance => throw _privateConstructorUsedError; // 公尺
  String? get busPlate => throw _privateConstructorUsedError;
  String? get direction => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;
  bool get isArriving => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BusRealtimeCopyWith<BusRealtime> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusRealtimeCopyWith<$Res> {
  factory $BusRealtimeCopyWith(
          BusRealtime value, $Res Function(BusRealtime) then) =
      _$BusRealtimeCopyWithImpl<$Res, BusRealtime>;
  @useResult
  $Res call(
      {String routeId,
      String stopId,
      String stopName,
      int? estimateTime,
      int? distance,
      String? busPlate,
      String? direction,
      String? updatedAt,
      bool isArriving});
}

/// @nodoc
class _$BusRealtimeCopyWithImpl<$Res, $Val extends BusRealtime>
    implements $BusRealtimeCopyWith<$Res> {
  _$BusRealtimeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? routeId = null,
    Object? stopId = null,
    Object? stopName = null,
    Object? estimateTime = freezed,
    Object? distance = freezed,
    Object? busPlate = freezed,
    Object? direction = freezed,
    Object? updatedAt = freezed,
    Object? isArriving = null,
  }) {
    return _then(_value.copyWith(
      routeId: null == routeId
          ? _value.routeId
          : routeId // ignore: cast_nullable_to_non_nullable
              as String,
      stopId: null == stopId
          ? _value.stopId
          : stopId // ignore: cast_nullable_to_non_nullable
              as String,
      stopName: null == stopName
          ? _value.stopName
          : stopName // ignore: cast_nullable_to_non_nullable
              as String,
      estimateTime: freezed == estimateTime
          ? _value.estimateTime
          : estimateTime // ignore: cast_nullable_to_non_nullable
              as int?,
      distance: freezed == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as int?,
      busPlate: freezed == busPlate
          ? _value.busPlate
          : busPlate // ignore: cast_nullable_to_non_nullable
              as String?,
      direction: freezed == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      isArriving: null == isArriving
          ? _value.isArriving
          : isArriving // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BusRealtimeImplCopyWith<$Res>
    implements $BusRealtimeCopyWith<$Res> {
  factory _$$BusRealtimeImplCopyWith(
          _$BusRealtimeImpl value, $Res Function(_$BusRealtimeImpl) then) =
      __$$BusRealtimeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String routeId,
      String stopId,
      String stopName,
      int? estimateTime,
      int? distance,
      String? busPlate,
      String? direction,
      String? updatedAt,
      bool isArriving});
}

/// @nodoc
class __$$BusRealtimeImplCopyWithImpl<$Res>
    extends _$BusRealtimeCopyWithImpl<$Res, _$BusRealtimeImpl>
    implements _$$BusRealtimeImplCopyWith<$Res> {
  __$$BusRealtimeImplCopyWithImpl(
      _$BusRealtimeImpl _value, $Res Function(_$BusRealtimeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? routeId = null,
    Object? stopId = null,
    Object? stopName = null,
    Object? estimateTime = freezed,
    Object? distance = freezed,
    Object? busPlate = freezed,
    Object? direction = freezed,
    Object? updatedAt = freezed,
    Object? isArriving = null,
  }) {
    return _then(_$BusRealtimeImpl(
      routeId: null == routeId
          ? _value.routeId
          : routeId // ignore: cast_nullable_to_non_nullable
              as String,
      stopId: null == stopId
          ? _value.stopId
          : stopId // ignore: cast_nullable_to_non_nullable
              as String,
      stopName: null == stopName
          ? _value.stopName
          : stopName // ignore: cast_nullable_to_non_nullable
              as String,
      estimateTime: freezed == estimateTime
          ? _value.estimateTime
          : estimateTime // ignore: cast_nullable_to_non_nullable
              as int?,
      distance: freezed == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as int?,
      busPlate: freezed == busPlate
          ? _value.busPlate
          : busPlate // ignore: cast_nullable_to_non_nullable
              as String?,
      direction: freezed == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      isArriving: null == isArriving
          ? _value.isArriving
          : isArriving // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BusRealtimeImpl implements _BusRealtime {
  const _$BusRealtimeImpl(
      {required this.routeId,
      required this.stopId,
      required this.stopName,
      this.estimateTime,
      this.distance,
      this.busPlate,
      this.direction,
      this.updatedAt,
      this.isArriving = false});

  factory _$BusRealtimeImpl.fromJson(Map<String, dynamic> json) =>
      _$$BusRealtimeImplFromJson(json);

  @override
  final String routeId;
  @override
  final String stopId;
  @override
  final String stopName;
  @override
  final int? estimateTime;
// 秒
  @override
  final int? distance;
// 公尺
  @override
  final String? busPlate;
  @override
  final String? direction;
  @override
  final String? updatedAt;
  @override
  @JsonKey()
  final bool isArriving;

  @override
  String toString() {
    return 'BusRealtime(routeId: $routeId, stopId: $stopId, stopName: $stopName, estimateTime: $estimateTime, distance: $distance, busPlate: $busPlate, direction: $direction, updatedAt: $updatedAt, isArriving: $isArriving)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusRealtimeImpl &&
            (identical(other.routeId, routeId) || other.routeId == routeId) &&
            (identical(other.stopId, stopId) || other.stopId == stopId) &&
            (identical(other.stopName, stopName) ||
                other.stopName == stopName) &&
            (identical(other.estimateTime, estimateTime) ||
                other.estimateTime == estimateTime) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.busPlate, busPlate) ||
                other.busPlate == busPlate) &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isArriving, isArriving) ||
                other.isArriving == isArriving));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, routeId, stopId, stopName,
      estimateTime, distance, busPlate, direction, updatedAt, isArriving);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BusRealtimeImplCopyWith<_$BusRealtimeImpl> get copyWith =>
      __$$BusRealtimeImplCopyWithImpl<_$BusRealtimeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BusRealtimeImplToJson(
      this,
    );
  }
}

abstract class _BusRealtime implements BusRealtime {
  const factory _BusRealtime(
      {required final String routeId,
      required final String stopId,
      required final String stopName,
      final int? estimateTime,
      final int? distance,
      final String? busPlate,
      final String? direction,
      final String? updatedAt,
      final bool isArriving}) = _$BusRealtimeImpl;

  factory _BusRealtime.fromJson(Map<String, dynamic> json) =
      _$BusRealtimeImpl.fromJson;

  @override
  String get routeId;
  @override
  String get stopId;
  @override
  String get stopName;
  @override
  int? get estimateTime;
  @override // 秒
  int? get distance;
  @override // 公尺
  String? get busPlate;
  @override
  String? get direction;
  @override
  String? get updatedAt;
  @override
  bool get isArriving;
  @override
  @JsonKey(ignore: true)
  _$$BusRealtimeImplCopyWith<_$BusRealtimeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BusRouteResponse _$BusRouteResponseFromJson(Map<String, dynamic> json) {
  return _BusRouteResponse.fromJson(json);
}

/// @nodoc
mixin _$BusRouteResponse {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  List<dynamic> get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BusRouteResponseCopyWith<BusRouteResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusRouteResponseCopyWith<$Res> {
  factory $BusRouteResponseCopyWith(
          BusRouteResponse value, $Res Function(BusRouteResponse) then) =
      _$BusRouteResponseCopyWithImpl<$Res, BusRouteResponse>;
  @useResult
  $Res call({bool success, String message, List<dynamic> data});
}

/// @nodoc
class _$BusRouteResponseCopyWithImpl<$Res, $Val extends BusRouteResponse>
    implements $BusRouteResponseCopyWith<$Res> {
  _$BusRouteResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BusRouteResponseImplCopyWith<$Res>
    implements $BusRouteResponseCopyWith<$Res> {
  factory _$$BusRouteResponseImplCopyWith(_$BusRouteResponseImpl value,
          $Res Function(_$BusRouteResponseImpl) then) =
      __$$BusRouteResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, String message, List<dynamic> data});
}

/// @nodoc
class __$$BusRouteResponseImplCopyWithImpl<$Res>
    extends _$BusRouteResponseCopyWithImpl<$Res, _$BusRouteResponseImpl>
    implements _$$BusRouteResponseImplCopyWith<$Res> {
  __$$BusRouteResponseImplCopyWithImpl(_$BusRouteResponseImpl _value,
      $Res Function(_$BusRouteResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = null,
  }) {
    return _then(_$BusRouteResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BusRouteResponseImpl implements _BusRouteResponse {
  const _$BusRouteResponseImpl(
      {required this.success,
      required this.message,
      final List<dynamic> data = const []})
      : _data = data;

  factory _$BusRouteResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$BusRouteResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  final List<dynamic> _data;
  @override
  @JsonKey()
  List<dynamic> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'BusRouteResponse(success: $success, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusRouteResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, message,
      const DeepCollectionEquality().hash(_data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BusRouteResponseImplCopyWith<_$BusRouteResponseImpl> get copyWith =>
      __$$BusRouteResponseImplCopyWithImpl<_$BusRouteResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BusRouteResponseImplToJson(
      this,
    );
  }
}

abstract class _BusRouteResponse implements BusRouteResponse {
  const factory _BusRouteResponse(
      {required final bool success,
      required final String message,
      final List<dynamic> data}) = _$BusRouteResponseImpl;

  factory _BusRouteResponse.fromJson(Map<String, dynamic> json) =
      _$BusRouteResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  List<dynamic> get data;
  @override
  @JsonKey(ignore: true)
  _$$BusRouteResponseImplCopyWith<_$BusRouteResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BusRealtimeResponse _$BusRealtimeResponseFromJson(Map<String, dynamic> json) {
  return _BusRealtimeResponse.fromJson(json);
}

/// @nodoc
mixin _$BusRealtimeResponse {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  List<dynamic> get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BusRealtimeResponseCopyWith<BusRealtimeResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusRealtimeResponseCopyWith<$Res> {
  factory $BusRealtimeResponseCopyWith(
          BusRealtimeResponse value, $Res Function(BusRealtimeResponse) then) =
      _$BusRealtimeResponseCopyWithImpl<$Res, BusRealtimeResponse>;
  @useResult
  $Res call({bool success, String message, List<dynamic> data});
}

/// @nodoc
class _$BusRealtimeResponseCopyWithImpl<$Res, $Val extends BusRealtimeResponse>
    implements $BusRealtimeResponseCopyWith<$Res> {
  _$BusRealtimeResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BusRealtimeResponseImplCopyWith<$Res>
    implements $BusRealtimeResponseCopyWith<$Res> {
  factory _$$BusRealtimeResponseImplCopyWith(_$BusRealtimeResponseImpl value,
          $Res Function(_$BusRealtimeResponseImpl) then) =
      __$$BusRealtimeResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, String message, List<dynamic> data});
}

/// @nodoc
class __$$BusRealtimeResponseImplCopyWithImpl<$Res>
    extends _$BusRealtimeResponseCopyWithImpl<$Res, _$BusRealtimeResponseImpl>
    implements _$$BusRealtimeResponseImplCopyWith<$Res> {
  __$$BusRealtimeResponseImplCopyWithImpl(_$BusRealtimeResponseImpl _value,
      $Res Function(_$BusRealtimeResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = null,
  }) {
    return _then(_$BusRealtimeResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BusRealtimeResponseImpl implements _BusRealtimeResponse {
  const _$BusRealtimeResponseImpl(
      {required this.success,
      required this.message,
      final List<dynamic> data = const []})
      : _data = data;

  factory _$BusRealtimeResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$BusRealtimeResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  final List<dynamic> _data;
  @override
  @JsonKey()
  List<dynamic> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'BusRealtimeResponse(success: $success, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusRealtimeResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, message,
      const DeepCollectionEquality().hash(_data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BusRealtimeResponseImplCopyWith<_$BusRealtimeResponseImpl> get copyWith =>
      __$$BusRealtimeResponseImplCopyWithImpl<_$BusRealtimeResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BusRealtimeResponseImplToJson(
      this,
    );
  }
}

abstract class _BusRealtimeResponse implements BusRealtimeResponse {
  const factory _BusRealtimeResponse(
      {required final bool success,
      required final String message,
      final List<dynamic> data}) = _$BusRealtimeResponseImpl;

  factory _BusRealtimeResponse.fromJson(Map<String, dynamic> json) =
      _$BusRealtimeResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  List<dynamic> get data;
  @override
  @JsonKey(ignore: true)
  _$$BusRealtimeResponseImplCopyWith<_$BusRealtimeResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BusStopResponse _$BusStopResponseFromJson(Map<String, dynamic> json) {
  return _BusStopResponse.fromJson(json);
}

/// @nodoc
mixin _$BusStopResponse {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  List<BusStop> get stops => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BusStopResponseCopyWith<BusStopResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusStopResponseCopyWith<$Res> {
  factory $BusStopResponseCopyWith(
          BusStopResponse value, $Res Function(BusStopResponse) then) =
      _$BusStopResponseCopyWithImpl<$Res, BusStopResponse>;
  @useResult
  $Res call({bool success, String message, List<BusStop> stops});
}

/// @nodoc
class _$BusStopResponseCopyWithImpl<$Res, $Val extends BusStopResponse>
    implements $BusStopResponseCopyWith<$Res> {
  _$BusStopResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? stops = null,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      stops: null == stops
          ? _value.stops
          : stops // ignore: cast_nullable_to_non_nullable
              as List<BusStop>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BusStopResponseImplCopyWith<$Res>
    implements $BusStopResponseCopyWith<$Res> {
  factory _$$BusStopResponseImplCopyWith(_$BusStopResponseImpl value,
          $Res Function(_$BusStopResponseImpl) then) =
      __$$BusStopResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, String message, List<BusStop> stops});
}

/// @nodoc
class __$$BusStopResponseImplCopyWithImpl<$Res>
    extends _$BusStopResponseCopyWithImpl<$Res, _$BusStopResponseImpl>
    implements _$$BusStopResponseImplCopyWith<$Res> {
  __$$BusStopResponseImplCopyWithImpl(
      _$BusStopResponseImpl _value, $Res Function(_$BusStopResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? stops = null,
  }) {
    return _then(_$BusStopResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      stops: null == stops
          ? _value._stops
          : stops // ignore: cast_nullable_to_non_nullable
              as List<BusStop>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BusStopResponseImpl implements _BusStopResponse {
  const _$BusStopResponseImpl(
      {required this.success,
      required this.message,
      final List<BusStop> stops = const []})
      : _stops = stops;

  factory _$BusStopResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$BusStopResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  final List<BusStop> _stops;
  @override
  @JsonKey()
  List<BusStop> get stops {
    if (_stops is EqualUnmodifiableListView) return _stops;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stops);
  }

  @override
  String toString() {
    return 'BusStopResponse(success: $success, message: $message, stops: $stops)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusStopResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._stops, _stops));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, message,
      const DeepCollectionEquality().hash(_stops));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BusStopResponseImplCopyWith<_$BusStopResponseImpl> get copyWith =>
      __$$BusStopResponseImplCopyWithImpl<_$BusStopResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BusStopResponseImplToJson(
      this,
    );
  }
}

abstract class _BusStopResponse implements BusStopResponse {
  const factory _BusStopResponse(
      {required final bool success,
      required final String message,
      final List<BusStop> stops}) = _$BusStopResponseImpl;

  factory _BusStopResponse.fromJson(Map<String, dynamic> json) =
      _$BusStopResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  List<BusStop> get stops;
  @override
  @JsonKey(ignore: true)
  _$$BusStopResponseImplCopyWith<_$BusStopResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BikeStation _$BikeStationFromJson(Map<String, dynamic> json) {
  return _BikeStation.fromJson(json);
}

/// @nodoc
mixin _$BikeStation {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  int get totalDocks => throw _privateConstructorUsedError;
  int get availableBikes => throw _privateConstructorUsedError;
  int get availableDocks => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get status =>
      throw _privateConstructorUsedError; // normal, maintenance, closed
  String? get updatedAt => throw _privateConstructorUsedError;
  String? get area => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BikeStationCopyWith<BikeStation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BikeStationCopyWith<$Res> {
  factory $BikeStationCopyWith(
          BikeStation value, $Res Function(BikeStation) then) =
      _$BikeStationCopyWithImpl<$Res, BikeStation>;
  @useResult
  $Res call(
      {String id,
      String name,
      double latitude,
      double longitude,
      int totalDocks,
      int availableBikes,
      int availableDocks,
      String? address,
      String? status,
      String? updatedAt,
      String? area});
}

/// @nodoc
class _$BikeStationCopyWithImpl<$Res, $Val extends BikeStation>
    implements $BikeStationCopyWith<$Res> {
  _$BikeStationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? totalDocks = null,
    Object? availableBikes = null,
    Object? availableDocks = null,
    Object? address = freezed,
    Object? status = freezed,
    Object? updatedAt = freezed,
    Object? area = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      totalDocks: null == totalDocks
          ? _value.totalDocks
          : totalDocks // ignore: cast_nullable_to_non_nullable
              as int,
      availableBikes: null == availableBikes
          ? _value.availableBikes
          : availableBikes // ignore: cast_nullable_to_non_nullable
              as int,
      availableDocks: null == availableDocks
          ? _value.availableDocks
          : availableDocks // ignore: cast_nullable_to_non_nullable
              as int,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      area: freezed == area
          ? _value.area
          : area // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BikeStationImplCopyWith<$Res>
    implements $BikeStationCopyWith<$Res> {
  factory _$$BikeStationImplCopyWith(
          _$BikeStationImpl value, $Res Function(_$BikeStationImpl) then) =
      __$$BikeStationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      double latitude,
      double longitude,
      int totalDocks,
      int availableBikes,
      int availableDocks,
      String? address,
      String? status,
      String? updatedAt,
      String? area});
}

/// @nodoc
class __$$BikeStationImplCopyWithImpl<$Res>
    extends _$BikeStationCopyWithImpl<$Res, _$BikeStationImpl>
    implements _$$BikeStationImplCopyWith<$Res> {
  __$$BikeStationImplCopyWithImpl(
      _$BikeStationImpl _value, $Res Function(_$BikeStationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? totalDocks = null,
    Object? availableBikes = null,
    Object? availableDocks = null,
    Object? address = freezed,
    Object? status = freezed,
    Object? updatedAt = freezed,
    Object? area = freezed,
  }) {
    return _then(_$BikeStationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      totalDocks: null == totalDocks
          ? _value.totalDocks
          : totalDocks // ignore: cast_nullable_to_non_nullable
              as int,
      availableBikes: null == availableBikes
          ? _value.availableBikes
          : availableBikes // ignore: cast_nullable_to_non_nullable
              as int,
      availableDocks: null == availableDocks
          ? _value.availableDocks
          : availableDocks // ignore: cast_nullable_to_non_nullable
              as int,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      area: freezed == area
          ? _value.area
          : area // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BikeStationImpl implements _BikeStation {
  const _$BikeStationImpl(
      {required this.id,
      required this.name,
      required this.latitude,
      required this.longitude,
      required this.totalDocks,
      required this.availableBikes,
      required this.availableDocks,
      this.address,
      this.status,
      this.updatedAt,
      this.area});

  factory _$BikeStationImpl.fromJson(Map<String, dynamic> json) =>
      _$$BikeStationImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final int totalDocks;
  @override
  final int availableBikes;
  @override
  final int availableDocks;
  @override
  final String? address;
  @override
  final String? status;
// normal, maintenance, closed
  @override
  final String? updatedAt;
  @override
  final String? area;

  @override
  String toString() {
    return 'BikeStation(id: $id, name: $name, latitude: $latitude, longitude: $longitude, totalDocks: $totalDocks, availableBikes: $availableBikes, availableDocks: $availableDocks, address: $address, status: $status, updatedAt: $updatedAt, area: $area)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BikeStationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.totalDocks, totalDocks) ||
                other.totalDocks == totalDocks) &&
            (identical(other.availableBikes, availableBikes) ||
                other.availableBikes == availableBikes) &&
            (identical(other.availableDocks, availableDocks) ||
                other.availableDocks == availableDocks) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.area, area) || other.area == area));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      latitude,
      longitude,
      totalDocks,
      availableBikes,
      availableDocks,
      address,
      status,
      updatedAt,
      area);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BikeStationImplCopyWith<_$BikeStationImpl> get copyWith =>
      __$$BikeStationImplCopyWithImpl<_$BikeStationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BikeStationImplToJson(
      this,
    );
  }
}

abstract class _BikeStation implements BikeStation {
  const factory _BikeStation(
      {required final String id,
      required final String name,
      required final double latitude,
      required final double longitude,
      required final int totalDocks,
      required final int availableBikes,
      required final int availableDocks,
      final String? address,
      final String? status,
      final String? updatedAt,
      final String? area}) = _$BikeStationImpl;

  factory _BikeStation.fromJson(Map<String, dynamic> json) =
      _$BikeStationImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  int get totalDocks;
  @override
  int get availableBikes;
  @override
  int get availableDocks;
  @override
  String? get address;
  @override
  String? get status;
  @override // normal, maintenance, closed
  String? get updatedAt;
  @override
  String? get area;
  @override
  @JsonKey(ignore: true)
  _$$BikeStationImplCopyWith<_$BikeStationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BikeStationResponse _$BikeStationResponseFromJson(Map<String, dynamic> json) {
  return _BikeStationResponse.fromJson(json);
}

/// @nodoc
mixin _$BikeStationResponse {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  List<dynamic> get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BikeStationResponseCopyWith<BikeStationResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BikeStationResponseCopyWith<$Res> {
  factory $BikeStationResponseCopyWith(
          BikeStationResponse value, $Res Function(BikeStationResponse) then) =
      _$BikeStationResponseCopyWithImpl<$Res, BikeStationResponse>;
  @useResult
  $Res call({bool success, String message, List<dynamic> data});
}

/// @nodoc
class _$BikeStationResponseCopyWithImpl<$Res, $Val extends BikeStationResponse>
    implements $BikeStationResponseCopyWith<$Res> {
  _$BikeStationResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BikeStationResponseImplCopyWith<$Res>
    implements $BikeStationResponseCopyWith<$Res> {
  factory _$$BikeStationResponseImplCopyWith(_$BikeStationResponseImpl value,
          $Res Function(_$BikeStationResponseImpl) then) =
      __$$BikeStationResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, String message, List<dynamic> data});
}

/// @nodoc
class __$$BikeStationResponseImplCopyWithImpl<$Res>
    extends _$BikeStationResponseCopyWithImpl<$Res, _$BikeStationResponseImpl>
    implements _$$BikeStationResponseImplCopyWith<$Res> {
  __$$BikeStationResponseImplCopyWithImpl(_$BikeStationResponseImpl _value,
      $Res Function(_$BikeStationResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = null,
  }) {
    return _then(_$BikeStationResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BikeStationResponseImpl implements _BikeStationResponse {
  const _$BikeStationResponseImpl(
      {required this.success,
      required this.message,
      final List<dynamic> data = const []})
      : _data = data;

  factory _$BikeStationResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$BikeStationResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  final List<dynamic> _data;
  @override
  @JsonKey()
  List<dynamic> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'BikeStationResponse(success: $success, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BikeStationResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, message,
      const DeepCollectionEquality().hash(_data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BikeStationResponseImplCopyWith<_$BikeStationResponseImpl> get copyWith =>
      __$$BikeStationResponseImplCopyWithImpl<_$BikeStationResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BikeStationResponseImplToJson(
      this,
    );
  }
}

abstract class _BikeStationResponse implements BikeStationResponse {
  const factory _BikeStationResponse(
      {required final bool success,
      required final String message,
      final List<dynamic> data}) = _$BikeStationResponseImpl;

  factory _BikeStationResponse.fromJson(Map<String, dynamic> json) =
      _$BikeStationResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  List<dynamic> get data;
  @override
  @JsonKey(ignore: true)
  _$$BikeStationResponseImplCopyWith<_$BikeStationResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrafficInfo _$TrafficInfoFromJson(Map<String, dynamic> json) {
  return _TrafficInfo.fromJson(json);
}

/// @nodoc
mixin _$TrafficInfo {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get type =>
      throw _privateConstructorUsedError; // roadwork, accident, control, event
  String? get location => throw _privateConstructorUsedError;
  String? get startTime => throw _privateConstructorUsedError;
  String? get endTime => throw _privateConstructorUsedError;
  String? get severity =>
      throw _privateConstructorUsedError; // low, medium, high
  String? get source => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrafficInfoCopyWith<TrafficInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrafficInfoCopyWith<$Res> {
  factory $TrafficInfoCopyWith(
          TrafficInfo value, $Res Function(TrafficInfo) then) =
      _$TrafficInfoCopyWithImpl<$Res, TrafficInfo>;
  @useResult
  $Res call(
      {String id,
      String title,
      String? description,
      String? type,
      String? location,
      String? startTime,
      String? endTime,
      String? severity,
      String? source,
      String? updatedAt});
}

/// @nodoc
class _$TrafficInfoCopyWithImpl<$Res, $Val extends TrafficInfo>
    implements $TrafficInfoCopyWith<$Res> {
  _$TrafficInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? type = freezed,
    Object? location = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? severity = freezed,
    Object? source = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String?,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String?,
      severity: freezed == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String?,
      source: freezed == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrafficInfoImplCopyWith<$Res>
    implements $TrafficInfoCopyWith<$Res> {
  factory _$$TrafficInfoImplCopyWith(
          _$TrafficInfoImpl value, $Res Function(_$TrafficInfoImpl) then) =
      __$$TrafficInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String? description,
      String? type,
      String? location,
      String? startTime,
      String? endTime,
      String? severity,
      String? source,
      String? updatedAt});
}

/// @nodoc
class __$$TrafficInfoImplCopyWithImpl<$Res>
    extends _$TrafficInfoCopyWithImpl<$Res, _$TrafficInfoImpl>
    implements _$$TrafficInfoImplCopyWith<$Res> {
  __$$TrafficInfoImplCopyWithImpl(
      _$TrafficInfoImpl _value, $Res Function(_$TrafficInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? type = freezed,
    Object? location = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? severity = freezed,
    Object? source = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$TrafficInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String?,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String?,
      severity: freezed == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String?,
      source: freezed == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrafficInfoImpl implements _TrafficInfo {
  const _$TrafficInfoImpl(
      {required this.id,
      required this.title,
      this.description,
      this.type,
      this.location,
      this.startTime,
      this.endTime,
      this.severity,
      this.source,
      this.updatedAt});

  factory _$TrafficInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrafficInfoImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String? type;
// roadwork, accident, control, event
  @override
  final String? location;
  @override
  final String? startTime;
  @override
  final String? endTime;
  @override
  final String? severity;
// low, medium, high
  @override
  final String? source;
  @override
  final String? updatedAt;

  @override
  String toString() {
    return 'TrafficInfo(id: $id, title: $title, description: $description, type: $type, location: $location, startTime: $startTime, endTime: $endTime, severity: $severity, source: $source, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrafficInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, description, type,
      location, startTime, endTime, severity, source, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrafficInfoImplCopyWith<_$TrafficInfoImpl> get copyWith =>
      __$$TrafficInfoImplCopyWithImpl<_$TrafficInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrafficInfoImplToJson(
      this,
    );
  }
}

abstract class _TrafficInfo implements TrafficInfo {
  const factory _TrafficInfo(
      {required final String id,
      required final String title,
      final String? description,
      final String? type,
      final String? location,
      final String? startTime,
      final String? endTime,
      final String? severity,
      final String? source,
      final String? updatedAt}) = _$TrafficInfoImpl;

  factory _TrafficInfo.fromJson(Map<String, dynamic> json) =
      _$TrafficInfoImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get description;
  @override
  String? get type;
  @override // roadwork, accident, control, event
  String? get location;
  @override
  String? get startTime;
  @override
  String? get endTime;
  @override
  String? get severity;
  @override // low, medium, high
  String? get source;
  @override
  String? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$TrafficInfoImplCopyWith<_$TrafficInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrafficInfoResponse _$TrafficInfoResponseFromJson(Map<String, dynamic> json) {
  return _TrafficInfoResponse.fromJson(json);
}

/// @nodoc
mixin _$TrafficInfoResponse {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  List<dynamic> get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrafficInfoResponseCopyWith<TrafficInfoResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrafficInfoResponseCopyWith<$Res> {
  factory $TrafficInfoResponseCopyWith(
          TrafficInfoResponse value, $Res Function(TrafficInfoResponse) then) =
      _$TrafficInfoResponseCopyWithImpl<$Res, TrafficInfoResponse>;
  @useResult
  $Res call({bool success, String message, List<dynamic> data});
}

/// @nodoc
class _$TrafficInfoResponseCopyWithImpl<$Res, $Val extends TrafficInfoResponse>
    implements $TrafficInfoResponseCopyWith<$Res> {
  _$TrafficInfoResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrafficInfoResponseImplCopyWith<$Res>
    implements $TrafficInfoResponseCopyWith<$Res> {
  factory _$$TrafficInfoResponseImplCopyWith(_$TrafficInfoResponseImpl value,
          $Res Function(_$TrafficInfoResponseImpl) then) =
      __$$TrafficInfoResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, String message, List<dynamic> data});
}

/// @nodoc
class __$$TrafficInfoResponseImplCopyWithImpl<$Res>
    extends _$TrafficInfoResponseCopyWithImpl<$Res, _$TrafficInfoResponseImpl>
    implements _$$TrafficInfoResponseImplCopyWith<$Res> {
  __$$TrafficInfoResponseImplCopyWithImpl(_$TrafficInfoResponseImpl _value,
      $Res Function(_$TrafficInfoResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = null,
  }) {
    return _then(_$TrafficInfoResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrafficInfoResponseImpl implements _TrafficInfoResponse {
  const _$TrafficInfoResponseImpl(
      {required this.success,
      required this.message,
      final List<dynamic> data = const []})
      : _data = data;

  factory _$TrafficInfoResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrafficInfoResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  final List<dynamic> _data;
  @override
  @JsonKey()
  List<dynamic> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'TrafficInfoResponse(success: $success, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrafficInfoResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, message,
      const DeepCollectionEquality().hash(_data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrafficInfoResponseImplCopyWith<_$TrafficInfoResponseImpl> get copyWith =>
      __$$TrafficInfoResponseImplCopyWithImpl<_$TrafficInfoResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrafficInfoResponseImplToJson(
      this,
    );
  }
}

abstract class _TrafficInfoResponse implements TrafficInfoResponse {
  const factory _TrafficInfoResponse(
      {required final bool success,
      required final String message,
      final List<dynamic> data}) = _$TrafficInfoResponseImpl;

  factory _TrafficInfoResponse.fromJson(Map<String, dynamic> json) =
      _$TrafficInfoResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  List<dynamic> get data;
  @override
  @JsonKey(ignore: true)
  _$$TrafficInfoResponseImplCopyWith<_$TrafficInfoResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TransportState {
  List<BusRoute> get busRoutes => throw _privateConstructorUsedError;
  List<BusRealtime> get busRealtime => throw _privateConstructorUsedError;
  List<BikeStation> get bikeStations => throw _privateConstructorUsedError;
  List<TrafficInfo> get trafficInfos => throw _privateConstructorUsedError;
  String? get selectedRouteId => throw _privateConstructorUsedError;
  String? get selectedStopId => throw _privateConstructorUsedError;
  bool get isLoadingRoutes => throw _privateConstructorUsedError;
  bool get isLoadingRealtime => throw _privateConstructorUsedError;
  bool get isLoadingBikes => throw _privateConstructorUsedError;
  bool get isLoadingTraffic => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TransportStateCopyWith<TransportState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransportStateCopyWith<$Res> {
  factory $TransportStateCopyWith(
          TransportState value, $Res Function(TransportState) then) =
      _$TransportStateCopyWithImpl<$Res, TransportState>;
  @useResult
  $Res call(
      {List<BusRoute> busRoutes,
      List<BusRealtime> busRealtime,
      List<BikeStation> bikeStations,
      List<TrafficInfo> trafficInfos,
      String? selectedRouteId,
      String? selectedStopId,
      bool isLoadingRoutes,
      bool isLoadingRealtime,
      bool isLoadingBikes,
      bool isLoadingTraffic,
      String? error});
}

/// @nodoc
class _$TransportStateCopyWithImpl<$Res, $Val extends TransportState>
    implements $TransportStateCopyWith<$Res> {
  _$TransportStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? busRoutes = null,
    Object? busRealtime = null,
    Object? bikeStations = null,
    Object? trafficInfos = null,
    Object? selectedRouteId = freezed,
    Object? selectedStopId = freezed,
    Object? isLoadingRoutes = null,
    Object? isLoadingRealtime = null,
    Object? isLoadingBikes = null,
    Object? isLoadingTraffic = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      busRoutes: null == busRoutes
          ? _value.busRoutes
          : busRoutes // ignore: cast_nullable_to_non_nullable
              as List<BusRoute>,
      busRealtime: null == busRealtime
          ? _value.busRealtime
          : busRealtime // ignore: cast_nullable_to_non_nullable
              as List<BusRealtime>,
      bikeStations: null == bikeStations
          ? _value.bikeStations
          : bikeStations // ignore: cast_nullable_to_non_nullable
              as List<BikeStation>,
      trafficInfos: null == trafficInfos
          ? _value.trafficInfos
          : trafficInfos // ignore: cast_nullable_to_non_nullable
              as List<TrafficInfo>,
      selectedRouteId: freezed == selectedRouteId
          ? _value.selectedRouteId
          : selectedRouteId // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedStopId: freezed == selectedStopId
          ? _value.selectedStopId
          : selectedStopId // ignore: cast_nullable_to_non_nullable
              as String?,
      isLoadingRoutes: null == isLoadingRoutes
          ? _value.isLoadingRoutes
          : isLoadingRoutes // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingRealtime: null == isLoadingRealtime
          ? _value.isLoadingRealtime
          : isLoadingRealtime // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingBikes: null == isLoadingBikes
          ? _value.isLoadingBikes
          : isLoadingBikes // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingTraffic: null == isLoadingTraffic
          ? _value.isLoadingTraffic
          : isLoadingTraffic // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransportStateImplCopyWith<$Res>
    implements $TransportStateCopyWith<$Res> {
  factory _$$TransportStateImplCopyWith(_$TransportStateImpl value,
          $Res Function(_$TransportStateImpl) then) =
      __$$TransportStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<BusRoute> busRoutes,
      List<BusRealtime> busRealtime,
      List<BikeStation> bikeStations,
      List<TrafficInfo> trafficInfos,
      String? selectedRouteId,
      String? selectedStopId,
      bool isLoadingRoutes,
      bool isLoadingRealtime,
      bool isLoadingBikes,
      bool isLoadingTraffic,
      String? error});
}

/// @nodoc
class __$$TransportStateImplCopyWithImpl<$Res>
    extends _$TransportStateCopyWithImpl<$Res, _$TransportStateImpl>
    implements _$$TransportStateImplCopyWith<$Res> {
  __$$TransportStateImplCopyWithImpl(
      _$TransportStateImpl _value, $Res Function(_$TransportStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? busRoutes = null,
    Object? busRealtime = null,
    Object? bikeStations = null,
    Object? trafficInfos = null,
    Object? selectedRouteId = freezed,
    Object? selectedStopId = freezed,
    Object? isLoadingRoutes = null,
    Object? isLoadingRealtime = null,
    Object? isLoadingBikes = null,
    Object? isLoadingTraffic = null,
    Object? error = freezed,
  }) {
    return _then(_$TransportStateImpl(
      busRoutes: null == busRoutes
          ? _value._busRoutes
          : busRoutes // ignore: cast_nullable_to_non_nullable
              as List<BusRoute>,
      busRealtime: null == busRealtime
          ? _value._busRealtime
          : busRealtime // ignore: cast_nullable_to_non_nullable
              as List<BusRealtime>,
      bikeStations: null == bikeStations
          ? _value._bikeStations
          : bikeStations // ignore: cast_nullable_to_non_nullable
              as List<BikeStation>,
      trafficInfos: null == trafficInfos
          ? _value._trafficInfos
          : trafficInfos // ignore: cast_nullable_to_non_nullable
              as List<TrafficInfo>,
      selectedRouteId: freezed == selectedRouteId
          ? _value.selectedRouteId
          : selectedRouteId // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedStopId: freezed == selectedStopId
          ? _value.selectedStopId
          : selectedStopId // ignore: cast_nullable_to_non_nullable
              as String?,
      isLoadingRoutes: null == isLoadingRoutes
          ? _value.isLoadingRoutes
          : isLoadingRoutes // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingRealtime: null == isLoadingRealtime
          ? _value.isLoadingRealtime
          : isLoadingRealtime // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingBikes: null == isLoadingBikes
          ? _value.isLoadingBikes
          : isLoadingBikes // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingTraffic: null == isLoadingTraffic
          ? _value.isLoadingTraffic
          : isLoadingTraffic // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$TransportStateImpl implements _TransportState {
  const _$TransportStateImpl(
      {final List<BusRoute> busRoutes = const [],
      final List<BusRealtime> busRealtime = const [],
      final List<BikeStation> bikeStations = const [],
      final List<TrafficInfo> trafficInfos = const [],
      this.selectedRouteId,
      this.selectedStopId,
      this.isLoadingRoutes = false,
      this.isLoadingRealtime = false,
      this.isLoadingBikes = false,
      this.isLoadingTraffic = false,
      this.error})
      : _busRoutes = busRoutes,
        _busRealtime = busRealtime,
        _bikeStations = bikeStations,
        _trafficInfos = trafficInfos;

  final List<BusRoute> _busRoutes;
  @override
  @JsonKey()
  List<BusRoute> get busRoutes {
    if (_busRoutes is EqualUnmodifiableListView) return _busRoutes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_busRoutes);
  }

  final List<BusRealtime> _busRealtime;
  @override
  @JsonKey()
  List<BusRealtime> get busRealtime {
    if (_busRealtime is EqualUnmodifiableListView) return _busRealtime;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_busRealtime);
  }

  final List<BikeStation> _bikeStations;
  @override
  @JsonKey()
  List<BikeStation> get bikeStations {
    if (_bikeStations is EqualUnmodifiableListView) return _bikeStations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bikeStations);
  }

  final List<TrafficInfo> _trafficInfos;
  @override
  @JsonKey()
  List<TrafficInfo> get trafficInfos {
    if (_trafficInfos is EqualUnmodifiableListView) return _trafficInfos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trafficInfos);
  }

  @override
  final String? selectedRouteId;
  @override
  final String? selectedStopId;
  @override
  @JsonKey()
  final bool isLoadingRoutes;
  @override
  @JsonKey()
  final bool isLoadingRealtime;
  @override
  @JsonKey()
  final bool isLoadingBikes;
  @override
  @JsonKey()
  final bool isLoadingTraffic;
  @override
  final String? error;

  @override
  String toString() {
    return 'TransportState(busRoutes: $busRoutes, busRealtime: $busRealtime, bikeStations: $bikeStations, trafficInfos: $trafficInfos, selectedRouteId: $selectedRouteId, selectedStopId: $selectedStopId, isLoadingRoutes: $isLoadingRoutes, isLoadingRealtime: $isLoadingRealtime, isLoadingBikes: $isLoadingBikes, isLoadingTraffic: $isLoadingTraffic, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransportStateImpl &&
            const DeepCollectionEquality()
                .equals(other._busRoutes, _busRoutes) &&
            const DeepCollectionEquality()
                .equals(other._busRealtime, _busRealtime) &&
            const DeepCollectionEquality()
                .equals(other._bikeStations, _bikeStations) &&
            const DeepCollectionEquality()
                .equals(other._trafficInfos, _trafficInfos) &&
            (identical(other.selectedRouteId, selectedRouteId) ||
                other.selectedRouteId == selectedRouteId) &&
            (identical(other.selectedStopId, selectedStopId) ||
                other.selectedStopId == selectedStopId) &&
            (identical(other.isLoadingRoutes, isLoadingRoutes) ||
                other.isLoadingRoutes == isLoadingRoutes) &&
            (identical(other.isLoadingRealtime, isLoadingRealtime) ||
                other.isLoadingRealtime == isLoadingRealtime) &&
            (identical(other.isLoadingBikes, isLoadingBikes) ||
                other.isLoadingBikes == isLoadingBikes) &&
            (identical(other.isLoadingTraffic, isLoadingTraffic) ||
                other.isLoadingTraffic == isLoadingTraffic) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_busRoutes),
      const DeepCollectionEquality().hash(_busRealtime),
      const DeepCollectionEquality().hash(_bikeStations),
      const DeepCollectionEquality().hash(_trafficInfos),
      selectedRouteId,
      selectedStopId,
      isLoadingRoutes,
      isLoadingRealtime,
      isLoadingBikes,
      isLoadingTraffic,
      error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TransportStateImplCopyWith<_$TransportStateImpl> get copyWith =>
      __$$TransportStateImplCopyWithImpl<_$TransportStateImpl>(
          this, _$identity);
}

abstract class _TransportState implements TransportState {
  const factory _TransportState(
      {final List<BusRoute> busRoutes,
      final List<BusRealtime> busRealtime,
      final List<BikeStation> bikeStations,
      final List<TrafficInfo> trafficInfos,
      final String? selectedRouteId,
      final String? selectedStopId,
      final bool isLoadingRoutes,
      final bool isLoadingRealtime,
      final bool isLoadingBikes,
      final bool isLoadingTraffic,
      final String? error}) = _$TransportStateImpl;

  @override
  List<BusRoute> get busRoutes;
  @override
  List<BusRealtime> get busRealtime;
  @override
  List<BikeStation> get bikeStations;
  @override
  List<TrafficInfo> get trafficInfos;
  @override
  String? get selectedRouteId;
  @override
  String? get selectedStopId;
  @override
  bool get isLoadingRoutes;
  @override
  bool get isLoadingRealtime;
  @override
  bool get isLoadingBikes;
  @override
  bool get isLoadingTraffic;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$TransportStateImplCopyWith<_$TransportStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
