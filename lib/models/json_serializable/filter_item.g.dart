// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FilterItem _$FilterItemFromJson(Map<String, dynamic> json) {
  return FilterItem(
    json['id'] as String,
    json['phrase'] as String,
    json['context'] as List,
    json['whole_word'] as bool,
    json['expires_at'] == null
        ? null
        : DateTime.parse(json['expires_at'] as String),
    json['irreversible'] as bool,
  );
}

Map<String, dynamic> _$FilterItemToJson(FilterItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'phrase': instance.phrase,
      'context': instance.context,
      'whole_word': instance.wholeWord,
      'expires_at': instance.expiresAt?.toIso8601String(),
      'irreversible': instance.irreversible,
    };
