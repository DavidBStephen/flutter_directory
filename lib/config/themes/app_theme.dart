import 'package:flutter/material.dart';

class AppTheme {
  static const Color _mainColor = Colors.orange;

  static const Color _secondaryColor = Colors.amberAccent;
  static const TextStyle _blackTextStyle = TextStyle(color: Colors.black);
  static const TextStyle _black54TextStyle = TextStyle(color: Colors.black54);
  static const TextStyle _black87TextStyle = TextStyle(color: Colors.black87);

  static final lightTheme = ThemeData.light().copyWith(
    primaryColor: _mainColor,
    textTheme: const TextTheme(
      headline1: _blackTextStyle,
      headline2: _blackTextStyle,
      headline3: _blackTextStyle,
      headline4: _blackTextStyle,
      headline5: _blackTextStyle,
      headline6: _blackTextStyle,
      bodyText1: _black54TextStyle,
      bodyText2: _black54TextStyle,
      subtitle1: _black87TextStyle,
      subtitle2: _black87TextStyle,
    ),
    appBarTheme: _appBarTheme,
    floatingActionButtonTheme: ThemeData.dark()
        .floatingActionButtonTheme
        .copyWith(backgroundColor: _mainColor),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      )),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: _secondaryColor),
  );

  static final darkTheme = ThemeData.dark().copyWith(
    primaryColor: _mainColor,
    appBarTheme: _appBarTheme,
    floatingActionButtonTheme: ThemeData.dark()
        .floatingActionButtonTheme
        .copyWith(backgroundColor: _mainColor),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          onSurface: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          )),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: _secondaryColor),
  );

  static final _appBarTheme = AppBarTheme(
      foregroundColor: Colors.white,
      shadowColor: _mainColor,
      color: _mainColor,
      iconTheme: ThemeData.light().iconTheme.copyWith(color: Colors.white),
      toolbarTextStyle: const TextTheme(
              headline6: TextStyle(fontSize: 24.0, color: Colors.white))
          .bodyText2,
      titleTextStyle: const TextTheme(
              headline6: TextStyle(fontSize: 24.0, color: Colors.white))
          .headline6);
}
