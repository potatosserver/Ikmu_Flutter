// 響應式佈局工具
// 支援窄螢幕 (手機)、中螢幕 (平板)、寬螢幕 (桌面)

import 'package:flutter/material.dart';

/// 斷點定義
class Breakpoints {
  static const double mobile = 600;      // < 600: 手機直向
  static const double tablet = 900;      // 600-900: 手機橫向/平板直向
  static const double desktop = 1200;    // 900-1200: 平板橫向/小筆電
  static const double wideDesktop = 1600; // > 1200: 桌面/大螢幕
}

/// 螢幕尺寸類型
enum ScreenSize {
  mobile,
  tablet,
  desktop,
  wideDesktop,
}

/// 響應式斷點查詢
class ResponsiveBreakpoints extends InheritedWidget {
  const ResponsiveBreakpoints({
    super.key,
    required super.child,
    required this.screenSize,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.isWideDesktop,
    required this.width,
    required this.height,
    required this.orientation,
  });

  final ScreenSize screenSize;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final bool isWideDesktop;
  final double width;
  final double height;
  final Orientation orientation;

  static ResponsiveBreakpoints of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ResponsiveBreakpoints>()!;
  }

  @override
  bool updateShouldNotify(ResponsiveBreakpoints oldWidget) {
    return screenSize != oldWidget.screenSize ||
        width != oldWidget.width ||
        height != oldWidget.height ||
        orientation != oldWidget.orientation;
  }
}

/// 響應式佈局包裝器
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final orientation = MediaQuery.of(context).orientation;

        ScreenSize screenSize;
        if (width < Breakpoints.mobile) {
          screenSize = ScreenSize.mobile;
        } else if (width < Breakpoints.tablet) {
          screenSize = ScreenSize.tablet;
        } else if (width < Breakpoints.wideDesktop) {
          screenSize = ScreenSize.desktop;
        } else {
          screenSize = ScreenSize.wideDesktop;
        }

        return ResponsiveBreakpoints(
          screenSize: screenSize,
          isMobile: screenSize == ScreenSize.mobile,
          isTablet: screenSize == ScreenSize.tablet,
          isDesktop: screenSize == ScreenSize.desktop || screenSize == ScreenSize.wideDesktop,
          isWideDesktop: screenSize == ScreenSize.wideDesktop,
          width: width,
          height: height,
          orientation: orientation,
          child: child,
        );
      },
    );
  }
}

/// 響應式數值
class ResponsiveValue<T> {
  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
    this.wideDesktop,
  });

  final T mobile;
  final T? tablet;
  final T? desktop;
  final T? wideDesktop;

  T resolve(BuildContext context) {
    final rb = ResponsiveBreakpoints.of(context);
    if (rb.isWideDesktop && wideDesktop != null) return wideDesktop!;
    if (rb.isDesktop && desktop != null) return desktop!;
    if (rb.isTablet && tablet != null) return tablet!;
    return mobile;
  }

  T operator [](BuildContext context) => resolve(context);
}

/// 響應式邊距
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobile,
    this.tablet,
    this.desktop,
    this.wideDesktop,
  });

  final Widget child;
  final EdgeInsetsGeometry? mobile;
  final EdgeInsetsGeometry? tablet;
  final EdgeInsetsGeometry? desktop;
  final EdgeInsetsGeometry? wideDesktop;

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveValue<EdgeInsetsGeometry>(
      mobile: mobile ?? const EdgeInsets.all(16),
      tablet: tablet ?? const EdgeInsets.all(20),
      desktop: desktop ?? const EdgeInsets.all(24),
      wideDesktop: wideDesktop ?? const EdgeInsets.all(32),
    ).resolve(context);

    return Padding(padding: padding, child: child);
  }
}

/// 響應式最大寬度容器
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.mobileMaxWidth,
    this.tabletMaxWidth,
    this.desktopMaxWidth,
    this.wideDesktopMaxWidth,
    this.center = true,
  });

  final Widget child;
  final double? mobileMaxWidth;
  final double? tabletMaxWidth;
  final double? desktopMaxWidth;
  final double? wideDesktopMaxWidth;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveValue<double?>(
      mobile: mobileMaxWidth ?? double.infinity,
      tablet: tabletMaxWidth ?? 600,
      desktop: desktopMaxWidth ?? 800,
      wideDesktop: wideDesktopMaxWidth ?? 1000,
    ).resolve(context);

    final widget = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: child,
    );

    return center ? Center(child: widget) : widget;
  }
}

/// 自適應欄位佈局
class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.wideDesktopColumns = 4,
    this.spacing = 16,
    this.runSpacing = 16,
    this.minItemWidth,
    this.maxItemWidth,
  });

  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final int wideDesktopColumns;
  final double spacing;
  final double runSpacing;
  final double? minItemWidth;
  final double? maxItemWidth;

  @override
  Widget build(BuildContext context) {
    final rb = ResponsiveBreakpoints.of(context);
    final columns = rb.isWideDesktop
        ? wideDesktopColumns
        : rb.isDesktop
            ? desktopColumns
            : rb.isTablet
                ? tabletColumns
                : mobileColumns;

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children.map((child) => SizedBox(
        width: (rb.width - spacing * (columns - 1)) / columns,
        child: child,
      )).toList(),
    );
  }
}

