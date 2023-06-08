// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide SearchBar;
import 'package:gem/animations/custompageroute.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:gem/widgets/search_bar.dart';
import 'package:gem/Screens/YouTube/youtube_search.dart';
import 'package:gem/Services/youtube_services.dart';
import 'package:hive/hive.dart';
import '../local/widgets/preview_page.dart';
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
      body: SafeArea(
        child: SearchBar(
          isYt: true,
          controller: _controller,
          liveSearch: true,
          hintText: "Search Youtube",
          leading: Icon(
            CupertinoIcons.search,
            color: Theme.of(context).colorScheme.secondary,
          ),
          onQueryChanged: (query) {
            return YouTubeServices().getSearchSuggestions(query: query);
          },
          onSubmitted: (query) {
            Navigator.push(
              context,
              PageRouteBuilder(
                opaque: false,
                pageBuilder: (_, __, ___) => YouTubeSearchPage(
                  query: query,
                ),
              ),
            );
            _controller.text = '';
          },
          body: Stack(
            children: [
              Positioned(
                left: MediaQuery.of(context).size.width / 2.95,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width,
                  child: const Opacity(
                    opacity: 0.3,
                    child: Image(
                      image: AssetImage(
                        'assets/ic_launcher_no_bg.png',
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 68.0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(8, 15, 0, 15),
                            child: Text(
                              'IDEAS FOR YOU',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      FutureBuilder<List>(
                          future: YouTubeServices.getHomeSuggestions(
                              "music"),
                          builder: (_, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return Wrap(
                                children: List.generate(
                                    snapshot.data!.take(8).length, (index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      opaque: false,
                                      pageBuilder: (_, __, ___) =>
                                          YouTubeSearchPage(
                                        query:
                                            "${snapshot.data![index].toString()} music",
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GlassmorphicContainer(
                                    width: boxSize - 20,
                                    height: 40,
                                    borderRadius: 8,
                                    blur: 20,
                                    alignment: Alignment.bottomCenter,
                                    border: 2,
                                    linearGradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          const Color(0xFFffffff)
                                              .withOpacity(0.1),
                                          const Color(0xFFFFFFFF)
                                              .withOpacity(0.05),
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
                                        snapshot.data![index].toString(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }));
                          }),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(8, 15, 0, 15),
                            child: Text(
                              'Charts and more', //popular on Gem
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: boxSize - 20,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
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
                                          FadeTransitionPageRoute(
                                            child: PreviewPage(
                                              isSong: false,
                                              localImage: true,
                                              title: "Charts\nTop 20 Tracks",
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
                                          FadeTransitionPageRoute(
                                            child: PreviewPage(
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
