// Material 3 主題系統
// 支援 Light/Dark 模式、動態色彩 (Material You)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 應用主題配置
class AppTheme {
  AppTheme._();

  // ===========================================
  // 色彩定義 (符合 Material 3 規範)
  // ===========================================

  /// 主品牌色 - KMU 藍
  static const Color _primaryBlue = Color(0xFF1A73E8);
  static const Color _primaryBlueContainer = Color(0xFFD6E4F0);
  static const Color _onPrimaryBlue = Color(0xFFFFFFFF);
  static const Color _onPrimaryBlueContainer = Color(0xFF001D3D);

  /// 次要品牌色
  static const Color _secondaryBlue = Color(0xFF4285F4);
  static const Color _secondaryContainer = Color(0xFFD6E4F0);

  /// 第三品牌色 (強調色)
  static const Color _tertiaryGreen = Color(0xFF00C853);
  static const Color _tertiaryContainer = Color(0xFFB7F5C3);

  /// 錯誤色
  static const Color _errorRed = Color(0xFFBA1A1A);
  static const Color _errorContainer = Color(0xFFFFDAD6);

  // ===========================================
  // Light ColorScheme
  // ===========================================

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,

    // Primary
    primary: _primaryBlue,
    onPrimary: _onPrimaryBlue,
    primaryContainer: _primaryBlueContainer,
    onPrimaryContainer: _onPrimaryBlueContainer,

    // Secondary
    secondary: _secondaryBlue,
    onSecondary: _onPrimaryBlue,
    secondaryContainer: _secondaryContainer,
    onSecondaryContainer: _onPrimaryBlueContainer,

    // Tertiary
    tertiary: _tertiaryGreen,
    onTertiary: _onPrimaryBlue,
    tertiaryContainer: _tertiaryContainer,
    onTertiaryContainer: Color(0xFF001F0E),

    // Error
    error: _errorRed,
    onError: _onPrimaryBlue,
    errorContainer: _errorContainer,
    onErrorContainer: Color(0xFF410002),

    // Surface
    surface: Color(0xFFFCFCFC),
    onSurface: Color(0xFF1A1C1E),
    surfaceContainerHighest: Color(0xFFE3E5E8),
    surfaceContainerHigh: Color(0xFFEBEDEF),
    surfaceContainer: Color(0xFFF3F5F7),
    surfaceContainerLow: Color(0xFFFAFCFE),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    onSurfaceVariant: Color(0xFF44474E),

    // Outline
    outline: Color(0xFF74777F),
    outlineVariant: Color(0xFFC4C7CF),

