import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

class SpotifyApi {
  final List<String> _scopes = [
    'user-read-private',
    'user-read-email',
    'playlist-read-private',
    'playlist-read-collaborative',
  ];

  /// id= 6ac6511f2ed1432e9917624fc7a67bef
  final String clientID = '6ac6511f2ed1432e9917624fc7a67bef';
  /* secret= d6331f83644e4d93b27f63bd97da3f3c */
  final String clientSecret = 'd6331f83644e4d93b27f63bd97da3f3c';
  final String redirectUrl = 'app://gem/auth';
  final String spotifyApiBaseUrl = 'https://accounts.spotify.com/api';
  final String spotifyPlaylistBaseUrl =
      'https://api.spotify.com/v1/me/playlists';
  final String spotifyTrackBaseUrl = 'https://api.spotify.com/v1/playlists';
  final String spotifyBaseUrl = 'https://accounts.spotify.com';
  final String requestToken = 'https://accounts.spotify.com/api/token';

  String requestAuthorization() =>
      'https://accounts.spotify.com/authorize?client_id=$clientID&response_type=code&redirect_uri=$redirectUrl&scope=${_scopes.join('%20')}';

  Future<List<String>> getAccessToken(String code) async {
    final Map<String, String> headers = {
      'Authorization':
          "Basic ${base64.encode(utf8.encode("$clientID:$clientSecret"))}",
    };

    final Map<String, String> body = {
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': redirectUrl
    };

    try {
      final Uri path = Uri.parse(requestToken);
      final response = await post(path, headers: headers, body: body);
      // print(response.statusCode);
      if (response.statusCode == 200) {
        final Map result = jsonDecode(response.body) as Map;
        return <String>[
          result['access_token'].toString(),
          result['refresh_token'].toString()
        ];
      }
    } catch (e) {
      // print('Error: $e');
    }
    return [];
  }

  Future<List> getUserPlaylists(String accessToken) async {
    try {
      final Uri path = Uri.parse('$spotifyPlaylistBaseUrl?limit=50');

      final response = await get(
        path,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json'
        },
      );
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final List playlists = result['items'] as List;
        return playlists;
      }
    } catch (e) {
      // print('Error: $e');
    }
    return [];
  }

  Future<Map> getTracksOfPlaylist(
    String accessToken,
    String playListId,
    int offset,
  ) async {
    try {
      final Uri path = Uri.parse(
        '$spotifyTrackBaseUrl/$playListId/tracks?limit=100&offset=$offset',
      );
      final response = await get(
        path,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final List tracks = result['items'] as List;
        final int total = result['total'] as int;
        return {'tracks': tracks, 'total': total};
      }
    } catch (e) {
      // print('Error: $e');
    }
    return {};
  }
}
