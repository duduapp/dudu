// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instance_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InstanceItem _$InstanceItemFromJson(Map<String, dynamic> json) {
  return InstanceItem()
    ..uri = json['uri'] as String
    ..title = json['title'] as String
    ..shortDescription = json['short_description'] as String
    ..description = json['description'] as String
    ..email = json['email'] as String
    ..version = json['version'] as String
    ..urls = (json['urls'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    )
    ..stats = json['stats'] as Map<String, dynamic>
    ..thumbnail = json['thumbnail'] as String
    ..languages = (json['languages'] as List)?.map((e) => e as String)?.toList()
    ..registrations = json['registrations'] as bool
    ..approvalRequired = json['approval_required'] as bool
    ..invitesEnabled = json['invites_enabled'] as bool
    ..contactAccount = json['contact_account'] == null
        ? null
        : OwnerAccount.fromJson(
            json['contact_account'] as Map<String, dynamic>);
}

Map<String, dynamic> _$InstanceItemToJson(InstanceItem instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'title': instance.title,
      'short_description': instance.shortDescription,
      'description': instance.description,
      'email': instance.email,
      'version': instance.version,
      'urls': instance.urls,
      'stats': instance.stats,
      'thumbnail': instance.thumbnail,
      'languages': instance.languages,
      'registrations': instance.registrations,
      'approval_required': instance.approvalRequired,
      'invites_enabled': instance.invitesEnabled,
      'contact_account': instance.contactAccount,
    };
