// 認證控制器 - Riverpod 狀態管理
// 不使用 @freezed 避免代碼生成衝突

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../api/endpoints/endpoints.dart';
import '../api/models.dart';
import '../providers.dart';

/// 認證狀態
class AuthState {
  const AuthState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.userProfile,
    this.token,
    this.error,
    this.rememberMe = false,
    this.userId,
    this.password,
  });

  factory AuthState.initial() => const AuthState();
  final bool isLoading;
  final bool isLoggedIn;
  final UserProfile? userProfile;
  final String? token;
  final String? error;
  final bool rememberMe;
  final String? userId;
  final String? password;

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    UserProfile? userProfile,
    String? token,
    String? error,
    bool? rememberMe,
    String? userId,
    String? password,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userProfile: userProfile ?? this.userProfile,
      token: token ?? this.token,
      error: error ?? this.error,
      rememberMe: rememberMe ?? this.rememberMe,
      userId: userId ?? this.userId,
      password: password ?? this.password,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.isLoading == isLoading &&
        other.isLoggedIn == isLoggedIn &&
        other.userProfile == userProfile &&
        other.token == token &&
        other.error == error &&
        other.rememberMe == rememberMe &&
        other.userId == userId &&
        other.password == password;
  }

  @override
  int get hashCode => Object.hash(
        isLoading,
        isLoggedIn,
        userProfile,
        token,
        error,
        rememberMe,
        userId,
        password,
      );
}

/// 認證控制器
class AuthController extends AutoDisposeNotifier<AuthState> {
  late final Endpoints _endpoints;
  late final FlutterSecureStorage _secureStorage;

  static const String _tokenKey = 'kmutoken';
  static const String _userProfileKey = 'user_profile';
  static const String _rememberMeKey = 'remember_me';
  static const String _savedUserIdKey = 'saved_user_id';
  static const String _savedPasswordKey = 'saved_password';

  @override
  AuthState build() {
    _endpoints = ref.read(endpointsProvider);
    _secureStorage = const FlutterSecureStorage();

    // 嘗試自動登入
    _tryAutoLogin();

    return AuthState.initial();
  }

  /// 嘗試自動登入
  Future<void> _tryAutoLogin() async {
    try {
      final token = await _safeRead(_tokenKey);
      final rememberMeStr = await _safeRead(_rememberMeKey);
      final rememberMe = rememberMeStr == 'true';

      if (token != null && rememberMe) {
        final userId = await _safeRead(_savedUserIdKey);
        final password = await _safeRead(_savedPasswordKey);

        if (userId != null && password != null) {
          state = state.copyWith(isLoading: true);
          await login(
            userId: userId,
            password: password,
            rememberMe: true,
          );
        }
      }
    } catch (e) {
      debugPrint('自動登入失敗: $e');
    }
  }

  /// 登入
  Future<bool> login({
    required String userId,
    required String password,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _endpoints.auth.login(
        userId: userId,
        password: password,
        fcmToken: null,
      );

      if (response.success) {
        final token = response.token;
        final userProfile = response.userInfo;

        if (token != null && userProfile != null) {
          await _saveAuthData(
            token: token,
            userProfile: userProfile,
            rememberMe: rememberMe,
            userId: rememberMe ? userId : null,
            password: rememberMe ? password : null,
          );

          state = state.copyWith(
            isLoading: false,
            isLoggedIn: true,
            token: token,
            userProfile: userProfile,
            rememberMe: rememberMe,
            userId: userId,
            password: password,
            error: null,
          );
          return true;
        }
      }

      state = state.copyWith(
        isLoading: false,
        error: response.message,
      );
      return false;
    } on DioException catch (e) {
      final errorMsg = _handleDioError(e);
      state = state.copyWith(
        isLoading: false,
        error: errorMsg,
      );
      return false;
    } catch (e) {
      debugPrint('登入異常: $e');
      state = state.copyWith(
        isLoading: false,
        error: '登入失敗: $e',
      );
      return false;
    }
  }

