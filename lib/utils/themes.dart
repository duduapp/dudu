import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';

class ThemeUtil {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      primaryColor: Colors.white,
      toggleableActiveColor: Colors.blue,
      appBarTheme: AppBarTheme(
          elevation: 1.0, color: Color.fromRGBO(252, 252, 252, 1)),
      dialogTheme: DialogTheme(),
      popupMenuTheme: PopupMenuThemeData(color: Colors.white),
      inputDecorationTheme:
          InputDecorationTheme(fillColor: Color.fromRGBO(240, 240, 240, 1)),
      backgroundColor: Color.fromRGBO(238, 238, 238, 1),
      buttonColor: Colors.blue,
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.white),
      splashColor: Colors.transparent,
      accentColor: Colors.grey[600],
      bottomAppBarColor: Color.fromRGBO(246, 246, 246, 1),
      scaffoldBackgroundColor: Color.fromRGBO(238, 238, 238, 1),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.blue,
        textTheme: ButtonTextTheme.primary,

      ),
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
        primaryColor: Color.fromRGBO(30, 30, 30, 1),
        accentColor: Colors.white,
        toggleableActiveColor: Colors.white,
        backgroundColor: Color.fromRGBO(21, 21, 21, 1),
        appBarTheme:
        AppBarTheme(color: Color.fromRGBO(30, 30, 30, 1), elevation: 1.0),
        splashColor: Colors.transparent,
        scaffoldBackgroundColor: Color.fromRGBO(21, 21, 21, 1),
        buttonColor: Colors.blue //Colors.grey[800],

    );
  }
}

