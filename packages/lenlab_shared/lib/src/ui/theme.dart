import 'package:flutter/material.dart';

abstract final class P2 {
  static const cream = Color(0xFFF7F1E8);
  static const rose = Color(0xFFD9B8A7);
  static const brown = Color(0xFF6B4B3E);

  // P2 defines separate button colors by role; do not apply one globally.
  static const productCardButton = Color(0xFF383029);
  static const productDetailButton = Color(0xFFF09942);
  static const checkoutButton = Color(0xFFE9A663);
  static const authButton = Color(0xFFD9A52E);
  static const authButtonLoading = Color(0xFFDBA324);
  static const categoryButton = Color(0xFF523419);
  static const ink = Color(0xFF6B3510);
  static const green = Color(0xFF344D24);
  static const gold = Color(0xFFD9A526);
  static const orange = Color(0xFFF59B3D);
  static const admin = Color(0xFFF3F4F6);
  static const tan = Color(0xFFD1A373);
  static const terracotta = Color(0xFFD97757);
  static const border = Color(0xFFE5E7EB);
  static TextStyle serif(
    double size, {
    Color color = brown,
    FontWeight weight = FontWeight.w400,
  }) => TextStyle(
    fontFamily: 'packages/lenlab_shared/PlayfairDisplay',
    fontSize: size,
    color: color,
    fontWeight: weight,
  );
  static ThemeData theme({bool admin = false}) {
    final scheme = ColorScheme.fromSeed(
      seedColor: admin ? tan : brown,
      primary: admin ? tan : brown,
      surface: admin ? Colors.white : cream,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'packages/lenlab_shared/${admin ? 'Inter' : 'BeVietnamPro'}',
      scaffoldBackgroundColor: admin ? P2.admin : cream,
      textTheme: TextTheme(
        bodyMedium: TextStyle(
          color: admin ? const Color(0xFF374151) : brown,
          fontSize: 14,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: admin ? Colors.white : rose,
        foregroundColor: ink,
        centerTitle: !admin,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'packages/lenlab_shared/BeVietnamPro',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: admin ? const Color(0xFFF9FAFB) : rose,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(admin ? 9 : 10),
          borderSide: BorderSide(
            color: admin ? border : brown,
            width: admin ? 1 : 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(admin ? 9 : 10),
          borderSide: BorderSide(
            color: admin ? border : brown,
            width: admin ? 1 : 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ink, width: 2),
        ),
      ),
      dividerColor: admin ? border : brown.withValues(alpha: .18),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brown,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: admin ? tan : orange,
          foregroundColor: admin ? const Color(0xFF4D2B1A) : brown,
          elevation: 0,
          minimumSize: const Size(44, 48),
          textStyle: TextStyle(
            fontFamily:
                'packages/lenlab_shared/${admin ? 'Inter' : 'BeVietnamPro'}',
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(admin ? 10 : 99),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brown,
          minimumSize: const Size(44, 48),
          side: const BorderSide(color: brown),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(admin ? 10 : 99),
          ),
        ),
      ),
    );
  }
}
