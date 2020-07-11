import 'package:dio/dio.dart';
import 'package:fastodon/models/user.dart';
import 'package:fastodon/widget/dialog/loading_dialog.dart';
import 'package:fastodon/widget/flutter_framework/progress_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fastodon/public.dart';
import 'package:nav_router/nav_router.dart';

enum RequestType {
  get,
  post,
  put,
  delete,
  patch
}

class Request {
  static Future get({String url, Map params, Map header}) async {
    Response res = await get1(url: url, params: params, header: header);
    return res.data;
  }

  // response all instead of response data only
  static Future get1({String url, Map params, Map header}) async {
    if (params != null && params.isNotEmpty) {
      StringBuffer sb = new StringBuffer("?");
      params.forEach((key, value) {
        sb.write("$key" + "=" + "$value" + "&");
      });
      String paramStr = sb.toString();
      paramStr = paramStr.substring(0, paramStr.length - 1);
      url += paramStr;
    }

    var dio = Request.createDio();
    if (header != null && header.isNotEmpty) {
      dio.options.headers = header;
    }
    try {
      Response response = await dio.get(url);
      if (response.statusCode != 200) {
        var errorMsg = "网络请求错误,状态码:" + response.statusCode.toString();
        showTotast(errorMsg);
      } else if (response.statusCode == 200 && response != null) {
        return response;
      }
    } catch (exception) {
      showTotast(exception.toString());
    }
  }

  static Future post(
      {String url,
      Object params,
      String errMsg,
      bool showDialog,
      String dialogMessage}) async {
    return await _request(
        requestType: RequestType.post,
        url: url,
        params: params,
        errMsg: errMsg,
        showDialog: showDialog,
        dialogMessage: dialogMessage);
  }

  static Future put(
      {String url,
      Object params,
      String errMsg,
      bool showDialog,
      String dialogMessage}) async {
    return await _request(
        requestType: RequestType.put,
        url: url,
        params: params,
        errMsg: errMsg,
        showDialog: showDialog,
        dialogMessage: dialogMessage);
  }

  static Future patch(
      {String url,
      Object params,
      String errMsg,
      bool showDialog,
      String dialogMessage}) async {
    return await _request(
        requestType: RequestType.patch,
        url: url,
        errMsg: errMsg,
        showDialog: showDialog,
        dialogMessage: dialogMessage);
  }

  static Future delete(
      {String url,
      Object params,
      String errMsg,
      bool showDialog,
      String dialogMessage}) async {
    return await _request(
        requestType: RequestType.delete,
        url: url,
        errMsg: errMsg,
        showDialog: showDialog,
        dialogMessage: dialogMessage);
  }

  static Future _request (
      {String url,
      @required RequestType requestType,
      Object params,
      String errMsg,
      bool showDialog,
      String dialogMessage}) async {
    ProgressDialog dialog;
    Response response;
    if (showDialog != null && showDialog == true) {
      dialog = ProgressDialog(navGK.currentState.overlay.context,
          isDismissible: false, customBody: LoadingDialog(text: dialogMessage));
      dialog.style(borderRadius: 20);
      await dialog.show();
    }
    var dio = Request.createDio();
    try {
      switch (requestType) {
        case RequestType.get:
          response = await dio.get(url, queryParameters: params);
          break;
        case RequestType.post:
          response = await dio.post(url, data: params);
          break;
        case RequestType.put:
          response = await dio.put(url, data: params);
          break;
        case RequestType.delete:
          response = await dio.delete(url, data: params);
          break;
        case RequestType.patch:
          response = await dio.patch(url,data: params);
          break;
      }
      dialog?.update(
          customBody: LoadingDialog(
            text: '已完成',
        finished: true,
      ));
    } catch (e) {
      if (errMsg != null) {
        showTotast(errMsg);
      }
    }
    await Future.delayed(Duration(milliseconds: 100), () {
      dialog?.hide();
    });
    return response.data;
  }

  static void showTotast(String errorMsg) {
    Fluttertoast.showToast(
        msg: errorMsg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: MyColor.error,
        textColor: MyColor.loginWhite,
        fontSize: 16.0);
    throw (errorMsg);
  }

  static Dio createDio() {
    var dio = new Dio();

    User user = new User();
    String userHeader = user.getToken();
    String urlHost = user.getHost();

    if (userHeader != null || urlHost != null) {
      dio.options.headers = {'Authorization': userHeader};
      dio.options.baseUrl = urlHost;
    }
    // dio拦截器
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) {
      print(options.uri);
      return options; //continue
    }, onResponse: (Response response) {
      print('收到了json信息');
      // print(response);
      return response; // continue
    }, onError: (DioError e) {
      // 当请求失败时做一些预处理
      return e; //continue
    }));

    return dio;
  }
}
