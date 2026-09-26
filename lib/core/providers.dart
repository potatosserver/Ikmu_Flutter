// 全域 Provider 定義
// 集中管理所有 Riverpod Provider

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api/kmu_client.dart';
import '../core/api/endpoints/endpoints.dart';
import '../core/auth/auth_controller.dart';
import '../core/cache/cache_service.dart';
import '../core/api/services/weather_service.dart';
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
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt('theme_mode') ?? 0;
      state = ThemeMode.values[themeIndex];
    } catch (_) {
      state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }
}

/// 天氣服務 Provider
final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
}, name: 'weatherServiceProvider');

/// 天氣狀態
class WeatherState {
  const WeatherState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  final WeatherData? data;
  final bool isLoading;
  final String? error;

  WeatherState copyWith({
    WeatherData? data,
    bool? isLoading,
    String? error,
  }) {
    return WeatherState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 天氣 Notifier
class WeatherNotifier extends AutoDisposeNotifier<WeatherState> {
  @override
  WeatherState build() {
    return const WeatherState(isLoading: true);
  }

  Future<void> fetchWeather() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final weatherService = ref.read(weatherServiceProvider);
      final data = await weatherService.fetchCurrentWeather();
      state = state.copyWith(data: data, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '載入天氣失敗: $e',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 天氣 Provider
final weatherProvider = AutoDisposeNotifierProvider<WeatherNotifier, WeatherState>(() {
  return WeatherNotifier();
}, name: 'weatherProvider');