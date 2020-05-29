import 'package:fastodon/constant/api.dart';
import 'package:fastodon/untils/request.dart';

class AccountsApi {
  static mute(String id) {
    var api = '${Api.accounts}/$id/mute';
    Request.post(url: api,errMsg: '隐藏用户$id失败');
  }

  static unMute(String id) {
    var api = '${Api.accounts}/$id/unmute';
    Request.post(url: api,errMsg: '取消隐藏用户$id失败');
  }

  static block(String id) {
    var api = '${Api.accounts}/$id/block';
    Request.post(url: api,errMsg: '屏蔽用户$id失败');
  }

  static unBlock(String id) {
    var api = '${Api.accounts}/$id/unblock';
    Request.post(url: api,errMsg: '取消屏蔽用户$id失败');
  }
}