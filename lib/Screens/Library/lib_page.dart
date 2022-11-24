import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gem/Screens/Library/favorites_section.dart';
import 'package:gem/Screens/LocalMusic/local_music.dart';
import 'package:iconsax/iconsax.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 8.0, right: 9, top: 20, bottom: 15),
              child: AppBar(
                leading: SizedBox(
                  height: 25,
                  width: 25,
                  child: Image.asset(
                    "assets/icon-white-trans.png",
                    height: 20,
                    width: 20,
                  ),
                ),
                title: Row(
                  children: [
                    const SizedBox(width: 10),
                    Text(
                      "Your Library",
                      style: TextStyle(
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
              ),
            ),
            const SizedBox(height: 25),
            LibraryTile(
              title: 'Now Playing',
              icon: Iconsax.music,
              onTap: () {
                Navigator.pushNamed(context, '/nowplaying');
              },
            ),
            LibraryTile(
              title: 'Last session',
              icon: Icons.history_rounded,
              onTap: () {
                Navigator.pushNamed(context, '/recent');
              },
            ),
            LibraryTile(
              title: 'Favorites',
              icon: Iconsax.heart,
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
                      ),
                    ),
                  );
                },
              ),
            LibraryTile(
              title: 'Downloads',
              icon: Icons.download_done_rounded,
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
          style:
              TextStyle(color: Theme.of(context).iconTheme.color, fontSize: 18),
        ),
        leading: Icon(icon, size: 25),
        onTap: onTap,
      ),
    );
  }
}