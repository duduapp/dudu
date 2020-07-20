import 'package:fastodon/models/local_account.dart';
import 'package:flutter/material.dart';

import 'my_app.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  LocalAccount account = await LocalStorageAccount.getActiveAccount();
  runApp(MyApp(logined: account != null,));
}
