

import 'package:dudu/models/http/http_response.dart';
import 'package:dudu/utils/request.dart';
import 'package:flutter/foundation.dart';


class AdminApi {

  static const String url = '/api/v1/admin/accounts';

  static warnUser(String accountId) async{
    var res = await Request.post(url: '$url/$accountId/action',params: {
      'type':'none',
      'send_email_notification': false
    },showDialog: false,returnAll: true);

    if (res is HttpResponse) {
      if (res.statusCode == 200) {
        return true;
      }
    }
    return false;
  }

  static accountAction({String accountId,String type,bool sendEmail,String text}) async{
    var res = await Request.post(url: '$url/$accountId/action',params: {
      'type': type,
      'send_email_notification': sendEmail,
      'text' : text,
    },showDialog: true,returnAll: true);
    if (res is HttpResponse) {
      if (res.statusCode == 200) {
        return true;
      }
    }
    return false;
  }

}