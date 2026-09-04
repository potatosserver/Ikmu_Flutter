// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CalendarEventType _$CalendarEventTypeFromJson(Map<String, dynamic> json) {
  return _CalendarEventType.fromJson(json);
}

/// @nodoc
mixin _$CalendarEventType {
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get color => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CalendarEventTypeCopyWith<CalendarEventType> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalendarEventTypeCopyWith<$Res> {
  factory $CalendarEventTypeCopyWith(
          CalendarEventType value, $Res Function(CalendarEventType) then) =
      _$CalendarEventTypeCopyWithImpl<$Res, CalendarEventType>;
  @useResult
  $Res call({String code, String name, String color, String icon});
}

/// @nodoc
class _$CalendarEventTypeCopyWithImpl<$Res, $Val extends CalendarEventType>
    implements $CalendarEventTypeCopyWith<$Res> {
  _$CalendarEventTypeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? color = null,
    Object? icon = null,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CalendarEventTypeImplCopyWith<$Res>
    implements $CalendarEventTypeCopyWith<$Res> {
  factory _$$CalendarEventTypeImplCopyWith(_$CalendarEventTypeImpl value,
          $Res Function(_$CalendarEventTypeImpl) then) =
      __$$CalendarEventTypeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String code, String name, String color, String icon});
}

