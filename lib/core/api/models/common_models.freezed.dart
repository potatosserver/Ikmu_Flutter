// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'common_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ApiResponse _$ApiResponseFromJson(Map<String, dynamic> json) {
  return _ApiResponse.fromJson(json);
}

/// @nodoc
mixin _$ApiResponse {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  int? get errorCode => throw _privateConstructorUsedError;
  Map<String, dynamic>? get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ApiResponseCopyWith<ApiResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiResponseCopyWith<$Res> {
  factory $ApiResponseCopyWith(
          ApiResponse value, $Res Function(ApiResponse) then) =
      _$ApiResponseCopyWithImpl<$Res, ApiResponse>;
  @useResult
  $Res call(
      {bool success,
      String message,
      int? errorCode,
      Map<String, dynamic>? data});
}

/// @nodoc
class _$ApiResponseCopyWithImpl<$Res, $Val extends ApiResponse>
    implements $ApiResponseCopyWith<$Res> {
  _$ApiResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? errorCode = freezed,
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
      errorCode: freezed == errorCode
          ? _value.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as int?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ApiResponseImplCopyWith<$Res>
    implements $ApiResponseCopyWith<$Res> {
  factory _$$ApiResponseImplCopyWith(
          _$ApiResponseImpl value, $Res Function(_$ApiResponseImpl) then) =
      __$$ApiResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool success,
      String message,
      int? errorCode,
      Map<String, dynamic>? data});
}

