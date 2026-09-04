// API 例外類別

import 'package:dio/dio.dart';

/// API 例外
class ApiException implements Exception {
  
  const ApiException({
    required this.statusCode,
    required this.message,
    this.code,
    this.details,
  });

  /// 從任意錯誤轉換
  factory ApiException.fromError(Object error) {
    if (error is ApiException) return error;
    if (error is DioException) return ApiException.fromDioException(error);
    return ApiException(statusCode: 0, message: error.toString(), code: 'UNKNOWN');
  }
  
  /// 401 Unauthorized
  factory ApiException.unauthorized({String message = '未授權，請重新登入'}) {
    return ApiException(statusCode: 401, message: message, code: 'UNAUTHORIZED');
  }
  
  /// 403 Forbidden
  factory ApiException.forbidden({String message = '權限不足'}) {
    return ApiException(statusCode: 403, message: message, code: 'FORBIDDEN');
  }
  
  /// 404 Not Found
  factory ApiException.notFound({String message = '資源不存在'}) {
    return ApiException(statusCode: 404, message: message, code: 'NOT_FOUND');
  }
  
  /// 429 Too Many Requests
  factory ApiException.tooManyRequests({String message = '請求過於頻繁'}) {
    return ApiException(statusCode: 429, message: message, code: 'RATE_LIMITED');
  }
  
  /// 5xx Server Error
  factory ApiException.serverError({String message = '伺服器錯誤'}) {
    return ApiException(statusCode: 500, message: message, code: 'SERVER_ERROR');
  }
  
  /// 從 DioException 轉換
  factory ApiException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const ApiException(statusCode: 408, message: '連線逾時', code: 'TIMEOUT');
      case DioExceptionType.connectionError:
        return const ApiException(statusCode: 0, message: '無法連線到伺服器', code: 'CONNECTION_ERROR');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final message = e.response?.data?['message'] as String? ?? '請求失敗';
        return ApiException(statusCode: statusCode, message: message);
      case DioExceptionType.cancel:
        return const ApiException(statusCode: 0, message: '請求已取消', code: 'CANCELLED');
      case DioExceptionType.unknown:
        return ApiException(statusCode: 0, message: '網路錯誤: ${e.message}', code: 'UNKNOWN');
      default:
        return const ApiException(statusCode: 0, message: '發生未知錯誤', code: 'UNKNOWN');
    }
  }
  final int statusCode;
  final String message;
  final String? code;
  final Map<String, dynamic>? details;
  
  @override
  String toString() => 'ApiException($statusCode): $message';
}