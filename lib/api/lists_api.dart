import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/utils/request.dart';


class ListsApi {
  static const String url = '/api/v1/lists';
  static const String timelineUrl = '/api/v1/timelines/list';

  static Future<List<OwnerAccount>> getMembers(String listId) async{
    List<dynamic> res = await Request.get2(url: url+'/'+listId+'/accounts');
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
    await Request.post(url: requestUrl,params: params,showDialog: false);
  }

  static removeAccount(String listId,String accountId) async {
    var requestUrl = '$url/$listId/accounts';
    var params = {
      'account_ids':[accountId]
    };
    await Request.delete(url: requestUrl,params: params,showDialog: false);
  }

  static updateTitle(String listId,String newTitle) async{
    var requestUrl = '$url/$listId';
    var params = {
      'title':newTitle
    };
    return await Request.put(url: requestUrl,params: params,showDialog: true);
  }

  static remove(String listId) async{
    var requestUrl = '$url/$listId';
    await Request.delete(url: requestUrl,showDialog: true);
  }

  static add(String title) async {
    var params = {
      'title':title
    };
    return await Request.post(url: url,params: params,showDialog: true);
  }
}