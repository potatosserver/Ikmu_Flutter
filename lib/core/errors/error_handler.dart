// 錯誤處理器

import 'package:flutter/foundation.dart';
import '../api/exceptions/api_exception.dart';
import '../api/exceptions/network_exception.dart';

/// 全域錯誤處理
class ErrorHandler {
  ErrorHandler._();
  
  /// 處理錯誤並回傳使用者友善訊息
  static String handle(Object error, [StackTrace? stackTrace]) {
    if (error is ApiException) {
      return _handleApiException(error);
    }
    
    if (error is NetworkException) {
      return error.message;
    }
    
    if (error is FormatException) {
      return '資料格式錯誤';
    }
    
    if (error is TypeError) {
      return '類型轉換錯誤';
    }
    
    if (error is StateError) {
      return error.message;
    }
    
    // 未知錯誤
    if (kDebugMode) {
      debugPrint('未處理的錯誤: $error');
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
    
    return '發生未知錯誤，請稍後再試';
  }
  
  static String _handleApiException(ApiException e) {
    switch (e.code) {
      case 'UNAUTHORIZED':
        return '登入已過期，請重新登入';
      case 'FORBIDDEN':
        return '權限不足，無法存取此功能';
      case 'NOT_FOUND':
        return '找不到請求的資源';
      case 'RATE_LIMITED':
        return '操作過於頻繁，請稍後再試';
      case 'SERVER_ERROR':
        return '伺服器暫時無法回應，請稍後再試';
      case 'TIMEOUT':
        return '請求逾時，請檢查網路後重試';
      case 'CONNECTION_ERROR':
        return '無法連線到伺服器，請檢查網路';
      case 'CANCELLED':
        return '請求已取消';
      default:
        return e.message;
    }
  }
  
  /// 記錄錯誤 (可整合 Sentry/Crashlytics)
  static void logError(Object error, StackTrace? stackTrace, {String? context}) {
    final message = StringBuffer();
    if (context != null) message.write('[$context] ');
    message.write(error.toString());
    
    if (kDebugMode) {
      debugPrint('[ERROR] $message');
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
    
    // TODO: 發送到錯誤監控服務
    // Sentry.captureException(error, stackTrace: stackTrace);
  }
}