import 'package:fastodon/models/json_serializable/article_item.dart';
import 'package:fastodon/models/json_serializable/owner_account.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notificate_item.g.dart';


@JsonSerializable()
  class NotificationItem extends Object {

  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'type')
  String type;

  @JsonKey(name: 'created_at')
  String createdAt;

  @JsonKey(name: 'account')
  OwnerAccount account;

  @JsonKey(name: 'status')
  StatusItemData status;

  NotificationItem(this.id,this.type,this.createdAt,this.account,this.status,);

  factory NotificationItem.fromJson(Map<String, dynamic> srcJson) => _$NotificationItemFromJson(srcJson);

  Map<String, dynamic> toJson() => _$NotificationItemToJson(this);

}

@JsonSerializable()
  class Application extends Object {

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'website')
  String website;

  Application(this.name,this.website,);

  factory Application.fromJson(Map<String, dynamic> srcJson) => _$ApplicationFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ApplicationToJson(this);

}
