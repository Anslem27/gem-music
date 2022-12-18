import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gem/CustomWidgets/gradient_containers.dart';
import 'package:gem/Helpers/local_music_functions.dart';
import 'package:gem/Screens/Player/music_player.dart';
import 'package:on_audio_query/on_audio_query.dart';

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
        headline6:
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
        headline6:
            const TextStyle(fontWeight: FontWeight.normal, color: Colors.white),
      ),
      inputDecorationTheme:
          const InputDecorationTheme(focusedBorder: InputBorder.none),
    );
  }
}
