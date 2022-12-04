import 'package:flutter/material.dart';

import '../../../services/spotify/playlist.dart';
import '../../../services/spotify/spotify.dart';
import '../../../services/spotify/track.dart';
import '../../../util/constants.dart';
import '../../base/app_bar.dart';
import '../../base/scrobble_button.dart';
import '../../base/two_up.dart';
import '../entity_display.dart';

class SpotifyPlaylistView extends StatelessWidget {
  final SPlaylistSimple playlist;

  const SpotifyPlaylistView({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: createAppBar(
          playlist.name,
          backgroundColor: spotifyGreen,
          actions: [
            if (playlist.isNotEmpty)
              ScrobbleButton(
                  entityProvider: () => Spotify.getFullPlaylist(playlist)),
          ],
        ),
        body: TwoUp(
          entity: playlist,
          listItems: [
            EntityDisplay<STrack>(
              request: SPlaylistTracksRequest(playlist),
              scrollable: false,
              scrobbleableEntity: (track) => Future.value(track),
            ),
          ],
        ),
      );
}
