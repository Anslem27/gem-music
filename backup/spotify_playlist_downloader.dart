/* // ignore_for_file: prefer_typing_uninitialized_variables, non_constant_identifier_names

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:spotify/spotify.dart' as sp;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'package:gem/widgets/gradient_containers.dart';

var yt = YoutubeExplode();
var video_Id;
var _controller = TextEditingController();

Directory dir = Directory("/storage/emulated/0/Download/music/");

List<String> tracks = <String>[];
final credentials = sp.SpotifyApiCredentials(
    '6ac6511f2ed1432e9917624fc7a67bef', 'd6331f83644e4d93b27f63bd97da3f3c');

const String regex =
    r'[^\p{Alphabetic}\p{Mark}\p{Decimal_Number}\p{Connector_Punctuation}\p{Join_Control}\s]+';

class SpotifyPlaylistGetter extends StatefulWidget {
  const SpotifyPlaylistGetter({Key? key}) : super(key: key);

  @override
  _SpotifyPlaylistGetterState createState() => _SpotifyPlaylistGetterState();
}

class _SpotifyPlaylistGetterState extends State<SpotifyPlaylistGetter> {
  Future<void> download(String song) async {
    final bool rotated =
        MediaQuery.of(context).size.height < MediaQuery.of(context).size.width;
    double boxSize = !rotated
        ? MediaQuery.of(context).size.width / 2
        : MediaQuery.of(context).size.height / 2.5;

    Center(
      child: SizedBox.square(
        dimension: boxSize,
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          clipBehavior: Clip.antiAlias,
          child: GradientContainer(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.secondary,
                    ),
                    strokeWidth: 5,
                  ),
                  const Text('Converting media'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await yt.search.getVideos(song).then((value) => video_Id = value.first.id);

    await yt.videos.get(video_Id);
    if (kDebugMode) {
      print("[DEBUG] Song name: $song");
    }

    // Get the streams manifest and the audio track.
    var manifest = await yt.videos.streamsClient.getManifest(video_Id);
    var audio = manifest.audioOnly.first;

    var audioStream = yt.videos.streamsClient.get(audio);

    var filePath = path.join(dir.uri.toFilePath(), '$song.mp3');

    var file = File(filePath);
    if (await file.exists()) {
      if (kDebugMode) {
        print("[DEBUG] $filePath exists...");
      }
      await file.delete();
    }
    var output = file.openWrite(mode: FileMode.writeOnlyAppend);

    var len = audio.size.totalBytes;
    var count = 0;

    // Listen for data received.

    await for (final data in audioStream) {
      // Keep track of the current downloaded data.
      count += data.length;
      int progress = ((count / len) * 100).ceil();
      //pd.update(msg: "Downloading $song", value: progress);
      Center(
        child: SizedBox.square(
          dimension: boxSize,
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            clipBehavior: Clip.antiAlias,
            child: GradientContainer(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.secondary,
                      ),
                      strokeWidth: 5,
                    ),
                    Text(
                      'Downloading $song\n$progress',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      // Write to file.
      output.add(data);
    }
    await output.close();
    if (kDebugMode) {
      print("[DEBUG] $song Download Completed.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GradientContainer(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                fillColor: Color.fromRGBO(20, 20, 20, 1),
                hintText: "Playlist URL here",
              ),
              style: GoogleFonts.roboto(),
              onSubmitted: (text) async {
                // Take the ID from the URL
                if (text.contains("playlist/")) {
                  final playlistID =
                      // ignore: unnecessary_string_escapes
                      RegExp("playlist\/([a-zA-Z0-9]{22})");
                  if (playlistID.hasMatch(text)) {
                    var match =
                        playlistID.firstMatch(text)?.group(1).toString();
                    text = match.toString();
                  }
                }

                final spotify = sp.SpotifyApi(credentials);
                final items =
                    await spotify.playlists.getTracksByPlaylistId(text).all();

                String title = await spotify.playlists.get(text).then((value) {
                  return value.name
                      .toString()
                      .replaceAll(RegExp(regex, unicode: true), '');
                });

                if (kDebugMode) {
                  print("[DEBUG] Playlist Title: $title");
                }
                await Permission.storage.request();
                dir =
                    await Directory("/storage/emulated/0/Download/music/$title")
                        .create(recursive: true);
                if (kDebugMode) {
                  print("[DEBUG] Directory created: ${dir.path}");
                }

                for (var track in items) {
                  var artist = track.artists!.first.name
                      .toString()
                      .replaceAll(RegExp(regex, unicode: true), '');
                  var song = track.name
                      .toString()
                      .replaceAll(RegExp(regex, unicode: true), '');
                  setState(() {
                    tracks.add('$artist - $song ');
                    if (kDebugMode) {
                      print('[DEBUG] Added $artist - $song to tracks list');
                    }
                  });
                }
              },
            ),
            actions: [
              IconButton(
                splashRadius: 24,
                onPressed: () {
                  setState(() {
                    tracks.clear();
                    _controller.clear();
                  });
                },
                icon: const Icon(Icons.clear_rounded),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                ),
                onPressed: () async {
                  Future.forEach(tracks, (element) async {
                    await download(element.toString());
                  });
                  /*  ShowSnackBar().showSnackBar(
                          context,
                          'No URL Available',
                        ); */
                },
                icon: const Icon(Icons.downloading_rounded),
                label: const Text(
                  'Download All',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              tracks.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: tracks.length,
                        itemBuilder: (BuildContext context, int index) {
                          double boxSize = MediaQuery.of(context).size.height >
                                  MediaQuery.of(context).size.width
                              ? MediaQuery.of(context).size.width / 2
                              : MediaQuery.of(context).size.height / 2.5;
                          return InkWell(
                            onTap: () async {
                              if (kDebugMode) {
                                print('[DEBUG] Clicked: ${tracks[index]}');
                              }

                              await download(tracks[index]);
                            },
                            child: SizedBox(
                              height: boxSize - 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 70,
                                    width: 70,
                                    child: Image.asset(
                                      "assets/cover.jpg",
                                    ),
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      title: Text(
                                        tracks[index],
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.roboto(fontSize: 17),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 3.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        IconButton(
                                          splashRadius: 24,
                                          onPressed: () async {
                                            if (kDebugMode) {
                                              print(
                                                  '[DEBUG] Clicked: ${tracks[index]}');
                                            }

                                            await download(tracks[index]);
                                          },
                                          icon: const Icon(
                                            Icons.file_download_outlined,
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset("assets/svg/music.svg",
                              height: 140, width: 100),
                          const SizedBox(height: 20),
                          Icon(
                            Icons.download_outlined,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 50,
                          ),
                          Text(
                            "Paste URL to fetch songs",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
 */