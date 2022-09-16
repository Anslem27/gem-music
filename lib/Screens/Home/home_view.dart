import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gem/APIs/api.dart';
import 'package:gem/CustomWidgets/collage.dart';
import 'package:gem/CustomWidgets/horizontal_albumlist.dart';
import 'package:gem/CustomWidgets/like_button.dart';
import 'package:gem/CustomWidgets/on_hover.dart';
import 'package:gem/CustomWidgets/snackbar.dart';
import 'package:gem/CustomWidgets/song_tile_trailing_menu.dart';
import 'package:gem/Helpers/extensions.dart';
import 'package:gem/Helpers/format.dart';
import 'package:gem/Helpers/mediaitem_converter.dart';
import 'package:gem/Screens/Common/song_list.dart';
import 'package:gem/Screens/Library/favorites_section.dart';
import 'package:gem/Screens/Player/audioplayer_page.dart';
import 'package:gem/Screens/Search/artists.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../Helpers/local_music_functions.dart';
import '../../Services/spotify_playlist_downloader.dart';
import '../Library/import.dart';
import '../LocalMusic/local_music.dart';

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

  Future<void> getHomePageData() async {
    Map recievedData = await SaavnAPI().fetchHomePageData();
    if (recievedData.isNotEmpty) {
      Hive.box('cache').put('homepage', recievedData);
      data = recievedData;
      lists = ['recent', 'playlist', ...?data['collections']];
      lists.insert((lists.length / 2).round(), 'likedArtists');
    }
    setState(() {});
    recievedData = await FormatResponse.formatPromoLists(data);
    if (recievedData.isNotEmpty) {
      Hive.box('cache').put('homepage', recievedData);
      data = recievedData;
      lists = ['recent', 'playlist', ...?data['collections']];
      lists.insert((lists.length / 2).round(), 'likedArtists');
    }

    setState(() {});
  }

  String getSubTitle(Map item) {
    final type = item['type'];
    switch (type) {
      case 'charts':
        return '';
      case 'radio_station':
        return 'Radio • ${item['subtitle']?.toString().unescape()}';
      case 'playlist':
        return 'Playlist • ${item['subtitle']?.toString().unescape() ?? ''}';
      case 'song':
        return 'Single • ${item['artist']?.toString().unescape()}';
      case 'album':
        final artists = item['more_info']?['artistMap']?['artists']
            .map((artist) => artist['name'])
            .toList();
        return 'Album  • ${artists?.join(', ')?.toString().unescape()}';
      default:
        final artists = item['more_info']?['artistMap']?['artists']
            .map((artist) => artist['name'])
            .toList();
        return artists?.join(', ')?.toString().unescape() ?? '';
    }
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
    if (!fetched) {
      getHomePageData();
      fetched = true;
    }
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

    return (data.isEmpty && recentList.isEmpty)
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : ListView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            itemCount: data.isEmpty ? 2 : lists.length,
            itemBuilder: (context, idx) {
              if (idx == recentIndex) {
                return (recentList.isEmpty ||
                        !(Hive.box('settings')
                            .get('showRecent', defaultValue: true) as bool))
                    ? const SizedBox()
                    /* Last Session */
                    : Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 10, 0, 5),
                                child: Text(
                                  "Last Session",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                        !(Hive.box('settings')
                            .get('showPlaylist', defaultValue: true) as bool))
                    ? const SizedBox()
                    /* Local Playlists */
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                youtubeImportCard(context),
                                spotifyImportCard(context)
                              ],
                            ),
                          ),
                          /* Local playlists */
                          offlinePlaylists.isNotEmpty
                              ? Column(
                                  children: [
                                    Row(
                                      children: const [
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(15, 10, 0, 5),
                                          child: Text(
                                            'Local Playlists',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
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
                                                      title: offlinePlaylists[
                                                              index]
                                                          .playlist,
                                                      cachedSongs: songs,
                                                      playlistId:
                                                          offlinePlaylists[
                                                                  index]
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
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    child: Column(
                                                      children: [
                                                        QueryArtworkWidget(
                                                          id: offlinePlaylists[
                                                                  index]
                                                              .id,
                                                          type: ArtworkType
                                                              .PLAYLIST,
                                                          artworkHeight:
                                                              boxSize - 45,
                                                          artworkWidth:
                                                              MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  2.5,
                                                          artworkBorder:
                                                              BorderRadius
                                                                  .circular(
                                                                      7.0),
                                                          nullArtworkWidget:
                                                              ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        7.0),
                                                            child: Image(
                                                              fit: BoxFit.cover,
                                                              height:
                                                                  boxSize - 45,
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
                                                              const EdgeInsets
                                                                      .only(
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
                                                                        const EdgeInsets.all(
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
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            5.0,
                                                                        right:
                                                                            5),
                                                                    child: Text(
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
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        fontWeight:
                                                                            FontWeight.bold,
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
                                padding: EdgeInsets.fromLTRB(15, 10, 0, 5),
                                child: Text(
                                  "Online Playlists",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              itemCount: playlistNames.length,
                              itemBuilder: (context, index) {
                                final String name =
                                    playlistNames[index].toString();
                                final String showName =
                                    playlistDetails.containsKey(name)
                                        ? playlistDetails[name]['name']
                                                ?.toString() ??
                                            name
                                        : name;
                                final String? subtitle = playlistDetails[
                                                name] ==
                                            null ||
                                        playlistDetails[name]['count'] ==
                                            null ||
                                        playlistDetails[name]['count'] == 0
                                    ? null
                                    : '${playlistDetails[name]['count']} songs';
                                return GestureDetector(
                                  child: SizedBox(
                                    width: boxSize - 30,
                                    child: HoverBox(
                                      child: (playlistDetails[name] == null ||
                                              playlistDetails[name]
                                                      ['imagesList'] ==
                                                  null ||
                                              (playlistDetails[name]
                                                      ['imagesList'] as List)
                                                  .isEmpty)
                                          ? Card(
                                              elevation: 5,
                                              color: Colors.black,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  10.0,
                                                ),
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              child: name == 'Favorite Songs'
                                                  ? const Image(
                                                      image: AssetImage(
                                                        'assets/cover.jpg',
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
                                              placeholderImage:
                                                  'assets/cover.jpg',
                                            ),
                                      builder: (BuildContext context,
                                          bool isHover, Widget? child) {
                                        return Card(
                                          color: isHover
                                              ? null
                                              : Colors.transparent,
                                          elevation: 0,
                                          margin: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      showName,
                                                      textAlign:
                                                          TextAlign.center,
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
                                                        textAlign:
                                                            TextAlign.center,
                                                        softWrap: false,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
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
                                    Navigator.push(
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
                          )
                        ],
                      );
              }

              /* Liked Artitsts */
              if (lists[idx] == 'likedArtists') {
                final List likedArtistsList = likedArtists.values.toList();
                return likedArtists.isEmpty
                    ? const SizedBox()
                    : Column(
                        children: [
                          Row(
                            children: const [
                              Padding(
                                padding: EdgeInsets.fromLTRB(15, 10, 0, 5),
                                child: Text(
                                  'Liked Artists',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          HorizontalAlbumsList(
                            songsList: likedArtistsList,
                            onTap: (int idx) {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  opaque: false,
                                  pageBuilder: (_, __, ___) => ArtistSearchPage(
                                    data: likedArtistsList[idx] as Map,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
              }
              return const SizedBox();
              // return (data[lists[idx]] == null ||
              //         blacklistedHomeSections.contains(
              //           data['modules'][lists[idx]]?['title']
              //               ?.toString()
              //               .toLowerCase(),
              //         ))
              //     ? const SizedBox()
              //     : Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Padding(
              //             padding: const EdgeInsets.fromLTRB(15, 10, 0, 5),
              //             child: Text(
              //               data['modules'][lists[idx]]?['title']
              //                       ?.toString()
              //                       .unescape() ??
              //                   '',
              //               style: TextStyle(
              //                 color: Theme.of(context).colorScheme.secondary,
              //                 fontSize: 18,
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             ),
              //           ),
              //           //radioSection(boxSize, idx),
              //         ],
              //       );
            },
          );
  }

  youtubeImportCard(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          importYt(
            context,
            getPlaylists,
            fetchBox,
          );
        },
        child: Card(
          // color: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                  width: 50,
                  child: Icon(
                    MdiIcons.youtube,
                    size: 35,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 2.0, right: 5),
                  child: Text(
                    "Import Youtube\nPlaylist",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  spotifyImportCard(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => const SpotifyPlaylistGetter(),
            ),
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                  width: 50,
                  child: Icon(
                    Iconsax.music,
                    size: 35,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 2.0, right: 5),
                  child: Text(
                    "Import Spotify\nPlaylist",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SizedBox radioSection(double boxSize, int idx) {
    return SizedBox(
      height: boxSize + 15,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: data['modules'][lists[idx]]?['title']?.toString() ==
                'Radio Stations'
            ? (data[lists[idx]] as List).length + likedRadio.length
            : (data[lists[idx]] as List).length,
        itemBuilder: (context, index) {
          Map item;
          if (data['modules'][lists[idx]]?['title']?.toString() ==
              'Radio Stations') {
            index < likedRadio.length
                ? item = likedRadio[index] as Map
                : item = data[lists[idx]][index - likedRadio.length] as Map;
          } else {
            item = data[lists[idx]][index] as Map;
          }
          final currentSongList =
              data[lists[idx]].where((e) => e['type'] == 'song').toList();
          final subTitle = getSubTitle(item);
          if (item.isEmpty) return const SizedBox();
          return GestureDetector(
            onLongPress: () {
              Feedback.forLongPress(context);
              showDialog(
                context: context,
                builder: (context) {
                  return InteractiveViewer(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                        ),
                        AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          backgroundColor: Colors.transparent,
                          contentPadding: EdgeInsets.zero,
                          content: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                item['type'] == 'radio_station' ? 1000.0 : 15.0,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              errorWidget: (context, _, __) => const Image(
                                fit: BoxFit.cover,
                                image: AssetImage(
                                  'assets/cover.jpg',
                                ),
                              ),
                              imageUrl: item['image']
                                  .toString()
                                  .replaceAll(
                                    'http:',
                                    'https:',
                                  )
                                  .replaceAll(
                                    '50x50',
                                    '500x500',
                                  )
                                  .replaceAll(
                                    '150x150',
                                    '500x500',
                                  ),
                              placeholder: (context, url) => Image(
                                fit: BoxFit.cover,
                                image: (item['type'] == 'playlist' ||
                                        item['type'] == 'album')
                                    ? const AssetImage(
                                        'assets/album.png',
                                      )
                                    : item['type'] == 'artist'
                                        ? const AssetImage(
                                            'assets/artist.png',
                                          )
                                        : const AssetImage(
                                            'assets/cover.jpg',
                                          ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            onTap: () {
              if (item['type'] == 'radio_station') {
                ShowSnackBar().showSnackBar(
                  context,
                  'Connecting to radio',
                  duration: const Duration(seconds: 2),
                );
                SaavnAPI()
                    .createRadio(
                  names:
                      item['more_info']['featured_station_type'].toString() ==
                              'artist'
                          ? [item['more_info']['query'].toString()]
                          : [item['id'].toString()],
                  language:
                      item['more_info']['language']?.toString() ?? 'english',
                  stationType:
                      item['more_info']['featured_station_type'].toString(),
                )
                    .then((value) {
                  if (value != null) {
                    SaavnAPI().getRadioSongs(stationId: value).then((value) {
                      value.shuffle();
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (_, __, ___) => PlayScreen(
                            songsList: value,
                            index: 0,
                            offline: false,
                            fromDownloads: false,
                            fromMiniplayer: false,
                            recommend: true,
                          ),
                        ),
                      );
                    });
                  }
                });
              } else {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (_, __, ___) => item['type'] == 'song'
                        ? PlayScreen(
                            songsList: currentSongList as List,
                            index: currentSongList.indexWhere(
                              (e) => e['id'] == item['id'],
                            ),
                            offline: false,
                            fromDownloads: false,
                            fromMiniplayer: false,
                            recommend: true,
                          )
                        : SongsListPage(
                            listItem: item,
                          ),
                  ),
                );
              }
            },
            child: SizedBox(
              width: boxSize - 30,
              child: HoverBox(
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      item['type'] == 'radio_station' ? 1000.0 : 10.0,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    errorWidget: (context, _, __) => const Image(
                      fit: BoxFit.cover,
                      image: AssetImage(
                        'assets/cover.jpg',
                      ),
                    ),
                    imageUrl: item['image']
                        .toString()
                        .replaceAll(
                          'http:',
                          'https:',
                        )
                        .replaceAll(
                          '50x50',
                          '500x500',
                        )
                        .replaceAll(
                          '150x150',
                          '500x500',
                        ),
                    placeholder: (context, url) => Image(
                      fit: BoxFit.cover,
                      image: (item['type'] == 'playlist' ||
                              item['type'] == 'album')
                          ? const AssetImage(
                              'assets/album.png',
                            )
                          : item['type'] == 'artist'
                              ? const AssetImage(
                                  'assets/artist.png',
                                )
                              : const AssetImage(
                                  'assets/cover.jpg',
                                ),
                    ),
                  ),
                ),
                builder: (
                  BuildContext context,
                  bool isHover,
                  Widget? child,
                ) {
                  return Card(
                    color: isHover ? null : Colors.transparent,
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            SizedBox.square(
                              dimension: isHover ? boxSize - 25 : boxSize - 30,
                              child: child,
                            ),
                            if (isHover &&
                                (item['type'] == 'song' ||
                                    item['type'] == 'radio_station'))
                              Positioned.fill(
                                child: Container(
                                  margin: const EdgeInsets.all(
                                    4.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(
                                      item['type'] == 'radio_station'
                                          ? 1000.0
                                          : 10.0,
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.circular(
                                          1000.0,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        size: 50.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (item['type'] == 'radio_station' &&
                                (Platform.isAndroid ||
                                    Platform.isIOS ||
                                    isHover))
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  icon: likedRadio.contains(item)
                                      ? const Icon(
                                          Iconsax.heart,
                                          color: Colors.red,
                                        )
                                      : const Icon(
                                          Icons.favorite_border_rounded,
                                        ),
                                  tooltip: likedRadio.contains(item)
                                      ? 'Unlike'
                                      : 'Like',
                                  onPressed: () {
                                    likedRadio.contains(item)
                                        ? likedRadio.remove(item)
                                        : likedRadio.add(item);
                                    Hive.box('settings').put(
                                      'likedRadio',
                                      likedRadio,
                                    );
                                    setState(() {});
                                  },
                                ),
                              ),
                            if (item['type'] == 'song' ||
                                item['duration'] != null)
                              Align(
                                alignment: Alignment.topRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isHover)
                                      LikeButton(
                                        mediaItem:
                                            MediaItemConverter.mapToMediaItem(
                                          item,
                                        ),
                                      ),
                                    SongTileTrailingMenu(
                                      data: item,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                          ),
                          child: Column(
                            children: [
                              Text(
                                item['title']?.toString().unescape() ?? '',
                                textAlign: TextAlign.center,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (subTitle != '')
                                Text(
                                  subTitle,
                                  textAlign: TextAlign.center,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
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
          );
        },
      ),
    );
  }
}
