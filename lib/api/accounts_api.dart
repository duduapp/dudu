import 'package:dio/dio.dart';
import 'package:fastodon/constant/api.dart';
import 'package:fastodon/utils/request.dart';

class AccountsApi {
  static const String url = '/api/v1/accounts';

  static mute(String id) {
    var api = '$url/$id/mute';
    Request.post(url: api,errMsg: '隐藏用户$id失败');
  }

  static unMute(String id) {
    var api = '$url/$id/unmute';
    Request.post(url: api,errMsg: '取消隐藏用户$id失败');
  }

  static block(String id) {
    var api = '$url/$id/block';
    Request.post(url: api,errMsg: '屏蔽用户$id失败');
  }

  static unBlock(String id) {
    var api = '$url/$id/unblock';
    Request.post(url: api,errMsg: '取消屏蔽用户$id失败');
  }

  static updateCredentials(Map<String,dynamic> params) async{
      var api = '$url/update_credentials';
//      var params = {
//        'display_name':displayName,
//        'note': note,
//        'avatar': MultipartFile.fromFileSync(avatar),
//        'header':MultipartFile.fromFileSync(header),
//        'fields_attributes': fieldsAttributes
//      };
      await Request.patch(url:api,params: FormData.fromMap(params));
  }
}