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
  static const String filterUrl = '/api/v1/filters';

  static Future<OwnerAccount> getAccount() async{
    var data = await Request.get(url: url+'/verify_credentials');
    return OwnerAccount.fromJson(data);
  }

  static getPreferences() async {
    return await Request.get(url: preferencesUrl);
  }

  static follow(String id,{bool receiveReblogs = true}) async{
    var api = '$url/$id/follow';
    Map paramsMap = Map();
    paramsMap['reblogs'] = receiveReblogs;
    return await Request.post(url: api,params: paramsMap);
  }

  static unFollow(String id) async {
    var api = '$url/$id/unfollow';
    return await Request.post(url:api,closeDilogDelay: 0);
  }

  static mute(String id) async{
    var api = '$url/$id/mute';
    return await Request.post(url: api,errMsg: '隐藏用户$id失败');
  }

  static unMute(String id) async{
    var api = '$url/$id/unmute';
    return await Request.post(url: api,errMsg: '取消隐藏用户$id失败');
  }


  static block(String id) async{
    var api = '$url/$id/block';
    return await Request.post(url: api,errMsg: '屏蔽用户$id失败');
  }

  static unBlock(String id) async{
    var api = '$url/$id/unblock';
    return await Request.post(url: api,errMsg: '取消屏蔽用户$id失败');
  }

  static blockDomain(String domain) async {
    var params = {
      'domain' : domain
    };
    await Request.post(url: blockDomainUrl,params: params);
  }

  static unBlockDomain(String domain) async {
    var params = {
      'domain' : domain
    };
    return await Request.delete(url: blockDomainUrl,params: params);
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

  static removeFilter(String id) async {
    var api = '$filterUrl/$id';
    return await Request.delete(url: api);
  }

  static addFilter(String phrase, List context,bool wholeWord) async{
    var params = {
      'phrase':phrase,
      'context': context,
      'whole_word': wholeWord
    };
   return  await Request.post(url: filterUrl,params: params);
  }

  static updateFilter(String id,String phrase,List context,bool wholeWord) async{
    var api = '$filterUrl/$id';
    var params = {
      'phrase':phrase,
      'context': context,
      'whole_word': wholeWord
    };

    return await Request.put(url: api,params: params);
  }
}