import 'package:fastodon/constant/api.dart';
import 'package:fastodon/public.dart';

class StatusApi {
  static reblog(String statusId) {
    var api = Api.status+'/'+statusId+'/reblog';
    Request.post(url: api);
  }

  static unReblog(String statusId) {
    var api = Api.status+'/'+statusId+'/unreblog';
    Request.post(url: api);
  }

  static bookmark(String statusId) {
    var api = Api.status+'/'+statusId+'/bookmark';
    Request.post(url: api);
  }

  static unBookmark(String statusId) {
    var api = Api.status+'/'+statusId+'/unbookmark';
    Request.post(url: api);
  }

  static getContext(String statusId) async{
    var api = '${Api.status}/$statusId/context';
    return await Request.get(url: api);
  }
}