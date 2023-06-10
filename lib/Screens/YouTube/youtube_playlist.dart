// ignore_for_file: use_super_parameters, use_build_context_synchronously, library_private_types_in_public_api

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gem/widgets/bouncy_sliver_scroll_view.dart';
import 'package:gem/widgets/copy_clipboard.dart';
import 'package:gem/widgets/gradient_containers.dart';
import 'package:gem/widgets/miniplayer.dart';
import 'package:gem/widgets/song_tile_trailing_menu.dart';
import 'package:gem/Screens/Player/music_player.dart';
import 'package:gem/Services/youtube_services.dart';
import 'package:hive/hive.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YouTubePlaylist extends StatefulWidget {
  final String playlistId;
  final String playlistName;
  final String playlistImage;
  const YouTubePlaylist({
    Key? key,
    required this.playlistId,
    required this.playlistName,
    required this.playlistImage,
  }) : super(key: key);

  @override
  _YouTubePlaylistState createState() => _YouTubePlaylistState();
}

class _YouTubePlaylistState extends State<YouTubePlaylist> {
  bool status = false;
  List<Video> searchedList = [];
  bool fetched = false;
  bool done = true;
  List ytSearch =
      Hive.box('settings').get('ytSearch', defaultValue: []) as List;

  @override
  void initState() {
    if (!status) {
      status = true;
      YouTubeServices().getPlaylistSongs(widget.playlistId).then((value) {
        if (value.isNotEmpty) {
          setState(() {
            searchedList = value;
            fetched = true;
          });
        } else {
          status = false;
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext cntxt) {
    return GradientContainer(
      child: Column(
        children: [
          Expanded(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  if (!fetched)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else
                    BouncyImageSliverScrollView(
                      title: widget.playlistName,
                      imageUrl: widget.playlistImage,
                      sliverList: SliverList(
                        delegate: SliverChildListDelegate(
                          searchedList.map(
                            (Video entry) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: 5.0,
                                ),
                                child: ListTile(
                                  leading: Card(
                                    elevation: 8,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        5.0,
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: SizedBox.square(
                                      dimension: 50,
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        errorWidget: (context, _, __) =>
                                            CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          imageUrl:
                                              entry.thumbnails.standardResUrl,
                                          errorWidget: (context, _, __) =>
                                              const Image(
                                            fit: BoxFit.cover,
                                            image: AssetImage(
                                              'assets/cover.jpg',
                                            ),
                                          ),
                                        ),
                                        imageUrl: entry.thumbnails.maxResUrl,
                                        placeholder: (context, url) =>
                                            const Image(
                                          fit: BoxFit.cover,
                                          image: AssetImage(
                                            'assets/cover.jpg',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    entry.title,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onLongPress: () {
                                    copyToClipboard(
                                      context: context,
                                      text: entry.title,
                                    );
                                  },
                                  subtitle: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          entry.author,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        entry.duration
                                            .toString()
                                            .split('.')[0]
                                            .replaceFirst('0:0', ''),
                                      ),
                                    ],
                                  ),
                                  onTap: () async {
                                    setState(() {
                                      done = false;
                                    });

                                    final Map? response =
                                        await YouTubeServices().formatVideo(
                                      video: entry,
                                      quality: Hive.box('settings')
                                          .get(
                                            'ytQuality',
                                            defaultValue: 'Low',
                                          )
                                          .toString(),
                                    );
                                    setState(() {
                                      done = true;
                                    });
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        opaque: false,
                                        pageBuilder: (_, __, ___) => PlayScreen(
                                          songsList: [response],
                                          index: 0,
                                          recommend: false,
                                          fromDownloads: false,
                                          fromMiniplayer: false,
                                          offline: false,
                                        ),
                                      ),
                                    );
                                  },
                                  trailing: YtSongTileTrailingMenu(data: entry),
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    ),
                  if (!done)
                    Center(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.width / 2,
                        width: MediaQuery.of(context).size.width / 2,
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: GradientContainer(
                            child: Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Padding(
                                  //   padding: const EdgeInsets.symmetric(
                                  //     horizontal: 8.0,
                                  //   ),
                                  //   child: Text(
                                  //     AppLocalizations.of(context)!.useHome,
                                  //     textAlign: TextAlign.center,
                                  //   ),
                                  // ),
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.secondary,
                                    ),
                                    strokeWidth: 5,
                                  ),
                                  const Text(
                                    'Converting media',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
          const MiniPlayer(),
        ],
      ),
    );
  }
}
