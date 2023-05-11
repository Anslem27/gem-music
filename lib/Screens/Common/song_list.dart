// ignore_for_file: use_super_parameters

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:gem/APIs/api.dart';
import 'package:gem/widgets/copy_clipboard.dart';
import 'package:gem/widgets/download_button.dart';
import 'package:gem/widgets/gradient_containers.dart';
import 'package:gem/widgets/miniplayer.dart';
import 'package:gem/widgets/playlist_popupmenu.dart';
import 'package:gem/widgets/snackbar.dart';
import 'package:gem/widgets/song_tile_trailing_menu.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:share_plus/share_plus.dart';

import '../../Helpers/image_cleaner.dart';
import '../../Services/player_service.dart';
import '../../widgets/bouncy_playlist)view.dart';

class SongsListPage extends StatefulWidget {
  final Map listItem;

  const SongsListPage({
    super.key,
    required this.listItem,
  });

  @override
  _SongsListPageState createState() => _SongsListPageState();
}

class _SongsListPageState extends State<SongsListPage> {
  int page = 1;
  bool loading = false;
  List songList = [];
  bool fetched = false;
  HtmlUnescape unescape = HtmlUnescape();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchSongs();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          widget.listItem['type'].toString() == 'songs' &&
          !loading) {
        page += 1;
        _fetchSongs();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void _fetchSongs() {
    loading = true;
    try {
      switch (widget.listItem['type'].toString()) {
        case 'songs':
          SaavnAPI()
              .fetchSongSearchResults(
            searchQuery: widget.listItem['id'].toString(),
            page: page,
          )
              .then((value) {
            setState(() {
              songList.addAll(value['songs'] as List);
              fetched = true;
              loading = false;
            });
            if (value['error'].toString() != '') {
              ShowSnackBar().showSnackBar(
                context,
                'Error: ${value["error"]}',
                duration: const Duration(seconds: 3),
              );
            }
          });
          break;
        case 'album':
          SaavnAPI()
              .fetchAlbumSongs(widget.listItem['id'].toString())
              .then((value) {
            setState(() {
              songList = value['songs'] as List;
              fetched = true;
              loading = false;
            });
            if (value['error'].toString() != '') {
              ShowSnackBar().showSnackBar(
                context,
                'Error: ${value["error"]}',
                duration: const Duration(seconds: 3),
              );
            }
          });
          break;
        case 'playlist':
          SaavnAPI()
              .fetchPlaylistSongs(widget.listItem['id'].toString())
              .then((value) {
            setState(() {
              songList = value['songs'] as List;
              fetched = true;
              loading = false;
            });
            if (value['error'] != null && value['error'].toString() != '') {
              ShowSnackBar().showSnackBar(
                context,
                'Error: ${value["error"]}',
                duration: const Duration(seconds: 3),
              );
            }
          });
          break;
        case 'mix':
          SaavnAPI()
              .getSongFromToken(
            widget.listItem['perma_url'].toString().split('/').last,
            'mix',
          )
              .then((value) {
            setState(() {
              songList = value['songs'] as List;
              fetched = true;
              loading = false;
            });

            if (value['error'] != null && value['error'].toString() != '') {
              ShowSnackBar().showSnackBar(
                context,
                'Error: ${value["error"]}',
                duration: const Duration(seconds: 3),
              );
            }
          });
          break;
        case 'show':
          SaavnAPI()
              .getSongFromToken(
            widget.listItem['perma_url'].toString().split('/').last,
            'show',
          )
              .then((value) {
            setState(() {
              songList = value['songs'] as List;
              fetched = true;
              loading = false;
            });

            if (value['error'] != null && value['error'].toString() != '') {
              ShowSnackBar().showSnackBar(
                context,
                'Error: ${value["error"]}',
                duration: const Duration(seconds: 3),
              );
            }
          });
          break;
        default:
          setState(() {
            fetched = true;
            loading = false;
          });
          ShowSnackBar().showSnackBar(
            context,
            'Error: Unsupported Type ${widget.listItem['type']}',
            duration: const Duration(seconds: 3),
          );
          break;
      }
    } catch (e) {
      setState(() {
        fetched = true;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Column(
        children: [
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: !fetched
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : BouncyPlaylistHeaderScrollView(
                      scrollController: _scrollController,
                      actions: [
                        if (songList.isNotEmpty)
                          MultiDownloadButton(
                            data: songList,
                            playlistName:
                                widget.listItem['title']?.toString() ?? 'Songs',
                          ),
                        IconButton(
                          icon: const Icon(EvaIcons.shareOutline),
                          tooltip: "Share",
                          onPressed: () {
                            Share.share(
                              widget.listItem['perma_url'].toString(),
                            );
                          },
                        ),
                        PlaylistPopupMenu(
                          data: songList,
                          title:
                              widget.listItem['title']?.toString() ?? 'Songs',
                        ),
                      ],
                      title: unescape.convert(
                        widget.listItem['title']?.toString() ?? 'Songs',
                      ),
                      subtitle: '${songList.length} Songs',
                      secondarySubtitle:
                          widget.listItem['subTitle']?.toString() ??
                              widget.listItem['subtitle']?.toString(),
                      onPlayTap: () => PlayerInvoke.init(
                        songsList: songList,
                        index: 0,
                        isOffline: false,
                      ),
                      onShuffleTap: () => PlayerInvoke.init(
                        songsList: songList,
                        index: 0,
                        isOffline: false,
                        shuffle: true,
                      ),
                      placeholderImage: 'assets/album.png',
                      imageUrl:
                          getImageUrl(widget.listItem['image']?.toString()),
                      sliverList: SliverList(
                        delegate: SliverChildListDelegate([
                          if (songList.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.only(
                                left: 20.0,
                                top: 5.0,
                                bottom: 5.0,
                              ),
                              child: Padding(
                                padding:
                                    EdgeInsets.fromLTRB(10, 10, 0, 10),
                                child: Text(
                                  "SONGS",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ...songList.map((entry) {
                            return ListTile(
                              contentPadding: const EdgeInsets.only(left: 15.0),
                              title: Text(
                                '${entry["title"]}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onLongPress: () {
                                copyToClipboard(
                                  context: context,
                                  text: '${entry["title"]}',
                                );
                              },
                              subtitle: Text(
                                '${entry["subtitle"]}',
                                overflow: TextOverflow.ellipsis,
                              ),
                              leading: Card(
                                margin: EdgeInsets.zero,
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  errorWidget: (context, _, __) => const Image(
                                    fit: BoxFit.cover,
                                    image: AssetImage(
                                      'assets/cover.jpg',
                                    ),
                                  ),
                                  imageUrl:
                                      '${entry["image"].replaceAll('http:', 'https:')}',
                                  placeholder: (context, url) => const Image(
                                    fit: BoxFit.cover,
                                    image: AssetImage(
                                      'assets/cover.jpg',
                                    ),
                                  ),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  DownloadButton(
                                    data: entry as Map,
                                    icon: 'download',
                                  ),
                                  /* LikeButton(
                                    mediaItem: null,
                                    data: entry,
                                  ), */
                                  SongTileTrailingMenu(data: entry),
                                ],
                              ),
                              onTap: () {
                                PlayerInvoke.init(
                                  songsList: songList,
                                  index: songList.indexWhere(
                                    (element) => element == entry,
                                  ),
                                  isOffline: false,
                                );
                              },
                            );
                          }).toList()
                        ]),
                      ),
                    ),
            ),
          ),
          const MiniPlayer(),
        ],
      ),
    );
  }
}
