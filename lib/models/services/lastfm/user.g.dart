// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LUserRegistered _$LUserRegisteredFromJson(Map<String, dynamic> json) =>
    LUserRegistered(
      fromSecondsSinceEpoch(json['unixtime']),
    );

LUser _$LUserFromJson(Map<String, dynamic> json) => LUser(
      json['name'] as String,
      json['realname'] as String?,
      json['url'] as String,
      extractImageId(json['image'] as List?),
      parseInt(json['playcount']),
      LUserRegistered.fromJson(json['registered'] as Map<String, dynamic>),
    );

LUserFriendsResponse _$LUserFriendsResponseFromJson(
        Map<String, dynamic> json) =>
    LUserFriendsResponse(
      (json['user'] as List<dynamic>)
          .map((e) => LUser.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

LAuthenticationResponseSession _$LAuthenticationResponseSessionFromJson(
        Map<String, dynamic> json) =>
    LAuthenticationResponseSession(
      json['name'] as String,
      json['key'] as String,
    );

LUserWeeklyChart _$LUserWeeklyChartFromJson(Map<String, dynamic> json) =>
    LUserWeeklyChart(
      json['from'] as String,
      json['to'] as String,
    );

LUserWeeklyChartList _$LUserWeeklyChartListFromJson(
        Map<String, dynamic> json) =>
    LUserWeeklyChartList(
      (json['chart'] as List<dynamic>)
          .map((e) => LUserWeeklyChart.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

LUserWeeklyTrackChartTrackArtist _$LUserWeeklyTrackChartTrackArtistFromJson(
        Map<String, dynamic> json) =>
    LUserWeeklyTrackChartTrackArtist(
      json['#text'] as String,
    );

LUserWeeklyTrackChartTrack _$LUserWeeklyTrackChartTrackFromJson(
        Map<String, dynamic> json) =>
    LUserWeeklyTrackChartTrack(
      LUserWeeklyTrackChartTrackArtist.fromJson(
          json['artist'] as Map<String, dynamic>),
      json['url'] as String,
      json['name'] as String,
      intParseSafe(json['playcount']),
    );

LUserWeeklyTrackChart _$LUserWeeklyTrackChartFromJson(
        Map<String, dynamic> json) =>
    LUserWeeklyTrackChart(
      (json['track'] as List<dynamic>)
          .map((e) =>
              LUserWeeklyTrackChartTrack.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

LUserWeeklyAlbumChartAlbumArtist _$LUserWeeklyAlbumChartAlbumArtistFromJson(
        Map<String, dynamic> json) =>
    LUserWeeklyAlbumChartAlbumArtist(
      json['#text'] as String,
    );

LUserWeeklyAlbumChartAlbum _$LUserWeeklyAlbumChartAlbumFromJson(
        Map<String, dynamic> json) =>
    LUserWeeklyAlbumChartAlbum(
      LUserWeeklyAlbumChartAlbumArtist.fromJson(
          json['artist'] as Map<String, dynamic>),
      json['url'] as String,
      json['name'] as String,
      intParseSafe(json['playcount']),
    );

LUserWeeklyAlbumChart _$LUserWeeklyAlbumChartFromJson(
        Map<String, dynamic> json) =>
    LUserWeeklyAlbumChart(
      (json['album'] as List<dynamic>)
          .map((e) =>
              LUserWeeklyAlbumChartAlbum.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

LUserWeeklyArtistChartArtist _$LUserWeeklyArtistChartArtistFromJson(
        Map<String, dynamic> json) =>
    LUserWeeklyArtistChartArtist(
      json['url'] as String,
      json['name'] as String,
      intParseSafe(json['playcount']),
    );

LUserWeeklyArtistChart _$LUserWeeklyArtistChartFromJson(
        Map<String, dynamic> json) =>
    LUserWeeklyArtistChart(
      (json['artist'] as List<dynamic>)
          .map((e) =>
              LUserWeeklyArtistChartArtist.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

LUserTrackScrobblesResponse _$LUserTrackScrobblesResponseFromJson(
        Map<String, dynamic> json) =>
    LUserTrackScrobblesResponse(
      (json['track'] as List<dynamic>)
          .map((e) => LUserTrackScrobble.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

LUserTrackScrobble _$LUserTrackScrobbleFromJson(Map<String, dynamic> json) =>
    LUserTrackScrobble(
      json['name'] as String,
      LUserTrackScrobble.extractDateTimeFromObject(
          json['date'] as Map<String, dynamic>),
      json['url'] as String,
      LUserWeeklyTrackChartTrackArtist.fromJson(
          json['artist'] as Map<String, dynamic>),
      LUserTrackScrobbleAlbum.fromJson(json['album'] as Map<String, dynamic>),
    );

LUserTrackScrobbleAlbum _$LUserTrackScrobbleAlbumFromJson(
        Map<String, dynamic> json) =>
    LUserTrackScrobbleAlbum(
      json['#text'] as String,
    );
