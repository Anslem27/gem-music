import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gem/CustomWidgets/collage.dart';
import 'package:gem/CustomWidgets/horizontal_albumlist.dart';
import 'package:gem/CustomWidgets/on_hover.dart';
import 'package:gem/Screens/Library/favorites_section.dart';
import 'package:gem/Screens/LocalMusic/widgets/bouncy_page.dart';
import 'package:gem/Screens/Player/audioplayer_page.dart';
import 'package:hive/hive.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../Helpers/local_music_functions.dart';
import '../../Services/spotify_playlist_downloader.dart';
import '../Library/import.dart';
import '../Library/online_playlists.dart';
import '../LocalMusic/local_music.dart';
import '../LocalMusic/localplaylists.dart';
import 'components/home_components.dart';

bool fetched = false;
List likedRadio =
    Hive.box('settings').get('likedRadio', defaultValue: []) as List;
Map data = Hive.box('cache').get('homepage', defaultValue: {}) as Map;
List lists = ['recent', 'playlist', ...?data['collections']];

class HomeViewPage extends StatefulWidget {
  const HomeViewPage({Key? key}) : super(key: key);

  @override
  _HomeViewPageState createState() => _HomeViewPageState();
}

class _HomeViewPageState extends State<HomeViewPage>
    with AutomaticKeepAliveClientMixin<HomeViewPage> {
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  List<PlaylistModel> offlinePlaylists = [];

  final Box fetchBox = Hive.box('settings');
  final List getPlaylists =
      Hive.box('settings').get('playlistNames')?.toList() as List? ??
          ['Favorite Songs'];

  List recentList =
      Hive.box('cache').get('recentSongs', defaultValue: []) as List;
  Map likedArtists =
      Hive.box('settings').get('likedArtists', defaultValue: {}) as Map;
  List blacklistedHomeSections = Hive.box('settings')
      .get('blacklistedHomeSections', defaultValue: []) as List;
  List playlistNames =
      Hive.box('settings').get('playlistNames')?.toList() as List? ??
          ['Favorite Songs'];
  Map playlistDetails =
      Hive.box('settings').get('playlistDetails', defaultValue: {}) as Map;
  int recentIndex = 0;
  int playlistIndex = 1;

  Future<void> fillData() async {
    offlinePlaylists = await offlineAudioQuery.getPlaylists();
    setState(() {});
  }

  @override
  void initState() {
    fillData();
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    List<String> musicLibImages = [
      "assets/elements/loco.png",
      "assets/elements/online.png"
    ];

    List<Function()?> muicLibOntaps = [
      () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const DownloadedSongs(
              showPlaylists: true,
            ),
          ),
        );
      },
      () {
        Navigator.pushNamed(context, '/downloads');
      }
    ];

    List<String> playlistImages = [
      "assets/elements/loc_play.png",
      "assets/elements/onl.png"
    ];

    List<Function()?> playlistLibOntaps = [
      () {
        Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (_) => BouncyPage(
                    title: "Local Playlists",
                    imageUrl: "assets/elements/loc_play.png",
                    body: LocalPlaylists(
                      playlistDetails: offlinePlaylists,
                      offlineAudioQuery: offlineAudioQuery,
                    ),
                  )),
        );
      },
      () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => const BouncyPage(
              title: "Online Playlists",
              imageUrl: "assets/elements/onl.png",
              body: OnlinePlaylistScreen(),
            ),
          ),
        );
      }
    ];

    double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.height / 2.5;
    if (boxSize > 250) boxSize = 250;
    if (recentList.length < playlistNames.length) {
      recentIndex = 0;
      playlistIndex = 1;
    } else {
      recentIndex = 1;
      playlistIndex = 0;
    }

    return /* (data.isEmpty)
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : */
        ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      itemCount: data.isEmpty ? 2 : lists.length,
      itemBuilder: (context, idx) {
        if (idx == recentIndex) {
          return (recentList.isEmpty ||
                  !(Hive.box('settings').get('showRecent', defaultValue: true)
                      as bool))
              ? const SizedBox()
              /* Last Session */
              : Column(
                  children: [
                    _homeTitleComponent("LAST SESSION"),
                    HorizontalAlbumsList(
                      songsList: recentList,
                      onTap: (int idx) {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (_, __, ___) => PlayScreen(
                              songsList: recentList,
                              index: idx,
                              offline: true,
                              fromDownloads: false,
                              fromMiniplayer: false,
                              recommend: true,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
        }
        if (idx == playlistIndex) {
          return (playlistNames.isEmpty ||
                  !(Hive.box('settings').get('showPlaylist', defaultValue: true)
                      as bool))
              ? const SizedBox()
              /* Local Playlists */
              : Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _homeTitleComponent("MUSIC LIBRARY"),
                      SizedBox(
                        height: boxSize + 50,
                        child: ListView.builder(
                          itemCount: musicLibImages.length,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (_, val) {
                            return GestureDetector(
                              onTap: muicLibOntaps[val],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                          val == 0
                                              ? EvaIcons.music
                                              : EvaIcons.recording,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                      const SizedBox(width: 5),
                                      Text(val == 0 ? "Local" : "Online")
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: SizedBox(
                                      height: boxSize - 20,
                                      width: boxSize - 30,
                                      child: Image.asset(
                                        musicLibImages[val],
                                        height: boxSize,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      _homeTitleComponent("RECENTLY ADDED"),
                      const RecentlyAddedSongs(),
                      _homeTitleComponent("ALBUMS"),
                      const HomeAlbums(),
                      _homeTitleComponent("GENRES"),
                      const HomeGenres(),
                      _homeTitleComponent("ARTISTS"),
                      const ArtistsAtAGlance(),
                      // Row(
                      //   children: const [
                      //     Padding(
                      //       padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      //       child: Text(
                      //         'Trending on Streaming Platforms',
                      //         style: TextStyle(
                      //           fontSize: 25,
                      //           fontWeight: FontWeight.w500,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      //const TrendingList(type: 'top'),
                      Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Text(
                              'PLAYLIST LIBRARY',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: boxSize + 50,
                        child: ListView.builder(
                          itemCount: playlistImages.length,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (_, val) {
                            return GestureDetector(
                              onTap: playlistLibOntaps[val],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(Icons.folder,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                      const SizedBox(width: 5),
                                      Text(
                                        val == 0
                                            ? offlinePlaylists.length > 1
                                                ? "${offlinePlaylists.length} playlists"
                                                : "No Playlists"
                                            : playlistNames.length > 1
                                                ? "${playlistImages.length} playlists"
                                                : "No Playlists",
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: SizedBox(
                                      height: boxSize - 20,
                                      width: boxSize - 30,
                                      child: Image.asset(
                                        playlistImages[val],
                                        height: boxSize,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      /* Local playlists List */
                      offlinePlaylists.isNotEmpty
                          ? Column(
                              children: [
                                Row(
                                  children: const [
                                    Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(0, 10, 0, 10),
                                      child: Text(
                                        'LOCAL PLAYLISTS',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: boxSize + 25,
                                  child: ListView.builder(
                                    itemCount: offlinePlaylists.length,
                                    physics: const BouncingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            left: index == 2 ? 3 : 5,
                                            right: 5,
                                            top: 3,
                                            bottom: 3),
                                        child: InkWell(
                                          onTap: () async {
                                            final songs =
                                                await offlineAudioQuery
                                                    .getPlaylistSongs(
                                              offlinePlaylists[index].id,
                                            );
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DownloadedSongs(
                                                  title: offlinePlaylists[index]
                                                      .playlist,
                                                  cachedSongs: songs,
                                                  playlistId:
                                                      offlinePlaylists[index]
                                                          .id,
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
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                clipBehavior: Clip.antiAlias,
                                                child: Column(
                                                  children: [
                                                    QueryArtworkWidget(
                                                      id: offlinePlaylists[
                                                              index]
                                                          .id,
                                                      type:
                                                          ArtworkType.PLAYLIST,
                                                      artworkHeight:
                                                          boxSize - 45,
                                                      artworkWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.5,
                                                      artworkBorder:
                                                          BorderRadius.circular(
                                                              7.0),
                                                      nullArtworkWidget:
                                                          ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(7.0),
                                                        child: Image(
                                                          fit: BoxFit.cover,
                                                          height: boxSize - 45,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              2.5,
                                                          image: const AssetImage(
                                                              'assets/file_playlist.png'),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 6.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        5.0),
                                                                child: Text(
                                                                  offlinePlaylists[
                                                                          index]
                                                                      .playlist,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  softWrap:
                                                                      false,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            5.0,
                                                                        right:
                                                                            5),
                                                                child: Text(
                                                                  offlinePlaylists[index]
                                                                              .numOfSongs >
                                                                          0
                                                                      ? "${offlinePlaylists[index].numOfSongs} songs"
                                                                      : "Empty playlist",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  softWrap:
                                                                      false,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              ],
                            )
                          : const SizedBox(height: 0, width: 0),
                      Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Text(
                              'ONLINE PLAYLISTS',
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
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          itemCount: playlistNames.length,
                          itemBuilder: (context, index) {
                            final String name = playlistNames[index].toString();
                            final String showName = playlistDetails
                                    .containsKey(name)
                                ? playlistDetails[name]['name']?.toString() ??
                                    name
                                : name;
                            final String? subtitle = playlistDetails[name] ==
                                        null ||
                                    playlistDetails[name]['count'] == null ||
                                    playlistDetails[name]['count'] == 0
                                ? null
                                : '${playlistDetails[name]['count']} songs';
                            return GestureDetector(
                              child: SizedBox(
                                width: boxSize - 30,
                                child: HoverBox(
                                  child: (playlistDetails[name] == null ||
                                          playlistDetails[name]['imagesList'] ==
                                              null ||
                                          (playlistDetails[name]['imagesList']
                                                  as List)
                                              .isEmpty)
                                      ? Card(
                                          elevation: 5,
                                          color: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10.0,
                                            ),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: name == 'Favorite Songs'
                                              ? const Image(
                                                  image: AssetImage(
                                                    'assets/elements/fav.png',
                                                  ),
                                                )
                                              : const Image(
                                                  image: AssetImage(
                                                    'assets/album.png',
                                                  ),
                                                ),
                                        )
                                      : Collage(
                                          borderRadius: 10.0,
                                          imageList: playlistDetails[name]
                                              ['imagesList'] as List,
                                          showGrid: true,
                                          placeholderImage: 'assets/cover.jpg',
                                        ),
                                  builder: (BuildContext context, bool isHover,
                                      Widget? child) {
                                    return Card(
                                      color:
                                          isHover ? null : Colors.transparent,
                                      elevation: 0,
                                      margin: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(1.0),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        children: [
                                          SizedBox.square(
                                            dimension: isHover
                                                ? boxSize - 25
                                                : boxSize - 30,
                                            child: child,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  showName,
                                                  textAlign: TextAlign.center,
                                                  softWrap: false,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 15.5),
                                                ),
                                                if (subtitle != null)
                                                  Text(
                                                    subtitle,
                                                    textAlign: TextAlign.center,
                                                    softWrap: false,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .caption!
                                                          .color,
                                                    ),
                                                  )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              onTap: () async {
                                await Hive.openBox(name);
                                name == 'Favorite Songs'
                                    ? Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (_) => BouncyPage(
                                            title: "Favorites",
                                            imageUrl: "assets/elements/fav.png",
                                            body: LikedSongs(
                                              scenario: "home favorites",
                                              playlistName: name,
                                              showName: playlistDetails
                                                      .containsKey(name)
                                                  ? playlistDetails[name]
                                                              ['name']
                                                          ?.toString() ??
                                                      name
                                                  : name,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LikedSongs(
                                            playlistName: name,
                                            showName: playlistDetails
                                                    .containsKey(name)
                                                ? playlistDetails[name]['name']
                                                        ?.toString() ??
                                                    name
                                                : name,
                                          ),
                                        ),
                                      );
                              },
                            );
                          },
                        ),
                      ),
                      Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Text(
                              'IMPORT PLAYLIST',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          importElement(context, boxSize, () {
                            importYt(
                              context,
                              getPlaylists,
                              fetchBox,
                            );
                          }, "Import from\nYoutube", "assets/album.png"),
                          importElement(context, boxSize, () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (_) => const SpotifyPlaylistGetter(),
                              ),
                            );
                          }, "Import from\nSpotify", "assets/album.png"),
                        ],
                      ),
                    ],
                  ),
                );
        }

        return const SizedBox();
      },
    );
  }

  Row _homeTitleComponent(String title) {
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
      ],
    );
  }

  importElement(BuildContext context, double boxSize, Function()? onTap,
      String title, imageUrl) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          width: boxSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Theme.of(context).cardColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(imageUrl),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Text(
                  title,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
