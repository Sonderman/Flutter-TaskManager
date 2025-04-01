import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: Color(0xFF2D3192),
          secondary: Color(0xFF006D77),
          surface: Color(0xFFF8F9FA),
          background: Color(0xFFFFFFFF),
          onPrimary: Colors.white,
          error: Colors.red[700]!,
          onSurface: Colors.black87,
        ),
        scaffoldBackgroundColor: Color(0xFFF8F9FA),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF2D3192),
          foregroundColor: Colors.white,
          elevation: 2,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 1.3,
            color: Colors.black87,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Colors.grey[800],
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey[900],
          ),
        ).apply(
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF2D3192),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF9BB1FF),
          secondary: Color(0xFF83C5BE),
          surface: Color(0xFF2F2F2F),
          background: Color(0xFF121212),
          onPrimary: Colors.black87,
          error: Colors.red[300]!,
          onSurface: Colors.white70,
        ),
        scaffoldBackgroundColor: Color(0xFF121212),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF2F2F2F),
          foregroundColor: Colors.white,
          elevation: 2,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 1.3,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Colors.white70,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ).apply(
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Color(0xFF2F2F2F),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF9BB1FF),
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      );
}
