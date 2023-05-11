// ignore_for_file: use_colored_box, avoid_redundant_argument_values, library_private_types_in_public_api

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem/widgets/gradient_containers.dart';
import 'package:gem/widgets/miniplayer.dart';
import 'package:gem/Screens/Player/music_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';

//TODO: Add recent local songs
class RecentlyPlayed extends StatefulWidget {
  const RecentlyPlayed({Key? key}) : super(key: key);

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
                title: Text(
                  'Previously Played',
                  style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.transparent
                    : Theme.of(context).colorScheme.secondary,
                elevation: 0,
              ),
              floatingActionButton: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: IconButton(
                    splashRadius: 24,
                    onPressed: () {
                      Hive.box('cache').put('recentSongs', []);
                      setState(() {
                        _songs = [];
                      });
                    },
                    tooltip: 'Clear queue',
                    icon: const Icon(Iconsax.trash),
                  ),
                ),
              ),
              body: _songs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset("assets/svg/listening.svg",
                              height: 140, width: 100),
                          const SizedBox(height: 20),
                          Text(
                            "Try playing\nsome music",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(
                              fontSize: 20,
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
