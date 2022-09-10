import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:gem/CustomWidgets/bouncy_sliver_scroll_view.dart';
import 'package:gem/CustomWidgets/empty_screen.dart';
import 'package:gem/CustomWidgets/gradient_containers.dart';
import 'package:gem/CustomWidgets/miniplayer.dart';
import 'package:gem/Screens/Player/audioplayer_page.dart';
import 'package:get_it/get_it.dart';

class NowPlaying extends StatefulWidget {
  const NowPlaying({Key? key}) : super(key: key);

  @override
  _NowPlayingState createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  final AudioPlayerHandler audioHandler = GetIt.I<AudioPlayerHandler>();
  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<PlaybackState>(
              stream: audioHandler.playbackState,
              builder: (context, snapshot) {
                final playbackState = snapshot.data;
                final processingState = playbackState?.processingState;
                return Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: processingState != AudioProcessingState.idle
                      ? null
                      : AppBar(
                          title: const Text('Now playing'),
                          centerTitle: true,
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.transparent
                                  : Theme.of(context).colorScheme.secondary,
                          elevation: 0,
                        ),
                  body: processingState == AudioProcessingState.idle
                      ? emptyScreen(
                          context,
                          3,
                          'Nothing is ',
                          18.0,
                          'Playling',
                          60,
                          'Try playing something',
                          23.0,
                        )
                      : StreamBuilder<MediaItem?>(
                          stream: audioHandler.mediaItem,
                          builder: (context, snapshot) {
                            final mediaItem = snapshot.data;
                            return mediaItem == null
                                ? const SizedBox()
                                : BouncyImageSliverScrollView(
                                    title: 'Now Playing',
                                    localImage: mediaItem.artUri!
                                        .toString()
                                        .startsWith('file:'),
                                    imageUrl: mediaItem.artUri!
                                            .toString()
                                            .startsWith('file:')
                                        ? mediaItem.artUri!.toFilePath()
                                        : mediaItem.artUri!.toString(),
                                    sliverList: SliverList(
                                      delegate: SliverChildListDelegate(
                                        [
                                          NowPlayingStream(
                                            audioHandler: audioHandler,
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                          },
                        ),
                );
              },
            ),
          ),
          const MiniPlayer(),
        ],
      ),
    );
  }
}
