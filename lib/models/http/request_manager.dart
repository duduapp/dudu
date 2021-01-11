import 'package:dudu/api/accounts_api.dart';
import 'package:dudu/api/timeline_api.dart';
import 'package:dudu/db/db_constant.dart';
import 'package:dudu/db/tb_cache.dart';
import 'package:dudu/models/http/http_response.dart';
import 'package:dudu/models/logined_user.dart';
import 'package:dudu/models/provider/settings_provider.dart';
import 'package:dudu/utils/request.dart';
import 'package:flutter/foundation.dart';

class RequestManager {


  static getTimeline(String url,bool enableCache) async{
    var provider = SettingsProvider();
    HttpResponse response = await Request.get(
        url: url,
        returnAll: true,
        enableCache: enableCache);
    if (response == null || response.body == null) return null;
    url = url.replaceFirst('?limit=1', '').replaceFirst('&limit=1', '');
    if (provider.unread.containsKey(url)) {
      _updateUnread(provider, url, 0);
      if (response.body.isNotEmpty && response.body is List) {
        var latestId;
        if (url == TimelineApi.conversations) {
          latestId = response.body[0]['last_status']['id'];
        } else if (url == TimelineApi.mention) {
          latestId = response.body[0]['status']['id'];
        } else {
          latestId = response.body[0]['id'];
        }
        _updateLatestId(provider, url, latestId);
      }
    }
    if (url == TimelineApi.notification) {
      _updateUnread(provider, TimelineApi.conversations, 0);
      _updateUnread(provider, TimelineApi.followRquest, 0);
      _updateUnread(provider, TimelineApi.follow, 0);
      _updateUnread(provider, TimelineApi.mention, 0);
      _updateUnread(provider, TimelineApi.reblogNotification, 0);
      _updateUnread(provider, TimelineApi.favoriteNotification, 0);
      _updateUnread(provider, TimelineApi.pollNotification, 0);
    }
    return response;
  }

  static _requestedStatusDetail(String statusId) {
    var provider = SettingsProvider();
    provider.latestIds.forEach((key, value) {
      if (key != TimelineApi.notification && value == statusId) {
        _updateUnread(provider, key, 0);
      }
    });
  }

  static _updateLatestId(SettingsProvider provider,String url,String id) {
    provider.latestIds[url] = id;
    TbCacheHelper.setCache(TbCache(account: LoginedUser().fullAddress,tag: DbConstant.latestIdPrefix+url,content: id));
  }

  static _updateUnread(SettingsProvider provider,String url,int count) {
    SettingsProvider().updateUnread(url, count);
    TbCacheHelper.setCache(TbCache(account: LoginedUser().fullAddress,tag: url,content: count.toString()));
  }


  static checkNewRecords() {
    var provider = SettingsProvider();
    provider.unread.forEach((key, value) async{
      if (value == 0) {
        try {
          HttpResponse response = await Request.get(
              url: key.contains('?') ? key+'&limit=1' : key+'?limit=1',
              returnAll: true);
          if (response.body.isNotEmpty && response.body is List) {
            var newLatestId = response.body[0]['id'];
            if (key == TimelineApi.conversations) {
              newLatestId = response.body[0]['last_status']['id'];
            } else if (key == TimelineApi.mention) {
              newLatestId = response.body[0]['status']['id'];
            }
            if (provider.latestIds.containsKey(key)) {
              if (int.parse(newLatestId) > int.parse(provider.latestIds[key])) {
                _updateUnread(provider, key, 1);
              }
            }
            _updateLatestId(provider, key, newLatestId);
          }

        } catch (e) {
          debugPrint(e.toString());
        }
      }
    });
  }
}