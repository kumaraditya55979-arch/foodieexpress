import 'package:flutter/material.dart';
class AdminTheme {
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFFE23744);
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color bg = Color(0xFFF0F0F7);
  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF7B7B7B);
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primary, primary: primary),
    scaffoldBackgroundColor: bg,
    appBarTheme: const AppBarTheme(backgroundColor: Colors.white, elevation: 0, iconTheme: IconThemeData(color: textPrimary), titleTextStyle: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
    cardTheme: CardTheme(color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFF0F0F0)))),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size(double.infinity, 52))),
  );
}
