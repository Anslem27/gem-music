import 'package:flutter/material.dart';
import 'package:gem/APIs/api.dart';
import 'package:gem/CustomWidgets/gradient_containers.dart';
import 'package:gem/Helpers/playlist.dart';
import 'package:gem/Services/youtube_services.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

// ignore: avoid_classes_with_only_static_members
class SearchAddPlaylist {
  static Future<Map> addYtPlaylist(String inLink) async {
    final String link = '$inLink&';
    try {
      final RegExpMatch? id = RegExp(r'.*list\=(.*?)&').firstMatch(link);
      if (id != null) {
        final Playlist metadata =
            await YouTubeServices().getPlaylistDetails(id[1]!);
        final List<Video> tracks =
            await YouTubeServices().getPlaylistSongs(id[1]!);
        return {
          'title': metadata.title,
          'image': metadata.thumbnails.standardResUrl,
          'author': metadata.author,
          'description': metadata.description,
          'tracks': tracks,
          'count': tracks.length,
        };
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  static Stream<Map> ytSongsAdder(String playName, List tracks) async* {
    int done = 0;
    for (final track in tracks) {
      String? trackName;
      try {
        trackName = (track as Video).title;
        yield {'done': ++done, 'name': trackName};
      } catch (e) {
        yield {'done': ++done, 'name': ''};
      }
      try {
        final List result =
            await SaavnAPI().fetchTopSearchResult(trackName!.split('|')[0]);
        addMapToPlaylist(playName, result[0] as Map);
      } catch (e) {
        // print('Error in $_done: $e');
      }
    }
  }

  static Future<void> showProgress(
    int total,
    BuildContext cxt,
    Stream songAdd,
  ) async {
    if (total != 0) {
      await showModalBottomSheet(
        isDismissible: false,
        backgroundColor: Colors.transparent,
        context: cxt,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setStt) {
              return BottomGradientContainer(
                child: SizedBox(
                  height: 300,
                  width: 300,
                  child: StreamBuilder<Object>(
                    stream: songAdd as Stream<Object>?,
                    builder: (ctxt, AsyncSnapshot snapshot) {
                      final Map? data = snapshot.data as Map?;
                      final int done = (data ?? const {})['done'] as int? ?? 0;
                      final String name =
                          (data ?? const {})['name'] as String? ?? '';
                      if (done == total) Navigator.pop(ctxt);
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Center(
                            child: Text(
                              'Converting media',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          SizedBox(
                            height: 80,
                            width: 80,
                            child: Stack(
                              children: [
                                Center(
                                  child: Text('$done / $total'),
                                ),
                                Center(
                                  child: SizedBox(
                                    height: 77,
                                    width: 77,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(ctxt).colorScheme.secondary,
                                      ),
                                      value: done / total,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Center(
                            child: Text(
                              name,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      );
    }
  }
}
