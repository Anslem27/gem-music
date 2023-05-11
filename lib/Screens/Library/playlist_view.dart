// ignore_for_file: always_use_package_imports

import 'package:flutter/material.dart';
import 'package:gem/Screens/Library/online_playlists.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';
import '../../widgets/gradient_containers.dart';
import '../../Helpers/local_music_functions.dart';
import '../local/localplaylists.dart';

class PlaylistView extends StatefulWidget {
  const PlaylistView({super.key});

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView>
    with TickerProviderStateMixin {
  TabController? _tcontroller;
  List<PlaylistModel> playlistDetails = [];
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();

  @override
  void initState() {
    _tcontroller = TabController(length: 2, vsync: this);
    fillData();
    super.initState();
  }

  Future<void> fillData() async {
    playlistDetails = await offlineAudioQuery.getPlaylists();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _tcontroller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool rotated =
        MediaQuery.of(context).size.height < MediaQuery.of(context).size.width;

    double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.height / 2.5;
    //get dorminant color from image rendered
    Future<Color> getdominantColor(ImageProvider imageProvider) async {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(imageProvider);

      return paletteGenerator.dominantColor!.color;
    }

    return GradientContainer(
        child: FutureBuilder<Color>(
            future: getdominantColor(const AssetImage("assets/lyrics.png")),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Scaffold(
                backgroundColor: Colors.transparent,
                body: NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        elevation: 0,
                        backgroundColor: Theme.of(context).cardColor,
                        stretch: true,
                        pinned: true,
                        centerTitle: true,
                        expandedHeight:
                            MediaQuery.of(context).size.height * 0.35,
                        bottom: TabBar(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          controller: _tcontroller,
                          indicator: MaterialIndicator(
                            horizontalPadding: 32,
                            color: Theme.of(context).focusColor,
                            height: 6,
                          ),
                          tabs: const [
                            Padding(
                              padding: EdgeInsets.only(bottom: 10.0),
                              child: Text(
                                "Online",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 10.0),
                              child: Text(
                                "Offline",
                                style: TextStyle(fontSize: 18),
                              ),
                            )
                          ],
                        ),
                        flexibleSpace: LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            double top = constraints.biggest.height;
                            if (top >
                                MediaQuery.of(context).size.height * 0.45) {
                              top = MediaQuery.of(context).size.height * 0.45;
                            }
                            return FlexibleSpaceBar(
                              centerTitle: true,
                              background: GlassmorphicContainer(
                                width: double.maxFinite,
                                height: double.maxFinite,
                                borderRadius: 0,
                                blur: 20,
                                alignment: Alignment.bottomCenter,
                                border: 2,
                                linearGradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      snapshot.data?.withOpacity(0.9) as Color,
                                      snapshot.data?.withOpacity(0.05) as Color,
                                    ],
                                    stops: const [
                                      0.1,
                                      1,
                                    ]),
                                borderGradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.transparent,
                                    Colors.transparent
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    if (!rotated)
                                      Align(
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 15.0),
                                              child: SizedBox(
                                                height: boxSize,
                                                child: Image.asset(
                                                    "assets/lyrics.png"),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (rotated)
                                      Align(
                                        alignment: const Alignment(-0.85, 0.5),
                                        child: Card(
                                          elevation: 5,
                                          color: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(7.0),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.3,
                                            child: Image.asset(
                                                "assets/lyrics.png"),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tcontroller,
                    children: [
                      const OnlinePlaylistScreen(),
                      LocalPlaylists(
                        playlistDetails: playlistDetails,
                        offlineAudioQuery: offlineAudioQuery,
                      ),
                    ],
                  ),
                ),
              );
            }));
  }
}
