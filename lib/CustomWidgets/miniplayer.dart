// ignore_for_file: use_super_parameters

import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gem/Screens/Player/music_player.dart';
import 'package:get_it/get_it.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:palette_generator/palette_generator.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({Key? key}) : super(key: key);

  @override
  _MiniPlayerState createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  AudioPlayerHandler audioHandler = GetIt.I<AudioPlayerHandler>();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool rotated = MediaQuery.of(context).size.height < screenWidth;

//get dorminant color from image rendered
    Future<Color> getdominantColor(ImageProvider imageProvider) async {
      try {
        final PaletteGenerator paletteGenerator =
            await PaletteGenerator.fromImageProvider(imageProvider);

        return paletteGenerator.dominantColor!.color;
      } on TimeoutException {
        final PaletteGenerator paletteGenerator =
            await PaletteGenerator.fromImageProvider(
                const AssetImage("assets/cover.jpg"));

        return paletteGenerator.dominantColor!.color;
      }
    }

    return StreamBuilder<PlaybackState>(
      stream: audioHandler.playbackState,
      builder: (context, snapshot) {
        final playbackState = snapshot.data;
        final processingState = playbackState?.processingState;
        if (processingState == AudioProcessingState.idle) {
          return const SizedBox();
        }
        return StreamBuilder<MediaItem?>(
          stream: audioHandler.mediaItem,
          builder: (context, snapshot) {
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
                builder: (context, AsyncSnapshot<Color> colorsSnapshot) {
                  if (!colorsSnapshot.hasData) {
                    return placeholderContainer(true);
                  }

                  return Material(
                    color: Colors.transparent,
                    child: Dismissible(
                      key: const Key('miniplayer'),
                      direction: DismissDirection.down,
                      onDismissed: (_) {
                        Feedback.forLongPress(context);
                        audioHandler.stop();
                      },
                      child: Dismissible(
                        key: Key(mediaItem.id),
                        confirmDismiss: (DismissDirection direction) {
                          if (direction == DismissDirection.startToEnd) {
                            audioHandler.skipToPrevious();
                          } else {
                            audioHandler.skipToNext();
                          }
                          return Future.value(false);
                        },
                        child: ValueListenableBuilder(
                          valueListenable: Hive.box('settings').listenable(),
                          child: StreamBuilder<Duration>(
                            stream: AudioService.position,
                            builder: (context, snapshot) {
                              final position = snapshot.data;
                              return position == null
                                  ? const SizedBox()
                                  : (position.inSeconds.toDouble() < 0.0 ||
                                          (position.inSeconds.toDouble() >
                                              mediaItem.duration!.inSeconds
                                                  .toDouble()))
                                      ? const SizedBox()
                                      : SliderTheme(
                                          data:
                                              SliderTheme.of(context).copyWith(
                                            activeTrackColor: Colors.white,
                                            inactiveTrackColor:
                                                Colors.transparent,
                                            trackHeight: 0.5,
                                            thumbColor: Colors.white,
                                            thumbShape:
                                                const RoundSliderThumbShape(
                                              enabledThumbRadius: 1.0,
                                            ),
                                            overlayColor: Colors.transparent,
                                            overlayShape:
                                                const RoundSliderOverlayShape(
                                              overlayRadius: 0,
                                            ),
                                          ),
                                          child: Center(
                                            child: Slider(
                                              inactiveColor: Colors.transparent,
                                              // activeColor: Colors.white,
                                              value:
                                                  position.inSeconds.toDouble(),
                                              max: mediaItem.duration!.inSeconds
                                                  .toDouble(),
                                              onChanged: (newPosition) {
                                                audioHandler.seek(
                                                  Duration(
                                                    seconds:
                                                        newPosition.round(),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                            },
                          ),
                          builder:
                              (BuildContext context, Box box1, Widget? child) {
                            final bool useDense = box1.get(
                                  'useDenseMini',
                                  defaultValue: false,
                                ) as bool ||
                                rotated;
                            final List preferredMiniButtons =
                                Hive.box('settings').get(
                              'preferredMiniButtons',
                              defaultValue: ['Previous', 'Play/Pause', 'Next'],
                            )?.toList() as List;

                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.transparent,
                              ),
                              height: useDense ? 68.0 : 68.0,
                              child: colorsSnapshot.connectionState ==
                                          ConnectionState.waiting &&
                                      colorsSnapshot.connectionState ==
                                          ConnectionState.none
                                  ? placeholderContainer(useDense)
                                  : GlassmorphicContainer(
                                      width: double.maxFinite,
                                      height: useDense ? 68.0 : 68.0,
                                      borderRadius: 8,
                                      blur: 10,
                                      alignment: Alignment.bottomCenter,
                                      border: 2,
                                      linearGradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            colorsSnapshot.data
                                                ?.withOpacity(0.5) as Color,
                                            colorsSnapshot.data
                                                ?.withOpacity(0.3) as Color,
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
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                            child: ListTile(
                                              dense: useDense,
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  PageRouteBuilder(
                                                    opaque: false,
                                                    pageBuilder: (_, __, ___) =>
                                                        const PlayScreen(
                                                      songsList: [],
                                                      index: 1,
                                                      offline: null,
                                                      fromMiniplayer: true,
                                                      fromDownloads: false,
                                                      recommend: false,
                                                    ),
                                                  ),
                                                );
                                              },
                                              title: Text(
                                                mediaItem.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              subtitle: Text(
                                                mediaItem.artist ?? '',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              leading: Hero(
                                                tag: 'currentArtwork',
                                                child: Card(
                                                  elevation: 8,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7.0),
                                                  ),
                                                  clipBehavior: Clip.antiAlias,
                                                  child: (mediaItem.artUri
                                                          .toString()
                                                          .startsWith('file:'))
                                                      ? SizedBox.square(
                                                          dimension: useDense
                                                              ? 40.0
                                                              : 45.0,
                                                          child: Image(
                                                            fit: BoxFit.cover,
                                                            image: FileImage(
                                                              File(
                                                                mediaItem
                                                                    .artUri!
                                                                    .toFilePath(),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : SizedBox.square(
                                                          dimension: useDense
                                                              ? 40.0
                                                              : 45.0,
                                                          child:
                                                              CachedNetworkImage(
                                                            fit: BoxFit.cover,
                                                            errorWidget: (
                                                              BuildContext
                                                                  context,
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
                                                              BuildContext
                                                                  context,
                                                              _,
                                                            ) =>
                                                                const Image(
                                                              fit: BoxFit.cover,
                                                              image: AssetImage(
                                                                'assets/cover.jpg',
                                                              ),
                                                            ),
                                                            imageUrl: mediaItem
                                                                .artUri
                                                                .toString(),
                                                          ),
                                                        ),
                                                ),
                                              ),
                                              trailing: ControlButtons(
                                                audioHandler,
                                                miniplayer: true,
                                                buttons: mediaItem.artUri
                                                        .toString()
                                                        .startsWith('file:')
                                                    ? [
                                                        'Previous',
                                                        'Play/Pause',
                                                        'Next'
                                                      ]
                                                    : preferredMiniButtons,
                                              ),
                                            ),
                                          ),
                                          child!,
                                        ],
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                });
          },
        );
      },
    );
  }

  placeholderContainer(bool useDense) {
    return GlassmorphicContainer(
      width: double.maxFinite,
      height: useDense ? 68.0 : 68.0,
      borderRadius: 8,
      blur: 20,
      padding: const EdgeInsets.all(40),
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
        colors: [
          Colors.transparent,
          Colors.transparent,
        ],
      ),
      child: null,
    );
  }
}
