// ignore_for_file: always_use_package_imports

import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:gem/Helpers/app_config.dart';
import 'package:gem/Screens/home/navigation.dart';
import 'package:gem/Screens/Library/downloads.dart';
import 'package:gem/Screens/Library/nowplaying.dart';
import 'package:gem/Screens/Library/recent.dart';
import 'package:gem/Screens/wizard/initial_wizard.dart';
import 'package:gem/Screens/wizard/pref.dart';
import 'package:gem/Screens/Player/music_player.dart';
import 'package:gem/Screens/Settings/setting.dart';
import 'package:gem/services/audio_service.dart';
import 'package:gem/theme/app_theme.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'Screens/Library/playlist_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Paint.enableDithering = true;

  await Hive.initFlutter();

  await openHiveBox('settings');
  await openHiveBox('downloads');
  await openHiveBox('Favorite Songs');
  await openHiveBox('cache', limit: true);
  if (Platform.isAndroid) {
    setOptimalDisplayMode();
  }
  await startService();
  runApp(const MyApp());
}

Future<void> setOptimalDisplayMode() async {
  final List<DisplayMode> supported = await FlutterDisplayMode.supported;
  final DisplayMode active = await FlutterDisplayMode.active;

  final List<DisplayMode> sameResolution = supported
      .where(
        (DisplayMode m) => m.width == active.width && m.height == active.height,
      )
      .toList()
    ..sort(
      (DisplayMode a, DisplayMode b) => b.refreshRate.compareTo(a.refreshRate),
    );

  final DisplayMode mostOptimalMode =
      sameResolution.isNotEmpty ? sameResolution.first : active;

  await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
}

Future<void> startService() async {
  final AudioPlayerHandler audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandlerImpl(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.app.gem.channel.audio',
      androidNotificationChannelName: 'Gem',
      androidNotificationOngoing: true,
      androidNotificationIcon: 'drawable/ic_stat_music_note',
      androidShowNotificationBadge: true,
      notificationColor: Colors.grey[900],
    ),
  );
  GetIt.I.registerSingleton<AudioPlayerHandler>(audioHandler);
  GetIt.I.registerSingleton<MyTheme>(MyTheme());
}

Future<void> openHiveBox(String boxName, {bool limit = false}) async {
  final box = await Hive.openBox(boxName).onError((error, stackTrace) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String dirPath = dir.path;
    File dbFile = File('$dirPath/$boxName.hive');
    File lockFile = File('$dirPath/$boxName.lock');
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      dbFile = File('$dirPath/Gem/$boxName.hive');
      lockFile = File('$dirPath/Gem/$boxName.lock');
    }
    await dbFile.delete();
    await lockFile.delete();
    await Hive.openBox(boxName);
    throw 'Failed to open $boxName Box\nError: $error';
  });
  // clear box if it grows large
  if (limit && box.length > 500) {
    box.clear();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en', '');
  late StreamSubscription _intentDataStreamSubscription;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    AppTheme.currentTheme.addListener(() {
      setState(() {});
    });
  }

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  Widget initialFuntion() {
    return Hive.box('settings').get('userId') != null
        ? const HomePage()
        : const AuthScreen();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppTheme.themeMode == ThemeMode.dark
            ? Colors.black38
            : Colors.white,
        statusBarIconBrightness: AppTheme.themeMode == ThemeMode.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarIconBrightness: AppTheme.themeMode == ThemeMode.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return MaterialApp(
      title: 'Gem',
      restorationScopeId: 'gem',
      debugShowCheckedModeBanner: false,
      themeMode: AppTheme.themeMode,
      theme: AppTheme.darkTheme(context: context),
      darkTheme: AppTheme.darkTheme(context: context),
      locale: _locale,
      routes: {
        '/': (context) => initialFuntion(),
        '/pref': (context) => const PrefScreen(),
        '/setting': (context) => const SettingPage(),
        '/playlists': (context) => const PlaylistView(),
        '/nowplaying': (context) => const NowPlaying(),
        '/recent': (context) => const RecentlyPlayed(),
        '/downloads': (context) => const Downloads(),
        '/navigation': (_) => const HomePage()
      },
      navigatorKey: navigatorKey,
    );
  }
}
