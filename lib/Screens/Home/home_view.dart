// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:gem/Screens/Home/components/online.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../Helpers/local_music_functions.dart';
import '../../animations/custompageroute.dart';
import '../Library/online_playlists.dart';
import '../local/local_music.dart';
import '../local/localplaylists.dart';
import '../local/widgets/preview_page.dart';
import 'components/home_components.dart';
//import 'components/recently_played.dart';

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
          FadeTransitionPageRoute(
            child: const DownloadedSongs(
              showPlaylists: true,
              fromHomElement: false,
            ),
          ),
        );
      },
      () {
        Navigator.pushNamed(context, '/downloads');
      }
    ];

    List<String> playlistImages = ["", "assets/elements/onl.png"];

    List<Function()?> playlistLibOntaps = [
      () {
        Navigator.push(
          context,
          FadeTransitionPageRoute(
            child: PreviewPage(
              title: "Local Playlists",
              imageUrl: "assets/lyrics.png",
              sliverList: LocalPlaylists(
                playlistDetails: offlinePlaylists,
                offlineAudioQuery: offlineAudioQuery,
              ),
              isSong: false,
              localImage: true,
            ),
          ),
        );
      },
      () {
        Navigator.push(
          context,
          FadeTransitionPageRoute(
            child: PreviewPage(
              title: "Online Playlists",
              imageUrl: "assets/elements/onl.png",
              sliverList: const OnlinePlaylistScreen(),
              isSong: false,
              localImage: true,
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
        ValueListenableBuilder(
            valueListenable: Hive.box('settings').listenable(),
            builder: ((context, box, child) {
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                itemCount: data.isEmpty ? 2 : lists.length,
                itemBuilder: (context, idx) {
                  if (idx == playlistIndex) {
                    return (playlistNames.isEmpty ||
                            !(Hive.box('settings').get('showPlaylist',
                                defaultValue: true) as bool))
                        ? const SizedBox()
                        /* Local Playlists */
                        : Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Stack(
                              children: [
                                Positioned(
                                  left:
                                      MediaQuery.of(context).size.width / 2.95,
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.width,
                                    child: const Opacity(
                                      opacity: 0.3,
                                      child: Image(
                                        image: AssetImage(
                                          'assets/ic_launcher_no_bg.png',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    _homeTitleComponent("YOUR LIBRARY"),
                                    SizedBox(
                                      height: boxSize + 40,
                                      child: ListView.builder(
                                        itemCount: musicLibImages.length,
                                        scrollDirection: Axis.horizontal,
                                        physics: const BouncingScrollPhysics(),
                                        itemBuilder: (_, val) {
                                          return GestureDetector(
                                            onTap: muicLibOntaps[val],
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 5),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    val == 0
                                                        ? const SizedBox(
                                                            height: 25,
                                                            child: Image(
                                                              image: AssetImage(
                                                                'assets/ic_launcher_no_bg.png',
                                                              ),
                                                            ),
                                                          )
                                                        : Icon(
                                                            EvaIcons
                                                                .cloudDownloadOutline,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .secondary),
                                                    const SizedBox(width: 5),
                                                    Text(val == 0
                                                        ? "Local"
                                                        : "Downloads")
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                val == 0
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5.0),
                                                        child: SizedBox(
                                                          height: boxSize - 20,
                                                          width: boxSize - 25,
                                                          child:
                                                              const SongGrid(),
                                                        ),
                                                      )
                                                    : Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5.0),
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
                                    const RecentlyAddedSongs(),
                                    const OnlineMusic(),
                                    //const SizedBox(height: 10),
                                    //const Previously(),
                                    const SizedBox(height: 10),
                                    const HomeAlbums(),
                                    const SizedBox(height: 10),
                                    const HomeGenres(),
                                    const SizedBox(height: 10),
                                    const ArtistsAtAGlance(),
                                    _homeTitleComponent("PLAYLIST LIBRARY"),
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 5),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Icon(Icons.folder,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        val == 0
                                                            ? offlinePlaylists
                                                                        .length >
                                                                    1
                                                                ? "${offlinePlaylists.length} playlists"
                                                                : "No Playlists"
                                                            : playlistNames
                                                                        .length >
                                                                    1
                                                                ? "${playlistImages.length} playlists"
                                                                : "No Playlists",
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                val == 0
                                                    ? const Padding(
                                                        padding:
                                                            EdgeInsets.all(5.0),
                                                        child:
                                                            LocalPlayListCollage(),
                                                      )
                                                    : Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
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
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                _homeTitleComponent(
                                                    "LOCAL PLAYLISTS"),
                                                SizedBox(
                                                  height: boxSize + 30,
                                                  child: ListView.builder(
                                                    itemCount:
                                                        offlinePlaylists.length,
                                                    physics:
                                                        const BouncingScrollPhysics(),
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return GestureDetector(
                                                        onTap: () async {
                                                          final songs =
                                                              await offlineAudioQuery
                                                                  .getPlaylistSongs(
                                                            offlinePlaylists[
                                                                    index]
                                                                .id,
                                                          );
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  DownloadedSongs(
                                                                title: offlinePlaylists[
                                                                        index]
                                                                    .playlist,
                                                                cachedSongs:
                                                                    songs,
                                                                playlistId:
                                                                    offlinePlaylists[
                                                                            index]
                                                                        .id,
                                                                fromHomElement:
                                                                    true,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: SizedBox(
                                                            height:
                                                                boxSize - 20,
                                                            width: boxSize - 30,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                QueryArtworkWidget(
                                                                  id: offlinePlaylists[
                                                                          index]
                                                                      .id,
                                                                  type: ArtworkType
                                                                      .PLAYLIST,
                                                                  artworkHeight:
                                                                      boxSize -
                                                                          30,
                                                                  artworkWidth:
                                                                      boxSize -
                                                                          30,
                                                                  artworkBorder:
                                                                      BorderRadius
                                                                          .circular(
                                                                              0.0),
                                                                  nullArtworkWidget:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            0.0),
                                                                    child:
                                                                        Image(
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      height:
                                                                          boxSize -
                                                                              35,
                                                                      width:
                                                                          boxSize -
                                                                              40,
                                                                      image: const AssetImage(
                                                                          'assets/file_playlist.png'),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      ListTile(
                                                                    title: Text(
                                                                      offlinePlaylists[
                                                                              index]
                                                                          .playlist
                                                                          .toUpperCase(),
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
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                      ),
                                                                    ),
                                                                    subtitle:
                                                                        Text(
                                                                      offlinePlaylists[index].numOfSongs >
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
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        : const SizedBox(height: 0, width: 0),
                                    const SizedBox(height: 5),
                                  ],
                                ),
                              ],
                            ),
                          );
                  }

                  return const SizedBox();
                },
              );
            }));
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
}
