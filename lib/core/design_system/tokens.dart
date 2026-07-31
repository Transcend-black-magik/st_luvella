import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  static const canvas = Color(0xFFF4F3EF);
  static const ink = Color(0xFF0A0A0A);
  static const muted = Color(0xFF73736F);
  static const border = Color(0xFFD8D8D4);
  static const accent = Color(0xFFFF4F35);
  static const white = Color(0xFFFFFFFF);
  static const success = Color(0xFF2E7D5B);
  static const warning = Color(0xFFD99A24);
  static const error = Color(0xFFC83D3D);
  static const charcoal = Color(0xFF20201F);
}

abstract final class AppSpace {
  static const xs = 6.0;
  static const sm = 12.0;
  static const md = 20.0;
  static const lg = 32.0;
  static const xl = 56.0;
  static const xxl = 96.0;
}

abstract final class AppBreakpoints {
  static const mobile = 600.0;
  static const tablet = 900.0;
  static const desktop = 1200.0;
}

ThemeData buildTheme() {
  final body = GoogleFonts.interTextTheme();
  final display = GoogleFonts.spaceGroteskTextTheme();
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.canvas,
    colorScheme: const ColorScheme.light(
      primary: AppColors.ink,
      secondary: AppColors.accent,
      surface: AppColors.white,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.ink,
      onSurface: AppColors.ink,
    ),
    textTheme: body.copyWith(
      displayLarge: display.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -4,
      ),
      displayMedium: display.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -2.5,
      ),
      headlineLarge: display.headlineLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -1.2,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -.8,
      ),
      titleLarge: display.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: body.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: .4,
      ),
      bodyLarge: body.bodyLarge?.copyWith(height: 1.55),
      bodyMedium: body.bodyMedium?.copyWith(height: 1.55),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.ink, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 17),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(0, 52),
        elevation: 0,
        shape: const RoundedRectangleBorder(),
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.white,
        textStyle: body.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: .8,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 52),
        shape: const RoundedRectangleBorder(),
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.ink),
        textStyle: body.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: .6,
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(shape: const RoundedRectangleBorder()),
    ),
    focusColor: AppColors.accent.withValues(alpha: .18),
    visualDensity: VisualDensity.standard,
  );
}

extension ResponsiveContext on BuildContext {
  double get width => MediaQuery.sizeOf(this).width;
  bool get isMobile => width < AppBreakpoints.mobile;
  bool get isTablet =>
      width >= AppBreakpoints.mobile && width < AppBreakpoints.desktop;
  EdgeInsets get pagePadding => EdgeInsets.symmetric(
    horizontal: isMobile ? 18 : (width < 1000 ? 32 : 56),
  );
}
