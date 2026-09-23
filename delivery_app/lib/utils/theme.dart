import 'package:flutter/material.dart';
class DeliveryTheme {
  static const Color primary = Color(0xFF1A73E8);
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color bg = Color(0xFFF5F5F5);
  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF7B7B7B);
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.fromSeed(seedColor: primary, primary: primary),
    scaffoldBackgroundColor: bg,
    appBarTheme: const AppBarTheme(backgroundColor: Colors.white, elevation: 0, iconTheme: IconThemeData(color: textPrimary), titleTextStyle: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size(double.infinity, 52))),
    cardTheme: CardTheme(color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFF0F0F0)))),
  );
}
