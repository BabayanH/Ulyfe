import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeData get lightTheme => ThemeData.light();

  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black, // This sets the AppBar color
    appBarTheme: AppBarTheme(
      color: Colors.black, // This should set AppBar color too
    ),
    scaffoldBackgroundColor: Color(0xFF111111),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey.shade600,
    ),
    textTheme: TextTheme(
      bodyText1: TextStyle(color: Colors.white), // Setting text color to white
      bodyText2: TextStyle(color: Colors.white), // Setting text color to white
    ),
  );

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
