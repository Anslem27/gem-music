import 'dart:convert';
import 'package:http/http.dart';

List topSongs = [];
List viralSongs = [];
List cachedTopSongs = [];
List cachedViralSongs = [];
bool fetched = false;
bool emptyTop = false;
bool emptyViral = false;

Future<List> scrapData(String type) async {
  const String authority = 'www.volt.fm';
  const String topPath = '/charts/spotify-top';
  const String viralPath = '/charts/spotify-viral';

  final String unencodedPath = type == 'top' ? topPath : viralPath;

  final Response res = await get(Uri.https(authority, unencodedPath));

  if (res.statusCode != 200) return List.empty();
  final result = RegExp(r'<script.*>({\"context\".*})<\/script>', dotAll: true)
      .firstMatch(res.body)![1]!;
  final Map data = json.decode(result) as Map;
  return data['chart_ranking']['tracks'] as List;
}
