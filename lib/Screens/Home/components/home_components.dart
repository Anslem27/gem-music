// ignore_for_file: non_constant_identifier_names

import "package:flutter/material.dart";
import 'package:on_audio_query/on_audio_query.dart';
import '../../../Helpers/local_music_functions.dart';

//recently added songs

class RecentlyAddedSongs extends StatefulWidget {
  const RecentlyAddedSongs({super.key});

  @override
  State<RecentlyAddedSongs> createState() => _RecentlyAddedSongsState();
}

class _RecentlyAddedSongsState extends State<RecentlyAddedSongs> {
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  List<SongModel> recntly_added = [];
  bool loading = false;

  Future<void> fetchSongs() async {
    await offlineAudioQuery.requestPermission();
    recntly_added = await offlineAudioQuery.getSongs(
      sortType: SongSortType.DATE_ADDED,
    );

    setState(() {
      loading = true;
    });
  }

  @override
  void initState() {
    fetchSongs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.height / 2.5;
    return SizedBox(
      height: boxSize + 40,
      child: ListView.builder(
        itemCount: recntly_added.length,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (_, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: boxSize - 30,
              width: boxSize - 40,
              child: Column(
                children: [
                  QueryArtworkWidget(
                    id: recntly_added[index].id,
                    type: ArtworkType.AUDIO,
                    artworkHeight: boxSize - 35,
                    artworkWidth: boxSize - 40,
                    artworkBorder: BorderRadius.circular(7.0),
                    nullArtworkWidget: ClipRRect(
                      borderRadius: BorderRadius.circular(7.0),
                      child: Image(
                        fit: BoxFit.cover,
                        height: boxSize - 35,
                        width: MediaQuery.of(context).size.width / 2.5,
                        image: const AssetImage('assets/song.png'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text(
                        recntly_added[index].title.toUpperCase(),
                        textAlign: TextAlign.center,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      subtitle: Text(
                        recntly_added[index].artist as String,
                        textAlign: TextAlign.center,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// home albums at a glance

class HomeAlbums extends StatefulWidget {
  const HomeAlbums({super.key});

  @override
  State<HomeAlbums> createState() => _HomeAlbumsState();
}

class _HomeAlbumsState extends State<HomeAlbums> {
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  List<AlbumModel> home_albums = [];
  bool loading = false;

  Future<void> fetchSongs() async {
    await offlineAudioQuery.requestPermission();
    home_albums = await offlineAudioQuery.getAlbums(
      sortType: AlbumSortType.ALBUM,
    );

    setState(() {
      loading = true;
    });
  }

  @override
  void initState() {
    fetchSongs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.height / 2.5;

    return SizedBox(
      height: boxSize + 40,
      child: ListView.builder(
        itemCount: home_albums.length,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (_, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: boxSize - 30,
              width: boxSize - 40,
              child: Column(
                children: [
                  QueryArtworkWidget(
                    id: home_albums[index].id,
                    type: ArtworkType.ALBUM,
                    artworkHeight: boxSize - 35,
                    artworkWidth: boxSize - 40,
                    artworkBorder: BorderRadius.circular(7.0),
                    nullArtworkWidget: ClipRRect(
                      borderRadius: BorderRadius.circular(7.0),
                      child: Image(
                        fit: BoxFit.cover,
                        height: boxSize - 35,
                        width: MediaQuery.of(context).size.width / 2.5,
                        image: const AssetImage('assets/album.png'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text(
                        home_albums[index].album.toUpperCase(),
                        textAlign: TextAlign.center,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      subtitle: Text(
                        home_albums[index].artist as String,
                        textAlign: TextAlign.center,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// home genres at a glance

class HomeGenres extends StatefulWidget {
  const HomeGenres({super.key});

  @override
  State<HomeGenres> createState() => _HomeGenresState();
}

class _HomeGenresState extends State<HomeGenres> {
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  List<GenreModel> home_genres = [];
  bool loading = false;

  Future<void> fetchSongs() async {
    await offlineAudioQuery.requestPermission();
    home_genres = await offlineAudioQuery.getGenres(
      sortType: GenreSortType.GENRE,
    );

    setState(() {
      loading = true;
    });
  }

  @override
  void initState() {
    fetchSongs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.height / 2.5;
    return SizedBox(
      height: boxSize + 20,
      child: ListView.builder(
        itemCount: home_genres.length,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (_, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: boxSize - 30,
              width: boxSize - 40,
              child: Column(
                children: [
                  QueryArtworkWidget(
                    id: home_genres[index].id,
                    type: ArtworkType.GENRE,
                    artworkHeight: boxSize - 35,
                    artworkWidth: boxSize - 40,
                    artworkBorder: BorderRadius.circular(7.0),
                    nullArtworkWidget: ClipRRect(
                      borderRadius: BorderRadius.circular(7.0),
                      child: Image(
                        fit: BoxFit.cover,
                        height: boxSize - 35,
                        width: MediaQuery.of(context).size.width / 2.5,
                        image: const AssetImage('assets/genre.png'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text(
                        home_genres[index].genre.toUpperCase(),
                        textAlign: TextAlign.center,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      // subtitle: Text(
                      //   home_genres[index]. as String,
                      //   textAlign: TextAlign.center,
                      //   softWrap: false,
                      //   overflow: TextOverflow.ellipsis,
                      //   style: const TextStyle(
                      //     fontSize: 13,
                      //     color: Colors.grey,
                      //   ),
                      // ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// home artists at a glance

class ArtistsAtAGlance extends StatefulWidget {
  const ArtistsAtAGlance({super.key});

  @override
  State<ArtistsAtAGlance> createState() => _ArtistsAtAGlanceState();
}

class _ArtistsAtAGlanceState extends State<ArtistsAtAGlance> {
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  List<ArtistModel> a_glance = [];
  bool loading = false;

  Future<void> fetchSongs() async {
    await offlineAudioQuery.requestPermission();
    a_glance = await offlineAudioQuery.getArtists(
      sortType: ArtistSortType.ARTIST,
    );

    setState(() {
      loading = true;
    });
  }

  @override
  void initState() {
    fetchSongs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.height / 2.5;
    return SizedBox(
      height: boxSize + 40,
      child: ListView.builder(
        itemCount: a_glance.length,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (_, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: boxSize - 30,
              width: boxSize - 40,
              child: Column(
                children: [
                  QueryArtworkWidget(
                    id: a_glance[index].id,
                    type: ArtworkType.AUDIO,
                    artworkHeight: boxSize - 35,
                    artworkWidth: boxSize - 40,
                    
                    artworkBorder: BorderRadius.circular(7.0),
                    nullArtworkWidget: ClipRRect(
                      borderRadius: BorderRadius.circular(100.0),
                      child: Image(
                        fit: BoxFit.cover,
                        height: boxSize - 35,
                        width: MediaQuery.of(context).size.width / 2.5,
                        image: const AssetImage('assets/artist.png'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text(
                        a_glance[index].artist.toUpperCase(),
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
          );
        },
      ),
    );
  }
}
