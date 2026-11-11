// 路由配置
// 使用 GoRouter 支援 Web 深層連結、重導向守衛

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/calendar/pages/calendar_page.dart';
import '../../features/classroom/pages/classroom_detail_page.dart';
import '../../features/classroom/pages/classroom_list_page.dart';
import '../../features/courses/pages/my_scores_page.dart';
import '../../features/courses/pages/my_schedule_page.dart';
import '../../features/campus_info/pages/news_detail_page.dart';
import '../../features/campus_info/pages/news_page.dart';
import '../../features/campus_info/pages/traffic_page.dart';
import '../../features/irs/pages/irs_detail_page.dart';
import '../../features/irs/pages/irs_history_page.dart';
import '../../features/irs/pages/irs_list_page.dart';
import '../../features/settings/pages/settings_page.dart';
import '../../shared/widgets/app_scaffold.dart';

/// 路由 Provider
final routerProvider = Provider<GoRouter>((ref) {
  // 先讀取當前認證狀態初始化 ValueNotifier
  final initialAuthState = ref.read(authControllerProvider);
  final authStateNotifier = ValueNotifier<bool>(initialAuthState.isLoggedIn);
  
  // 監聽 authControllerProvider 變化並更新 notifier
  ref.listen<AuthState>(authControllerProvider, (previous, next) {
    if (authStateNotifier.value != next.isLoggedIn) {
      authStateNotifier.value = next.isLoggedIn;
    }
  });

  return GoRouter(
      initialLocation: RoutePaths.splash,
      refreshListenable: authStateNotifier,
      redirect: (context, state) {
        final isLoggedIn = authStateNotifier.value;
        final isAuthRoute = state.matchedLocation == RoutePaths.login;
        final isSplashRoute = state.matchedLocation == RoutePaths.splash;
        final isHomeRoute = state.matchedLocation == RoutePaths.home;

        debugPrint('[router] redirect: location=${state.matchedLocation}, isLoggedIn=$isLoggedIn, isAuthRoute=$isAuthRoute, isSplashRoute=$isSplashRoute, isHomeRoute=$isHomeRoute');

        // 已登入 -> 導向主畫面 (包含從 splash 來的情況)
        if (isLoggedIn) {
          if (isAuthRoute || isSplashRoute) {
            debugPrint('[router] -> redirect to home');
            return RoutePaths.home;
          }
          return null; // 已登入且在其他頁面，不攔截
        }

        // 未登入 -> 導向登入 (包含從 splash 來的情況)
        if (!isLoggedIn) {
          if (isAuthRoute) {
            debugPrint('[router] -> already at login, no redirect');
            return null; // 已在登入頁，不攔截
          }
          debugPrint('[router] -> redirect to login');
          return RoutePaths.login; // 在 splash 或其他頁面，導向登入
        }

        return null;
      },
      routes: [
        // 啟動頁
        GoRoute(
          path: RoutePaths.splash,
          builder: (context, state) => const _SplashPage(),
        ),

        // 登入頁
        GoRoute(
          path: RoutePaths.login,
          builder: (context, state) => const LoginPage(),
        ),

        // 主要功能頁面 (需登入，包含底部導航)
        ShellRoute(
          builder: (context, state, child) => AppScaffold(child: child),
          routes: [
            // 首頁
            GoRoute(
              path: RoutePaths.home,
              builder: (context, state) => const HomePage(),
            ),

            // 行事曆
            GoRoute(
              path: RoutePaths.calendar,
              builder: (context, state) => const CalendarPage(),
            ),

          // 場地查詢
          GoRoute(
            path: RoutePaths.classroom,
            builder: (context, state) => const ClassroomListPage(),
          ),
          GoRoute(
            path: RoutePaths.classroomDetail,
            builder: (context, state) {
              final roomId = state.pathParameters['roomId'] ?? '';
              final date = state.uri.queryParameters['date'];
              return ClassroomDetailPage(roomId: roomId, initialDate: date);
            },
          ),

          // 課務
          GoRoute(
            path: RoutePaths.schedule,
            builder: (context, state) => const MySchedulePage(),
          ),
          GoRoute(
            path: RoutePaths.scores,
            builder: (context, state) => const MyScoresPage(),
          ),
          GoRoute(
            path: RoutePaths.scoreDetail,
            builder: (context, state) {
              final subjectId = state.pathParameters['subjectId'] ?? '';
              return _ScoreDetailPage(subjectId: subjectId);
            },
          ),

          // IRS 答題系統
          GoRoute(
            path: RoutePaths.irs,
            builder: (context, state) => const IrsListPage(),
          ),
          GoRoute(
            path: RoutePaths.irsHistory,
            builder: (context, state) => const IrsHistoryPage(),
          ),
          GoRoute(
            path: '${RoutePaths.irs}/detail',
            builder: (context, state) => const IrsDetailPage(),
          ),

          // 校園資訊
          GoRoute(
            path: RoutePaths.news,
            builder: (context, state) => const NewsPage(),
          ),
          GoRoute(
            path: RoutePaths.newsDetail,
            builder: (context, state) {
              final newsId = state.pathParameters['newsId'] ?? '';
              return NewsDetailPage(newsId: newsId);
            },
          ),
          GoRoute(
            path: RoutePaths.traffic,
            builder: (context, state) => const TrafficPage(),
          ),

          // 設定
          GoRoute(
            path: RoutePaths.settings,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => _ErrorPage(error: state.error.toString()),
  );
});

/// 啟動頁
class _SplashPage extends ConsumerWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 由 GoRouter 的 redirect 根據 auth state 自動導航
    // 這裡只需顯示載入畫面

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_hospital,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'i高醫',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '高雄醫學大學行動查詢系統',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// 錯誤頁
class _ErrorPage extends StatelessWidget {

  const _ErrorPage({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                '頁面載入失敗',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go(RoutePaths.calendar),
                icon: const Icon(Icons.refresh),
                label: const Text('返回行事曆'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 成績詳情頁 (佔位)
class _ScoreDetailPage extends StatelessWidget {

  const _ScoreDetailPage({required this.subjectId});
  final String subjectId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('成績詳情')),
      body: Center(child: Text('科目 ID: $subjectId (待實作)')),
    );
  }
}