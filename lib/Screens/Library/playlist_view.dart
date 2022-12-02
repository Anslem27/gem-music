// ignore_for_file: always_use_package_imports

import 'package:flutter/material.dart';
import 'package:gem/Screens/Library/online_playlists.dart';
import 'package:gem/Screens/LocalMusic/localplaylists.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

import '../../CustomWidgets/gradient_containers.dart';
import '../../Helpers/local_music_functions.dart';

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
    return GradientContainer(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          title: const Text(
            "My Playlists",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  "Offline",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              )
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
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
  }
}
