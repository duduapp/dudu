import 'package:flutter/material.dart';

class ThemeUtil {
  static ThemeData lightTheme() {
    return ThemeData(
      primaryColor: Colors.white,
      toggleableActiveColor: Colors.blue,
      appBarTheme:
          AppBarTheme(elevation: 1.0, color: Color.fromRGBO(252, 252, 252, 1),textTheme: TextTheme(
            headline6: TextStyle(fontSize: 18,color: Colors.black)
          )),
      dialogTheme: DialogTheme(),
      popupMenuTheme: PopupMenuThemeData(color: Color.fromRGBO(238, 238, 238, 1)),
      inputDecorationTheme:
          InputDecorationTheme(fillColor: Color.fromRGBO(240, 240, 240, 1)),
      backgroundColor: Color.fromRGBO(238, 238, 238, 1),
      buttonColor: Colors.blue,
      textTheme: TextTheme(
        headline5: TextStyle(color: Color.fromRGBO(68, 75, 91, 1))
      ),
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

  static ThemeData darkTheme() {
    return ThemeData.dark().copyWith(
        primaryColor: Color.fromRGBO(30, 30, 30, 1),
        accentColor: Colors.grey[600],
        textTheme: TextTheme(
            bodyText1: TextStyle(color: Color.fromRGBO(211, 211, 211, 1)),
            bodyText2: TextStyle(color: Color.fromRGBO(211, 211, 211, 1)),),
        toggleableActiveColor: Colors.blue,
        backgroundColor: Color.fromRGBO(21, 21, 21, 1),
        appBarTheme:
            AppBarTheme(color: Color.fromRGBO(30, 30, 30, 1), elevation: 1.0),
        splashColor: Colors.transparent,
        scaffoldBackgroundColor: Color.fromRGBO(21, 21, 21, 1),
        buttonColor: Colors.blue //Colors.grey[800],

        );
  }

  static ThemeData lightDartTheme() {
    return ThemeData.dark().copyWith(
        primaryColor: Color.fromRGBO(49,52,67, 1),
        accentColor: Color.fromRGBO(154, 174, 199, 1),
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),
          subtitle1: TextStyle(color: Color.fromRGBO(216, 225, 232, 1)),
          headline5: TextStyle(color: Color.fromRGBO(154, 174, 199, 1)), // 转嘟前面颜色
          bodyText2: TextStyle(color: Color.fromRGBO(226, 226, 226, 1)),),

        toggleableActiveColor: Colors.blue,
        backgroundColor: Color.fromRGBO(40, 44, 53, 1),
        appBarTheme:
        AppBarTheme(color: Color.fromRGBO(68, 75, 93, 1), elevation: 1.0),
        splashColor: Colors.transparent,
        scaffoldBackgroundColor: Color.fromRGBO(40,44,55, 1),
        buttonColor: Colors.blue, //Colors.grey[800],
        dialogTheme: DialogTheme(backgroundColor: Color.fromRGBO(49,52,67, 1)),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: Color.fromRGBO(49,52,67, 1)),
      cardColor: Color.fromRGBO(40,44,55, 1),
    );
  }

  static get themes {
    return [lightTheme(),lightDartTheme(),darkTheme()];
  }
}
