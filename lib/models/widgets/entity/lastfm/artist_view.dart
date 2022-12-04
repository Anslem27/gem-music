import 'package:flutter/material.dart';
import 'package:gem/models/widgets/entity/lastfm/profile_stack.dart';
import 'package:gem/models/widgets/entity/lastfm/scoreboard.dart';
import 'package:gem/models/widgets/entity/lastfm/tag_chips.dart';
import 'package:gem/models/widgets/entity/lastfm/track_view.dart';
import 'package:gem/models/widgets/entity/lastfm/wiki_view.dart';
import 'package:share_plus/share_plus.dart';

import '../../../services/generic.dart';
import '../../../services/lastfm/artist.dart';
import '../../../services/lastfm/lastfm.dart';
import '../../base/app_bar.dart';
import '../../base/fractional_bar.dart';
import '../../base/future_builder_view.dart';
import '../../base/two_up.dart';
import '../artist_tabs.dart';
import '../entity_display.dart';
import 'album_view.dart';

class ArtistView extends StatelessWidget {
  final BasicArtist artist;

  const ArtistView({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    final friendUsername = ProfileStack.of(context).friendUsername;
    return FutureBuilderView<LArtist>(
      futureFactory: artist is LArtist
          ? () => Future.value(artist as LArtist)
          : () => Lastfm.getArtist(artist),
      baseEntity: artist,
      builder: (artist) => Scaffold(
        appBar: createAppBar(
          artist.name,
          actions: [
            IconButton(
              icon: Icon(Icons.adaptive.share),
              onPressed: () {
                Share.share(artist.url);
              },
            ),
          ],
        ),
        body: TwoUp(
          entity: artist,
          listItems: [
            Scoreboard(statistics: {
              'Scrobbles': artist.stats.playCount,
              'Listeners': artist.stats.listeners,
              'Your scrobbles': artist.stats.userPlayCount,
              if (friendUsername != null)
                "$friendUsername's scrobbles":
                    Lastfm.getArtist(artist, username: friendUsername)
                        .then((value) => value.stats.userPlayCount),
            }),
            if (artist.topTags.tags.isNotEmpty) ...[
              const Divider(),
              TagChips(topTags: artist.topTags),
            ],
            if (artist.bio != null && artist.bio!.isNotEmpty) ...[
              const Divider(),
              WikiTile(entity: artist, wiki: artist.bio!),
            ],
            const Divider(),
            ArtistTabs(
              albumsWidget: EntityDisplay<LArtistTopAlbum>(
                scrollable: false,
                request: ArtistGetTopAlbumsRequest(artist.name),
                detailWidgetBuilder: (album) => AlbumView(album: album),
              ),
              tracksWidget: EntityDisplay<LArtistTopTrack>(
                scrollable: false,
                request: ArtistGetTopTracksRequest(artist.name),
                detailWidgetBuilder: (track) => TrackView(track: track),
              ),
              similarArtistsWidget: FutureBuilderView<List<LSimilarArtist>>(
                futureFactory: () => Lastfm.getSimilarArtists(artist),
                baseEntity: artist,
                isView: false,
                builder: (items) => EntityDisplay<LSimilarArtist>(
                  scrollable: false,
                  items: items,
                  detailWidgetBuilder: (artist) => ArtistView(artist: artist),
                  subtitleWidgetBuilder: (artist, _) =>
                      FractionalBar(artist.similarity),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
