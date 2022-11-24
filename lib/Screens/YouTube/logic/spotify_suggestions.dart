import 'package:spotify/spotify.dart';

// Play More with the Spotify API here
// to fetch prefered playlists

//TODO: Fetch recently played from personal account, rather than setting up const variables
class SpotifyService {
  //TODO: Add client secret and id here
  static var credentials = SpotifyApiCredentials(
      '6ac6511f2ed1432e9917624fc7a67bef', 'd6331f83644e4d93b27f63bd97da3f3c');
  //static var credentials = SpotifyApiCredentials('CLIENT_ID', 'CLIENT_SECRET');
  final spotify = SpotifyApi(credentials);

  //playlist id from which you want to fetch fav songs preferably a daily updated playlist.
  final desiredPlaylistid = "37i9dQZF1DX2L0ib23Enbq";

  getSpotifyHottest() async {
    var tracks = spotify.playlists.getTracksByPlaylistId(desiredPlaylistid);
    return tracks;
  }
}
