// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'classroom_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ClassroomCategory {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  int get roomCount => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ClassroomCategoryCopyWith<ClassroomCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassroomCategoryCopyWith<$Res> {
  factory $ClassroomCategoryCopyWith(
          ClassroomCategory value, $Res Function(ClassroomCategory) then) =
      _$ClassroomCategoryCopyWithImpl<$Res, ClassroomCategory>;
  @useResult
  $Res call(
      {String id, String name, String? icon, int sortOrder, int roomCount});
}

/// @nodoc
class _$ClassroomCategoryCopyWithImpl<$Res, $Val extends ClassroomCategory>
    implements $ClassroomCategoryCopyWith<$Res> {
  _$ClassroomCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = freezed,
    Object? sortOrder = null,
    Object? roomCount = null,
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
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      roomCount: null == roomCount
          ? _value.roomCount
          : roomCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClassroomCategoryImplCopyWith<$Res>
    implements $ClassroomCategoryCopyWith<$Res> {
  factory _$$ClassroomCategoryImplCopyWith(_$ClassroomCategoryImpl value,
          $Res Function(_$ClassroomCategoryImpl) then) =
      __$$ClassroomCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id, String name, String? icon, int sortOrder, int roomCount});
}

/// @nodoc
class __$$ClassroomCategoryImplCopyWithImpl<$Res>
    extends _$ClassroomCategoryCopyWithImpl<$Res, _$ClassroomCategoryImpl>
    implements _$$ClassroomCategoryImplCopyWith<$Res> {
  __$$ClassroomCategoryImplCopyWithImpl(_$ClassroomCategoryImpl _value,
      $Res Function(_$ClassroomCategoryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = freezed,
    Object? sortOrder = null,
    Object? roomCount = null,
  }) {
    return _then(_$ClassroomCategoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      roomCount: null == roomCount
          ? _value.roomCount
          : roomCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ClassroomCategoryImpl implements _ClassroomCategory {
  const _$ClassroomCategoryImpl(
      {required this.id,
      required this.name,
      this.icon,
      this.sortOrder = 0,
      this.roomCount = 0});

  @override
  final String id;
  @override
  final String name;
  @override
  final String? icon;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  @JsonKey()
  final int roomCount;

  @override
  String toString() {
    return 'ClassroomCategory(id: $id, name: $name, icon: $icon, sortOrder: $sortOrder, roomCount: $roomCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassroomCategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.roomCount, roomCount) ||
                other.roomCount == roomCount));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, icon, sortOrder, roomCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassroomCategoryImplCopyWith<_$ClassroomCategoryImpl> get copyWith =>
      __$$ClassroomCategoryImplCopyWithImpl<_$ClassroomCategoryImpl>(
          this, _$identity);
}

abstract class _ClassroomCategory implements ClassroomCategory {
  const factory _ClassroomCategory(
      {required final String id,
      required final String name,
      final String? icon,
      final int sortOrder,
      final int roomCount}) = _$ClassroomCategoryImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get icon;
  @override
  int get sortOrder;
  @override
  int get roomCount;
  @override
  @JsonKey(ignore: true)
  _$$ClassroomCategoryImplCopyWith<_$ClassroomCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ClassroomRoom {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get building => throw _privateConstructorUsedError;
  String? get floor => throw _privateConstructorUsedError;
  int? get capacity => throw _privateConstructorUsedError;
  String? get categoryId => throw _privateConstructorUsedError;
  String? get categoryName => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  List<String> get equipment => throw _privateConstructorUsedError;
  bool get hasProjector => throw _privateConstructorUsedError;
  bool get hasAc => throw _privateConstructorUsedError;
  bool get hasComputer => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ClassroomRoomCopyWith<ClassroomRoom> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassroomRoomCopyWith<$Res> {
  factory $ClassroomRoomCopyWith(
          ClassroomRoom value, $Res Function(ClassroomRoom) then) =
      _$ClassroomRoomCopyWithImpl<$Res, ClassroomRoom>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? building,
      String? floor,
      int? capacity,
      String? categoryId,
      String? categoryName,
      String? location,
      List<String> equipment,
      bool hasProjector,
      bool hasAc,
      bool hasComputer,
      String? imageUrl,
      String? description});
}

/// @nodoc
class _$ClassroomRoomCopyWithImpl<$Res, $Val extends ClassroomRoom>
    implements $ClassroomRoomCopyWith<$Res> {
  _$ClassroomRoomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? building = freezed,
    Object? floor = freezed,
    Object? capacity = freezed,
    Object? categoryId = freezed,
    Object? categoryName = freezed,
    Object? location = freezed,
    Object? equipment = null,
    Object? hasProjector = null,
    Object? hasAc = null,
    Object? hasComputer = null,
    Object? imageUrl = freezed,
    Object? description = freezed,
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
      building: freezed == building
          ? _value.building
          : building // ignore: cast_nullable_to_non_nullable
              as String?,
      floor: freezed == floor
          ? _value.floor
          : floor // ignore: cast_nullable_to_non_nullable
              as String?,
      capacity: freezed == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int?,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryName: freezed == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      equipment: null == equipment
          ? _value.equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as List<String>,
      hasProjector: null == hasProjector
          ? _value.hasProjector
          : hasProjector // ignore: cast_nullable_to_non_nullable
              as bool,
      hasAc: null == hasAc
          ? _value.hasAc
          : hasAc // ignore: cast_nullable_to_non_nullable
              as bool,
      hasComputer: null == hasComputer
          ? _value.hasComputer
          : hasComputer // ignore: cast_nullable_to_non_nullable
              as bool,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClassroomRoomImplCopyWith<$Res>
    implements $ClassroomRoomCopyWith<$Res> {
  factory _$$ClassroomRoomImplCopyWith(
          _$ClassroomRoomImpl value, $Res Function(_$ClassroomRoomImpl) then) =
      __$$ClassroomRoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? building,
      String? floor,
      int? capacity,
      String? categoryId,
      String? categoryName,
      String? location,
      List<String> equipment,
      bool hasProjector,
      bool hasAc,
      bool hasComputer,
      String? imageUrl,
      String? description});
}

/// @nodoc
class __$$ClassroomRoomImplCopyWithImpl<$Res>
    extends _$ClassroomRoomCopyWithImpl<$Res, _$ClassroomRoomImpl>
    implements _$$ClassroomRoomImplCopyWith<$Res> {
  __$$ClassroomRoomImplCopyWithImpl(
      _$ClassroomRoomImpl _value, $Res Function(_$ClassroomRoomImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? building = freezed,
    Object? floor = freezed,
    Object? capacity = freezed,
    Object? categoryId = freezed,
    Object? categoryName = freezed,
    Object? location = freezed,
    Object? equipment = null,
    Object? hasProjector = null,
    Object? hasAc = null,
    Object? hasComputer = null,
    Object? imageUrl = freezed,
    Object? description = freezed,
  }) {
    return _then(_$ClassroomRoomImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      building: freezed == building
          ? _value.building
          : building // ignore: cast_nullable_to_non_nullable
              as String?,
      floor: freezed == floor
          ? _value.floor
          : floor // ignore: cast_nullable_to_non_nullable
              as String?,
      capacity: freezed == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int?,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryName: freezed == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      equipment: null == equipment
          ? _value._equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as List<String>,
      hasProjector: null == hasProjector
          ? _value.hasProjector
          : hasProjector // ignore: cast_nullable_to_non_nullable
              as bool,
      hasAc: null == hasAc
          ? _value.hasAc
          : hasAc // ignore: cast_nullable_to_non_nullable
              as bool,
      hasComputer: null == hasComputer
          ? _value.hasComputer
          : hasComputer // ignore: cast_nullable_to_non_nullable
              as bool,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ClassroomRoomImpl implements _ClassroomRoom {
  const _$ClassroomRoomImpl(
      {required this.id,
      required this.name,
      this.building,
      this.floor,
      this.capacity,
      this.categoryId,
      this.categoryName,
      this.location,
      final List<String> equipment = const [],
      this.hasProjector = false,
      this.hasAc = false,
      this.hasComputer = false,
      this.imageUrl,
      this.description})
      : _equipment = equipment;

  @override
  final String id;
  @override
  final String name;
  @override
  final String? building;
  @override
  final String? floor;
  @override
  final int? capacity;
  @override
  final String? categoryId;
  @override
  final String? categoryName;
  @override
  final String? location;
  final List<String> _equipment;
  @override
  @JsonKey()
  List<String> get equipment {
    if (_equipment is EqualUnmodifiableListView) return _equipment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_equipment);
  }

  @override
  @JsonKey()
  final bool hasProjector;
  @override
  @JsonKey()
  final bool hasAc;
  @override
  @JsonKey()
  final bool hasComputer;
  @override
  final String? imageUrl;
  @override
  final String? description;

  @override
  String toString() {
    return 'ClassroomRoom(id: $id, name: $name, building: $building, floor: $floor, capacity: $capacity, categoryId: $categoryId, categoryName: $categoryName, location: $location, equipment: $equipment, hasProjector: $hasProjector, hasAc: $hasAc, hasComputer: $hasComputer, imageUrl: $imageUrl, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassroomRoomImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.building, building) ||
                other.building == building) &&
            (identical(other.floor, floor) || other.floor == floor) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality()
                .equals(other._equipment, _equipment) &&
            (identical(other.hasProjector, hasProjector) ||
                other.hasProjector == hasProjector) &&
            (identical(other.hasAc, hasAc) || other.hasAc == hasAc) &&
            (identical(other.hasComputer, hasComputer) ||
                other.hasComputer == hasComputer) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      building,
      floor,
      capacity,
      categoryId,
      categoryName,
      location,
      const DeepCollectionEquality().hash(_equipment),
      hasProjector,
      hasAc,
      hasComputer,
      imageUrl,
      description);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassroomRoomImplCopyWith<_$ClassroomRoomImpl> get copyWith =>
      __$$ClassroomRoomImplCopyWithImpl<_$ClassroomRoomImpl>(this, _$identity);
}

abstract class _ClassroomRoom implements ClassroomRoom {
  const factory _ClassroomRoom(
      {required final String id,
      required final String name,
      final String? building,
      final String? floor,
      final int? capacity,
      final String? categoryId,
      final String? categoryName,
      final String? location,
      final List<String> equipment,
      final bool hasProjector,
      final bool hasAc,
      final bool hasComputer,
      final String? imageUrl,
      final String? description}) = _$ClassroomRoomImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get building;
  @override
  String? get floor;
  @override
  int? get capacity;
  @override
  String? get categoryId;
  @override
  String? get categoryName;
  @override
  String? get location;
  @override
  List<String> get equipment;
  @override
  bool get hasProjector;
  @override
  bool get hasAc;
  @override
  bool get hasComputer;
  @override
  String? get imageUrl;
  @override
  String? get description;
  @override
  @JsonKey(ignore: true)
  _$$ClassroomRoomImplCopyWith<_$ClassroomRoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ClassroomDetail {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get building => throw _privateConstructorUsedError;
  String? get floor => throw _privateConstructorUsedError;
  int? get capacity => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  List<String> get equipments => throw _privateConstructorUsedError;
  String? get openTime => throw _privateConstructorUsedError;
  String? get closeTime => throw _privateConstructorUsedError;
  String? get contactPhone => throw _privateConstructorUsedError;
  String? get manager => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String? get categoryName => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ClassroomDetailCopyWith<ClassroomDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassroomDetailCopyWith<$Res> {
  factory $ClassroomDetailCopyWith(
          ClassroomDetail value, $Res Function(ClassroomDetail) then) =
      _$ClassroomDetailCopyWithImpl<$Res, ClassroomDetail>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? building,
      String? floor,
      int? capacity,
      String? description,
      String? imageUrl,
      List<String> equipments,
      String? openTime,
      String? closeTime,
      String? contactPhone,
      String? manager,
      String? notes,
      String? location,
      String? categoryName});
}

/// @nodoc
class _$ClassroomDetailCopyWithImpl<$Res, $Val extends ClassroomDetail>
    implements $ClassroomDetailCopyWith<$Res> {
  _$ClassroomDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? building = freezed,
    Object? floor = freezed,
    Object? capacity = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? equipments = null,
    Object? openTime = freezed,
    Object? closeTime = freezed,
    Object? contactPhone = freezed,
    Object? manager = freezed,
    Object? notes = freezed,
    Object? location = freezed,
    Object? categoryName = freezed,
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
      building: freezed == building
          ? _value.building
          : building // ignore: cast_nullable_to_non_nullable
              as String?,
      floor: freezed == floor
          ? _value.floor
          : floor // ignore: cast_nullable_to_non_nullable
              as String?,
      capacity: freezed == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      equipments: null == equipments
          ? _value.equipments
          : equipments // ignore: cast_nullable_to_non_nullable
              as List<String>,
      openTime: freezed == openTime
          ? _value.openTime
          : openTime // ignore: cast_nullable_to_non_nullable
              as String?,
      closeTime: freezed == closeTime
          ? _value.closeTime
          : closeTime // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPhone: freezed == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      manager: freezed == manager
          ? _value.manager
          : manager // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryName: freezed == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClassroomDetailImplCopyWith<$Res>
    implements $ClassroomDetailCopyWith<$Res> {
  factory _$$ClassroomDetailImplCopyWith(_$ClassroomDetailImpl value,
          $Res Function(_$ClassroomDetailImpl) then) =
      __$$ClassroomDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? building,
      String? floor,
      int? capacity,
      String? description,
      String? imageUrl,
      List<String> equipments,
      String? openTime,
      String? closeTime,
      String? contactPhone,
      String? manager,
      String? notes,
      String? location,
      String? categoryName});
}

/// @nodoc
class __$$ClassroomDetailImplCopyWithImpl<$Res>
    extends _$ClassroomDetailCopyWithImpl<$Res, _$ClassroomDetailImpl>
    implements _$$ClassroomDetailImplCopyWith<$Res> {
  __$$ClassroomDetailImplCopyWithImpl(
      _$ClassroomDetailImpl _value, $Res Function(_$ClassroomDetailImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? building = freezed,
    Object? floor = freezed,
    Object? capacity = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? equipments = null,
    Object? openTime = freezed,
    Object? closeTime = freezed,
    Object? contactPhone = freezed,
    Object? manager = freezed,
    Object? notes = freezed,
    Object? location = freezed,
    Object? categoryName = freezed,
  }) {
    return _then(_$ClassroomDetailImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      building: freezed == building
          ? _value.building
          : building // ignore: cast_nullable_to_non_nullable
              as String?,
      floor: freezed == floor
          ? _value.floor
          : floor // ignore: cast_nullable_to_non_nullable
              as String?,
      capacity: freezed == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      equipments: null == equipments
          ? _value._equipments
          : equipments // ignore: cast_nullable_to_non_nullable
              as List<String>,
      openTime: freezed == openTime
          ? _value.openTime
          : openTime // ignore: cast_nullable_to_non_nullable
              as String?,
      closeTime: freezed == closeTime
          ? _value.closeTime
          : closeTime // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPhone: freezed == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      manager: freezed == manager
          ? _value.manager
          : manager // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryName: freezed == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ClassroomDetailImpl implements _ClassroomDetail {
  const _$ClassroomDetailImpl(
      {required this.id,
      required this.name,
      this.building,
      this.floor,
      this.capacity,
      this.description,
      this.imageUrl,
      final List<String> equipments = const [],
      this.openTime,
      this.closeTime,
      this.contactPhone,
      this.manager,
      this.notes,
      this.location,
      this.categoryName})
      : _equipments = equipments;

  @override
  final String id;
  @override
  final String name;
  @override
  final String? building;
  @override
  final String? floor;
  @override
  final int? capacity;
  @override
  final String? description;
  @override
  final String? imageUrl;
  final List<String> _equipments;
  @override
  @JsonKey()
  List<String> get equipments {
    if (_equipments is EqualUnmodifiableListView) return _equipments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_equipments);
  }

  @override
  final String? openTime;
  @override
  final String? closeTime;
  @override
  final String? contactPhone;
  @override
  final String? manager;
  @override
  final String? notes;
  @override
  final String? location;
  @override
  final String? categoryName;

  @override
  String toString() {
    return 'ClassroomDetail(id: $id, name: $name, building: $building, floor: $floor, capacity: $capacity, description: $description, imageUrl: $imageUrl, equipments: $equipments, openTime: $openTime, closeTime: $closeTime, contactPhone: $contactPhone, manager: $manager, notes: $notes, location: $location, categoryName: $categoryName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassroomDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.building, building) ||
                other.building == building) &&
            (identical(other.floor, floor) || other.floor == floor) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality()
                .equals(other._equipments, _equipments) &&
            (identical(other.openTime, openTime) ||
                other.openTime == openTime) &&
            (identical(other.closeTime, closeTime) ||
                other.closeTime == closeTime) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.manager, manager) || other.manager == manager) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      building,
      floor,
      capacity,
      description,
      imageUrl,
      const DeepCollectionEquality().hash(_equipments),
      openTime,
      closeTime,
      contactPhone,
      manager,
      notes,
      location,
      categoryName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassroomDetailImplCopyWith<_$ClassroomDetailImpl> get copyWith =>
      __$$ClassroomDetailImplCopyWithImpl<_$ClassroomDetailImpl>(
          this, _$identity);
}

