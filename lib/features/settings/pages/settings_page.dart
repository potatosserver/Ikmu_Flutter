// 設定頁面 (佔位實作)

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 外觀設定
          Text(
            '外觀',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('主題模式'),
                  subtitle: Text(_themeModeToString(themeMode)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemeDialog(context, ref),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  secondary: const Icon(Icons.language),
                  title: const Text('語言'),
                  subtitle: const Text('繁體中文 (預設)'),
                  value: true,
                  onChanged: (value) {
                    // TODO: 語言切換
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 帳號設定
          Text(
            '帳號',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('個人資料'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: 個人資料頁
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('修改密碼'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: 修改密碼
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    '登出',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  onTap: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (context.mounted) {
                      GoRouter.of(context).go(RoutePaths.login);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 快取設定
          Text(
            '快取與資料',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.clear_all),
                  title: const Text('清除快取'),
                  subtitle: const Text('刪除所有本地快取資料'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showClearCacheDialog(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 關於
          Text(
            '關於',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('版本資訊'),
                  subtitle: Text('${AppConstants.appName} v${AppConstants.version} (Build ${AppConstants.buildNumber})'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('隱私權政策'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: 隱私權政策
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('服務條款'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: 服務條款
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '淺色模式';
      case ThemeMode.dark:
        return '深色模式';
      case ThemeMode.system:
        return '跟隨系統';
    }
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.read(themeModeProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('選擇主題模式'),
        content: SegmentedButton<ThemeMode>(
          selected: {currentThemeMode},
          onSelectionChanged: (Set<ThemeMode> selected) {
            final value = selected.first;
            ref.read(themeModeProvider.notifier).setThemeMode(value);
            Navigator.pop(context);
          },
          segments: const [
            ButtonSegment<ThemeMode>(value: ThemeMode.light, label: Text('淺色模式')),
            ButtonSegment<ThemeMode>(value: ThemeMode.dark, label: Text('深色模式')),
            ButtonSegment<ThemeMode>(value: ThemeMode.system, label: Text('跟隨系統')),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除快取'),
        content: const Text('這將刪除所有本地快取資料，確定要繼續嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await CacheService.instance.closeAll();
              await CacheService.instance.initialize();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('快取已清除')),
                );
              }
            },
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }
}