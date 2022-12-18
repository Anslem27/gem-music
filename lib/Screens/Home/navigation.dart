import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gem/CustomWidgets/gradient_containers.dart';
import 'package:gem/CustomWidgets/miniplayer.dart';
import 'package:gem/CustomWidgets/snackbar.dart';
import 'package:gem/Helpers/backup_restore.dart';
import 'package:gem/Helpers/downloads_checker.dart';
import 'package:gem/Helpers/supabase.dart';
import 'package:gem/Screens/Home/home_view.dart';
import 'package:gem/Screens/Library/lib_page.dart';
import 'package:gem/Screens/YouTube/youtube_home.dart';
import 'package:gem/Services/ext_storage_provider.dart';
import 'package:gem/animations/custom_physics.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'components/drawer.dart';
import 'components/home_logic.dart';

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
              fileName: 'Gem_AutoBackup',
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
    return GradientContainer(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        drawer: gemDrawer(context),
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
                            //const LoginView(),
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
        bottomNavigationBar: _bottomNavBar(),
      ),
    );
  }

  SafeArea _bottomNavBar() {
    return SafeArea(
      child: ValueListenableBuilder(
        valueListenable: _selectedIndex,
        builder: (BuildContext context, int indexValue, Widget? child) {
          return CustomNavigationBar(
            opacity: 0.9,
            blurEffect: true,
            backgroundColor: Theme.of(
              context,
            ).scaffoldBackgroundColor.withOpacity(0.2),
            iconSize: 30.0,
            selectedColor: Theme.of(
              context,
            ).colorScheme.secondary,
            strokeColor: const Color(0x30040307),
            items: [
              CustomNavigationBarItem(
                icon: const Icon(
                  EvaIcons.homeOutline,
                  size: 30,
                ),
                selectedIcon: const Icon(
                  EvaIcons.home,
                  size: 30,
                ),
              ),
              CustomNavigationBarItem(
                icon: const Icon(
                  EvaIcons.searchOutline,
                  size: 25,
                ),
                selectedIcon: const Icon(
                  CupertinoIcons.search,
                  size: 25,
                ),
              ),
              // CustomNavigationBarItem(
              //   icon: const Icon(
              //     FontAwesomeIcons.lastfm,
              //     size: 25,
              //   ),
              //   selectedIcon: const Icon(
              //     FontAwesomeIcons.lastfm,
              //     size: 25,
              //   ),
              // ),
              CustomNavigationBarItem(
                icon: const Icon(
                  FontAwesomeIcons.itunesNote,
                  size: 25,
                ),
                selectedIcon: const Icon(
                  FontAwesomeIcons.itunesNote,
                  size: 25,
                ),
              ),
            ],
            currentIndex: _selectedIndex.value,
            onTap: (index) {
              setState(() {
                _onItemTapped(index);
              });
            },
          );
        },
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
            automaticallyImplyLeading: false,
            expandedHeight: 100,
            toolbarHeight: 120,
            backgroundColor: Colors.transparent,
            elevation: 1,
            stretch: true,
            title: AnimatedBuilder(
              animation: _scrollController,
              builder: (context, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                          child: Text(
                            greeting().toUpperCase(),
                            style: const TextStyle(
                              fontSize: 18.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {},
                          splashRadius: 24,
                          icon: const Icon(EvaIcons.speakerOutline),
                        ),
                        IconButton(
                          splashRadius: 24,
                          onPressed: () {
                            Navigator.pushNamed(context, '/recent');
                          },
                          icon: const Icon(
                            EvaIcons.activityOutline,
                            size: 25,
                          ),
                        ),
                        IconButton(
                          splashRadius: 24,
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                          icon: const Icon(EvaIcons.settings2, size: 25),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: GestureDetector(
                        child: AnimatedContainer(
                          height: 50.0,
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
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
                              const SizedBox(width: 10.0),
                              Icon(
                                CupertinoIcons.search,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                'What do you want to play?',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Theme.of(context)
                                      .textTheme
                                      .caption!
                                      .color,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {},
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ];
      },
      body: const HomeViewPage(),
    );
  }
}
