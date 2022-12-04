import 'package:flutter/material.dart';
import 'package:gem/models/widgets/entity/spotify/spotify_album_view.dart';

import '../../../services/spotify/album.dart';
import '../../../services/spotify/artist.dart';
import '../../../services/spotify/spotify.dart';
import '../../../services/spotify/track.dart';
import '../../../util/constants.dart';
import '../../base/app_bar.dart';
import '../../base/future_builder_view.dart';
import '../../base/two_up.dart';
import '../artist_tabs.dart';
import '../entity_display.dart';

class SpotifyArtistView extends StatelessWidget {
  final dynamic /* SArtist|SArtistSimple */ artist;

  const SpotifyArtistView({super.key, required this.artist})
      : assert(artist is SArtist || artist is SArtistSimple);

  @override
  Widget build(BuildContext context) => FutureBuilderView<SArtist>(
        futureFactory: artist is SArtist
            ? () => Future.value(artist)
            : () => Spotify.getFullArtist(artist),
        baseEntity: artist,
        builder: (artist) => Scaffold(
          appBar: createAppBar(
            artist.name,
            backgroundColor: spotifyGreen,
          ),
          body: TwoUp(
            entity: artist,
            listItems: [
              ArtistTabs(
                color: spotifyGreen,
                albumsWidget: EntityDisplay<SAlbumSimple>(
                  scrollable: false,
                  request: SArtistAlbumsRequest(artist),
                  detailWidgetBuilder: (album) =>
                      SpotifyAlbumView(album: album),
                ),
                tracksWidget: FutureBuilderView<List<STrack>>(
                  futureFactory: () => Spotify.getTopTracksForArtist(artist),
                  baseEntity: artist,
                  isView: false,
                  builder: (tracks) => EntityDisplay<STrack>(
                    scrollable: false,
                    items: tracks,
                    scrobbleableEntity: (track) => Future.value(track),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
