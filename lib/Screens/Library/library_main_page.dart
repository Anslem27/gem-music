import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gem/Screens/Library/favorites_section.dart';
import 'package:gem/Screens/LocalMusic/local_music.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';


class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    // final double screenWidth = MediaQuery.of(context).size.width;
    // final bool rotated = MediaQuery.of(context).size.height < screenWidth;
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 9, top: 20),
          child: AppBar(
            title: Row(
              children: [
                Image.asset("assets/library.png", height: 40, width: 40),
                const SizedBox(width: 10),
                Text(
                  "Your Library",
                  style: GoogleFonts.roboto(
                    color: Theme.of(context).iconTheme.color,
                    fontSize: 28,
                  ),
                ),
              ],
            ),
            centerTitle: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            // leading: IconButton(
            //     onPressed: () {
            //       Navigator.push(
            //           context, MaterialPageRoute(builder: (_) => PrefScreen()));
            //     },
            //     icon: Icon(Icons.add)),
            // leading: (rotated && screenWidth < 1050)
            //     ? null
            //     : Builder(
            //         builder: (BuildContext context) {
            //           return Transform.rotate(
            //             angle: 22 / 7 * 2,
            //             child: IconButton(
            //               color: Theme.of(context).iconTheme.color,
            //               icon: const Icon(
            //                 Icons.horizontal_split_rounded,
            //               ),
            //               onPressed: () {
            //                 Scaffold.of(context).openDrawer();
            //               },
            //               tooltip: MaterialLocalizations.of(context)
            //                   .openAppDrawerTooltip,
            //             ),
            //           );
            //         },
            //       ),
          ),
        ),
        LibraryTile(
          title: AppLocalizations.of(context)!.nowPlaying,
          icon: Icons.queue_music_rounded,
          onTap: () {
            Navigator.pushNamed(context, '/nowplaying');
          },
        ),
        LibraryTile(
          title: AppLocalizations.of(context)!.lastSession,
          icon: Icons.history_rounded,
          onTap: () {
            Navigator.pushNamed(context, '/recent');
          },
        ),
        LibraryTile(
          title: AppLocalizations.of(context)!.favorites,
          icon: Icons.favorite_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LikedSongs(
                  playlistName: 'Favorite Songs',
                  showName: AppLocalizations.of(context)!.favSongs,
                ),
              ),
            );
          },
        ),
        if (!Platform.isIOS)
          LibraryTile(
            title: "My Music",
            icon: MdiIcons.folderMusic,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DownloadedSongs(
                    showPlaylists: true,
                  ),
                ),
              );
            },
          ),
        LibraryTile(
          title: AppLocalizations.of(context)!.downs,
          icon: Icons.download_done_rounded,
          onTap: () {
            Navigator.pushNamed(context, '/downloads');
          },
        ),
        LibraryTile(
          title: AppLocalizations.of(context)!.playlists,
          icon: Icons.playlist_play_rounded,
          onTap: () {
            Navigator.pushNamed(context, '/playlists');
          },
        ),
      ],
    );
  }
}

class LibraryTile extends StatelessWidget {
  const LibraryTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.roboto(
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        leading: Icon(
          icon,
          color: Theme.of(
            context,
          ).colorScheme.secondary,
        ),
        onTap: onTap,
      ),
    );
  }
}
