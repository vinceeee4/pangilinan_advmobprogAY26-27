import 'package:flutter/material.dart';

import '../constants.dart';

/// App-wide theme state (dark / light) shared through Provider.
class ThemeProvider with ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  /// Light theme used by MaterialApp.theme
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimary,
      primary: kPrimary,
      secondary: kAccent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kPrimary,
      foregroundColor: Colors.white,
    ),
  );

  /// Dark theme used by MaterialApp.darkTheme
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimary,
      secondary: kAccent,
      brightness: Brightness.dark,
    ),
  );
}
