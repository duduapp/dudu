
import 'dart:convert';

import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:dudu/utils/local_storage.dart';
// account info saved in local
class LocalAccount {
  OwnerAccount account;
  final String hostUrl;
  final String token;
  bool active;

  LocalAccount({this.account,this.hostUrl,this.token,this.active});

  setAccount(OwnerAccount account) {
    this.account = account;
  }


  factory LocalAccount.fromStr(String str) {
    Map json = jsonDecode(str);
    return LocalAccount(
      hostUrl: json['host_url'],
      token: json['token'],
      account: json['account'] == null  ?  null : OwnerAccount.fromJson(json['account']),
      active: json['active']
    );
  }

  String toStr() {
    return jsonEncode({
      'host_url':hostUrl,
      'token':token,
      'account':account?.toJson(),
      'active':active
    });
  }
}

class LocalStorageAccount {
  static Future<List<LocalAccount>> getAccounts() async{
    List<String> accs = await Storage.getStringList('mastodon_accounts');
    if (accs == null) return [];
    List<LocalAccount> accounts = [];
    for (String s in accs) {
      accounts.add(LocalAccount.fromStr(s));
    }
    return accounts;
  }

  static Future<LocalAccount> getActiveAccount() async {
    var accounts = await getAccounts();
    for (var acc in accounts) {
      if (acc.active) {
        return acc;
      }
    }
    return null;
  }

  static setActiveAccount(LocalAccount account) async{
      var accounts = await getAccounts();
      for (var acc in accounts) {
        if (acc.hostUrl == account.hostUrl && acc.token == account.token) {
          acc.active = true;
        } else {
          acc.active = false;
        }
      }
      await saveAccounts(accounts);
  }

  static removeAccount(LocalAccount account) async {
    List<LocalAccount> newAcc = [];
    var accounts = await getAccounts();
    for (var acc in accounts) {
      if (acc.hostUrl == account.hostUrl && acc.token == account.token) {
      } else {
        newAcc.add(acc);
      }
    }
    await saveAccounts(newAcc);
  }

  static logout() async{
    LocalAccount account = await getActiveAccount();
    await removeAccount(account);
  }
  
  static addLocalAccount(LocalAccount account) async{
    List<LocalAccount> accounts = await getAccounts();
    for (var acc in accounts) {
      acc.active = false;
    }
    accounts.add(account);

    await saveAccounts(accounts);
  }
  
  static Future addOwnerAccount(OwnerAccount account) async{
    List<LocalAccount> accounts = await getAccounts();
    for (var a in accounts) {
      if (a.active) {
        a.setAccount(account);
        break;
      }
    }
    await saveAccounts(accounts);
  }

  static Future saveAccounts(List<LocalAccount> accounts) async{
    await Storage.saveStringList('mastodon_accounts', accounts.map((e) => e.toStr()).toList());
  }
}