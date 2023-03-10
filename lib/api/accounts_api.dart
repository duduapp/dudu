import 'package:dudu/l10n/l10n.dart';
import 'package:dio/dio.dart';
import 'package:dudu/models/json_serializable/filter_item.dart';
import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/pages/setting/model/relation_ship.dart';
import 'package:dudu/utils/account_util.dart';
import 'package:dudu/utils/request.dart';

class AccountsApi {
  static const String url = '/api/v1/accounts';
  static const String muteUrl= '/api/v1/mutes';
  static const String blockUrl = '/api/v1/blocks';
  static const String blockDomainUrl = '/api/v1/domain_blocks';
  static const String preferencesUrl = '/api/v1/preferences';
  static const String filterUrl = '/api/v1/filters';
  static const String relationShipUrl = '/api/v1/accounts/relationships';
  static const String reportUrl = '/api/v1/reports';
  static const String followRequestUrl = '/api/v1/follow_requests';

  static Future<OwnerAccount> getMyAccount() async{
    var data = await Request.get(url: url+'/verify_credentials');
    return OwnerAccount.fromJson(data);
  }

  static Future<OwnerAccount> getAccount(OwnerAccount account,{String hostUrl,CancelToken cancelToken}) async {



    var api = '${hostUrl ?? ''}$url/${account.id}';


    var res =  await Request.get(url: api,cancelToken: cancelToken);
    if (res == null) {
      return null;
    } else {
      var account =  OwnerAccount.fromJson(res);
      if (account.url != null)
        return account;
    }
    return null;
  }

  static Future<RelationShip> getRelationShip(OwnerAccount account,{String hostUrl,CancelToken cancelToken}) async {
    if (hostUrl != null) return null;
    var params = {
      'id[]':account.id
    };
    var res = await Request.get(url: relationShipUrl,params: params,cancelToken: cancelToken);
    if (res == null) {
      return null;
    } else {
      return RelationShip.fromJson(res[0]);
    }
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
    return await Request.post(url: api,showDialog: false);
  }

  static unMute(String id) async{
    var api = '$url/$id/unmute';
    return await Request.post(url: api);
  }


  static block(String id) async{
    var api = '$url/$id/block';
    return await Request.post(url: api,showDialog: false);
  }

  static unBlock(String id) async{
    var api = '$url/$id/unblock';
    return await Request.post(url: api);
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
      return await Request.requestDio(url:api,params: FormData.fromMap(params),type: RequestType.patch);
  }

  static Future<List<FilterItem>> getFilters() async{
    List<FilterItem> filters = [];
    var res = await Request.get(url: filterUrl);
    if (res != null)
    for (var row in res) {
      filters.add(FilterItem.fromJson(row));
    }
    return filters;
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


  static String statusUrl({OwnerAccount account,String hostUrl,String param = ''}) {
    return '${hostUrl ?? ''}$url/${account.id}/statuses?$param';
  }

  static String accountHost(OwnerAccount account) {
    return account.url.substring(0,account.url.lastIndexOf('/'));
  }

  static  reportUser(String accountId,List<String> statusesIds,String comment,bool forward) async{
    var params = {
      'account_id':accountId,
      'status_ids': statusesIds,
      'forward':forward
    };
    if (comment != null) {
      params['comment'] = comment;
    }

    return await Request.post(url: reportUrl,params: params);
  }

  static acceptFollow(String accountId) async{
    return await Request.post(url: '$followRequestUrl/$accountId/authorize');
  }

  static rejectFollow(String accountId) async {
    return await Request.post(url: '$followRequestUrl/$accountId/reject',showDialog: false);
  }
}