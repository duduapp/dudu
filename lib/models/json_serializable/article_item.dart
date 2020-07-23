import 'package:fastodon/models/json_serializable/owner_account.dart';
import 'package:json_annotation/json_annotation.dart';

part 'article_item.g.dart';

@JsonSerializable()
class StatusItemData extends Object {
  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'created_at')
  String createdAt;

  @JsonKey(name: 'in_reply_to_id')
  String inReplyToId;

  @JsonKey(name: 'in_reply_to_account_id')
  String inReplyToAccountId;

  @JsonKey(name: 'sensitive')
  bool sensitive;

  @JsonKey(name: 'spoiler_text')
  String spoilerText;

  @JsonKey(name: 'visibility')
  String visibility;

  @JsonKey(name: 'language')
  String language;

  @JsonKey(name: 'uri')
  String uri;

  @JsonKey(name: 'content')
  String content;

  @JsonKey(name: 'text')
  String text;

  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: 'replies_count')
  int repliesCount;

  @JsonKey(name: 'reblogs_count')
  int reblogsCount;

  @JsonKey(name: 'favourites_count')
  int favouritesCount;

  @JsonKey(name: 'favourited')
  bool favourited;

  @JsonKey(name: 'reblogged')
  bool reblogged;

  @JsonKey(name: 'muted')
  bool muted;

  @JsonKey(name: 'bookmarked')
  bool bookmarked;

  @JsonKey(name: 'reblog')
  StatusItemData reblog;

  @JsonKey(name: 'application')
  Application application;

  @JsonKey(name: 'account')
  OwnerAccount account;

  @JsonKey(name: 'media_attachments')
  List<dynamic> mediaAttachments;

  @JsonKey(name: 'mentions')
  List<dynamic> mentions;

  @JsonKey(name: 'tags')
  List<dynamic> tags;

  @JsonKey(name: 'emojis')
  List<dynamic> emojis;

  @JsonKey(name: 'card')
  Card card;

  @JsonKey(name: 'poll')
  Poll poll;

  StatusItemData(
      this.id,
      this.createdAt,
      this.inReplyToId,
      this.inReplyToAccountId,
      this.sensitive,
      this.spoilerText,
      this.visibility,
      this.language,
      this.uri,
      this.content,
      this.text,
      this.url,
      this.repliesCount,
      this.reblogsCount,
      this.favouritesCount,
      this.favourited,
      this.reblogged,
      this.muted,
      this.bookmarked,
      this.reblog,
      this.application,
      this.account,
      this.mediaAttachments,
      this.mentions,
      this.tags,
      this.emojis,
      this.card,
      this.poll);

  factory StatusItemData.fromJson(Map<String, dynamic> srcJson) =>
      _$StatusItemDataFromJson(srcJson);

  Map<String, dynamic> toJson() => _$StatusItemDataToJson(this);
}

@JsonSerializable()
class Application extends Object {
  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'website')
  String website;

  @JsonKey(name: 'vapid_key')
  String vapid_key;

  Application(this.name, this.website, this.vapid_key);

  factory Application.fromJson(Map<String, dynamic> srcJson) =>
      _$ApplicationFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ApplicationToJson(this);
}

@JsonSerializable()
class Card extends Object {
  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: 'title')
  String title;

  @JsonKey(name: 'description')
  String description;

  @JsonKey(name: 'type')
  String type;

  @JsonKey(name: 'author_name')
  String authorName;

  @JsonKey(name: 'author_url')
  String authorUrl;

  @JsonKey(name: 'provider_name')
  String providerName;

  @JsonKey(name: 'provider_url')
  String providerUrl;

  @JsonKey(name: 'html')
  String html;

  @JsonKey(name: 'width')
  int width;

  @JsonKey(name: 'height')
  int height;

  @JsonKey(name: 'image')
  String image;

  @JsonKey(name: 'embed_url')
  String embedUrl;

  Card(
    this.url,
    this.title,
    this.description,
    this.type,
    this.authorName,
    this.authorUrl,
    this.providerName,
    this.providerUrl,
    this.html,
    this.width,
    this.height,
    this.image,
    this.embedUrl,
  );

  factory Card.fromJson(Map<String, dynamic> srcJson) =>
      _$CardFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CardToJson(this);
}

@JsonSerializable()
class Poll extends Object {
  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'expires_at')
  String expiresAt;

  @JsonKey(name: 'expired')
  bool expired;

  @JsonKey(name: 'multiple')
  bool multiple;

  @JsonKey(name: 'votes_count')
  int votesCount;

  @JsonKey(name: 'voted')
  bool voted;

  @JsonKey(name: 'own_votes')
  List<dynamic> ownVotes;

  @JsonKey(name: 'options')
  List<dynamic> options;

  @JsonKey(name: 'emojis')
  List<dynamic> emojis;

  Poll(
      {this.id,
      this.expiresAt,
      this.expired,
      this.multiple,
      this.votesCount,
      this.voted,
      this.ownVotes,
      this.options,
      this.emojis});

  factory Poll.fromJson(Map<String, dynamic> srcJson) =>
      _$PollFromJson(srcJson);

  Map<String, dynamic> toJson() => _$PollToJson(this);
}
