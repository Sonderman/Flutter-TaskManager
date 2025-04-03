import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: Color(0xFF2D3192).withOpacity(0.3),
      selectionHandleColor: Color(0xFF2D3192),
      cursorColor: Color(0xFF2D3192),
    ),
    colorScheme: ColorScheme.light(
      brightness: Brightness.light,
      primary: Color.fromARGB(255, 63, 19, 185),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color.fromARGB(255, 121, 93, 229),
      onPrimaryContainer: Color(0xFF22005D),
      secondary: Color(0xFF625B71),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFE8DEF8),
      onSecondaryContainer: Color(0xFF1E192B),
      tertiary: Color(0xFF7E5260),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFF2D7E1),
      onTertiaryContainer: Color(0xFF31101D),
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: Color(0xFFFFFBFE),
      onSurface: Color(0xFF1C1B1F),
      surfaceContainerHighest: Color(0xFFE7E0EC),
      onSurfaceVariant: Color(0xFF49454F),
      outline: Color(0xFF7A757F),
      outlineVariant: Color(0xFFCAC4D0),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF313033),
      onInverseSurface: Color(0xFFF4EFF4),
      inversePrimary: Color(0xFFD0BCFF),
      surfaceTint: Color(0xFF6750A4),
    ),
    scaffoldBackgroundColor: Color(0xFFFFFBFE),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF6750A4),
      foregroundColor: Color(0xFFFFFFFF),
      elevation: 2,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
        fontFamily: 'Roboto',
      ),
      iconTheme: IconThemeData(color: Color(0xFFFFFFFF)),
    ),
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: Colors.black87,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[800]),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[900]),
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shadowColor: Color(0xFF6750A4).withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(0xFFE7E0EC), width: 1),
      ),
      color: Colors.white,
      surfaceTintColor: Color(0xFFFFFBFE),
      margin: EdgeInsets.symmetric(vertical: 8),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color.fromARGB(255, 74, 41, 163),
      foregroundColor: Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: ColorScheme.light().surface,
      selectedItemColor: ColorScheme.light().primary,
      unselectedItemColor: ColorScheme.light().onSurface.withOpacity(0.6),
      selectedLabelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        backgroundColor: ColorScheme.light().surfaceContainerHighest,
        selectedBackgroundColor: ColorScheme.light().primary,
        selectedForegroundColor: ColorScheme.light().onPrimary,
        side: BorderSide(color: ColorScheme.light().outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: Color.fromARGB(255, 219, 91, 91),
      primaryContainer: Color.fromARGB(255, 209, 164, 164),
      secondary: Color(0xFF83C5BE),
      surface: Color(0xFF2F2F2F),
      onPrimary: Colors.black87,
      error: Colors.red[300]!,
      onSurface: Colors.white70,
    ),
    scaffoldBackgroundColor: Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF2F2F2F),
      foregroundColor: Colors.white,
      elevation: 2,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
        fontFamily: 'Roboto',
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
      bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: Colors.white70),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Color(0xFF2F2F2F),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color.fromARGB(255, 190, 224, 222),
      foregroundColor: Colors.black87,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: ColorScheme.dark().surface,
      selectedItemColor: ColorScheme.dark().primary,
      unselectedItemColor: ColorScheme.dark().onSurface.withOpacity(0.6),
      selectedLabelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        backgroundColor: ColorScheme.dark().surfaceContainerHighest,
        selectedBackgroundColor: ColorScheme.dark().secondary,
        //selectedForegroundColor: ColorScheme.dark().onPrimaryContainer,
        side: BorderSide(color: ColorScheme.dark().outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
