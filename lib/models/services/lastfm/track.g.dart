// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LRecentTracksResponseTrackArtist _$LRecentTracksResponseTrackArtistFromJson(
        Map<String, dynamic> json) =>
    LRecentTracksResponseTrackArtist(
      json['#text'] as String?,
      json['name'] as String?,
      json['url'] as String?,
    );

LRecentTracksResponseTrackAlbum _$LRecentTracksResponseTrackAlbumFromJson(
        Map<String, dynamic> json) =>
    LRecentTracksResponseTrackAlbum(
      json['#text'] as String,
    );

LRecentTracksResponseTrackDate _$LRecentTracksResponseTrackDateFromJson(
        Map<String, dynamic> json) =>
    LRecentTracksResponseTrackDate(
      fromSecondsSinceEpoch(json['uts']),
    );

LRecentTracksResponseTrack _$LRecentTracksResponseTrackFromJson(
        Map<String, dynamic> json) =>
    LRecentTracksResponseTrack(
      json['name'] as String,
      json['url'] as String,
      extractImageId(json['image'] as List?),
      LRecentTracksResponseTrackArtist.fromJson(
          json['artist'] as Map<String, dynamic>),
      LRecentTracksResponseTrackAlbum.fromJson(
          json['album'] as Map<String, dynamic>),
      json['date'] == null
          ? null
          : LRecentTracksResponseTrackDate.fromJson(
              json['date'] as Map<String, dynamic>),
      convertStringToBoolean(json['loved'] as String?),
    );

LRecentTracksResponseRecentTracks _$LRecentTracksResponseRecentTracksFromJson(
        Map<String, dynamic> json) =>
    LRecentTracksResponseRecentTracks(
      LAttr.fromJson(json['@attr'] as Map<String, dynamic>),
      (json['track'] as List<dynamic>)
          .map((e) =>
              LRecentTracksResponseTrack.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

LTrackMatch _$LTrackMatchFromJson(Map<String, dynamic> json) => LTrackMatch(
      json['name'] as String,
      json['url'] as String,
      json['artist'] as String,
    );

LTrackSearchResponse _$LTrackSearchResponseFromJson(
        Map<String, dynamic> json) =>
    LTrackSearchResponse(
      (json['track'] as List<dynamic>)
          .map((e) => LTrackMatch.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

LTrackArtist _$LTrackArtistFromJson(Map<String, dynamic> json) => LTrackArtist(
      json['name'] as String,
      json['url'] as String,
    );

LTrackAlbum _$LTrackAlbumFromJson(Map<String, dynamic> json) => LTrackAlbum(
      json['title'] as String,
      json['url'] as String,
      json['artist'] as String,
      extractImageId(json['image'] as List?),
    );

LTrack _$LTrackFromJson(Map<String, dynamic> json) => LTrack(
      json['name'] as String,
      json['url'] as String,
      parseInt(json['duration']),
      parseInt(json['listeners']),
      parseInt(json['playcount']),
      parseInt(json['userplaycount']),
      convertStringToBoolean(json['userloved'] as String?),
      json['artist'] == null
          ? null
          : LTrackArtist.fromJson(json['artist'] as Map<String, dynamic>),
      json['album'] == null
          ? null
          : LTrackAlbum.fromJson(json['album'] as Map<String, dynamic>),
      LTopTags.fromJsonSafe(json['toptags']),
      json['wiki'] == null
          ? null
          : LWiki.fromJson(json['wiki'] as Map<String, dynamic>),
    );

LTopTracksResponseTrack _$LTopTracksResponseTrackFromJson(
        Map<String, dynamic> json) =>
    LTopTracksResponseTrack(
      json['name'] as String,
      json['url'] as String,
      LTrackArtist.fromJson(json['artist'] as Map<String, dynamic>),
      parseInt(json['playcount']),
    );

LTopTracksResponseTopTracks _$LTopTracksResponseTopTracksFromJson(
        Map<String, dynamic> json) =>
    LTopTracksResponseTopTracks(
      (json['track'] as List<dynamic>)
          .map((e) =>
              LTopTracksResponseTrack.fromJson(e as Map<String, dynamic>))
          .toList(),
      LAttr.fromJson(json['@attr'] as Map<String, dynamic>),
    );
