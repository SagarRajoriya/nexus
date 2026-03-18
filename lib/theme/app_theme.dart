import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary    = Color(0xFF6C63FF);
  static const Color accent     = Color(0xFF00D4AA);
  static const Color danger     = Color(0xFFEF4444);
  static const Color warning    = Color(0xFFF59E0B);
  static const Color success    = Color(0xFF10B981);

  static const Color transferColor  = Color(0xFF3B82F6);
  static const Color streamColor    = Color(0xFFEC4899);
  static const Color mouseColor     = Color(0xFF8B5CF6);
  static const Color clipboardColor = Color(0xFF14B8A6);
  static const Color notifColor     = Color(0xFFF97316);
  static const Color cloudColor     = Color(0xFF06B6D4);

  static const Color _darkBg        = Color(0xFF0A0A14);
  static const Color _darkSurface   = Color(0xFF13131F);
  static const Color _darkSurface2  = Color(0xFF1C1C2E);
  static const Color _darkOnSurface = Color(0xFFE8E8F0);

  static const Color _lightBg        = Color(0xFFF0F0FA);
  static const Color _lightSurface   = Color(0xFFFFFFFF);
  static const Color _lightSurface2  = Color(0xFFF5F5FF);
  static const Color _lightOnSurface = Color(0xFF0F0F1A);

  static TextTheme _textTheme(Color c) => TextTheme(
    displayLarge:  GoogleFonts.sora(fontSize: 32, fontWeight: FontWeight.w700, color: c),
    displayMedium: GoogleFonts.sora(fontSize: 26, fontWeight: FontWeight.w600, color: c),
    headlineLarge: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w600, color: c),
    headlineMedium:GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: c),
    titleLarge:    GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600, color: c),
    titleMedium:   GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: c),
    bodyLarge:     GoogleFonts.inter(fontSize: 16, color: c),
    bodyMedium:    GoogleFonts.inter(fontSize: 14, color: c),
    bodySmall:     GoogleFonts.inter(fontSize: 12, color: c.withOpacity(0.55)),
    labelLarge:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: c),
    labelSmall:    GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: c),
  );

  static CardThemeData _card(Color surface, Color border) => CardThemeData(
    color: surface, elevation: 0, margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: border),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true, brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primary, secondary: accent,
      surface: _darkSurface, onSurface: _darkOnSurface,
      surfaceContainerHighest: _darkSurface2,
      outline: Colors.white.withOpacity(0.12),
      outlineVariant: Colors.white.withOpacity(0.06),
    ),
    scaffoldBackgroundColor: _darkBg,
    textTheme: _textTheme(_darkOnSurface),
    cardTheme: _card(_darkSurface, Colors.white.withOpacity(0.08)),
    dividerTheme: DividerThemeData(color: Colors.white.withOpacity(0.08), thickness: 1),
    listTileTheme: ListTileThemeData(textColor: _darkOnSurface, iconColor: _darkOnSurface.withOpacity(0.5)),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => Colors.white),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? primary : Colors.white.withOpacity(0.15)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: Colors.white.withOpacity(0.05),
      labelStyle: GoogleFonts.inter(color: _darkOnSurface.withOpacity(0.6), fontSize: 14),
      hintStyle:  GoogleFonts.inter(color: _darkOnSurface.withOpacity(0.35), fontSize: 14),
      border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.12))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.12))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primary, width: 1.5)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _darkSurface, foregroundColor: _darkOnSurface, elevation: 0, centerTitle: false,
      titleTextStyle: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: _darkOnSurface),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: _darkSurface,
      selectedIconTheme:   const IconThemeData(color: primary, size: 20),
      unselectedIconTheme: IconThemeData(color: _darkOnSurface.withOpacity(0.35), size: 20),
      selectedLabelTextStyle:   GoogleFonts.inter(color: primary, fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelTextStyle: GoogleFonts.inter(color: _darkOnSurface.withOpacity(0.35), fontSize: 12),
      indicatorColor: primary.withOpacity(0.15),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _darkSurface, selectedItemColor: primary,
      unselectedItemColor: _darkOnSurface.withOpacity(0.35),
      type: BottomNavigationBarType.fixed, elevation: 0,
      selectedLabelStyle:   GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white.withOpacity(0.07), selectedColor: primary.withOpacity(0.2),
      side: BorderSide(color: Colors.white.withOpacity(0.12)),
      labelStyle: GoogleFonts.inter(fontSize: 13, color: _darkOnSurface), checkmarkColor: primary,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? primary.withOpacity(0.2) : Colors.transparent),
      foregroundColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? primary : _darkOnSurface.withOpacity(0.5)),
      side: WidgetStatePropertyAll(BorderSide(color: Colors.white.withOpacity(0.12))),
    )),
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true, brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primary, secondary: accent,
      surface: _lightSurface, onSurface: _lightOnSurface,
      surfaceContainerHighest: _lightSurface2,
      outline: Colors.black.withOpacity(0.12),
      outlineVariant: Colors.black.withOpacity(0.06),
    ),
    scaffoldBackgroundColor: _lightBg,
    textTheme: _textTheme(_lightOnSurface),
    cardTheme: _card(_lightSurface, Colors.black.withOpacity(0.08)),
    dividerTheme: DividerThemeData(color: Colors.black.withOpacity(0.08), thickness: 1),
    listTileTheme: ListTileThemeData(textColor: _lightOnSurface, iconColor: _lightOnSurface.withOpacity(0.5)),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => Colors.white),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? primary : Colors.black.withOpacity(0.2)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: Colors.black.withOpacity(0.03),
      labelStyle: GoogleFonts.inter(color: _lightOnSurface.withOpacity(0.6), fontSize: 14),
      hintStyle:  GoogleFonts.inter(color: _lightOnSurface.withOpacity(0.35), fontSize: 14),
      border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.black.withOpacity(0.12))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.black.withOpacity(0.12))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primary, width: 1.5)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _lightSurface, foregroundColor: _lightOnSurface, elevation: 0, centerTitle: false,
      titleTextStyle: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: _lightOnSurface),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: _lightSurface,
      selectedIconTheme:   const IconThemeData(color: primary, size: 20),
      unselectedIconTheme: IconThemeData(color: _lightOnSurface.withOpacity(0.35), size: 20),
      selectedLabelTextStyle:   GoogleFonts.inter(color: primary, fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelTextStyle: GoogleFonts.inter(color: _lightOnSurface.withOpacity(0.35), fontSize: 12),
      indicatorColor: primary.withOpacity(0.1),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _lightSurface, selectedItemColor: primary,
      unselectedItemColor: _lightOnSurface.withOpacity(0.35),
      type: BottomNavigationBarType.fixed, elevation: 0,
      selectedLabelStyle:   GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.black.withOpacity(0.05), selectedColor: primary.withOpacity(0.15),
      side: BorderSide(color: Colors.black.withOpacity(0.12)),
      labelStyle: GoogleFonts.inter(fontSize: 13, color: _lightOnSurface), checkmarkColor: primary,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? primary.withOpacity(0.12) : Colors.transparent),
      foregroundColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? primary : _lightOnSurface.withOpacity(0.5)),
      side: WidgetStatePropertyAll(BorderSide(color: Colors.black.withOpacity(0.12))),
    )),
  );
}
