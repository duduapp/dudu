

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
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height:200,child: Image(image: AssetImage('assets/images/oops.gif'),)),
            Text(getErrorString(),style: TextStyle(fontSize: 18),),
            SizedBox(height: 10,),
            OutlineButton(child: Text('重试',style: TextStyle(fontWeight: FontWeight.normal,color: Theme.of(context).buttonColor),),onPressed:onClickRetry,)
          ],
        ),
      ),
    );
  }

  String getErrorString() {
    if (error is SocketException) {
      return '网络请求出错，请检查互联网并重试';
    }
    if (error is AuthRequiredException) {
      return '需要登录才能查看当前实例内容';
    }
    return '应用程序出现错误';
  }
}
