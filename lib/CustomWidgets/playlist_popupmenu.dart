// ignore_for_file: use_super_parameters

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:gem/CustomWidgets/snackbar.dart';
import 'package:gem/Helpers/mediaitem_converter.dart';
import 'package:gem/Helpers/playlist.dart';
import 'package:gem/Screens/Player/audioplayer_page.dart';
import 'package:get_it/get_it.dart';
import 'package:iconsax/iconsax.dart';

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
    return PopupMenuButton(
      icon: const Icon(
        Icons.more_vert_rounded,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: Row(
            children: [
              Icon(
                Iconsax.play_add,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              const Text('Add to playing queue'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
            children: const [
              Icon(
                Iconsax.heart,
                color: Colors.redAccent,
              ),
              SizedBox(width: 10.0),
              Text('Save Playlist'),
            ],
          ),
        ),
      ],
      onSelected: (int? value) {
        if (value == 1) {
          addPlaylist(widget.title, widget.data).then(
            (value) => ShowSnackBar().showSnackBar(
              context,
              '"${widget.title}" Added to playlist',
            ),
          );
        }
        if (value == 0) {
          final AudioPlayerHandler audioHandler = GetIt.I<AudioPlayerHandler>();
          final MediaItem? currentMediaItem = audioHandler.mediaItem.value;
          if (currentMediaItem != null &&
              currentMediaItem.extras!['url'].toString().startsWith('http')) {
            // TODO: make sure to check if song is already in queue
            final queue = audioHandler.queue.value;
            widget.data.map((e) {
              final element = MediaItemConverter.mapToMediaItem(e as Map);
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
        }
      },
    );
  }
}
