import 'package:fastodon/constant/api.dart';
import 'package:fastodon/public.dart';

class StatusApi {
  static reblog(String statusId) {
    var api = Api.PushNewTooT+'/'+statusId+'/reblog';
    Request.post(url: api);
  }

  static unReblog(String statusId) {
    var api = Api.PushNewTooT+'/'+statusId+'/unreblog';
    Request.post(url: api);
  }

  static bookmark(String statusId) {
    var api = Api.PushNewTooT+'/'+statusId+'/bookmark';
    Request.post(url: api);
  }

  static unBookmark(String statusId) {
    var api = Api.PushNewTooT+'/'+statusId+'/unbookmark';
    Request.post(url: api);
  }
}