// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'package:audio_service/audio_service.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gem/widgets/add_playlist.dart';
import 'package:gem/Helpers/add_mediaitem_to_queue.dart';
import 'package:gem/Helpers/mediaitem_converter.dart';
import 'package:gem/Screens/Common/song_list.dart';
import 'package:gem/Screens/Search/albums.dart';
import 'package:gem/Screens/Search/search.dart';
import 'package:gem/services/youtube_services.dart';
import 'package:gem/widgets/playlist_popupmenu.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SongTileTrailingMenu extends StatefulWidget {
  final Map data;
  final bool isPlaylist;
  final Function(Map)? deleteLiked;
  const SongTileTrailingMenu({
    Key? key,
    required this.data,
    this.isPlaylist = false,
    this.deleteLiked,
  }) : super(key: key);

  @override
  _SongTileTrailingMenuState createState() => _SongTileTrailingMenuState();
}

class _SongTileTrailingMenuState extends State<SongTileTrailingMenu> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          builder: (_) {
            final MediaItem mediaItem =
                MediaItemConverter.mapToMediaItem(widget.data);
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.isPlaylist)
                        sheetTile(
                          "Remove",
                          () {
                            widget.deleteLiked!(widget.data);
                          },
                          Iconsax.trash,
                        ),
                      sheetTile(
                        "Play next",
                        () {
                          playNext(mediaItem, context);
                          Navigator.pop(context);
                        },
                        Iconsax.music_play,
                      ),
                      sheetTile(
                        "Add to queue",
                        () {
                          addToNowPlaying(
                              context: context, mediaItem: mediaItem);
                          Navigator.pop(context);
                        },
                        Iconsax.music_play,
                      ),
                      sheetTile(
                        "Add to playlist",
                        () {
                          AddToPlaylist().addToPlaylist(context, mediaItem);
                        },
                        EvaIcons.music,
                      ),
                      sheetTile(
                        "View Album",
                        () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              opaque: false,
                              pageBuilder: (_, __, ___) => SongsListPage(
                                listItem: {
                                  'type': 'album',
                                  'id': mediaItem.extras?['album_id'],
                                  'title': mediaItem.album,
                                  'image': mediaItem.artUri,
                                },
                              ),
                            ),
                          );
                        },
                        EvaIcons.fileAdd,
                      ),
                      sheetTile(
                        "View Artist",
                        () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              opaque: false,
                              pageBuilder: (_, __, ___) => AlbumSearchPage(
                                query: mediaItem.artist
                                    .toString()
                                    .split(', ')
                                    .first,
                                type: 'Artists',
                              ),
                            ),
                          );
                        },
                        EvaIcons.person,
                      ),
                      sheetTile(
                        "Share",
                        () {
                          Share.share(widget.data['perma_url'].toString());
                        },
                        Icons.share_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      icon: const Icon(EvaIcons.moreVertical),
    );
  }
}

class YtSongTileTrailingMenu extends StatefulWidget {
  final Video data;
  const YtSongTileTrailingMenu({Key? key, required this.data})
      : super(key: key);

  @override
  _YtSongTileTrailingMenuState createState() => _YtSongTileTrailingMenuState();
}

class _YtSongTileTrailingMenuState extends State<YtSongTileTrailingMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert_rounded,
        color: Theme.of(context).iconTheme.color,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: Row(
            children: [
              Icon(
                CupertinoIcons.search,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(
                width: 10.0,
              ),
              const Text('Search'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(
                Iconsax.music_play,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              const Text('Play next'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(
                Icons.playlist_add_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              const Text('Add to queue'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: Row(
            children: [
              Icon(
                Iconsax.music_playlist,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              const Text('Add to playlist'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 4,
          child: Row(
            children: [
              Icon(
                Icons.video_library_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              const Text('Watch Video'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 5,
          child: Row(
            children: [
              Icon(
                Icons.share_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              const Text('Share'),
            ],
          ),
        ),
      ],
      onSelected: (int? value) {
        if (value == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchPage(
                query: widget.data.title.split('|')[0].split('(')[0],
              ),
            ),
          );
        }
        if (value == 1 || value == 2 || value == 3) {
          YouTubeServices()
              .formatVideo(
            video: widget.data,
            quality: Hive.box('settings')
                .get(
                  'ytQuality',
                  defaultValue: 'Low',
                )
                .toString(),
          )
              .then((songMap) {
            final MediaItem mediaItem =
                MediaItemConverter.mapToMediaItem(songMap!);
            if (value == 1) {
              playNext(mediaItem, context);
            }
            if (value == 2) {
              addToNowPlaying(context: context, mediaItem: mediaItem);
            }
            if (value == 3) {
              AddToPlaylist().addToPlaylist(context, mediaItem);
            }
          });
        }
        if (value == 4) {
          launchUrl(
            Uri.parse(widget.data.url),
            mode: LaunchMode.externalApplication,
          );
        }
        if (value == 5) {
          Share.share(widget.data.url);
        }
      },
    );
  }
}
