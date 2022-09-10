// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:gem/Screens/Player/audioplayer_page.dart';

class PlaylistHead extends StatelessWidget {
  final List songsList;
  final bool offline;
  final bool fromDownloads;
  const PlaylistHead({
    Key? key,
    required this.songsList,
    required this.fromDownloads,
    required this.offline,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 20.0, right: 10.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${songsList.length} ${songsList.length > 1 ? "Songs" : "Song"}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              final tempList = songsList.toList();
              tempList.shuffle();
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (_, __, ___) => PlayScreen(
                    songsList: tempList,
                    index: 0,
                    offline: offline,
                    fromMiniplayer: false,
                    fromDownloads: fromDownloads,
                    recommend: false,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.shuffle_rounded),
            label: const Text(
              "Shuffle",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            splashRadius: 24,
            color: Theme.of(
              context,
            ).colorScheme.secondary,
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (_, __, ___) => PlayScreen(
                    songsList: songsList,
                    index: 0,
                    offline: offline,
                    fromMiniplayer: false,
                    fromDownloads: fromDownloads,
                    recommend: false,
                  ),
                ),
              );
            },
            tooltip: 'Shuffle',
            icon: const Icon(Icons.play_arrow_rounded),
            iconSize: 30.0,
          ),
        ],
      ),
    );
  }
}
