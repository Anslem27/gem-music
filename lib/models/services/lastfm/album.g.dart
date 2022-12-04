// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LTopAlbumsResponseAlbumArtist _$LTopAlbumsResponseAlbumArtistFromJson(
        Map<String, dynamic> json) =>
    LTopAlbumsResponseAlbumArtist(
      json['name'] as String,
      json['url'] as String?,
    );

LTopAlbumsResponseAlbum _$LTopAlbumsResponseAlbumFromJson(
        Map<String, dynamic> json) =>
    LTopAlbumsResponseAlbum(
      json['name'] as String,
      json['url'] as String,
      parseInt(json['playcount']),
      LTopAlbumsResponseAlbumArtist.fromJson(
          json['artist'] as Map<String, dynamic>),
      extractImageId(json['image'] as List?),
    );

LTopAlbumsResponseTopAlbums _$LTopAlbumsResponseTopAlbumsFromJson(
        Map<String, dynamic> json) =>
    LTopAlbumsResponseTopAlbums(
      (json['album'] as List<dynamic>)
          .map((e) =>
              LTopAlbumsResponseAlbum.fromJson(e as Map<String, dynamic>))
          .toList(),
      LAttr.fromJson(json['@attr'] as Map<String, dynamic>),
    );

LAlbumMatch _$LAlbumMatchFromJson(Map<String, dynamic> json) => LAlbumMatch(
      json['name'] as String,
      json['url'] as String,
      json['artist'] as String,
      extractImageId(json['image'] as List?),
    );

LAlbumSearchResponse _$LAlbumSearchResponseFromJson(
        Map<String, dynamic> json) =>
    LAlbumSearchResponse(
      (json['album'] as List<dynamic>)
          .map((e) => LAlbumMatch.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

LAlbumTrack _$LAlbumTrackFromJson(Map<String, dynamic> json) => LAlbumTrack(
      json['name'] as String,
      json['url'] as String,
      intParseSafe(json['duration']),
      json['album'] as String?,
      LTopAlbumsResponseAlbumArtist.fromJson(
          json['artist'] as Map<String, dynamic>),
    );

LAlbumTracks _$LAlbumTracksFromJson(Map<String, dynamic> json) => LAlbumTracks(
      LAlbumTracks.parseTracks(json['track']),
    );

LAlbum _$LAlbumFromJson(Map<String, dynamic> json) => LAlbum(
      json['name'] as String,
      json['artist'] as String,
      json['url'] as String,
      extractImageId(json['image'] as List?),
      parseInt(json['playcount']),
      parseInt(json['userplaycount']),
      parseInt(json['listeners']),
      json['tracks'] == null
          ? null
          : LAlbumTracks.fromJson(json['tracks'] as Map<String, dynamic>),
      LTopTags.fromJsonSafe(json['tags']),
      json['wiki'] == null
          ? null
          : LWiki.fromJson(json['wiki'] as Map<String, dynamic>),
    );
