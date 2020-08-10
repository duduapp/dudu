import 'package:json_annotation/json_annotation.dart';

part 'filter_item.g.dart';

@JsonSerializable()
class FilterItem extends Object {

  @JsonKey(name: 'id')
  String id;

  @JsonKey(name : 'phrase')
  String phrase;

  @JsonKey(name : 'context')
  List context;

  @JsonKey(name : 'whole_word')
  bool wholeWord;

  @JsonKey(name : 'expires_at')
  DateTime expiresAt;

  @JsonKey(name : 'irreversible')
  bool irreversible;

  FilterItem(this.id,this.phrase,this.context,this.wholeWord,this.expiresAt,this.irreversible);

  factory FilterItem.fromJson(Map<String, dynamic> srcJson) => _$FilterItemFromJson(srcJson);

  Map<String, dynamic> toJson() => _$FilterItemToJson(this);

}