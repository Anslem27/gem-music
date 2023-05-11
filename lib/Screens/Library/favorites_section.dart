import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem/widgets/data_search.dart';
import 'package:gem/widgets/gradient_containers.dart';
import 'package:gem/widgets/miniplayer.dart';
import 'package:gem/widgets/playlist_head.dart';
import 'package:gem/Helpers/songs_count.dart' as songs_count;
import 'package:gem/Screens/Player/music_player.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';

import '../../widgets/add_playlist.dart';
import '../../Helpers/add_mediaitem_to_queue.dart';
import '../../Helpers/mediaitem_converter.dart';
import '../Common/song_list.dart';
import '../Search/albums.dart';
// import 'package:path_provider/path_provider.dart';

class LikedSongs extends StatefulWidget {
  final String scenario;
  final String playlistName;
  final String? showName;
  const LikedSongs({
    Key? key,
    required this.playlistName,
    this.showName,
    this.scenario = "normal",
  }) : super(key: key);
  @override
  _LikedSongsState createState() => _LikedSongsState();
}

class _LikedSongsState extends State<LikedSongs>
    with SingleTickerProviderStateMixin {
  Box? likedBox;
  bool added = false;
  // String? tempPath = Hive.box('settings').get('tempDirPath')?.toString();
  List _songs = [];
  final Map<String, List<Map>> _albums = {};
  final Map<String, List<Map>> _artists = {};
  final Map<String, List<Map>> _genres = {};
  List _sortedAlbumKeysList = [];
  List _sortedArtistKeysList = [];
  List _sortedGenreKeysList = [];
  // int currentIndex = 0;
  int sortValue = Hive.box('settings').get('sortValue', defaultValue: 1) as int;
  int orderValue =
      Hive.box('settings').get('orderValue', defaultValue: 1) as int;
  int albumSortValue =
      Hive.box('settings').get('albumSortValue', defaultValue: 2) as int;
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showShuffle = ValueNotifier<bool>(true);

  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
  }

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        _showShuffle.value = false;
      } else {
        _showShuffle.value = true;
      }
    });
    getLiked();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void getLiked() {
    likedBox = Hive.box(widget.playlistName);
    _songs = likedBox?.values.toList() ?? [];
    songs_count.addSongsCount(
      widget.playlistName,
      _songs.length,
      _songs.length >= 4
          ? _songs.sublist(0, 4)
          : _songs.sublist(0, _songs.length),
    );
    setArtistAlbum();
  }

  void setArtistAlbum() {
    for (final element in _songs) {
      if (_albums.containsKey(element['album'])) {
        final List<Map> tempAlbum = _albums[element['album']]!;
        tempAlbum.add(element as Map);
        _albums.addEntries([MapEntry(element['album'].toString(), tempAlbum)]);
      } else {
        _albums.addEntries([
          MapEntry(element['album'].toString(), [element as Map])
        ]);
      }

      if (_artists.containsKey(element['artist'])) {
        final List<Map> tempArtist = _artists[element['artist']]!;
        tempArtist.add(element);
        _artists
            .addEntries([MapEntry(element['artist'].toString(), tempArtist)]);
      } else {
        _artists.addEntries([
          MapEntry(element['artist'].toString(), [element])
        ]);
      }

      if (_genres.containsKey(element['genre'])) {
        final List<Map> tempGenre = _genres[element['genre']]!;
        tempGenre.add(element);
        _genres.addEntries([MapEntry(element['genre'].toString(), tempGenre)]);
      } else {
        _genres.addEntries([
          MapEntry(element['genre'].toString(), [element])
        ]);
      }
    }

    sortSongs(sortVal: sortValue, order: orderValue);

    _sortedAlbumKeysList = _albums.keys.toList();
    _sortedArtistKeysList = _artists.keys.toList();
    _sortedGenreKeysList = _genres.keys.toList();

    sortAlbums();

    added = true;
    setState(() {});
  }

  void sortSongs({required int sortVal, required int order}) {
    switch (sortVal) {
      case 0:
        _songs.sort(
          (a, b) => a['title']
              .toString()
              .toUpperCase()
              .compareTo(b['title'].toString().toUpperCase()),
        );
        break;
      case 1:
        _songs.sort(
          (a, b) => a['dateAdded']
              .toString()
              .toUpperCase()
              .compareTo(b['dateAdded'].toString().toUpperCase()),
        );
        break;
      case 2:
        _songs.sort(
          (a, b) => a['album']
              .toString()
              .toUpperCase()
              .compareTo(b['album'].toString().toUpperCase()),
        );
        break;
      case 3:
        _songs.sort(
          (a, b) => a['artist']
              .toString()
              .toUpperCase()
              .compareTo(b['artist'].toString().toUpperCase()),
        );
        break;
      case 4:
        _songs.sort(
          (a, b) => a['duration']
              .toString()
              .toUpperCase()
              .compareTo(b['duration'].toString().toUpperCase()),
        );
        break;
      default:
        _songs.sort(
          (b, a) => a['dateAdded']
              .toString()
              .toUpperCase()
              .compareTo(b['dateAdded'].toString().toUpperCase()),
        );
        break;
    }

    if (order == 1) {
      _songs = _songs.reversed.toList();
    }
  }

  void sortAlbums() {
    if (albumSortValue == 0) {
      _sortedAlbumKeysList.sort(
        (a, b) =>
            a.toString().toUpperCase().compareTo(b.toString().toUpperCase()),
      );
      _sortedArtistKeysList.sort(
        (a, b) =>
            a.toString().toUpperCase().compareTo(b.toString().toUpperCase()),
      );
      _sortedGenreKeysList.sort(
        (a, b) =>
            a.toString().toUpperCase().compareTo(b.toString().toUpperCase()),
      );
    }
    if (albumSortValue == 1) {
      _sortedAlbumKeysList.sort(
        (b, a) =>
            a.toString().toUpperCase().compareTo(b.toString().toUpperCase()),
      );
      _sortedArtistKeysList.sort(
        (b, a) =>
            a.toString().toUpperCase().compareTo(b.toString().toUpperCase()),
      );
      _sortedGenreKeysList.sort(
        (b, a) =>
            a.toString().toUpperCase().compareTo(b.toString().toUpperCase()),
      );
    }
    if (albumSortValue == 2) {
      _sortedAlbumKeysList
          .sort((b, a) => _albums[a]!.length.compareTo(_albums[b]!.length));
      _sortedArtistKeysList
          .sort((b, a) => _artists[a]!.length.compareTo(_artists[b]!.length));
      _sortedGenreKeysList
          .sort((b, a) => _genres[a]!.length.compareTo(_genres[b]!.length));
    }
    if (albumSortValue == 3) {
      _sortedAlbumKeysList
          .sort((a, b) => _albums[a]!.length.compareTo(_albums[b]!.length));
      _sortedArtistKeysList
          .sort((a, b) => _artists[a]!.length.compareTo(_artists[b]!.length));
      _sortedGenreKeysList
          .sort((a, b) => _genres[a]!.length.compareTo(_genres[b]!.length));
    }
    if (albumSortValue == 4) {
      _sortedAlbumKeysList.shuffle();
      _sortedArtistKeysList.shuffle();
      _sortedGenreKeysList.shuffle();
    }
  }

  void deleteLiked(Map song) {
    setState(() {
      likedBox!.delete(song['id']);
      if (_albums[song['album']]!.length == 1) {
        _sortedAlbumKeysList.remove(song['album']);
      }
      _albums[song['album']]!.remove(song);

      if (_artists[song['artist']]!.length == 1) {
        _sortedArtistKeysList.remove(song['artist']);
      }
      _artists[song['artist']]!.remove(song);

      if (_genres[song['genre']]!.length == 1) {
        _sortedGenreKeysList.remove(song['genre']);
      }
      _genres[song['genre']]!.remove(song);

      _songs.remove(song);
      songs_count.addSongsCount(
        widget.playlistName,
        _songs.length,
        _songs.length >= 4
            ? _songs.sublist(0, 4)
            : _songs.sublist(0, _songs.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return _body(context);
  }

  _body(BuildContext context) {
    if (widget.scenario == "normal") {
      return GradientContainer(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              Expanded(
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    title: Text(
                      widget.showName == null
                          ? widget.playlistName[0].toUpperCase() +
                              widget.playlistName.substring(1)
                          : widget.showName![0].toUpperCase() +
                              widget.showName!.substring(1),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 20),
                    ),
                    centerTitle: true,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.transparent
                            : Theme.of(context).colorScheme.secondary,
                    elevation: 0,
                    actions: [
                      IconButton(
                        splashRadius: 24,
                        icon: const Icon(CupertinoIcons.search),
                        tooltip: 'Search',
                        onPressed: () {
                          showSearch(
                            context: context,
                            delegate: DownloadsSearch(data: _songs),
                          );
                        },
                      ),
                      PopupMenuButton(
                        splashRadius: 24,
                        icon: const Icon(Iconsax.sort),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                        onSelected: (int value) {
                          if (value < 5) {
                            sortValue = value;
                            Hive.box('settings').put('sortValue', value);
                          } else {
                            orderValue = value - 5;
                            Hive.box('settings').put('orderValue', orderValue);
                          }
                          sortSongs(sortVal: sortValue, order: orderValue);
                          setState(() {});
                        },
                        itemBuilder: (context) {
                          final List<String> sortTypes = [
                            'Display Name',
                            'Date Added',
                            'Album',
                            'Artist',
                            'Duration',
                          ];
                          final List<String> orderTypes = [
                            'Increasing',
                            'Decreasing',
                          ];
                          final menuList = <PopupMenuEntry<int>>[];
                          menuList.addAll(
                            sortTypes
                                .map(
                                  (e) => PopupMenuItem(
                                    value: sortTypes.indexOf(e),
                                    child: Row(
                                      children: [
                                        if (sortValue == sortTypes.indexOf(e))
                                          Icon(
                                            Icons.check_rounded,
                                            size: 20,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.grey[700],
                                          )
                                        else
                                          const SizedBox(),
                                        const SizedBox(width: 10),
                                        Text(e),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                          menuList.add(
                            const PopupMenuDivider(height: 10),
                          );
                          menuList.addAll(
                            orderTypes
                                .map(
                                  (e) => PopupMenuItem(
                                    value: sortTypes.length +
                                        orderTypes.indexOf(e),
                                    child: Row(
                                      children: [
                                        if (orderValue == orderTypes.indexOf(e))
                                          Icon(
                                            Icons.check_rounded,
                                            size: 20,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.grey[700],
                                          )
                                        else
                                          const SizedBox(),
                                        const SizedBox(width: 10),
                                        Text(e),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                          return menuList;
                        },
                      ),
                    ],
                  ),
                  body: !added
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : SongsTab(
                          songs: _songs,
                          onDelete: (Map item) {
                            deleteLiked(item);
                          },
                          playlistName: widget.playlistName,
                          scrollController: _scrollController,
                        ),
                  floatingActionButton: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(80.0),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        if (_songs.isNotEmpty) {
                          final tempList = _songs.toList();
                          tempList.shuffle();
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              opaque: false,
                              pageBuilder: (_, __, ___) => PlayScreen(
                                songsList: tempList,
                                index: 0,
                                offline: false,
                                fromMiniplayer: false,
                                fromDownloads: false,
                                recommend: false,
                              ),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _showShuffle,
                            builder: (
                              BuildContext context,
                              bool showFullShuffle,
                              Widget? child,
                            ) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Iconsax.shuffle,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    size: 24.0,
                                  ),
                                  if (showFullShuffle)
                                    const SizedBox(width: 5.0),
                                  if (showFullShuffle)
                                    Text(
                                      "Shuffle",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  if (showFullShuffle)
                                    const SizedBox(width: 2.5),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const MiniPlayer(),
            ],
          ),
        ),
      );
    } else {
      return SongsTab(
        songs: _songs,
        onDelete: (Map item) {
          deleteLiked(item);
        },
        playlistName: widget.playlistName,
        scrollController: _scrollController,
      );
    }
  }
}

class SongsTab extends StatefulWidget {
  final List songs;
  final String playlistName;
  final Function(Map item) onDelete;
  final ScrollController scrollController;
  const SongsTab({
    Key? key,
    required this.songs,
    required this.onDelete,
    required this.playlistName,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<SongsTab> createState() => _SongsTabState();
}

class _SongsTabState extends State<SongsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.height / 2.5;
    super.build(context);
    return (widget.songs.isEmpty)
        ? Material(
            color: Colors.transparent,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset("assets/svg/music.svg",
                      height: 140, width: 100),
                  const SizedBox(height: 20),
                  Text(
                    "Wow...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary),
                  ),
                  const Text(
                    "No music here",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          )
        : Material(
            color: Colors.transparent,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  PlaylistHead(
                    songsList: widget.songs,
                    offline: true,
                    fromDownloads: false,
                  ),
                  SizedBox(
                    height: 500,
                    child: ListView.builder(
                      controller: widget.scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 10),
                      shrinkWrap: true,
                      itemCount: widget.songs.length,
                      itemBuilder: (context, index) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    opaque: false,
                                    pageBuilder: (_, __, ___) => PlayScreen(
                                      songsList: widget.songs,
                                      index: index,
                                      offline: true,
                                      fromMiniplayer: false,
                                      fromDownloads: false,
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
                                    //TODO: Fix song Art
                                    Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Image(
                                        fit: BoxFit.cover,
                                        image: FileImage(
                                          File(
                                            widget.songs[index]['image']
                                                .toString(),
                                          ),
                                        ),
                                        errorBuilder: (_, __, ___) {
                                          return Image.asset(
                                            'assets/cover.jpg',
                                          );
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: ListTile(
                                        title: Text(
                                          '${widget.songs[index]['title']}',
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 17),
                                        ),
                                        subtitle: Text(
                                          '${widget.songs[index]['artist'] ?? 'Unknown'} - ${widget.songs[index]['album'] ?? 'Unknown'}',
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
                                      padding:
                                          const EdgeInsets.only(right: 3.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [
                                            // SongTileTrailingMenu(
                                            //   data: widget.songs[index] as Map,
                                            //   isPlaylist: true,
                                            //   deleteLiked: widget.onDelete,
                                            // ),
                                            PopupMenuButton(
                                              splashRadius: 24,
                                              icon: Icon(
                                                Icons.more_vert_rounded,
                                                color: Theme.of(context)
                                                    .iconTheme
                                                    .color,
                                              ),
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(15.0),
                                                ),
                                              ),
                                              itemBuilder: (context) => [
                                                PopupMenuItem(
                                                  value: 6,
                                                  child: Row(
                                                    children: const [
                                                      Icon(
                                                        Iconsax.trash,
                                                      ),
                                                      SizedBox(
                                                        width: 10.0,
                                                      ),
                                                      Text("Unlike"),
                                                    ],
                                                  ),
                                                ),
                                                PopupMenuItem(
                                                  value: 2,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Iconsax.music_play,
                                                        color: Theme.of(context)
                                                            .iconTheme
                                                            .color,
                                                      ),
                                                      const SizedBox(
                                                          width: 10.0),
                                                      const Text('Play next'),
                                                    ],
                                                  ),
                                                ),
                                                PopupMenuItem(
                                                  value: 1,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Iconsax.music_play,
                                                        color: Theme.of(context)
                                                            .iconTheme
                                                            .color,
                                                      ),
                                                      const SizedBox(
                                                          width: 10.0),
                                                      const Text(
                                                          'Add to queue'),
                                                    ],
                                                  ),
                                                ),
                                                PopupMenuItem(
                                                  value: 0,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .playlist_add_rounded,
                                                        color: Theme.of(context)
                                                            .iconTheme
                                                            .color,
                                                      ),
                                                      const SizedBox(
                                                          width: 10.0),
                                                      const Text(
                                                          'Add to playlist'),
                                                    ],
                                                  ),
                                                ),
                                                PopupMenuItem(
                                                  value: 4,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Iconsax.music_library_2,
                                                        color: Theme.of(context)
                                                            .iconTheme
                                                            .color,
                                                      ),
                                                      const SizedBox(
                                                          width: 10.0),
                                                      const Text('View Album'),
                                                    ],
                                                  ),
                                                ),
                                                PopupMenuItem(
                                                  value: 5,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        EvaIcons.person,
                                                        color: Theme.of(context)
                                                            .iconTheme
                                                            .color,
                                                      ),
                                                      const SizedBox(
                                                          width: 10.0),
                                                      const Text('View Artist'),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                              onSelected: (int? value) {
                                                final MediaItem mediaItem =
                                                    MediaItemConverter
                                                        .mapToMediaItem(
                                                            widget.songs[index]
                                                                as Map);

                                                if (value == 4) {
                                                  Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                      opaque: false,
                                                      pageBuilder:
                                                          (_, __, ___) =>
                                                              SongsListPage(
                                                        listItem: {
                                                          'type': 'album',
                                                          'id':
                                                              mediaItem.extras?[
                                                                  'album_id'],
                                                          'title':
                                                              mediaItem.album,
                                                          'image':
                                                              mediaItem.artUri,
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                }
                                                if (value == 5) {
                                                  Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                      opaque: false,
                                                      pageBuilder:
                                                          (_, __, ___) =>
                                                              AlbumSearchPage(
                                                        query: mediaItem.artist
                                                            .toString()
                                                            .split(', ')
                                                            .first,
                                                        type: 'Artists',
                                                      ),
                                                    ),
                                                  );
                                                }
                                                if (value == 6) {
                                                  widget.onDelete;
                                                  setState(() {});
                                                }
                                                if (value == 0) {
                                                  AddToPlaylist().addToPlaylist(
                                                      context, mediaItem);
                                                }
                                                if (value == 1) {
                                                  addOfflineToNowPlaying(
                                                      context: context,
                                                      mediaItem: mediaItem);
                                                }
                                                if (value == 2) {
                                                  playOfflineNext(
                                                      mediaItem, context);
                                                }
                                              },
                                            )
                                          ]),
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
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
