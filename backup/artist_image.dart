import 'package:http/http.dart' as http;

int width = 300;
int height = 300;



//eg
// url=https://itunes.apple.com/ca/artist/taylor-swift/id159260351

Future<String> getArtistArtworkUrl(String artistId) async {
  final response =
      await http.get(Uri.parse('https://music.apple.com/en/artist/$artistId'));
  final document = response.body;

  RegExp regEx = RegExp("<meta property=\"og:image\" content=\"(.*png)\"");
  RegExpMatch? match = regEx.firstMatch(document);

  if (match != null) {
    String rawImageUrl = match.group(1) ?? '';
    String imageUrl = rawImageUrl.replaceAll(
        RegExp(r'[\d]+x[\d]+(cw)+'), '${width}x${height}cc');
    return imageUrl;
  }

  throw Exception();
}


// string map implmentation

Map<String, String> artistMap = {
  "https://itunes.apple.com/ca/artist/taylor-swift/id159260351": "Taylor Swift"
};

// use variable elsewhere in app

var callString = artistMap["Taylor Swift"];
