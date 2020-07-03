import 'package:flutter/material.dart';

var defaultTheme = ThemeData(
  primaryColor: Colors.white,
  toggleableActiveColor: Color.fromRGBO(0, 0, 0, 60),
  appBarTheme: AppBarTheme(elevation: 0.0,color: Color.fromRGBO(240, 240, 240, 1)),
  dialogTheme: DialogTheme(),
  popupMenuTheme: PopupMenuThemeData(color: Colors.white),
  inputDecorationTheme: InputDecorationTheme(fillColor: Color.fromRGBO(240, 240, 240, 1)),
  backgroundColor: Color.fromRGBO(240, 240, 240, 1),
  buttonColor: Colors.grey[500],
  bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.white),
  splashColor: Colors.grey[600]


  
);

var darTheme = ThemeData.dark().copyWith(
  accentColor: Colors.white,
  toggleableActiveColor: Colors.white,
  backgroundColor: Colors.black38,
  appBarTheme: AppBarTheme(color: Colors.black38,elevation: 0.0),
  splashColor: Colors.grey[500]

);