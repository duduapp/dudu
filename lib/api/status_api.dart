
import 'package:dio/dio.dart';
import 'package:dudu/api/accounts_api.dart';
import 'package:dudu/models/json_serializable/article_item.dart';
import 'package:dudu/public.dart';

class StatusApi {
  static String url = '/api/v1/statuses';

  static reblog(String statusId) {
    var api = url+'/'+statusId+'/reblog';
    Request.post(url: api,showDialog: false);
  }

  static unReblog(String statusId) async{
    var api = url+'/'+statusId+'/unreblog';
    return await Request.post(url: api,showDialog: false);
  }

  static favourite(String statusId) {
    var api = url+'/'+statusId+'/favourite';
    Request.post(url: api,showDialog: false);
  }

  static unfavourite(String statusId) {
    var api = url+'/'+statusId+'/unfavourite';
    Request.post(url: api,showDialog: false);
  }

  static bookmark(String statusId) async{
    var api = url+'/'+statusId+'/bookmark';
    return await Request.post(url: api,showDialog: false);
  }

  static unBookmark(String statusId) async{
    var api = url+'/'+statusId+'/unbookmark';
    return await Request.post(url: api,showDialog: false);
  }

  static muteConversation(String statusId) async{
    var api = '$url/$statusId/mute';
    return await Request.post(url: api,showDialog: false);
  }

  static numuteConversation(String statusId) async {
    var api = '$url/$statusId/unmute';
    return await Request.post(url: api,showDialog: false);
  }

  static getContext(StatusItemData data,bool requestOriginal,{CancelToken cancelToken}) async{
    var prefix = '';
    if (requestOriginal)
      prefix = statusHost(data);
    var api = '$prefix$url/${data.id}/context';
    return await Request.get(url: api,cancelToken: cancelToken);
  }
  
  static String statusPrefix(StatusItemData data,bool requestOriginal) {
    return requestOriginal ? statusHost(data) : '';
  }
  
  static String reblogByUrl(StatusItemData data, bool requestOriginal) {
    return statusPrefix(data, requestOriginal) + '/$url/${data.id}/reblogged_by';
  }

  static String favouritedByUrl(StatusItemData data,bool requestOriginal) {
    return statusPrefix(data, requestOriginal) + '/$url/${data.id}/favourited_by';
  }

  static String statusHost(StatusItemData data) {
    return data.url.substring(0,data.url.indexOf('/@'));
  }

  static remove(String statusId) async{
    var api = '$url/$statusId';
    return await Request.delete(url: api,showDialog: false);
  }
}