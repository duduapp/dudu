import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:dudu/models/http/http_client.dart';
import 'package:dudu/models/http/http_response.dart';
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
import 'package:http/http.dart' as http;

enum RequestType { get, post, put, delete, patch }

class Request {
  static Dio dioClient;
  static Dio dioClientWithCache;
  static HttpClient httpClient;

  static Future get(
      {String url,
      Map params,
      bool showDialog = false,
      bool returnAll = false,
      Map header,
      CancelToken cancelToken,
      bool enableCache = false}) async {
    return await _request(
        requestType: RequestType.get,
        url: url,
        params: params,
        showDialog: showDialog,
        returnAll: returnAll,
        header: header,
        cancelToken: cancelToken,
        enableCache: enableCache);
  }

  static Future post(
      {String url,
      Object params,
      String errMsg,
      bool showDialog = true,
      String dialogMessage,
      String successMessage,
        bool returnAll = false,
      int closeDilogDelay}) async {
    return await _request(
      requestType: RequestType.post,
      url: url,
      params: params,
      errMsg: errMsg,
      showDialog: showDialog,
      dialogMessage: dialogMessage,
      successMessage: successMessage,
      closeDialogDelay: closeDilogDelay,
      returnAll: returnAll
    );
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

  static uploadFile({String url, File file}) async {
    final http.MultipartRequest request =
        http.MultipartRequest('POST', Uri.parse(_realUrl(url)));
    request.headers['Authorization'] = LoginedUser().getToken();
    final http.MultipartFile multipartFile =
        await http.MultipartFile.fromPath('image', file.path);
    request.files.add(multipartFile);
    final http.StreamedResponse response = await request.send();
    final String res = await response.stream.transform(utf8.decoder).join();
    return json.decode(res);
  }

  static requestDio({String url,dynamic params,RequestType type = RequestType.post}) async{
    var response;
    switch (type) {
      case RequestType.post:
        response = await getDio().post(url, data: params);
        break;
      case RequestType.patch:
        response = await getDio().patch(url, data: params);
        break;
    }

    return response.data;
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
    http.Response response;
    HttpClient client = getGetClient();
    debugPrint(url);
    if (showDialog != null && showDialog == true) {
      dialog = await DialogUtils.showProgressDialog(dialogMessage ?? '处理中...');
    }
    if (header != null && header.isNotEmpty) {

    }
    try {
      switch (requestType) {
        case RequestType.get:
          if (enableCache) {
            var response = await getDioWithCache().get(url, queryParameters: params,cancelToken: cancelToken,options: enableCache ? buildCacheOptions(Duration(days: 1)) : null);
            if (returnAll) {
              dialog?.hide();
              return HttpResponse(response.data,response.headers.map,response.statusCode);
            } else {
              dialog?.hide();
              return response.data;
            }
          }
          response = await client.get(
            buildGetUrl(_realUrl(url), params),
          ).timeout(Duration(seconds: 10));

          //
          break;
        case RequestType.post:
          //response = await dio.post(url, data: params,cancelToken: cancelToken);
          response = await getGetClient().post(_realUrl(url),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(params)).timeout(Duration(seconds: 10));
          break;
        case RequestType.put:
          response = await client.put(_realUrl(url), body: params);
          break;
        case RequestType.delete:
          response =
              await client.delete(buildGetUrl(_realUrl(url), params));
          break;
        case RequestType.patch:
          response =
              await client.patch(url, body: params);
          break;
      }
      if (closeDialogDelay != 0)
        dialog?.update(
            customBody: LoadingDialog(
          text: successMessage ?? '已完成',
          finished: true,
        ));
    } catch (e) {
      dialog?.hide();
     // DialogUtils.toastErrorInfo('网络请求出错');
      RuntimeConfig.error = e;
      return null;
    }

    if (closeDialogDelay == 0) {
      await dialog?.hide();
    } else {
      await Future.delayed(Duration(milliseconds: closeDialogDelay ?? 100), () {
        dialog?.hide();
      });
    }
    if (returnAll) {
      return HttpResponse(json.decode(response.body), response.headers, response.statusCode);
    }
    if (response.statusCode == 401) {
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
   // debugPrint(response.body);

    return json.decode(response.body);

  }

  static _realUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://'))
      return url;
    return LoginedUser().host + url;
  }

  static void showTotast(String errorMsg) {
    Fluttertoast.showToast(
        msg: errorMsg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Theme.of(navGK.currentContext).primaryColor,
        fontSize: 16.0);
    throw (errorMsg);
  }

  static Dio getDioWithCache() {
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

    dio.httpClientAdapter = DefaultHttpClientAdapter();

    dio.interceptors
        .add(DioCacheManager(CacheConfig(baseUrl: urlHost)).interceptor);

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

  static http.Client getGetClient() {
    if (httpClient == null) {
      httpClient = HttpClient(LoginedUser().token);
    }
    return httpClient;
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

  static closeHttpClient() {
    dioClient?.close(force: true);
    dioClientWithCache?.close(force: true);
    httpClient?.close();

    dioClient = null;
    httpClient = null;
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
