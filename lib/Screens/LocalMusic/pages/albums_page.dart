// ignore_for_file: non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gem/CustomWidgets/gradient_containers.dart';
import 'package:gem/Helpers/local_music_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'detail_page.dart';

class LocalAlbumsPage extends StatefulWidget {
  const LocalAlbumsPage({super.key});

  @override
  State<LocalAlbumsPage> createState() => _LocalAlbumsPageState();
}

class _LocalAlbumsPageState extends State<LocalAlbumsPage> {
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  List<AlbumModel> local_albums = [];
  List<SongModel> album_songs = [];
  bool loading = false;

  Future<void> fetchAlbums() async {
    await offlineAudioQuery.requestPermission();
    local_albums =
        await offlineAudioQuery.getAlbums(sortType: AlbumSortType.ALBUM);
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
            ? const Center(child: CircularProgressIndicator())
            : albumBody(boxSize, context),
      ),
    );
  }

  albumBody(double boxSize, BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Text(
                "${local_albums.length} ALBUMS",
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: StaggeredGridView.countBuilder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            itemCount: local_albums.length,
            itemBuilder: (_, index) {
              return GestureDetector(
                onTap: () async {
                  var album_songs = await offlineAudioQuery
                      .getAlbumSongs(local_albums[index].id);

                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => LocalMusicsDetail(
                        title: local_albums[index].album,
                        id: local_albums[index].id,
                        certainCase: 'album',
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
                              id: local_albums[index].id,
                              type: ArtworkType.ALBUM,
                              artworkHeight: boxSize - 15,
                              artworkWidth:
                                  MediaQuery.of(context).size.width / 2.5,
                              artworkBorder: BorderRadius.circular(7.0),
                              nullArtworkWidget: ClipRRect(
                                borderRadius: BorderRadius.circular(7.0),
                                child: Image(
                                  fit: BoxFit.cover,
                                  height: boxSize - 35,
                                  width:
                                      MediaQuery.of(context).size.width / 2.5,
                                  image: const AssetImage('assets/cover.jpg'),
                                ),
                              )),
                          Expanded(
                            child: ListTile(
                              title: Text(
                                local_albums[index].album,
                                textAlign: TextAlign.center,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              subtitle: Text(
                                local_albums[index].numOfSongs == 1
                                    ? "${local_albums[index].numOfSongs} song"
                                    : "${local_albums[index].numOfSongs} songs",
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
              return const StaggeredTile.count(1, 1.25);
            },
          ),
        )
      ],
    );
  }
}
