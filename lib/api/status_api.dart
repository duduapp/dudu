import 'package:fastodon/public.dart';

class StatusApi {
  static String url = '/api/v1/statuses';

  static reblog(String statusId) {
    var api = url+'/'+statusId+'/reblog';
    Request.post(url: api,showDialog: false);
  }

  static unReblog(String statusId) {
    var api = url+'/'+statusId+'/unreblog';
    Request.post(url: api,showDialog: false);
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

  static getContext(String statusId) async{
    var api = '$url/$statusId/context';
    return await Request.get2(url: api);
  }

  static remove(String statusId) async{
    var api = '$url/$statusId';
    return await Request.delete(url: api,showDialog: false);
  }
}