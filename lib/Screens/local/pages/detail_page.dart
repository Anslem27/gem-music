import 'package:audio_service/audio_service.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import '../../../widgets/add_playlist.dart';
import '../../../widgets/gradient_containers.dart';
import '../../../widgets/like_button.dart';
import '../../../widgets/miniplayer.dart';
import '../../../Helpers/add_mediaitem_to_queue.dart';
import '../../../Helpers/local_music_functions.dart';
import '../../Player/music_player.dart';

// list tile for song options
ListTile _sheetTile(String title, Function()? ontap, IconData icon) {
  return ListTile(
    leading: Icon(icon),
    title: Text(title),
    onTap: ontap,
  );
}

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
    getArtistAlbums();
    super.initState();
  }

  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  List<AlbumModel> getAlbums = [];

  getArtistAlbums() async {
    getAlbums = await offlineAudioQuery.getAlbums();
    setState(() {});
    return getAlbums;
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
        child: SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            CustomScrollView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              slivers: [
                _sliverTopBar(expandedHeight, rotated, boxSize),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      // page body

                      _songWidget(boxSize),

                      getAlbums.isEmpty || widget.certainCase == "artist"
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(10, 10, 0, 0),
                                      child: Text(
                                        "ALBUMS",
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: boxSize + 15,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: getAlbums.length,
                                      itemBuilder: (_, index) {
                                        return GestureDetector(
                                          onTap: () async {
                                            var albumSongs =
                                                await offlineAudioQuery
                                                    .getAlbumSongs(
                                                        getAlbums[index].id);

                                            Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                builder: (_) =>
                                                    LocalMusicsDetail(
                                                  title: getAlbums[index].album,
                                                  id: getAlbums[index].id,
                                                  certainCase: 'album',
                                                  songs: albumSongs,
                                                ),
                                              ),
                                            );
                                          },
                                          child: widget.title ==
                                                  getAlbums[index].artist
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      QueryArtworkWidget(
                                                        id: getAlbums[index].id,
                                                        type: ArtworkType.ALBUM,
                                                        artworkHeight:
                                                            boxSize - 35,
                                                        artworkWidth:
                                                            boxSize - 40,
                                                        artworkBorder:
                                                            BorderRadius
                                                                .circular(7.0),
                                                        nullArtworkWidget:
                                                            ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      7.0),
                                                          child: Image(
                                                            fit: BoxFit.cover,
                                                            height:
                                                                boxSize - 35,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                2.5,
                                                            image: const AssetImage(
                                                                'assets/cover.jpg'),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 8.0,
                                                                vertical: 5),
                                                        child: Text(
                                                          getAlbums[index]
                                                              .album,
                                                          textAlign:
                                                              TextAlign.center,
                                                          softWrap: false,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              : const SizedBox(
                                                  height: 0, width: 0),
                                        );
                                      }),
                                ),
                              ],
                            )
                          : const SizedBox(height: 0, width: 0),
                    ],
                  ),
                ),
              ],
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: MiniPlayer(),
            )
          ],
        ),
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
            widget.certainCase == "album" && index == 0
                ? Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                    child: ListTile(
                      onTap: () async {
                        OfflineAudioQuery offlineAudioQuery =
                            OfflineAudioQuery();
                        var albumSongs =
                            await offlineAudioQuery.getArtistsByName(
                                widget.songs[index].artist as String);

                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => LocalMusicsDetail(
                              title: albumSongs[index].artist as String,
                              id: albumSongs[index].id,
                              certainCase: 'artist',
                              songs: albumSongs,
                            ),
                          ),
                        );
                      },
                      leading: const CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage("assets/artist.png"),
                      ),
                      title: Text(
                          "by ${widget.songs[index].artist!.toUpperCase()}"),
                      subtitle: Text(
                        "${widget.songs.length} ${widget.songs.length < 2 ? "Song" : "Songs"}",
                      ),
                    ),
                  )
                : const SizedBox(width: 0, height: 0),
            widget.certainCase == "genre" && index == 0 ||
                    widget.certainCase == "artist" && index == 0
                ? Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                        child: Text(
                          "SONGS",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                width: 1,
                                color: Theme.of(context).colorScheme.secondary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            final tempList = widget.songs.toList();
                            tempList.shuffle();
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                opaque: false,
                                pageBuilder: (_, __, ___) => PlayScreen(
                                  songsList: tempList,
                                  index: 0,
                                  offline: true,
                                  fromMiniplayer: false,
                                  fromDownloads: false,
                                  recommend: false,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(EvaIcons.shuffle2),
                          label: const Text(
                            "Shuffle",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                      //   child: Text(
                      //     "${widget.songs.length} ${widget.songs.length < 2 ? "Song" : "Songs"}",
                      //     style:
                      //         const TextStyle(fontSize: 15, color: Colors.grey),
                      //   ),
                      // ),
                    ],
                  )
                : const SizedBox(height: 0, width: 0),
            widget.certainCase == "album" && index == 0
                ? Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                        child: Text(
                          "SONGS",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                width: 1,
                                color: Theme.of(context).colorScheme.secondary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            final tempList = widget.songs.toList();
                            tempList.shuffle();
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                opaque: false,
                                pageBuilder: (_, __, ___) => PlayScreen(
                                  songsList: tempList,
                                  index: 0,
                                  offline: true,
                                  fromMiniplayer: false,
                                  fromDownloads: false,
                                  recommend: false,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(EvaIcons.shuffle2),
                          label: const Text(
                            "Shuffle",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox(height: 0, width: 0),
            const SizedBox(height: 5),
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
                          style: const TextStyle(fontSize: 17),
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
                        children: [
                          IconButton(
                            splashRadius: 24,
                            padding: const EdgeInsets.only(bottom: 20),
                            onPressed: () async {
                              await detailedMusicBottomSheet(context, index);
                            },
                            icon: const Icon(EvaIcons.moreVerticalOutline),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            // const SizedBox(height: 15),
          ],
        );
      },
    );
  }

  detailedMusicBottomSheet(BuildContext context, int index) async {
    showModalBottomSheet(
      isDismissible: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        String playTitle = widget.songs[index].title;
        playTitle == ''
            ? playTitle = widget.songs[index].displayNameWOExt
            : playTitle = widget.songs[index].title;
        String playArtist = widget.songs[index].artist!;
        playArtist == '<unknown>'
            ? playArtist = 'Unknown'
            : playArtist = widget.songs[index].artist!;

        final String playAlbum = widget.songs[index].album!;
        final int playDuration = widget.songs[index].duration ?? 180000;
        final String imagePath =
            '$tempPath/${widget.songs[index].displayNameWOExt}.png';

        final MediaItem mediaItem = MediaItem(
          id: widget.songs[index].id.toString(),
          album: playAlbum,
          duration: Duration(milliseconds: playDuration),
          title: playTitle.split('(')[0],
          artist: playArtist,
          genre: widget.songs[index].genre,
          artUri: Uri.file(imagePath),
          extras: {
            'url': widget.songs[index].data,
            'date_added': widget.songs[index].dateAdded,
            'date_modified': widget.songs[index].dateModified,
            'size': widget.songs[index].size,
            'year': widget.songs[index].getMap['year'],
          },
        );
        return BottomGradientContainer(
          borderRadius: BorderRadius.circular(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListTile(
                  leading: QueryArtworkWidget(
                    id: widget.songs[index].id,
                    type: ArtworkType.AUDIO,
                    artworkHeight: 50,
                    artworkWidth: 50,
                    artworkBorder: BorderRadius.circular(7.0),
                    nullArtworkWidget: ClipRRect(
                      borderRadius: BorderRadius.circular(7.0),
                      child: const Image(
                        fit: BoxFit.cover,
                        height: 50,
                        width: 50,
                        image: AssetImage('assets/song.png'),
                      ),
                    ),
                  ),
                  title: Text(
                    widget.songs[index].title.toUpperCase(),
                    textAlign: TextAlign.start,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  subtitle: Text(
                    widget.songs[index].artist as String,
                    textAlign: TextAlign.start,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  trailing: LikeButton(mediaItem: mediaItem),
                ),
              ),
              _sheetTile("Play Next", () {
                playOfflineNext(mediaItem, context);
              }, EvaIcons.playCircleOutline),
              _sheetTile("Add to queue", () {
                addOfflineToNowPlaying(context: context, mediaItem: mediaItem);
              }, EvaIcons.fileAdd),
              _sheetTile("Add to playlist", () {
                AddToOffPlaylist().addToOffPlaylist(
                  context,
                  widget.songs[index].id,
                );
              }, Iconsax.music_playlist),
              _sheetTile("View Album", () async {
                var albumSongs = await offlineAudioQuery
                    .getAlbumSongs(widget.songs[index].albumId as int);

                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => LocalMusicsDetail(
                      title: widget.songs[index].album as String,
                      id: widget.songs[index].id,
                      certainCase: 'album',
                      songs: albumSongs,
                    ),
                  ),
                ).then((value) => Navigator.pop(context));
              }, Icons.album_outlined),
              _sheetTile("View Artist", () async {
                var albumSongs = await offlineAudioQuery
                    .getArtistsByName(widget.songs[index].artist as String);

                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => LocalMusicsDetail(
                      title: widget.songs[index].artist as String,
                      id: widget.songs[index].id,
                      certainCase: 'artist',
                      songs: albumSongs,
                    ),
                  ),
                ).then((value) => Navigator.pop(context));
              }, EvaIcons.person),
            ],
          ),
        );
      },
    );
  }

  _sliverTopBar(double expandedHeight, bool rotated, double boxSize) {
    return SliverAppBar(
      elevation: 0,
      stretch: true,
      pinned: true,
      centerTitle: true,
      expandedHeight: expandedHeight,
      actions: widget.actions,
      // title: Opacity(
      //   opacity: 1 - _opacity.value,
      //   child: Text(
      //     title.toUpperCase(),
      //     style: const TextStyle(
      //       fontSize: 17,
      //       fontWeight: FontWeight.w500,
      //     ),
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
            background: GlassmorphicContainer(
              width: double.maxFinite,
              height: double.maxFinite,
              borderRadius: 0,
              blur: 20,
              alignment: Alignment.bottomCenter,
              border: 2,
              linearGradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black,
                    Colors.transparent,
                  ],
                  stops: [
                    0.1,
                    1,
                  ]),
              borderGradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.transparent, Colors.transparent],
              ),
              child: Stack(
                children: [
                  if (!rotated)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12.0, horizontal: 8),
                                      child: SizedBox(
                                        height: boxSize - 30,
                                        width: boxSize - 30,
                                        child: QueryArtworkWidget(
                                          id: widget.id,
                                          artworkBorder:
                                              BorderRadius.circular(0),
                                          type: widget.certainCase == "album"
                                              ? ArtworkType.ALBUM
                                              : widget.certainCase == "artist"
                                                  ? ArtworkType.ARTIST
                                                  : ArtworkType.GENRE,
                                          artworkWidth: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.5,
                                          nullArtworkWidget: const ClipRRect(
                                            child: Image(
                                              fit: BoxFit.cover,
                                              image: AssetImage(
                                                  'assets/artist.png'),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: ListTile(
                                        title: Text(
                                          widget.title.trim(),
                                          style: GoogleFonts.ubuntu(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text(
                                          "${widget.songs.length} ${widget.songs.length < 2 ? "Song" : "Songs"}",
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                          ),
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
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
                          height: MediaQuery.of(context).size.height * 0.35,
                          width: 200,
                          child: QueryArtworkWidget(
                            id: widget.id,
                            type: widget.certainCase == "album"
                                ? ArtworkType.ALBUM
                                : widget.certainCase == "artist"
                                    ? ArtworkType.ARTIST
                                    : ArtworkType.GENRE,
                            artworkWidth:
                                MediaQuery.of(context).size.width / 2.5,
                            artworkBorder: BorderRadius.circular(8),
                            nullArtworkWidget: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
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
            ),
          );
        },
      ),
    );
  }
}
