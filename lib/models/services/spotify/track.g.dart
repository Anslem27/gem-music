// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

STrackSimple _$STrackSimpleFromJson(Map<String, dynamic> json) => STrackSimple(
      (json['artists'] as List<dynamic>)
          .map((e) => SArtistSimple.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['duration_ms'] as int,
      json['href'] as String,
      json['name'] as String,
    );

STrack _$STrackFromJson(Map<String, dynamic> json) => STrack(
      SAlbumSimple.fromJson(json['album'] as Map<String, dynamic>),
      (json['artists'] as List<dynamic>)
          .map((e) => SArtistSimple.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['duration_ms'] as int,
      json['href'] as String?,
      json['name'] as String,
    );
