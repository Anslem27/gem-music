import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:gem/CustomWidgets/snackbar.dart';
import 'package:gem/Screens/Player/music_player.dart';
import 'package:get_it/get_it.dart';

void addToNowPlaying({
  required BuildContext context,
  required MediaItem mediaItem,
  bool showNotification = true,
}) {
  final AudioPlayerHandler audioHandler = GetIt.I<AudioPlayerHandler>();
  final MediaItem? currentMediaItem = audioHandler.mediaItem.value;
  if (currentMediaItem != null &&
      currentMediaItem.extras!['url'].toString().startsWith('http')) {
    if (audioHandler.queue.value.contains(mediaItem) && showNotification) {
      ShowSnackBar().showSnackBar(
        context,
        'Song already in queue',
      );
    } else {
      audioHandler.addQueueItem(mediaItem);

      if (showNotification) {
        ShowSnackBar().showSnackBar(
          context,
          'Added to playing queue',
        );
      }
    }
  } else {
    if (showNotification) {
      ShowSnackBar().showSnackBar(
        context,
        currentMediaItem == null
            ? 'No music is playing'
            : 'Cant add online music to offline queue',
      );
    }
  }
}

void playNext(
  MediaItem mediaItem,
  BuildContext context,
) {
  final AudioPlayerHandler audioHandler = GetIt.I<AudioPlayerHandler>();
  final MediaItem? currentMediaItem = audioHandler.mediaItem.value;
  if (currentMediaItem != null &&
      currentMediaItem.extras!['url'].toString().startsWith('http')) {
    final queue = audioHandler.queue.value;
    if (queue.contains(mediaItem)) {
      audioHandler.moveQueueItem(
        queue.indexOf(mediaItem),
        queue.indexOf(currentMediaItem) + 1,
      );
    } else {
      audioHandler.addQueueItem(mediaItem).then(
            (value) => audioHandler.moveQueueItem(
              queue.length,
              queue.indexOf(currentMediaItem) + 1,
            ),
          );
    }

    ShowSnackBar().showSnackBar(
      context,
      '"${mediaItem.title}" set to play next}',
    );
  } else {
    ShowSnackBar().showSnackBar(
      context,
      currentMediaItem == null ? 'No music playing' : 'Cant add song to queue',
    );
  }
}
