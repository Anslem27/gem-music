import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:gem/Screens/Settings/about.dart';
import 'package:gem/animations/custompageroute.dart';
import 'package:get_it/get_it.dart';
import 'package:iconsax/iconsax.dart';
import 'package:palette_generator/palette_generator.dart';
import '../../../widgets/gradient_containers.dart';
import '../../../animations/equalizer.dart';
import '../../Player/music_player.dart';
import '../../settings/setting.dart';
import '../../local/local_music.dart';

Drawer gemDrawer(BuildContext context) {
  //super.build(context);
  AudioPlayerHandler audioHandler = GetIt.I<AudioPlayerHandler>();

  //get dorminant color from image rendered
  Future<Color> getdominantColor(ImageProvider imageProvider) async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider);
    return paletteGenerator.dominantColor!.color;
  }

  void callback() {
    Navigator.pop(context);
  }

  return Drawer(
    child: GradientContainer(
      child: StreamBuilder<PlaybackState>(
        stream: audioHandler.playbackState,
        builder: (_, snapshot) {
          final playbackState = snapshot.data;
          final processingState = playbackState?.processingState;
          if (processingState == AudioProcessingState.idle) {
            return const SizedBox();
          }
          return StreamBuilder<MediaItem?>(
            stream: audioHandler.mediaItem,
            builder: (_, snapshot) {
              if (snapshot.connectionState != ConnectionState.active) {
                return const SizedBox();
              }
              final mediaItem = snapshot.data;
              if (mediaItem == null) return const SizedBox();

              return FutureBuilder(
                future: getdominantColor(
                  (mediaItem.artUri.toString().startsWith('file:'))
                      ? FileImage(
                          File(
                            mediaItem.artUri!.toFilePath(),
                          ),
                        )
                      : NetworkImage(mediaItem.artUri.toString())
                          as ImageProvider,
                ),
                builder: (_, AsyncSnapshot<Color> colorSnapshot) {
                  return CustomScrollView(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverAppBar(
                        backgroundColor: Colors.transparent,
                        automaticallyImplyLeading: false,
                        elevation: 0,
                        stretch: true,
                        expandedHeight:
                            MediaQuery.of(context).size.height * 0.3,
                        flexibleSpace: FlexibleSpaceBar(
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
                            child: (mediaItem.artUri
                                    .toString()
                                    .startsWith('file:'))
                                ? SizedBox.square(
                                    dimension: 55.0,
                                    child: Image(
                                      fit: BoxFit.cover,
                                      image: FileImage(
                                        File(
                                          mediaItem.artUri!.toFilePath(),
                                        ),
                                      ),
                                      // loadingBuilder: (_, __, ___) {
                                      //   return Image.asset(
                                      //     'assets/cover.jpg',
                                      //   );
                                      // },
                                      errorBuilder: (_, __, ___) {
                                        // if (widget.songs[index]['image'] != null &&
                                        //     widget.songs[index]['image_url'] !=
                                        //         null) {
                                        //   downImage(
                                        //     widget.songs[index]['image'].toString(),
                                        //     widget.songs[index]['path'].toString(),
                                        //     widget.songs[index]['image_url']
                                        //         .toString(),
                                        //   );
                                        // }
                                        return Image.asset(
                                          'assets/cover.jpg',
                                        );
                                      },
                                    ),
                                  )
                                : SizedBox.square(
                                    dimension: 55,
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      errorWidget: (
                                        BuildContext context,
                                        _,
                                        __,
                                      ) =>
                                          const Image(
                                        fit: BoxFit.cover,
                                        image: AssetImage(
                                          'assets/cover.jpg',
                                        ),
                                      ),
                                      placeholder: (
                                        BuildContext context,
                                        _,
                                      ) =>
                                          const Image(
                                        fit: BoxFit.cover,
                                        image: AssetImage(
                                          'assets/cover.jpg',
                                        ),
                                      ),
                                      imageUrl: mediaItem.artUri.toString(),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            const SizedBox(height: 10),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Now Playing"),
                            ),
                            snapshot.connectionState != ConnectionState.active
                                ? const SizedBox()
                                : SizedBox(
                                    height: 50,
                                    child: MusicVisualizer(),
                                  ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 35,
                                    backgroundImage: AssetImage(
                                        "assets/ic_launcher_no_bg.png"),
                                  ),
                                  Expanded(
                                      child: ListTile(
                                    title: Text(mediaItem.title),
                                    subtitle: Text(mediaItem.artist as String),
                                  ))
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            ListTile(
                              title: Text(
                                "Home",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              leading: Icon(
                                EvaIcons.home,
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
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                leading: Icon(
                                  Iconsax.music,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DownloadedSongs(
                                        showPlaylists: true,
                                        fromHomElement: false,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ListTile(
                              title: const Text('Downloads'),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
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
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
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
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              leading: Icon(
                                EvaIcons.settings2,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              onTap: () {
                                // Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SettingPage(
                                      callback: () => callback,
                                    ),
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
                            const Divider(
                              color: Colors.grey,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5, 30, 5, 20),
                              child: ListTile(
                                title: const Text("About"),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                leading: Icon(
                                  Iconsax.info_circle,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    FadeTransitionPageRoute(
                                      child: const AboutScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    ),
  );
}
