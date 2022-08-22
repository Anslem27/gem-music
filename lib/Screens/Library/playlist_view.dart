// ignore_for_file: always_use_package_imports

import 'package:flutter/material.dart';
import 'package:gem/Screens/Library/online_playlists.dart';
import 'package:gem/Screens/LocalMusic/localplaylists.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

import '../../CustomWidgets/gradient_containers.dart';
import '../../Helpers/audio_query.dart';

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
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tcontroller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          title: Text(
            "My Playlists",
            style: GoogleFonts.roboto(
              fontSize: 20,
            ),
          ),
          bottom: TabBar(
            controller: _tcontroller,
            indicator: RectangularIndicator(
              bottomLeftRadius: 12,
              bottomRightRadius: 12,
              topLeftRadius: 12,
              topRightRadius: 12,
              color: Theme.of(
                context,
              ).colorScheme.secondary,
            ),
            tabs: const [
              Tab(
                text: "Online",
              ),
              Tab(
                text: "Offline",
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        body: TabBarView(
          controller: _tcontroller,
          children: [
            OnlinePlaylistScreen(),
            LocalPlaylists(
              playlistDetails: playlistDetails,
              offlineAudioQuery: offlineAudioQuery,
            ),
          ],
        ),
      ),
    );
  }
}
