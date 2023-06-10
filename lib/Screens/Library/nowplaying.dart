// ignore_for_file: library_private_types_in_public_api

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem/widgets/bouncy_sliver_scroll_view.dart';
import 'package:gem/widgets/gradient_containers.dart';
import 'package:gem/widgets/miniplayer.dart';
import 'package:gem/Screens/Player/music_player.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

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
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset("assets/svg/meditating.svg",
                                  height: 140, width: 100),
                              const SizedBox(height: 20),
                              Text(
                                "Playing Queue is empty\ntry playing some music",
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
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
                                        ? mediaItem.artUri!.toFilePath().isEmpty
                                            ? "assets/cover.jpg"
                                            : mediaItem.artUri!.toFilePath()
                                        : mediaItem.artUri!.toString(),
                                    sliverList: SliverList(
                                      delegate: SliverChildListDelegate(
                                        [
                                          GradientContainer(
                                            child: NowPlayingStream(
                                              audioHandler: audioHandler,
                                            ),
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
