import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gem/CustomWidgets/snackbar.dart';
import 'package:gem/Helpers/picker.dart';
import 'package:gem/Helpers/songs_count.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> exportPlaylist(
  BuildContext context,
  String playlistName,
  String showName,
) async {
  final String dirPath = await Picker.selectFolder(
    context: context,
    message: 'Select where to export',
  );
  if (dirPath == '') {
    ShowSnackBar().showSnackBar(
      context,
      'Failed to export "$showName"',
    );
    return;
  }
  await Hive.openBox(playlistName);
  final Box playlistBox = Hive.box(playlistName);
  final Map songsMap = playlistBox.toMap();
  final String songs = json.encode(songsMap);
  final File file =
      await File('$dirPath/$showName.json').create(recursive: true);
  await file.writeAsString(songs);
  ShowSnackBar().showSnackBar(
    context,
    'Exported "$showName"',
  );
}

Future<void> sharePlaylist(
  BuildContext context,
  String playlistName,
  String showName,
) async {
  final Directory appDir = await getApplicationDocumentsDirectory();
  final String temp = appDir.path;

  await Hive.openBox(playlistName);
  final Box playlistBox = Hive.box(playlistName);
  final Map songsMap = playlistBox.toMap();
  final String songs = json.encode(songsMap);
  final File file = await File('$temp/$showName.json').create(recursive: true);
  await file.writeAsString(songs);

  await Share.shareFiles(
    [file.path],
    text: 'Hey there, try this playlist out',
  );
  await Future.delayed(const Duration(seconds: 10), () {});
  if (await file.exists()) {
    await file.delete();
  }
}

Future<List> importPlaylist(BuildContext context, List playlistNames) async {
  try {
    String temp = '';
    try {
      temp = await Picker.selectFile(
        context: context,
        // ext: ['json'],
        message: 'Select Json Import',
      );
    } catch (e) {
      temp = await Picker.selectFile(
        context: context,
        message: 'Select Json Import',
      );
    }
    if (temp == '') {
      ShowSnackBar().showSnackBar(
        context,
        'Failed to import',
      );
      return playlistNames;
    }

    final RegExp avoid = RegExp(r'[\.\\\*\:\"\?#/;\|]');
    String playlistName = temp
        .split('/')
        .last
        .replaceAll('.json', '')
        .replaceAll(avoid, '')
        .replaceAll('  ', ' ');

    final File file = File(temp);
    final String finString = await file.readAsString();
    final Map songsMap = json.decode(finString) as Map;
    final List songs = songsMap.values.toList();
    // playlistBox.put(mediaItem.id.toString(), info);
    // Hive.box(play)

    if (playlistName.trim() == '') {
      playlistName = 'Playlist ${playlistNames.length}';
    }
    if (playlistNames.contains(playlistName)) {
      playlistName = '$playlistName (1)';
    }
    playlistNames.add(playlistName);

    await Hive.openBox(playlistName);
    final Box playlistBox = Hive.box(playlistName);
    await playlistBox.putAll(songsMap);

    addSongsCount(
      playlistName,
      songs.length,
      songs.length >= 4 ? songs.sublist(0, 4) : songs.sublist(0, songs.length),
    );
    ShowSnackBar().showSnackBar(
      context,
      'Successfully imported "$playlistName"',
    );
    return playlistNames;
  } catch (e) {
    ShowSnackBar().showSnackBar(
      context,
      'Failed to import\nError: $e',
    );
  }
  return playlistNames;
}
