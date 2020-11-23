import 'dart:convert';

import 'package:dudu/models/json_serializable/article_item.dart';

dynamic parseJsonString(String str) {
  return json.decode(str);
}

List<StatusItemData> parseStatsuJsonList(List jsonList) {
  return jsonList.map<StatusItemData>((e) => StatusItemData.fromJson(e)).toList();
}