// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gem/Screens/Library/favorites_section.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../local/local_music.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  String category = '';
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: MediaQuery.of(context).size.width / 2.95,
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
        ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 9, top: 20),
              child: AppBar(
                leading: CircleAvatar(
                  radius: 15,
                  child: Image.asset(
                    "assets/ic_launcher_no_bg.png",
                  ),
                ),
                title: Row(
                  children: [
                    const SizedBox(width: 10),
                    Text(
                      "Your Library".toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).iconTheme.color,
                        fontSize: 18.5,
                      ),
                    ),
                  ],
                ),
                centerTitle: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
              ),
            ),
            const SizedBox(height: 25),
            LibraryTile(
              title: 'Now Playing',
              icon: EvaIcons.musicOutline,
              onTap: () {
                Navigator.pushNamed(context, '/nowplaying');
              },
            ),
            LibraryTile(
              title: 'Online last session',
              icon: Icons.history_rounded,
              onTap: () {
                Navigator.pushNamed(context, '/recent');
              },
            ),
            LibraryTile(
              title: 'Favorites',
              icon: EvaIcons.heartOutline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LikedSongs(
                      playlistName: 'Favorite Songs',
                      showName: 'Favourite Songs',
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
                        fromHomElement: false,
                      ),
                    ),
                  );
                },
              ),
            LibraryTile(
              title: 'Downloads',
              icon: EvaIcons.cloudDownloadOutline,
              onTap: () {
                Navigator.pushNamed(context, '/downloads');
              },
            ),
            LibraryTile(
              title: 'Playlists',
              icon: Iconsax.music_dashboard,
              onTap: () {
                Navigator.pushNamed(context, '/playlists');
              },
            ),
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                AnimatedContainer(
                  curve: Curves.easeInOutCubic,
                  duration: const Duration(milliseconds: 500),
                  margin: const EdgeInsets.only(left: 5, right: 5),
                  child: IconButton(
                      splashRadius: 24,
                      onPressed: () {
                        category = '';
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear)),
                ),
                AnimatedContainer(
                  curve: Curves.easeInOutCubic,
                  duration: const Duration(milliseconds: 500),
                  margin: const EdgeInsets.only(left: 5, right: 5),
                  child: ChoiceChip(
                    label: const Text(
                      'Liked Artists',
                    ),
                    selectedColor: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.5),
                    labelStyle: TextStyle(
                      fontWeight:
                          category == '' ? FontWeight.w600 : FontWeight.normal,
                    ),
                    selected: category == '',
                    onSelected: (bool selected) {
                      if (selected) {
                        category = '';
                        setState(() {});
                      }
                    },
                  ),
                ),
                const SizedBox(width: 5),
                AnimatedContainer(
                  curve: Curves.easeInOutCubic,
                  duration: const Duration(milliseconds: 500),
                  child: ChoiceChip(
                    label: const Text(
                      'Genres',
                    ),
                    selectedColor: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: category == 'genres'
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).textTheme.bodyLarge!.color,
                      fontWeight: category == 'genres'
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    selected: category == 'genres',
                    onSelected: (bool selected) {
                      if (selected) {
                        category = 'genres';

                        setState(() {});
                      }
                    },
                  ),
                ),
                AnimatedContainer(
                  curve: Curves.easeInOutCubic,
                  duration: const Duration(milliseconds: 500),
                  child: ChoiceChip(
                    label: const Text(
                      'Playlists',
                    ),
                    selectedColor: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: category == 'playlists'
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).textTheme.bodyLarge!.color,
                      fontWeight: category == 'playlists'
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    selected: category == 'playlists',
                    onSelected: (bool selected) {
                      if (selected) {
                        category = 'playlists';

                        setState(() {});
                      }
                    },
                  ),
                ),
                const SizedBox(width: 5),
              ],
            ),
            category == ""
                ? const SizedBox()
                : category == "genres"
                    ? const SizedBox()
                    : const SizedBox()
          ],
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
          style: GoogleFonts.ubuntu(
              color: Theme.of(context).iconTheme.color, fontSize: 18),
        ),
        leading: Icon(icon, size: 25),
        trailing: const Icon(CupertinoIcons.chevron_forward, size: 20),
        onTap: onTap,
      ),
    );
  }
}