/// @nodoc
class __$$CalendarEventTypeImplCopyWithImpl<$Res>
    extends _$CalendarEventTypeCopyWithImpl<$Res, _$CalendarEventTypeImpl>
    implements _$$CalendarEventTypeImplCopyWith<$Res> {
  __$$CalendarEventTypeImplCopyWithImpl(_$CalendarEventTypeImpl _value,
      $Res Function(_$CalendarEventTypeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? color = null,
    Object? icon = null,
  }) {
    return _then(_$CalendarEventTypeImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CalendarEventTypeImpl implements _CalendarEventType {
  const _$CalendarEventTypeImpl(
      {required this.code,
      required this.name,
      required this.color,
      this.icon = ''});

  factory _$CalendarEventTypeImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalendarEventTypeImplFromJson(json);

  @override
  final String code;
  @override
  final String name;
  @override
  final String color;
  @override
  @JsonKey()
  final String icon;

  @override
  String toString() {
    return 'CalendarEventType(code: $code, name: $name, color: $color, icon: $icon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalendarEventTypeImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.icon, icon) || other.icon == icon));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, code, name, color, icon);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CalendarEventTypeImplCopyWith<_$CalendarEventTypeImpl> get copyWith =>
      __$$CalendarEventTypeImplCopyWithImpl<_$CalendarEventTypeImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalendarEventTypeImplToJson(
      this,
    );
  }
}

abstract class _CalendarEventType implements CalendarEventType {
  const factory _CalendarEventType(
      {required final String code,
      required final String name,
      required final String color,
      final String icon}) = _$CalendarEventTypeImpl;

  factory _CalendarEventType.fromJson(Map<String, dynamic> json) =
      _$CalendarEventTypeImpl.fromJson;

  @override
  String get code;
  @override
  String get name;
  @override
  String get color;
  @override
  String get icon;
  @override
  @JsonKey(ignore: true)
  _$$CalendarEventTypeImplCopyWith<_$CalendarEventTypeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CalendarEvent {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get typeCode => throw _privateConstructorUsedError;
  String? get typeName => throw _privateConstructorUsedError;
  String? get startTime => throw _privateConstructorUsedError;
  String? get endTime => throw _privateConstructorUsedError;
  bool get allDay => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String? get info => throw _privateConstructorUsedError;
  String? get extendedInfo => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  int? get sequence => throw _privateConstructorUsedError;
  String? get date => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CalendarEventCopyWith<CalendarEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalendarEventCopyWith<$Res> {
  factory $CalendarEventCopyWith(
          CalendarEvent value, $Res Function(CalendarEvent) then) =
      _$CalendarEventCopyWithImpl<$Res, CalendarEvent>;
  @useResult
  $Res call(
      {String id,
      String title,
      String typeCode,
      String? typeName,
      String? startTime,
      String? endTime,
      bool allDay,
      String? location,
      String? info,
      String? extendedInfo,
      String? color,
      int? sequence,
      String? date});
}

/// @nodoc
class _$CalendarEventCopyWithImpl<$Res, $Val extends CalendarEvent>
    implements $CalendarEventCopyWith<$Res> {
  _$CalendarEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? typeCode = null,
    Object? typeName = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? allDay = null,
    Object? location = freezed,
    Object? info = freezed,
    Object? extendedInfo = freezed,
    Object? color = freezed,
    Object? sequence = freezed,
    Object? date = freezed,
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
      typeCode: null == typeCode
          ? _value.typeCode
          : typeCode // ignore: cast_nullable_to_non_nullable
              as String,
      typeName: freezed == typeName
          ? _value.typeName
          : typeName // ignore: cast_nullable_to_non_nullable
              as String?,
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String?,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String?,
      allDay: null == allDay
          ? _value.allDay
          : allDay // ignore: cast_nullable_to_non_nullable
              as bool,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      info: freezed == info
          ? _value.info
          : info // ignore: cast_nullable_to_non_nullable
              as String?,
      extendedInfo: freezed == extendedInfo
          ? _value.extendedInfo
          : extendedInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      sequence: freezed == sequence
          ? _value.sequence
          : sequence // ignore: cast_nullable_to_non_nullable
              as int?,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CalendarEventImplCopyWith<$Res>
    implements $CalendarEventCopyWith<$Res> {
  factory _$$CalendarEventImplCopyWith(
          _$CalendarEventImpl value, $Res Function(_$CalendarEventImpl) then) =
      __$$CalendarEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String typeCode,
      String? typeName,
      String? startTime,
      String? endTime,
      bool allDay,
      String? location,
      String? info,
      String? extendedInfo,
      String? color,
      int? sequence,
      String? date});
}

/// @nodoc
class __$$CalendarEventImplCopyWithImpl<$Res>
    extends _$CalendarEventCopyWithImpl<$Res, _$CalendarEventImpl>
    implements _$$CalendarEventImplCopyWith<$Res> {
  __$$CalendarEventImplCopyWithImpl(
      _$CalendarEventImpl _value, $Res Function(_$CalendarEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? typeCode = null,
    Object? typeName = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? allDay = null,
    Object? location = freezed,
    Object? info = freezed,
    Object? extendedInfo = freezed,
    Object? color = freezed,
    Object? sequence = freezed,
    Object? date = freezed,
  }) {
    return _then(_$CalendarEventImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      typeCode: null == typeCode
          ? _value.typeCode
          : typeCode // ignore: cast_nullable_to_non_nullable
              as String,
      typeName: freezed == typeName
          ? _value.typeName
          : typeName // ignore: cast_nullable_to_non_nullable
              as String?,
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String?,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String?,
      allDay: null == allDay
          ? _value.allDay
          : allDay // ignore: cast_nullable_to_non_nullable
              as bool,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      info: freezed == info
          ? _value.info
          : info // ignore: cast_nullable_to_non_nullable
              as String?,
      extendedInfo: freezed == extendedInfo
          ? _value.extendedInfo
          : extendedInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      sequence: freezed == sequence
          ? _value.sequence
          : sequence // ignore: cast_nullable_to_non_nullable
              as int?,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$CalendarEventImpl implements _CalendarEvent {
  const _$CalendarEventImpl(
      {required this.id,
      required this.title,
      required this.typeCode,
      this.typeName,
      this.startTime,
      this.endTime,
      this.allDay = false,
      this.location,
      this.info,
      this.extendedInfo,
      this.color,
      this.sequence,
      this.date});

  @override
  final String id;
  @override
  final String title;
  @override
  final String typeCode;
  @override
  final String? typeName;
  @override
  final String? startTime;
  @override
  final String? endTime;
  @override
  @JsonKey()
  final bool allDay;
  @override
  final String? location;
  @override
  final String? info;
  @override
  final String? extendedInfo;
  @override
  final String? color;
  @override
  final int? sequence;
  @override
  final String? date;

  @override
  String toString() {
    return 'CalendarEvent(id: $id, title: $title, typeCode: $typeCode, typeName: $typeName, startTime: $startTime, endTime: $endTime, allDay: $allDay, location: $location, info: $info, extendedInfo: $extendedInfo, color: $color, sequence: $sequence, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalendarEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.typeCode, typeCode) ||
                other.typeCode == typeCode) &&
            (identical(other.typeName, typeName) ||
                other.typeName == typeName) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.allDay, allDay) || other.allDay == allDay) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.info, info) || other.info == info) &&
            (identical(other.extendedInfo, extendedInfo) ||
                other.extendedInfo == extendedInfo) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.sequence, sequence) ||
                other.sequence == sequence) &&
            (identical(other.date, date) || other.date == date));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      typeCode,
      typeName,
      startTime,
      endTime,
      allDay,
      location,
      info,
      extendedInfo,
      color,
      sequence,
      date);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CalendarEventImplCopyWith<_$CalendarEventImpl> get copyWith =>
      __$$CalendarEventImplCopyWithImpl<_$CalendarEventImpl>(this, _$identity);
}

