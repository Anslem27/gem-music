import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:gem/Screens/Settings/about.dart';
import 'package:gem/animations/custompageroute.dart';
import 'package:get_it/get_it.dart';
import '../../../widgets/gradient_containers.dart';
import '../../../animations/equalizer.dart';
import '../../Player/music_player.dart';
import '../../settings/setting.dart';
import '../../local/local_music.dart';
import 'drawer/drawer_tile.dart';
import 'drawer/drawer_top_component.dart';

class GemDrawer extends StatefulWidget {
  const GemDrawer({super.key});

  @override
  State<GemDrawer> createState() => _GemDrawerState();
}

class _GemDrawerState extends State<GemDrawer> {
  bool _isCollapsed = false;
  @override
  Widget build(BuildContext context) {
    AudioPlayerHandler audioHandler = GetIt.I<AudioPlayerHandler>();

    void callback() {
      Navigator.pop(context);
    }

    return SafeArea(
        child: AnimatedContainer(
      curve: Curves.easeInOutCubic,
      duration: const Duration(milliseconds: 500),
      width: _isCollapsed ? 300 : 70,
      margin: const EdgeInsets.only(bottom: 5, top: 5, left: 5),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            topLeft: Radius.circular(10)),
        color: Color.fromRGBO(20, 20, 20, 1),
      ),
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

                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Stack(
                      children: [
                        _isCollapsed
                            ? positionedGemLogo(context)
                            : const SizedBox(),
                        _isCollapsed
                            ? CustomScrollView(
                                //shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                slivers: [
                                  sliverAppBar(context, mediaItem),
                                  SliverList(
                                    delegate: SliverChildListDelegate(
                                      [
                                        const SizedBox(height: 10),
                                        _isCollapsed &&
                                                snapshot.connectionState !=
                                                    ConnectionState.active
                                            ? const SizedBox()
                                            : musicVisualizerComponent(),
                                        const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text("Now Playing"),
                                        ),
                                        AnimatedContainer(
                                          curve: Curves.easeInOutCubic,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          margin: const EdgeInsets.only(
                                              left: 5, right: 5),
                                          child: Padding(
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
                                                  subtitle: Text(mediaItem
                                                      .artist as String),
                                                ))
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        AnimatedContainer(
                                          curve: Curves.easeInOutCubic,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          child: CustomListTile(
                                            isCollapsed: _isCollapsed,
                                            icon: EvaIcons.home,
                                            title: 'Home',
                                            ontap: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                        if (Platform.isAndroid)
                                          CustomListTile(
                                            isCollapsed: _isCollapsed,
                                            icon: EvaIcons.music,
                                            title: 'Local Music',
                                            ontap: () {
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
                                        CustomListTile(
                                          isCollapsed: _isCollapsed,
                                          icon: EvaIcons.cloudDownload,
                                          title: 'Downloads',
                                          ontap: () {
                                            Navigator.pop(context);
                                            Navigator.pushNamed(
                                                context, '/downloads');
                                          },
                                        ),
                                        CustomListTile(
                                          isCollapsed: _isCollapsed,
                                          icon: Icons.playlist_play,
                                          title: 'Playlists',
                                          ontap: () {
                                            Navigator.pop(context);
                                            Navigator.pushNamed(
                                                context, '/playlists');
                                          },
                                        ),
                                        const Divider(color: Colors.grey),
                                        //const Spacer(),
                                        CustomListTile(
                                          isCollapsed: _isCollapsed,
                                          icon: Icons.settings,
                                          title: 'Settings',
                                          ontap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SettingPage(
                                                  callback: () => callback,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              splashColor: Colors.transparent,
                                              icon: Icon(
                                                _isCollapsed
                                                    ? Icons.arrow_back_ios
                                                    : Icons.arrow_forward_ios,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _isCollapsed = !_isCollapsed;
                                                });
                                              },
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : halfDrawerBody(mediaItem, snapshot),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    ));
  }

  sliverAppBar(BuildContext context, MediaItem mediaItem) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0,
      stretch: true,
      expandedHeight: MediaQuery.of(context).size.height * 0.3,
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
          child: (mediaItem.artUri.toString().startsWith('file:'))
              ? Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: AnimatedContainer(
                    curve: Curves.easeInOutCubic,
                    duration: const Duration(milliseconds: 500),
                    height: 250,
                    margin: const EdgeInsets.only(bottom: 5, top: 5, left: 0),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          topLeft: Radius.circular(10)),
                      color: Color.fromRGBO(20, 20, 20, 1),
                    ),
                    child: SizedBox.square(
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
                    ),
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
    );
  }

  halfDrawerBody(MediaItem mediaItem, AsyncSnapshot<MediaItem?> snapshot) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GemDrawerTopComponent(isColapsed: _isCollapsed),
        const Divider(
          color: Colors.grey,
        ),
        const SizedBox(height: 5),
        const SizedBox(height: 5),
        drawerBodySection()
      ],
    );
  }

  drawerBodySection() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomListTile(
            isCollapsed: _isCollapsed,
            icon: EvaIcons.home,
            title: 'Home',
            ontap: () {
              Navigator.pop(context);
            },
          ),
          if (Platform.isAndroid)
            CustomListTile(
              isCollapsed: _isCollapsed,
              icon: EvaIcons.music,
              title: 'Local Music',
              ontap: () {
                Navigator.pop(context);
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
          CustomListTile(
            isCollapsed: _isCollapsed,
            icon: EvaIcons.cloudDownload,
            title: 'Downloads',
            ontap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/downloads');
            },
          ),
          CustomListTile(
            isCollapsed: _isCollapsed,
            icon: Icons.playlist_play,
            title: 'Playlists',
            ontap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/playlists');
            },
          ),
          const Divider(color: Colors.grey),
          const Spacer(),
          CustomListTile(
            isCollapsed: _isCollapsed,
            icon: Icons.settings,
            title: 'Settings',
            ontap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingPage(
                    callback: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          BottomDrawerComponent(isCollapsed: _isCollapsed),
          Align(
            alignment:
                _isCollapsed ? Alignment.bottomRight : Alignment.bottomCenter,
            child: IconButton(
              splashColor: Colors.transparent,
              icon: Icon(
                _isCollapsed ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
              onPressed: () {
                setState(() {
                  _isCollapsed = !_isCollapsed;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  SizedBox musicVisualizerComponent() {
    return SizedBox(
      height: _isCollapsed ? 50 : 30,
      child: AnimatedContainer(
        curve: Curves.easeInOutCubic,
        duration: const Duration(milliseconds: 500),
        width: _isCollapsed ? 300 : 70,
        margin: const EdgeInsets.only(bottom: 2, top: 2),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              topLeft: Radius.circular(10)),
        ),
        child: MusicVisualizer(),
      ),
    );
  }

  Positioned positionedGemLogo(BuildContext context) {
    return Positioned(
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
    );
  }
}

class BottomDrawerComponent extends StatelessWidget {
  final bool isCollapsed;

  const BottomDrawerComponent({
    Key? key,
    required this.isCollapsed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isCollapsed ? 70 : 90,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: isCollapsed
          ? const SizedBox()
          : Column(
              children: [
                /* Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: CircleAvatar(
                      //borderRadius: BorderRadius.circular(20),
                      child: Container(
                        margin: const EdgeInsets.only(),
                        color: Colors.transparent,
                        child: SizedBox(
                          height: 20,
                          child: MusicVisualizer(),
                        ),
                      ),
                    ),
                  ),
                ), */
                Expanded(
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        FadeTransitionPageRoute(
                          child: const AboutScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      //size: 18,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
