import 'package:flutter/material.dart';
import 'package:gem/models/widgets/entity/spotify/spotify_artist_view.dart';

import '../../../services/spotify/album.dart';
import '../../../services/spotify/spotify.dart';
import '../../../util/constants.dart';
import '../../base/app_bar.dart';
import '../../base/future_builder_view.dart';
import '../../base/scrobble_button.dart';
import '../../base/two_up.dart';
import '../entity_display.dart';
import '../entity_image.dart';

class SpotifyAlbumView extends StatelessWidget {
  final SAlbumSimple album;

  const SpotifyAlbumView({super.key, required this.album});

  @override
  Widget build(BuildContext context) => FutureBuilderView<SAlbumFull>(
        futureFactory: () => Spotify.getFullAlbum(album),
        baseEntity: album,
        builder: (album) => Scaffold(
            appBar: createAppBar(
              album.name,
              subtitle: album.artist.name,
              backgroundColor: spotifyGreen,
              actions: [
                ScrobbleButton(entity: album),
              ],
            ),
            body: TwoUp(
              entity: album,
              listItems: [
                ListTile(
                    leading: EntityImage(entity: album.artist),
                    title: Text(album.artist.name),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SpotifyArtistView(artist: album.artist)));
                    }),
                if (album.tracks.isNotEmpty) ...[
                  const Divider(),
                  EntityDisplay<SAlbumTrack>(
                    items: album.tracks,
                    scrollable: false,
                    displayNumbers: true,
                    displayImages: false,
                    scrobbleableEntity: (track) => Future.value(track),
                  ),
                ],
              ],
            )),
      );
}