abstract class _ClassroomDetail implements ClassroomDetail {
  const factory _ClassroomDetail(
      {required final String id,
      required final String name,
      final String? building,
      final String? floor,
      final int? capacity,
      final String? description,
      final String? imageUrl,
      final List<String> equipments,
      final String? openTime,
      final String? closeTime,
      final String? contactPhone,
      final String? manager,
      final String? notes,
      final String? location,
      final String? categoryName}) = _$ClassroomDetailImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get building;
  @override
  String? get floor;
  @override
  int? get capacity;
  @override
  String? get description;
  @override
  String? get imageUrl;
  @override
  List<String> get equipments;
  @override
  String? get openTime;
  @override
  String? get closeTime;
  @override
  String? get contactPhone;
  @override
  String? get manager;
  @override
  String? get notes;
  @override
  String? get location;
  @override
  String? get categoryName;
  @override
  @JsonKey(ignore: true)
  _$$ClassroomDetailImplCopyWith<_$ClassroomDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TimeSlot {
  String get id => throw _privateConstructorUsedError;
  String get startTime => throw _privateConstructorUsedError;
  String get endTime => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // available, occupied, maintenance
  String? get courseName => throw _privateConstructorUsedError;
  String? get teacherName => throw _privateConstructorUsedError;
  String? get department => throw _privateConstructorUsedError;
  String? get className => throw _privateConstructorUsedError;
  int? get weekday => throw _privateConstructorUsedError; // 1-7
  String? get weeks => throw _privateConstructorUsedError; // e.g., "1-18"
  bool get isRecurring => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TimeSlotCopyWith<TimeSlot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeSlotCopyWith<$Res> {
  factory $TimeSlotCopyWith(TimeSlot value, $Res Function(TimeSlot) then) =
      _$TimeSlotCopyWithImpl<$Res, TimeSlot>;
  @useResult
  $Res call(
      {String id,
      String startTime,
      String endTime,
      String status,
      String? courseName,
      String? teacherName,
      String? department,
      String? className,
      int? weekday,
      String? weeks,
      bool isRecurring});
}

/// @nodoc
class _$TimeSlotCopyWithImpl<$Res, $Val extends TimeSlot>
    implements $TimeSlotCopyWith<$Res> {
  _$TimeSlotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? status = null,
    Object? courseName = freezed,
    Object? teacherName = freezed,
    Object? department = freezed,
    Object? className = freezed,
    Object? weekday = freezed,
    Object? weeks = freezed,
    Object? isRecurring = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      courseName: freezed == courseName
          ? _value.courseName
          : courseName // ignore: cast_nullable_to_non_nullable
              as String?,
      teacherName: freezed == teacherName
          ? _value.teacherName
          : teacherName // ignore: cast_nullable_to_non_nullable
              as String?,
      department: freezed == department
          ? _value.department
          : department // ignore: cast_nullable_to_non_nullable
              as String?,
      className: freezed == className
          ? _value.className
          : className // ignore: cast_nullable_to_non_nullable
              as String?,
      weekday: freezed == weekday
          ? _value.weekday
          : weekday // ignore: cast_nullable_to_non_nullable
              as int?,
      weeks: freezed == weeks
          ? _value.weeks
          : weeks // ignore: cast_nullable_to_non_nullable
              as String?,
      isRecurring: null == isRecurring
          ? _value.isRecurring
          : isRecurring // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimeSlotImplCopyWith<$Res>
    implements $TimeSlotCopyWith<$Res> {
  factory _$$TimeSlotImplCopyWith(
          _$TimeSlotImpl value, $Res Function(_$TimeSlotImpl) then) =
      __$$TimeSlotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String startTime,
      String endTime,
      String status,
      String? courseName,
      String? teacherName,
      String? department,
      String? className,
      int? weekday,
      String? weeks,
      bool isRecurring});
}

/// @nodoc
class __$$TimeSlotImplCopyWithImpl<$Res>
    extends _$TimeSlotCopyWithImpl<$Res, _$TimeSlotImpl>
    implements _$$TimeSlotImplCopyWith<$Res> {
  __$$TimeSlotImplCopyWithImpl(
      _$TimeSlotImpl _value, $Res Function(_$TimeSlotImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? status = null,
    Object? courseName = freezed,
    Object? teacherName = freezed,
    Object? department = freezed,
    Object? className = freezed,
    Object? weekday = freezed,
    Object? weeks = freezed,
    Object? isRecurring = null,
  }) {
    return _then(_$TimeSlotImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      courseName: freezed == courseName
          ? _value.courseName
          : courseName // ignore: cast_nullable_to_non_nullable
              as String?,
      teacherName: freezed == teacherName
          ? _value.teacherName
          : teacherName // ignore: cast_nullable_to_non_nullable
              as String?,
      department: freezed == department
          ? _value.department
          : department // ignore: cast_nullable_to_non_nullable
              as String?,
      className: freezed == className
          ? _value.className
          : className // ignore: cast_nullable_to_non_nullable
              as String?,
      weekday: freezed == weekday
          ? _value.weekday
          : weekday // ignore: cast_nullable_to_non_nullable
              as int?,
      weeks: freezed == weeks
          ? _value.weeks
          : weeks // ignore: cast_nullable_to_non_nullable
              as String?,
      isRecurring: null == isRecurring
          ? _value.isRecurring
          : isRecurring // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$TimeSlotImpl implements _TimeSlot {
  const _$TimeSlotImpl(
      {required this.id,
      required this.startTime,
      required this.endTime,
      required this.status,
      this.courseName,
      this.teacherName,
      this.department,
      this.className,
      this.weekday,
      this.weeks,
      this.isRecurring = false});

  @override
  final String id;
  @override
  final String startTime;
  @override
  final String endTime;
  @override
  final String status;
// available, occupied, maintenance
  @override
  final String? courseName;
  @override
  final String? teacherName;
  @override
  final String? department;
  @override
  final String? className;
  @override
  final int? weekday;
// 1-7
  @override
  final String? weeks;
// e.g., "1-18"
  @override
  @JsonKey()
  final bool isRecurring;

  @override
  String toString() {
    return 'TimeSlot(id: $id, startTime: $startTime, endTime: $endTime, status: $status, courseName: $courseName, teacherName: $teacherName, department: $department, className: $className, weekday: $weekday, weeks: $weeks, isRecurring: $isRecurring)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeSlotImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.courseName, courseName) ||
                other.courseName == courseName) &&
            (identical(other.teacherName, teacherName) ||
                other.teacherName == teacherName) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.className, className) ||
                other.className == className) &&
            (identical(other.weekday, weekday) || other.weekday == weekday) &&
            (identical(other.weeks, weeks) || other.weeks == weeks) &&
            (identical(other.isRecurring, isRecurring) ||
                other.isRecurring == isRecurring));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      startTime,
      endTime,
      status,
      courseName,
      teacherName,
      department,
      className,
      weekday,
      weeks,
      isRecurring);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeSlotImplCopyWith<_$TimeSlotImpl> get copyWith =>
      __$$TimeSlotImplCopyWithImpl<_$TimeSlotImpl>(this, _$identity);
}

