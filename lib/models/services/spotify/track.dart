
import 'package:json_annotation/json_annotation.dart';

import '../generic.dart';
import '../image_id.dart';
import 'album.dart';
import 'artist.dart';

part 'track.g.dart';

@JsonSerializable()
class STrackSimple extends ScrobbleableTrack {
  final List<SArtistSimple> artists;

  @JsonKey(name: 'duration_ms')
  final int durationMs;

  @JsonKey(name: 'href')
  @override
  final String url;

  @override
  final String name;

  @override
  String? get albumName => null;

  @override
  String get artistName => artists.first.name;

  @override
  int get duration => durationMs ~/ 1000;

  STrackSimple(this.artists, this.durationMs, this.url, this.name);

  factory STrackSimple.fromJson(Map<String, dynamic> json) =>
      _$STrackSimpleFromJson(json);
}

@JsonSerializable()
class STrack extends ScrobbleableTrack {
  final SAlbumSimple album;

  final List<SArtistSimple> artists; // Should be SArtist

  @JsonKey(name: 'duration_ms')
  final int durationMs;

  @JsonKey(name: 'href')
  @override
  final String? url;

  @override
  final String name;

  @override
  String get albumName => album.name;

  @override
  String get artistName => artists.first.name;

  @override
  ImageId? get imageId => album.imageId;

  @override
  int get duration => durationMs ~/ 1000;

  STrack(this.album, this.artists, this.durationMs, this.url, this.name);

  factory STrack.fromJson(Map<String, dynamic> json) => _$STrackFromJson(json);

  @override
  String toString() =>
      'STrack(name=$name, artist=$artistName, album=$albumName)';
}
