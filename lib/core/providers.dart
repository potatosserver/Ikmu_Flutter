// 全域 Provider 定義
// 集中管理所有 Riverpod Provider

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/api/kmu_client.dart';
import '../core/api/endpoints/endpoints.dart';
import '../core/auth/auth_controller.dart';
import '../core/cache/cache_service.dart';
import 'constants/api_constants.dart';

/// Dio Provider - 全域單例
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: kKmuApiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      // 不在 Dio 層面拋出 HTTP 錯誤狀態碼，改由 _handleResponse 統一處理
      validateStatus: (status) => true,
    ),
  );
  return dio;
}, name: 'dioProvider');

/// 安全儲存 Provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
}, name: 'secureStorageProvider');

/// KMU Client Provider
final kmuClientProvider = Provider<KmuClient>((ref) {
  return KmuClient(ref.read(dioProvider));
}, name: 'kmuClientProvider');

/// Endpoints Provider
final endpointsProvider = Provider<Endpoints>((ref) {
  return Endpoints(ref.read(kmuClientProvider));
}, name: 'endpointsProvider');

/// 認證控制器 Provider
final authControllerProvider = AutoDisposeNotifierProvider<AuthController, AuthState>(() {
  return AuthController();
}, name: 'authControllerProvider');

/// 當前登入使用者憑證 Provider (userId, password)
/// 從 authController 衍生
final currentUserCredentialsProvider = Provider<Map<String, String>?>((ref) {
  final authState = ref.watch(authControllerProvider);
  if (authState.isLoggedIn && authState.token != null && authState.userId != null && authState.password != null) {
    return {
      'userId': authState.userId!,
      'password': authState.password!,
    };
  }
  return null;
}, name: 'currentUserCredentialsProvider');

/// 快取服務 Provider
final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService.instance;
}, name: 'cacheServiceProvider');

/// 主題模式 Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
}, name: 'themeModeProvider');

/// 主題模式 Notifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadSavedTheme();
  }
  
  Future<void> _loadSavedTheme() async {
    try {
      // 這裡會在 Hive 初始化後使用
      // 暫時使用預設值
      state = ThemeMode.system;
    } catch (_) {
      state = ThemeMode.system;
    }
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    // TODO: 儲存到 Hive
  }
}