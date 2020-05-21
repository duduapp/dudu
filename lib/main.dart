import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'my_app.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.white));
  runApp(MyApp());
}
