// 主要 Scaffold 佈局
// 提供底部導航、抽屜、安全區域適配

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core.dart';

/// 應用主 Scaffold - 底部導航 + 頁面內容
class AppScaffold extends ConsumerStatefulWidget {
  const AppScaffold({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold> {
  // 當前選中的標籤索引
  int _currentIndex = 0;

  // 主要功能頁面路由對應
  final List<_NavItem> _navItems = const [
    _NavItem(
      path: RoutePaths.calendar,
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
      label: '行事曆',
    ),
    _NavItem(
      path: RoutePaths.classroom,
      icon: Icons.meeting_room_outlined,
      activeIcon: Icons.meeting_room,
      label: '場地',
    ),
    _NavItem(
      path: RoutePaths.schedule,
      icon: Icons.schedule_outlined,
      activeIcon: Icons.schedule,
      label: '課表',
    ),
    _NavItem(
      path: RoutePaths.bus,
      icon: Icons.directions_bus_outlined,
      activeIcon: Icons.directions_bus,
      label: '交通',
    ),
    _NavItem(
      path: RoutePaths.settings,
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: '設定',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // 根據初始路由設定當前索引
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateIndexFromRoute();
    });
  }

  void _updateIndexFromRoute() {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _navItems.length; i++) {
      if (location.startsWith(_navItems[i].path)) {
        setState(() => _currentIndex = i);
        break;
      }
    }
  }

  void _onTap(int index) {
    final path = _navItems[index].path;
    if (GoRouterState.of(context).matchedLocation != path) {
      context.go(path);
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false, // NavigationBar 會處理底部安全區
        child: widget.child,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTap,
        destinations: _navItems.map((item) => NavigationDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.activeIcon),
          label: item.label,
        )).toList(),
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}

/// 導航項目資料類
class _NavItem {
  const _NavItem({
    required this.path,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;
}