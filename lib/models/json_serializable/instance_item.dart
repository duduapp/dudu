import 'package:dudu/models/json_serializable/owner_account.dart';
import 'package:json_annotation/json_annotation.dart';

part 'instance_item.g.dart';

@JsonSerializable()
class InstanceItem extends Object {
  @JsonKey(name:'uri')
  String uri;

  @JsonKey(name:'title')
  String title;

  @JsonKey(name:'short_description')
  String shortDescription;

  @JsonKey(name:'description')
  String description;

  @JsonKey(name:'email')
  String email;

  @JsonKey(name:'version')
  String version;

  @JsonKey(name:'urls')
  Map<String,String> urls;

  @JsonKey(name:'stats')
  Map<String,dynamic> stats;

  @JsonKey(name:'thumbnail')
  String thumbnail;

  @JsonKey(name:'languages')
  List<String> languages;

  @JsonKey(name:'registrations')
  bool registrations; //Added in 2.7.2

  @JsonKey(name:'approval_required')
  bool approvalRequired; // Added in 2.9.2

  @JsonKey(name:'invites_enabled')
  bool invitesEnabled; // Added in 3.1.4

  @JsonKey(name: 'contact_account')
  OwnerAccount contactAccount;

  InstanceItem();

  factory InstanceItem.fromJson(Map<String, dynamic> srcJson) => _$InstanceItemFromJson(srcJson);

  Map<String, dynamic> toJson() => _$InstanceItemToJson(this);
}