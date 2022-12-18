//API_KEY: AIzaSyCnhvbSnWz5I-HvUTbbPr6DznmC_Nl3JTM

//!Code.

// import 'dart:convert';
// import 'dart:html';

/* void main() async {
  // Make a request to the Google Images search API
  var response = await HttpRequest.getString(
      'https://www.googleapis.com/customsearch/v1?q=flowers&cx=017576662512468239146:omuauf_lfve&imgSize=huge&imgType=news&num=1&searchType=image&key=YOUR_API_KEY');

  // Parse the JSON response
  var data = json.decode(response);

  // Get the first image URL from the search results
  var imageUrl = data['items'][0]['link'];

  // Create an image element and set its src to the image URL
  var image = ImageElement();
  image.src = imageUrl;

  // Add the image to the page
  document.body.append(image);
} */
// This code makes a request to the Google Custom Search API with a query for "flowers" and returns the URL of the first image in the search results. It then creates an ImageElement and sets its src to the image URL, and adds the image to the page.

// Note that you will need to replace YOUR_API_KEY with your own API key, which you can obtain by signing up for the Google Custom Search API.


//! Code Two.



/* String searchTerm = 'cat';
String searchEngineId = 'YOUR_SEARCH_ENGINE_ID';
String apiKey = 'YOUR_API_KEY';

Future<List<String>> searchImages() async {
  List<String> imageUrls = [];
  String searchUrl = 'https://www.googleapis.com/customsearch/v1?key=$apiKey&cx=$searchEngineId&q=$searchTerm&searchType=image';
  var response = await http.get(searchUrl);
  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    for (var item in data['items']) {
      imageUrls.add(item['link']);
    }
  }
  return imageUrls;
} */

//! Code Three.


// Replace 'SEARCH_QUERY' with the search query you want to use
/* String searchUrl = 'https://www.google.com/search?q=SEARCH_QUERY&tbm=isch';

// Make the HTTP GET request to the search URL
http.Response response = await http.get(searchUrl);

// Convert the response body to a JSON map
Map<String, dynamic> jsonResponse = json.decode(response.body);

// Get the list of search results from the JSON map
List<dynamic> searchResults = jsonResponse['items'];

// Get the first result from the list of search results
Map<String, dynamic> firstResult = searchResults[0];

// Get the URL of the first result
String imageUrl = firstResult['link']; */

// You can now use the image URL to download or display the image

//! Code Three.
/* import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom; */

// Function to search Google and return the first image from the search results
/* Future<String> searchGoogleAndGetFirstImage(String query) async {
  // Send a GET request to Google with the search query
  var response = await http.get('https://www.google.com/search?q=$query&tbm=isch');

  // Parse the HTML response
  var document = parser.parse(response.body);

  // Find the first image in the search results
  var imageElement = document.querySelector('img');

  // Return the source URL of the image
  return imageElement.attributes['src'];
}
 */
/* void main() async {
  // Search Google for "Dart programming language"
  var imageUrl = await searchGoogleAndGetFirstImage('Dart programming language');

  // Print the URL of the first image from the search results
  print(imageUrl);
}
 */

