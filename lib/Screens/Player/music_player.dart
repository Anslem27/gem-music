// ignore_for_file: use_super_parameters, use_colored_box

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gem/widgets/add_playlist.dart';
import 'package:gem/widgets/copy_clipboard.dart';
import 'package:gem/widgets/download_button.dart';
import 'package:gem/widgets/empty_screen.dart';
import 'package:gem/widgets/equalizer.dart';
import 'package:gem/widgets/like_button.dart';
import 'package:gem/widgets/popup.dart';
import 'package:gem/widgets/seek_bar.dart';
import 'package:gem/widgets/snackbar.dart';
import 'package:gem/widgets/textinput_dialog.dart';
import 'package:gem/Helpers/app_config.dart';
import 'package:gem/Helpers/dominant_color.dart';
import 'package:gem/Helpers/lyrics.dart';
import 'package:gem/Helpers/mediaitem_converter.dart';
import 'package:gem/Screens/Common/song_list.dart';
import 'package:gem/Screens/Search/albums.dart';
import 'package:gem/animations/animated_text.dart';
import 'package:get_it/get_it.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:overlapping_panels/overlapping_panels.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

import '../home/components/home_logic.dart';

class PlayScreen extends StatefulWidget {
  final List songsList;
  final bool fromMiniplayer;
  final bool? offline;
  final int index;
  final bool recommend;
  final bool fromDownloads;
  const PlayScreen({
    Key? key,
    required this.index,
    required this.songsList,
    required this.fromMiniplayer,
    required this.offline,
    required this.recommend,
    required this.fromDownloads,
  }) : super(key: key);
  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  bool fromMiniplayer = false;
  final String preferredQuality = Hive.box('settings')
      .get('streamingQuality', defaultValue: '96 kbps')
      .toString();
  final String repeatMode =
      Hive.box('settings').get('repeatMode', defaultValue: 'None').toString();
  final bool enforceRepeat =
      Hive.box('settings').get('enforceRepeat', defaultValue: false) as bool;
  final String gradientType = Hive.box('settings')
      .get('gradientType', defaultValue: 'halfDark')
      .toString();
  final bool getLyricsOnline =
      Hive.box('settings').get('getLyricsOnline', defaultValue: true) as bool;

  List<MediaItem> globalQueue = [];
  int globalIndex = 0;
  List response = [];
  bool offline = false;
  bool fromDownloads = false;
  String defaultCover = '';
  final MyTheme currentTheme = GetIt.I<MyTheme>();
  final ValueNotifier<List<Color?>?> gradientColor =
      ValueNotifier<List<Color?>?>(GetIt.I<MyTheme>().playGradientColor);

  final List<Color?>? getGradient = GetIt.I<MyTheme>().playGradientColor;
  final PanelController _panelController = PanelController();
  final AudioPlayerHandler audioHandler = GetIt.I<AudioPlayerHandler>();

  void sleepTimer(int time) {
    audioHandler.customAction('sleepTimer', {'time': time});
  }

  void sleepCounter(int count) {
    audioHandler.customAction('sleepCounter', {'count': count});
  }

  late Duration _time;

  Future<void> main() async {
    await Hive.openBox('Favorite Songs');
  }

  @override
  void initState() {
    super.initState();
    main();
    response = widget.songsList;
    globalIndex = widget.index;
    if (globalIndex == -1) {
      globalIndex = 0;
    }
    fromDownloads = widget.fromDownloads;
    if (widget.offline == null) {
      if (audioHandler.mediaItem.value?.extras!['url'].startsWith('http')
          as bool) {
        offline = false;
      } else {
        offline = true;
      }
    } else {
      offline = widget.offline!;
    }

    fromMiniplayer = widget.fromMiniplayer;
    if (!fromMiniplayer) {
      if (!Platform.isAndroid) {
        // Don't know why but it fixes the playback issue with iOS Side
        audioHandler.stop();
      }
      if (offline) {
        fromDownloads
            ? setDownValues(response)
            : (Platform.isWindows || Platform.isLinux)
                ? setOffDesktopValues(response)
                : setOffValues(response);
      } else {
        setValues(response);
        updateNplay();
      }
    }
  }

