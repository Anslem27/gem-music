import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gem/CustomWidgets/search_bar.dart';
import 'package:gem/Screens/YouTube/youtube_search.dart';
import 'package:gem/Services/youtube_services.dart';
import 'package:hive/hive.dart';
import '../LocalMusic/widgets/preview_page.dart';
import 'components/top_artists.dart';
import 'components/trending.dart';
import 'logic/suggestions.dart';

bool status = false;
List searchedList = Hive.box('cache').get('ytHome', defaultValue: []) as List;
List headList = Hive.box('cache').get('ytHomeHead', defaultValue: []) as List;
List topSongs = [];
bool fetched = false;
bool emptyTop = false;

class YouTube extends StatefulWidget {
  const YouTube({super.key});

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
        body: Padding(
          padding: const EdgeInsets.only(top: 68.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Padding(
                      padding: EdgeInsets.fromLTRB(8, 15, 0, 15),
                      child: Text(
                        'IDEAS FOR YOU', //popular on Gem
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                StaggeredGridView.countBuilder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  itemCount: ytSuggestions.length,
                  itemBuilder: (_, index) {
                    return GestureDetector(
                      onTap: () async {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (_, __, ___) => YouTubeSearchPage(
                              query: "${ytSuggestions[index]} music",
                            ),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GlassmorphicContainer(
                              width: boxSize - 20,
                              height: boxSize - 150,
                              borderRadius: 8,
                              blur: 20,
                              alignment: Alignment.bottomCenter,
                              border: 2,
                              linearGradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFFffffff).withOpacity(0.1),
                                    const Color(0xFFFFFFFF).withOpacity(0.05),
                                  ],
                                  stops: const [
                                    0.1,
                                    1,
                                  ]),
                              borderGradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.transparent,
                                  Colors.transparent
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  ytSuggestions[index],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                  staggeredTileBuilder: (int index) {
                    return const StaggeredTile.count(1, 0.25);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Padding(
                      padding: EdgeInsets.fromLTRB(8, 15, 0, 15),
                      child: Text(
                        'CHARTS AND MORE', //popular on Gem
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                StaggeredGridView.countBuilder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  itemCount: chartsMore.length,
                  itemBuilder: (_, index) {
                    return GestureDetector(
                      onTap: () async {},
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: SizedBox(
                          height: boxSize + 10,
                          width: boxSize - 40,
                          child: GestureDetector(
                            onTap: () {
                              if (index == 0) {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (_) => PreviewPage(
                                      isSong: false,
                                      localImage: true,
                                      title: "CHARTS\nTop 20 Tracks",
                                      imageUrl: chartImg[0],
                                      sliverList: const TrendingList(
                                        type: 'top',
                                      ),
                                    ),
                                  ),
                                );
                              }
                              if (index == 1) {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (_) => PreviewPage(
                                        isSong: false,
                                        localImage: true,
                                        title:
                                            "TOP\nTop Tracks around the globe",
                                        imageUrl: chartImg[1],
                                        sliverList: const SizedBox()),
                                  ),
                                );
                              }
                            },
                            child: Column(
                              children: [
                                Image.asset(
                                  chartImg[index],
                                  height: boxSize - 30,
                                ),
                                Expanded(
                                  child: ListTile(
                                    title: Text(
                                      chartsMore[index],
                                      textAlign: TextAlign.center,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  staggeredTileBuilder: (int index) {
                    return const StaggeredTile.count(1, 1.2);
                  },
                ),
                const TopSearchArtists(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
