// ignore_for_file: use_super_parameters

import 'package:audio_service/audio_service.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:gem/widgets/snackbar.dart';
import 'package:gem/Helpers/mediaitem_converter.dart';
import 'package:gem/Helpers/playlist.dart';
import 'package:gem/Screens/Player/music_player.dart';
import 'package:get_it/get_it.dart';

class PlaylistPopupMenu extends StatefulWidget {
  final List data;
  final String title;
  const PlaylistPopupMenu({
    Key? key,
    required this.data,
    required this.title,
  }) : super(key: key);

  @override
  _PlaylistPopupMenuState createState() => _PlaylistPopupMenuState();
}

class _PlaylistPopupMenuState extends State<PlaylistPopupMenu> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          showModalBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            builder: (_) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      sheetTile(
                        "Add to favourites",
                        () {
                          addPlaylist(widget.title, widget.data).then(
                            (value) => ShowSnackBar().showSnackBar(
                              context,
                              '"${widget.title}" Added to playlist',
                            ),
                          );
                        },
                        EvaIcons.heart,
                      ),
                      sheetTile(
                        "Add to playing queue",
                        () {
                          final AudioPlayerHandler audioHandler =
                              GetIt.I<AudioPlayerHandler>();
                          final MediaItem? currentMediaItem =
                              audioHandler.mediaItem.value;
                          if (currentMediaItem != null &&
                              currentMediaItem.extras!['url']
                                  .toString()
                                  .startsWith('http')) {
                            // TODO: make sure to check if song is already in queue
                            final queue = audioHandler.queue.value;
                            widget.data.map((e) {
                              final element =
                                  MediaItemConverter.mapToMediaItem(e as Map);
                              if (!queue.contains(element)) {
                                audioHandler.addQueueItem(element);
                              }
                            });

                            ShowSnackBar().showSnackBar(
                              context,
                              '"${widget.title}" Added to queue',
                            );
                          } else {
                            ShowSnackBar().showSnackBar(
                              context,
                              currentMediaItem == null
                                  ? 'No song in queue'
                                  : 'Cant add to queue',
                            );
                          }
                        },
                        EvaIcons.music,
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
        icon: const Icon(EvaIcons.moreVertical));
  }
}

ListTile sheetTile(String title, Function()? ontap, IconData icon) {
  return ListTile(
    leading: Icon(icon),
    title: Text(title),
    onTap: ontap,
  );
}
