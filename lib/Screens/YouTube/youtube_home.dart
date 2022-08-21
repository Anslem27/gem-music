// ignore_for_file: use_super_parameters, no_leading_underscores_for_local_identifiers, avoid_redundant_argument_values, always_use_package_imports, avoid_field_initializers_in_const_classes, require_trailing_commas

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gem/CustomWidgets/on_hover.dart';
import 'package:gem/CustomWidgets/search_bar.dart';
import 'package:gem/CustomWidgets/snackbar.dart';
import 'package:gem/Screens/YouTube/youtube_playlist.dart';
import 'package:gem/Screens/YouTube/youtube_search.dart';
import 'package:gem/Services/youtube_services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'fetch_spotify_suggestions.dart';

bool status = false;
List searchedList = Hive.box('cache').get('ytHome', defaultValue: []) as List;
List headList = Hive.box('cache').get('ytHomeHead', defaultValue: []) as List;
List topSongs = [];
bool fetched = false;
bool emptyTop = false;

class YouTube extends StatefulWidget {
  const YouTube({Key? key}) : super(key: key);

  @override
  _YouTubeState createState() => _YouTubeState();
}

class _YouTubeState extends State<YouTube>
    with AutomaticKeepAliveClientMixin<YouTube> {
  final TextEditingController _controller = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    if (!status) {
      YouTubeServices().getMusicHome().then((value) {
        status = true;
        if (value.isNotEmpty) {
          setState(() {
            searchedList = value['body'] ?? [];
            headList = value['head'] ?? [];

            Hive.box('cache').put('ytHome', value['body']);
            Hive.box('cache').put('ytHomeHead', value['head']);
          });
        } else {
          status = false;
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext cntxt) {
    super.build(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool rotated = MediaQuery.of(context).size.height < screenWidth;
    double boxSize = !rotated
        ? MediaQuery.of(context).size.width / 2
        : MediaQuery.of(context).size.height / 2.5;
    if (boxSize > 250) boxSize = 250;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: SearchBar(
        isYt: true,
        controller: _controller,
        liveSearch: true,
        hintText: "Search Youtube",
        leading: Icon(
          CupertinoIcons.search,
          color: Theme.of(context).colorScheme.secondary,
        ),
        onQueryChanged: (_query) {
          return YouTubeServices().getSearchSuggestions(query: _query);
        },
        onSubmitted: (_query) {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (_, __, ___) => YouTubeSearchPage(
                query: _query,
              ),
            ),
          );
          _controller.text = '';
        },
        body: (searchedList.isEmpty)
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ListTile(
                          title: Text(
                            'Trending on Streaming Platforms',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary,
                              fontSize: 20,
                            ),
                          ),
                          subtitle: const Text(
                            'Try searching for these',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                            ),
                          ),
                          trailing: IconButton(
                            splashRadius: 24,
                            onPressed: () {
                              ShowSnackBar().showSnackBar(
                                  context, 'Tap the suggestion to look it up');
                            },
                            icon: const Icon(Icons.trending_up_rounded),
                          ),
                        ),
                        const SpotifySection(),
                        Icon(
                          CupertinoIcons.search,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 40,
                        ),
                        Text(
                          'Click the search field\nto search',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondary,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(10, 80, 10, 0),
                child: Column(
                  children: [
                    if (headList.isNotEmpty)
                      CarouselSlider.builder(
                        itemCount: headList.length,
                        options: CarouselOptions(
                          height: boxSize + 20,
                          viewportFraction: rotated ? 0.36 : 1.0,
                          autoPlay: true,
                          enlargeCenterPage: true,
                        ),
                        itemBuilder: (
                          BuildContext context,
                          int index,
                          int pageViewIndex,
                        ) =>
                            GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                opaque: false,
                                pageBuilder: (_, __, ___) => YouTubeSearchPage(
                                  query: headList[index]['title'].toString(),
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              errorWidget: (context, _, __) => const Image(
                                fit: BoxFit.cover,
                                image: AssetImage(
                                  'assets/ytCover.png',
                                ),
                              ),
                              imageUrl: headList[index]['image'].toString(),
                              placeholder: (context, url) => const Image(
                                fit: BoxFit.cover,
                                image: AssetImage('assets/ytCover.png'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ListView.builder(
                      itemCount: searchedList.length,
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(bottom: 10),
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 10, 0, 5),
                                  child: Text(
                                    '${searchedList[index]["title"]}',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: boxSize + 10,
                              width: double.infinity,
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                itemCount:
                                    (searchedList[index]['playlists'] as List)
                                        .length,
                                itemBuilder: (context, idx) {
                                  final item =
                                      searchedList[index]['playlists'][idx];
                                  return GestureDetector(
                                    onTap: () {
                                      item['type'] == 'video'
                                          ? Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                opaque: false,
                                                pageBuilder: (_, __, ___) =>
                                                    YouTubeSearchPage(
                                                  query:
                                                      item['title'].toString(),
                                                ),
                                              ),
                                            )
                                          : Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                opaque: false,
                                                pageBuilder: (_, __, ___) =>
                                                    YouTubePlaylist(
                                                  playlistId: item['playlistId']
                                                      .toString(),
                                                  playlistImage:
                                                      item['imageStandard']
                                                          .toString(),
                                                  playlistName:
                                                      item['title'].toString(),
                                                ),
                                              ),
                                            );
                                    },
                                    child: SizedBox(
                                      width: item['type'] != 'playlist'
                                          ? (boxSize - 30) * (16 / 9)
                                          : boxSize - 30,
                                      child: HoverBox(
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: Card(
                                                elevation: 5,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    10.0,
                                                  ),
                                                ),
                                                clipBehavior: Clip.antiAlias,
                                                child: CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  errorWidget:
                                                      (context, _, __) => Image(
                                                    fit: BoxFit.cover,
                                                    image: item['type'] !=
                                                            'playlist'
                                                        ? const AssetImage(
                                                            'assets/ytCover.png')
                                                        : const AssetImage(
                                                            'assets/cover.jpg'),
                                                  ),
                                                  imageUrl:
                                                      item['image'].toString(),
                                                  placeholder: (context, url) =>
                                                      Image(
                                                    fit: BoxFit.cover,
                                                    image: item['type'] !=
                                                            'playlist'
                                                        ? const AssetImage(
                                                            'assets/ytCover.png',
                                                          )
                                                        : const AssetImage(
                                                            'assets/cover.jpg',
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10.0,
                                              ),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    '${item["title"]}',
                                                    textAlign: TextAlign.center,
                                                    softWrap: false,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    item['type'] != 'video'
                                                        ? '${item["count"]} Tracks | ${item["description"]}'
                                                        : '${item["count"]} | ${item["description"]}',
                                                    textAlign: TextAlign.center,
                                                    softWrap: false,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .caption!
                                                          .color,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5.0,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        builder: (
                                          BuildContext context,
                                          bool isHover,
                                          Widget? child,
                                        ) {
                                          return Card(
                                            color: isHover
                                                ? null
                                                : Colors.transparent,
                                            elevation: 0,
                                            margin: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                10.0,
                                              ),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: child,
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

//spotify section of youtube page
class SpotifySection extends StatefulWidget {
  final String type = 'top';
  const SpotifySection({Key? key}) : super(key: key);
  @override
  _SpotifySectionState createState() => _SpotifySectionState();
}

class _SpotifySectionState extends State<SpotifySection>
    with AutomaticKeepAliveClientMixin<SpotifySection> {
  Future<void> getData(String type) async {
    fetched = true;
    final List temp = await compute(scrapData, type);
    setState(() {
      if (type == 'top') {
        topSongs = temp;
        if (topSongs.isNotEmpty) {
          cachedTopSongs = topSongs;
          Hive.box('cache').put(type, topSongs);
        }
        emptyTop = topSongs.isEmpty && cachedTopSongs.isEmpty;
      } else {
        viralSongs = temp;
        if (viralSongs.isNotEmpty) {
          cachedViralSongs = viralSongs;
          Hive.box('cache').put(type, viralSongs);
        }
        emptyViral = viralSongs.isEmpty && cachedViralSongs.isEmpty;
      }
    });
  }

  Future<void> getCachedData(String type) async {
    fetched = true;
    if (type == 'top') {
      cachedTopSongs =
          await Hive.box('cache').get(type, defaultValue: []) as List;
    } else {
      cachedViralSongs =
          await Hive.box('cache').get(type, defaultValue: []) as List;
    }
    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (widget.type == 'top' && topSongs.isEmpty) {
      getCachedData(widget.type);
      getData(widget.type);
    } else {
      if (viralSongs.isEmpty) {
        getCachedData(widget.type);
        getData(widget.type);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool isTop = widget.type == 'top';
    if (!fetched) {
      getCachedData(widget.type);
      getData(widget.type);
    }
    final List showList = isTop ? cachedTopSongs : cachedViralSongs;
    final bool isListEmpty = isTop ? emptyTop : emptyViral;
    return Column(
      children: [
        if (showList.length <= 10)
          isListEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "🤐Well somethin's\nmeant to be here",
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                  ],
                )
        else
          SizedBox(
            height: 100,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: showList.length,
              scrollDirection: Axis.horizontal,
              itemExtent: 70.0,
              itemBuilder: (context, index) {
                return GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 2.2,
                      child: Column(
                        children: [
                          if (showList[index]['image_url_small'] != '')
                            CachedNetworkImage(
                              width: MediaQuery.of(context).size.width / 2.5,
                              fit: BoxFit.cover,
                              imageUrl:
                                  showList[index]['image_url_small'].toString(),
                              errorWidget: (context, _, __) => const Image(
                                fit: BoxFit.cover,
                                image: AssetImage('assets/cover.jpg'),
                              ),
                              placeholder: (context, url) => const Image(
                                fit: BoxFit.cover,
                                image: AssetImage('assets/cover.jpg'),
                              ),
                            ),
                          Text(
                            //Song name
                            '${index + 1}. ${showList[index]["name"]}',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            softWrap: false,

                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            //artist name
                            (showList[index]['artists'] as List)
                                .map((e) => e['name'])
                                .toList()
                                .join(', '),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            softWrap: false,

                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).textTheme.caption!.color,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  onTap: () async {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (_, __, ___) => YouTubeSearchPage(
                          query: showList[index]['name'].toString(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
