import 'package:flutter/material.dart';
class AppTheme {
  static final Color primary = Color(0xFFEF7A9A); // soft pink
  static final Color accent = Color(0xFF6EC1C6); // teal
  static final Color surface = Colors.white;
  static final Color bg = Color(0xFFF7F8FB);

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primary,
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: accent),
    scaffoldBackgroundColor: bg,
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black87),
      titleTextStyle: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: surface,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
  );
}

class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFEF7A9A), // pink
            Color(0xFF6EC1C6), // teal
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}
