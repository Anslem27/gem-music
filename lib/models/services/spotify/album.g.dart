// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SAlbumSimple _$SAlbumSimpleFromJson(Map<String, dynamic> json) => SAlbumSimple(
      (json['artists'] as List<dynamic>)
          .map((e) => SArtistSimple.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['href'] as String?,
      json['name'] as String,
      json['id'] as String?,
      extractImageId(json['images'] as List?),
    );

SAlbumFull _$SAlbumFullFromJson(Map<String, dynamic> json) => SAlbumFull(
      (json['artists'] as List<dynamic>)
          .map((e) => SArtistSimple.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['href'] as String,
      json['name'] as String,
      json['id'] as String,
      extractImageId(json['images'] as List?),
      SAlbumFull.extractItems(json['tracks'] as Map<String, dynamic>),
    );