abstract class _CalendarEvent implements CalendarEvent {
  const factory _CalendarEvent(
      {required final String id,
      required final String title,
      required final String typeCode,
      final String? typeName,
      final String? startTime,
      final String? endTime,
      final bool allDay,
      final String? location,
      final String? info,
      final String? extendedInfo,
      final String? color,
      final int? sequence,
      final String? date}) = _$CalendarEventImpl;

  @override
  String get id;
  @override
  String get title;
  @override
  String get typeCode;
  @override
  String? get typeName;
  @override
  String? get startTime;
  @override
  String? get endTime;
  @override
  bool get allDay;
  @override
  String? get location;
  @override
  String? get info;
  @override
  String? get extendedInfo;
  @override
  String? get color;
  @override
  int? get sequence;
  @override
  String? get date;
  @override
  @JsonKey(ignore: true)
  _$$CalendarEventImplCopyWith<_$CalendarEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CalendarState {
  CalendarView get currentView => throw _privateConstructorUsedError;
  DateTime? get currentMonth =>
      throw _privateConstructorUsedError; // 月檢視：當前月份 (第一天)
  DateTime? get currentWeekStart =>
      throw _privateConstructorUsedError; // 週檢視：週起始日 (週日)
  DateTime? get currentDay => throw _privateConstructorUsedError; // 日檢視：當前日期
  Map<String, List<CalendarEvent>> get eventsCache =>
      throw _privateConstructorUsedError; // dateStr -> events
  Map<String, int> get cacheTimestamps =>
      throw _privateConstructorUsedError; // dateStr -> timestamp
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  bool get isOffline => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CalendarStateCopyWith<CalendarState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalendarStateCopyWith<$Res> {
  factory $CalendarStateCopyWith(
          CalendarState value, $Res Function(CalendarState) then) =
      _$CalendarStateCopyWithImpl<$Res, CalendarState>;
  @useResult
  $Res call(
      {CalendarView currentView,
      DateTime? currentMonth,
      DateTime? currentWeekStart,
      DateTime? currentDay,
      Map<String, List<CalendarEvent>> eventsCache,
      Map<String, int> cacheTimestamps,
      bool isLoading,
      String? error,
      bool isOffline});
}

/// @nodoc
class _$CalendarStateCopyWithImpl<$Res, $Val extends CalendarState>
    implements $CalendarStateCopyWith<$Res> {
  _$CalendarStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentView = null,
    Object? currentMonth = freezed,
    Object? currentWeekStart = freezed,
    Object? currentDay = freezed,
    Object? eventsCache = null,
    Object? cacheTimestamps = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? isOffline = null,
  }) {
    return _then(_value.copyWith(
      currentView: null == currentView
          ? _value.currentView
          : currentView // ignore: cast_nullable_to_non_nullable
              as CalendarView,
      currentMonth: freezed == currentMonth
          ? _value.currentMonth
          : currentMonth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      currentWeekStart: freezed == currentWeekStart
          ? _value.currentWeekStart
          : currentWeekStart // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      currentDay: freezed == currentDay
          ? _value.currentDay
          : currentDay // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      eventsCache: null == eventsCache
          ? _value.eventsCache
          : eventsCache // ignore: cast_nullable_to_non_nullable
              as Map<String, List<CalendarEvent>>,
      cacheTimestamps: null == cacheTimestamps
          ? _value.cacheTimestamps
          : cacheTimestamps // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      isOffline: null == isOffline
          ? _value.isOffline
          : isOffline // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CalendarStateImplCopyWith<$Res>
    implements $CalendarStateCopyWith<$Res> {
  factory _$$CalendarStateImplCopyWith(
          _$CalendarStateImpl value, $Res Function(_$CalendarStateImpl) then) =
      __$$CalendarStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {CalendarView currentView,
      DateTime? currentMonth,
      DateTime? currentWeekStart,
      DateTime? currentDay,
      Map<String, List<CalendarEvent>> eventsCache,
      Map<String, int> cacheTimestamps,
      bool isLoading,
      String? error,
      bool isOffline});
}

/// @nodoc
class __$$CalendarStateImplCopyWithImpl<$Res>
    extends _$CalendarStateCopyWithImpl<$Res, _$CalendarStateImpl>
    implements _$$CalendarStateImplCopyWith<$Res> {
  __$$CalendarStateImplCopyWithImpl(
      _$CalendarStateImpl _value, $Res Function(_$CalendarStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentView = null,
    Object? currentMonth = freezed,
    Object? currentWeekStart = freezed,
    Object? currentDay = freezed,
    Object? eventsCache = null,
    Object? cacheTimestamps = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? isOffline = null,
  }) {
    return _then(_$CalendarStateImpl(
      currentView: null == currentView
          ? _value.currentView
          : currentView // ignore: cast_nullable_to_non_nullable
              as CalendarView,
      currentMonth: freezed == currentMonth
          ? _value.currentMonth
          : currentMonth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      currentWeekStart: freezed == currentWeekStart
          ? _value.currentWeekStart
          : currentWeekStart // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      currentDay: freezed == currentDay
          ? _value.currentDay
          : currentDay // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      eventsCache: null == eventsCache
          ? _value._eventsCache
          : eventsCache // ignore: cast_nullable_to_non_nullable
              as Map<String, List<CalendarEvent>>,
      cacheTimestamps: null == cacheTimestamps
          ? _value._cacheTimestamps
          : cacheTimestamps // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      isOffline: null == isOffline
          ? _value.isOffline
          : isOffline // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$CalendarStateImpl implements _CalendarState {
  const _$CalendarStateImpl(
      {this.currentView = CalendarView.month,
      this.currentMonth,
      this.currentWeekStart,
      this.currentDay,
      final Map<String, List<CalendarEvent>> eventsCache = const {},
      final Map<String, int> cacheTimestamps = const {},
      this.isLoading = false,
      this.error,
      this.isOffline = false})
      : _eventsCache = eventsCache,
        _cacheTimestamps = cacheTimestamps;

  @override
  @JsonKey()
  final CalendarView currentView;
  @override
  final DateTime? currentMonth;
// 月檢視：當前月份 (第一天)
  @override
  final DateTime? currentWeekStart;
// 週檢視：週起始日 (週日)
  @override
  final DateTime? currentDay;
// 日檢視：當前日期
  final Map<String, List<CalendarEvent>> _eventsCache;
// 日檢視：當前日期
  @override
  @JsonKey()
  Map<String, List<CalendarEvent>> get eventsCache {
    if (_eventsCache is EqualUnmodifiableMapView) return _eventsCache;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_eventsCache);
  }

// dateStr -> events
  final Map<String, int> _cacheTimestamps;
// dateStr -> events
  @override
  @JsonKey()
  Map<String, int> get cacheTimestamps {
    if (_cacheTimestamps is EqualUnmodifiableMapView) return _cacheTimestamps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_cacheTimestamps);
  }

// dateStr -> timestamp
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  @override
  @JsonKey()
  final bool isOffline;

  @override
  String toString() {
    return 'CalendarState(currentView: $currentView, currentMonth: $currentMonth, currentWeekStart: $currentWeekStart, currentDay: $currentDay, eventsCache: $eventsCache, cacheTimestamps: $cacheTimestamps, isLoading: $isLoading, error: $error, isOffline: $isOffline)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalendarStateImpl &&
            (identical(other.currentView, currentView) ||
                other.currentView == currentView) &&
            (identical(other.currentMonth, currentMonth) ||
                other.currentMonth == currentMonth) &&
            (identical(other.currentWeekStart, currentWeekStart) ||
                other.currentWeekStart == currentWeekStart) &&
            (identical(other.currentDay, currentDay) ||
                other.currentDay == currentDay) &&
            const DeepCollectionEquality()
                .equals(other._eventsCache, _eventsCache) &&
            const DeepCollectionEquality()
                .equals(other._cacheTimestamps, _cacheTimestamps) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.isOffline, isOffline) ||
                other.isOffline == isOffline));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentView,
      currentMonth,
      currentWeekStart,
      currentDay,
      const DeepCollectionEquality().hash(_eventsCache),
      const DeepCollectionEquality().hash(_cacheTimestamps),
      isLoading,
      error,
      isOffline);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CalendarStateImplCopyWith<_$CalendarStateImpl> get copyWith =>
      __$$CalendarStateImplCopyWithImpl<_$CalendarStateImpl>(this, _$identity);
}

abstract class _CalendarState implements CalendarState {
  const factory _CalendarState(
      {final CalendarView currentView,
      final DateTime? currentMonth,
      final DateTime? currentWeekStart,
      final DateTime? currentDay,
      final Map<String, List<CalendarEvent>> eventsCache,
      final Map<String, int> cacheTimestamps,
      final bool isLoading,
      final String? error,
      final bool isOffline}) = _$CalendarStateImpl;

