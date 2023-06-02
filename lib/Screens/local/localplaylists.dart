// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:async';
import 'dart:typed_data';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem/widgets/snackbar.dart';
import 'package:gem/widgets/textinput_dialog.dart';
import 'package:gem/Helpers/local_music_functions.dart';
import 'package:gem/Screens/local/local_music.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:hive/hive.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;
import '../Player/music_player.dart';

class LocalPlaylists extends StatefulWidget {
  final List<PlaylistModel> playlistDetails;
  final OfflineAudioQuery offlineAudioQuery;
  const LocalPlaylists({
    Key? key,
    required this.playlistDetails,
    required this.offlineAudioQuery,
  }) : super(key: key);
  @override
  _LocalPlaylistsState createState() => _LocalPlaylistsState();
}

class _LocalPlaylistsState extends State<LocalPlaylists> {
  List<PlaylistModel> playlistDetails = [];
  String? tempPath = Hive.box('settings').get('tempDirPath')?.toString();

  setUpPath() async {
    tempPath ??= (await getTemporaryDirectory()).path;
  }

  @override
  void initState() {
    setUpPath();
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.height / 2.5;

    if (playlistDetails.isEmpty) {
      playlistDetails = widget.playlistDetails;
    }

    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
                  title: const Text(
                    "Create Playlist",
                    style: TextStyle(fontSize: 18),
                  ),
                  leading: const Card(
                    elevation: 0,
                    color: Colors.transparent,
                    child: SizedBox.square(
                      dimension: 50,
                      child: Center(
                        child: Icon(Iconsax.add),
                      ),
                    ),
                  ),
                  onTap: () async {
                    await showTextInputDialog(
                      context: context,
                      title: 'Create New Playlist',
                      initialText: '',
                      keyboardType: TextInputType.name,
                      onSubmitted: (String value) async {
                        if (value.trim() != '') {
                          Navigator.pop(context);
                          await widget.offlineAudioQuery.createPlaylist(
                            name: value,
                          );
                          widget.offlineAudioQuery.getPlaylists().then((value) {
                            playlistDetails = value;
                            setState(() {});
                          });
                        }
                      },
                    );
                    setState(() {});
                  },
                ),
              ),
              if (playlistDetails.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SvgPicture.asset("assets/svg/playlist.svg",
                          height: 140, width: 100),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlistDetails.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    //get dorminant color from image rendered
                    Future<Color> getdominantColor(
                        ImageProvider imageProvider) async {
                      try {
                        final PaletteGenerator paletteGenerator =
                            await PaletteGenerator.fromImageProvider(
                                imageProvider);
    
                        return paletteGenerator.dominantColor!.color;
                      } on TimeoutException {
                        final PaletteGenerator paletteGenerator =
                            await PaletteGenerator.fromImageProvider(
                                const AssetImage("assets/cover.jpg"));
    
                        return paletteGenerator.dominantColor!.color;
                      }
                    }
    
                    //query memory image
                    getImage() async {
                      final Uint8List? image = await OnAudioQuery().queryArtwork(
                        playlistDetails[index].id,
                        ArtworkType.PLAYLIST,
                        size: 200,
                      );
                      return image;
                    }
    
                    return GestureDetector(
                      onTap: () async {
                        final songs =
                            await widget.offlineAudioQuery.getPlaylistSongs(
                          playlistDetails[index].id,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DownloadedSongs(
                              title: playlistDetails[index].playlist,
                              cachedSongs: songs,
                              playlistId: playlistDetails[index].id,
                              fromHomElement: true,
                            ),
                          ),
                        );
                      },
                      child: FutureBuilder(
                          future: getImage(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return loadingContainer(boxSize);
                            }
                            return FutureBuilder<Color>(
                                future: getdominantColor(
                                  MemoryImage(
                                    snapshot.data as Uint8List,
                                  ),
                                ),
                                builder: (context, colorSnapshot) {
                                  if (!colorSnapshot.hasData) {
                                    return loadingContainer(boxSize);
                                  }
                                  return GlassmorphicContainer(
                                    margin: const EdgeInsets.all(5),
                                    width: double.maxFinite,
                                    height: boxSize - 60,
                                    borderRadius: 8,
                                    blur: 20,
                                    alignment: Alignment.bottomCenter,
                                    border: 2,
                                    linearGradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          colorSnapshot.data!.withOpacity(0.05),
                                          colorSnapshot.data!.withOpacity(0.5),
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
                                    child: Row(
                                      children: [
                                        Stack(
                                          children: [
                                            Transform.rotate(
                                              angle: -math.pi / 12,
                                              child: Container(
                                                height: boxSize,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2.8,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  image: DecorationImage(
                                                    image: MemoryImage(
                                                      snapshot.data as Uint8List,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              ListTile(
                                                title: Text(
                                                  playlistDetails[index]
                                                      .playlist
                                                      .toUpperCase(),
                                                  textAlign: TextAlign.center,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  "${playlistDetails[index].numOfSongs} ${playlistDetails[index].numOfSongs > 1 ? "Songs" : "Song"}",
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                    onPressed: () async {
                                                      OfflineAudioQuery
                                                          offlineAudioQuery =
                                                          OfflineAudioQuery();
                                                      List<SongModel>
                                                          queriedPlaylist = [];
    
                                                      await offlineAudioQuery
                                                          .requestPermission();
                                                      queriedPlaylist =
                                                          await offlineAudioQuery
                                                              .getPlaylistSongs(
                                                                  playlistDetails[
                                                                          index]
                                                                      .id);
                                                      setState(() {});
    
                                                      final tempList =
                                                          queriedPlaylist
                                                              .toList();
                                                      tempList.shuffle();
                                                      Navigator.of(context).push(
                                                        PageRouteBuilder(
                                                          opaque: false,
                                                          pageBuilder:
                                                              (_, __, ___) =>
                                                                  PlayScreen(
                                                            songsList: tempList,
                                                            index: 0,
                                                            offline: true,
                                                            fromMiniplayer: false,
                                                            fromDownloads: false,
                                                            recommend: false,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    icon: const Icon(
                                                      EvaIcons.shuffle2,
                                                    ),
                                                  ),
                                                  PopupMenuButton(
                                                    padding:
                                                        const EdgeInsets.all(3),
                                                    itemBuilder: (_) => [
                                                      const PopupMenuItem(
                                                        value: 0,
                                                        child: Row(
                                                          children: [
                                                            Icon(Iconsax.trash),
                                                            SizedBox(width: 10.0),
                                                            Text('Delete'),
                                                          ],
                                                        ),
                                                      ),
                                                      // PopupMenuItem(
                                                      //   value: 1,
                                                      //   child: Row(
                                                      //     children: const [
                                                      //       Icon(Icons.edit),
                                                      //       SizedBox(width: 10.0),
                                                      //       Text('Rename'),
                                                      //     ],
                                                      //   ),
                                                      // )
                                                    ],
                                                    onSelected:
                                                        (int? value) async {
                                                      if (value == 0) {
                                                        if (await widget
                                                            .offlineAudioQuery
                                                            .removePlaylist(
                                                          playlistId:
                                                              playlistDetails[
                                                                      index]
                                                                  .id,
                                                        )) {
                                                          ShowSnackBar()
                                                              .showSnackBar(
                                                            context,
                                                            'Deleted ${playlistDetails[index].playlist}',
                                                          );
                                                          playlistDetails
                                                              .removeAt(index);
                                                          setState(() {});
                                                        } else {
                                                          ShowSnackBar()
                                                              .showSnackBar(
                                                            context,
                                                            'Failed to delete',
                                                          );
                                                        }
                                                      }
                                                      // if (value == 1) {
                                                      //   await showTextInputDialog(
                                                      //     context: context,
                                                      //     title: 'Add new playlist name',
                                                      //     initialText: '',
                                                      //     keyboardType: TextInputType.text,
                                                      //     onSubmitted: (name) async {
                                                      //       Navigator.pop(context);
                                                      //       await widget.offlineAudioQuery
                                                      //           .renamePlaylist(
                                                      //         playlistId:
                                                      //             playlistDetails[index].id,
                                                      //         newName: name,
                                                      //       );
    
                                                      //       setState(() {});
                                                      //     },
                                                      //   );
    
                                                      //   setState(() {});
                                                      // }
                                                    },
                                                  ),
                                                  IconButton(
                                                    splashRadius: 24,
                                                    onPressed: () async {
                                                      //TODO: Fix renaming playlists
                                                      await showTextInputDialog(
                                                        context: context,
                                                        title:
                                                            'Create New Playlist',
                                                        initialText: '',
                                                        keyboardType:
                                                            TextInputType.name,
                                                        onSubmitted:
                                                            (String value) async {
                                                          if (value.trim() !=
                                                              '') {
                                                            Navigator.pop(
                                                                context);
                                                            await widget
                                                                .offlineAudioQuery
                                                                .renamePlaylist(
                                                              newName: value,
                                                              playlistId:
                                                                  playlistDetails[
                                                                          index]
                                                                      .id,
                                                            );
                                                            setState(() {});
                                                          }
                                                        },
                                                      );
                                                      setState(() {});
                                                    },
                                                    icon: const Icon(Icons.edit),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                });
                          }),
                    );
                  },
                )
            ],
          ),
        ),
      ),
    );
  }
}

GlassmorphicContainer loadingContainer(double boxSize) {
  return GlassmorphicContainer(
    margin: const EdgeInsets.all(5),
    width: double.maxFinite,
    height: boxSize - 60,
    borderRadius: 8,
    blur: 20,
    alignment: Alignment.bottomCenter,
    border: 2,
    linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFffffff).withOpacity(0.1),
          const Color(0xFFFFFFFF).withOpacity(0.05),
        ],
        stops: const [
          0.1,
          1,
        ]),
    borderGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.transparent, Colors.transparent],
    ),
    child: null,
  );
}