  /// 登出
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      final token = state.token;
      if (token != null) {
        await _endpoints.auth.logout(token);
      }
    } catch (e) {
      debugPrint('登出 API 呼叫失敗: $e');
    } finally {
      await _clearAuthData();
      state = AuthState.initial();
    }
  }

  /// 修改密碼
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _endpoints.auth.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (response.success) {
        state = state.copyWith(isLoading: false, error: null);
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error: response.message,
      );
      return false;
    } on DioException catch (e) {
      final errorMsg = _handleDioError(e);
      state = state.copyWith(
        isLoading: false,
        error: errorMsg,
      );
      return false;
    } catch (e) {
      debugPrint('修改密碼異常: $e');
      state = state.copyWith(
        isLoading: false,
        error: '修改密碼失敗: $e',
      );
      return false;
    }
  }

  /// 更新使用者資訊
  Future<void> updateUserProfile(UserProfile profile) async {
    await _secureStorage.write(
      key: _userProfileKey,
      value: jsonEncode(profile.toJson()),
    );
    state = state.copyWith(userProfile: profile);
  }

  /// 手動設定認證狀態 (供測試模式使用)
  void setAuthState({
    required bool isLoggedIn,
    String? token,
    String? userId,
    String? password,
    UserProfile? userProfile,
  }) {
    state = state.copyWith(
      isLoading: false,
      isLoggedIn: isLoggedIn,
      token: token,
      userId: userId,
      password: password,
      userProfile: userProfile,
      error: null,
    );
  }

  // ===========================================
  // 私有方法
  // ===========================================

  /// 安全讀取 secure storage (遠端桌面環境下 libsecret 可能不可用)
  Future<String?> _safeRead(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      debugPrint('Secure storage read failed ($key): $e');
      return null;
    }
  }

  /// 安全寫入 secure storage (遠端桌面環境下 libsecret 可能不可用)
  Future<void> _safeWrite({required String key, required String value}) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      debugPrint('Secure storage write failed ($key): $e');
    }
  }

  /// 安全刪除 secure storage (遠端桌面環境下 libsecret 可能不可用)
  Future<void> _safeDelete({required String key}) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      debugPrint('Secure storage delete failed ($key): $e');
    }
  }

  Future<void> _saveAuthData({
    required String token,
    required UserProfile userProfile,
    required bool rememberMe,
    String? userId,
    String? password,
  }) async {
    await Future.wait([
      _safeWrite(key: _tokenKey, value: token),
      _safeWrite(key: _userProfileKey, value: jsonEncode(userProfile.toJson())),
      _safeWrite(key: _rememberMeKey, value: rememberMe.toString()),
    ]);

    if (rememberMe && userId != null && password != null) {
      await Future.wait([
        _safeWrite(key: _savedUserIdKey, value: userId),
        _safeWrite(key: _savedPasswordKey, value: password),
      ]);
    } else {
      await Future.wait([
        _safeDelete(key: _savedUserIdKey),
        _safeDelete(key: _savedPasswordKey),
      ]);
    }
  }

  Future<void> _clearAuthData() async {
    await Future.wait([
      _safeDelete(key: _tokenKey),
      _safeDelete(key: _userProfileKey),
      _safeDelete(key: _rememberMeKey),
      // 保留 rememberMe 為 true 時的帳密
      if (!state.rememberMe) _safeDelete(key: _savedUserIdKey),
      if (!state.rememberMe) _safeDelete(key: _savedPasswordKey),
    ]);
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return '連線逾時，請檢查網路後重試';
      case DioExceptionType.connectionError:
        return '無法連線到伺服器，請檢查網路';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) return '帳號或密碼錯誤';
        if (statusCode == 403) return '權限不足';
        if (statusCode == 429) return '請求過於頻繁，請稍後再試';
        if (statusCode != null && statusCode >= 500) return '伺服器錯誤，請稍後再試';
        return '請求失敗: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return '請求已取消';
      case DioExceptionType.unknown:
        return '網路錯誤: ${e.message}';
      default:
        return '發生未知錯誤';
    }
  }
}

/// Logger 簡易實作
class Logger {
  void d(String msg) => debugPrint('[DEBUG] $msg');
  void i(String msg) => debugPrint('[INFO] $msg');
  void w(String msg) => debugPrint('[WARN] $msg');
  void e(String msg, {StackTrace? stackTrace}) {
    debugPrint('[ERROR] $msg');
    if (stackTrace != null) debugPrint(stackTrace.toString());
  }
}

final logger = Logger();