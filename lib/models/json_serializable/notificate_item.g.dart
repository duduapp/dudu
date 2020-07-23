// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notificate_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationItem _$NotificationItemFromJson(Map<String, dynamic> json) {
  return NotificationItem(
      json['id'] as String,
      json['type'] as String,
      json['created_at'] as String,
      json['account'] == null
          ? null
          : OwnerAccount.fromJson(json['account'] as Map<String, dynamic>),
      json['status'] == null
          ? null
          : StatusItemData.fromJson(json['status'] as Map<String, dynamic>));
}

Map<String, dynamic> _$NotificationItemToJson(NotificationItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'created_at': instance.createdAt,
      'account': instance.account,
      'status': instance.status
    };

Application _$ApplicationFromJson(Map<String, dynamic> json) {
  return Application(json['name'] as String, json['website'] as String);
}

Map<String, dynamic> _$ApplicationToJson(Application instance) =>
    <String, dynamic>{'name': instance.name, 'website': instance.website};
