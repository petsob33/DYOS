import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppPalette {
  const AppPalette();

  final Color background = const Color(0xFFF2F2F7);
  final Color card = Colors.white;
  final Color primary = const Color(0xFF5E5CE6);
  final Color text = const Color(0xFF1C1C1E);
  final Color textSecondary = const Color(0xFF8E8E93);
  final Color love = const Color(0xFFFF375F);
  final Color success = const Color(0xFF34C759);
  final Color warning = const Color(0xFFFF9F0A);
  final Color shadow = const Color(0x1A000000);
}

class AppTheme {
  static const colors = AppPalette();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        primary: colors.primary,
        background: colors.background,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme(),
    );

    return base.copyWith(
      cardTheme: CardThemeData(
        color: colors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
        shadowColor: colors.shadow,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colors.text,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
      ),
    );
  }

  static CupertinoThemeData get cupertinoLight {
    return CupertinoThemeData(
      primaryColor: colors.primary,
      scaffoldBackgroundColor: colors.background,
      barBackgroundColor: colors.card,
      textTheme: CupertinoTextThemeData(
        textStyle: GoogleFonts.inter(color: colors.text),
      ),
    );
  }
}