abstract class _TimeSlot implements TimeSlot {
  const factory _TimeSlot(
      {required final String id,
      required final String startTime,
      required final String endTime,
      required final String status,
      final String? courseName,
      final String? teacherName,
      final String? department,
      final String? className,
      final int? weekday,
      final String? weeks,
      final bool isRecurring}) = _$TimeSlotImpl;

  @override
  String get id;
  @override
  String get startTime;
  @override
  String get endTime;
  @override
  String get status;
  @override // available, occupied, maintenance
  String? get courseName;
  @override
  String? get teacherName;
  @override
  String? get department;
  @override
  String? get className;
  @override
  int? get weekday;
  @override // 1-7
  String? get weeks;
  @override // e.g., "1-18"
  bool get isRecurring;
  @override
  @JsonKey(ignore: true)
  _$$TimeSlotImplCopyWith<_$TimeSlotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ClassroomUsage {
  ClassroomDetail get room => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  List<TimeSlot> get timeSlots => throw _privateConstructorUsedError;
  int? get weekday => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ClassroomUsageCopyWith<ClassroomUsage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassroomUsageCopyWith<$Res> {
  factory $ClassroomUsageCopyWith(
          ClassroomUsage value, $Res Function(ClassroomUsage) then) =
      _$ClassroomUsageCopyWithImpl<$Res, ClassroomUsage>;
  @useResult
  $Res call(
      {ClassroomDetail room,
      String date,
      List<TimeSlot> timeSlots,
      int? weekday});

  $ClassroomDetailCopyWith<$Res> get room;
}

/// @nodoc
class _$ClassroomUsageCopyWithImpl<$Res, $Val extends ClassroomUsage>
    implements $ClassroomUsageCopyWith<$Res> {
  _$ClassroomUsageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? room = null,
    Object? date = null,
    Object? timeSlots = null,
    Object? weekday = freezed,
  }) {
    return _then(_value.copyWith(
      room: null == room
          ? _value.room
          : room // ignore: cast_nullable_to_non_nullable
              as ClassroomDetail,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      timeSlots: null == timeSlots
          ? _value.timeSlots
          : timeSlots // ignore: cast_nullable_to_non_nullable
              as List<TimeSlot>,
      weekday: freezed == weekday
          ? _value.weekday
          : weekday // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ClassroomDetailCopyWith<$Res> get room {
    return $ClassroomDetailCopyWith<$Res>(_value.room, (value) {
      return _then(_value.copyWith(room: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ClassroomUsageImplCopyWith<$Res>
    implements $ClassroomUsageCopyWith<$Res> {
  factory _$$ClassroomUsageImplCopyWith(_$ClassroomUsageImpl value,
          $Res Function(_$ClassroomUsageImpl) then) =
      __$$ClassroomUsageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ClassroomDetail room,
      String date,
      List<TimeSlot> timeSlots,
      int? weekday});

  @override
  $ClassroomDetailCopyWith<$Res> get room;
}

/// @nodoc
class __$$ClassroomUsageImplCopyWithImpl<$Res>
    extends _$ClassroomUsageCopyWithImpl<$Res, _$ClassroomUsageImpl>
    implements _$$ClassroomUsageImplCopyWith<$Res> {
  __$$ClassroomUsageImplCopyWithImpl(
      _$ClassroomUsageImpl _value, $Res Function(_$ClassroomUsageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? room = null,
    Object? date = null,
    Object? timeSlots = null,
    Object? weekday = freezed,
  }) {
    return _then(_$ClassroomUsageImpl(
      room: null == room
          ? _value.room
          : room // ignore: cast_nullable_to_non_nullable
              as ClassroomDetail,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      timeSlots: null == timeSlots
          ? _value._timeSlots
          : timeSlots // ignore: cast_nullable_to_non_nullable
              as List<TimeSlot>,
      weekday: freezed == weekday
          ? _value.weekday
          : weekday // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$ClassroomUsageImpl extends _ClassroomUsage {
  const _$ClassroomUsageImpl(
      {required this.room,
      required this.date,
      final List<TimeSlot> timeSlots = const [],
      this.weekday})
      : _timeSlots = timeSlots,
        super._();

  @override
  final ClassroomDetail room;
  @override
  final String date;
  final List<TimeSlot> _timeSlots;
  @override
  @JsonKey()
  List<TimeSlot> get timeSlots {
    if (_timeSlots is EqualUnmodifiableListView) return _timeSlots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_timeSlots);
  }

  @override
  final int? weekday;

  @override
  String toString() {
    return 'ClassroomUsage(room: $room, date: $date, timeSlots: $timeSlots, weekday: $weekday)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassroomUsageImpl &&
            (identical(other.room, room) || other.room == room) &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality()
                .equals(other._timeSlots, _timeSlots) &&
            (identical(other.weekday, weekday) || other.weekday == weekday));
  }

  @override
  int get hashCode => Object.hash(runtimeType, room, date,
      const DeepCollectionEquality().hash(_timeSlots), weekday);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassroomUsageImplCopyWith<_$ClassroomUsageImpl> get copyWith =>
      __$$ClassroomUsageImplCopyWithImpl<_$ClassroomUsageImpl>(
          this, _$identity);
}

abstract class _ClassroomUsage extends ClassroomUsage {
  const factory _ClassroomUsage(
      {required final ClassroomDetail room,
      required final String date,
      final List<TimeSlot> timeSlots,
      final int? weekday}) = _$ClassroomUsageImpl;
  const _ClassroomUsage._() : super._();

  @override
  ClassroomDetail get room;
  @override
  String get date;
  @override
  List<TimeSlot> get timeSlots;
  @override
  int? get weekday;
  @override
  @JsonKey(ignore: true)
  _$$ClassroomUsageImplCopyWith<_$ClassroomUsageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ClassroomUsageResponse _$ClassroomUsageResponseFromJson(
    Map<String, dynamic> json) {
  return _ClassroomUsageResponse.fromJson(json);
}

/// @nodoc
mixin _$ClassroomUsageResponse {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  dynamic get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ClassroomUsageResponseCopyWith<ClassroomUsageResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassroomUsageResponseCopyWith<$Res> {
  factory $ClassroomUsageResponseCopyWith(ClassroomUsageResponse value,
          $Res Function(ClassroomUsageResponse) then) =
      _$ClassroomUsageResponseCopyWithImpl<$Res, ClassroomUsageResponse>;
  @useResult
  $Res call({bool success, String message, dynamic data});
}

/// @nodoc
class _$ClassroomUsageResponseCopyWithImpl<$Res,
        $Val extends ClassroomUsageResponse>
    implements $ClassroomUsageResponseCopyWith<$Res> {
  _$ClassroomUsageResponseCopyWithImpl(this._value, this._then);

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
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClassroomUsageResponseImplCopyWith<$Res>
    implements $ClassroomUsageResponseCopyWith<$Res> {
  factory _$$ClassroomUsageResponseImplCopyWith(
          _$ClassroomUsageResponseImpl value,
          $Res Function(_$ClassroomUsageResponseImpl) then) =
      __$$ClassroomUsageResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, String message, dynamic data});
}

/// @nodoc
class __$$ClassroomUsageResponseImplCopyWithImpl<$Res>
    extends _$ClassroomUsageResponseCopyWithImpl<$Res,
        _$ClassroomUsageResponseImpl>
    implements _$$ClassroomUsageResponseImplCopyWith<$Res> {
  __$$ClassroomUsageResponseImplCopyWithImpl(
      _$ClassroomUsageResponseImpl _value,
      $Res Function(_$ClassroomUsageResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = freezed,
  }) {
    return _then(_$ClassroomUsageResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      data: freezed == data ? _value.data! : data,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClassroomUsageResponseImpl implements _ClassroomUsageResponse {
  const _$ClassroomUsageResponseImpl(
      {required this.success, required this.message, this.data});

  factory _$ClassroomUsageResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClassroomUsageResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  @override
  final dynamic data;

  @override
  String toString() {
    return 'ClassroomUsageResponse(success: $success, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassroomUsageResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, success, message, const DeepCollectionEquality().hash(data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassroomUsageResponseImplCopyWith<_$ClassroomUsageResponseImpl>
      get copyWith => __$$ClassroomUsageResponseImplCopyWithImpl<
          _$ClassroomUsageResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClassroomUsageResponseImplToJson(
      this,
    );
  }
}

abstract class _ClassroomUsageResponse implements ClassroomUsageResponse {
  const factory _ClassroomUsageResponse(
      {required final bool success,
      required final String message,
      final dynamic data}) = _$ClassroomUsageResponseImpl;

  factory _ClassroomUsageResponse.fromJson(Map<String, dynamic> json) =
      _$ClassroomUsageResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  dynamic get data;
  @override
  @JsonKey(ignore: true)
  _$$ClassroomUsageResponseImplCopyWith<_$ClassroomUsageResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ClassroomUsageData {
  ClassroomDetail get room => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  List<TimeSlot> get timeSlots => throw _privateConstructorUsedError;
  int? get weekday => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ClassroomUsageDataCopyWith<ClassroomUsageData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassroomUsageDataCopyWith<$Res> {
  factory $ClassroomUsageDataCopyWith(
          ClassroomUsageData value, $Res Function(ClassroomUsageData) then) =
      _$ClassroomUsageDataCopyWithImpl<$Res, ClassroomUsageData>;
  @useResult
  $Res call(
      {ClassroomDetail room,
      String date,
      List<TimeSlot> timeSlots,
      int? weekday});

  $ClassroomDetailCopyWith<$Res> get room;
}

/// @nodoc
class _$ClassroomUsageDataCopyWithImpl<$Res, $Val extends ClassroomUsageData>
    implements $ClassroomUsageDataCopyWith<$Res> {
  _$ClassroomUsageDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? room = null,
    Object? date = null,
    Object? timeSlots = null,
    Object? weekday = freezed,
  }) {
    return _then(_value.copyWith(
      room: null == room
          ? _value.room
          : room // ignore: cast_nullable_to_non_nullable
              as ClassroomDetail,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      timeSlots: null == timeSlots
          ? _value.timeSlots
          : timeSlots // ignore: cast_nullable_to_non_nullable
              as List<TimeSlot>,
      weekday: freezed == weekday
          ? _value.weekday
          : weekday // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ClassroomDetailCopyWith<$Res> get room {
    return $ClassroomDetailCopyWith<$Res>(_value.room, (value) {
      return _then(_value.copyWith(room: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ClassroomUsageDataImplCopyWith<$Res>
    implements $ClassroomUsageDataCopyWith<$Res> {
  factory _$$ClassroomUsageDataImplCopyWith(_$ClassroomUsageDataImpl value,
          $Res Function(_$ClassroomUsageDataImpl) then) =
      __$$ClassroomUsageDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ClassroomDetail room,
      String date,
      List<TimeSlot> timeSlots,
      int? weekday});

  @override
  $ClassroomDetailCopyWith<$Res> get room;
}

/// @nodoc
class __$$ClassroomUsageDataImplCopyWithImpl<$Res>
    extends _$ClassroomUsageDataCopyWithImpl<$Res, _$ClassroomUsageDataImpl>
    implements _$$ClassroomUsageDataImplCopyWith<$Res> {
  __$$ClassroomUsageDataImplCopyWithImpl(_$ClassroomUsageDataImpl _value,
      $Res Function(_$ClassroomUsageDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? room = null,
    Object? date = null,
    Object? timeSlots = null,
    Object? weekday = freezed,
  }) {
    return _then(_$ClassroomUsageDataImpl(
      room: null == room
          ? _value.room
          : room // ignore: cast_nullable_to_non_nullable
              as ClassroomDetail,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      timeSlots: null == timeSlots
          ? _value._timeSlots
          : timeSlots // ignore: cast_nullable_to_non_nullable
              as List<TimeSlot>,
      weekday: freezed == weekday
          ? _value.weekday
          : weekday // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$ClassroomUsageDataImpl implements _ClassroomUsageData {
  const _$ClassroomUsageDataImpl(
      {required this.room,
      required this.date,
      final List<TimeSlot> timeSlots = const [],
      this.weekday})
      : _timeSlots = timeSlots;

  @override
  final ClassroomDetail room;
  @override
  final String date;
  final List<TimeSlot> _timeSlots;
  @override
  @JsonKey()
  List<TimeSlot> get timeSlots {
    if (_timeSlots is EqualUnmodifiableListView) return _timeSlots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_timeSlots);
  }

  @override
  final int? weekday;

  @override
  String toString() {
    return 'ClassroomUsageData(room: $room, date: $date, timeSlots: $timeSlots, weekday: $weekday)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassroomUsageDataImpl &&
            (identical(other.room, room) || other.room == room) &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality()
                .equals(other._timeSlots, _timeSlots) &&
            (identical(other.weekday, weekday) || other.weekday == weekday));
  }

  @override
  int get hashCode => Object.hash(runtimeType, room, date,
      const DeepCollectionEquality().hash(_timeSlots), weekday);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassroomUsageDataImplCopyWith<_$ClassroomUsageDataImpl> get copyWith =>
      __$$ClassroomUsageDataImplCopyWithImpl<_$ClassroomUsageDataImpl>(
          this, _$identity);
}

abstract class _ClassroomUsageData implements ClassroomUsageData {
  const factory _ClassroomUsageData(
      {required final ClassroomDetail room,
      required final String date,
      final List<TimeSlot> timeSlots,
      final int? weekday}) = _$ClassroomUsageDataImpl;

  @override
  ClassroomDetail get room;
  @override
  String get date;
  @override
  List<TimeSlot> get timeSlots;
  @override
  int? get weekday;
  @override
  @JsonKey(ignore: true)
  _$$ClassroomUsageDataImplCopyWith<_$ClassroomUsageDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ClassroomState {
  List<ClassroomCategory> get categories => throw _privateConstructorUsedError;
  String? get selectedCategoryId => throw _privateConstructorUsedError;
  List<ClassroomRoom> get rooms => throw _privateConstructorUsedError;
  ClassroomDetail? get selectedRoom => throw _privateConstructorUsedError;
  ClassroomUsageData? get usageData => throw _privateConstructorUsedError;
  String? get usageDate => throw _privateConstructorUsedError;
  bool get isLoadingCategories => throw _privateConstructorUsedError;
  bool get isLoadingRooms => throw _privateConstructorUsedError;
  bool get isLoadingDetail => throw _privateConstructorUsedError;
  bool get isLoadingUsage => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ClassroomStateCopyWith<ClassroomState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassroomStateCopyWith<$Res> {
  factory $ClassroomStateCopyWith(
          ClassroomState value, $Res Function(ClassroomState) then) =
      _$ClassroomStateCopyWithImpl<$Res, ClassroomState>;
  @useResult
  $Res call(
      {List<ClassroomCategory> categories,
      String? selectedCategoryId,
      List<ClassroomRoom> rooms,
      ClassroomDetail? selectedRoom,
      ClassroomUsageData? usageData,
      String? usageDate,
      bool isLoadingCategories,
      bool isLoadingRooms,
      bool isLoadingDetail,
      bool isLoadingUsage,
      String? error});

  $ClassroomDetailCopyWith<$Res>? get selectedRoom;
  $ClassroomUsageDataCopyWith<$Res>? get usageData;
}

/// @nodoc
class _$ClassroomStateCopyWithImpl<$Res, $Val extends ClassroomState>
    implements $ClassroomStateCopyWith<$Res> {
  _$ClassroomStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categories = null,
    Object? selectedCategoryId = freezed,
    Object? rooms = null,
    Object? selectedRoom = freezed,
    Object? usageData = freezed,
    Object? usageDate = freezed,
    Object? isLoadingCategories = null,
    Object? isLoadingRooms = null,
    Object? isLoadingDetail = null,
    Object? isLoadingUsage = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      categories: null == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<ClassroomCategory>,
      selectedCategoryId: freezed == selectedCategoryId
          ? _value.selectedCategoryId
          : selectedCategoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      rooms: null == rooms
          ? _value.rooms
          : rooms // ignore: cast_nullable_to_non_nullable
              as List<ClassroomRoom>,
      selectedRoom: freezed == selectedRoom
          ? _value.selectedRoom
          : selectedRoom // ignore: cast_nullable_to_non_nullable
              as ClassroomDetail?,
      usageData: freezed == usageData
          ? _value.usageData
          : usageData // ignore: cast_nullable_to_non_nullable
              as ClassroomUsageData?,
      usageDate: freezed == usageDate
          ? _value.usageDate
          : usageDate // ignore: cast_nullable_to_non_nullable
              as String?,
      isLoadingCategories: null == isLoadingCategories
          ? _value.isLoadingCategories
          : isLoadingCategories // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingRooms: null == isLoadingRooms
          ? _value.isLoadingRooms
          : isLoadingRooms // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingDetail: null == isLoadingDetail
          ? _value.isLoadingDetail
          : isLoadingDetail // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingUsage: null == isLoadingUsage
          ? _value.isLoadingUsage
          : isLoadingUsage // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ClassroomDetailCopyWith<$Res>? get selectedRoom {
    if (_value.selectedRoom == null) {
      return null;
    }

    return $ClassroomDetailCopyWith<$Res>(_value.selectedRoom!, (value) {
      return _then(_value.copyWith(selectedRoom: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $ClassroomUsageDataCopyWith<$Res>? get usageData {
    if (_value.usageData == null) {
      return null;
    }

    return $ClassroomUsageDataCopyWith<$Res>(_value.usageData!, (value) {
      return _then(_value.copyWith(usageData: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ClassroomStateImplCopyWith<$Res>
    implements $ClassroomStateCopyWith<$Res> {
  factory _$$ClassroomStateImplCopyWith(_$ClassroomStateImpl value,
          $Res Function(_$ClassroomStateImpl) then) =
      __$$ClassroomStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<ClassroomCategory> categories,
      String? selectedCategoryId,
      List<ClassroomRoom> rooms,
      ClassroomDetail? selectedRoom,
      ClassroomUsageData? usageData,
      String? usageDate,
      bool isLoadingCategories,
      bool isLoadingRooms,
      bool isLoadingDetail,
      bool isLoadingUsage,
      String? error});

  @override
  $ClassroomDetailCopyWith<$Res>? get selectedRoom;
  @override
  $ClassroomUsageDataCopyWith<$Res>? get usageData;
}

/// @nodoc
class __$$ClassroomStateImplCopyWithImpl<$Res>
    extends _$ClassroomStateCopyWithImpl<$Res, _$ClassroomStateImpl>
    implements _$$ClassroomStateImplCopyWith<$Res> {
  __$$ClassroomStateImplCopyWithImpl(
      _$ClassroomStateImpl _value, $Res Function(_$ClassroomStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categories = null,
    Object? selectedCategoryId = freezed,
    Object? rooms = null,
    Object? selectedRoom = freezed,
    Object? usageData = freezed,
    Object? usageDate = freezed,
    Object? isLoadingCategories = null,
    Object? isLoadingRooms = null,
    Object? isLoadingDetail = null,
    Object? isLoadingUsage = null,
    Object? error = freezed,
  }) {
    return _then(_$ClassroomStateImpl(
      categories: null == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<ClassroomCategory>,
      selectedCategoryId: freezed == selectedCategoryId
          ? _value.selectedCategoryId
          : selectedCategoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      rooms: null == rooms
          ? _value._rooms
          : rooms // ignore: cast_nullable_to_non_nullable
              as List<ClassroomRoom>,
      selectedRoom: freezed == selectedRoom
          ? _value.selectedRoom
          : selectedRoom // ignore: cast_nullable_to_non_nullable
              as ClassroomDetail?,
      usageData: freezed == usageData
          ? _value.usageData
          : usageData // ignore: cast_nullable_to_non_nullable
              as ClassroomUsageData?,
      usageDate: freezed == usageDate
          ? _value.usageDate
          : usageDate // ignore: cast_nullable_to_non_nullable
              as String?,
      isLoadingCategories: null == isLoadingCategories
          ? _value.isLoadingCategories
          : isLoadingCategories // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingRooms: null == isLoadingRooms
          ? _value.isLoadingRooms
          : isLoadingRooms // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingDetail: null == isLoadingDetail
          ? _value.isLoadingDetail
          : isLoadingDetail // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingUsage: null == isLoadingUsage
          ? _value.isLoadingUsage
          : isLoadingUsage // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ClassroomStateImpl implements _ClassroomState {
  const _$ClassroomStateImpl(
      {final List<ClassroomCategory> categories = const [],
      this.selectedCategoryId,
      final List<ClassroomRoom> rooms = const [],
      this.selectedRoom,
      this.usageData,
      this.usageDate,
      this.isLoadingCategories = false,
      this.isLoadingRooms = false,
      this.isLoadingDetail = false,
      this.isLoadingUsage = false,
      this.error})
      : _categories = categories,
        _rooms = rooms;

  final List<ClassroomCategory> _categories;
  @override
  @JsonKey()
  List<ClassroomCategory> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  @override
  final String? selectedCategoryId;
  final List<ClassroomRoom> _rooms;
  @override
  @JsonKey()
  List<ClassroomRoom> get rooms {
    if (_rooms is EqualUnmodifiableListView) return _rooms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rooms);
  }

  @override
  final ClassroomDetail? selectedRoom;
  @override
  final ClassroomUsageData? usageData;
  @override
  final String? usageDate;
  @override
  @JsonKey()
  final bool isLoadingCategories;
  @override
  @JsonKey()
  final bool isLoadingRooms;
  @override
  @JsonKey()
  final bool isLoadingDetail;
  @override
  @JsonKey()
  final bool isLoadingUsage;
  @override
  final String? error;

  @override
  String toString() {
    return 'ClassroomState(categories: $categories, selectedCategoryId: $selectedCategoryId, rooms: $rooms, selectedRoom: $selectedRoom, usageData: $usageData, usageDate: $usageDate, isLoadingCategories: $isLoadingCategories, isLoadingRooms: $isLoadingRooms, isLoadingDetail: $isLoadingDetail, isLoadingUsage: $isLoadingUsage, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassroomStateImpl &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories) &&
            (identical(other.selectedCategoryId, selectedCategoryId) ||
                other.selectedCategoryId == selectedCategoryId) &&
            const DeepCollectionEquality().equals(other._rooms, _rooms) &&
            (identical(other.selectedRoom, selectedRoom) ||
                other.selectedRoom == selectedRoom) &&
            (identical(other.usageData, usageData) ||
                other.usageData == usageData) &&
            (identical(other.usageDate, usageDate) ||
                other.usageDate == usageDate) &&
            (identical(other.isLoadingCategories, isLoadingCategories) ||
                other.isLoadingCategories == isLoadingCategories) &&
            (identical(other.isLoadingRooms, isLoadingRooms) ||
                other.isLoadingRooms == isLoadingRooms) &&
            (identical(other.isLoadingDetail, isLoadingDetail) ||
                other.isLoadingDetail == isLoadingDetail) &&
            (identical(other.isLoadingUsage, isLoadingUsage) ||
                other.isLoadingUsage == isLoadingUsage) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_categories),
      selectedCategoryId,
      const DeepCollectionEquality().hash(_rooms),
      selectedRoom,
      usageData,
      usageDate,
      isLoadingCategories,
      isLoadingRooms,
      isLoadingDetail,
      isLoadingUsage,
      error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassroomStateImplCopyWith<_$ClassroomStateImpl> get copyWith =>
      __$$ClassroomStateImplCopyWithImpl<_$ClassroomStateImpl>(
          this, _$identity);
}

abstract class _ClassroomState implements ClassroomState {
  const factory _ClassroomState(
      {final List<ClassroomCategory> categories,
      final String? selectedCategoryId,
      final List<ClassroomRoom> rooms,
      final ClassroomDetail? selectedRoom,
      final ClassroomUsageData? usageData,
      final String? usageDate,
      final bool isLoadingCategories,
      final bool isLoadingRooms,
      final bool isLoadingDetail,
      final bool isLoadingUsage,
      final String? error}) = _$ClassroomStateImpl;

  @override
  List<ClassroomCategory> get categories;
  @override
  String? get selectedCategoryId;
  @override
  List<ClassroomRoom> get rooms;
  @override
  ClassroomDetail? get selectedRoom;
  @override
  ClassroomUsageData? get usageData;
  @override
  String? get usageDate;
  @override
  bool get isLoadingCategories;
  @override
  bool get isLoadingRooms;
  @override
  bool get isLoadingDetail;
  @override
  bool get isLoadingUsage;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$ClassroomStateImplCopyWith<_$ClassroomStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
