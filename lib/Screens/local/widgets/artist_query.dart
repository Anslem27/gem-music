/* import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
// import 'package:html/dom.dart' as dom;

Future<String?> searchGoogleAndGetFirstImage(String query) async {
  // Send a GET request to Google with the search query
  var response = await http
      .get(Uri.https('https://www.google.com/search?q=$query&tbm=isch'));

  // Parse the HTML response
  var document = parser.parse(response.body);

  // Find the first image in the search results
  var imageElement = document.querySelector('img');

  // Return the source URL of the image
  return imageElement!.attributes['src'];
}
 */