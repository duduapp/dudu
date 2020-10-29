import 'package:dudu/models/provider/result_list_provider.dart';
import 'package:dudu/utils/url_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class ProviderUtil {
  static String url(BuildContext context) {
    ResultListProvider provider;
    try {
      provider = Provider.of<ResultListProvider>(context, listen: false);
    } catch (e) {
      return null;
    }
    return provider.requestUrl;
  }

  static String hostUrl(BuildContext context) {
    var providerUrl = url(context);
    if (providerUrl != null && providerUrl.startsWith('https://')) {
      return UrlUtil.hostUrl(providerUrl);
    }
    return null;
  }
}