import 'package:dudu/l10n/l10n.dart';


import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dudu/models/exception/auth_required_exception.dart';
import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final Exception error;
  final Function onClickRetry;

  const ErrorView({Key key, this.onClickRetry,this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 30,right: 30),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height:200,child: Image(image: AssetImage('assets/images/error.png'),)),
            Text(getErrorString(context),style: TextStyle(fontSize: 14),),
            SizedBox(height: 10,),
            OutlineButton(child: Text(S.of(context).retry,style: TextStyle(fontWeight: FontWeight.normal,color: Theme.of(context).buttonColor),),onPressed:onClickRetry,)
          ],
        ),
      ),
    );
  }

  String getErrorString(BuildContext context) {
    if (error is SocketException) {
      return S.of(context).there_was_an_error_in_the_network_request;
    }
    if (error is AuthRequiredException) {
      return S.of(context).this_instance_does_not_open_the_timeline_preview_function;
    }
    return S.of(context).an_error_occurred_in_the_application;
  }
}
