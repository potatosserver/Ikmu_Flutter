// KMU API 回應模型定義
// 使用 Freezed + json_serializable
// 基礎類別，不依賴其他模型

import 'package:freezed_annotation/freezed_annotation.dart';

part 'common_models.freezed.dart';
part 'common_models.g.dart';

/// 通用 API 回應包裝 (基礎版)
@freezed
abstract class ApiResponse with _$ApiResponse {
  const factory ApiResponse({
    required bool success,
    required String message,
    int? errorCode,
    data,
  }) = _ApiResponse;

  factory ApiResponse.fromJson(Map<String, dynamic> json) => _$ApiResponseFromJson(json);
}

/// ApiResponse 擴展方法
extension ApiResponseExtension on ApiResponse {
  /// 嘗試將 data 轉換為指定型別 (單一物件)
  T? dataAs<T>(T Function(Object?) fromJsonT) {
    if (data == null) return null;
    if (data is List) return null; // List 請用 dataAsList
    return fromJsonT(data);
  }

  /// 嘗試將 data 轉換為指定型別列表
  List<T>? dataAsList<T>(T Function(Object?) fromJsonT) {
    if (data == null) return null;
    if (data is! List) return null;
    return (data as List).map((e) => fromJsonT(e)).toList();
  }
}

/// 空資料回應
@freezed
abstract class EmptyData with _$EmptyData {
  const factory EmptyData() = _EmptyData;
  factory EmptyData.fromJson(Map<String, dynamic> json) => _$EmptyDataFromJson(json);
}

/// 分頁資訊
@freezed
abstract class Pagination with _$Pagination {
  const factory Pagination({
    required int page,
    required int pageSize,
    required int total,
    required int totalPages,
    required bool hasNext,
    required bool hasPrev,
  }) = _Pagination;

  factory Pagination.fromJson(Map<String, dynamic> json) => _$PaginationFromJson(json);
}

/// API 錯誤代碼
enum ApiErrorCode {
  unknown,
  invalidCredentials,
  tokenExpired,
  tokenInvalid,
  permissionDenied,
  paramMissing,
  paramInvalid,
  serverError,
  serviceUnavailable,
  dataNotFound,
  dataConflict,
  rateLimited,
  ipBlocked,
}

/// 擴展方法
extension ApiErrorCodeExtension on ApiErrorCode {
  String get message {
    switch (this) {
      case ApiErrorCode.invalidCredentials:
        return '帳號或密碼錯誤';
      case ApiErrorCode.tokenExpired:
        return '登入已過期，請重新登入';
      case ApiErrorCode.tokenInvalid:
        return '無效的登入憑證';
      case ApiErrorCode.permissionDenied:
        return '權限不足';
      case ApiErrorCode.paramMissing:
        return '缺少必要參數';
      case ApiErrorCode.paramInvalid:
        return '參數格式錯誤';
      case ApiErrorCode.serverError:
        return '伺服器內部錯誤';
      case ApiErrorCode.serviceUnavailable:
        return '服務暫時不可用';
      case ApiErrorCode.dataNotFound:
        return '查無資料';
      case ApiErrorCode.dataConflict:
        return '資料衝突';
      case ApiErrorCode.rateLimited:
        return '請求過於頻繁，請稍後再試';
      case ApiErrorCode.ipBlocked:
        return 'IP 已被封鎖';
      default:
        return '未知錯誤';
    }
  }
}

/// 學期資訊
/// Python API 回傳格式: {sem: 1, syear: 115} (id 需要從 syear+sem 組合)
@freezed
abstract class SemesterInfo with _$SemesterInfo {
  const factory SemesterInfo({
    required String id,
    required String name,
    required bool isCurrent,
    String? startDate,
    String? endDate,
  }) = _SemesterInfo;

  factory SemesterInfo.fromJson(Map<String, dynamic> json) {
    // Python API: 學期用 syear (學年) + sem (學期) 表示
    final syear = json['syear'] ?? json['year'] ?? json['id'];
    final sem = json['sem'] ?? '';
    final syearStr = syear?.toString() ?? '';
    final id = syearStr.isNotEmpty && sem.toString().isNotEmpty
        ? '$syearStr-$sem'
        : (syear?.toString() ?? '');
    final name = json['name']?.toString() ?? id;

    return SemesterInfo(
      id: id,
      name: name,
      isCurrent: json['isCurrent'] as bool? ?? false,
      startDate: json['startDate']?.toString(),
      endDate: json['endDate']?.toString(),
    );
  }
}

/// 系所資訊
@freezed
abstract class DepartmentInfo with _$DepartmentInfo {
  const factory DepartmentInfo({
    required String id,
    required String name,
    String? collegeId,
    String? collegeName,
  }) = _DepartmentInfo;

  factory DepartmentInfo.fromJson(Map<String, dynamic> json) => _$DepartmentInfoFromJson(json);
}

/// 使用者基本資訊
@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String userId,
    required String userName,
    required String userType,
    String? deptId,
    String? deptName,
    String? grade,
    String? classId,
    String? className,
    String? email,
    String? phone,
    String? avatar,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}

/// 登入請求
@freezed
abstract class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String userId,
    required String password,
    @Default(false) bool rememberMe,
    String? deviceId,
    String? deviceName,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
}

/// 登入回應
@freezed
abstract class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required bool success,
    required String message,
    String? token,
    UserProfile? userInfo,
    int? expiresIn,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
}