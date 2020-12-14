import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:dudu/db/tb_cache.dart';
import 'package:dudu/models/http/cache_response.dart';
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

import 'compute_util.dart';

enum RequestType { get, post, put, delete, patch }

class Request {
  static Dio dioClient;
  static Dio dioCacheClientWithBaseUrl;
  static Dio dioCacheClient;
  static HttpClient httpClient;

  static const int requestTimeout = 20;

  static Future<CacheResponse> cacheGet(
      {String url, Duration duration = const Duration(days: 1),Map<String,String> headers}) async {
    // var res =  await Request.get(url: url,enableCache: true,decodeJson:false,cacheOption: buildCacheOptions(duration,maxStale: Duration(days: 7)));
    // return CacheResponse(res, CacheResponseType.cache,);
    var cache = await TbCacheHelper.getCache('', url);
    if (cache == null) {
      HttpResponse res = await Request.get(url: url, decodeJson: false,header:headers,showDialog: false,returnAll: true);
      if (res == null || res.statusCode != 200) return CacheResponse(null, CacheResponseType.stale);
      TbCacheHelper.setCache(TbCache(account: '', tag: url, content: res.body));
      return CacheResponse(res.body, CacheResponseType.net);
    } else {
      if (DateTime.now().difference(cache.time).compareTo(duration) <= 0) {
        return CacheResponse(cache.content, CacheResponseType.cache);
      } else {
        HttpResponse res = await Request.get(url: url, decodeJson: false,header:headers,showDialog: false,returnAll: true);
        if (res == null || res.statusCode != 200) return CacheResponse(null, CacheResponseType.stale);
        TbCacheHelper.setCache(TbCache(account: '', tag: url, content: res.body));
        return CacheResponse(res.body, CacheResponseType.net);
      }
    }
  }

  static Future get(
      {String url,
      Map params,
      bool showDialog = false,
      bool returnAll = false,
      Map header,
      CancelToken cancelToken,
      HttpClient httpClient,
      bool enableCache = false,
      Options cacheOption,
      bool withToken = true,
      String handlingMessage,
      String successMessage,
      int closeDialogDelay,
      bool decodeJson = true}) async {
    return await _request(
        requestType: RequestType.get,
        url: url,
        params: params,
        showDialog: showDialog,
        returnAll: returnAll,
        header: header,
        cancelToken: cancelToken,
        enableCache: enableCache,
        cacheOptions: cacheOption,
        handlingMessage: handlingMessage,
        successMessage: successMessage,
        withToken: withToken,
        closeDialogDelay: closeDialogDelay,
        decodeJson: decodeJson);
  }

  static Future post(
      {String url,
      Object params,
      String errMsg,
      bool showDialog = true,
      String dialogMessage,
      String successMessage,
      bool returnAll = false,
      int closeDilogDelay,
      Map header}) async {
    return await _request(
        requestType: RequestType.post,
        url: url,
        params: params,
        errMsg: errMsg,
        showDialog: showDialog,
        handlingMessage: dialogMessage,
        successMessage: successMessage,
        closeDialogDelay: closeDilogDelay,
        returnAll: returnAll,
        header: header);
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
        handlingMessage: dialogMessage);
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
        handlingMessage: dialogMessage);
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
        handlingMessage: dialogMessage);
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

  static requestDio(
      {String url, dynamic params, RequestType type = RequestType.post}) async {
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
      String handlingMessage,
      String successMessage,
      int closeDialogDelay,
      bool returnAll = false,
      Map header,
      CancelToken cancelToken,
      bool enableCache = false,
      Options cacheOptions,
      bool withToken = true,
      bool decodeJson = true}) async {
    //some request do not need token
    ProgressDialog dialog;
    http.Response response;
    HttpClient client = getGetClient();
    debugPrint(url);
    if (showDialog != null && showDialog == true) {
      dialog =
          await DialogUtils.showProgressDialog(handlingMessage ?? '处理中...');
    }
    if (header != null && header.isNotEmpty) {}
    try {
      switch (requestType) {
        case RequestType.get:
          if (enableCache) {
            var response;
            if (withToken)
              response = await getDioCacheWithBaseUrl().get(url,
                  queryParameters: params,
                  cancelToken: cancelToken,
                  options:
                      cacheOptions ?? buildCacheOptions(Duration(days: 7)));
            else
              response = await getDioCache().get(url,
                  queryParameters: params,
                  cancelToken: cancelToken,
                  options:
                      cacheOptions ?? buildCacheOptions(Duration(days: 7)));
            if (returnAll) {
              dialog?.hide();
              return HttpResponse(
                  response.data, response.headers.map, response.statusCode);
            } else {
              dialog?.hide();
              return response.data;
            }
          }
          if (withToken && !url.startsWith('http'))
            response = await client
                .get(
                  buildGetUrl(_realUrl(url), params),
                )
                .timeout(Duration(seconds: requestTimeout));
          else
            response = await http
                .get(
                  buildGetUrl(_realUrl(url), params,), headers: header
                )
                .timeout(Duration(seconds: requestTimeout));

          //
          break;
        case RequestType.post:
          //response = await dio.post(url, data: params,cancelToken: cancelToken);
          if (withToken && !url.startsWith('http'))
            response = await getGetClient()
                .post(_realUrl(url),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode(params))
                .timeout(Duration(seconds: requestTimeout));
          else
            response = await http
                .post(url, body: params,headers: header as Map<String,String>)
                .timeout(Duration(seconds: requestTimeout));
          break;
        case RequestType.put:
          response = await client
              .put(_realUrl(url), body: params)
              .timeout(Duration(seconds: requestTimeout));
          break;
        case RequestType.delete:
          response = await client
              .delete(buildGetUrl(_realUrl(url), params))
              .timeout(Duration(seconds: requestTimeout));
          break;
        case RequestType.patch:
          response = await client
              .patch(url, body: params)
              .timeout(Duration(seconds: requestTimeout));
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
      return HttpResponse((decodeJson == null || decodeJson) ? await compute(parseJsonString, response.body) : response.body,
          response.headers, response.statusCode);
    }
    if (response.statusCode == 401) {
      // if (!RuntimeConfig.dialogOpened) {
      //   DialogUtils.showSimpleAlertDialog(
      //           context: navGK.currentState.overlay.context,
      //           text: '你的登录信息已失效，你可以退出重新登录',
      //           onlyInfo: true)
      //       .then((val) {
      //     RuntimeConfig.dialogOpened = false;
      //   });
      //   RuntimeConfig.dialogOpened = true;
      // }
    }
    // debugPrint(response.body);

    return (decodeJson == null || decodeJson)
        ? json.decode(response.body)
        : response.body;
  }

  static _realUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
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

  static Dio getDioCacheWithBaseUrl() {
    if (dioCacheClientWithBaseUrl != null) {
      return dioCacheClientWithBaseUrl;
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
    dioCacheClientWithBaseUrl = dio;
    return dioCacheClientWithBaseUrl;
  }

  static Dio getDioCache() {
    if (dioCacheClient != null) {
      return dioCacheClient;
    }
    Dio dio = Dio();

    dio.httpClientAdapter = DefaultHttpClientAdapter();

    dio.interceptors.add(DioCacheManager(CacheConfig()).interceptor);

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
    dioCacheClient = dio;
    return dioCacheClient;
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
    dioCacheClientWithBaseUrl?.close(force: true);
    dioCacheClient?.close(force: true);
    httpClient?.close();

    dioClient = null;
    httpClient = null;
    dioCacheClientWithBaseUrl = null;
    dioCacheClient = null;
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
