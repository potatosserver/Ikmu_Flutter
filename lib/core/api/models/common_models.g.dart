// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ApiResponseImpl _$$ApiResponseImplFromJson(Map<String, dynamic> json) =>
    _$ApiResponseImpl(
      success: json['success'] as bool,
      message: json['message'] as String,
      errorCode: (json['errorCode'] as num?)?.toInt(),
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ApiResponseImplToJson(_$ApiResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'errorCode': instance.errorCode,
      'data': instance.data,
    };

_$EmptyDataImpl _$$EmptyDataImplFromJson(Map<String, dynamic> json) =>
    _$EmptyDataImpl();

Map<String, dynamic> _$$EmptyDataImplToJson(_$EmptyDataImpl instance) =>
    <String, dynamic>{};

_$PaginationImpl _$$PaginationImplFromJson(Map<String, dynamic> json) =>
    _$PaginationImpl(
      page: (json['page'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      hasNext: json['hasNext'] as bool,
      hasPrev: json['hasPrev'] as bool,
    );

Map<String, dynamic> _$$PaginationImplToJson(_$PaginationImpl instance) =>
    <String, dynamic>{
      'page': instance.page,
      'pageSize': instance.pageSize,
      'total': instance.total,
      'totalPages': instance.totalPages,
      'hasNext': instance.hasNext,
      'hasPrev': instance.hasPrev,
    };

_$DepartmentInfoImpl _$$DepartmentInfoImplFromJson(Map<String, dynamic> json) =>
    _$DepartmentInfoImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      collegeId: json['collegeId'] as String?,
      collegeName: json['collegeName'] as String?,
    );

Map<String, dynamic> _$$DepartmentInfoImplToJson(
        _$DepartmentInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'collegeId': instance.collegeId,
      'collegeName': instance.collegeName,
    };

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userType: json['userType'] as String,
      deptId: json['deptId'] as String?,
      deptName: json['deptName'] as String?,
      grade: json['grade'] as String?,
      classId: json['classId'] as String?,
      className: json['className'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userName': instance.userName,
      'userType': instance.userType,
      'deptId': instance.deptId,
      'deptName': instance.deptName,
      'grade': instance.grade,
      'classId': instance.classId,
      'className': instance.className,
      'email': instance.email,
      'phone': instance.phone,
      'avatar': instance.avatar,
    };

_$LoginRequestImpl _$$LoginRequestImplFromJson(Map<String, dynamic> json) =>
    _$LoginRequestImpl(
      userId: json['userId'] as String,
      password: json['password'] as String,
      rememberMe: json['rememberMe'] as bool? ?? false,
      deviceId: json['deviceId'] as String?,
      deviceName: json['deviceName'] as String?,
    );

Map<String, dynamic> _$$LoginRequestImplToJson(_$LoginRequestImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'password': instance.password,
      'rememberMe': instance.rememberMe,
      'deviceId': instance.deviceId,
      'deviceName': instance.deviceName,
    };

_$LoginResponseImpl _$$LoginResponseImplFromJson(Map<String, dynamic> json) =>
    _$LoginResponseImpl(
      success: json['success'] as bool,
      message: json['message'] as String,
      token: json['token'] as String?,
      userInfo: json['userInfo'] == null
          ? null
          : UserProfile.fromJson(json['userInfo'] as Map<String, dynamic>),
      expiresIn: (json['expiresIn'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$LoginResponseImplToJson(_$LoginResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'token': instance.token,
      'userInfo': instance.userInfo,
      'expiresIn': instance.expiresIn,
    };
