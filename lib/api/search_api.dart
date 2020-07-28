import 'dart:convert';

import 'package:fastodon/constant/api.dart';
import 'package:fastodon/public.dart';
import 'package:fastodon/utils/request.dart';

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
    return await Request.get2(url: accountSearchUrl, params: params);
  }

  static searchHashtags(String q, {int maxId}) {
    return _search(q, SearchType.hashtags, maxId: maxId);
  }

  static _search(String q, SearchType type, {int maxId, bool following}) async {
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
    return await Request.get2(url: Api.search, params: params);
  }

  static get statusUrl {
    return '${Api.search}/${SearchType.statuses.toString()}';
  }

  static get accountUrl {}

  static getUrl(SearchType type, String query) {
    return '${Api.search}/?type=${type.toString().split('.')[1]}&q=$query';
  }

  static searchEmoji(String query) async {
    List emojiList = json.decode(
        await Storage.getStringWithAccount('cache_data' + Api.CustomEmojis));
    List res = [];
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
