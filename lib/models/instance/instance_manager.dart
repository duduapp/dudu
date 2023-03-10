import 'package:dudu/l10n/l10n.dart';
import 'dart:convert';

import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:dudu/api/accounts_api.dart';
import 'package:dudu/api/instance_api.dart';
import 'package:dudu/constant/api.dart';
import 'package:dudu/constant/app_config.dart';
import 'package:dudu/db/tb_cache.dart';
import 'package:dudu/db/tb_instance.dart';
import 'package:dudu/models/http/cache_response.dart';
import 'package:dudu/models/instance/server_instance.dart';
import 'package:dudu/models/json_serializable/instance_item.dart';
import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/models/local_account.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/models/task/check_role_task.dart';
import 'package:dudu/pages/home_page.dart';
import 'package:dudu/pages/login/model/app_credential.dart';
import 'package:dudu/pages/login/model/token.dart';
import 'package:dudu/pages/webview/inner_browser.dart';
import 'package:dudu/utils/account_util.dart';
import 'package:dudu/utils/app_navigate.dart';
import 'package:dudu/utils/dialog_util.dart';
import 'package:dudu/utils/request.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nav_router/nav_router.dart';

import '../logined_user.dart';

class InstanceManager {
  static List<ServerInstance> instances;

  static Future<List<ServerInstance>> getList() async {
    if (instances != null) return instances;
    instances = [];
    var list = [];
    var resCache = await Request.cacheGet(url: AppConfig.instancesUrl);
    if (resCache.content != null) {
      List<String> ins = resCache.content.split('\n');
      ins.forEach((element) => element.trim());
      ins.removeWhere((element) => element.isEmpty);
      list.addAll(ins);
    }
    for (var item in list) {
      var detail = await getInstanceDetail(item, true);
      if (detail != null && detail.url != null) instances.add(detail);
    }

    list.clear();
    list.addAll(await TbInstanceHelper.getInstanceList());
    for (var item in list) {
      var detail = await getInstanceDetail(item, false);
      if (detail != null) instances.add(detail);
    }

    return instances ?? [];
  }

  static removeAll() {
    instances = null;
  }

  static Future<ServerInstance> getInstanceDetail(
      String url, bool fromServer) async {
    if (url.startsWith('help.dudu.today')) {}
    var cache = await Request.cacheGet(
        url: InstanceApi.getUrl(url),
        headers: url.startsWith('help.dudu.today')
            ? {
                'Authorization':
                    'Bearer s5Ey1Iw7VDipInrx-g8cyobMK3WDQN1NOVaGwmnmK4A'
              }
            : null);
    if (cache.content != null) {
      var item;
      try {
        item = InstanceItem.fromJson(json.decode(cache.content));
      } catch (e) {
        return null;
      }
      if (item.uri == null) return null;
      return ServerInstance(
          url: url,
          detail: item,
          fromServer: fromServer,
          fromStale: cache.type == CacheResponseType.stale);
    }
    return null;
  }

  static bool instanceExist(String url) {
    url = url.replaceFirst('https://', '');
    for (var i in instances) {
      if (i.url == url) {
        return true;
      }
    }
    return false;
  }

  static addInstance(InstanceItem instance) {
    if (instanceExist(instance.uri)) return;
    TbInstanceHelper.addInstance(instance.uri);
    Request.cacheGet(url: InstanceApi.getUrl(instance.uri));
    instances.add(ServerInstance(
        url: instance.uri,
        detail: instance,
        fromServer: false,
        fromStale: false));
  }

  static removeInstance(InstanceItem instance) {
    TbInstanceHelper.removeInstance(instance.uri);
    instances.removeWhere((element) => element.url == instance.uri);
  }

  static login(InstanceItem instance) async {
    var hostUrl = 'https://' + instance.uri;

    var pd = await DialogUtils.showProgressDialog('');
    Map paramsMap = Map();
    paramsMap['client_name'] = AppConfig.ClientName;
    paramsMap['redirect_uris'] = AppConfig.RedirectUris;
    paramsMap['scopes'] = AppConfig.Scopes;
    paramsMap['website'] = AppConfig.website;

    var response;

    try {
      response = await http
          .post(hostUrl + Api.Apps, body: paramsMap)
          .timeout(Duration(seconds: 10));
      pd.hide();
    } catch (e) {
      pd.hide();
      DialogUtils.showInfoDialog(
          navGK.currentState.overlay.context, S.of(navGK.currentState.overlay.context).unable_to_connect_to_server);
      return;
    } finally {
      pd.hide();
    }

    AppCredential model = AppCredential.fromJson(json.decode(response.body));
      if (model.clientId == null) {
      DialogUtils.toastErrorInfo(S.of(navGK.currentState.overlay.context).an_error_occurred);
      return;
    }

    final result = await AppNavigate.push(
      InnerBrowser(
        hostUrl,
        appCredential: model,
      ),
    );

    if (result == null) {
      pd.hide();
      return;
    }

    pd.show();

    paramsMap = Map();
    paramsMap['client_id'] = model.clientId;
    paramsMap['client_secret'] = model.clientSecret;
    paramsMap['grant_type'] = 'authorization_code';
    paramsMap['code'] = result;
    paramsMap['redirect_uri'] = model.redirectUri;
    try {
      var data = await http
          .post('$hostUrl' + Api.Token, body: paramsMap)
          .timeout(Duration(seconds: 10));
      Token getToken = Token.fromJson(json.decode(data.body));
      String token = '${getToken.tokenType} ${getToken.accessToken}';

      Request.closeHttpClient();

      LoginedUser user = new LoginedUser();
      user.token = token;
      user.host = hostUrl;
      OwnerAccount account = await AccountsApi.getMyAccount();
      if (account == null) {
        DialogUtils.toastErrorInfo(S.of(navGK.currentState.overlay.context).something_went_wrong);
      }
      var localA = LocalStorageAccount.getLocalAccount(account);
      if (localA != null) {
        SettingsProvider().setHomeTabIndex(1);
        SettingsProvider().setPublicTabIndex(0);
        AccountUtil.switchToAccount(localA);
        return;
      }

      LocalAccount localAccount = LocalAccount(
          hostUrl: hostUrl, token: token, active: true, account: account);
      await LocalStorageAccount.addLocalAccount(localAccount);

      user = new LoginedUser();
      user.loadFromLocalAccount(localAccount);

      await SettingsProvider().load(); // load new settings
      SettingsProvider().setHomeTabIndex(1);
      SettingsProvider().setPublicTabIndex(0);

      AccountUtil.cacheEmoji();
      AccountUtil.requestPreference();
      CheckRoleTask.checkRole();
      removeAll();

      pd.hide();
      pushAndRemoveUntil(HomePage());

      // eventBus.emit(EventBusKey.HidePresentWidegt);

    } catch (e) {
      pd.hide();
      print(e);
      debugPrint(e.toString());
      DialogUtils.toastErrorInfo(S.of(navGK.currentState.overlay.context).something_went_wrong);
    } finally {
      pd.hide();
    }
  }
}
