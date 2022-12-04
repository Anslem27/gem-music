// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LScrobbleResponseScrobblesAttr _$LScrobbleResponseScrobblesAttrFromJson(
        Map<String, dynamic> json) =>
    LScrobbleResponseScrobblesAttr(
      parseInt(json['accepted']),
      parseInt(json['ignored']),
    );

LTag _$LTagFromJson(Map<String, dynamic> json) => LTag(
      json['name'] as String,
    );

LTopTags _$LTopTagsFromJson(Map<String, dynamic> json) => LTopTags(
      LTopTags.parseTags(json['tag']),
    );

LAttr _$LAttrFromJson(Map<String, dynamic> json) => LAttr(
      parseInt(json['page']),
      parseInt(json['total']),
      json['user'] as String,
      parseInt(json['perPage']),
      parseInt(json['totalPages']),
    );

LWiki _$LWikiFromJson(Map<String, dynamic> json) => LWiki(
      json['published'] as String,
      LWiki.trim(json['summary'] as String),
      LWiki.trim(json['content'] as String),
    );

LException _$LExceptionFromJson(Map<String, dynamic> json) => LException(
      parseInt(json['error']),
      json['message'] as String,
    );
