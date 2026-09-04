// App 入口點
// 初始化 Hive、Riverpod、GoRouter、主題

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'core.dart';
import 'routing/app_router.dart';

/// 全域錯誤處理
void _setupErrorHandling() {
  FlutterError.onError = (details) {
    logger.e('Flutter Error: ${details.exception}', stackTrace: details.stack);
  };
  
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.e('Platform Error: $error', stackTrace: stack);
    return true;
  };
}

/// 主函式
Future<void> main() async {
  // 確保 Flutter binding 初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 設定錯誤處理
  _setupErrorHandling();
  
  // 設定系統 UI 模式
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // 啟用邊緣到邊緣 (Android)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  // 初始化時區資料
  tz_data.initializeTimeZones();
  
  // 初始化 Hive (本地快取)
  await Hive.initFlutter();
  
  // 註冊 Hive Adapters (需先執行 build_runner 生成)
  // Hive.registerAdapter(CacheItemAdapter());
  // Hive.registerAdapter(AuthCacheAdapter());
  // ... 其他 adapters
  
  // 開啟預設 Box
  await _openDefaultBoxes();
  
  // 初始化快取服務
  await CacheService.instance.initialize();
  
  // 執行 App
  runApp(
    const ProviderScope(
      child: IKmuApp(),
    ),
  );
}

/// 開啟預設 Box
Future<void> _openDefaultBoxes() async {
  final boxes = CacheBoxes.values.toList();
  for (final boxName in boxes) {
    if (!Hive.isBoxOpen(boxName.name)) {
      await Hive.openBox<Map>(boxName.name);
    }
  }
}

/// 主應用程式 Widget
class IKmuApp extends ConsumerWidget {
  const IKmuApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // 路由
      routerConfig: router,
      
      // 主題
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      
      // 本地化
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'TW'),
        Locale('en', 'US'),
      ],
      locale: const Locale('zh', 'TW'),
      
      // Builder 可在此包裹全域 Provider、錯誤邊界等
      builder: (context, child) {
        return MediaQuery(
          // 限制文字縮放最大倍率
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.3),
            ),
          ),
          child: child!,
        );
      },
    );
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