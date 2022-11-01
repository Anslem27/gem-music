import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import '../../../CustomWidgets/add_playlist.dart';
import '../../../CustomWidgets/gradient_containers.dart';
import '../../../CustomWidgets/miniplayer.dart';
import '../../../Helpers/local_music_functions.dart';
import '../../Player/audioplayer_page.dart';

class LocalMusicsDetail extends StatefulWidget {
  final List<Widget>? actions;
  final List<SongModel> songs;
  final String certainCase; //album, artist,genre
  final String title;
  final int id;
  const LocalMusicsDetail(
      {super.key,
      this.actions,
      required this.title,
      required this.id,
      required this.songs,
      required this.certainCase});

  @override
  State<LocalMusicsDetail> createState() => _LocalMusicsDetailState();
}

class _LocalMusicsDetailState extends State<LocalMusicsDetail> {
  final ValueNotifier<double> _opacity = ValueNotifier<double>(1.0);
  String? tempPath = Hive.box('settings').get('tempDirPath')?.toString();

  @override
  void initState() {
    getTempPath();
    super.initState();
  }

  Future<void> getTempPath() async {
    tempPath ??= (await getTemporaryDirectory()).path;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool rotated =
        MediaQuery.of(context).size.height < MediaQuery.of(context).size.width;
    final double expandedHeight = MediaQuery.of(context).size.height * 0.4;
    double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.height / 2.5;

    return GradientContainer(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _sliverTopBar(expandedHeight, rotated),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const MiniPlayer(),
                // page body
                _songWidget(boxSize),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  _songWidget(double boxSize) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.songs.length,
      itemBuilder: (context, index) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {});
                Navigator.of(context).push(
                  PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (_, __, ___) => PlayScreen(
                      songsList: widget.songs,
                      index: index,
                      offline: true,
                      fromDownloads: false,
                      fromMiniplayer: false,
                      recommend: false,
                    ),
                  ),
                );
              },
              child: SizedBox(
                height: boxSize - 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OfflineAudioQuery.offlineArtworkWidget(
                      id: widget.songs[index].id,
                      type: ArtworkType.AUDIO,
                      height: 70,
                      width: 70,
                      fileName: widget.songs[index].displayNameWOExt,
                      tempPath: tempPath!,
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text(
                          widget.songs[index].title.trim() != ''
                              ? widget.songs[index].title
                              : widget.songs[index].displayNameWOExt,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.roboto(fontSize: 17),
                        ),
                        subtitle: Text(
                          widget.songs[index].album
                                  ?.replaceAll('<unknown>', 'Unknown') ??
                              'Unknown',
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 3.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PopupMenuButton(
                            splashRadius: 24,
                            icon: const Icon(
                              Icons.more_horiz_rounded,
                              color: Colors.grey,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                            ),
                            onSelected: (int? value) async {
                              if (value == 0) {
                                AddToOffPlaylist().addToOffPlaylist(
                                  context,
                                  widget.songs[index].id,
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 0,
                                child: Row(
                                  children: const [
                                    Icon(Icons.playlist_add_rounded),
                                    SizedBox(width: 10.0),
                                    Text(
                                      'Add to Playlist',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            splashRadius: 24,
                            onPressed: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  opaque: false,
                                  pageBuilder: (_, __, ___) => PlayScreen(
                                    songsList: widget.songs,
                                    index: index,
                                    offline: true,
                                    fromDownloads: false,
                                    fromMiniplayer: false,
                                    recommend: false,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              MdiIcons.playCircleOutline,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  _sliverTopBar(double expandedHeight, bool rotated) {
    return SliverAppBar(
      elevation: 0,
      stretch: true,
      pinned: true,
      centerTitle: true,
      expandedHeight: 250,
      actions: widget.actions,
      // title: Opacity(
      //   opacity: 1 - _opacity.value,
      //   child: Text(
      //     widget.title,
      //   ),
      // ),
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double top = constraints.biggest.height;
          if (top > expandedHeight) {
            top = expandedHeight;
          }
          _opacity.value = (top - 80) / (expandedHeight - 80);

          return FlexibleSpaceBar(
            title: Opacity(
              opacity: max(0, _opacity.value),
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            centerTitle: true,
            background: Stack(
              children: [
                SizedBox.expand(
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return const LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black,
                          Colors.transparent,
                        ],
                      ).createShader(
                        Rect.fromLTRB(
                          0,
                          0,
                          rect.width,
                          rect.height,
                        ),
                      );
                    },
                    blendMode: BlendMode.dstIn,
                    child: QueryArtworkWidget(
                      id: widget.id,
                      type: widget.certainCase == "album"
                          ? ArtworkType.ALBUM
                          : widget.certainCase == "artist"
                              ? ArtworkType.ARTIST
                              : ArtworkType.GENRE,
                      artworkWidth: MediaQuery.of(context).size.width / 2.5,
                      nullArtworkWidget: const ClipRRect(
                        child: Image(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/artist.png'),
                        ),
                      ),
                    ),
                  ),
                ),
                if (rotated)
                  Align(
                    alignment: const Alignment(-0.85, 0.5),
                    child: Card(
                      elevation: 5,
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: QueryArtworkWidget(
                          id: widget.id,
                          type: widget.certainCase == "album"
                              ? ArtworkType.ALBUM
                              : widget.certainCase == "artist"
                                  ? ArtworkType.ARTIST
                                  : ArtworkType.GENRE,
                          artworkWidth: MediaQuery.of(context).size.width / 2.5,
                          artworkBorder: BorderRadius.circular(90),
                          nullArtworkWidget: ClipRRect(
                            borderRadius: BorderRadius.circular(90),
                            child: Image(
                              fit: BoxFit.cover,
                              image: AssetImage(
                                widget.certainCase == "artist"
                                    ? 'assets/artist.png'
                                    : widget.certainCase == "album"
                                        ? 'assets/album.png'
                                        : 'assets/genre.png',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