/// @nodoc
class __$$ApiResponseImplCopyWithImpl<$Res>
    extends _$ApiResponseCopyWithImpl<$Res, _$ApiResponseImpl>
    implements _$$ApiResponseImplCopyWith<$Res> {
  __$$ApiResponseImplCopyWithImpl(
      _$ApiResponseImpl _value, $Res Function(_$ApiResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? errorCode = freezed,
    Object? data = freezed,
  }) {
    return _then(_$ApiResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      errorCode: freezed == errorCode
          ? _value.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as int?,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ApiResponseImpl implements _ApiResponse {
  const _$ApiResponseImpl(
      {required this.success,
      required this.message,
      this.errorCode,
      final Map<String, dynamic>? data})
      : _data = data;

  factory _$ApiResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApiResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  @override
  final int? errorCode;
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
    return 'ApiResponse(success: $success, message: $message, errorCode: $errorCode, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.errorCode, errorCode) ||
                other.errorCode == errorCode) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, message, errorCode,
      const DeepCollectionEquality().hash(_data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiResponseImplCopyWith<_$ApiResponseImpl> get copyWith =>
      __$$ApiResponseImplCopyWithImpl<_$ApiResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ApiResponseImplToJson(
      this,
    );
  }
}

abstract class _ApiResponse implements ApiResponse {
  const factory _ApiResponse(
      {required final bool success,
      required final String message,
      final int? errorCode,
      final Map<String, dynamic>? data}) = _$ApiResponseImpl;

  factory _ApiResponse.fromJson(Map<String, dynamic> json) =
      _$ApiResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  int? get errorCode;
  @override
  Map<String, dynamic>? get data;
  @override
  @JsonKey(ignore: true)
  _$$ApiResponseImplCopyWith<_$ApiResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EmptyData _$EmptyDataFromJson(Map<String, dynamic> json) {
  return _EmptyData.fromJson(json);
}

/// @nodoc
mixin _$EmptyData {
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmptyDataCopyWith<$Res> {
  factory $EmptyDataCopyWith(EmptyData value, $Res Function(EmptyData) then) =
      _$EmptyDataCopyWithImpl<$Res, EmptyData>;
}

/// @nodoc
class _$EmptyDataCopyWithImpl<$Res, $Val extends EmptyData>
    implements $EmptyDataCopyWith<$Res> {
  _$EmptyDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$EmptyDataImplCopyWith<$Res> {
  factory _$$EmptyDataImplCopyWith(
          _$EmptyDataImpl value, $Res Function(_$EmptyDataImpl) then) =
      __$$EmptyDataImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$EmptyDataImplCopyWithImpl<$Res>
    extends _$EmptyDataCopyWithImpl<$Res, _$EmptyDataImpl>
    implements _$$EmptyDataImplCopyWith<$Res> {
  __$$EmptyDataImplCopyWithImpl(
      _$EmptyDataImpl _value, $Res Function(_$EmptyDataImpl) _then)
      : super(_value, _then);
}

/// @nodoc
@JsonSerializable()
class _$EmptyDataImpl implements _EmptyData {
  const _$EmptyDataImpl();

  factory _$EmptyDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmptyDataImplFromJson(json);

  @override
  String toString() {
    return 'EmptyData()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$EmptyDataImpl);
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => runtimeType.hashCode;

  @override
  Map<String, dynamic> toJson() {
    return _$$EmptyDataImplToJson(
      this,
    );
  }
}

abstract class _EmptyData implements EmptyData {
  const factory _EmptyData() = _$EmptyDataImpl;

  factory _EmptyData.fromJson(Map<String, dynamic> json) =
      _$EmptyDataImpl.fromJson;
}

Pagination _$PaginationFromJson(Map<String, dynamic> json) {
  return _Pagination.fromJson(json);
}

/// @nodoc
mixin _$Pagination {
  int get page => throw _privateConstructorUsedError;
  int get pageSize => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  bool get hasNext => throw _privateConstructorUsedError;
  bool get hasPrev => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PaginationCopyWith<Pagination> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaginationCopyWith<$Res> {
  factory $PaginationCopyWith(
          Pagination value, $Res Function(Pagination) then) =
      _$PaginationCopyWithImpl<$Res, Pagination>;
  @useResult
  $Res call(
      {int page,
      int pageSize,
      int total,
      int totalPages,
      bool hasNext,
      bool hasPrev});
}

/// @nodoc
class _$PaginationCopyWithImpl<$Res, $Val extends Pagination>
    implements $PaginationCopyWith<$Res> {
  _$PaginationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = null,
    Object? pageSize = null,
    Object? total = null,
    Object? totalPages = null,
    Object? hasNext = null,
    Object? hasPrev = null,
  }) {
    return _then(_value.copyWith(
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      hasNext: null == hasNext
          ? _value.hasNext
          : hasNext // ignore: cast_nullable_to_non_nullable
              as bool,
      hasPrev: null == hasPrev
          ? _value.hasPrev
          : hasPrev // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaginationImplCopyWith<$Res>
    implements $PaginationCopyWith<$Res> {
  factory _$$PaginationImplCopyWith(
          _$PaginationImpl value, $Res Function(_$PaginationImpl) then) =
      __$$PaginationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int page,
      int pageSize,
      int total,
      int totalPages,
      bool hasNext,
      bool hasPrev});
}

/// @nodoc
class __$$PaginationImplCopyWithImpl<$Res>
    extends _$PaginationCopyWithImpl<$Res, _$PaginationImpl>
    implements _$$PaginationImplCopyWith<$Res> {
  __$$PaginationImplCopyWithImpl(
      _$PaginationImpl _value, $Res Function(_$PaginationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = null,
    Object? pageSize = null,
    Object? total = null,
    Object? totalPages = null,
    Object? hasNext = null,
    Object? hasPrev = null,
  }) {
    return _then(_$PaginationImpl(
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      hasNext: null == hasNext
          ? _value.hasNext
          : hasNext // ignore: cast_nullable_to_non_nullable
              as bool,
      hasPrev: null == hasPrev
          ? _value.hasPrev
          : hasPrev // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PaginationImpl implements _Pagination {
  const _$PaginationImpl(
      {required this.page,
      required this.pageSize,
      required this.total,
      required this.totalPages,
      required this.hasNext,
      required this.hasPrev});

  factory _$PaginationImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaginationImplFromJson(json);

  @override
  final int page;
  @override
  final int pageSize;
  @override
  final int total;
  @override
  final int totalPages;
  @override
  final bool hasNext;
  @override
  final bool hasPrev;

  @override
  String toString() {
    return 'Pagination(page: $page, pageSize: $pageSize, total: $total, totalPages: $totalPages, hasNext: $hasNext, hasPrev: $hasPrev)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaginationImpl &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.hasNext, hasNext) || other.hasNext == hasNext) &&
            (identical(other.hasPrev, hasPrev) || other.hasPrev == hasPrev));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, page, pageSize, total, totalPages, hasNext, hasPrev);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PaginationImplCopyWith<_$PaginationImpl> get copyWith =>
      __$$PaginationImplCopyWithImpl<_$PaginationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaginationImplToJson(
      this,
    );
  }
}

abstract class _Pagination implements Pagination {
  const factory _Pagination(
      {required final int page,
      required final int pageSize,
      required final int total,
      required final int totalPages,
      required final bool hasNext,
      required final bool hasPrev}) = _$PaginationImpl;

  factory _Pagination.fromJson(Map<String, dynamic> json) =
      _$PaginationImpl.fromJson;

  @override
  int get page;
  @override
  int get pageSize;
  @override
  int get total;
  @override
  int get totalPages;
  @override
  bool get hasNext;
  @override
  bool get hasPrev;
  @override
  @JsonKey(ignore: true)
  _$$PaginationImplCopyWith<_$PaginationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SemesterInfo {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  bool get isCurrent => throw _privateConstructorUsedError;
  String? get startDate => throw _privateConstructorUsedError;
  String? get endDate => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SemesterInfoCopyWith<SemesterInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SemesterInfoCopyWith<$Res> {
  factory $SemesterInfoCopyWith(
          SemesterInfo value, $Res Function(SemesterInfo) then) =
      _$SemesterInfoCopyWithImpl<$Res, SemesterInfo>;
  @useResult
  $Res call(
      {String id,
      String name,
      bool isCurrent,
      String? startDate,
      String? endDate});
}

/// @nodoc
class _$SemesterInfoCopyWithImpl<$Res, $Val extends SemesterInfo>
    implements $SemesterInfoCopyWith<$Res> {
  _$SemesterInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? isCurrent = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
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
      isCurrent: null == isCurrent
          ? _value.isCurrent
          : isCurrent // ignore: cast_nullable_to_non_nullable
              as bool,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SemesterInfoImplCopyWith<$Res>
    implements $SemesterInfoCopyWith<$Res> {
  factory _$$SemesterInfoImplCopyWith(
          _$SemesterInfoImpl value, $Res Function(_$SemesterInfoImpl) then) =
      __$$SemesterInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      bool isCurrent,
      String? startDate,
      String? endDate});
}

/// @nodoc
class __$$SemesterInfoImplCopyWithImpl<$Res>
    extends _$SemesterInfoCopyWithImpl<$Res, _$SemesterInfoImpl>
    implements _$$SemesterInfoImplCopyWith<$Res> {
  __$$SemesterInfoImplCopyWithImpl(
      _$SemesterInfoImpl _value, $Res Function(_$SemesterInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? isCurrent = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
  }) {
    return _then(_$SemesterInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      isCurrent: null == isCurrent
          ? _value.isCurrent
          : isCurrent // ignore: cast_nullable_to_non_nullable
              as bool,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$SemesterInfoImpl implements _SemesterInfo {
  const _$SemesterInfoImpl(
      {required this.id,
      required this.name,
      required this.isCurrent,
      this.startDate,
      this.endDate});

  @override
  final String id;
  @override
  final String name;
  @override
  final bool isCurrent;
  @override
  final String? startDate;
  @override
  final String? endDate;

  @override
  String toString() {
    return 'SemesterInfo(id: $id, name: $name, isCurrent: $isCurrent, startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SemesterInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.isCurrent, isCurrent) ||
                other.isCurrent == isCurrent) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, isCurrent, startDate, endDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SemesterInfoImplCopyWith<_$SemesterInfoImpl> get copyWith =>
      __$$SemesterInfoImplCopyWithImpl<_$SemesterInfoImpl>(this, _$identity);
}

abstract class _SemesterInfo implements SemesterInfo {
  const factory _SemesterInfo(
      {required final String id,
      required final String name,
      required final bool isCurrent,
      final String? startDate,
      final String? endDate}) = _$SemesterInfoImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  bool get isCurrent;
  @override
  String? get startDate;
  @override
  String? get endDate;
  @override
  @JsonKey(ignore: true)
  _$$SemesterInfoImplCopyWith<_$SemesterInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DepartmentInfo _$DepartmentInfoFromJson(Map<String, dynamic> json) {
  return _DepartmentInfo.fromJson(json);
}

/// @nodoc
mixin _$DepartmentInfo {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get collegeId => throw _privateConstructorUsedError;
  String? get collegeName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DepartmentInfoCopyWith<DepartmentInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DepartmentInfoCopyWith<$Res> {
  factory $DepartmentInfoCopyWith(
          DepartmentInfo value, $Res Function(DepartmentInfo) then) =
      _$DepartmentInfoCopyWithImpl<$Res, DepartmentInfo>;
  @useResult
  $Res call({String id, String name, String? collegeId, String? collegeName});
}

/// @nodoc
class _$DepartmentInfoCopyWithImpl<$Res, $Val extends DepartmentInfo>
    implements $DepartmentInfoCopyWith<$Res> {
  _$DepartmentInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? collegeId = freezed,
    Object? collegeName = freezed,
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
      collegeId: freezed == collegeId
          ? _value.collegeId
          : collegeId // ignore: cast_nullable_to_non_nullable
              as String?,
      collegeName: freezed == collegeName
          ? _value.collegeName
          : collegeName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DepartmentInfoImplCopyWith<$Res>
    implements $DepartmentInfoCopyWith<$Res> {
  factory _$$DepartmentInfoImplCopyWith(_$DepartmentInfoImpl value,
          $Res Function(_$DepartmentInfoImpl) then) =
      __$$DepartmentInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String? collegeId, String? collegeName});
}

/// @nodoc
class __$$DepartmentInfoImplCopyWithImpl<$Res>
    extends _$DepartmentInfoCopyWithImpl<$Res, _$DepartmentInfoImpl>
    implements _$$DepartmentInfoImplCopyWith<$Res> {
  __$$DepartmentInfoImplCopyWithImpl(
      _$DepartmentInfoImpl _value, $Res Function(_$DepartmentInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? collegeId = freezed,
    Object? collegeName = freezed,
  }) {
    return _then(_$DepartmentInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      collegeId: freezed == collegeId
          ? _value.collegeId
          : collegeId // ignore: cast_nullable_to_non_nullable
              as String?,
      collegeName: freezed == collegeName
          ? _value.collegeName
          : collegeName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DepartmentInfoImpl implements _DepartmentInfo {
  const _$DepartmentInfoImpl(
      {required this.id, required this.name, this.collegeId, this.collegeName});

  factory _$DepartmentInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DepartmentInfoImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? collegeId;
  @override
  final String? collegeName;

  @override
  String toString() {
    return 'DepartmentInfo(id: $id, name: $name, collegeId: $collegeId, collegeName: $collegeName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DepartmentInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.collegeId, collegeId) ||
                other.collegeId == collegeId) &&
            (identical(other.collegeName, collegeName) ||
                other.collegeName == collegeName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, collegeId, collegeName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DepartmentInfoImplCopyWith<_$DepartmentInfoImpl> get copyWith =>
      __$$DepartmentInfoImplCopyWithImpl<_$DepartmentInfoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DepartmentInfoImplToJson(
      this,
    );
  }
}

abstract class _DepartmentInfo implements DepartmentInfo {
  const factory _DepartmentInfo(
      {required final String id,
      required final String name,
      final String? collegeId,
      final String? collegeName}) = _$DepartmentInfoImpl;

  factory _DepartmentInfo.fromJson(Map<String, dynamic> json) =
      _$DepartmentInfoImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get collegeId;
  @override
  String? get collegeName;
  @override
  @JsonKey(ignore: true)
  _$$DepartmentInfoImplCopyWith<_$DepartmentInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String get userType => throw _privateConstructorUsedError;
  String? get deptId => throw _privateConstructorUsedError;
  String? get deptName => throw _privateConstructorUsedError;
  String? get grade => throw _privateConstructorUsedError;
  String? get classId => throw _privateConstructorUsedError;
  String? get className => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
          UserProfile value, $Res Function(UserProfile) then) =
      _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call(
      {String userId,
      String userName,
      String userType,
      String? deptId,
      String? deptName,
      String? grade,
      String? classId,
      String? className,
      String? email,
      String? phone,
      String? avatar});
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? userType = null,
    Object? deptId = freezed,
    Object? deptName = freezed,
    Object? grade = freezed,
    Object? classId = freezed,
    Object? className = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? avatar = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      userType: null == userType
          ? _value.userType
          : userType // ignore: cast_nullable_to_non_nullable
              as String,
      deptId: freezed == deptId
          ? _value.deptId
          : deptId // ignore: cast_nullable_to_non_nullable
              as String?,
      deptName: freezed == deptName
          ? _value.deptName
          : deptName // ignore: cast_nullable_to_non_nullable
              as String?,
      grade: freezed == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as String?,
      classId: freezed == classId
          ? _value.classId
          : classId // ignore: cast_nullable_to_non_nullable
              as String?,
      className: freezed == className
          ? _value.className
          : className // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
          _$UserProfileImpl value, $Res Function(_$UserProfileImpl) then) =
      __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String userName,
      String userType,
      String? deptId,
      String? deptName,
      String? grade,
      String? classId,
      String? className,
      String? email,
      String? phone,
      String? avatar});
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
      _$UserProfileImpl _value, $Res Function(_$UserProfileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? userType = null,
    Object? deptId = freezed,
    Object? deptName = freezed,
    Object? grade = freezed,
    Object? classId = freezed,
    Object? className = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? avatar = freezed,
  }) {
    return _then(_$UserProfileImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      userType: null == userType
          ? _value.userType
          : userType // ignore: cast_nullable_to_non_nullable
              as String,
      deptId: freezed == deptId
          ? _value.deptId
          : deptId // ignore: cast_nullable_to_non_nullable
              as String?,
      deptName: freezed == deptName
          ? _value.deptName
          : deptName // ignore: cast_nullable_to_non_nullable
              as String?,
      grade: freezed == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as String?,
      classId: freezed == classId
          ? _value.classId
          : classId // ignore: cast_nullable_to_non_nullable
              as String?,
      className: freezed == className
          ? _value.className
          : className // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl(
      {required this.userId,
      required this.userName,
      required this.userType,
      this.deptId,
      this.deptName,
      this.grade,
      this.classId,
      this.className,
      this.email,
      this.phone,
      this.avatar});

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  final String userId;
  @override
  final String userName;
  @override
  final String userType;
  @override
  final String? deptId;
  @override
  final String? deptName;
  @override
  final String? grade;
  @override
  final String? classId;
  @override
  final String? className;
  @override
  final String? email;
  @override
  final String? phone;
  @override
  final String? avatar;

  @override
  String toString() {
    return 'UserProfile(userId: $userId, userName: $userName, userType: $userType, deptId: $deptId, deptName: $deptName, grade: $grade, classId: $classId, className: $className, email: $email, phone: $phone, avatar: $avatar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userType, userType) ||
                other.userType == userType) &&
            (identical(other.deptId, deptId) || other.deptId == deptId) &&
            (identical(other.deptName, deptName) ||
                other.deptName == deptName) &&
            (identical(other.grade, grade) || other.grade == grade) &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.className, className) ||
                other.className == className) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.avatar, avatar) || other.avatar == avatar));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, userId, userName, userType,
      deptId, deptName, grade, classId, className, email, phone, avatar);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(
      this,
    );
  }
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile(
      {required final String userId,
      required final String userName,
      required final String userType,
      final String? deptId,
      final String? deptName,
      final String? grade,
      final String? classId,
      final String? className,
      final String? email,
      final String? phone,
      final String? avatar}) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  String get userId;
  @override
  String get userName;
  @override
  String get userType;
  @override
  String? get deptId;
  @override
  String? get deptName;
  @override
  String? get grade;
  @override
  String? get classId;
  @override
  String? get className;
  @override
  String? get email;
  @override
  String? get phone;
  @override
  String? get avatar;
  @override
  @JsonKey(ignore: true)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) {
  return _LoginRequest.fromJson(json);
}

/// @nodoc
mixin _$LoginRequest {
  String get userId => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  bool get rememberMe => throw _privateConstructorUsedError;
  String? get deviceId => throw _privateConstructorUsedError;
  String? get deviceName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LoginRequestCopyWith<LoginRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginRequestCopyWith<$Res> {
  factory $LoginRequestCopyWith(
          LoginRequest value, $Res Function(LoginRequest) then) =
      _$LoginRequestCopyWithImpl<$Res, LoginRequest>;
  @useResult
  $Res call(
      {String userId,
      String password,
      bool rememberMe,
      String? deviceId,
      String? deviceName});
}

/// @nodoc
class _$LoginRequestCopyWithImpl<$Res, $Val extends LoginRequest>
    implements $LoginRequestCopyWith<$Res> {
  _$LoginRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? password = null,
    Object? rememberMe = null,
    Object? deviceId = freezed,
    Object? deviceName = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      rememberMe: null == rememberMe
          ? _value.rememberMe
          : rememberMe // ignore: cast_nullable_to_non_nullable
              as bool,
      deviceId: freezed == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceName: freezed == deviceName
          ? _value.deviceName
          : deviceName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoginRequestImplCopyWith<$Res>
    implements $LoginRequestCopyWith<$Res> {
  factory _$$LoginRequestImplCopyWith(
          _$LoginRequestImpl value, $Res Function(_$LoginRequestImpl) then) =
      __$$LoginRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String password,
      bool rememberMe,
      String? deviceId,
      String? deviceName});
}

/// @nodoc
class __$$LoginRequestImplCopyWithImpl<$Res>
    extends _$LoginRequestCopyWithImpl<$Res, _$LoginRequestImpl>
    implements _$$LoginRequestImplCopyWith<$Res> {
  __$$LoginRequestImplCopyWithImpl(
      _$LoginRequestImpl _value, $Res Function(_$LoginRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? password = null,
    Object? rememberMe = null,
    Object? deviceId = freezed,
    Object? deviceName = freezed,
  }) {
    return _then(_$LoginRequestImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      rememberMe: null == rememberMe
          ? _value.rememberMe
          : rememberMe // ignore: cast_nullable_to_non_nullable
              as bool,
      deviceId: freezed == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceName: freezed == deviceName
          ? _value.deviceName
          : deviceName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginRequestImpl implements _LoginRequest {
  const _$LoginRequestImpl(
      {required this.userId,
      required this.password,
      this.rememberMe = false,
      this.deviceId,
      this.deviceName});

  factory _$LoginRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginRequestImplFromJson(json);

  @override
  final String userId;
  @override
  final String password;
  @override
  @JsonKey()
  final bool rememberMe;
  @override
  final String? deviceId;
  @override
  final String? deviceName;

  @override
  String toString() {
    return 'LoginRequest(userId: $userId, password: $password, rememberMe: $rememberMe, deviceId: $deviceId, deviceName: $deviceName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginRequestImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.rememberMe, rememberMe) ||
                other.rememberMe == rememberMe) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.deviceName, deviceName) ||
                other.deviceName == deviceName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, userId, password, rememberMe, deviceId, deviceName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginRequestImplCopyWith<_$LoginRequestImpl> get copyWith =>
      __$$LoginRequestImplCopyWithImpl<_$LoginRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginRequestImplToJson(
      this,
    );
  }
}

abstract class _LoginRequest implements LoginRequest {
  const factory _LoginRequest(
      {required final String userId,
      required final String password,
      final bool rememberMe,
      final String? deviceId,
      final String? deviceName}) = _$LoginRequestImpl;

  factory _LoginRequest.fromJson(Map<String, dynamic> json) =
      _$LoginRequestImpl.fromJson;

  @override
  String get userId;
  @override
  String get password;
  @override
  bool get rememberMe;
  @override
  String? get deviceId;
  @override
  String? get deviceName;
  @override
  @JsonKey(ignore: true)
  _$$LoginRequestImplCopyWith<_$LoginRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) {
  return _LoginResponse.fromJson(json);
}

/// @nodoc
mixin _$LoginResponse {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String? get token => throw _privateConstructorUsedError;
  UserProfile? get userInfo => throw _privateConstructorUsedError;
  int? get expiresIn => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LoginResponseCopyWith<LoginResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginResponseCopyWith<$Res> {
  factory $LoginResponseCopyWith(
          LoginResponse value, $Res Function(LoginResponse) then) =
      _$LoginResponseCopyWithImpl<$Res, LoginResponse>;
  @useResult
  $Res call(
      {bool success,
      String message,
      String? token,
      UserProfile? userInfo,
      int? expiresIn});

  $UserProfileCopyWith<$Res>? get userInfo;
}

/// @nodoc
class _$LoginResponseCopyWithImpl<$Res, $Val extends LoginResponse>
    implements $LoginResponseCopyWith<$Res> {
  _$LoginResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? token = freezed,
    Object? userInfo = freezed,
    Object? expiresIn = freezed,
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
      token: freezed == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String?,
      userInfo: freezed == userInfo
          ? _value.userInfo
          : userInfo // ignore: cast_nullable_to_non_nullable
              as UserProfile?,
      expiresIn: freezed == expiresIn
          ? _value.expiresIn
          : expiresIn // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserProfileCopyWith<$Res>? get userInfo {
    if (_value.userInfo == null) {
      return null;
    }

    return $UserProfileCopyWith<$Res>(_value.userInfo!, (value) {
      return _then(_value.copyWith(userInfo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LoginResponseImplCopyWith<$Res>
    implements $LoginResponseCopyWith<$Res> {
  factory _$$LoginResponseImplCopyWith(
          _$LoginResponseImpl value, $Res Function(_$LoginResponseImpl) then) =
      __$$LoginResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool success,
      String message,
      String? token,
      UserProfile? userInfo,
      int? expiresIn});

  @override
  $UserProfileCopyWith<$Res>? get userInfo;
}

/// @nodoc
class __$$LoginResponseImplCopyWithImpl<$Res>
    extends _$LoginResponseCopyWithImpl<$Res, _$LoginResponseImpl>
    implements _$$LoginResponseImplCopyWith<$Res> {
  __$$LoginResponseImplCopyWithImpl(
      _$LoginResponseImpl _value, $Res Function(_$LoginResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? token = freezed,
    Object? userInfo = freezed,
    Object? expiresIn = freezed,
  }) {
    return _then(_$LoginResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      token: freezed == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String?,
      userInfo: freezed == userInfo
          ? _value.userInfo
          : userInfo // ignore: cast_nullable_to_non_nullable
              as UserProfile?,
      expiresIn: freezed == expiresIn
          ? _value.expiresIn
          : expiresIn // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginResponseImpl implements _LoginResponse {
  const _$LoginResponseImpl(
      {required this.success,
      required this.message,
      this.token,
      this.userInfo,
      this.expiresIn});

  factory _$LoginResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  @override
  final String? token;
  @override
  final UserProfile? userInfo;
  @override
  final int? expiresIn;

  @override
  String toString() {
    return 'LoginResponse(success: $success, message: $message, token: $token, userInfo: $userInfo, expiresIn: $expiresIn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.userInfo, userInfo) ||
                other.userInfo == userInfo) &&
            (identical(other.expiresIn, expiresIn) ||
                other.expiresIn == expiresIn));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, success, message, token, userInfo, expiresIn);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginResponseImplCopyWith<_$LoginResponseImpl> get copyWith =>
      __$$LoginResponseImplCopyWithImpl<_$LoginResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginResponseImplToJson(
      this,
    );
  }
}

abstract class _LoginResponse implements LoginResponse {
  const factory _LoginResponse(
      {required final bool success,
      required final String message,
      final String? token,
      final UserProfile? userInfo,
      final int? expiresIn}) = _$LoginResponseImpl;

  factory _LoginResponse.fromJson(Map<String, dynamic> json) =
      _$LoginResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  String? get token;
  @override
  UserProfile? get userInfo;
  @override
  int? get expiresIn;
  @override
  @JsonKey(ignore: true)
  _$$LoginResponseImplCopyWith<_$LoginResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