/// 自適應列表/網格切換
class AdaptiveListGrid extends StatelessWidget {
  const AdaptiveListGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.itemBuilder,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final Widget Function(Widget, int)? itemBuilder;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    final rb = ResponsiveBreakpoints.of(context);
    final columns = rb.isDesktop
        ? desktopColumns
        : rb.isTablet
            ? tabletColumns
            : mobileColumns;

    if (columns == 1) {
      // 手機：列表模式
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: children.length,
        separatorBuilder: (_, __) => SizedBox(height: spacing),
        itemBuilder: (context, index) {
          final child = children[index];
          return itemBuilder != null ? itemBuilder!(child, index) : child;
        },
      );
    }

    // 平板/桌面：網格模式
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children.asMap().entries.map((entry) {
        final child = entry.value;
        return SizedBox(
          width: (rb.width - spacing * (columns - 1)) / columns,
          child: itemBuilder != null ? itemBuilder!(child, entry.key) : child,
        );
      }).toList(),
    );
  }
}

/// 響應式側邊欄佈局
class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    this.appBar,
    this.body,
    this.sidebar,
    this.sidebarWidth = 280,
    this.collapsedSidebarWidth = 72,
    this.showSidebarBreakpoint = Breakpoints.tablet,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? sidebar;
  final double sidebarWidth;
  final double collapsedSidebarWidth;
  final double showSidebarBreakpoint;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  @override
  Widget build(BuildContext context) {
    final rb = ResponsiveBreakpoints.of(context);
    final showSidebar = rb.width >= showSidebarBreakpoint && sidebar != null;

    return Scaffold(
      appBar: appBar,
      drawer: showSidebar ? null : drawer,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Row(
        children: [
          if (showSidebar && sidebar != null)
            SizedBox(
              width: sidebarWidth,
              child: sidebar!,
            ),
          Expanded(
            child: body ?? const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// 響應式對話框/底部抽屜
Future<T?> showAdaptiveDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool useBottomSheetOnMobile = true,
}) {
  final rb = ResponsiveBreakpoints.of(context);
  
  if (rb.isMobile && useBottomSheetOnMobile) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: builder,
    );
  }

  return showDialog<T>(
    context: context,
    builder: builder,
  );
}

/// 安全區域適配
class SafeAreaAdapter extends StatelessWidget {
  const SafeAreaAdapter({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = false,
    this.right = false,
    this.minimum,
  });

  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final EdgeInsets? minimum;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      minimum: minimum ?? EdgeInsets.zero,
      child: child,
    );
  }
}

/// 文字縮放限制
class TextScaleClamp extends StatelessWidget {
  const TextScaleClamp({
    super.key,
    required this.child,
    this.minScale = 0.8,
    this.maxScale = 1.3,
  });

  final Widget child;
  final double minScale;
  final double maxScale;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(
          MediaQuery.of(context).textScaler.scale(1.0).clamp(minScale, maxScale),
        ),
      ),
      child: child,
    );
  }
}

/// 方向適配
class OrientationAdapter extends StatelessWidget {
  const OrientationAdapter({
    super.key,
    this.portrait,
    this.landscape,
    required this.builder,
  });

  final Widget? portrait;
  final Widget? landscape;
  final Widget Function(BuildContext, Orientation) builder;

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    if (orientation == Orientation.portrait && portrait != null) {
      return portrait!;
    }
    if (orientation == Orientation.landscape && landscape != null) {
      return landscape!;
    }
    return builder(context, orientation);
  }
}

extension ResponsiveContext on BuildContext {
  ResponsiveBreakpoints get responsive => ResponsiveBreakpoints.of(this);
  bool get isMobile => responsive.isMobile;
  bool get isTablet => responsive.isTablet;
  bool get isDesktop => responsive.isDesktop;
  bool get isWideDesktop => responsive.isWideDesktop;
  double get screenWidth => responsive.width;
  double get screenHeight => responsive.height;
  Orientation get orientation => responsive.orientation;
  ScreenSize get screenSize => responsive.screenSize;
}

/// 響應式間距常數
class ResponsiveSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static double responsive(BuildContext context, {
    double mobile = md,
    double? tablet,
    double? desktop,
    double? wideDesktop,
  }) {
    return ResponsiveValue<double>(
      mobile: mobile,
      tablet: tablet ?? mobile * 1.25,
      desktop: desktop ?? mobile * 1.5,
      wideDesktop: wideDesktop ?? mobile * 2,
    ).resolve(context);
  }
}

/// 響應式圓角
class ResponsiveRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 9999;

  static double responsive(BuildContext context, {
    double mobile = md,
    double? tablet,
    double? desktop,
    double? wideDesktop,
  }) {
    return ResponsiveValue<double>(
      mobile: mobile,
      tablet: tablet ?? mobile * 1.25,
      desktop: desktop ?? mobile * 1.5,
      wideDesktop: wideDesktop ?? mobile * 2,
    ).resolve(context);
  }
}