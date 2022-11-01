// ignore_for_file: non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gem/CustomWidgets/gradient_containers.dart';
import 'package:gem/Screens/LocalMusic/pages/detail_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../../../Helpers/local_music_functions.dart';

class LocalArtistsPage extends StatefulWidget {
  const LocalArtistsPage({super.key});

  @override
  State<LocalArtistsPage> createState() => _LocalArtistsPageState();
}

class _LocalArtistsPageState extends State<LocalArtistsPage> {
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  List<ArtistModel> local_artists = [];
  bool loading = false;

  Future<void> fetchAlbums() async {
    await offlineAudioQuery.requestPermission();
    local_artists = await offlineAudioQuery.getArtists();

    setState(() {
      loading = true;
    });
  }

  @override
  void initState() {
    fetchAlbums();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.height / 2.5;
    return GradientContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: loading == false
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    child: StaggeredGridView.countBuilder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      itemCount: local_artists.length,
                      itemBuilder: (_, index) {
                        return GestureDetector(
                          onTap: () async {
                            var album_songs = await offlineAudioQuery
                                .getArtistSongs(local_artists[index].id);

                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (_) => LocalMusicsDetail(
                                  title: local_artists[index].artist,
                                  id: local_artists[index].id,
                                  certainCase: 'artist',
                                  songs: album_songs,
                                ),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              Card(
                                color: Colors.transparent,
                                elevation: 0,
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    QueryArtworkWidget(
                                      id: local_artists[index].id,
                                      type: ArtworkType.ARTIST,
                                      artworkHeight: boxSize - 35,
                                      artworkWidth:
                                          MediaQuery.of(context).size.width /
                                              2.5,
                                      artworkBorder: BorderRadius.circular(90),
                                      nullArtworkWidget: ClipRRect(
                                        borderRadius: BorderRadius.circular(90),
                                        child: Image(
                                          fit: BoxFit.cover,
                                          height: boxSize - 35,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.5,
                                          image: const AssetImage(
                                              'assets/artist.png'),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: ListTile(
                                        title: Text(
                                          local_artists[index].artist ==
                                                  '<unknown>'
                                              ? "Unknown artist"
                                              : local_artists[index].artist,
                                          textAlign: TextAlign.center,
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.roboto(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        subtitle: Text(
                                          local_artists[index].numberOfTracks ==
                                                  1
                                              ? "${local_artists[index].numberOfTracks} song"
                                              : "${local_artists[index].numberOfTracks} songs",
                                          textAlign: TextAlign.center,
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.roboto(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                      staggeredTileBuilder: (int index) {
                        return const StaggeredTile.count(1, 1.2);
                      },
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
