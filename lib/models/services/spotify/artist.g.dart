// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SArtistSimple _$SArtistSimpleFromJson(Map<String, dynamic> json) =>
    SArtistSimple(
      json['id'] as String?,
      json['name'] as String,
      json['href'] as String?,
    );

SArtist _$SArtistFromJson(Map<String, dynamic> json) => SArtist(
      json['id'] as String,
      json['name'] as String,
      json['href'] as String,
      extractImageId(json['images'] as List?),
    );
