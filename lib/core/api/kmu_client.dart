// KMU API 客戶端
// 封裝 Dio、加密、簽名、Token 管理
// 對應 Python ikmu.py 實作

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../utils/crypto_utils.dart';
import '../constants/api_constants.dart';
import '../api/exceptions/api_exception.dart';

/// KMU API 客戶端
class KmuClient {
  KmuClient(this._dio);

  final Dio _dio;

  String _currentUserId = '';
  String _currentToken = '';

  /// 設定當前使用者憑證 (供後續 API 使用)
  void setCredentials({required String userId, required String token}) {
    _currentUserId = userId;
    _currentToken = token;
    _updateAuthHeaders();
  }

  /// 清除認證
  void clearCredentials() {
    _currentUserId = '';
    _currentToken = '';
    _dio.options.headers.remove('kmutoken');
    _dio.options.headers.remove('uevw');
    _dio.options.headers.remove('uevw2');
    _dio.options.headers.remove('akfw');
  }

  void _updateAuthHeaders() {
    if (_currentUserId.isNotEmpty) {
      _dio.options.headers['uevw'] = CryptoUtils.generateUevw(_currentUserId);
      _dio.options.headers['uevw2'] = CryptoUtils.generateUevw2ForLogin(_currentUserId);
      _dio.options.headers['akfw'] = kAkfw;
      _dio.options.headers['kmutoken'] = _currentToken;
    } else {
      // 未登入狀態：使用預設 UEVW
      _dio.options.headers['uevw'] = 'da39a3ee5e6b4b0d3255bfef95601890afd80709'; // SHA-1("")
      _dio.options.headers['uevw2'] = 'da39a3ee5e6b4b0d3255bfef95601890afd80709';
      _dio.options.headers['akfw'] = kAkfw;
      _dio.options.headers['kmutoken'] = '';
    }
    _dio.options.headers['User-Agent'] = 'Dalvik/2.1.0 (Linux; U; Android 10; AOSP on IA Emulator Build/QSR1.190920.001)';
    _dio.options.headers['Content-Type'] = 'application/x-www-form-urlencoded';
  }

  /// 登入 - 取得 kmutoken (對應 Python /verify 端點)
  Future<Map<String, dynamic>> login({
    required String userId,
    required String password,
    String? fcmToken,
  }) async {
    _currentUserId = userId;
    _currentToken = '';

    // 登入時 headers: uevw=SHA1(userId), uevw2=動態加密, akfw, kmutoken=""
    final uevw = CryptoUtils.generateUevw(userId);
    final uevw2 = CryptoUtils.generateUevw2ForLogin(userId);

    _dio.options.headers['uevw'] = uevw;
    _dio.options.headers['uevw2'] = uevw2;
    _dio.options.headers['akfw'] = kAkfw;
    _dio.options.headers['kmutoken'] = '';
    _dio.options.headers['Content-Type'] = 'application/x-www-form-urlencoded';
    _dio.options.headers['User-Agent'] = 'Dalvik/2.1.0 (Linux; U; Android 10; AOSP on IA Emulator Build/QSR1.190920.001)';

    if (kDebugMode) {
      print('[KmuClient] Login POST ${kKmuApiBaseUrl}${ApiEndpoints.login}');
    }
    print('[KmuClient] Headers: uevw=$uevw, uevw2=$uevw2, akfw=$kAkfw');

    try {
      // 依照 Python 格式: id, pw 加密後送 form-urlencoded
      final encryptedId = CryptoUtils.encrypt3DesHex(userId);
      final encryptedPw = CryptoUtils.encrypt3DesHex(password);

      final formData = {
        'id': encryptedId,
        'pw': encryptedPw,
        'os': 'android',
        't': fcmToken ?? 'clYnahsdT5s:APA91bEqL49atesEi9rXDtrD_8a0zVkVM18p-nYnfhECBGqgx1VcscbF3NJt6mlpF-qptS2rcK9TByn8FMXYQYWnLKLoLQ3UDRJAJer4b_IolxOEZWASKCE',
        'lang': '0',
        'device': 'AOSP on IA Emulator',
        'deviceid': 'flutter_${DateTime.now().millisecondsSinceEpoch}',
      };

      print('[KmuClient] Request body: $formData');

      final response = await _dio.post(
        ApiEndpoints.login,
        data: formData,
      );

      print('[KmuClient] Response status: ${response.statusCode}');
      print('[KmuClient] Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['result'].toString() == 'true') {
          final items = data['items'] as Map<String, dynamic>?;
          if (items != null && items['token'] != null) {
            final token = items['token'] as String;
            _currentToken = token;
            _updateAuthHeaders(); // 更新 headers 帶入 token
            return {
              'success': true,
              'message': data['reason']?.toString() ?? '登入成功',
              'data': items,
            };
          }
        }
        return {
          'success': false,
          'message': data['reason']?.toString() ?? '登入失敗',
        };
      }
      return {
        'success': false,
        'message': 'HTTP ${response.statusCode}: ${response.statusMessage}',
      };
    } on DioException catch (e) {
      print('[KmuClient] DioException: ${e.message}');
      print('[KmuClient] DioException response: ${e.response?.data}');
      print('[KmuClient] DioException status: ${e.response?.statusCode}');
      return {
        'success': false,
        'message': _extractDioError(e),
      };
    } catch (e, stack) {
      print('[KmuClient] Exception: $e');
      print('[KmuClient] Stack: $stack');
      return {
        'success': false,
        'message': '登入異常: $e',
      };
    }
  }

  /// 登出
  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } finally {
      clearCredentials();
    }
  }

  /// GET 請求 - 對應 Python GET 方式 (query parameters)
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      print('[KmuClient] GET $path query: $queryParameters');
      final response = await _dio.get(path, queryParameters: queryParameters);
      print('[KmuClient] GET response: ${response.data}');
      return _handleResponse(response);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  /// POST 請求 - 對應 Python POST 方式 (form data)
  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    try {
      print('[KmuClient] POST $path data: $data');
      final response = await _dio.post(path, data: data);
      print('[KmuClient] POST response: ${response.data}');
      return _handleResponse(response);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  /// 處理回應 - Python 格式 (result 為字串 "true"/"false")
  Map<String, dynamic> _handleResponse(Response response) {
    final responseData = response.data as Map<String, dynamic>;
    final result = responseData['result']?.toString();

    if (result == 'true') {
      return {
        'success': true,
        'message': responseData['reason']?.toString() ?? '成功',
        'data': responseData['items'],
      };
    }

    return {
      'success': false,
      'message': responseData['reason']?.toString() ?? '請求失敗',
    };
  }

  String _extractDioError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data['reason'] != null) {
        return data['reason'] as String;
      }
      return 'HTTP ${e.response!.statusCode}: ${e.response!.statusMessage}';
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '連線逾時，請檢查網路';
      case DioExceptionType.badResponse:
        return '伺服器錯誤 (${e.response?.statusCode})';
      case DioExceptionType.connectionError:
        return '無法連線到伺服器，請檢查網路';
      default:
        return '網路錯誤: ${e.message}';
    }
  }

  /// 取得原始 Dio 實例 (進階用法)
  Dio get dio => _dio;
}