  @override
  CalendarView get currentView;
  @override
  DateTime? get currentMonth;
  @override // 月檢視：當前月份 (第一天)
  DateTime? get currentWeekStart;
  @override // 週檢視：週起始日 (週日)
  DateTime? get currentDay;
  @override // 日檢視：當前日期
  Map<String, List<CalendarEvent>> get eventsCache;
  @override // dateStr -> events
  Map<String, int> get cacheTimestamps;
  @override // dateStr -> timestamp
  bool get isLoading;
  @override
  String? get error;
  @override
  bool get isOffline;
  @override
  @JsonKey(ignore: true)
  _$$CalendarStateImplCopyWith<_$CalendarStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CalendarMonthResponse _$CalendarMonthResponseFromJson(
    Map<String, dynamic> json) {
  return _CalendarMonthResponse.fromJson(json);
}

/// @nodoc
mixin _$CalendarMonthResponse {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  Map<String, dynamic>? get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CalendarMonthResponseCopyWith<CalendarMonthResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalendarMonthResponseCopyWith<$Res> {
  factory $CalendarMonthResponseCopyWith(CalendarMonthResponse value,
          $Res Function(CalendarMonthResponse) then) =
      _$CalendarMonthResponseCopyWithImpl<$Res, CalendarMonthResponse>;
  @useResult
  $Res call({bool success, String message, Map<String, dynamic>? data});
}

/// @nodoc
class _$CalendarMonthResponseCopyWithImpl<$Res,
        $Val extends CalendarMonthResponse>
    implements $CalendarMonthResponseCopyWith<$Res> {
  _$CalendarMonthResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = freezed,
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
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CalendarMonthResponseImplCopyWith<$Res>
    implements $CalendarMonthResponseCopyWith<$Res> {
  factory _$$CalendarMonthResponseImplCopyWith(
          _$CalendarMonthResponseImpl value,
          $Res Function(_$CalendarMonthResponseImpl) then) =
      __$$CalendarMonthResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, String message, Map<String, dynamic>? data});
}

/// @nodoc
class __$$CalendarMonthResponseImplCopyWithImpl<$Res>
    extends _$CalendarMonthResponseCopyWithImpl<$Res,
        _$CalendarMonthResponseImpl>
    implements _$$CalendarMonthResponseImplCopyWith<$Res> {
  __$$CalendarMonthResponseImplCopyWithImpl(_$CalendarMonthResponseImpl _value,
      $Res Function(_$CalendarMonthResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = freezed,
  }) {
    return _then(_$CalendarMonthResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CalendarMonthResponseImpl implements _CalendarMonthResponse {
  const _$CalendarMonthResponseImpl(
      {required this.success,
      required this.message,
      final Map<String, dynamic>? data})
      : _data = data;

  factory _$CalendarMonthResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalendarMonthResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  final Map<String, dynamic>? _data;
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'CalendarMonthResponse(success: $success, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalendarMonthResponseImpl &&
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
  _$$CalendarMonthResponseImplCopyWith<_$CalendarMonthResponseImpl>
      get copyWith => __$$CalendarMonthResponseImplCopyWithImpl<
          _$CalendarMonthResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalendarMonthResponseImplToJson(
      this,
    );
  }
}

abstract class _CalendarMonthResponse implements CalendarMonthResponse {
  const factory _CalendarMonthResponse(
      {required final bool success,
      required final String message,
      final Map<String, dynamic>? data}) = _$CalendarMonthResponseImpl;

  factory _CalendarMonthResponse.fromJson(Map<String, dynamic> json) =
      _$CalendarMonthResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  Map<String, dynamic>? get data;
  @override
  @JsonKey(ignore: true)
  _$$CalendarMonthResponseImplCopyWith<_$CalendarMonthResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

EventDetailData _$EventDetailDataFromJson(Map<String, dynamic> json) {
  return _EventDetailData.fromJson(json);
}

/// @nodoc
mixin _$EventDetailData {
  dynamic get event => throw _privateConstructorUsedError;
  String get dateStr => throw _privateConstructorUsedError;
  List<dynamic> get allDayEvents => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EventDetailDataCopyWith<EventDetailData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventDetailDataCopyWith<$Res> {
  factory $EventDetailDataCopyWith(
          EventDetailData value, $Res Function(EventDetailData) then) =
      _$EventDetailDataCopyWithImpl<$Res, EventDetailData>;
  @useResult
  $Res call({dynamic event, String dateStr, List<dynamic> allDayEvents});
}

/// @nodoc
class _$EventDetailDataCopyWithImpl<$Res, $Val extends EventDetailData>
    implements $EventDetailDataCopyWith<$Res> {
  _$EventDetailDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? event = freezed,
    Object? dateStr = null,
    Object? allDayEvents = null,
  }) {
    return _then(_value.copyWith(
      event: freezed == event
          ? _value.event
          : event // ignore: cast_nullable_to_non_nullable
              as dynamic,
      dateStr: null == dateStr
          ? _value.dateStr
          : dateStr // ignore: cast_nullable_to_non_nullable
              as String,
      allDayEvents: null == allDayEvents
          ? _value.allDayEvents
          : allDayEvents // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EventDetailDataImplCopyWith<$Res>
    implements $EventDetailDataCopyWith<$Res> {
  factory _$$EventDetailDataImplCopyWith(_$EventDetailDataImpl value,
          $Res Function(_$EventDetailDataImpl) then) =
      __$$EventDetailDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({dynamic event, String dateStr, List<dynamic> allDayEvents});
}

/// @nodoc
class __$$EventDetailDataImplCopyWithImpl<$Res>
    extends _$EventDetailDataCopyWithImpl<$Res, _$EventDetailDataImpl>
    implements _$$EventDetailDataImplCopyWith<$Res> {
  __$$EventDetailDataImplCopyWithImpl(
      _$EventDetailDataImpl _value, $Res Function(_$EventDetailDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? event = freezed,
    Object? dateStr = null,
    Object? allDayEvents = null,
  }) {
    return _then(_$EventDetailDataImpl(
      event: freezed == event
          ? _value.event
          : event // ignore: cast_nullable_to_non_nullable
              as dynamic,
      dateStr: null == dateStr
          ? _value.dateStr
          : dateStr // ignore: cast_nullable_to_non_nullable
              as String,
      allDayEvents: null == allDayEvents
          ? _value._allDayEvents
          : allDayEvents // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EventDetailDataImpl implements _EventDetailData {
  const _$EventDetailDataImpl(
      {required this.event,
      required this.dateStr,
      required final List<dynamic> allDayEvents})
      : _allDayEvents = allDayEvents;

  factory _$EventDetailDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventDetailDataImplFromJson(json);

  @override
  final dynamic event;
  @override
  final String dateStr;
  final List<dynamic> _allDayEvents;
  @override
  List<dynamic> get allDayEvents {
    if (_allDayEvents is EqualUnmodifiableListView) return _allDayEvents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allDayEvents);
  }

  @override
  String toString() {
    return 'EventDetailData(event: $event, dateStr: $dateStr, allDayEvents: $allDayEvents)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventDetailDataImpl &&
            const DeepCollectionEquality().equals(other.event, event) &&
            (identical(other.dateStr, dateStr) || other.dateStr == dateStr) &&
            const DeepCollectionEquality()
                .equals(other._allDayEvents, _allDayEvents));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(event),
      dateStr,
      const DeepCollectionEquality().hash(_allDayEvents));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EventDetailDataImplCopyWith<_$EventDetailDataImpl> get copyWith =>
      __$$EventDetailDataImplCopyWithImpl<_$EventDetailDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventDetailDataImplToJson(
      this,
    );
  }
}

abstract class _EventDetailData implements EventDetailData {
  const factory _EventDetailData(
      {required final dynamic event,
      required final String dateStr,
      required final List<dynamic> allDayEvents}) = _$EventDetailDataImpl;

  factory _EventDetailData.fromJson(Map<String, dynamic> json) =
      _$EventDetailDataImpl.fromJson;

  @override
  dynamic get event;
  @override
  String get dateStr;
  @override
  List<dynamic> get allDayEvents;
  @override
  @JsonKey(ignore: true)
  _$$EventDetailDataImplCopyWith<_$EventDetailDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
