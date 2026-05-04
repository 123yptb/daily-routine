import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Color Palette (Sacred Modernist Light) ─────────────────────────────────
  static const Color background = Color(0xFFF7F5F2); // Warm off-white
  static const Color cardBg = Color(0xFFFFFFFF); // White cards
  
  static const Color textPrimary = Color(0xFF2C2C2C); // Dark gray/brown
  static const Color textSecondary = Color(0xFF8C8A87);
  static const Color textMuted = Color(0xFFB4B2AE);
  
  static const Color accentYellow = Color(0xFFFFBE21); // The main sunny yellow
  static const Color accentBrown = Color(0xFF7B4E41);
  static const Color accentGreen = Color(0xFF85A943);
  static const Color accentOlive = Color(0xFF767A66);

  // Pastel Card Colors
  static const Color pastelPeach = Color(0xFFFDE4E1);
  static const Color pastelLavender = Color(0xFFE8E2FF);
  static const Color pastelGreen = Color(0xFFE2EBE0);
  static const Color pastelSand = Color(0xFFDFD7CF);

  // ─── Backward Compatibility Aliases for other screens ───────────
  static const Color navy = background;
  static const Color navyLight = background;
  static const Color navyCard = cardBg;
  static const Color charcoal = cardBg;
  static const Color charcoalLight = pastelSand;
  
  static const Color accentCyan = accentYellow;
  static const Color accentPurple = pastelLavender;
  static const Color accentPink = pastelPeach;
  static const Color accentAmber = accentYellow;
  static const Color accentRed = Color(0xFFE57373); // Soft red

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentYellow, Color(0xFFFF9D00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [accentGreen, Color(0xFFA2C653)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient failGradient = LinearGradient(
    colors: [accentRed, Color(0xFFEF9A9A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, Color(0xFFEFEBE4)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Color glassBorder = Color(0x1A000000); // Faint dark border
  static const Color glassBackground = Color(0x99FFFFFF);

  // ─── Cupertino Theme ──────────────────────────────────────────────────────
  static CupertinoThemeData get cupertinoTheme => CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: accentYellow,
        primaryContrastingColor: textPrimary,
        barBackgroundColor: const Color(0xEEF7F5F2),
        scaffoldBackgroundColor: background,
        textTheme: CupertinoTextThemeData(
          primaryColor: accentYellow,
          textStyle: GoogleFonts.nunito(
            color: textPrimary,
            fontSize: 17,
          ),
          navLargeTitleTextStyle: GoogleFonts.nunito(
            color: textPrimary,
            fontSize: 34,
            fontWeight: FontWeight.w800,
          ),
          navTitleTextStyle: GoogleFonts.nunito(
            color: textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  // ─── Fallback Material theme ─────────────────────────────────────────────
  static ThemeData get materialFallback => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.light(
          primary: accentYellow,
          secondary: accentBrown,
          surface: cardBg,
          error: Color(0xFFE57373),
        ),
        textTheme: GoogleFonts.nunitoTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: accentYellow, width: 2),
          ),
          hintStyle: GoogleFonts.nunito(color: textMuted, fontSize: 15),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );

  // ─── Helpers ──────────────────────────────────────────────────────────────
  static Color categoryColor(String? category) {
    switch (category) {
      case 'calls':
        return accentYellow;
      case 'sales':
        return accentGreen;
      case 'fitness':
        return pastelPeach;
      case 'reading':
        return pastelLavender;
      case 'work':
        return accentBrown;
      default:
        return pastelSand;
    }
  }

  static IconData categoryIcon(String? category) {
    switch (category) {
      case 'calls':
        return CupertinoIcons.phone_fill;
      case 'sales':
        return CupertinoIcons.graph_circle_fill;
      case 'fitness':
        return CupertinoIcons.heart_fill;
      case 'reading':
        return CupertinoIcons.book_fill;
      case 'work':
        return CupertinoIcons.briefcase_fill;
      default:
        return CupertinoIcons.checkmark_circle_fill;
    }
  }
}
