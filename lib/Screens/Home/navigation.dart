// ignore_for_file: avoid_redundant_argument_values

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gem/CustomWidgets/gradient_containers.dart';
import 'package:gem/CustomWidgets/miniplayer.dart';
import 'package:gem/CustomWidgets/snackbar.dart';
import 'package:gem/Helpers/backup_restore.dart';
import 'package:gem/Helpers/downloads_checker.dart';
import 'package:gem/Helpers/supabase.dart';
import 'package:gem/Screens/Home/home_view.dart';
import 'package:gem/Screens/Library/library_main_page.dart';
import 'package:gem/Screens/LocalMusic/local_music.dart';
import 'package:gem/Screens/Search/search.dart';
import 'package:gem/Screens/Settings/setting.dart';
// import 'package:gem/Screens/YouTube/top_charts_page.dart';
import 'package:gem/Screens/YouTube/youtube_home.dart';
import 'package:gem/Services/ext_storage_provider.dart';
import 'package:gem/animations/custom_physics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);
  bool checked = false;
  String? appVersion;
  String name =
      Hive.box('settings').get('name', defaultValue: 'Guest') as String;
  bool checkUpdate =
      Hive.box('settings').get('checkUpdate', defaultValue: false) as bool;
  bool autoBackup =
      Hive.box('settings').get('autoBackup', defaultValue: false) as bool;
  DateTime? backButtonPressTime;

  void callback() {
    setState(() {});
  }

  void _onItemTapped(int index) {
    _selectedIndex.value = index;
    _pageController.jumpToPage(
      index,
    );
  }

  bool compareVersion(String latestVersion, String currentVersion) {
    bool update = false;
    final List latestList = latestVersion.split('.');
    final List currentList = currentVersion.split('.');

    for (int i = 0; i < latestList.length; i++) {
      try {
        if (int.parse(latestList[i] as String) >
            int.parse(currentList[i] as String)) {
          update = true;
          break;
        }
      } catch (e) {
        break;
      }
    }
    return update;
  }

  void updateUserDetails(String key, dynamic value) {
    final userId = Hive.box('settings').get('userId') as String?;
    SupaBase().updateUserDetails(userId, key, value);
  }

  Future<bool> handleWillPop(BuildContext context) async {
    final now = DateTime.now();
    final backButtonHasNotBeenPressedOrSnackBarHasBeenClosed =
        backButtonPressTime == null ||
            now.difference(backButtonPressTime!) > const Duration(seconds: 3);

    if (backButtonHasNotBeenPressedOrSnackBarHasBeenClosed) {
      backButtonPressTime = now;
      ShowSnackBar().showSnackBar(
        context,
        'Press back again to exit app',
        duration: const Duration(seconds: 2),
        noAction: true,
      );
      return false;
    }
    return true;
  }

  Widget checkVersion() {
    if (!checked && Theme.of(context).platform == TargetPlatform.android) {
      checked = true;
      final SupaBase db = SupaBase();
      final DateTime now = DateTime.now();
      final List lastLogin = now
          .toUtc()
          .add(const Duration(hours: 5, minutes: 30))
          .toString()
          .split('.')
        ..removeLast()
        ..join('.');
      updateUserDetails('lastLogin', '${lastLogin[0]} IST');
      final String offset =
          now.timeZoneOffset.toString().replaceAll('.000000', '');

      updateUserDetails(
        'timeZone',
        'Zone: ${now.timeZoneName}, Offset: $offset',
      );

      PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
        appVersion = packageInfo.version;
        updateUserDetails('version', packageInfo.version);

        if (checkUpdate) {
          db.getUpdate().then((Map value) async {
            if (compareVersion(
              value['LatestVersion'] as String,
              appVersion!,
            )) {
              List? abis =
                  await Hive.box('settings').get('supportedAbis') as List?;

              if (abis == null) {
                final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                final AndroidDeviceInfo androidDeviceInfo =
                    await deviceInfo.androidInfo;
                abis = androidDeviceInfo.supportedAbis;
                await Hive.box('settings').put('supportedAbis', abis);
              }

              ShowSnackBar().showSnackBar(
                context,
                'Update Available',
                duration: const Duration(seconds: 15),
                action: SnackBarAction(
                  textColor: Theme.of(context).colorScheme.secondary,
                  label: 'Update',
                  onPressed: () {
                    Navigator.pop(context);
                    if (abis!.contains('arm64-v8a')) {
                      launchUrl(
                        Uri.parse(value['arm64-v8a'] as String),
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      if (abis.contains('armeabi-v7a')) {
                        launchUrl(
                          Uri.parse(value['armeabi-v7a'] as String),
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        launchUrl(
                          Uri.parse(value['universal'] as String),
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    }
                  },
                ),
              );
            }
          });
        }
        if (autoBackup) {
          final List<String> checked = [
            'Settings',
            'Downloads',
            'Playlists',
          ];
          final List playlistNames = Hive.box('settings').get(
            'playlistNames',
            defaultValue: ['Favorite Songs'],
          ) as List;
          final Map<String, List> boxNames = {
            'Settings': ['settings'],
            'Cache': ['cache'],
            'Downloads': ['downloads'],
            'Playlists': playlistNames,
          };
          final String autoBackPath = Hive.box('settings').get(
            'autoBackPath',
            defaultValue: '',
          ) as String;
          if (autoBackPath == '') {
            ExtStorageProvider.getExtStorage(
              dirName: 'Gem/Backups',
            ).then((value) {
              Hive.box('settings').put('autoBackPath', value);
              createBackup(
                context,
                checked,
                boxNames,
                path: value,
                fileName: 'Gem_AutoBackup',
                showDialog: false,
              );
            });
          } else {
            createBackup(
              context,
              checked,
              boxNames,
              path: autoBackPath,
              fileName: 'BlackHole_AutoBackup',
              showDialog: false,
            );
          }
        }
      });
      if (Hive.box('settings').get('proxyIp') == null) {
        Hive.box('settings').put('proxyIp', '103.47.67.134');
      }
      if (Hive.box('settings').get('proxyPort') == null) {
        Hive.box('settings').put('proxyPort', 8080);
      }
      downloadChecker();
      return const SizedBox();
    } else {
      return const SizedBox();
    }
  }

  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //icon list
    final List<IconData> icondata = [
      Iconsax.home,
      MdiIcons.youtube,
      Iconsax.music_playlist,
    ];

    return GradientContainer(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        drawer: appDrawer(context),
        body: WillPopScope(
          onWillPop: () => handleWillPop(context),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView(
                          physics: const CustomPhysics(),
                          onPageChanged: (indx) {
                            _selectedIndex.value = indx;
                          },
                          controller: _pageController,
                          children: [
                            Stack(
                              children: [
                                checkVersion(),
                                homeBody(),
                              ],
                            ),
                            const YouTube(),
                            const LibraryPage(),
                          ],
                        ),
                      ),
                      const MiniPlayer()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: portaitBottomNavBar(icondata),
      ),
    );
  }

  NestedScrollView homeBody() {
    return NestedScrollView(
      physics: const BouncingScrollPhysics(),
      controller: _scrollController,
      headerSliverBuilder: (
        BuildContext context,
        bool innerBoxScrolled,
      ) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 135,
            backgroundColor: Colors.transparent,
            elevation: 0,
            //pinned: true,
            toolbarHeight: 65,
            // floating: true,
            automaticallyImplyLeading: false,
            flexibleSpace: LayoutBuilder(
              builder: (
                BuildContext context,
                BoxConstraints constraints,
              ) {
                return FlexibleSpaceBar(
                  background: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(height: 60),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 15.0,
                            ),
                            child: Text(
                              "Gem",
                              style: GoogleFonts.robotoCondensed(
                                letterSpacing: 2,
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondary,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            splashRadius: 24,
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/recent',
                              );
                            },
                            icon: const Icon(
                              Icons.history_rounded,
                              size: 35,
                            ),
                          ),
                          IconButton(
                            splashRadius: 24,
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                            icon: const Icon(Iconsax.setting, size: 30),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            stretch: true,
            toolbarHeight: 65,
            title: Align(
              alignment: Alignment.centerRight,
              child: AnimatedBuilder(
                animation: _scrollController,
                builder: (context, child) {
                  return GestureDetector(
                    child: AnimatedContainer(
                      height: 52.0,
                      duration: const Duration(
                        milliseconds: 150,
                      ),
                      padding: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          12.0,
                        ),
                        color: Theme.of(context).cardColor,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5.0,
                            offset: Offset(1, 1),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10.0,
                          ),
                          Icon(
                            CupertinoIcons.search,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Text(
                            'Songs,albums or artists',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Theme.of(context).textTheme.caption!.color,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchPage(
                          query: '',
                          fromHome: true,
                          autofocus: true,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ];
      },
      body: const HomeViewPage(),
    );
  }

  SafeArea portaitBottomNavBar(List<IconData> icondata) {
    return SafeArea(
      child: ValueListenableBuilder(
        valueListenable: _selectedIndex,
        builder: (BuildContext context, int indexValue, Widget? child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            height: 65,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Material(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black,
                child: SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ListView.builder(
                    itemCount: icondata.length,
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    itemBuilder: (ctx, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: () {
                          _onItemTapped(i);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 35,
                          decoration: BoxDecoration(
                            border: i == indexValue
                                ? const Border(
                                    top: BorderSide(
                                      width: 3.0,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                            gradient: i == indexValue
                                ? LinearGradient(
                                    colors: [
                                        Colors.grey.shade800,
                                        Colors.black
                                      ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter)
                                : null,
                          ),
                          child: Icon(icondata[i],
                              size: 37,
                              color: i == indexValue
                                  ? Colors.white
                                  : Colors.grey.shade800),
                        ),
                      ),
                    ),
                    scrollDirection: Axis.horizontal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Drawer appDrawer(BuildContext context) {
    return Drawer(
      child: GradientContainer(
        child: CustomScrollView(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              elevation: 0,
              stretch: true,
              expandedHeight: MediaQuery.of(context).size.height * 0.2,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Gem\nMusic',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 30,
                    color: Colors.white.withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                titlePadding: const EdgeInsets.only(bottom: 40.0),
                centerTitle: true,
                background: ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.black.withOpacity(0.1),
                      ],
                    ).createShader(
                      Rect.fromLTRB(0, 0, rect.width, rect.height),
                    );
                  },
                  blendMode: BlendMode.dstIn,
                  child: const Image(
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    image: AssetImage(
                      "assets/icon-white-trans.png",
                    ),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  ListTile(
                    title: Text(
                      "Home",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20.0),
                    leading: Icon(
                      Iconsax.home,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    selected: true,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  if (Platform.isAndroid)
                    ListTile(
                      title: const Text("Local Music"),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20.0),
                      leading: Icon(
                        Iconsax.music,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DownloadedSongs(
                              showPlaylists: true,
                            ),
                          ),
                        );
                      },
                    ),
                  ListTile(
                    title: const Text('Downloads'),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20.0),
                    leading: Icon(
                      Iconsax.document_download,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/downloads');
                    },
                  ),
                  ListTile(
                    title: const Text('Playlists'),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20.0),
                    leading: Icon(
                      Icons.playlist_play_rounded,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/playlists');
                    },
                  ),
                  ListTile(
                    title: const Text('Settings'),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20.0),
                    leading: Icon(
                      Iconsax.setting,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingPage(callback: callback),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: <Widget>[
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 30, 5, 20),
                    child: ListTile(
                      title: const Text("About"),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20.0),
                      leading: Icon(
                        Iconsax.info_circle,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        //TODO: Add a info dialog
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
