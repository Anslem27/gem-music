import 'package:flutter/material.dart';
import 'package:gem/animations/custompageroute.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../../models/services/image_id.dart';
import '../../../models/services/lastfm/artist.dart';
import '../../../models/services/lastfm/lastfm.dart';
import '../../../models/widgets/entity/entity_image.dart';
import '../youtube_search.dart';

Row _homeTitleComponent(String title, Function()? ontap, Icon? icon) {
  return Row(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      const Spacer(),
      IconButton(
        splashRadius: 24,
        onPressed: ontap,
        icon: icon ?? const SizedBox(),
      )
    ],
  );
}

class TopSearchArtists extends StatefulWidget {
  const TopSearchArtists({super.key});

  @override
  State<TopSearchArtists> createState() => _TopSearchArtistsState();
}

class _TopSearchArtistsState extends State<TopSearchArtists> {
  @override
  Widget build(BuildContext context) {
    double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.height / 2.5;
    return FutureBuilder<List<LTopArtistsResponseArtist>>(
      future: Lastfm.getGlobalTopArtists(100),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _homeTitleComponent(
            "Most Streamed",
            () {
              Navigator.push(context,
                  FadeTransitionPageRoute(child: detailedArtists(context)));
            },
            const Icon(Icons.remove_red_eye_outlined),
          ),
          SizedBox(
            height: boxSize + 20,
            child: ListView(
              //shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              // padding: EdgeInsets.zero,
              children: snapshot.data!
                  .map(
                    (artist) => FutureBuilder<List<LArtistTopAlbum>>(
                      future:
                          ArtistGetTopAlbumsRequest(artist.name).getData(1, 1),
                      builder: (context, snapshot) => snapshot.hasData
                          ? Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: boxSize - 30,
                                    width: boxSize - 40,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          FadeTransitionPageRoute(
                                            child: YouTubeSearchPage(
                                              query:
                                                  "${artist.name}'s recent songs",
                                            ),
                                          ),
                                        );
                                      },
                                      child: EntityImage(
                                        entity: snapshot.data!.first,
                                        quality: ImageQuality.high,
                                        placeholderBehavior:
                                            PlaceholderBehavior.none,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  artist.name,
                                  textAlign: TextAlign.center,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  "Play Count ${artist.playCount}",
                                  textAlign: TextAlign.center,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            )
                          : GlassmorphicContainer(
                              height: boxSize - 30,
                              width: boxSize - 50,
                              borderRadius: 0,
                              blur: 20,
                              alignment: Alignment.bottomCenter,
                              border: 2,
                              linearGradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.5),
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
                              child: null,
                            ),
                    ),
                  )
                  .toList(),
            ),
          )
        ]);
      },
    );
  }

  detailedArtists(BuildContext context) {
    double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.height / 2.5;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text("Most Streamed Artists"),
        ),
        body: FutureBuilder<List<LTopArtistsResponseArtist>>(
          future: Lastfm.getGlobalTopArtists(100),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: SafeArea(
                child: SizedBox(
                  height: double.maxFinite,
                  child: GridView(
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    // padding: EdgeInsets.zero,
                    children: snapshot.data!
                        .map(
                          (artist) => FutureBuilder<List<LArtistTopAlbum>>(
                            future: ArtistGetTopAlbumsRequest(artist.name)
                                .getData(1, 1),
                            builder: (context, snapshot) => snapshot.hasData
                                ? Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          height: boxSize - 30,
                                          width: boxSize - 40,
                                          child: EntityImage(
                                            entity: snapshot.data!.first,
                                            quality: ImageQuality.high,
                                            placeholderBehavior:
                                                PlaceholderBehavior.none,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        artist.name,
                                        textAlign: TextAlign.center,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Text(
                                        "Play Count ${artist.playCount}",
                                        textAlign: TextAlign.center,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  )
                                : GlassmorphicContainer(
                                    height: boxSize - 30,
                                    width: boxSize - 50,
                                    borderRadius: 0,
                                    blur: 20,
                                    alignment: Alignment.bottomCenter,
                                    border: 2,
                                    linearGradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Theme.of(context)
                                              .colorScheme
                                              .secondary
                                              .withOpacity(0.5),
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
                                    child: null,
                                  ),
                          ),
                        )
                        .toList(),

                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      childAspectRatio: 0.5,
                      maxCrossAxisExtent: 5,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                  ),
                ),
              ),
            );
          },
        ));
  }
}