  //get dorminant color from image rendered
  Future<Color> getdominantColor(ImageProvider imageProvider) async {
    try {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(imageProvider);

      return paletteGenerator.dominantColor!.color;
    } on TimeoutException {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
              const AssetImage("assets/cover.jpg"));

      return paletteGenerator.dominantColor!.color;
    }
  }

  Future<MediaItem> setTags(SongModel response, Directory tempDir) async {
    String playTitle = response.title;
    playTitle == ''
        ? playTitle = response.displayNameWOExt
        : playTitle = response.title;
    String playArtist = response.artist!;
    playArtist == '<unknown>'
        ? playArtist = 'Unknown'
        : playArtist = response.artist!;

    final String playAlbum = response.album!;
    final int playDuration = response.duration ?? 180000;
    final String imagePath = '${tempDir.path}/${response.displayNameWOExt}.png';

    final MediaItem tempDict = MediaItem(
      id: response.id.toString(),
      album: playAlbum,
      duration: Duration(milliseconds: playDuration),
      title: playTitle.split('(')[0],
      artist: playArtist,
      genre: response.genre,
      artUri: Uri.file(imagePath),
      extras: {
        'url': response.data,
        'date_added': response.dateAdded,
        'date_modified': response.dateModified,
        'size': response.size,
        'year': response.getMap['year'],
      },
    );
    return tempDict;
  }

  void setOffDesktopValues(List response) {
    getTemporaryDirectory().then((tempDir) async {
      final File file = File('${tempDir.path}/cover.jpg');
      if (!await file.exists()) {
        final byteData = await rootBundle.load('assets/cover.jpg');
        await file.writeAsBytes(
          byteData.buffer
              .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        );
      }
      globalQueue.addAll(
        response.map(
          (song) => MediaItem(
            id: song['id'].toString(),
            album: song['album'].toString(),
            artist: song['artist'].toString(),
            duration: Duration(
              seconds: int.parse(
                (song['duration'] == null || song['duration'] == 'null')
                    ? '180'
                    : song['duration'].toString(),
              ),
            ),
            title: song['title'].toString(),
            artUri: Uri.file(file.path),
            genre: song['genre'].toString(),
            extras: {
              'url': song['path'].toString(),
              'subtitle': song['subtitle'],
              'quality': song['quality'],
            },
          ),
        ),
      );
      updateNplay();
    });
  }

  void setOffValues(List response) {
    getTemporaryDirectory().then((tempDir) async {
      final File file = File('${tempDir.path}/cover.jpg');
      if (!await file.exists()) {
        final byteData = await rootBundle.load('assets/cover.jpg');
        await file.writeAsBytes(
          byteData.buffer
              .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        );
      }
      for (int i = 0; i < response.length; i++) {
        globalQueue.add(
          await setTags(response[i] as SongModel, tempDir),
        );
      }
      updateNplay();
    });
  }

  void setDownValues(List response) {
    globalQueue.addAll(
      response.map(
        (song) => MediaItemConverter.downMapToMediaItem(song as Map),
      ),
    );
    updateNplay();
  }

  void setValues(List response) {
    globalQueue.addAll(
      response.map(
        (song) => MediaItemConverter.mapToMediaItem(
          song as Map,
          autoplay: widget.recommend,
        ),
      ),
    );
  }

  Future<void> updateNplay() async {
    await audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    await audioHandler.updateQueue(globalQueue);
    await audioHandler.skipToQueueItem(globalIndex);
    await audioHandler.play();
    if (enforceRepeat) {
      switch (repeatMode) {
        case 'None':
          audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
          break;
        case 'All':
          audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
          break;
        case 'One':
          audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
          break;
        default:
          break;
      }
    } else {
      audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
      Hive.box('settings').put('repeatMode', 'None');
    }
  }

  void updateBackgroundColors(List<Color?> value) {
    gradientColor.value = value;
    return;
  }

  String format(String msg) {
    return '${msg[0].toUpperCase()}${msg.substring(1)}: '.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    BuildContext? scaffoldContext;

    return Stack(
      children: [
        OverlappingPanels(
          right: Builder(
            builder: (context) {
              return StreamBuilder<PlaybackState>(
                stream: audioHandler.playbackState,
                builder: (context, snapshot) {
                  final playbackState = snapshot.data;
                  final processingState = playbackState?.processingState;
                  if (processingState == AudioProcessingState.idle) {
                    return const SizedBox();
                  }
                  return StreamBuilder<MediaItem?>(
                    stream: audioHandler.mediaItem,
                    builder: (context, snapshot) {
                      final mediaItem = snapshot.data;
                      final ValueNotifier<bool> done =
                          ValueNotifier<bool>(false);
                      Map lyrics = {'id': '', 'lyrics': ''};
                      final bool getLyricsOnline = offline;

                      if (offline) {
                        Lyrics.getOffLyrics(
                          mediaItem!.extras!['url'].toString(),
                        ).then((value) {
                          if (value == '' && getLyricsOnline) {
                            Lyrics.getLyrics(
                              id: mediaItem.id,
                              saavnHas:
                                  mediaItem.extras?['has_lyrics'] == 'true',
                              title: mediaItem.title,
                              artist: mediaItem.artist.toString(),
                            ).then((value) {
                              lyrics['lyrics'] = value;
                              lyrics['id'] = mediaItem.id;
                              done.value = true;
                            });
                          } else {
                            lyrics['lyrics'] = value;
                            lyrics['id'] = mediaItem.id;
                            done.value = true;
                          }
                        });
                      } else {
                        Lyrics.getLyrics(
                          id: mediaItem!.id,
                          saavnHas: mediaItem.extras?['has_lyrics'] == 'true',
                          title: mediaItem.title,
                          artist: mediaItem.artist.toString(),
                        ).then((value) {
                          lyrics['lyrics'] = value;
                          lyrics['id'] = mediaItem.id;
                          done.value = true;
                        });
                      }
                      if (snapshot.connectionState != ConnectionState.active) {
                        return const SizedBox();
                      }

                      // ignore: unnecessary_null_comparison
                      if (mediaItem == null) return const SizedBox();
                      return FutureBuilder(
                          future: getdominantColor(
                            (mediaItem.artUri.toString().startsWith('file:'))
                                ? FileImage(
                                    File(
                                      mediaItem.artUri!.toFilePath(),
                                    ),
                                  )
                                : NetworkImage(mediaItem.artUri.toString())
                                    as ImageProvider,
                          ),
                          builder:
                              (context, AsyncSnapshot<Color> colorsSnapshot) {
                            if (!colorsSnapshot.hasData) {
                              return const CircularProgressIndicator();
                            }

                            return GlassmorphicContainer(
                              width: double.maxFinite,
                              height: double.maxFinite,
                              borderRadius: 20,
                              blur: 20,
                              alignment: Alignment.bottomCenter,
                              border: 2,
                              linearGradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.black.withOpacity(0.1),
                                    Colors.black.withOpacity(0.05),
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
                                  Colors.transparent,
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: Row(
                                  children: [
                                    Container(width: 50),
                                    Expanded(
                                      child: SafeArea(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            decoration: BoxDecoration(
                                                color: colorsSnapshot.data!
                                                    .withOpacity(0.8),
                                                borderRadius:
                                                    BorderRadius.circular(16)),
                                            child: SingleChildScrollView(
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              child: Column(children: [
                                                Row(
                                                  children: [
                                                    IconButton(
                                                        splashRadius: 24,
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        icon: const Icon(
                                                            EvaIcons
                                                                .arrowIosBack)),
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              10, 10, 0, 10),
                                                      child: Text(
                                                        "Lyrics",
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 5.0),
                                                      child:
                                                          OutlinedButton.icon(
                                                        style: OutlinedButton
                                                            .styleFrom(
                                                          side:
                                                              const BorderSide(
                                                                  width: 1,
                                                                  color: Colors
                                                                      .white30),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          Feedback.forLongPress(
                                                              context);
                                                          copyToClipboard(
                                                            context: context,
                                                            text:
                                                                lyrics['lyrics']
                                                                    .toString(),
                                                          );
                                                        },
                                                        icon: const Icon(
                                                            EvaIcons.copy),
                                                        label: const Text(
                                                          "Copy",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Center(
                                                  child: SingleChildScrollView(
                                                    physics:
                                                        const BouncingScrollPhysics(),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 60,
                                                      horizontal: 20,
                                                    ),
                                                    child:
                                                        ValueListenableBuilder(
                                                      valueListenable: done,
                                                      child:
                                                          const CircularProgressIndicator(),
                                                      builder: (
                                                        BuildContext context,
                                                        bool value,
                                                        Widget? child,
                                                      ) {
                                                        return value
                                                            ? lyrics['lyrics'] ==
                                                                    ''
                                                                ? emptyScreen(
                                                                    context,
                                                                    0,
                                                                    ':( ',
                                                                    100.0,
                                                                    "Lyrics",
                                                                    60.0,
                                                                    "Not availbale",
                                                                    20.0,
                                                                    useWhite:
                                                                        true,
                                                                  )
                                                                : SelectableText(
                                                                    lyrics['lyrics']
                                                                        .toString(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: GoogleFonts.roboto(
                                                                        fontSize:
                                                                            18.0),
                                                                  )
                                                            : child!;
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ]),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                    },
                  );
                },
              );
            },
          ),
          main: Builder(
            builder: (context) {
              return StreamBuilder<MediaItem?>(
                stream: audioHandler.mediaItem,
                builder: (context, snapshot) {
                  final MediaItem? mediaItem = snapshot.data;
                  if (mediaItem == null) return const SizedBox();
                  try {
                    mediaItem.artUri.toString().startsWith('file')
                        ? getColors(
                            imageProvider: FileImage(
                              File(
                                mediaItem.artUri!.toFilePath(),
                              ),
                            ),
                          ).then((value) => updateBackgroundColors(value))
                        : getColors(
                            imageProvider: CachedNetworkImageProvider(
                              mediaItem.artUri.toString(),
                            ),
                          ).then((value) => updateBackgroundColors(value));
                  } catch (e) {
                    throw Exception;
                  }
                  return FutureBuilder(
                      future: getdominantColor(
                        (mediaItem.artUri.toString().startsWith('file:'))
                            ? FileImage(
                                File(
                                  mediaItem.artUri!.toFilePath(),
                                ),
                              )
                            : NetworkImage(mediaItem.artUri.toString())
                                as ImageProvider,
                      ),
                      builder: (context, AsyncSnapshot<Color> colorsSnapshot) {
                        if (!colorsSnapshot.hasData ||
                            colorsSnapshot.hasError) {
                          WidgetsBinding.instance
                              .addPostFrameCallback((timeStamp) {
                            setState(() {});
                          });
                          return ValueListenableBuilder(
                            valueListenable: gradientColor,
                            child: SafeArea(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.black.withOpacity(0.5),
                                      Colors.black.withOpacity(0.2),
                                      // colorsSnapshot.data!.withOpacity(0.3),
                                    ],
                                  ),
                                ),
                                child: Scaffold(
                                  resizeToAvoidBottomInset: false,
                                  backgroundColor: Colors.transparent,
                                  appBar: AppBar(
                                    elevation: 0,
                                    backgroundColor: Colors.transparent,
                                    centerTitle: true,
                                    title: Text(
                                      "Playing Album\n${(mediaItem.album.toString().toUpperCase())}",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    leading: IconButton(
                                      splashRadius: 24,
                                      icon:
                                          const Icon(Icons.expand_more_rounded),
                                      tooltip: 'Back',
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    actions: [
                                      IconButton(
                                        icon: const Icon(Iconsax.microphone),
                                        tooltip: "Lyrics",
                                        onPressed: () =>
                                            // Reveal lyrics drawer
                                            //cardKey.currentState!.toggleCard()
                                            OverlappingPanels.of(context)
                                                ?.reveal(RevealSide.right),
                                      ),
                                      if (!offline)
                                        IconButton(
                                          splashRadius: 24,
                                          icon: const Icon(MdiIcons.share),
                                          tooltip: "Share",
                                          onPressed: () {
                                            Share.share(
                                              mediaItem.extras!['perma_url']
                                                  .toString(),
                                            );
                                          },
                                        ),
                                      // if (offline)
                                      //   LikeButton(
                                      //     mediaItem: mediaItem,
                                      //     size:25
                                      //   ),
                                      //now playing song options
                                      PopupMenuButton(
                                        splashRadius: 24,
                                        icon: const Icon(
                                          Icons.more_vert_rounded,
                                        ),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                        ),
                                        onSelected: (int? value) {
                                          if (value == 10) {
                                            final Map details =
                                                MediaItemConverter
                                                    .mediaItemToMap(mediaItem);
                                            details['duration'] =
                                                '${int.parse(details["duration"].toString()) ~/ 60}:${int.parse(details["duration"].toString()) % 60}';
                                            // style: Theme.of(context).textTheme.caption,
                                            if (mediaItem.extras?['size'] !=
                                                null) {
                                              details.addEntries([
                                                MapEntry(
                                                  'date_modified',
                                                  DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                    int.parse(
                                                          mediaItem.extras![
                                                                  'date_modified']
                                                              .toString(),
                                                        ) *
                                                        1000,
                                                  ).toString().split('.').first,
                                                ),
                                                MapEntry(
                                                  'size',
                                                  '${((mediaItem.extras!['size'] as int) / (1024 * 1024)).toStringAsFixed(2)} MB',
                                                ),
                                              ]);
                                            }
                                            //song info dialog
                                            PopupDialog().showPopup(
                                              context: context,
                                              child: SingleChildScrollView(
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                padding:
                                                    const EdgeInsets.all(25.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children:
                                                      details.keys.map((e) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5.0),
                                                      child:
                                                          SelectableText.rich(
                                                        TextSpan(
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                              text: format(
                                                                e.toString(),
                                                              ),
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 17,
                                                                color: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyText1!
                                                                    .color,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text: details[e]
                                                                  .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        showCursor: true,
                                                        cursorColor:
                                                            Colors.black,
                                                        cursorRadius:
                                                            const Radius
                                                                .circular(5),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            );
                                          }
                                          if (value == 5) {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                opaque: false,
                                                pageBuilder: (_, __, ___) =>
                                                    SongsListPage(
                                                  listItem: {
                                                    'type': 'album',
                                                    'id': mediaItem
                                                        .extras?['album_id'],
                                                    'title': mediaItem.album,
                                                    'image': mediaItem.artUri,
                                                  },
                                                ),
                                              ),
                                            );
                                          }
                                          if (value == 4) {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return const Equalizer();
                                              },
                                            );
                                          }
                                          if (value == 3) {
                                            launchUrl(
                                              Uri.parse(
                                                mediaItem.genre == 'YouTube'
                                                    ? 'https://youtube.com/watch?v=${mediaItem.id}'
                                                    : 'https://www.youtube.com/results?search_query=${mediaItem.title} by ${mediaItem.artist}',
                                              ),
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          }
                                          if (value == 1) {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return SimpleDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                  ),
                                                  title: Text(
                                                    'Sleep timer',
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                    ),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets.all(
                                                          10.0),
                                                  children: [
                                                    ListTile(
                                                      title: const Text(
                                                        'Sleep Duration',
                                                      ),
                                                      dense: true,
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        setTimer(
                                                          context,
                                                          scaffoldContext,
                                                        );
                                                      },
                                                    ),
                                                    ListTile(
                                                      title: const Text(
                                                        'Sleep After',
                                                      ),
                                                      dense: true,
                                                      isThreeLine: true,
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        setCounter();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                          if (value == 0) {
                                            AddToPlaylist().addToPlaylist(
                                                context, mediaItem);
                                          }
                                        },
                                        itemBuilder: (context) => offline
                                            ? [
                                                if (mediaItem
                                                        .extras?['album_id'] !=
                                                    null)
                                                  PopupMenuItem(
                                                    value: 5,
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.album_rounded,
                                                          color:
                                                              Theme.of(context)
                                                                  .iconTheme
                                                                  .color,
                                                        ),
                                                        const SizedBox(
                                                            width: 10.0),
                                                        const Text(
                                                          'View Album',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                PopupMenuItem(
                                                  value: 1,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        CupertinoIcons.timer,
                                                        color: Theme.of(context)
                                                            .iconTheme
                                                            .color,
                                                      ),
                                                      const SizedBox(
                                                          width: 10.0),
                                                      const Text(
                                                        'Sleep timer',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (Hive.box('settings').get(
                                                  'supportEq',
                                                  defaultValue: false,
                                                ) as bool)
                                                  PopupMenuItem(
                                                    value: 4,
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .equalizer_rounded,
                                                          color:
                                                              Theme.of(context)
                                                                  .iconTheme
                                                                  .color,
                                                        ),
                                                        const SizedBox(
                                                            width: 10.0),
                                                        const Text(
                                                          'Equalizer',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                PopupMenuItem(
                                                  value: 10,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .info_outline_rounded,
                                                        color: Theme.of(context)
                                                            .iconTheme
                                                            .color,
                                                      ),
                                                      const SizedBox(
                                                          width: 10.0),
                                                      const Text(
                                                        'Track Info',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ]
                                            : [
                                                if (mediaItem
                                                        .extras?['album_id'] !=
                                                    null)
                                                  PopupMenuItem(
                                                    value: 5,
                                                    child: Row(
                                                      children: const [
                                                        Icon(
                                                          Icons.album_rounded,
                                                        ),
                                                        SizedBox(width: 10.0),
                                                        Text(
                                                          'View Album',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                PopupMenuItem(
                                                  value: 0,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Iconsax.music_playlist,
                                                        color: Theme.of(context)
                                                            .iconTheme
                                                            .color,
                                                      ),
                                                      const SizedBox(
                                                          width: 10.0),
                                                      const Text(
                                                        "Add to Playlist",
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                PopupMenuItem(
                                                  value: 1,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        CupertinoIcons.timer,
                                                        color: Theme.of(context)
                                                            .iconTheme
                                                            .color,
                                                      ),
                                                      const SizedBox(
                                                          width: 10.0),
                                                      const Text(
                                                        "Sleep Timer",
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (Hive.box('settings').get(
                                                  'supportEq',
                                                  defaultValue: false,
                                                ) as bool)
                                                  PopupMenuItem(
                                                    value: 4,
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .equalizer_rounded,
                                                          color:
                                                              Theme.of(context)
                                                                  .iconTheme
                                                                  .color,
                                                        ),
                                                        const SizedBox(
                                                            width: 10.0),
                                                        const Text("Equalizer"),
                                                      ],
                                                    ),
                                                  ),
                                                PopupMenuItem(
                                                  value: 3,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        MdiIcons.youtube,
                                                        color: Theme.of(context)
                                                            .iconTheme
                                                            .color,
                                                      ),
                                                      const SizedBox(
                                                          width: 10.0),
                                                      Text(mediaItem.genre ==
                                                              'YouTube'
                                                          ? 'Watch Video'
                                                          : 'Search Video'),
                                                    ],
                                                  ),
                                                ),
                                                PopupMenuItem(
                                                  value: 10,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .info_outline_rounded,
                                                        color: Theme.of(context)
                                                            .iconTheme
                                                            .color,
                                                      ),
                                                      const SizedBox(
                                                          width: 10.0),
                                                      const Text(
                                                        'Song Info',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                      )
                                    ],
                                  ),
                                  body: LayoutBuilder(
                                    builder: (
                                      BuildContext context,
                                      BoxConstraints constraints,
                                    ) {
                                      if (constraints.maxWidth >
                                          constraints.maxHeight) {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            // Null Artwork
                                            SizedBox(
                                              height:
                                                  constraints.maxWidth * 0.85,
                                              width:
                                                  constraints.maxWidth * 0.85,
                                              child: const Center(
                                                child: Image(
                                                  fit: BoxFit.cover,
                                                  image: AssetImage(
                                                      'assets/cover.jpg'),
                                                ),
                                              ),
                                            ),

                                            // title and controls
                                            NameNControls(
                                              mediaItem: mediaItem,
                                              offline: offline,
                                              width: constraints.maxWidth / 2,
                                              height: constraints.maxHeight,
                                              panelController: _panelController,
                                              audioHandler: audioHandler,
                                            ),
                                          ],
                                        );
                                      }
                                      return Column(
                                        children: [
                                          // Null Artwork
                                          SizedBox(
                                            height: constraints.maxWidth * 0.85,
                                            width: constraints.maxWidth * 0.85,
                                            child: const Center(
                                              child: Image(
                                                fit: BoxFit.cover,
                                                image: AssetImage(
                                                    'assets/cover.jpg'),
                                              ),
                                            ),
                                          ),

                                          // title and controls
                                          NameNControls(
                                            mediaItem: mediaItem,
                                            offline: offline,
                                            width: constraints.maxWidth,
                                            height: constraints.maxHeight -
                                                (constraints.maxWidth * 0.85),
                                            panelController: _panelController,
                                            audioHandler: audioHandler,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  // }
                                ),
                              ),
                            ),
                            builder: (BuildContext context, List<Color?>? value,
                                Widget? child) {
                              return AnimatedContainer(
                                curve: Curves.easeInOutCubic,
                                duration: const Duration(milliseconds: 600),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: gradientType == 'simple'
                                        ? Alignment.topLeft
                                        : Alignment.topCenter,
                                    end: gradientType == 'simple'
                                        ? Alignment.bottomRight
                                        : (gradientType == 'halfLight' ||
                                                gradientType == 'halfDark')
                                            ? Alignment.center
                                            : Alignment.bottomCenter,
                                    colors: gradientType == 'simple'
                                        ? Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? currentTheme.getBackGradient()
                                            : [
                                                const Color(0xfff5f9ff),
                                                Colors.white,
                                              ]
                                        : Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? [
                                                if (gradientType ==
                                                        'halfDark' ||
                                                    gradientType == 'fullDark')
                                                  value?[1] ?? Colors.grey[900]!
                                                else
                                                  value?[0] ??
                                                      Colors.grey[900]!,
                                                if (gradientType == 'fullMix')
                                                  value?[1] ?? Colors.black
                                                else
                                                  Colors.black
                                              ]
                                            : [
                                                value?[0] ??
                                                    const Color(0xfff5f9ff),
                                                Colors.white,
                                              ],
                                  ),
                                ),
                                child: child,
                              );
                            },
                          );
                        }

                        return ValueListenableBuilder(
                          valueListenable: gradientColor,
                          child: SafeArea(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    colorsSnapshot.data?.withOpacity(0.5)
                                        as Color,
                                    colorsSnapshot.data?.withOpacity(0.2)
                                        as Color,
                                    // colorsSnapshot.data!.withOpacity(0.3),
                                  ],
                                ),
                              ),
                              child: Scaffold(
                                resizeToAvoidBottomInset: false,
                                backgroundColor: Colors.transparent,
                                appBar: AppBar(
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                  centerTitle: true,
                                  title: Text(
                                    "Playing Album\n${(mediaItem.album.toString().toUpperCase())}",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  leading: IconButton(
                                    splashRadius: 24,
                                    icon: const Icon(Icons.expand_more_rounded),
                                    tooltip: 'Back',
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  actions: [
                                    IconButton(
                                      icon: const Icon(Iconsax.microphone),
                                      tooltip: "Lyrics",
                                      onPressed: () =>
                                          // Reveal lyrics drawer
                                          //cardKey.currentState!.toggleCard()
                                          OverlappingPanels.of(context)
                                              ?.reveal(RevealSide.right),
                                    ),
                                    if (!offline)
                                      IconButton(
                                        splashRadius: 24,
                                        icon: const Icon(MdiIcons.share),
                                        tooltip: "Share",
                                        onPressed: () {
                                          Share.share(
                                            mediaItem.extras!['perma_url']
                                                .toString(),
                                          );
                                        },
                                      ),
                                    //now playing song options
                                    PopupMenuButton(
                                      splashRadius: 24,
                                      icon: const Icon(
                                        Icons.more_vert_rounded,
                                      ),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                      ),
                                      onSelected: (int? value) {
                                        if (value == 10) {
                                          final Map details =
                                              MediaItemConverter.mediaItemToMap(
                                                  mediaItem);
                                          details['duration'] =
                                              '${int.parse(details["duration"].toString()) ~/ 60}:${int.parse(details["duration"].toString()) % 60}';
                                          // style: Theme.of(context).textTheme.caption,
                                          if (mediaItem.extras?['size'] !=
                                              null) {
                                            details.addEntries([
                                              MapEntry(
                                                'date_modified',
                                                DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                  int.parse(
                                                        mediaItem.extras![
                                                                'date_modified']
                                                            .toString(),
                                                      ) *
                                                      1000,
                                                ).toString().split('.').first,
                                              ),
                                              MapEntry(
                                                'size',
                                                '${((mediaItem.extras!['size'] as int) / (1024 * 1024)).toStringAsFixed(2)} MB',
                                              ),
                                            ]);
                                          }
                                          //song info dialog
                                          PopupDialog().showPopup(
                                            context: context,
                                            child: SingleChildScrollView(
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              padding:
                                                  const EdgeInsets.all(25.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: details.keys.map((e) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: SelectableText.rich(
                                                      TextSpan(
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                            text: format(
                                                              e.toString(),
                                                            ),
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 17,
                                                              color: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyText1!
                                                                  .color,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: details[e]
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      showCursor: true,
                                                      cursorColor: Colors.black,
                                                      cursorRadius:
                                                          const Radius.circular(
                                                              5),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          );
                                        }
                                        if (value == 5) {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              opaque: false,
                                              pageBuilder: (_, __, ___) =>
                                                  SongsListPage(
                                                listItem: {
                                                  'type': 'album',
                                                  'id': mediaItem
                                                      .extras?['album_id'],
                                                  'title': mediaItem.album,
                                                  'image': mediaItem.artUri,
                                                },
                                              ),
                                            ),
                                          );
                                        }
                                        if (value == 4) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return const Equalizer();
                                            },
                                          );
                                        }
                                        if (value == 3) {
                                          launchUrl(
                                            Uri.parse(
                                              mediaItem.genre == 'YouTube'
                                                  ? 'https://youtube.com/watch?v=${mediaItem.id}'
                                                  : 'https://www.youtube.com/results?search_query=${mediaItem.title} by ${mediaItem.artist}',
                                            ),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        }
                                        if (value == 1) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return SimpleDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                title: Text(
                                                  'Sleep timer',
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                  ),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.all(10.0),
                                                children: [
                                                  ListTile(
                                                    title: const Text(
                                                      'Sleep Duration',
                                                    ),
                                                    dense: true,
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      setTimer(
                                                        context,
                                                        scaffoldContext,
                                                      );
                                                    },
                                                  ),
                                                  ListTile(
                                                    title: const Text(
                                                      'Sleep After',
                                                    ),
                                                    dense: true,
                                                    isThreeLine: true,
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      setCounter();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                        if (value == 0) {
                                          AddToPlaylist().addToPlaylist(
                                              context, mediaItem);
                                        }
                                      },
                                      itemBuilder: (context) => offline
                                          ? [
                                              if (mediaItem
                                                      .extras?['album_id'] !=
                                                  null)
                                                PopupMenuItem(
                                                  value: 5,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.album_rounded,
                                                        color: Theme.of(context)
                                                            .iconTheme
                                                            .color,
                                                      ),
                                                      const SizedBox(
                                                          width: 10.0),
                                                      const Text(
                                                        'View Album',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              PopupMenuItem(
                                                value: 1,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      CupertinoIcons.timer,
                                                      color: Theme.of(context)
                                                          .iconTheme
                                                          .color,
                                                    ),
                                                    const SizedBox(width: 10.0),
                                                    const Text(
                                                      'Sleep timer',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (Hive.box('settings').get(
                                                'supportEq',
                                                defaultValue: false,
                                              ) as bool)
                                                PopupMenuItem(
                                                  value: 4,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.equalizer_rounded,
                                                        color: Theme.of(context)
                                                            .iconTheme
                                                            .color,
                                                      ),
                                                      const SizedBox(
                                                          width: 10.0),
                                                      const Text(
                                                        'Equalizer',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              PopupMenuItem(
                                                value: 10,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .info_outline_rounded,
                                                      color: Theme.of(context)
                                                          .iconTheme
                                                          .color,
                                                    ),
                                                    const SizedBox(width: 10.0),
                                                    const Text(
                                                      'Track Info',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ]
                                          : [
                                              if (mediaItem
                                                      .extras?['album_id'] !=
                                                  null)
                                                PopupMenuItem(
                                                  value: 5,
                                                  child: Row(
                                                    children: const [
                                                      Icon(
                                                        Icons.album_rounded,
                                                      ),
                                                      SizedBox(width: 10.0),
                                                      Text(
                                                        'View Album',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              PopupMenuItem(
                                                value: 0,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Iconsax.music_playlist,
                                                      color: Theme.of(context)
                                                          .iconTheme
                                                          .color,
                                                    ),
                                                    const SizedBox(width: 10.0),
                                                    const Text(
                                                      "Add to Playlist",
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 1,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      CupertinoIcons.timer,
                                                      color: Theme.of(context)
                                                          .iconTheme
                                                          .color,
                                                    ),
                                                    const SizedBox(width: 10.0),
                                                    const Text(
                                                      "Sleep Timer",
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (Hive.box('settings').get(
                                                'supportEq',
                                                defaultValue: false,
                                              ) as bool)
                                                PopupMenuItem(
                                                  value: 4,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.equalizer_rounded,
                                                        color: Theme.of(context)
                                                            .iconTheme
                                                            .color,
                                                      ),
                                                      const SizedBox(
                                                          width: 10.0),
                                                      const Text("Equalizer"),
                                                    ],
                                                  ),
                                                ),
                                              PopupMenuItem(
                                                value: 3,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      MdiIcons.youtube,
                                                      color: Theme.of(context)
                                                          .iconTheme
                                                          .color,
                                                    ),
                                                    const SizedBox(width: 10.0),
                                                    Text(mediaItem.genre ==
                                                            'YouTube'
                                                        ? 'Watch Video'
                                                        : 'Search Video'),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 10,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .info_outline_rounded,
                                                      color: Theme.of(context)
                                                          .iconTheme
                                                          .color,
                                                    ),
                                                    const SizedBox(width: 10.0),
                                                    const Text('Song Info'),
                                                  ],
                                                ),
                                              ),
                                            ],
                                    )
                                  ],
                                ),
                                body: LayoutBuilder(
                                  builder: (
                                    BuildContext context,
                                    BoxConstraints constraints,
                                  ) {
                                    if (constraints.maxWidth >
                                        constraints.maxHeight) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          // Artwork
                                          ArtWorkWidget(
                                            mediaItem: mediaItem,
                                            width: min(
                                              constraints.maxHeight / 0.9,
                                              constraints.maxWidth / 1.8,
                                            ),
                                            audioHandler: audioHandler,
                                            offline: offline,
                                            getLyricsOnline: getLyricsOnline,
                                          ),

                                          // title and controls
                                          NameNControls(
                                            mediaItem: mediaItem,
                                            offline: offline,
                                            width: constraints.maxWidth / 2,
                                            height: constraints.maxHeight,
                                            panelController: _panelController,
                                            audioHandler: audioHandler,
                                          ),
                                        ],
                                      );
                                    }
                                    return Column(
                                      children: [
                                        // Artwork
                                        colorsSnapshot.connectionState ==
                                                ConnectionState.waiting
                                            ? SizedBox(
                                                height:
                                                    constraints.maxWidth * 0.85,
                                                width:
                                                    constraints.maxWidth * 0.85,
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              )
                                            : colorsSnapshot.hasError ||
                                                    colorsSnapshot
                                                            .connectionState ==
                                                        ConnectionState.none
                                                //TODO: Add null artwork image
                                                ? SizedBox(
                                                    height:
                                                        constraints.maxWidth *
                                                            0.85,
                                                    width:
                                                        constraints.maxWidth *
                                                            0.85,
                                                    child: const Center(
                                                      child: Image(
                                                        fit: BoxFit.cover,
                                                        image: AssetImage(
                                                            'assets/cover.jpg'),
                                                      ),
                                                    ),
                                                  )
                                                : ArtWorkWidget(
                                                    mediaItem: mediaItem,
                                                    width: constraints.maxWidth,
                                                    audioHandler: audioHandler,
                                                    offline: offline,
                                                    getLyricsOnline:
                                                        getLyricsOnline,
                                                  ),

                                        // title and controls
                                        NameNControls(
                                          mediaItem: mediaItem,
                                          offline: offline,
                                          width: constraints.maxWidth,
                                          height: constraints.maxHeight -
                                              (constraints.maxWidth * 0.85),
                                          panelController: _panelController,
                                          audioHandler: audioHandler,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                // }
                              ),
                            ),
                          ),
                          builder: (BuildContext context, List<Color?>? value,
                              Widget? child) {
                            return AnimatedContainer(
                              curve: Curves.easeInOutCubic,
                              duration: const Duration(milliseconds: 600),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: gradientType == 'simple'
                                      ? Alignment.topLeft
                                      : Alignment.topCenter,
                                  end: gradientType == 'simple'
                                      ? Alignment.bottomRight
                                      : (gradientType == 'halfLight' ||
                                              gradientType == 'halfDark')
                                          ? Alignment.center
                                          : Alignment.bottomCenter,
                                  colors: gradientType == 'simple'
                                      ? Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? currentTheme.getBackGradient()
                                          : [
                                              const Color(0xfff5f9ff),
                                              Colors.white,
                                            ]
                                      : Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? [
                                              if (gradientType == 'halfDark' ||
                                                  gradientType == 'fullDark')
                                                value?[1] ?? Colors.grey[900]!
                                              else
                                                value?[0] ?? Colors.grey[900]!,
                                              if (gradientType == 'fullMix')
                                                value?[1] ?? Colors.black
                                              else
                                                Colors.black
                                            ]
                                          : [
                                              value?[0] ??
                                                  const Color(0xfff5f9ff),
                                              Colors.white,
                                            ],
                                ),
                              ),
                              child: child,
                            );
                          },
                        );
                      });
                  // );
                },
              );
            },
          ),
          onSideChange: (side) {
            // setState(() {});
          },
        ),
      ],
    );
  }

  Future<dynamic> setTimer(
    BuildContext context,
    BuildContext? scaffoldContext,
  ) {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Center(
            child: Text(
              'Select Duration',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          children: [
            Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    primaryColor: Theme.of(context).colorScheme.secondary,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hm,
                    onTimerDurationChanged: (value) {
                      _time = value;
                    },
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    sleepTimer(0);
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(
                  width: 10,
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor:
                        Theme.of(context).colorScheme.secondary == Colors.white
                            ? Colors.black
                            : Colors.white,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    sleepTimer(_time.inMinutes);
                    Navigator.pop(context);
                    ShowSnackBar().showSnackBar(
                      context,
                      'Sleep Timer set for ${_time.inMinutes} min',
                    );
                  },
                  child: const Text('OK'),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> setCounter() async {
    await showTextInputDialog(
      context: context,
      title: 'Enter number of songs',
      initialText: '',
      keyboardType: TextInputType.number,
      onSubmitted: (String value) {
        sleepCounter(
          int.parse(value),
        );
        Navigator.pop(context);
        ShowSnackBar().showSnackBar(
          context,
          'Sleep timer set for $value songs',
        );
      },
    );
  }
}

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}

class QueueState {
  static const QueueState empty =
      QueueState([], 0, [], AudioServiceRepeatMode.none);

  final List<MediaItem> queue;
  final int? queueIndex;
  final List<int>? shuffleIndices;
  final AudioServiceRepeatMode repeatMode;

  const QueueState(
    this.queue,
    this.queueIndex,
    this.shuffleIndices,
    this.repeatMode,
  );

  bool get hasPrevious =>
      repeatMode != AudioServiceRepeatMode.none || (queueIndex ?? 0) > 0;
  bool get hasNext =>
      repeatMode != AudioServiceRepeatMode.none ||
      (queueIndex ?? 0) + 1 < queue.length;

  List<int> get indices =>
      shuffleIndices ?? List.generate(queue.length, (i) => i);
}

class ControlButtons extends StatelessWidget {
  final AudioPlayerHandler audioHandler;
  final bool shuffle;
  final bool miniplayer;
  final List buttons;
  final Color? dominantColor;

  const ControlButtons(
    this.audioHandler, {
    Key? key,
    this.shuffle = false,
    this.miniplayer = false,
    this.buttons = const ['Previous', 'Play/Pause', 'Next'],
    this.dominantColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MediaItem mediaItem = audioHandler.mediaItem.value!;
    final bool online = mediaItem.extras!['url'].toString().startsWith('http');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      children: buttons.map((e) {
        switch (e) {
          case 'Like':
            return !online
                ? const SizedBox()
                : LikeButton(
                    mediaItem: mediaItem,
                    size: 22.0,
                  );
          case 'Previous':
            return StreamBuilder<QueueState>(
              stream: audioHandler.queueState,
              builder: (context, snapshot) {
                final queueState = snapshot.data;
                return IconButton(
                  icon: const Icon(Icons.skip_previous_rounded),
                  iconSize: miniplayer ? 35.0 : 45.0,
                  tooltip: "Skip previous",
                  color: dominantColor ?? Theme.of(context).iconTheme.color,
                  onPressed: queueState?.hasPrevious ?? true
                      ? audioHandler.skipToPrevious
                      : null,
                );
              },
            );
          case 'Play/Pause':
            return SizedBox(
              height: miniplayer ? 55.0 : 65.0,
              width: miniplayer ? 55.0 : 65.0,
              child: StreamBuilder<PlaybackState>(
                stream: audioHandler.playbackState,
                builder: (context, snapshot) {
                  final playbackState = snapshot.data;
                  final processingState = playbackState?.processingState;
                  final playing = playbackState?.playing ?? true;
                  return Stack(
                    children: [
                      if (processingState == AudioProcessingState.loading ||
                          processingState == AudioProcessingState.buffering)
                        Center(
                          child: SizedBox(
                            height: miniplayer ? 40.0 : 65.0,
                            width: miniplayer ? 40.0 : 65.0,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(
                                  context,
                                ).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ),
                      if (miniplayer)
                        Center(
                          child: playing
                              ? IconButton(
                                  splashRadius: 24,
                                  tooltip: 'Pause',
                                  onPressed: audioHandler.pause,
                                  icon: const Icon(
                                    Icons.pause_rounded,
                                  ),
                                  color: Colors.white,
                                )
                              : IconButton(
                                  tooltip: 'Play',
                                  onPressed: audioHandler.play,
                                  icon: const Icon(
                                    Icons.play_arrow_rounded,
                                    size: 35,
                                  ),
                                  color: Colors.white,
                                ),
                        )
                      else
                        //Play Page Pause and Play buttons
                        Center(
                          child: SizedBox(
                            height: 59,
                            width: 59,
                            child: Center(
                              child: playing
                                  ? FloatingActionButton(
                                      elevation: 10,
                                      tooltip: "Pause",
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                      onPressed: audioHandler.pause,
                                      child: const Icon(
                                        Icons.pause_rounded,
                                        size: 40.0,
                                        color: Colors.black,
                                      ),
                                    )
                                  : FloatingActionButton(
                                      elevation: 10,
                                      tooltip: "Play",
                                      backgroundColor: Colors.white,
                                      onPressed: audioHandler.play,
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        size: 40.0,
                                        color: Colors.black,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          case 'Next':
            return StreamBuilder<QueueState>(
              stream: audioHandler.queueState,
              builder: (context, snapshot) {
                final queueState = snapshot.data;
                return IconButton(
                  icon: const Icon(Icons.skip_next_rounded),
                  iconSize: miniplayer ? 35.0 : 45.0,
                  tooltip: 'Skip to next',
                  color: dominantColor ?? Theme.of(context).iconTheme.color,
                  onPressed: queueState?.hasNext ?? true
                      ? audioHandler.skipToNext
                      : null,
                );
              },
            );
          case 'Download':
            return !online
                ? const SizedBox()
                : DownloadButton(
                    size: 20.0,
                    icon: 'download',
                    data: MediaItemConverter.mediaItemToMap(mediaItem),
                  );
          default:
            break;
        }
        return const SizedBox();
      }).toList(),
    );
  }
}

abstract class AudioPlayerHandler implements AudioHandler {
  Stream<QueueState> get queueState;
  Future<void> moveQueueItem(int currentIndex, int newIndex);
  ValueStream<double> get volume;
  Future<void> setVolume(double volume);
  ValueStream<double> get speed;
}

class NowPlayingStream extends StatefulWidget {
  final AudioPlayerHandler audioHandler;
  final ScrollController? scrollController;
  final bool head;
  final double headHeight;

  const NowPlayingStream({
    Key? key,
    required this.audioHandler,
    this.scrollController,
    this.head = false,
    this.headHeight = 50,
  }) : super(key: key);

  @override
  State<NowPlayingStream> createState() => _NowPlayingStreamState();
}

class _NowPlayingStreamState extends State<NowPlayingStream> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QueueState>(
      stream: widget.audioHandler.queueState,
      builder: (context, snapshot) {
        final queueState = snapshot.data ?? QueueState.empty;
        final queue = queueState.queue;
        //place stream to recently played box
        Hive.openBox("recently_played");
        updateRandomArray(queue);

        return ReorderableListView.builder(
          header: SizedBox(
            height: widget.head ? widget.headHeight : 0,
          ),
          onReorder: (int oldIndex, int newIndex) {
            if (oldIndex < newIndex) {
              newIndex--;
            }
            widget.audioHandler.moveQueueItem(oldIndex, newIndex);
          },
          scrollController: widget.scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 10),
          shrinkWrap: true,
          itemCount: queue.length,
          itemBuilder: (context, index) {
            return Dismissible(
              key: ValueKey(queue[index].id),
              direction: index == queueState.queueIndex
                  ? DismissDirection.none
                  : DismissDirection.horizontal,
              onDismissed: (dir) {
                widget.audioHandler.removeQueueItemAt(index);
              },
              child: ListTileTheme(
                //selectedColor: Theme.of(context).colorScheme.secondary,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.only(left: 16.0, right: 10.0),
                  selected: index == queueState.queueIndex,
                  trailing: index == queueState.queueIndex
                      ? Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: SizedBox(
                            height: 50,
                            width: 40,
                            child: Image.asset("assets/ic_launcher_no_bg.png"),
                          ),
                        )
                      : queue[index]
                              .extras!['url']
                              .toString()
                              .startsWith('http')
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                LikeButton(
                                  mediaItem: queue[index],
                                ),
                                DownloadButton(
                                  icon: 'download',
                                  size: 25.0,
                                  data: {
                                    'id': queue[index].id,
                                    'artist': queue[index].artist.toString(),
                                    'album': queue[index].album.toString(),
                                    'image': queue[index].artUri.toString(),
                                    'duration': queue[index]
                                        .duration!
                                        .inSeconds
                                        .toString(),
                                    'title': queue[index].title,
                                    'url':
                                        queue[index].extras?['url'].toString(),
                                    'year':
                                        queue[index].extras?['year'].toString(),
                                    'language': queue[index]
                                        .extras?['language']
                                        .toString(),
                                    'genre': queue[index].genre?.toString(),
                                    '320kbps': queue[index].extras?['320kbps'],
                                    'has_lyrics':
                                        queue[index].extras?['has_lyrics'],
                                    'release_date':
                                        queue[index].extras?['release_date'],
                                    'album_id':
                                        queue[index].extras?['album_id'],
                                    'subtitle':
                                        queue[index].extras?['subtitle'],
                                    'perma_url':
                                        queue[index].extras?['perma_url'],
                                  },
                                )
                              ],
                            )
                          : const SizedBox(),
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (queue[index].extras?['addedByAutoplay'] as bool? ??
                          false)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const RotatedBox(
                                  quarterTurns: 3,
                                  child: Text(
                                    'Added By',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 5.0,
                                    ),
                                  ),
                                ),
                                RotatedBox(
                                  quarterTurns: 3,
                                  child: Text(
                                    'AutoPlay',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 8.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5.0),
                          ],
                        ),
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: (queue[index].artUri == null)
                            ? const SizedBox.square(
                                dimension: 50,
                                child: Image(
                                  image: AssetImage('assets/cover.jpg'),
                                ),
                              )
                            : SizedBox.square(
                                dimension: 50,
                                child: queue[index]
                                        .artUri
                                        .toString()
                                        .startsWith('file:')
                                    ? Image(
                                        fit: BoxFit.cover,
                                        image: FileImage(
                                          File(
                                            queue[index]
                                                    .artUri!
                                                    .toFilePath()
                                                    .isEmpty
                                                ? "assets/cover.jpg"
                                                : queue[index]
                                                    .artUri!
                                                    .toFilePath(),
                                          ),
                                        ),
                                        errorBuilder: (_, __, ___) {
                                          return Image.asset(
                                            'assets/cover.jpg',
                                          );
                                        },
                                      )
                                    : CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        errorWidget:
                                            (BuildContext context, _, __) =>
                                                const Image(
                                          fit: BoxFit.cover,
                                          image: AssetImage(
                                            'assets/cover.jpg',
                                          ),
                                        ),
                                        placeholder:
                                            (BuildContext context, _) =>
                                                const Image(
                                          fit: BoxFit.cover,
                                          image: AssetImage(
                                            'assets/cover.jpg',
                                          ),
                                        ),
                                        imageUrl:
                                            queue[index].artUri.toString(),
                                      ),
                              ),
                      ),
                    ],
                  ),
                  title: Text(
                    queue[index].title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: index == queueState.queueIndex
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    queue[index].artist!,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    widget.audioHandler.skipToQueueItem(index);
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

class ArtWorkWidget extends StatefulWidget {
  final MediaItem mediaItem;
  final bool offline;
  final bool getLyricsOnline;
  final double width;
  final AudioPlayerHandler audioHandler;

  const ArtWorkWidget({
    Key? key,
    required this.mediaItem,
    required this.width,
    this.offline = false,
    required this.getLyricsOnline,
    required this.audioHandler,
  }) : super(key: key);

  @override
  _ArtWorkWidgetState createState() => _ArtWorkWidgetState();
}

class _ArtWorkWidgetState extends State<ArtWorkWidget> {
  final ValueNotifier<bool> dragging = ValueNotifier<bool>(false);
  final ValueNotifier<bool> done = ValueNotifier<bool>(false);
  Map lyrics = {'id': '', 'lyrics': ''};

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.width * 0.85,
      width: widget.width * 0.85,
      child: Hero(
        tag: 'currentArtwork',
        child: StreamBuilder<QueueState>(
          stream: widget.audioHandler.queueState,
          builder: (context, snapshot) {
            final queueState = snapshot.data ?? QueueState.empty;

            final bool enabled = Hive.box('settings')
                .get('enableGesture', defaultValue: true) as bool;
            return GestureDetector(
              onTap: !enabled
                  ? null
                  : () {
                      widget.audioHandler.playbackState.value.playing
                          ? widget.audioHandler.pause()
                          : widget.audioHandler.play();
                    },
              onDoubleTap: !enabled
                  ? null
                  : () {
                      Feedback.forLongPress(context);

                      OverlappingPanels.of(context)?.reveal(RevealSide.right);
                    },
              onHorizontalDragEnd: !enabled
                  ? null
                  : (DragEndDetails details) {
                      if ((details.primaryVelocity ?? 0) > 100) {
                        if (queueState.hasPrevious) {
                          widget.audioHandler.skipToPrevious();
                        }
                      }

                      if ((details.primaryVelocity ?? 0) < -100) {
                        if (queueState.hasNext) {
                          widget.audioHandler.skipToNext();
                        }
                      }
                    },
              onLongPress: !enabled
                  ? null
                  : () {
                      if (!widget.offline) {
                        Feedback.forLongPress(context);
                        AddToPlaylist()
                            .addToPlaylist(context, widget.mediaItem);
                      }
                    },
              // onVerticalDragStart: !enabled
              //     ? null
              //     : (_) {
              //         dragging.value = true;
              //       },
              // onVerticalDragEnd: !enabled
              //     ? null
              //     : (_) {
              //         dragging.value = false;
              //       },
              // onVerticalDragUpdate: !enabled
              //     ? null
              //     : (DragUpdateDetails details) {
              //         if (details.delta.dy != 0.0) {
              //           double volume = widget.audioHandler.volume.value;
              //           volume -= details.delta.dy / 150;
              //           if (volume < 0) {
              //             volume = 0;
              //           }
              //           if (volume > 1.0) {
              //             volume = 1.0;
              //           }
              //           widget.audioHandler.setVolume(volume);
              //         }
              //       },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Card(
                    elevation: 10.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: widget.mediaItem.artUri.toString().startsWith('file')
                        //TODO: fix issue with local music image image thats low quality

                        ? widget.mediaItem.artUri!.toFilePath().isEmpty ||
                                widget.mediaItem.artUri!.hasEmptyPath ||
                                widget.mediaItem.artUri == null
                            //expression checks for an empty mediaItem file string
//Do things
                            ? const Image(
                                fit: BoxFit.cover,
                                image: AssetImage('assets/cover.jpg'),
                              )
                            : Image(
                                fit: BoxFit.cover,
                                image: FileImage(
                                  File(widget.mediaItem.artUri!.toFilePath()),
                                ),
                                errorBuilder: (_, __, ___) {
                                  return Image.asset(
                                    'assets/cover.jpg',
                                  );
                                },
                              )
                        : CachedNetworkImage(
                            fit: BoxFit.contain,
                            errorWidget: (BuildContext context, _, __) => Image(
                              fit: BoxFit.cover,
                              image: const AssetImage('assets/cover.jpg'),
                              width: widget.width * 0.6,
                              height: widget.width * 0.6,
                            ),
                            placeholder: (BuildContext context, _) =>
                                const Image(
                              fit: BoxFit.cover,
                              image: AssetImage('assets/cover.jpg'),
                            ),
                            imageUrl: widget.mediaItem.artUri.toString(),
                            width: widget.width * 0.6,
                            height: widget.width * 0.6,
                          ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: dragging,
                    child: StreamBuilder<double>(
                      stream: widget.audioHandler.volume,
                      builder: (context, snapshot) {
                        final double volumeValue = snapshot.data ?? 1.0;
                        return Center(
                          child: SizedBox(
                            width: 60.0,
                            height: widget.width * 0.7,
                            child: Card(
                              color: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.fitHeight,
                                      child: RotatedBox(
                                        quarterTurns: -1,
                                        child: SliderTheme(
                                          data:
                                              SliderTheme.of(context).copyWith(
                                            activeTrackColor: Colors.white,
                                            inactiveTrackColor:
                                                Colors.transparent,
                                            trackHeight: 0,
                                            thumbColor: Colors.white,
                                            thumbShape:
                                                const RoundSliderThumbShape(
                                              enabledThumbRadius: 1.0,
                                            ),
                                            overlayColor: Colors.transparent,
                                            overlayShape:
                                                const RoundSliderOverlayShape(
                                              overlayRadius: 0,
                                            ),
                                          ),
                                          child: ExcludeSemantics(
                                            child: Slider(
                                              value: widget
                                                  .audioHandler.volume.value,
                                              onChanged: (_) {},
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 20.0,
                                    ),
                                    child: Icon(
                                      volumeValue == 0
                                          ? Icons.volume_off_rounded
                                          : volumeValue > 0.6
                                              ? Icons.volume_up_rounded
                                              : Icons.volume_down_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    builder: (
                      BuildContext context,
                      bool value,
                      Widget? child,
                    ) {
                      return Visibility(
                        visible: value,
                        child: child!,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class NameNControls extends StatelessWidget {
  final MediaItem mediaItem;
  final bool offline;
  final double width;
  final double height;
  final PanelController panelController;
  final AudioPlayerHandler audioHandler;

  const NameNControls({
    Key? key,
    required this.width,
    required this.height,
    required this.mediaItem,
    required this.audioHandler,
    required this.panelController,
    this.offline = false,
  }) : super(key: key);

  Stream<Duration> get _bufferedPositionStream => audioHandler.playbackState
      .map((state) => state.bufferedPosition)
      .distinct();
  Stream<Duration?> get _durationStream =>
      audioHandler.mediaItem.map((item) => item?.duration).distinct();
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        AudioService.position,
        _bufferedPositionStream,
        _durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  @override
  Widget build(BuildContext context) {
    final double titleBoxHeight = height * 0.25;
    final double seekBoxHeight = height > 500 ? height * 0.15 : height * 0.2;
    final double controlBoxHeight = offline
        ? height > 500
            ? height * 0.2
            : height * 0.25
        : (height < 350
            ? height * 0.4
            : height > 500
                ? height * 0.2
                : height * 0.3);
    final double nowplayingBoxHeight =
        height > 500 ? height * 0.4 : height * 0.15;
    // final bool useFullScreenGradient = Hive.box('settings')
    //     .get('useFullScreenGradient', defaultValue: false) as bool;

    //get dorminant color from image rendered
    Future<Color> getdominantColor(ImageProvider imageProvider) async {
      try {
        final PaletteGenerator paletteGenerator =
            await PaletteGenerator.fromImageProvider(imageProvider);

        return paletteGenerator.dominantColor!.color;
      } on TimeoutException {
        final PaletteGenerator paletteGenerator =
            await PaletteGenerator.fromImageProvider(
                const AssetImage("assets/cover.jpg"));

        return paletteGenerator.dominantColor!.color;
      }
    }

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              /// Title and subtitle
              SizedBox(
                height: titleBoxHeight,
                child: PopupMenuButton<int>(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  ),
                  offset: const Offset(1.0, 0.0),
                  onSelected: (int value) {
                    if (value == 0) {
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
                    }
                    if (value == 5) {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (_, __, ___) => AlbumSearchPage(
                            query:
                                mediaItem.artist.toString().split(', ').first,
                            type: 'Artists',
                          ),
                        ),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                    if (mediaItem.extras?['album_id'] != null)
                      PopupMenuItem<int>(
                        value: 0,
                        child: Row(
                          children: const [
                            Icon(
                              Icons.album_rounded,
                            ),
                            SizedBox(width: 10.0),
                            Text('View Album'),
                          ],
                        ),
                      ),
                    if (mediaItem.artist != null)
                      PopupMenuItem<int>(
                        value: 5,
                        child: Row(
                          children: const [
                            Icon(
                              EvaIcons.person,
                            ),
                            SizedBox(width: 10.0),
                            Text(
                              'View Artist',
                            ),
                          ],
                        ),
                      ),
                  ],
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: titleBoxHeight / 10,
                          ),

                          /// Title container
                          AnimatedText(
                            text: mediaItem.title
                                .split(' (')[0]
                                .split('|')[0]
                                .trim()
                                .toUpperCase(),
                            pauseAfterRound: const Duration(seconds: 3),
                            showFadingOnlyWhenScrolling: false,
                            fadingEdgeEndFraction: 0.1,
                            fadingEdgeStartFraction: 0.1,
                            startAfter: const Duration(seconds: 2),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              // color: Theme.of(context).accentColor,
                            ),
                          ),

                          SizedBox(
                            height: titleBoxHeight / 40,
                          ),

                          /// Subtitle container
                          AnimatedText(
                            // •${mediaItem.album ?? "Unknown"}
                            text: mediaItem.artist ?? "Unknown",
                            pauseAfterRound: const Duration(seconds: 3),
                            showFadingOnlyWhenScrolling: false,
                            fadingEdgeEndFraction: 0.1,
                            fadingEdgeStartFraction: 0.1,
                            startAfter: const Duration(seconds: 2),
                            style: TextStyle(
                              fontSize: titleBoxHeight / 6.75,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Seekbar
              SizedBox(
                height: seekBoxHeight,
                width: width * 0.95,
                child: StreamBuilder<PositionData>(
                  stream: _positionDataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data ??
                        PositionData(
                          Duration.zero,
                          Duration.zero,
                          mediaItem.duration ?? Duration.zero,
                        );
                    return SeekBar(
                      width: width,
                      height: height,
                      duration: positionData.duration,
                      position: positionData.position,
                      bufferedPosition: positionData.bufferedPosition,
                      offline: offline,
                      onChangeEnd: (newPosition) {
                        audioHandler.seek(newPosition);
                      },
                      audioHandler: audioHandler,
                    );
                  },
                ),
              ),

              /// Final row starts from here
              SizedBox(
                height: controlBoxHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Center(
                    child: SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 6.0),
                              StreamBuilder<bool>(
                                stream: audioHandler.playbackState
                                    .map(
                                      (state) =>
                                          state.shuffleMode ==
                                          AudioServiceShuffleMode.all,
                                    )
                                    .distinct(),
                                builder: (context, snapshot) {
                                  final shuffleModeEnabled =
                                      snapshot.data ?? false;
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        padding: const EdgeInsets.all(3),
                                        icon: shuffleModeEnabled
                                            ? const Icon(
                                                EvaIcons.shuffle2,
                                              )
                                            : Icon(
                                                EvaIcons.shuffle2,
                                                color: Theme.of(context)
                                                    .disabledColor,
                                              ),
                                        tooltip: 'Shuffle',
                                        onPressed: () async {
                                          final enable = !shuffleModeEnabled;
                                          await audioHandler.setShuffleMode(
                                            enable
                                                ? AudioServiceShuffleMode.all
                                                : AudioServiceShuffleMode.none,
                                          );
                                        },
                                      ),
                                      if (offline)
                                        LikeButton(mediaItem: mediaItem)
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ControlButtons(
                              audioHandler,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 6.0),
                                StreamBuilder<AudioServiceRepeatMode>(
                                  stream: audioHandler.playbackState
                                      .map((state) => state.repeatMode)
                                      .distinct(),
                                  builder: (context, snapshot) {
                                    final repeatMode = snapshot.data ??
                                        AudioServiceRepeatMode.none;
                                    const texts = ['None', 'All', 'One'];
                                    final icons = [
                                      Icon(
                                        EvaIcons.repeat,
                                        color: Theme.of(context).disabledColor,
                                      ),
                                      const Icon(
                                        EvaIcons.repeat,
                                      ),
                                      const Icon(
                                        Icons.repeat_one_rounded,
                                      ),
                                    ];
                                    const cycleModes = [
                                      AudioServiceRepeatMode.none,
                                      AudioServiceRepeatMode.all,
                                      AudioServiceRepeatMode.one,
                                    ];
                                    final index =
                                        cycleModes.indexOf(repeatMode);
                                    return IconButton(
                                      icon: icons[index],
                                      tooltip:
                                          'Repeat ${texts[(index + 1) % texts.length]}',
                                      onPressed: () async {
                                        await Hive.box('settings').put(
                                          'repeatMode',
                                          texts[(index + 1) % texts.length],
                                        );
                                        await audioHandler.setRepeatMode(
                                          cycleModes[
                                              (cycleModes.indexOf(repeatMode) +
                                                      1) %
                                                  cycleModes.length],
                                        );
                                      },
                                    );
                                  },
                                ),
                                if (!offline)
                                  DownloadButton(
                                    size: 25.0,
                                    data: MediaItemConverter.mediaItemToMap(
                                      mediaItem,
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: nowplayingBoxHeight,
              ),
            ],
          ),

          //Playing Queue
          nowPlayingQueue(getdominantColor, nowplayingBoxHeight),
        ],
      ),
    );
  }

  StreamBuilder<PlaybackState> nowPlayingQueue(
      Future<ui.Color> Function(ImageProvider<Object> imageProvider)
          getdominantColor,
      double nowplayingBoxHeight) {
    return StreamBuilder<PlaybackState>(
        stream: audioHandler.playbackState,
        builder: (context, snapshot) {
          final playbackState = snapshot.data;
          final processingState = playbackState?.processingState;
          if (processingState == AudioProcessingState.idle) {
            return const SizedBox();
          }
          return StreamBuilder<MediaItem?>(
              stream: audioHandler.mediaItem,
              builder: (context, snapshot) {
                final mediaItem = snapshot.data;
                if (mediaItem == null) return const SizedBox();
                return FutureBuilder(
                    future: getdominantColor(
                      (mediaItem.artUri.toString().startsWith('file:'))
                          ? FileImage(
                              File(
                                mediaItem.artUri!.toFilePath(),
                              ),
                            )
                          : NetworkImage(mediaItem.artUri.toString())
                              as ImageProvider,
                    ),
                    builder: (context, AsyncSnapshot<Color> colorsSnapshot) {
                      if (!colorsSnapshot.hasData || colorsSnapshot.hasError) {
                        return const SizedBox();
                      }

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SlidingUpPanel(
                          minHeight: nowplayingBoxHeight - 10,
                          maxHeight: 350,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0),
                          ),
                          margin: EdgeInsets.zero,
                          padding: EdgeInsets.zero,
                          boxShadow: const [],
                          color: colorsSnapshot.data?.withOpacity(0.8) as Color,
                          // color: useFullScreenGradient
                          //     ? const Color.fromRGBO(0, 0, 0, 0.05)
                          //     : const Color.fromRGBO(0, 0, 0, 0.5),
                          controller: panelController,
                          panelBuilder: (ScrollController scrollController) {
                            return GlassmorphicContainer(
                              width: double.maxFinite,
                              height: 350,
                              borderRadius: 8,
                              blur: 20,
                              padding: const EdgeInsets.all(40),
                              alignment: Alignment.bottomCenter,
                              border: 2,
                              linearGradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    colorsSnapshot.data?.withOpacity(0.1)
                                        as Color,
                                    colorsSnapshot.data?.withOpacity(0.05)
                                        as Color,
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
                              child: NowPlayingStream(
                                head: true,
                                headHeight: nowplayingBoxHeight,
                                audioHandler: audioHandler,
                                scrollController: scrollController,
                              ),
                            );
                          },
                          header: GestureDetector(
                            onTap: () {
                              if (panelController.isPanelOpen) {
                                panelController.close();
                              } else {
                                if (panelController.panelPosition > 0.9) {
                                  panelController.close();
                                } else {
                                  panelController.open();
                                }
                              }
                            },
                            onVerticalDragUpdate: (DragUpdateDetails details) {
                              if (details.delta.dy > 0.0) {
                                panelController.animatePanelToPosition(0.0);
                              }
                            },
                            child: Container(
                              height: nowplayingBoxHeight,
                              width: width,
                              color: Colors.transparent,
                              child: Column(
                                children: [
                                  const SizedBox(height: 5),
                                  Center(
                                    child: Container(
                                      width: 30,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: colorsSnapshot.data!,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    child: Center(
                                      child: Text(
                                        "PLAYING QUEUE",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    });
              });
        });
  }
}