    // Shadow / Scrim
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF2F3033),
    onInverseSurface: Color(0xFFF1F0F4),
    inversePrimary: Color(0xFFA6C9F5),

    // Surface Tint (Material 3 動態高度色彩)
    surfaceTint: _primaryBlue,
  );

  // ===========================================
  // Dark ColorScheme
  // ===========================================

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,

    // Primary
    primary: Color(0xFFA6C9F5),
    onPrimary: Color(0xFF003366),
    primaryContainer: Color(0xFF00498B),
    onPrimaryContainer: Color(0xFFD6E4F0),

    // Secondary
    secondary: Color(0xFFBFD0F7),
    onSecondary: Color(0xFF003366),
    secondaryContainer: Color(0xFF00498B),
    onSecondaryContainer: Color(0xFFD6E4F0),

    // Tertiary
    tertiary: Color(0xFF81F598),
    onTertiary: Color(0xFF003D0E),
    tertiaryContainer: Color(0xFF005415),
    onTertiaryContainer: Color(0xFFB7F5C3),

    // Error
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),

    // Surface
    surface: Color(0xFF1A1C1E),
    onSurface: Color(0xFFE3E2E6),
    surfaceContainerHighest: Color(0xFF44474E),
    surfaceContainerHigh: Color(0xFF3A3D43),
    surfaceContainer: Color(0xFF303339),
    surfaceContainerLow: Color(0xFF282A2E),
    surfaceContainerLowest: Color(0xFF1A1C1E),
    onSurfaceVariant: Color(0xFFC4C7CF),

    // Outline
    outline: Color(0xFF8E9199),
    outlineVariant: Color(0xFF44474E),

    // Shadow / Scrim
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE3E2E6),
    onInverseSurface: Color(0xFF2F3033),
    inversePrimary: _primaryBlue,

    // Surface Tint
    surfaceTint: Color(0xFFA6C9F5),
  );

  // ===========================================
  // 文字主題
  // ===========================================

  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
    );
  }

  // ===========================================
  // 建立 ThemeData
  // ===========================================

  /// 建立 Light Theme
  static ThemeData light({
    ColorScheme? colorScheme,
    TextTheme? textTheme,
    bool useMaterial3 = true,
  }) {
    final scheme = colorScheme ?? _lightColorScheme;
    final baseTextTheme = ThemeData.light(useMaterial3: useMaterial3).textTheme;
    final tt = textTheme ?? _textTheme(baseTextTheme);

    return ThemeData(
      useMaterial3: useMaterial3,
      colorScheme: scheme,
      textTheme: tt,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: scheme.surfaceTint,
        titleTextStyle: tt.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        elevation: 1,
        shadowColor: scheme.shadow.withValues(alpha: 0.1),
        surfaceTintColor: scheme.surfaceTint,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.12),
          disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // FilledButton (Material 3)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),

      // IconButton
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurfaceVariant,
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.all(12),
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        disabledColor: scheme.onSurface.withValues(alpha: 0.12),
        selectedColor: scheme.primaryContainer,
        secondarySelectedColor: scheme.secondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: tt.labelMedium?.copyWith(
          color: scheme.onSurface,
        ),
        secondaryLabelStyle: tt.labelMedium?.copyWith(
          color: scheme.onPrimaryContainer,
        ),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),

      // InputDecoration (TextField)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        labelStyle: tt.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        hintStyle: tt.bodyLarge?.copyWith(color: scheme.onSurfaceVariant.withValues(alpha: 0.6)),
        errorStyle: tt.bodySmall?.copyWith(color: scheme.error),
        floatingLabelStyle: tt.bodyMedium?.copyWith(color: scheme.primary),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        elevation: 8,
        shadowColor: scheme.shadow.withValues(alpha: 0.3),
        surfaceTintColor: scheme.surfaceTint,
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: tt.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: tt.bodyLarge?.copyWith(
          color: scheme.onSurface,
        ),
      ),

      // BottomSheet
      bottomSheetTheme: BottomSheetThemeData(
        shadowColor: scheme.shadow.withValues(alpha: 0.3),
        surfaceTintColor: scheme.surfaceTint,
        backgroundColor: scheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        modalBackgroundColor: scheme.surface,
        clipBehavior: Clip.antiAlias,
      ),

      // NavigationBar
      navigationBarTheme: NavigationBarThemeData(
        elevation: 8,
        shadowColor: scheme.shadow.withValues(alpha: 0.2),
        surfaceTintColor: scheme.surfaceTint,
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return tt.labelSmall?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            );
          }
          return tt.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: scheme.onPrimaryContainer, size: 24);
          }
          return IconThemeData(color: scheme.onSurfaceVariant, size: 24);
        }),
      ),

      // TabBar
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        indicatorColor: scheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w400),
        dividerColor: scheme.outlineVariant,
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.transparent,
        selectedTileColor: scheme.primaryContainer,
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        titleTextStyle: tt.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        subtitleTextStyle: tt.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        leadingAndTrailingTextStyle: tt.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
        indent: 16,
        endIndent: 16,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: tt.bodyMedium?.copyWith(color: scheme.onInverseSurface),
        actionTextColor: scheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
      ),

      // ProgressIndicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primaryContainer,
        circularTrackColor: scheme.primaryContainer,
      ),

      // FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        elevation: 2,
        focusElevation: 4,
        hoverElevation: 3,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // SegmentedButton
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return scheme.primaryContainer;
            }
            return scheme.surfaceContainerHigh;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return scheme.onPrimaryContainer;
            }
            return scheme.onSurface;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return BorderSide(color: scheme.primary, width: 2);
            }
            return BorderSide(color: scheme.outlineVariant);
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: tt.bodySmall?.copyWith(color: scheme.onInverseSurface),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        waitDuration: const Duration(milliseconds: 500),
      ),

      // Drawer
      drawerTheme: DrawerThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        elevation: 16,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
        ),
      ),

      // ExpansionTile
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        collapsedBackgroundColor: scheme.surfaceContainerLowest,
        textColor: scheme.onSurface,
        collapsedTextColor: scheme.onSurface,
        iconColor: scheme.onSurfaceVariant,
        collapsedIconColor: scheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),

      // PopupMenu
      popupMenuTheme: PopupMenuThemeData(
        elevation: 8,
        shadowColor: scheme.shadow.withValues(alpha: 0.3),
        surfaceTintColor: scheme.surfaceTint,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: tt.bodyLarge?.copyWith(color: scheme.onSurface),
      ),

      // TimePicker
      timePickerTheme: TimePickerThemeData(
        backgroundColor: scheme.surface,
        hourMinuteTextColor: scheme.onSurface,
        hourMinuteColor: scheme.surfaceContainerHigh,
        dayPeriodTextColor: scheme.onSurfaceVariant,
        dayPeriodColor: scheme.surfaceContainerHighest,
        dialHandColor: scheme.primary,
        dialBackgroundColor: scheme.primaryContainer,
        entryModeIconColor: scheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // DatePicker
      datePickerTheme: DatePickerThemeData(
        backgroundColor: scheme.surface,
        headerBackgroundColor: scheme.primaryContainer,
        headerForegroundColor: scheme.onPrimaryContainer,
        surfaceTintColor: scheme.surfaceTint,
        shadowColor: scheme.shadow.withValues(alpha: 0.3),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        dayStyle: tt.bodyLarge?.copyWith(color: scheme.onSurface),
        yearStyle: tt.bodyLarge?.copyWith(color: scheme.onSurface),
        rangePickerHeaderBackgroundColor: scheme.primaryContainer,
        rangePickerHeaderForegroundColor: scheme.onPrimaryContainer,
        rangePickerHeaderHeadlineStyle: tt.titleMedium?.copyWith(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 建立 Dark Theme
  static ThemeData dark({
    ColorScheme? colorScheme,
    TextTheme? textTheme,
    bool useMaterial3 = true,
  }) {
    final scheme = colorScheme ?? _darkColorScheme;
    final baseTextTheme = ThemeData.dark(useMaterial3: useMaterial3).textTheme;
    final tt = textTheme ?? _textTheme(baseTextTheme);

    return ThemeData(
      useMaterial3: useMaterial3,
      colorScheme: scheme,
      textTheme: tt,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: scheme.surfaceTint,
        titleTextStyle: tt.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      // Card
      cardTheme: CardThemeData( // 👈 修正: CardTheme -> CardThemeData
        elevation: 1,
        shadowColor: scheme.shadow.withValues(alpha: 0.1),
        surfaceTintColor: scheme.surfaceTint,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.12),
          disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // FilledButton
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),

      // IconButton
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurfaceVariant,
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.all(12),
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        disabledColor: scheme.onSurface.withValues(alpha: 0.12),
        selectedColor: scheme.primaryContainer,
        secondarySelectedColor: scheme.secondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: tt.labelMedium?.copyWith(
          color: scheme.onSurface,
        ),
        secondaryLabelStyle: tt.labelMedium?.copyWith(
          color: scheme.onPrimaryContainer,
        ),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),

      // InputDecoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        labelStyle: tt.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        hintStyle: tt.bodyLarge?.copyWith(color: scheme.onSurfaceVariant.withValues(alpha: 0.6)),
        errorStyle: tt.bodySmall?.copyWith(color: scheme.error),
        floatingLabelStyle: tt.bodyMedium?.copyWith(color: scheme.primary),
      ),

      // Dialog
      dialogTheme: DialogThemeData( // 👈 修正: DialogTheme -> DialogThemeData
        elevation: 8,
        shadowColor: scheme.shadow.withValues(alpha: 0.3),
        surfaceTintColor: scheme.surfaceTint,
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: tt.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: tt.bodyLarge?.copyWith(
          color: scheme.onSurface,
        ),
      ),

      // BottomSheet
      bottomSheetTheme: BottomSheetThemeData(
        shadowColor: scheme.shadow.withValues(alpha: 0.3),
        surfaceTintColor: scheme.surfaceTint,
        backgroundColor: scheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        modalBackgroundColor: scheme.surface,
        clipBehavior: Clip.antiAlias,
      ),

      // NavigationBar
      navigationBarTheme: NavigationBarThemeData(
        elevation: 8,
        shadowColor: scheme.shadow.withValues(alpha: 0.2),
        surfaceTintColor: scheme.surfaceTint,
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return tt.labelSmall?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            );
          }
          return tt.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: scheme.onPrimaryContainer, size: 24);
          }
          return IconThemeData(color: scheme.onSurfaceVariant, size: 24);
        }),
      ),

      // TabBar
      tabBarTheme: TabBarThemeData( // 👈 修正: TabBarTheme -> TabBarThemeData
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        indicatorColor: scheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w400),
        dividerColor: scheme.outlineVariant,
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.transparent,
        selectedTileColor: scheme.primaryContainer,
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        titleTextStyle: tt.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        subtitleTextStyle: tt.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        leadingAndTrailingTextStyle: tt.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
        indent: 16,
        endIndent: 16,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: tt.bodyMedium?.copyWith(color: scheme.onInverseSurface),
        actionTextColor: scheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
      ),

      // ProgressIndicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primaryContainer,
        circularTrackColor: scheme.primaryContainer,
      ),

      // FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        elevation: 2,
        focusElevation: 4,
        hoverElevation: 3,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // SegmentedButton
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return scheme.primaryContainer;
            }
            return scheme.surfaceContainerHigh;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return scheme.onPrimaryContainer;
            }
            return scheme.onSurface;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return BorderSide(color: scheme.primary, width: 2);
            }
            return BorderSide(color: scheme.outlineVariant);
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: tt.bodySmall?.copyWith(color: scheme.onInverseSurface),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        waitDuration: const Duration(milliseconds: 500),
      ),

      // Drawer
      drawerTheme: DrawerThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        elevation: 16,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
        ),
      ),

      // ExpansionTile
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        collapsedBackgroundColor: scheme.surfaceContainerLowest,
        textColor: scheme.onSurface,
        collapsedTextColor: scheme.onSurface,
        iconColor: scheme.onSurfaceVariant,
        collapsedIconColor: scheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),

      // PopupMenu
      popupMenuTheme: PopupMenuThemeData(
        elevation: 8,
        shadowColor: scheme.shadow.withValues(alpha: 0.3),
        surfaceTintColor: scheme.surfaceTint,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: tt.bodyLarge?.copyWith(color: scheme.onSurface),
      ),

      // TimePicker
      timePickerTheme: TimePickerThemeData(
        backgroundColor: scheme.surface,
        hourMinuteTextColor: scheme.onSurface,
        hourMinuteColor: scheme.surfaceContainerHigh,
        dayPeriodTextColor: scheme.onSurfaceVariant,
        dayPeriodColor: scheme.surfaceContainerHighest,
        dialHandColor: scheme.primary,
        dialBackgroundColor: scheme.primaryContainer,
        entryModeIconColor: scheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // DatePicker
      datePickerTheme: DatePickerThemeData(
        backgroundColor: scheme.surface,
        headerBackgroundColor: scheme.primaryContainer,
        headerForegroundColor: scheme.onPrimaryContainer,
        surfaceTintColor: scheme.surfaceTint,
        shadowColor: scheme.shadow.withValues(alpha: 0.3),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        dayStyle: tt.bodyLarge?.copyWith(color: scheme.onSurface),
        yearStyle: tt.bodyLarge?.copyWith(color: scheme.onSurface),
        rangePickerHeaderBackgroundColor: scheme.primaryContainer,
        rangePickerHeaderForegroundColor: scheme.onPrimaryContainer,
        rangePickerHeaderHeadlineStyle: tt.titleMedium?.copyWith(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}