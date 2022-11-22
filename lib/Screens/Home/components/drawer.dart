import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../CustomWidgets/gradient_containers.dart';
import '../../LocalMusic/local_music.dart';
import '../../Settings/setting.dart';

Drawer appDrawer(BuildContext context) {
  return Drawer(
    child: GradientContainer(
      child: CustomScrollView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            elevation: 0,
            stretch: true,
            expandedHeight: MediaQuery.of(context).size.height * 0.2,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Gem\nMusic',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
              titlePadding: const EdgeInsets.only(bottom: 40.0),
              centerTitle: true,
              background: ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.1),
                    ],
                  ).createShader(
                    Rect.fromLTRB(0, 0, rect.width, rect.height),
                  );
                },
                blendMode: BlendMode.dstIn,
                child: const Image(
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  image: AssetImage(
                    "assets/icon-white-trans.png",
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                ListTile(
                  title: Text(
                    "Home",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: Icon(
                    Iconsax.home,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  selected: true,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                if (Platform.isAndroid)
                  ListTile(
                    title: const Text("Local Music"),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20.0),
                    leading: Icon(
                      Iconsax.music,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onTap: () {
                      Navigator.pop(context);
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
                ListTile(
                  title: const Text('Downloads'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: Icon(
                    Iconsax.document_download,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/downloads');
                  },
                ),
                ListTile(
                  title: const Text('Playlists'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: Icon(
                    Icons.playlist_play_rounded,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/playlists');
                  },
                ),
                ListTile(
                  title: const Text('Settings'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: Icon(
                    Iconsax.setting,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingPage(callback: () {}),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: <Widget>[
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 30, 5, 20),
                  child: ListTile(
                    title: const Text("About"),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20.0),
                    leading: Icon(
                      Iconsax.info_circle,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      //TODO: Add a info dialog
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
