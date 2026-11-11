// 主畫面
// 顯示使用者名稱、學號、高雄天氣 (預留介面)
//
// 待整合:
// - 真實天氣 API (OpenWeatherMap / CWB / 其他)
// - 使用者個人資料從 AuthController 取得

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final userProfile = authState.userProfile;
    final userId = authState.userId ?? 'guest';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 歡迎區塊
              _WelcomeSection(
                userName: userProfile?.userName ?? '測試用戶',
                userId: userId,
              ),
              const SizedBox(height: 24),

              // 天氣卡片 (預留)
              const _WeatherCard(),
              const SizedBox(height: 24),

              // 快速功能入口
              _QuickActions(),
            ],
          ),
        ),
      ),
    );
  }
}

/// 歡迎區塊
class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection({
    required this.userName,
    required this.userId,
  });

  final String userName;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGuest = userId == 'guest';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    isGuest ? Icons.science_outlined : Icons.person_outline,
                    size: 32,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGuest ? '歡迎使用測試模式' : '歡迎回來，$userName',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isGuest
                            ? '目前為測試模式，部分功能需真實登入'
                            : '學號：$userId',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isGuest) ...[
              const SizedBox(height: 16),
              Divider(color: theme.colorScheme.outlineVariant),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '高雄醫學大學行動查詢系統',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 天氣卡片 (使用真實 Open-Meteo API)
class _WeatherCard extends ConsumerWidget {
  const _WeatherCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final weatherState = ref.watch(weatherProvider);
    final notifier = ref.read(weatherProvider.notifier);

    // 初始載入 - 使用 useEffect 模式
    return Consumer(
      builder: (context, ref, _) {
        // 觸發初始載入
        if (weatherState.data == null && !weatherState.isLoading && weatherState.error == null) {
          // 使用 Future.microtask 避免 build 期間修改狀態
          Future.microtask(() => notifier.fetchWeather());
        }
        return _buildWeatherCard(context, ref, theme, weatherState, notifier);
      },
    );
  }

  Widget _buildWeatherCard(BuildContext context, WidgetRef ref, ThemeData theme,
      WeatherState weatherState, WeatherNotifier notifier) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.wb_sunny_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '高雄天氣',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (weatherState.isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                else if (weatherState.error != null)
                  TextButton.icon(
                    onPressed: () => notifier.fetchWeather(),
                    icon: Icon(Icons.refresh, size: 16, color: theme.colorScheme.primary),
                    label: Text(
                      '重試',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // 載入中
            if (weatherState.isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: theme.colorScheme.primary),
                ),
              )

            // 錯誤狀態
            else if (weatherState.error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_off_outlined,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        weatherState.error!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () => notifier.fetchWeather(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('重試'),
                      ),
                    ],
                  ),
                ),
              )

            // 天氣資料
            else if (weatherState.data != null) ...[
              _WeatherContent(data: weatherState.data!, theme: theme),
            ],
          ],
        ),
      ),
    );
  }
}

class _WeatherContent extends StatelessWidget {
  const _WeatherContent({
    required this.data,
    required this.theme,
  });

  final WeatherData data;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 主要天氣 + 詳細資訊
        Row(
          children: [
            // 主要天氣
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.icon,
                        style: const TextStyle(fontSize: 56),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        data.temperatureDisplay,
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.w300,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // 詳細資訊 (3欄)
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  _WeatherDetailRow(
                    icon: Icons.water_drop_outlined,
                    label: '濕度',
                    value: data.humidityDisplay,
                  ),
                  _WeatherDetailRow(
                    icon: Icons.air_outlined,
                    label: '風速',
                    value: data.windSpeedDisplay,
                  ),
                  _WeatherDetailRow(
                    icon: Icons.thermostat_outlined,
                    label: '體感',
                    value: data.apparentTemperatureDisplay,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WeatherDetailRow extends StatelessWidget {
  const _WeatherDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// 快速功能入口
class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final actions = [
      const _QuickActionItem(
        icon: Icons.calendar_today_outlined,
        label: '行事曆',
        color: Colors.blue,
        route: RoutePaths.calendar,
      ),
      const _QuickActionItem(
        icon: Icons.meeting_room_outlined,
        label: '場地查詢',
        color: Colors.green,
        route: RoutePaths.classroom,
      ),
      const _QuickActionItem(
        icon: Icons.schedule_outlined,
        label: '我的課表',
        color: Colors.orange,
        route: RoutePaths.schedule,
      ),
      const _QuickActionItem(
        icon: Icons.quiz_outlined,
        label: 'IRS 答題',
        color: Colors.teal,
        route: RoutePaths.irs,
      ),
      const _QuickActionItem(
        icon: Icons.article_outlined,
        label: '校園新聞',
        color: Colors.red,
        route: RoutePaths.news,
      ),
      const _QuickActionItem(
        icon: Icons.settings_outlined,
        label: '設定',
        color: Colors.grey,
        route: RoutePaths.settings,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快速功能',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _QuickActionCard(action: action);
          },
        ),
      ],
    );
  }
}

class _QuickActionItem {
  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });

  final IconData icon;
  final String label;
  final Color color;
  final String route;
}

class _QuickActionCard extends ConsumerWidget {
  const _QuickActionCard({required this.action});

  final _QuickActionItem action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(action.route),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: action.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: action.color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                action.icon,
                size: 32,
                color: action.color,
              ),
              const SizedBox(height: 12),
              Text(
                action.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: action.color,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}