// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:gem/widgets/like_button.dart';
import 'package:gem/animations/custompageroute.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path_provider/path_provider.dart';
import '../../../widgets/add_playlist.dart';
import '../../../widgets/gradient_containers.dart';
import '../../../Helpers/add_mediaitem_to_queue.dart';
import '../../../Helpers/local_music_functions.dart';
import '../../Player/music_player.dart';
import '../../local/pages/albums_page.dart';
import '../../local/pages/detail_page.dart';
import '../../local/pages/local_genres.dart';

//title header component with actions

Row _homeTitleComponent(String title, Function()? ontap, Icon? icon) {
  return Row(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      const Spacer(),
      IconButton(
        splashRadius: 24,
        onPressed: ontap,
        icon: icon ?? const SizedBox(),
      )
    ],
  );
}

// list tile for song options
ListTile _sheetTile(String title, Function()? ontap, IconData icon) {
  return ListTile(
    leading: Icon(icon),
    title: Text(title),
    onTap: ontap,
  );
}

//gridview widget for all local songs
class SongGrid extends StatefulWidget {
  const SongGrid({super.key});

  @override
  State<SongGrid> createState() => _SongGridState();
}

class _SongGridState extends State<SongGrid> {
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  List<SongModel> recntly_added = [];
  bool loading = false;

  Future<void> fetchSongs() async {
    await offlineAudioQuery.requestPermission();
    recntly_added = await offlineAudioQuery.getSongs(
      sortType: SongSortType.DATE_ADDED,
    );

    setState(() {
      loading = true;
    });
  }

