import 'package:dio/dio.dart';
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

  static getContext(String statusId,{CancelToken cancelToken}) async{
    var api = '$url/$statusId/context';
    return await Request.get(url: api,cancelToken: cancelToken);
  }

  static remove(String statusId) async{
    var api = '$url/$statusId';
    return await Request.delete(url: api,showDialog: false);
  }
}