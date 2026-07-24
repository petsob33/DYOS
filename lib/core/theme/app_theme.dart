import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.card,
    required this.primary,
    required this.text,
    required this.textSecondary,
    required this.love,
    required this.success,
    required this.warning,
    required this.shadow,
  });

  final Color background;
  final Color card;
  final Color primary;
  final Color text;
  final Color textSecondary;
  final Color love;
  final Color success;
  final Color warning;
  final Color shadow;

  static const light = AppPalette(
    background: Color(0xFFF2F2F7),
    card: Colors.white,
    primary: Color(0xFF5E5CE6),
    text: Color(0xFF1C1C1E),
    textSecondary: Color(0xFF8E8E93),
    love: Color(0xFFFF375F),
    success: Color(0xFF34C759),
    warning: Color(0xFFFF9F0A),
    shadow: Color(0x1A000000),
  );

  static const dark = AppPalette(
    background: Color(0xFF000000),
    card: Color(0xFF1C1C1E),
    primary: Color(0xFF7A78F0),
    text: Color(0xFFF2F2F7),
    textSecondary: Color(0xFF98989D),
    love: Color(0xFFFF6482),
    success: Color(0xFF32D74B),
    warning: Color(0xFFFFB340),
    shadow: Color(0x33000000),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? card,
    Color? primary,
    Color? text,
    Color? textSecondary,
    Color? love,
    Color? success,
    Color? warning,
    Color? shadow,
  }) {
    return AppPalette(
      background: background ?? this.background,
      card: card ?? this.card,
      primary: primary ?? this.primary,
      text: text ?? this.text,
      textSecondary: textSecondary ?? this.textSecondary,
      love: love ?? this.love,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      text: Color.lerp(text, other.text, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      love: Color.lerp(love, other.love, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get colors => Theme.of(this).extension<AppPalette>()!;
}

class AppTheme {
  static ThemeData _themeFor(AppPalette palette, Brightness brightness) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: palette.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.primary,
        primary: palette.primary,
        background: palette.background,
        brightness: brightness,
      ),
      textTheme: GoogleFonts.interTextTheme(
        brightness == Brightness.dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),
      extensions: [palette],
    );

    return base.copyWith(
      cardTheme: CardThemeData(
        color: palette.card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
        shadowColor: palette.shadow,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: palette.text,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
      ),
    );
  }

  static ThemeData get light => _themeFor(AppPalette.light, Brightness.light);
  static ThemeData get dark => _themeFor(AppPalette.dark, Brightness.dark);

  static CupertinoThemeData get cupertinoLight {
    return CupertinoThemeData(
      primaryColor: AppPalette.light.primary,
      scaffoldBackgroundColor: AppPalette.light.background,
      barBackgroundColor: AppPalette.light.card,
      textTheme: CupertinoTextThemeData(
        textStyle: GoogleFonts.inter(color: AppPalette.light.text),
      ),
    );
  }
}
