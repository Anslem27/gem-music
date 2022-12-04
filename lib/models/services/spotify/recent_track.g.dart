// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SRecentTracksResponse _$SRecentTracksResponseFromJson(
        Map<String, dynamic> json) =>
    SRecentTracksResponse(
      (json['items'] as List<dynamic>)
          .map((e) => SRecentTrack.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

SRecentTrack _$SRecentTrackFromJson(Map<String, dynamic> json) => SRecentTrack(
      STrack.fromJson(json['track'] as Map<String, dynamic>),
      DateTime.parse(json['played_at'] as String),
    );
