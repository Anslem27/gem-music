// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LTopArtistsResponseArtist _$LTopArtistsResponseArtistFromJson(
        Map<String, dynamic> json) =>
    LTopArtistsResponseArtist(
      json['name'] as String,
      json['url'] as String,
      parseInt(json['playcount']),
    );

LTopArtistsResponseTopArtists _$LTopArtistsResponseTopArtistsFromJson(
        Map<String, dynamic> json) =>
    LTopArtistsResponseTopArtists(
      (json['artist'] as List<dynamic>)
          .map((e) =>
              LTopArtistsResponseArtist.fromJson(e as Map<String, dynamic>))
          .toList(),
      LAttr.fromJson(json['@attr'] as Map<String, dynamic>),
    );

LArtistMatch _$LArtistMatchFromJson(Map<String, dynamic> json) => LArtistMatch(
      json['name'] as String,
      json['url'] as String,
    );

LArtistSearchResponse _$LArtistSearchResponseFromJson(
        Map<String, dynamic> json) =>
    LArtistSearchResponse(
      (json['artist'] as List<dynamic>)
          .map((e) => LArtistMatch.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

LSimilarArtist _$LSimilarArtistFromJson(Map<String, dynamic> json) =>
    LSimilarArtist(
      json['name'] as String,
      url: json['url'] as String,
      similarity: double.parse(json['match'] as String),
    );

LSimilarArtistsResponse _$LSimilarArtistsResponseFromJson(
        Map<String, dynamic> json) =>
    LSimilarArtistsResponse(
      (json['artist'] as List<dynamic>)
          .map((e) => LSimilarArtist.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

LArtistStats _$LArtistStatsFromJson(Map<String, dynamic> json) => LArtistStats(
      parseInt(json['playcount']),
      parseInt(json['userplaycount']),
      parseInt(json['listeners']),
    );

LArtist _$LArtistFromJson(Map<String, dynamic> json) => LArtist(
      json['name'] as String,
      json['url'] as String,
      LArtistStats.fromJson(json['stats'] as Map<String, dynamic>),
      LTopTags.fromJsonSafe(json['tags']),
      json['bio'] == null
          ? null
          : LWiki.fromJson(json['bio'] as Map<String, dynamic>),
    );

LArtistTopAlbum _$LArtistTopAlbumFromJson(Map<String, dynamic> json) =>
    LArtistTopAlbum(
      json['name'] as String,
      json['url'] as String,
      parseInt(json['playcount']),
      LTopAlbumsResponseAlbumArtist.fromJson(
          json['artist'] as Map<String, dynamic>),
      extractImageId(json['image'] as List?),
    );

LArtistGetTopAlbumsResponse _$LArtistGetTopAlbumsResponseFromJson(
        Map<String, dynamic> json) =>
    LArtistGetTopAlbumsResponse(
      (json['album'] as List<dynamic>)
          .map((e) => LArtistTopAlbum.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

LArtistTopTrack _$LArtistTopTrackFromJson(Map<String, dynamic> json) =>
    LArtistTopTrack(
      json['name'] as String,
      json['url'] as String,
      LTopAlbumsResponseAlbumArtist.fromJson(
          json['artist'] as Map<String, dynamic>),
    );

LArtistGetTopTracksResponse _$LArtistGetTopTracksResponseFromJson(
        Map<String, dynamic> json) =>
    LArtistGetTopTracksResponse(
      (json['track'] as List<dynamic>)
          .map((e) => LArtistTopTrack.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

LChartTopArtists _$LChartTopArtistsFromJson(Map<String, dynamic> json) =>
    LChartTopArtists(
      (json['artist'] as List<dynamic>)
          .map((e) =>
              LTopArtistsResponseArtist.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
