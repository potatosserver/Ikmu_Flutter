// 網路例外類別

import 'package:dio/dio.dart';

/// 網路例外
class NetworkException implements Exception {
  
  const NetworkException({
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  /// 無網路連線
  factory NetworkException.noConnection() {
    return const NetworkException(message: '無網路連線，請檢查網路設定');
  }

  /// 連線逾時
  factory NetworkException.timeout() {
    return const NetworkException(message: '連線逾時，請稍後再試');
  }

  /// DNS 解析失敗
  factory NetworkException.dnsError() {
    return const NetworkException(message: '無法解析伺服器位址');
  }

  /// SSL 錯誤
  factory NetworkException.sslError() {
    return const NetworkException(message: '安全連線錯誤');
  }

  /// 從 DioException 轉換
  factory NetworkException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkException.timeout();
      case DioExceptionType.connectionError:
        if (e.error.toString().contains('SocketException')) {
          return NetworkException.noConnection();
        }
        return NetworkException(message: '連線錯誤: ${e.message}');
      case DioExceptionType.badCertificate:
        return NetworkException.sslError();
      default:
        return NetworkException(message: e.message ?? '網路錯誤');
    }
  }
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;

  @override
  String toString() => 'NetworkException: $message';
}