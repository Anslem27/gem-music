// ignore_for_file: use_super_parameters, no_leading_underscores_for_local_identifiers

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gem/CustomWidgets/empty_screen.dart';
import 'package:gem/CustomWidgets/gradient_containers.dart';
import 'package:gem/CustomWidgets/miniplayer.dart';
import 'package:gem/CustomWidgets/search_bar.dart';
import 'package:gem/CustomWidgets/snackbar.dart';
import 'package:gem/CustomWidgets/song_tile_trailing_menu.dart';
import 'package:gem/Screens/Player/music_player.dart';
import 'package:gem/Services/youtube_services.dart';
import 'package:hive/hive.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YouTubeSearchPage extends StatefulWidget {
  final String query;
  const YouTubeSearchPage({Key? key, required this.query}) : super(key: key);
  @override
  _YouTubeSearchPageState createState() => _YouTubeSearchPageState();
}

class _YouTubeSearchPageState extends State<YouTubeSearchPage> {
  String query = '';
  bool status = false;
  List<Video> searchedList = [];
  bool fetched = false;
  bool done = true;
  bool liveSearch =
      Hive.box('settings').get('liveSearch', defaultValue: true) as bool;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _controller.text = widget.query;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool rotated =
        MediaQuery.of(context).size.height < MediaQuery.of(context).size.width;
    double boxSize = !rotated
        ? MediaQuery.of(context).size.width / 2
        : MediaQuery.of(context).size.height / 2.5;
    if (boxSize > 250) boxSize = 250;
    if (!status) {
      status = true;
      YouTubeServices()
          .fetchSearchResults(query == '' ? widget.query : query)
          .then((value) {
        setState(() {
          searchedList = value;
          fetched = true;
        });
      });
    }
    return GradientContainer(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: SearchBar(
                  isYt: true,
                  controller: _controller,
                  liveSearch: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  hintText: 'Search Youtube',
                  onQueryChanged: (_query) {
                    return YouTubeServices()
                        .getSearchSuggestions(query: _query);
                  },
                  onSubmitted: (_query) async {
                    setState(() {
                      fetched = false;
                      query = _query;
                      _controller.text = _query;
                      status = false;
                      searchedList = [];
                    });
                  },
                  body: (!fetched)
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : searchedList.isEmpty
                          ? emptyScreen(
                              context,
                              0,
                              ':( ',
                              100,
                              'Oops',
                              60,
                              'No results',
                              20,
                            )
                          : Stack(
                              children: [
                                ListView.builder(
                                  itemCount: searchedList.length,
                                  physics: const BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.fromLTRB(
                                    15,
                                    80,
                                    15,
                                    0,
                                  ),
                                  itemBuilder: (context, index) {
                                    final Widget thumbnailWidget = Card(
                                      elevation: 8,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          10.0,
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Stack(
                                        children: [
                                          CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            height: !rotated
                                                ? null
                                                : boxSize / 1.25,
                                            width: !rotated
                                                ? null
                                                : (boxSize / 1.25) * 16 / 9,
                                            errorWidget: (context, _, __) =>
                                                Image(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(
                                                searchedList[index]
                                                    .thumbnails
                                                    .standardResUrl,
                                              ),
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) =>
                                                  const Image(
                                                fit: BoxFit.cover,
                                                image: AssetImage(
                                                  'assets/ytCover.png',
                                                ),
                                              ),
                                            ),
                                            imageUrl: searchedList[index]
                                                .thumbnails
                                                .maxResUrl,
                                            placeholder: (context, url) =>
                                                const Image(
                                              fit: BoxFit.cover,
                                              image: AssetImage(
                                                'assets/ytCover.png',
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Card(
                                              elevation: 0.0,
                                              color: Colors.black54,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  6.0,
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.5),
                                                child: Text(
                                                  searchedList[index]
                                                              .duration
                                                              .toString() ==
                                                          'null'
                                                      ? 'Live now'
                                                      : searchedList[index]
                                                          .duration
                                                          .toString()
                                                          .split(
                                                            '.',
                                                          )[0]
                                                          .replaceFirst(
                                                            '0:0',
                                                            '',
                                                          ),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10.0,
                                      ),
                                      child: GestureDetector(
                                        onTap: () async {
                                          setState(() {
                                            done = false;
                                          });
                                          final Map? response =
                                              await YouTubeServices()
                                                  .formatVideo(
                                            video: searchedList[index],
                                            quality: Hive.box('settings')
                                                .get(
                                                  'ytQuality',
                                                  defaultValue: 'Low',
                                                )
                                                .toString(),
                                          );
                                          setState(() {
                                            done = true;
                                          });
                                          response == null
                                              ? ShowSnackBar().showSnackBar(
                                                  context,
                                                  'Video is still streaming',
                                                )
                                              : Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    opaque: false,
                                                    pageBuilder: (_, __, ___) =>
                                                        PlayScreen(
                                                      fromMiniplayer: false,
                                                      songsList: [response],
                                                      index: 0,
                                                      offline: false,
                                                      fromDownloads: false,
                                                      recommend: false,
                                                    ),
                                                  ),
                                                );
                                        },
                                        child: rotated
                                            ? Row(
                                                children: [
                                                  thumbnailWidget,
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            ((boxSize / 1.25) *
                                                                16 /
                                                                9) -
                                                            50,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                        15.0,
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            searchedList[index]
                                                                .title,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 22,
                                                            ),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              SizedBox(
                                                                width: MediaQuery
                                                                            .of(
                                                                      context,
                                                                    )
                                                                        .size
                                                                        .width -
                                                                    ((boxSize /
                                                                            1.25) *
                                                                        16 /
                                                                        9) -
                                                                    150,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    const SizedBox(
                                                                        height:
                                                                            5.0),
                                                                    Text(
                                                                      '${searchedList[index].author} • ${searchedList[index].engagement.viewCount} Views',
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: TextStyle(
                                                                          color: Theme.of(
                                                                        context,
                                                                      ).textTheme.caption!.color),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            10.0),
                                                                    Text(
                                                                      searchedList[
                                                                              index]
                                                                          .description,
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Theme
                                                                                .of(
                                                                          context,
                                                                        )
                                                                            .textTheme
                                                                            .caption!
                                                                            .color,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              YtSongTileTrailingMenu(
                                                                data:
                                                                    searchedList[
                                                                        index],
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Card(
                                                elevation: 8,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    10.0,
                                                  ),
                                                ),
                                                clipBehavior: Clip.antiAlias,
                                                child: GradientContainer(
                                                  child: Column(
                                                    children: [
                                                      thumbnailWidget,
                                                      ListTile(
                                                        dense: true,
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .only(
                                                          left: 15.0,
                                                        ),
                                                        title: Text(
                                                          searchedList[index]
                                                              .title,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        // isThreeLine: true,
                                                        subtitle: Text(
                                                          searchedList[index]
                                                              .author,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        trailing:
                                                            YtSongTileTrailingMenu(
                                                          data: searchedList[
                                                              index],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                      ),
                                    );
                                  },
                                ),
                                if (!done)
                                  Center(
                                    child: SizedBox.square(
                                      dimension: boxSize,
                                      child: Card(
                                        elevation: 10,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: GradientContainer(
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
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
                                  )
                              ],
                            ),
                ),
              ),
            ),
            const MiniPlayer(),
          ],
        ),
      ),
    );
  }
}
