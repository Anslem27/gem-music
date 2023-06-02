// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gem/widgets/gradient_containers.dart';
import 'package:gem/Helpers/local_music_functions.dart';
import 'package:gem/Screens/Player/music_player.dart';
import 'package:iconsax/iconsax.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../Helpers/add_mediaitem_to_queue.dart';
import '../Screens/local/pages/detail_page.dart';
import 'add_playlist.dart';
import 'like_button.dart';

class DataSearch extends SearchDelegate {
  final List<SongModel> data;
  final String tempPath;

  DataSearch({required this.data, required this.tempPath}) : super();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isEmpty)
        IconButton(
          splashRadius: 24,
          icon: const Icon(CupertinoIcons.search),
          tooltip: 'Search',
          onPressed: () {},
        )
      else
        IconButton(
          splashRadius: 24,
          onPressed: () {
            query = '';
          },
          tooltip: 'Clear',
          icon: const Icon(
            Icons.clear_rounded,
          ),
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      splashRadius: 24,
      icon: const Icon(CupertinoIcons.chevron_back),
      tooltip: 'Back',
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? data
        : [
            ...{
              ...data
                  .where(
                    (element) => element.title
                        .toLowerCase()
                        .contains(query.toLowerCase()),
                  )
                  .toList(),
              ...data
                  .where(
                    (element) => element.artist!
                        .toLowerCase()
                        .contains(query.toLowerCase()),
                  )
                  .toList(),
            }
          ];
    return GradientContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          shrinkWrap: true,
          itemExtent: 70.0,
          itemCount: suggestionList.length,
          itemBuilder: (context, index) => ListTile(
            leading: OfflineAudioQuery.offlineArtworkWidget(
              id: suggestionList[index].id,
              type: ArtworkType.AUDIO,
              tempPath: tempPath,
              fileName: suggestionList[index].displayNameWOExt,
            ),
            title: Text(
              suggestionList[index].title.trim() != ''
                  ? suggestionList[index].title
                  : suggestionList[index].displayNameWOExt,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              suggestionList[index].artist! == '<unknown>'
                  ? 'Unknown'
                  : suggestionList[index].artist!,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () async {
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (_, __, ___) => PlayScreen(
                    songsList: suggestionList,
                    index: index,
                    offline: true,
                    fromMiniplayer: false,
                    fromDownloads: false,
                    recommend: false,
                  ),
                ),
              );
            },
            trailing: IconButton(
              onPressed: () {
                showModalBottomSheet(
                  isDismissible: true,
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (BuildContext context) {
                    OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
                    String playTitle = data[index].title;
                    playTitle == ''
                        ? playTitle = data[index].displayNameWOExt
                        : playTitle = data[index].title;
                    String playArtist = data[index].artist!;
                    playArtist == '<unknown>'
                        ? playArtist = 'Unknown'
                        : playArtist = data[index].artist!;

                    final String playAlbum = data[index].album!;
                    final int playDuration = data[index].duration ?? 180000;
                    final String imagePath =
                        '$tempPath}/${data[index].displayNameWOExt}.png';

                    final MediaItem mediaItem = MediaItem(
                      id: data[index].id.toString(),
                      album: playAlbum,
                      duration: Duration(milliseconds: playDuration),
                      title: playTitle.split('(')[0],
                      artist: playArtist,
                      genre: data[index].genre,
                      artUri: Uri.file(imagePath),
                      extras: {
                        'url': data[index].data,
                        'date_added': data[index].dateAdded,
                        'date_modified': data[index].dateModified,
                        'size': data[index].size,
                        'year': data[index].getMap['year'],
                      },
                    );
                    return SizedBox(
                      child: BottomGradientContainer(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ListTile(
                                leading: OfflineAudioQuery.offlineArtworkWidget(
                                  id: data[index].id,
                                  type: ArtworkType.AUDIO,
                                  height: 50,
                                  width: 50,
                                  tempPath: tempPath,
                                  fileName: data[index].displayNameWOExt,
                                ),
                                title: Text(
                                  data[index].title.toUpperCase(),
                                  textAlign: TextAlign.start,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                subtitle: Text(
                                  data[index].artist as String,
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
                              addOfflineToNowPlaying(
                                  context: context, mediaItem: mediaItem);
                              Navigator.pop(context);
                            }, EvaIcons.fileAdd),
                            _sheetTile("Add to playlist", () {
                              AddToOffPlaylist().addToOffPlaylist(
                                context,
                                data[index].id,
                              );
                              Navigator.pop(context);
                            }, Iconsax.music_playlist),
                            _sheetTile("View Album", () async {
                              var albumSongs = await offlineAudioQuery
                                  .getAlbumSongs(data[index].albumId as int);

                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => LocalMusicsDetail(
                                    title: data[index].album as String,
                                    id: data[index].id,
                                    certainCase: 'album',
                                    songs: albumSongs,
                                  ),
                                ),
                              ).then((value) => Navigator.pop(context));
                            }, Icons.album_outlined),
                            _sheetTile("View Artist", () async {
                              var albumSongs =
                                  await offlineAudioQuery.getArtistsByName(
                                      data[index].artist as String);

                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => LocalMusicsDetail(
                                    title: data[index].artist as String,
                                    id: data[index].id,
                                    certainCase: 'artist',
                                    songs: albumSongs,
                                  ),
                                ),
                              ).then((value) => Navigator.pop(context));
                            }, EvaIcons.person),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              icon: const Icon(
                EvaIcons.moreVertical,
              ),
            ),
          ),
        ),
      ),
    );
  }

  ListTile _sheetTile(String title, Function()? ontap, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: ontap,
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final suggestionList = query.isEmpty
        ? data
        : [
            ...{
              ...data
                  .where(
                    (element) => element.title
                        .toLowerCase()
                        .contains(query.toLowerCase()),
                  )
                  .toList(),
              ...data
                  .where(
                    (element) => element.artist!
                        .toLowerCase()
                        .contains(query.toLowerCase()),
                  )
                  .toList(),
            }
          ];
    return GradientContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          shrinkWrap: true,
          itemExtent: 70.0,
          itemCount: suggestionList.length,
          itemBuilder: (context, index) => ListTile(
            leading: OfflineAudioQuery.offlineArtworkWidget(
              id: suggestionList[index].id,
              type: ArtworkType.AUDIO,
              tempPath: tempPath,
              fileName: suggestionList[index].displayNameWOExt,
            ),
            title: Text(
              suggestionList[index].title.trim() != ''
                  ? suggestionList[index].title
                  : suggestionList[index].displayNameWOExt,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              suggestionList[index].artist! == '<unknown>'
                  ? 'Unknown'
                  : suggestionList[index].artist!,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () async {
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (_, __, ___) => PlayScreen(
                    songsList: suggestionList,
                    index: index,
                    offline: true,
                    fromMiniplayer: false,
                    fromDownloads: false,
                    recommend: false,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: Theme.of(context).colorScheme.secondary,
      textSelectionTheme:
          const TextSelectionThemeData(cursorColor: Colors.white),
      hintColor: Colors.white70,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.white),
      textTheme: theme.textTheme.copyWith(
        titleLarge:
            const TextStyle(fontWeight: FontWeight.normal, color: Colors.white),
      ),
      inputDecorationTheme:
          const InputDecorationTheme(focusedBorder: InputBorder.none),
    );
  }
}

class DownloadsSearch extends SearchDelegate {
  final bool isDowns;
  final List data;

  DownloadsSearch({required this.data, this.isDowns = false});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isEmpty)
        IconButton(
          splashRadius: 24,
          icon: const Icon(CupertinoIcons.search),
          tooltip: 'Search',
          onPressed: () {},
        )
      else
        IconButton(
          splashRadius: 24,
          onPressed: () {
            query = '';
          },
          tooltip: 'Clear',
          icon: const Icon(
            Icons.clear_rounded,
          ),
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      splashRadius: 24,
      icon: const Icon(CupertinoIcons.chevron_back),
      tooltip: 'Back',
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? data
        : [
            ...{
              ...data
                  .where(
                    (element) => element['title']
                        .toString()
                        .toLowerCase()
                        .contains(query.toLowerCase()),
                  )
                  .toList(),
              ...data
                  .where(
                    (element) => element['artist']
                        .toString()
                        .toLowerCase()
                        .contains(query.toLowerCase()),
                  )
                  .toList(),
            }
          ];
    return GradientContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          shrinkWrap: true,
          itemExtent: 70.0,
          itemCount: suggestionList.length,
          itemBuilder: (context, index) => ListTile(
            leading: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: SizedBox.square(
                dimension: 50,
                child: isDowns
                    ? Image(
                        fit: BoxFit.cover,
                        image: FileImage(
                          File(suggestionList[index]['image'].toString()),
                        ),
                        errorBuilder: (_, __, ___) =>
                            Image.asset('assets/cover.jpg'),
                      )
                    : CachedNetworkImage(
                        fit: BoxFit.cover,
                        errorWidget: (context, _, __) => const Image(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/cover.jpg'),
                        ),
                        imageUrl: suggestionList[index]['image']
                            .toString()
                            .replaceAll('http:', 'https:'),
                        placeholder: (context, url) => const Image(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/cover.jpg'),
                        ),
                      ),
              ),
            ),
            title: Text(
              suggestionList[index]['title'].toString(),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              suggestionList[index]['artist'].toString(),
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (_, __, ___) => PlayScreen(
                    songsList: suggestionList,
                    index: index,
                    offline: isDowns,
                    fromMiniplayer: false,
                    fromDownloads: isDowns,
                    recommend: false,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final suggestionList = query.isEmpty
        ? data
        : [
            ...{
              ...data
                  .where(
                    (element) => element['title']
                        .toString()
                        .toLowerCase()
                        .contains(query.toLowerCase()),
                  )
                  .toList(),
              ...data
                  .where(
                    (element) => element['artist']
                        .toString()
                        .toLowerCase()
                        .contains(query.toLowerCase()),
                  )
                  .toList(),
            }
          ];
    return GradientContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          shrinkWrap: true,
          itemExtent: 70.0,
          itemCount: suggestionList.length,
          itemBuilder: (context, index) => ListTile(
            leading: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: SizedBox.square(
                dimension: 50,
                child: isDowns
                    ? Image(
                        fit: BoxFit.cover,
                        image: FileImage(
                          File(suggestionList[index]['image'].toString()),
                        ),
                        errorBuilder: (_, __, ___) =>
                            Image.asset('assets/cover.jpg'),
                      )
                    : CachedNetworkImage(
                        fit: BoxFit.cover,
                        errorWidget: (context, _, __) => const Image(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/cover.jpg'),
                        ),
                        imageUrl: suggestionList[index]['image']
                            .toString()
                            .replaceAll('http:', 'https:'),
                        placeholder: (context, url) => const Image(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/cover.jpg'),
                        ),
                      ),
              ),
            ),
            title: Text(
              suggestionList[index]['title'].toString(),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              suggestionList[index]['artist'].toString(),
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (_, __, ___) => PlayScreen(
                    songsList: suggestionList,
                    index: index,
                    offline: isDowns,
                    fromMiniplayer: false,
                    fromDownloads: isDowns,
                    recommend: false,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: Theme.of(context).colorScheme.secondary,
      textSelectionTheme:
          const TextSelectionThemeData(cursorColor: Colors.white),
      hintColor: Colors.white70,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.white),
      textTheme: theme.textTheme.copyWith(
        titleLarge:
            const TextStyle(fontWeight: FontWeight.normal, color: Colors.white),
      ),
      inputDecorationTheme:
          const InputDecorationTheme(focusedBorder: InputBorder.none),
    );
  }
}
