import 'dart:convert';

import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:dudu/constant/api.dart';
import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/public.dart';
import 'package:dudu/utils/request.dart';
import 'package:dudu/widget/status/status_item.dart';

enum SearchType { accounts, hashtags, statuses }

class SearchApi {
  static const String accountSearchUrl = '/api/v1/accounts/search';

  static searchStatuses(String q, {int maxId}) {
    return _search(q, SearchType.statuses, maxId: maxId);
  }

  static searchAccounts(String q, {int maxId, bool following}) async {
    Map params = {
      'q': q,
    };
    if (maxId != null) {
      params['max_id'] = maxId;
    }
    if (following != null) {
      params['following'] = following;
    }
    return await Request.get(url: accountSearchUrl, params: params);
  }

  static searchHashtags(String q, {int maxId}) {
    return _search(q, SearchType.hashtags, maxId: maxId);
  }

  static Future _search(String q, SearchType type,
      {int maxId,
      bool following,
      bool resolve,
      bool showDialog = false,
      String handlingMessage,
      successMessage,
      int closeDialogDelay}) async {
    Map params = {
      'type': type.toString().split('.')[1],
      'q': q,
    };
    if (maxId != null) {
      params['max_id'] = maxId;
    }
    if (following != null) {
      params['following'] = following;
    }
    if (resolve != null) {
      params['resolve'] = resolve;
    }
    return await Request.get(
        url: Api.search,
        params: params,
        showDialog: showDialog,
        handlingMessage: handlingMessage,
        successMessage: successMessage,
        closeDialogDelay: closeDialogDelay);
  }

  static Future resolveStatus(String url) async{
    return await _resolve(url,SearchType.statuses);
  }

  static Future resolveAccount(String url) async {
    return await _resolve(url,SearchType.accounts);
  }

  static Future _resolve(String url,[SearchType type = SearchType.statuses]) async {
    Map res = await _search(url, type,
        resolve: true,
        showDialog: true,
        handlingMessage: '',
        successMessage: '',
        closeDialogDelay: 0);
    if (res != null) {
      if (type == SearchType.statuses) {
        if (res.containsKey('statuses') &&
            res['statuses'] is List &&
            res['statuses'].isNotEmpty)
          return StatusItemData.fromJson(res['statuses'][0]);
      } else if (type == SearchType.accounts) {
        if (res.containsKey('accounts') &&
            res['accounts'] is List &&
            res['accounts'].isNotEmpty)
          return OwnerAccount.fromJson(res['accounts'][0]);
      }
    }
    return null;
  }


  static get statusUrl {
    return '${Api.search}/${SearchType.statuses.toString()}';
  }

  static get accountUrl {}

  static getUrl(SearchType type, String query) {
    return '${Api.search}/?type=${type.toString().split('.')[1]}&q=$query';
  }

  static searchEmoji(String query) async {
    List res = [];
    var emojiList = await Request.get(url: Api.CustomEmojis, enableCache: true);

    if (emojiList != null && emojiList.isNotEmpty) {
      for (var emoji in emojiList) {
        if ((emoji['shortcode'] as String).startsWith(query)) {
          res.add(emoji);
          if (res.length >= 20) {
            return res;
          }
        }
      }
      return res;
    }
  }
}
