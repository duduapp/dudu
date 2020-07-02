import 'package:dio/dio.dart';
import 'package:fastodon/constant/api.dart';
import 'package:fastodon/models/owner_account.dart';
import 'package:fastodon/utils/request.dart';

class AccountsApi {
  static const String url = '/api/v1/accounts';
  static const String muteUrl= '/api/v1/mutes';
  static const String blockUrl = '/api/v1/blocks';
  static const String blockDomainUrl = '/api/v1/domain_blocks';
  static const String preferencesUrl = '/api/v1/preferences';

  static Future<OwnerAccount> getAccount() async{
    var data = await Request.get(url: url+'/verify_credentials');
    return OwnerAccount.fromJson(data);
  }

  static getPreferences() async {
    return await Request.get(url: preferencesUrl);
  }

  static mute(String id) {
    var api = '$url/$id/mute';
    Request.post(url: api,errMsg: '隐藏用户$id失败');
  }

  static unMute(String id) async{
    var api = '$url/$id/unmute';
    await Request.post(url: api,errMsg: '取消隐藏用户$id失败');
  }


  static block(String id) {
    var api = '$url/$id/block';
    Request.post(url: api,errMsg: '屏蔽用户$id失败');
  }

  static unBlock(String id) async{
    var api = '$url/$id/unblock';
    await Request.post(url: api,errMsg: '取消屏蔽用户$id失败');
  }

  static unBlockDomain(String domain) async {
    var params = {
      'domain' : domain
    };
    await Request.delete(url: blockDomainUrl,params: params);
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