  @override
  void initState() {
    fetchSongs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.height / 2.5;
    return SizedBox(
      height: boxSize - 20,
      width: boxSize - 30,
      child: GridView.count(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        crossAxisCount: recntly_added.length < 3 ? 1 : 2,
        children: recntly_added
            .take(4)
            .map(
              (image) => QueryArtworkWidget(
                id: image.id,
                type: ArtworkType.AUDIO,
                // artworkHeight: boxSize - 35,
                // artworkWidth: boxSize - 40,
                artworkBorder: BorderRadius.circular(0.0),
                nullArtworkWidget: ClipRRect(
                  borderRadius: BorderRadius.circular(0.0),
                  child: Image(
                    fit: BoxFit.cover,
                    height: boxSize - 35,
                    width: MediaQuery.of(context).size.width / 2.5,
                    image: const AssetImage('assets/album.png'),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

//playlist collage component
class PlaylistCollage extends StatefulWidget {
  final int playlistId;

  const PlaylistCollage({super.key, required this.playlistId});

  @override
  State<PlaylistCollage> createState() => _PlaylistCollageState();
}

class _PlaylistCollageState extends State<PlaylistCollage> {
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  List<SongModel> queriedPlaylist = [];
  bool loading = false;

  Future<void> fetchSongs() async {
    await offlineAudioQuery.requestPermission();
    queriedPlaylist =
        await offlineAudioQuery.getPlaylistSongs(widget.playlistId);
    setState(() {
      loading = true;
    });
  }

  @override
  void initState() {
    fetchSongs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.height / 2.5;
    return queriedPlaylist.length < 3
        ? QueryArtworkWidget(
            id: widget.playlistId,
            type: ArtworkType.ARTIST,
            artworkHeight: boxSize - 20,
            artworkWidth: boxSize - 30,
            artworkBorder: BorderRadius.circular(8.0),
            nullArtworkWidget: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image(
                fit: BoxFit.cover,
                height: boxSize - 35,
                width: MediaQuery.of(context).size.width / 2.5,
                image: const AssetImage('assets/album.png'),
              ),
            ),
          )
        : SizedBox(
            height: boxSize - 25,
            width: boxSize - 30,
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              children: queriedPlaylist
                  .take(4)
                  .map(
                    (image) => QueryArtworkWidget(
                      id: image.id,
                      type: ArtworkType.AUDIO,
                      // artworkHeight: boxSize - 35,
                      // artworkWidth: boxSize - 40,
                      artworkBorder: BorderRadius.circular(0.0),
                      nullArtworkWidget: ClipRRect(
                        borderRadius: BorderRadius.circular(0.0),
                        child: Image(
                          fit: BoxFit.cover,
                          height: boxSize - 35,
                          width: MediaQuery.of(context).size.width / 2.5,
                          image: const AssetImage('assets/album.png'),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
  }
}

//local playlist collage

class LocalPlayListCollage extends StatefulWidget {
  const LocalPlayListCollage({super.key});

  @override
  State<LocalPlayListCollage> createState() => _LocalPlayListCollageState();
}

class _LocalPlayListCollageState extends State<LocalPlayListCollage> {
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  List<PlaylistModel> localPlaylists = [];
  String? tempPath = Hive.box('settings').get('tempDirPath')?.toString();
  bool loading = false;

  Future<void> fetchSongs() async {
    await offlineAudioQuery.requestPermission();
    localPlaylists = await offlineAudioQuery.getPlaylists();
    tempPath ??= (await getTemporaryDirectory()).path;

    setState(() {
      loading = true;
    });
  }

  @override
  void initState() {
    fetchSongs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.height / 2.5;
    return SizedBox(
      height: boxSize - 20,
      width: boxSize - 30,
      child: localPlaylists.isNotEmpty
          ? GridView.count(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              crossAxisCount: localPlaylists.length < 3 ? 1 : 2,
              children: localPlaylists
                  .take(4)
                  .map(
                    (image) => QueryArtworkWidget(
                      id: image.id,
                      type: ArtworkType.PLAYLIST,
                      // artworkHeight: boxSize - 35,
                      // artworkWidth: boxSize - 40,
                      artworkBorder: BorderRadius.circular(0.0),
                      nullArtworkWidget: ClipRRect(
                        borderRadius: BorderRadius.circular(0.0),
                        child: Image(
                          fit: BoxFit.cover,
                          height: boxSize - 35,
                          width: MediaQuery.of(context).size.width / 2.5,
                          image: const AssetImage('assets/album.png'),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            )
          : SizedBox(
              height: boxSize - 20,
              width: boxSize - 30,
              child: Image.asset("assets/file_playlist.png"),
            ),
    );
  }
}

class RecentlyAddedSongs extends StatefulWidget {
  const RecentlyAddedSongs({super.key});

  @override
  State<RecentlyAddedSongs> createState() => _RecentlyAddedSongsState();
}

class _RecentlyAddedSongsState extends State<RecentlyAddedSongs> {
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  List<SongModel> recntly_added = [];
  bool loading = false;
  String? tempPath = Hive.box('settings').get('tempDirPath')?.toString();
  Future<void> fetchSongs() async {
    await offlineAudioQuery.requestPermission();
    recntly_added = await offlineAudioQuery.getSongs(
      sortType: SongSortType.DATE_ADDED,
    );
    tempPath ??= (await getTemporaryDirectory()).path;

    setState(() {
      loading = true;
    });
  }

  @override
  void initState() {
    fetchSongs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.height / 2.5;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _homeTitleComponent("RECENTLY ADDED", () async {
          final tempList = recntly_added.take(10).toList();
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
        }, const Icon(EvaIcons.shuffle2)),
        SizedBox(
          height: boxSize - 50,
          child: ListView.builder(
            itemCount: recntly_added.take(10).length,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (_, index) {
              //get dorminant color from image rendered
              Future<Color> getdominantColor(
                  ImageProvider imageProvider) async {
                try {
                  final PaletteGenerator paletteGenerator =
                      await PaletteGenerator.fromImageProvider(imageProvider);

                  return paletteGenerator.dominantColor!.color;
                } on TimeoutException {
                  final PaletteGenerator paletteGenerator =
                      await PaletteGenerator.fromImageProvider(
                          const AssetImage("assets/cover.jpg"));

                  return paletteGenerator.dominantColor!.color;
                }
              }

              //set mediaItem
              String playTitle = recntly_added[index].title;
              playTitle == ''
                  ? playTitle = recntly_added[index].displayNameWOExt
                  : playTitle = recntly_added[index].title;
              String playArtist = recntly_added[index].artist!;
              playArtist == '<unknown>'
                  ? playArtist = 'Unknown'
                  : playArtist = recntly_added[index].artist!;

              final String playAlbum = recntly_added[index].album!;
              final int playDuration = recntly_added[index].duration ?? 180000;
              final String imagePath =
                  '$tempPath/${recntly_added[index].displayNameWOExt}.png';

              final MediaItem mediaItem = MediaItem(
                id: recntly_added[index].id.toString(),
                album: playAlbum,
                duration: Duration(milliseconds: playDuration),
                title: playTitle.split('(')[0],
                artist: playArtist,
                genre: recntly_added[index].genre,
                artUri: Uri.file(imagePath),
                extras: {
                  'url': recntly_added[index].data,
                  'date_added': recntly_added[index].dateAdded,
                  'date_modified': recntly_added[index].dateModified,
                  'size': recntly_added[index].size,
                  'year': recntly_added[index].getMap['year'],
                },
              );
              //mediaItem functionality stops here

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                    onLongPress: () async {
                      await recentlyAddedBottomSheet(context, index, mediaItem);
                    },
                    child: FutureBuilder(
                        future: OfflineAudioQuery.queryNSave(
                            fileName: recntly_added[index].displayNameWOExt,
                            tempPath: tempPath!,
                            id: recntly_added[index].id,
                            type: ArtworkType.AUDIO),
                        builder: (_, snapshot) {
                          if (!snapshot.hasData) {
                            return loadingContainer(boxSize);
                          }
                          return FutureBuilder<Color>(
                              future: getdominantColor(
                                FileImage(
                                  File(mediaItem.artUri!.toFilePath()),
                                ),
                              ),
                              builder: (context, colorSnapshot) {
                                if (!colorSnapshot.hasData) {
                                  return loadingContainer(boxSize);
                                }
                                return GlassmorphicContainer(
                                  margin: const EdgeInsets.all(5),
                                  height: boxSize - 50,
                                  width: boxSize + 50,
                                  borderRadius: 8,
                                  blur: 20,
                                  alignment: Alignment.bottomCenter,
                                  border: 2,
                                  linearGradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        colorSnapshot.data!.withOpacity(0.05),
                                        colorSnapshot.data!,
                                      ],
                                      stops: const [
                                        0.1,
                                        1,
                                      ]),
                                  borderGradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.transparent,
                                      Colors.transparent
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: Image(
                                              fit: BoxFit.cover,
                                              image: FileImage(
                                                File(snapshot.data as String),
                                              ),
                                              errorBuilder: (_, __, ___) {
                                                return Image.asset(
                                                  'assets/cover.jpg',
                                                );
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ListTile(
                                              title: Text(
                                                recntly_added[index]
                                                    .title
                                                    .toUpperCase(),
                                                textAlign: TextAlign.center,
                                                softWrap: false,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              subtitle: Text(
                                                recntly_added[index].artist
                                                    as String,
                                                textAlign: TextAlign.center,
                                                softWrap: false,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  splashRadius: 24,
                                                  onPressed: () {
                                                    setState(() {});
                                                    Navigator.of(context).push(
                                                      PageRouteBuilder(
                                                        opaque: false,
                                                        pageBuilder:
                                                            (_, __, ___) =>
                                                                PlayScreen(
                                                          songsList:
                                                              recntly_added,
                                                          index: index,
                                                          offline: true,
                                                          fromDownloads: false,
                                                          fromMiniplayer: false,
                                                          recommend: false,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  icon: const Icon(EvaIcons
                                                      .playCircleOutline),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              });
                        })),
              );
            },
          ),
        ),
      ],
    );
  }

  recentlyAddedBottomSheet(
      BuildContext context, int index, MediaItem mediaItem) async {
    showModalBottomSheet(
      isDismissible: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return BottomGradientContainer(
          borderRadius: BorderRadius.circular(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListTile(
                  leading: QueryArtworkWidget(
                    id: recntly_added[index].id,
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
                    recntly_added[index].title.toUpperCase(),
                    textAlign: TextAlign.start,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  subtitle: Text(
                    recntly_added[index].artist as String,
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
                Navigator.pop(context);
              }, EvaIcons.playCircleOutline),
              _sheetTile("Add to queue", () {
                addOfflineToNowPlaying(context: context, mediaItem: mediaItem);
                Navigator.pop(context);
              }, EvaIcons.fileAdd),
              _sheetTile("Add to playlist", () {
                AddToOffPlaylist().addToOffPlaylist(
                  context,
                  recntly_added[index].id,
                );
              }, Iconsax.music_playlist),
              _sheetTile("View Album", () async {
                var album_songs = await offlineAudioQuery
                    .getAlbumSongs(recntly_added[index].albumId as int);

                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => LocalMusicsDetail(
                      title: recntly_added[index].album as String,
                      id: recntly_added[index].id,
                      certainCase: 'album',
                      songs: album_songs,
                    ),
                  ),
                ).then((value) => Navigator.pop(context));
              }, Icons.album_outlined),
              _sheetTile("View Artist", () async {
                var album_songs = await offlineAudioQuery
                    .getArtistsByName(recntly_added[index].artist as String);

                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => LocalMusicsDetail(
                      title: recntly_added[index].artist as String,
                      id: recntly_added[index].id,
                      certainCase: 'artist',
                      songs: album_songs,
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

  GlassmorphicContainer loadingContainer(double boxSize) {
    return GlassmorphicContainer(
      margin: const EdgeInsets.all(5),
      height: boxSize - 50,
      width: boxSize + 50,
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
      child: null,
    );
  }
}
/* Column(
                      children: [
                        QueryArtworkWidget(
                          id: recntly_added[index].id,
                          type: ArtworkType.AUDIO,
                          artworkHeight: boxSize - 30,
                          artworkWidth: boxSize - 40,
                          artworkBorder: BorderRadius.circular(7.0),
                          nullArtworkWidget: ClipRRect(
                            borderRadius: BorderRadius.circular(7.0),
                            child: Image(
                              fit: BoxFit.cover,
                              height: boxSize - 35,
                              width: MediaQuery.of(context).size.width / 2.5,
                              image: const AssetImage('assets/song.png'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(
                              recntly_added[index].title.toUpperCase(),
                              textAlign: TextAlign.center,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            subtitle: Text(
                              recntly_added[index].artist as String,
                              textAlign: TextAlign.center,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ), */
// home albums at a glance

class HomeAlbums extends StatefulWidget {
  const HomeAlbums({super.key});

  @override
  State<HomeAlbums> createState() => _HomeAlbumsState();
}

class _HomeAlbumsState extends State<HomeAlbums> {
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  List<AlbumModel> home_albums = [];
  bool loading = false;
  late final MediaItem mediaItem;

  Future<void> fetchSongs() async {
    await offlineAudioQuery.requestPermission();
    home_albums = await offlineAudioQuery.getAlbums(
      sortType: AlbumSortType.ALBUM,
    );

    setState(() {
      loading = true;
    });
  }

  @override
  void initState() {
    fetchSongs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.height / 2.5;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _homeTitleComponent(
          "ALBUMS",
          () {
            Navigator.push(
              context,
              FadeTransitionPageRoute(
                  child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  title: const Text("ALBUMS"),
                ),
                body: const LocalAlbumsPage(),
              )),
            );
          },
          const Icon(EvaIcons.arrowRightOutline),
        ),
        SizedBox(
          height: boxSize + 40,
          child: ListView.builder(
            itemCount: home_albums.take(10).length,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (_, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () async {
                    var album_songs = await offlineAudioQuery
                        .getAlbumSongs(home_albums[index].id);

                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => LocalMusicsDetail(
                          title: home_albums[index].album,
                          id: home_albums[index].id,
                          certainCase: 'album',
                          songs: album_songs,
                        ),
                      ),
                    );
                  },
                  child: SizedBox(
                    height: boxSize - 30,
                    width: boxSize - 40,
                    child: Column(
                      children: [
                        QueryArtworkWidget(
                          id: home_albums[index].id,
                          type: ArtworkType.ALBUM,
                          artworkHeight: boxSize - 35,
                          artworkWidth: boxSize - 40,
                          artworkBorder: BorderRadius.circular(7.0),
                          nullArtworkWidget: ClipRRect(
                            borderRadius: BorderRadius.circular(7.0),
                            child: Image(
                              fit: BoxFit.cover,
                              height: boxSize - 35,
                              width: MediaQuery.of(context).size.width / 2.5,
                              image: const AssetImage('assets/album.png'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(
                              home_albums[index].album.toUpperCase(),
                              textAlign: TextAlign.center,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            subtitle: Text(
                              home_albums[index].artist as String,
                              textAlign: TextAlign.center,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

// home genres at a glance

class HomeGenres extends StatefulWidget {
  const HomeGenres({super.key});

  @override
  State<HomeGenres> createState() => _HomeGenresState();
}

class _HomeGenresState extends State<HomeGenres> {
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  List<GenreModel> home_genres = [];
  bool loading = false;

  Future<void> fetchSongs() async {
    await offlineAudioQuery.requestPermission();
    home_genres = await offlineAudioQuery.getGenres(
      sortType: GenreSortType.GENRE,
    );

    setState(() {
      loading = true;
    });
  }

  @override
  void initState() {
    fetchSongs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.height / 2.5;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _homeTitleComponent(
          "YOUR GENRES",
          () {
            Navigator.push(
              context,
              FadeTransitionPageRoute(
                  child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  title: const Text("Genres"),
                ),
                body: const LocalGenresPage(),
              )),
            );
          },
          const Icon(EvaIcons.arrowRightOutline),
        ),
        SizedBox(
          height: boxSize + 20,
          child: ListView.builder(
            itemCount: home_genres.take(10).length,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (_, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () async {
                    var album_songs = await offlineAudioQuery
                        .getGenreSongs(home_genres[index].id);

                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => LocalMusicsDetail(
                          title: home_genres[index].genre,
                          id: home_genres[index].id,
                          certainCase: 'genre', //genre
                          songs: album_songs,
                        ),
                      ),
                    );
                  },
                  child: SizedBox(
                    height: boxSize - 30,
                    width: boxSize - 40,
                    child: Column(
                      children: [
                        QueryArtworkWidget(
                          id: home_genres[index].id,
                          type: ArtworkType.GENRE,
                          artworkHeight: boxSize - 35,
                          artworkWidth: boxSize - 40,
                          artworkBorder: BorderRadius.circular(7.0),
                          nullArtworkWidget: ClipRRect(
                            borderRadius: BorderRadius.circular(7.0),
                            child: Image(
                              fit: BoxFit.cover,
                              height: boxSize - 35,
                              width: MediaQuery.of(context).size.width / 2.5,
                              image: const AssetImage('assets/genre.png'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(
                              home_genres[index].genre.toUpperCase(),
                              textAlign: TextAlign.center,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            // subtitle: Text(
                            //   home_genres[index]. as String,
                            //   textAlign: TextAlign.center,
                            //   softWrap: false,
                            //   overflow: TextOverflow.ellipsis,
                            //   style: const TextStyle(
                            //     fontSize: 13,
                            //     color: Colors.grey,
                            //   ),
                            // ),
                          ),
                        ),
                      ],
                    ),
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

// home artists at a glance

class ArtistsAtAGlance extends StatefulWidget {
  const ArtistsAtAGlance({super.key});

  @override
  State<ArtistsAtAGlance> createState() => _ArtistsAtAGlanceState();
}

class _ArtistsAtAGlanceState extends State<ArtistsAtAGlance> {
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  List<ArtistModel> a_glance = [];
  bool loading = false;

  Future<void> fetchSongs() async {
    await offlineAudioQuery.requestPermission();
    a_glance = await offlineAudioQuery.getArtists(
      sortType: ArtistSortType.ARTIST,
    );

    setState(() {
      loading = true;
    });
  }

  @override
  void initState() {
    fetchSongs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.height / 2.5;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _homeTitleComponent("LOCAL ARTISTS", () {}, null),
        //testing fetching some images from last fm api
        SizedBox(
          height: boxSize + 40,
          child: ListView.builder(
            itemCount: a_glance.take(10).length,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (_, index) {
              return GestureDetector(
                onTap: () async {
                  var album_songs = await offlineAudioQuery
                      .getArtistSongs(a_glance[index].id);

                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => LocalMusicsDetail(
                        title: a_glance[index].artist,
                        id: a_glance[index].id,
                        certainCase: 'artist',
                        songs: album_songs,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: boxSize - 30,
                    width: boxSize - 40,
                    child: Column(
                      children: [
                        QueryArtworkWidget(
                          id: a_glance[index].id,
                          type: ArtworkType.AUDIO,
                          artworkHeight: boxSize - 35,
                          artworkWidth: boxSize - 40,
                          artworkBorder: BorderRadius.circular(7.0),
                          nullArtworkWidget: ClipRRect(
                            borderRadius: BorderRadius.circular(100.0),
                            child: Image(
                              fit: BoxFit.cover,
                              height: boxSize - 35,
                              width: MediaQuery.of(context).size.width / 2.5,
                              image: const AssetImage('assets/artist.png'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(
                              a_glance[index].artist.toUpperCase(),
                              textAlign: TextAlign.center,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

//recently played


