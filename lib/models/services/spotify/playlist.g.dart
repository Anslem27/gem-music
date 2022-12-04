// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SPlaylistSimple _$SPlaylistSimpleFromJson(Map<String, dynamic> json) =>
    SPlaylistSimple(
      json['href'] as String,
      json['name'] as String,
      json['id'] as String,
      extractImageId(json['images'] as List?),
      SPlaylistSimple.extractIsNotEmpty(json['tracks'] as Map<String, dynamic>),
    );

SPlaylistItem _$SPlaylistItemFromJson(Map<String, dynamic> json) =>
    SPlaylistItem(
      json['track'] == null
          ? null
          : STrack.fromJson(json['track'] as Map<String, dynamic>),
    );
