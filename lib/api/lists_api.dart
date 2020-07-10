import 'package:fastodon/models/owner_account.dart';
import 'package:fastodon/utils/request.dart';
import 'package:flutter/cupertino.dart';


class ListsApi {
  static const String url = '/api/v1/lists';
  static const String timelineUrl = '/api/v1/timelines/list';

  static Future<List<OwnerAccount>> getMembers(String listId) async{
    List<dynamic> res = await Request.get(url: url+'/'+listId+'/accounts');
    List<OwnerAccount> accounts= [];
    for (dynamic acc in res) {
      accounts.add(OwnerAccount.fromJson(acc));
    }
    return accounts;
  }

  static addAccount(String listId,String accountId) async{
    var requestUrl = '$url/$listId/accounts';
    var params = {
      'account_ids':[accountId]
    };
    await Request.post(url: requestUrl,params: params);
  }

  static removeAccount(String listId,String accountId) async {
    var requestUrl = '$url/$listId/accounts';
    var params = {
      'account_ids':[accountId]
    };
    await Request.delete(url: requestUrl,params: params);
  }

  static updateTitle(String listId,String newTitle) async{
    var requestUrl = '$url/$listId';
    var params = {
      'title':newTitle
    };
    return await Request.put(url: requestUrl,params: params);
  }

  static remove(String listId) async{
    var requestUrl = '$url/$listId';
    await Request.delete(url: requestUrl);
  }

  static add(String title,{BuildContext context}) async {
    var params = {
      'title':title
    };
    await Request.post(url: url,params: params,showDialog: true);
  }
}