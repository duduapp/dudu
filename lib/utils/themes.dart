import 'package:flutter/material.dart';

var defaultTheme = ThemeData(
  primaryColor: Colors.white,
  toggleableActiveColor: Colors.blue,
  appBarTheme: AppBarTheme(elevation: 1.0,color: Color.fromRGBO(252, 252, 252, 0.98)),
  dialogTheme: DialogTheme(),
  popupMenuTheme: PopupMenuThemeData(color: Colors.white),
  inputDecorationTheme: InputDecorationTheme(fillColor: Color.fromRGBO(240, 240, 240, 1)),
  backgroundColor: Color.fromRGBO(238, 238, 238, 1),
  buttonColor: Colors.blue,
  bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.white),
  splashColor: Colors.grey[600],
  accentColor: Colors.grey[600],
  scaffoldBackgroundColor: Color.fromRGBO(238, 238, 238, 1),


  
);

var darTheme = ThemeData.dark().copyWith(
  primaryColor: Color.fromRGBO(30, 30, 30, 1),
  accentColor: Colors.white,
  toggleableActiveColor: Colors.white,
  backgroundColor: Color.fromRGBO(21, 21, 21, 1),
  appBarTheme: AppBarTheme(color: Color.fromRGBO(30, 30, 30, 1),elevation: 1.0),
  splashColor: Colors.grey[800],
  scaffoldBackgroundColor: Color.fromRGBO(21, 21, 21, 1),
  buttonColor: Colors.blue //Colors.grey[800],

);