// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SPage<T> _$SPageFromJson<T extends Entity>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    SPage<T>(
      (json['items'] as List<dynamic>).map(fromJsonT).toList(),
    );

SException _$SExceptionFromJson(Map<String, dynamic> json) => SException(
      json['message'] as String,
      json['status'] as int,
    );
