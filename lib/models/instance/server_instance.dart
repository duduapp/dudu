import 'package:dudu/models/json_serializable/instance_item.dart';

class ServerInstance {
  String url;
  InstanceItem detail;
  bool fromServer;
  bool fromStale;

  ServerInstance({this.url, this.detail, this.fromServer,this.fromStale});
}