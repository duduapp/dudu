
import 'package:fastodon/constant/api.dart';
import 'package:fastodon/utils/request.dart';

enum SearchType{
  accounts,
  hashtags,
  statuses
}

class SearchApi {
  static searchStatuses({int maxId}) {
    return _search(SearchType.statuses,maxId: maxId);
  }

  static searchAccounts({int maxId}) {
    return _search(SearchType.accounts,maxId: maxId);
  }

  static searchHashtags({int maxId}) {
    return _search(SearchType.hashtags,maxId: maxId);
  }

  static _search(SearchType type, {int maxId}) {
    Map params = {
      'type':SearchType.statuses.toString()
    };
    if (maxId != null) {
      params['max_id'] = maxId;
    }
    return Request.get(url:Api.search,params: params);
  }

  static get statusUrl {
    return '${Api.search}/${SearchType.statuses.toString()}';
  }

  static get accountUrl {

  }

  static getUrl(SearchType type,String query) {
    return '${Api.search}/?type=${type.toString().split('.')[1]}&q=$query';
  }
}