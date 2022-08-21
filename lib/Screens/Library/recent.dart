// ignore_for_file: use_colored_box, avoid_redundant_argument_values

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gem/CustomWidgets/gradient_containers.dart';
import 'package:gem/CustomWidgets/miniplayer.dart';
import 'package:gem/Screens/Player/audioplayer_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';

class RecentlyPlayed extends StatefulWidget {
  @override
  _RecentlyPlayedState createState() => _RecentlyPlayedState();
}

class _RecentlyPlayedState extends State<RecentlyPlayed> {
  List _songs = [];
  bool added = false;

  Future<void> getSongs() async {
    _songs = Hive.box('cache').get('recentSongs', defaultValue: []) as List;
    added = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!added) {
      getSongs();
    }

    return GradientContainer(
      child: Column(
        children: [
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.lastSession),
                centerTitle: true,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.transparent
                    : Theme.of(context).colorScheme.secondary,
                elevation: 0,
                actions: [
                  IconButton(
                    onPressed: () {
                      Hive.box('cache').put('recentSongs', []);
                      setState(() {
                        _songs = [];
                      });
                    },
                    tooltip: AppLocalizations.of(context)!.clearAll,
                    icon: const Icon(Icons.clear_all_rounded),
                  ),
                ],
              ),
              body: _songs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset("assets/Puzzle.png",
                              height: 100, width: 100),
                          Text(
                            "Nothing to show here",
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      shrinkWrap: true,
                      itemCount: _songs.length,
                      itemExtent: 70.0,
                      itemBuilder: (context, index) {
                        return _songs.isEmpty
                            ? const SizedBox()
                            : Dismissible(
                                key: Key(_songs[index]['id'].toString()),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.redAccent,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: const [
                                        Icon(Iconsax.trash),
                                      ],
                                    ),
                                  ),
                                ),
                                onDismissed: (direction) {
                                  _songs.removeAt(index);
                                  setState(() {});
                                  Hive.box('cache').put('recentSongs', _songs);
                                },
                                child: ListTile(
                                  leading: Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      errorWidget: (context, _, __) =>
                                          const Image(
                                        fit: BoxFit.cover,
                                        image: AssetImage('assets/cover.jpg'),
                                      ),
                                      imageUrl: _songs[index]['image']
                                          .toString()
                                          .replaceAll('http:', 'https:'),
                                      placeholder: (context, url) =>
                                          const Image(
                                        fit: BoxFit.cover,
                                        image: AssetImage('assets/cover.jpg'),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    '${_songs[index]["title"]}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    '${_songs[index]["artist"]}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        opaque: false,
                                        pageBuilder: (_, __, ___) => PlayScreen(
                                          songsList: _songs,
                                          index: index,
                                          offline: false,
                                          fromDownloads: false,
                                          fromMiniplayer: false,
                                          recommend: true,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                      },
                    ),
            ),
          ),
          const MiniPlayer(),
        ],
      ),
    );
  }
}
