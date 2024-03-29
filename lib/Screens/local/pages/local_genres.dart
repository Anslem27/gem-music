// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously
import 'dart:math' as math;
// import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../widgets/gradient_containers.dart';
import '../../../Helpers/local_music_functions.dart';
import 'detail_page.dart';

class LocalGenresPage extends StatefulWidget {
  const LocalGenresPage({super.key});

  @override
  State<LocalGenresPage> createState() => _LocalGenresPageState();
}

class _LocalGenresPageState extends State<LocalGenresPage> {
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  OnAudioQuery onAudioQuery = OnAudioQuery();
  List<GenreModel> local_genres = [];
  bool loading = false;

  Future<void> fetchAlbums() async {
    await offlineAudioQuery.requestPermission();
    local_genres = await offlineAudioQuery.getGenres();

    setState(() {
      loading = true;
    });
  }

  // Future<Uint8List?> getArt(int id) async {
  //   await onAudioQuery.queryArtwork(id, ArtworkType.GENRE);
  // }

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
            : genreBody(boxSize, context),
      ),
    );
  }

  genreBody(double boxSize, BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Text(
                "${local_genres.length} GENRES",
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: GridView.builder(
            itemCount: local_genres.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 4, childAspectRatio: 1.8),
            itemBuilder: (_, index) {
              return GestureDetector(
                onTap: () async {
                  var album_songs = await offlineAudioQuery
                      .getGenreSongs(local_genres[index].id);

                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => LocalMusicsDetail(
                        title: local_genres[index].genre,
                        id: local_genres[index].id,
                        certainCase: 'genre', //genre
                        songs: album_songs,
                      ),
                    ),
                  );
                },
                child: GlassmorphicContainer(
                  margin: const EdgeInsets.all(5),
                  width: double.maxFinite,
                  height: boxSize - 60,
                  borderRadius: 8,
                  blur: 20,
                  alignment: Alignment.bottomCenter,
                  border: 2,
                  linearGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFffffff).withOpacity(0.1),
                        const Color(0xFFFFFFFF).withOpacity(0.05),
                      ],
                      stops: const [
                        0.1,
                        1,
                      ]),
                  borderGradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.transparent, Colors.transparent],
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Transform.rotate(
                            angle: -math.pi / 9,
                            child: QueryArtworkWidget(
                              id: local_genres[index].id,
                              type: ArtworkType.GENRE,
                              artworkHeight: boxSize - 110,
                              artworkWidth:
                                  MediaQuery.of(context).size.width / 5,
                              artworkBorder: BorderRadius.circular(7.0),
                              nullArtworkWidget: ClipRRect(
                                borderRadius: BorderRadius.circular(7.0),
                                child: Image(
                                  fit: BoxFit.cover,
                                  height: boxSize - 55,
                                  width:
                                      MediaQuery.of(context).size.width / 2.5,
                                  image: const AssetImage('assets/cover.jpg'),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListTile(
                          title: Text(
                            local_genres[index].genre.toUpperCase(),
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                              "${local_genres[index].numOfSongs} ${local_genres[index].numOfSongs > 1 ? "Songs" : "Song"}"),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
