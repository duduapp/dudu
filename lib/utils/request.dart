import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/runtime_config.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/widget/dialog/loading_dialog.dart';
import 'package:dudu/widget/flutter_framework/progress_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nav_router/nav_router.dart';

enum RequestType { get, post, put, delete, patch }

class Request {
  static Dio dioClient;
  static Dio dioClientWithCache;
  
  static Future get({String url,Map params,bool showDialog = false,bool returnAll = false,Map header,CancelToken cancelToken,bool enableCache = false}) async{
    return await _request(requestType: RequestType.get,url: url,params: params,showDialog: showDialog,returnAll: returnAll,header: header,cancelToken: cancelToken,enableCache: enableCache);
  }

  static Future post(
      {String url,
      Object params,
      String errMsg,
      bool showDialog = true,
      String dialogMessage,
      String successMessage,
      int closeDilogDelay}) async {
    return await _request(
        requestType: RequestType.post,
        url: url,
        params: params,
        errMsg: errMsg,
        showDialog: showDialog,
        dialogMessage: dialogMessage,
        successMessage: successMessage,
        closeDialogDelay: closeDilogDelay,);
  }

  static Future put(
      {String url,
      Object params,
      String errMsg,
      bool showDialog = true,
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
        params: params,
        errMsg: errMsg,
        showDialog: showDialog,
        dialogMessage: dialogMessage);
  }

  static Future delete(
      {String url,
      Object params,
      String errMsg,
      bool showDialog = true,
      String dialogMessage}) async {
    return await _request(
        requestType: RequestType.delete,
        url: url,
        params: params,
        errMsg: errMsg,
        showDialog: showDialog,
        dialogMessage: dialogMessage);
  }

  static Future _request(
      {String url,
      @required RequestType requestType,
      Object params,
      String errMsg,
      bool showDialog,
      String dialogMessage,
      String successMessage,
      int closeDialogDelay,
      bool returnAll = false,
      Map header,
      CancelToken cancelToken,
      bool enableCache = false}) async {
    ProgressDialog dialog;
    Response response;
    if (showDialog != null && showDialog == true) {
      dialog = await DialogUtils.showProgressDialog(dialogMessage ?? '处理中...');
    }
    var dio = enableCache ? getDioWithCache() : getDio();
    if (header != null && header.isNotEmpty) {
      dio.options.headers = header;
    }
    try {
      switch (requestType) {
        case RequestType.get:
          Map<String,dynamic> queryParams;
          if (params != null )
            queryParams =  Map.from(params);
          response = await dio.get(url, queryParameters: queryParams,cancelToken: cancelToken,options: enableCache ? buildCacheOptions(Duration(days: 1)) : null);
          break;
        case RequestType.post:
          response = await dio.post(url, data: params,cancelToken: cancelToken);
          break;
        case RequestType.put:
          response = await dio.put(url, data: params,cancelToken: cancelToken);
          break;
        case RequestType.delete:
          response = await dio.delete(url, data: params,cancelToken: cancelToken);
          break;
        case RequestType.patch:
          response = await dio.patch(url, data: params,cancelToken: cancelToken);
          break;
      }
      if (closeDialogDelay != 0)
        dialog?.update(
            customBody: LoadingDialog(
          text: successMessage ?? '已完成',
          finished: true,
        ));
    } catch (e) {
      if (e is DioError) {
        dialog?.hide();
        if (e.response != null && e.response.statusCode == 401) {
          if (!RuntimeConfig.dialogOpened) {
            DialogUtils.showSimpleAlertDialog(
                    context: navGK.currentState.overlay.context,
                    text: '你的登录信息已失效，你可以退出重新登录',
                    onlyInfo: true)
                .then((val) {
              RuntimeConfig.dialogOpened = false;
            });
            RuntimeConfig.dialogOpened = true;
          }
        }
        RuntimeConfig.error = e;
      }
      return null;

    }

    if (closeDialogDelay == 0) {
      await dialog?.hide();
    } else {
      await Future.delayed(Duration(milliseconds: closeDialogDelay ?? 100), () {
        dialog?.hide();
      });
    }
    return returnAll ? response: response.data;
  }

  static void showTotast(String errorMsg) {
    Fluttertoast.showToast(
        msg: errorMsg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Theme.of(navGK.currentContext).primaryColor,
        fontSize: 16.0);
    throw (errorMsg);
  }

  static getDioWithCache() {
    if (dioClientWithCache != null) {
      return dioClientWithCache;
    }
    Dio dio = Dio();
    LoginedUser user = new LoginedUser();
    String userHeader = user.getToken();
    String urlHost = user.getHost();

    if (userHeader != null || urlHost != null) {
      dio.options.headers = {'Authorization': userHeader};
      dio.options.baseUrl = urlHost;
    }

    dio.interceptors.add(DioCacheManager(CacheConfig(baseUrl: urlHost)).interceptor);

    if (!kReleaseMode) {
      dio.interceptors
          .add(InterceptorsWrapper(onRequest: (RequestOptions options) {
        debugPrint(options.uri.toString());
        return options; //continue
      }, onResponse: (Response response) {
        debugPrint('收到了json信息');
        // print(response);
        return response; // continue
      }, onError: (DioError e) {
        // 当请求失败时做一些预处理
        return e; //continue
      }));
    }
    dioClientWithCache = dio;
    return dioClientWithCache;

  }

  static Dio getDio() {
    if (dioClient != null) {
      return dioClient;
    }

    Dio dio = Dio();
    LoginedUser user = new LoginedUser();
    String userHeader = user.getToken();
    String urlHost = user.getHost();

    if (userHeader != null || urlHost != null) {
      dio.options.headers = {'Authorization': userHeader};
      dio.options.baseUrl = urlHost;
    }

    // dio拦截器
    if (!kReleaseMode) {
      dio.interceptors
          .add(InterceptorsWrapper(onRequest: (RequestOptions options) {
        debugPrint(options.uri.toString());
        return options; //continue
      }, onResponse: (Response response) {
        debugPrint('收到了json信息');
        // print(response);
        return response; // continue
      }, onError: (DioError e) {
        // 当请求失败时做一些预处理
        return e; //continue
      }));
    }
    dioClient = dio;

    return dioClient;
  }

  static closeDioClient() {
    dioClient?.close(force: true);
    dioClientWithCache?.close(force: true);
    dioClient = null;
    dioClientWithCache = null;
  }

  static String buildGetUrl(String url, Map params) {
    if (params != null && params.isNotEmpty) {
      StringBuffer sb = new StringBuffer("?");
      params.forEach((key, value) {
        if (value is List) {
          for (var v in value) {
            sb.write("$key[]" + "=" + "$v" + "&");
          }
        } else {
          sb.write("$key" + "=" + "$value" + "&");
        }
      });
      String paramStr = sb.toString();
      paramStr = paramStr.substring(0, paramStr.length - 1);
      url += paramStr;
      return url;
    }
    return url;
  }
}
