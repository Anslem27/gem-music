// ignore_for_file: use_super_parameters

import 'dart:io';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gem/widgets/gradient_containers.dart';
import 'package:gem/widgets/popup.dart';
import 'package:gem/widgets/snackbar.dart';
import 'package:gem/widgets/textinput_dialog.dart';
import 'package:gem/Helpers/app_config.dart';
import 'package:gem/Helpers/backup_restore.dart';
import 'package:gem/Helpers/picker.dart';
// import 'package:gem/Screens/Settings/player_gradient.dart';
import 'package:gem/services/ext_storage_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingPage extends StatefulWidget {
  final Function? callback;
  const SettingPage({Key? key, this.callback}) : super(key: key);
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String? appVersion;
  final Box settingsBox = Hive.box('settings');
  final MyTheme currentTheme = GetIt.I<MyTheme>();
  String downloadPath = Hive.box('settings')
      .get('downloadPath', defaultValue: '/storage/emulated/0/Music') as String;
  String autoBackPath = Hive.box('settings').get(
    'autoBackPath',
    defaultValue: '/storage/emulated/0/Gem/Backups',
  ) as String;
  final ValueNotifier<bool> includeOrExclude = ValueNotifier<bool>(
    Hive.box('settings').get('includeOrExclude', defaultValue: false) as bool,
  );
  List includedExcludedPaths = Hive.box('settings')
      .get('includedExcludedPaths', defaultValue: []) as List;
  List blacklistedHomeSections = Hive.box('settings')
      .get('blacklistedHomeSections', defaultValue: []) as List;
  String streamingQuality = Hive.box('settings')
      .get('streamingQuality', defaultValue: '96 kbps') as String;
  String ytQuality =
      Hive.box('settings').get('ytQuality', defaultValue: 'Low') as String;
  String downloadQuality = Hive.box('settings')
      .get('downloadQuality', defaultValue: '320 kbps') as String;
  String ytDownloadQuality = Hive.box('settings')
      .get('ytDownloadQuality', defaultValue: 'High') as String;
  String lang =
      Hive.box('settings').get('lang', defaultValue: 'English') as String;
  String canvasColor =
      Hive.box('settings').get('canvasColor', defaultValue: 'Grey') as String;
  String cardColor =
      Hive.box('settings').get('cardColor', defaultValue: 'Grey900') as String;
  String theme =
      Hive.box('settings').get('theme', defaultValue: 'Default') as String;
  Map userThemes =
      Hive.box('settings').get('userThemes', defaultValue: {}) as Map;

  bool useProxy =
      Hive.box('settings').get('useProxy', defaultValue: false) as bool;
  String themeColor = Hive.box('settings')
      .get('themeColor', defaultValue: 'Dark Purple') as String;
  int colorHue = Hive.box('settings').get('colorHue', defaultValue: 400) as int;
  int downFilename =
      Hive.box('settings').get('downFilename', defaultValue: 0) as int;

  List miniButtonsOrder = Hive.box('settings').get(
    'miniButtonsOrder',
    defaultValue: ['Like', 'Previous', 'Play/Pause', 'Next', 'Download'],
  ) as List;
  List preferredLanguage = Hive.box('settings')
      .get('preferredLanguage', defaultValue: ['English'])?.toList() as List;
  List preferredMiniButtons = Hive.box('settings').get(
    'preferredMiniButtons',
    defaultValue: ['Previous', 'Play/Pause', 'Next'],
  )?.toList() as List;

  @override
  void initState() {
    main();
    super.initState();
  }

  Future<void> main() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    setState(
      () {},
    );
  }

  bool compareVersion(String latestVersion, String currentVersion) {
    bool update = false;
    final List<String> latestList = latestVersion.split('.');
    final List<String> currentList = currentVersion.split('.');

    for (int i = 0; i < latestList.length; i++) {
      try {
        if (int.parse(latestList[i]) > int.parse(currentList[i])) {
          update = true;
          break;
        }
      } catch (e) {
        break;
      }
    }

    return update;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> userThemesList = <String>[
      'Default',
      ...userThemes.keys.map((theme) => theme as String),
      'Custom',
    ];

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            elevation: 0,
            stretch: true,
            pinned: true,
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Theme.of(context).colorScheme.secondary
                : null,
            title: const Text(
              'Settings',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                  child: GradientCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                          child: Text(
                            'Theming',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // BoxSwitchTile(
                        //   title: const Text(
                        //     'Dark Mode',
                        //   ),
                        //   keyName: 'darkMode',
                        //   defaultValue: true,
                        //   onChanged: (bool val, Box box) {
                        //     box.put(
                        //       'useSystemTheme',
                        //       false,
                        //     );
                        //     currentTheme.switchTheme(
                        //       isDark: val,
                        //       useSystemTheme: false,
                        //     );
                        //     switchToCustomTheme();
                        //   },
                        // ),
                        amoledSettings(),
                        // BoxSwitchTile(
                        //   title: const Text(
                        //     'Use System Theme',
                        //   ),
                        //   subtitle:
                        //       const Text("We prefer using Gem with dark mode"),
                        //   keyName: 'useSystemTheme',
                        //   defaultValue: true,
                        //   onChanged: (bool val, Box box) {
                        //     currentTheme.switchTheme(useSystemTheme: val);
                        //     switchToCustomTheme();
                        //   },
                        // ),
                        ListTile(
                          title: const Text('Accent Colors'),
                          subtitle: Text(themeColor),
                          trailing: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100.0),
                                color: Theme.of(context).colorScheme.secondary,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey[900]!,
                                    blurRadius: 5.0,
                                    offset: const Offset(
                                      0.0,
                                      3.0,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            showModalBottomSheet(
                              isDismissible: true,
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (BuildContext context) {
                                final List<String> colors = [
                                  'Purple',
                                  'Deep Purple',
                                  'Indigo',
                                  'Blue',
                                  'Light Blue',
                                  'Cyan',
                                  'Teal',
                                  'Green',
                                  'Light Green',
                                  'Lime',
                                  'Yellow',
                                  'Amber',
                                  'Orange',
                                  'Deep Orange',
                                  'Red',
                                  'Pink',
                                  'White',
                                ];
                                return BottomGradientContainer(
                                  borderRadius: BorderRadius.circular(
                                    20.0,
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    itemCount: colors.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 15.0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            for (int hue in [
                                              100,
                                              200,
                                              400,
                                              700
                                            ])
                                              GestureDetector(
                                                onTap: () {
                                                  themeColor = colors[index];
                                                  colorHue = hue;
                                                  currentTheme.switchColor(
                                                    colors[index],
                                                    colorHue,
                                                  );
                                                  setState(
                                                    () {},
                                                  );
                                                  switchToCustomTheme();
                                                  Navigator.pop(context);
                                                },
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.125,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.125,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50.0),
                                                    color: MyTheme().getColor(
                                                        colors[index], hue),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color:
                                                            Colors.grey[900]!,
                                                        blurRadius: 5.0,
                                                        offset: const Offset(
                                                          0.0,
                                                          3.0,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  child: (themeColor ==
                                                              colors[index] &&
                                                          colorHue == hue)
                                                      ? const Icon(
                                                          Icons.done_rounded,
                                                        )
                                                      : const SizedBox(),
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                          dense: true,
                        ),
                        backgroundGradient(context),
                        currentThemeConfig(context, userThemesList),
                        customThemeConfig(context)
                      ],
                    ),
                  ),
                ),
                appUiSection(context),
                musicPrefs(context),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    10.0,
                    10.0,
                    10.0,
                    10.0,
                  ),
                  child: GradientCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(
                            15,
                            15,
                            15,
                            0,
                          ),
                          child: Text(
                            'Download',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              //color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        ListTile(
                          title: const Text(
                            'Download Quality',
                          ),
                          onTap: () {},
                          trailing: DropdownButton(
                            value: downloadQuality,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color,
                            ),
                            underline: const SizedBox(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(
                                  () {
                                    downloadQuality = newValue;
                                    Hive.box('settings')
                                        .put('downloadQuality', newValue);
                                  },
                                );
                              }
                            },
                            items: <String>['96 kbps', '160 kbps', '320 kbps']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                ),
                              );
                            }).toList(),
                          ),
                          dense: true,
                        ),
                        ListTile(
                          title: const Text(
                            'Youtube Download Quality',
                          ),
                          subtitle: const Text(
                            'Higher quality consumes more data ',
                          ),
                          onTap: () {},
                          trailing: DropdownButton(
                            value: ytDownloadQuality,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color,
                            ),
                            underline: const SizedBox(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(
                                  () {
                                    ytDownloadQuality = newValue;
                                    Hive.box('settings')
                                        .put('ytDownloadQuality', newValue);
                                  },
                                );
                              }
                            },
                            items: <String>['Low', 'High']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                ),
                              );
                            }).toList(),
                          ),
                          dense: true,
                        ),
                        ListTile(
                          title: const Text(
                            'Download directory',
                          ),
                          //subtitle: Text(downloadPath),
                          trailing: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.grey[700],
                            ),
                            onPressed: () async {
                              downloadPath =
                                  await ExtStorageProvider.getExtStorage(
                                        dirName: 'Music',
                                        writeAccess: true,
                                      ) ??
                                      '/storage/emulated/0/Music';
                              Hive.box('settings')
                                  .put('downloadPath', downloadPath);
                              setState(
                                () {},
                              );
                            },
                            child: const Text(
                              'Reset',
                            ),
                          ),
                          onTap: () async {
                            final String temp = await Picker.selectFolder(
                              context: context,
                              message: 'Select download location',
                            );
                            if (temp.trim() != '') {
                              downloadPath = temp;
                              Hive.box('settings').put('downloadPath', temp);
                              setState(
                                () {},
                              );
                            } else {
                              ShowSnackBar().showSnackBar(
                                context,
                                'No folder selected',
                              );
                            }
                          },
                          dense: true,
                        ),
                        ListTile(
                          title: const Text(
                            'Download name format',
                          ),
                          dense: true,
                          onTap: () {
                            showModalBottomSheet(
                              isDismissible: true,
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (BuildContext context) {
                                return BottomGradientContainer(
                                  borderRadius: BorderRadius.circular(
                                    20.0,
                                  ),
                                  child: ListView(
                                    physics: const BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.fromLTRB(
                                      0,
                                      10,
                                      0,
                                      10,
                                    ),
                                    children: [
                                      CheckboxListTile(
                                        activeColor: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        title: const Text(
                                          'Title - Artist',
                                        ),
                                        value: downFilename == 0,
                                        selected: downFilename == 0,
                                        onChanged: (bool? val) {
                                          if (val ?? false) {
                                            downFilename = 0;
                                            settingsBox.put('downFilename', 0);
                                            Navigator.pop(context);
                                          }
                                        },
                                      ),
                                      CheckboxListTile(
                                        activeColor: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        title: const Text(
                                          'Artist - Title',
                                        ),
                                        value: downFilename == 1,
                                        selected: downFilename == 1,
                                        onChanged: (val) {
                                          if (val ?? false) {
                                            downFilename = 1;
                                            settingsBox.put('downFilename', 1);
                                            Navigator.pop(context);
                                          }
                                        },
                                      ),
                                      CheckboxListTile(
                                        activeColor: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        title: const Text('Title'),
                                        value: downFilename == 2,
                                        selected: downFilename == 2,
                                        onChanged: (val) {
                                          if (val ?? false) {
                                            downFilename = 2;
                                            settingsBox.put('downFilename', 2);
                                            Navigator.pop(context);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        const BoxSwitchTile(
                          title: Text(
                            'Create album folder',
                          ),
                          keyName: 'createDownloadFolder',
                          defaultValue: false,
                        ),
                        const BoxSwitchTile(
                          title: Text(
                            'Create Youtube folder',
                          ),
                          keyName: 'createYoutubeFolder',
                          defaultValue: false,
                        ),
                        const BoxSwitchTile(
                          title: Text(
                            'Download lyrics',
                          ),
                          keyName: 'downloadLyrics',
                          defaultValue: false,
                          isThreeLine: false,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    10.0,
                    10.0,
                    10.0,
                    10.0,
                  ),
                  child: GradientCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(
                            15,
                            15,
                            15,
                            0,
                          ),
                          child: Text(
                            'Others',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              //color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        ListTile(
                          title: const Text('Folders'),
                          subtitle: const Text(
                            "Pick folders where you want us to pick your music, or hide what you dont want to appear in Gem",
                          ),
                          dense: true,
                          onTap: () {
                            final GlobalKey<AnimatedListState> listKey =
                                GlobalKey<AnimatedListState>();
                            showModalBottomSheet(
                              isDismissible: true,
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (BuildContext context) {
                                return BottomGradientContainer(
                                  borderRadius: BorderRadius.circular(20.0),
                                  child: AnimatedList(
                                    physics: const BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.fromLTRB(
                                      0,
                                      10,
                                      0,
                                      10,
                                    ),
                                    key: listKey,
                                    initialItemCount:
                                        includedExcludedPaths.length + 2,
                                    itemBuilder: (cntxt, idx, animation) {
                                      if (idx == 0) {
                                        return ValueListenableBuilder(
                                          valueListenable: includeOrExclude,
                                          builder: (
                                            BuildContext context,
                                            bool value,
                                            Widget? widget,
                                          ) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: <Widget>[
                                                    ChoiceChip(
                                                      label: const Text(
                                                        'Excluded',
                                                      ),
                                                      selectedColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .secondary
                                                              .withOpacity(0.2),
                                                      labelStyle: TextStyle(
                                                        color: !value
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .secondary
                                                            : Theme.of(context)
                                                                .textTheme
                                                                .bodyText1!
                                                                .color,
                                                        fontWeight: !value
                                                            ? FontWeight.w600
                                                            : FontWeight.normal,
                                                      ),
                                                      selected: !value,
                                                      onSelected:
                                                          (bool selected) {
                                                        includeOrExclude.value =
                                                            !selected;
                                                        settingsBox.put(
                                                          'includeOrExclude',
                                                          !selected,
                                                        );
                                                      },
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    ChoiceChip(
                                                      label: const Text(
                                                        'Included',
                                                      ),
                                                      selectedColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .secondary
                                                              .withOpacity(0.2),
                                                      labelStyle: TextStyle(
                                                        color: value
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .secondary
                                                            : Theme.of(context)
                                                                .textTheme
                                                                .bodyText1!
                                                                .color,
                                                        fontWeight: value
                                                            ? FontWeight.w600
                                                            : FontWeight.normal,
                                                      ),
                                                      selected: value,
                                                      onSelected:
                                                          (bool selected) {
                                                        includeOrExclude.value =
                                                            selected;
                                                        settingsBox.put(
                                                          'includeOrExclude',
                                                          selected,
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 5.0,
                                                    top: 5.0,
                                                    bottom: 10.0,
                                                  ),
                                                  child: Text(
                                                    value
                                                        ? 'Included Folders'
                                                        : 'Excluded Folders',
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                      if (idx == 1) {
                                        return ListTile(
                                          title: const Text('Add new'),
                                          leading: const Icon(
                                            CupertinoIcons.add,
                                          ),
                                          onTap: () async {
                                            final String temp =
                                                await Picker.selectFolder(
                                              context: context,
                                            );
                                            if (temp.trim() != '' &&
                                                !includedExcludedPaths
                                                    .contains(temp)) {
                                              includedExcludedPaths.add(temp);
                                              Hive.box('settings').put(
                                                'includedExcludedPaths',
                                                includedExcludedPaths,
                                              );
                                              listKey.currentState!.insertItem(
                                                includedExcludedPaths.length,
                                              );
                                            } else {
                                              if (temp.trim() == '') {
                                                Navigator.pop(context);
                                              }
                                              ShowSnackBar().showSnackBar(
                                                context,
                                                temp.trim() == ''
                                                    ? 'No folder selected'
                                                    : 'Already added',
                                              );
                                            }
                                          },
                                        );
                                      }

                                      return SizeTransition(
                                        sizeFactor: animation,
                                        child: ListTile(
                                          leading: const Icon(
                                            CupertinoIcons.folder,
                                          ),
                                          title: Text(
                                            includedExcludedPaths[idx - 2]
                                                .toString(),
                                          ),
                                          trailing: IconButton(
                                            icon: const Icon(
                                              CupertinoIcons.clear,
                                              size: 15.0,
                                            ),
                                            tooltip: 'Remove',
                                            onPressed: () {
                                              includedExcludedPaths
                                                  .removeAt(idx - 2);
                                              Hive.box('settings').put(
                                                'includedExcludedPaths',
                                                includedExcludedPaths,
                                              );
                                              listKey.currentState!.removeItem(
                                                idx,
                                                (context, animation) =>
                                                    Container(),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        const BoxSwitchTile(
                          title: Text(
                            'Search lyrics for local music',
                          ),
                          subtitle: Text(
                            'Search online for local music lyrics',
                          ),
                          keyName: 'getLyricsOnline',
                          defaultValue: true,
                        ),
                        const BoxSwitchTile(
                          title: Text(
                            'Support Equalizer',
                          ),
                          keyName: 'supportEq',
                          defaultValue: false,
                        ),
                        const BoxSwitchTile(
                          title: Text(
                            'Stop Music on App close',
                          ),
                          subtitle:
                              Text('Music will stop playing once its closed'),
                          keyName: 'stopForegroundService',
                          defaultValue: true,
                        ),
                        const BoxSwitchTile(
                          title: Text(
                            'Auto Check for updates',
                          ),
                          keyName: 'checkUpdate',
                          defaultValue: false,
                        ),
                        ListTile(
                          title: const Text(
                            'Clear cached data',
                          ),
                          subtitle: const Text(
                            'Deletes Cached details including Homepage, YouTube and Last Session Data',
                          ),
                          trailing: SizedBox(
                            height: 70.0,
                            width: 70.0,
                            child: Center(
                              child: FutureBuilder(
                                future: File(Hive.box('cache').path!).length(),
                                builder: (
                                  BuildContext context,
                                  AsyncSnapshot<int> snapshot,
                                ) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return Text(
                                      '${((snapshot.data ?? 0) / (1024 * 1024)).toStringAsFixed(2)} MB',
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          dense: true,
                          isThreeLine: true,
                          onTap: () async {
                            Hive.box('cache').clear();
                            setState(
                              () {},
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    10.0,
                    10.0,
                    10.0,
                    10.0,
                  ),
                  child: GradientCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(
                            15,
                            15,
                            15,
                            0,
                          ),
                          child: Text(
                            'BackUp & Restore',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ListTile(
                          title: const Text(
                            'Create backup',
                          ),
                          subtitle: const Text(
                            'Create backup of your data',
                          ),
                          dense: true,
                          onTap: () {
                            showModalBottomSheet(
                              isDismissible: true,
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (BuildContext context) {
                                final List playlistNames =
                                    Hive.box('settings').get(
                                  'playlistNames',
                                  defaultValue: ['Favorite Songs'],
                                ) as List;
                                if (!playlistNames.contains('Favorite Songs')) {
                                  playlistNames.insert(0, 'Favorite Songs');
                                  settingsBox.put(
                                    'playlistNames',
                                    playlistNames,
                                  );
                                }

                                final List<String> persist = [
                                  'Settings',
                                  'Playlists',
                                ];

                                final List<String> checked = [
                                  'Settings',
                                  'Downloads',
                                  'Playlists',
                                ];

                                final List<String> items = [
                                  'Settings',
                                  'Playlists',
                                  'Downloads',
                                  'Cache',
                                ];

                                final Map<String, List> boxNames = {
                                  'Settings': ['settings'],
                                  'Cache': ['cache'],
                                  'Downloads': ['downloads'],
                                  'Playlists': playlistNames,
                                };
                                return StatefulBuilder(
                                  builder: (
                                    BuildContext context,
                                    StateSetter setStt,
                                  ) {
                                    return BottomGradientContainer(
                                      borderRadius: BorderRadius.circular(
                                        20.0,
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: ListView.builder(
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              shrinkWrap: true,
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                0,
                                                10,
                                                0,
                                                10,
                                              ),
                                              itemCount: items.length,
                                              itemBuilder: (context, idx) {
                                                return CheckboxListTile(
                                                  activeColor: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  checkColor: Theme.of(context)
                                                              .colorScheme
                                                              .secondary ==
                                                          Colors.white
                                                      ? Colors.black
                                                      : null,
                                                  value: checked.contains(
                                                    items[idx],
                                                  ),
                                                  title: Text(
                                                    items[idx],
                                                  ),
                                                  onChanged: persist
                                                          .contains(items[idx])
                                                      ? null
                                                      : (bool? value) {
                                                          value!
                                                              ? checked.add(
                                                                  items[idx],
                                                                )
                                                              : checked.remove(
                                                                  items[idx],
                                                                );
                                                          setStt(
                                                            () {},
                                                          );
                                                        },
                                                );
                                              },
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  'Cancel',
                                                ),
                                              ),
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                ),
                                                onPressed: () {
                                                  createBackup(
                                                    context,
                                                    checked,
                                                    boxNames,
                                                  );
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  'Okay',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                        ListTile(
                          title: const Text(
                            'Restore',
                          ),
                          subtitle: const Text(
                            'Restore backed up data, Restart may be required',
                          ),
                          dense: true,
                          onTap: () async {
                            await restore(context);
                            currentTheme.refresh();
                          },
                        ),
                        const BoxSwitchTile(
                          title: Text(
                            'AutoBackup',
                          ),
                          keyName: 'autoBackup',
                          defaultValue: false,
                        ),
                        ListTile(
                          title: const Text(
                            'Autobackup location',
                          ),
                          subtitle: Text(autoBackPath),
                          trailing: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.grey[700],
                            ),
                            onPressed: () async {
                              autoBackPath =
                                  await ExtStorageProvider.getExtStorage(
                                        dirName: 'Gem/Backups',
                                        writeAccess: true,
                                      ) ??
                                      '/storage/emulated/0/Gem/Backups';
                              Hive.box('settings')
                                  .put('autoBackPath', autoBackPath);
                              setState(
                                () {},
                              );
                            },
                            child: const Text(
                              'Reset',
                            ),
                          ),
                          onTap: () async {
                            final String temp = await Picker.selectFolder(
                              context: context,
                              message: 'Select backup directory',
                            );
                            if (temp.trim() != '') {
                              autoBackPath = temp;
                              Hive.box('settings').put('autoBackPath', temp);
                              setState(
                                () {},
                              );
                            } else {
                              ShowSnackBar().showSnackBar(
                                context,
                                'No folder selected',
                              );
                            }
                          },
                          dense: true,
                        ),
                      ],
                    ),
                  ),
                ),
                aboutSection(context),
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(
                //     5,
                //     30,
                //     5,
                //     20,
                //   ),
                //   child: Center(
                //     child: Text(
                //       'Copyright (c) Tricky Drevs',
                //       style: const TextStyle(fontSize: 12),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Padding aboutSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        10.0,
        10.0,
        10.0,
        10.0,
      ),
      child: GradientCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                15,
                15,
                15,
                0,
              ),
              child: Text(
                'About',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  // color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            ListTile(
              title: const Text(
                'Version',
              ),
              subtitle: const Text(
                'Tap to check for updates',
              ),
              onTap: () {
                ShowSnackBar().showSnackBar(
                  context,
                  'Checking for updates...',
                  noAction: true,
                );

                // SupaBase().getUpdate().then(
                //   (Map value) async {
                //     if (compareVersion(
                //       value['LatestVersion'].toString(),
                //       appVersion!,
                //     )) {
                //       List? abis = await Hive.box('settings')
                //           .get('supportedAbis') as List?;

                //       if (abis == null) {
                //         final DeviceInfoPlugin deviceInfo =
                //             DeviceInfoPlugin();
                //         final AndroidDeviceInfo androidDeviceInfo =
                //             await deviceInfo.androidInfo;
                //         abis = androidDeviceInfo.supportedAbis;
                //         await Hive.box('settings')
                //             .put('supportedAbis', abis);
                //       }
                //       ShowSnackBar().showSnackBar(
                //         context,
                //         'Update Available',
                //         duration: const Duration(seconds: 15),
                //         action: SnackBarAction(
                //           textColor: Theme.of(context)
                //               .colorScheme
                //               .secondary,
                //           label:
                //               AppLocalizations.of(context)!.update,
                //           onPressed: () {
                //             Navigator.pop(context);
                //             if (abis!.contains('arm64-v8a')) {
                //               launchUrl(
                //                 Uri.parse(
                //                   value['arm64-v8a'] as String,
                //                 ),
                //                 mode:
                //                     LaunchMode.externalApplication,
                //               );
                //             } else {
                //               if (abis.contains('armeabi-v7a')) {
                //                 launchUrl(
                //                   Uri.parse(
                //                     value['armeabi-v7a'] as String,
                //                   ),
                //                   mode: LaunchMode
                //                       .externalApplication,
                //                 );
                //               } else {
                //                 launchUrl(
                //                   Uri.parse(
                //                     value['universal'] as String,
                //                   ),
                //                   mode: LaunchMode
                //                       .externalApplication,
                //                 );
                //               }
                //             }
                //           },
                //         ),
                //       );
                //     } else {
                //       ShowSnackBar().showSnackBar(
                //         context,
                //         AppLocalizations.of(
                //           context,
                //         )!
                //             .latest,
                //       );
                //     }
                //   },
                // );
              },
              trailing: Text(
                'v$appVersion',
                style: const TextStyle(fontSize: 12),
              ),
              dense: true,
            ),
            ListTile(
              title: const Text(
                'Share App',
              ),
              subtitle: const Text(
                'Share Gem with your pals',
              ),
              onTap: () {
                // Share.share(
                //   'Check out this app at https://github.com/',
                // );
              },
              dense: true,
            ),
            ListTile(
              title: const Text(
                'Contact Us',
              ),
              subtitle: const Text(
                'Report an issue',
              ),
              dense: true,
              onTap: () {},
            ),
            ListTile(
              title: const Text(
                'More info',
              ),
              dense: true,
              onTap: () {
                // Navigator.pushNamed(context, '/about');
              },
            ),
          ],
        ),
      ),
    );
  }

  Padding musicPrefs(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        10.0,
        10.0,
        10.0,
        10.0,
      ),
      child: GradientCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                15,
                15,
                15,
                0,
              ),
              child: Text(
                'Music & Playback',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  // color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),

            ListTile(
              title: const Text(
                'Streaming quality',
              ),
              onTap: () {},
              trailing: DropdownButton(
                value: streamingQuality,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyText1!.color,
                ),
                underline: const SizedBox(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(
                      () {
                        streamingQuality = newValue;
                        Hive.box('settings').put('streamingQuality', newValue);
                      },
                    );
                  }
                },
                items: <String>['96 kbps', '160 kbps', '320 kbps']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              dense: true,
            ),
            ListTile(
              title: const Text(
                'Youtube streaming Quality',
              ),
              subtitle: const Text(
                'Higher quality consumes more data',
              ),
              onTap: () {},
              trailing: DropdownButton(
                value: ytQuality,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyText1!.color,
                ),
                underline: const SizedBox(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(
                      () {
                        ytQuality = newValue;
                        Hive.box('settings').put('ytQuality', newValue);
                      },
                    );
                  }
                },
                items: <String>['Low', 'High']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              dense: true,
            ),
            const BoxSwitchTile(
              title: Text(
                'Load last session on App start',
              ),
              subtitle: Text(
                'Automatically load previously playe songs when app starts',
              ),
              keyName: 'loadStart',
              defaultValue: true,
            ),
            const BoxSwitchTile(
              title: Text(
                'AutoPlay',
              ),
              subtitle: Text(
                'Autoplay music as soon as App is opened',
              ),
              keyName: 'autoplay',
              defaultValue: true,
              isThreeLine: true,
            ),
            // BoxSwitchTile(
            //   title: Text(
            //     AppLocalizations.of(
            //       context,
            //     )!
            //         .cacheSong,
            //   ),
            //   subtitle: Text(
            //     AppLocalizations.of(
            //       context,
            //     )!
            //         .cacheSongSub,
            //   ),
            //   keyName: 'cacheSong',
            //   defaultValue: false,
            // ),
          ],
        ),
      ),
    );
  }

  Padding appUiSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        10.0,
        10.0,
        10.0,
        10.0,
      ),
      child: GradientCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                15,
                15,
                15,
                0,
              ),
              child: Text(
                'User Interface',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            /* ListTile(
              title: const Text(
                'Player screen background',
              ),
              dense: true,
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (_, __, ___) =>
                        const PlayerGradientSelection(),
                  ),
                );
              },
            ), */

            const BoxSwitchTile(
              title: Text(
                'Use blur for now playing',
              ),
              keyName: 'useBlurForNowPlaying',
              defaultValue: true,
            ),
            // const BoxSwitchTile(
            //   title: Text(
            //     'Use minimal Mini player',
            //   ),
            //   subtitle: Text('Mini player will have shorter height'),
            //   keyName: 'useDenseMini',
            //   defaultValue: false,
            //   isThreeLine: false,
            // ),
            ListTile(
              title: const Text(
                'Mini Player Buttons',
              ),
              subtitle: const Text(
                'Change buttons you want to appear on the miniplayer',
              ),
              dense: true,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    final List checked = List.from(preferredMiniButtons);
                    final List<String> order = List.from(miniButtonsOrder);
                    return StatefulBuilder(
                      builder: (
                        BuildContext context,
                        StateSetter setStt,
                      ) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              15.0,
                            ),
                          ),
                          content: SizedBox(
                            width: 500,
                            child: ReorderableListView(
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                              onReorder: (int oldIndex, int newIndex) {
                                if (oldIndex < newIndex) {
                                  newIndex--;
                                }
                                final temp = order.removeAt(
                                  oldIndex,
                                );
                                order.insert(newIndex, temp);
                                setStt(
                                  () {},
                                );
                              },
                              header: const Center(
                                child: Text('Change Order'),
                              ),
                              children: order.map((e) {
                                return CheckboxListTile(
                                  key: Key(e),
                                  dense: true,
                                  activeColor:
                                      Theme.of(context).colorScheme.secondary,
                                  checkColor:
                                      Theme.of(context).colorScheme.secondary ==
                                              Colors.white
                                          ? Colors.black
                                          : null,
                                  value: checked.contains(e),
                                  title: Text(e),
                                  onChanged: (bool? value) {
                                    setStt(
                                      () {
                                        value!
                                            ? checked.add(e)
                                            : checked.remove(e);
                                      },
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.grey[700],
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.secondary ==
                                            Colors.white
                                        ? Colors.black
                                        : null,
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                              ),
                              onPressed: () {
                                setState(
                                  () {
                                    final List temp = [];
                                    for (int i = 0; i < order.length; i++) {
                                      if (checked.contains(order[i])) {
                                        temp.add(order[i]);
                                      }
                                    }
                                    preferredMiniButtons = temp;
                                    miniButtonsOrder = order;
                                    Navigator.pop(context);
                                    Hive.box('settings').put(
                                      'preferredMiniButtons',
                                      preferredMiniButtons,
                                    );
                                    Hive.box('settings').put(
                                      'miniButtonsOrder',
                                      order,
                                    );
                                  },
                                );
                              },
                              child: const Text('Ok'),
                            ),
                            const SizedBox(width: 5),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),

            BoxSwitchTile(
              title: const Text(
                'Show playlsts',
              ),
              keyName: 'showPlaylist',
              defaultValue: true,
              onChanged: (val, box) {
                widget.callback!();
              },
            ),

            BoxSwitchTile(
              title: const Text(
                'Show recent',
              ),
              subtitle: const Text('Show recently played songs'),
              keyName: 'showRecent',
              defaultValue: true,
              onChanged: (val, box) {
                widget.callback!();
              },
            ),
            const BoxSwitchTile(
              title: Text('Enable gestures '),
              keyName: 'enableGesture',
              defaultValue: true,
              isThreeLine: false,
            ),
          ],
        ),
      ),
    );
  }

  Visibility customThemeConfig(BuildContext context) {
    return Visibility(
      visible: theme == 'Custom',
      child: ListTile(
        title: const Text(
          'Save Theme',
        ),
        trailing: const Icon(EvaIcons.save, size: 20),
        onTap: () {
          final initialThemeName = 'Theme ${userThemes.length + 1}';
          showTextInputDialog(
            context: context,
            title: 'Enter Theme Name',
            onSubmitted: (value) {
              if (value == '') return;
              currentTheme.saveTheme(value);
              currentTheme.setInitialTheme(value);
              setState(
                () {
                  userThemes = currentTheme.getThemes();
                  theme = value;
                },
              );
              ShowSnackBar().showSnackBar(
                context,
                'Theme Saved',
              );
              Navigator.of(context).pop();
            },
            keyboardType: TextInputType.text,
            initialText: initialThemeName,
          );
        },
        dense: true,
      ),
    );
  }

  ListTile currentThemeConfig(
    BuildContext context,
    List<String> userThemesList,
  ) {
    return ListTile(
      title: const Text(
        'Current Theme',
      ),
      trailing: DropdownButton(
        value: theme,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).textTheme.bodyText1!.color,
        ),
        underline: const SizedBox(),
        onChanged: (String? themeChoice) {
          if (themeChoice != null) {
            const deflt = 'Default';

            currentTheme.setInitialTheme(themeChoice);

            setState(
              () {
                theme = themeChoice;
                if (themeChoice == 'Custom') return;
                final selectedTheme = userThemes[themeChoice];

                settingsBox.put(
                  'backGrad',
                  themeChoice == deflt ? 2 : selectedTheme['backGrad'],
                );
                currentTheme.backGrad =
                    themeChoice == deflt ? 2 : selectedTheme['backGrad'] as int;

                settingsBox.put(
                  'cardGrad',
                  themeChoice == deflt ? 4 : selectedTheme['cardGrad'],
                );
                currentTheme.cardGrad =
                    themeChoice == deflt ? 4 : selectedTheme['cardGrad'] as int;

                settingsBox.put(
                  'bottomGrad',
                  themeChoice == deflt ? 3 : selectedTheme['bottomGrad'],
                );
                currentTheme.bottomGrad = themeChoice == deflt
                    ? 3
                    : selectedTheme['bottomGrad'] as int;

                currentTheme.switchCanvasColor(
                  themeChoice == deflt
                      ? 'Grey'
                      : selectedTheme['canvasColor'] as String,
                  notify: false,
                );
                canvasColor = themeChoice == deflt
                    ? 'Grey'
                    : selectedTheme['canvasColor'] as String;

                currentTheme.switchCardColor(
                  themeChoice == deflt
                      ? 'Grey900'
                      : selectedTheme['cardColor'] as String,
                  notify: false,
                );
                cardColor = themeChoice == deflt
                    ? 'Grey900'
                    : selectedTheme['cardColor'] as String;

                themeColor = themeChoice == deflt
                    ? 'Teal'
                    : selectedTheme['accentColor'] as String;
                colorHue = themeChoice == deflt
                    ? 400
                    : selectedTheme['colorHue'] as int;

                currentTheme.switchColor(
                  themeColor,
                  colorHue,
                  notify: false,
                );

                currentTheme.switchTheme(
                  useSystemTheme: !(themeChoice == deflt) &&
                      selectedTheme['useSystemTheme'] as bool,
                  isDark:
                      themeChoice == deflt || selectedTheme['isDark'] as bool,
                );
              },
            );
          }
        },
        selectedItemBuilder: (BuildContext context) {
          return userThemesList.map<Widget>((String item) {
            return Text(item);
          }).toList();
        },
        items: userThemesList.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 2,
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (value != 'Default' && value != 'Custom')
                  Flexible(
                    child: IconButton(
                      //padding: EdgeInsets.zero,
                      iconSize: 18,
                      splashRadius: 18,
                      onPressed: () {
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                10.0,
                              ),
                            ),
                            title: Text(
                              'Delete Theme',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            content: Text(
                              'Are you sure you want to delete $value?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: Navigator.of(context).pop,
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.secondary ==
                                              Colors.white
                                          ? Colors.black
                                          : null,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                onPressed: () {
                                  currentTheme.deleteTheme(value);
                                  if (currentTheme.getInitialTheme() == value) {
                                    currentTheme.setInitialTheme(
                                      'Custom',
                                    );
                                    theme = 'Custom';
                                  }
                                  setState(
                                    () {
                                      userThemes = currentTheme.getThemes();
                                    },
                                  );
                                  ShowSnackBar().showSnackBar(
                                    context,
                                    'Theme deleted',
                                  );
                                  return Navigator.of(
                                    context,
                                  ).pop();
                                },
                                child: const Text('Delete'),
                              ),
                              const SizedBox(width: 5.0),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.delete_rounded,
                      ),
                    ),
                  )
              ],
            ),
          );
        }).toList(),
        isDense: true,
      ),
      dense: true,
    );
  }

  ListTile amoledSettings() {
    return ListTile(
      title: const Text('Use Amoled'),
      subtitle: const Text("Amoled theme for best battery perfomance"),
      dense: true,
      onTap: () {
        currentTheme.switchTheme(
          useSystemTheme: false,
          isDark: true,
        );
        Hive.box('settings').put('darkMode', true);

        settingsBox.put('backGrad', 4);
        currentTheme.backGrad = 4;
        settingsBox.put('cardGrad', 6);
        currentTheme.cardGrad = 6;
        settingsBox.put('bottomGrad', 4);
        currentTheme.bottomGrad = 4;

        currentTheme.switchCanvasColor('Black');
        canvasColor = 'Black';

        currentTheme.switchCardColor('Grey900');
        cardColor = 'Grey900';

        themeColor = 'White';
        colorHue = 400;
        currentTheme.switchColor('White', colorHue);
      },
    );
  }

  Visibility backgroundGradient(BuildContext context) {
    return Visibility(
      visible: Theme.of(context).brightness == Brightness.dark,
      child: Column(
        children: [
          ListTile(
            title: const Text(
              'Background Gradient',
            ),
            trailing: Padding(
              padding: const EdgeInsets.all(
                10.0,
              ),
              child: Container(
                height: 25,
                width: 25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    100.0,
                  ),
                  color: Theme.of(context).colorScheme.secondary,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? currentTheme.getBackGradient()
                        : [
                            Colors.white,
                            Theme.of(context).canvasColor,
                          ],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.white24,
                      blurRadius: 5.0,
                      offset: Offset(
                        0.0,
                        3.0,
                      ),
                    )
                  ],
                ),
              ),
            ),
            onTap: () {
              final List<List<Color>> gradients = currentTheme.backOpt;
              PopupDialog().showPopup(
                context: context,
                child: SizedBox(
                  width: 500,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      30,
                      0,
                      10,
                    ),
                    itemCount: gradients.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 20.0,
                          right: 20.0,
                          bottom: 15.0,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            settingsBox.put(
                              'backGrad',
                              index,
                            );
                            currentTheme.backGrad = index;
                            widget.callback!();
                            switchToCustomTheme();
                            Navigator.pop(context);
                            setState(
                              () {},
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.125,
                            height: MediaQuery.of(context).size.width * 0.125,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                15.0,
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: gradients[index],
                              ),
                            ),
                            child: (currentTheme.getBackGradient() ==
                                    gradients[index])
                                ? const Icon(
                                    Icons.done_rounded,
                                    size: 20,
                                  )
                                : const SizedBox(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            dense: true,
          ),
          ListTile(
            title: const Text(
              'Card gradient',
            ),
            trailing: Padding(
              padding: const EdgeInsets.all(
                10.0,
              ),
              child: Container(
                height: 25,
                width: 25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    100.0,
                  ),
                  color: Theme.of(context).colorScheme.secondary,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? currentTheme.getCardGradient()
                        : [
                            Colors.white,
                            Theme.of(context).canvasColor,
                          ],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.white24,
                      blurRadius: 5.0,
                      offset: Offset(0.0, 3.0),
                    )
                  ],
                ),
              ),
            ),
            onTap: () {
              final List<List<Color>> gradients = currentTheme.cardOpt;
              PopupDialog().showPopup(
                context: context,
                child: SizedBox(
                  width: 500,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      30,
                      0,
                      10,
                    ),
                    itemCount: gradients.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 20.0,
                          right: 20.0,
                          bottom: 15.0,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            settingsBox.put(
                              'cardGrad',
                              index,
                            );
                            currentTheme.cardGrad = index;
                            widget.callback!();
                            switchToCustomTheme();
                            Navigator.pop(context);
                            setState(
                              () {},
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.125,
                            height: MediaQuery.of(context).size.width * 0.125,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                15.0,
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: gradients[index],
                              ),
                            ),
                            child: (currentTheme.getCardGradient() ==
                                    gradients[index])
                                ? const Icon(
                                    Icons.done_rounded,
                                  )
                                : const SizedBox(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            dense: true,
          ),
          ListTile(
            title: const Text(
              'Bottom card Gradient',
            ),
            trailing: Padding(
              padding: const EdgeInsets.all(
                10.0,
              ),
              child: Container(
                height: 25,
                width: 25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    100.0,
                  ),
                  color: Theme.of(context).colorScheme.secondary,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? currentTheme.getBottomGradient()
                        : [
                            Colors.white,
                            Theme.of(context).canvasColor,
                          ],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.white24,
                      blurRadius: 5.0,
                      offset: Offset(
                        0.0,
                        3.0,
                      ),
                    )
                  ],
                ),
              ),
            ),
            onTap: () {
              final List<List<Color>> gradients = currentTheme.backOpt;
              PopupDialog().showPopup(
                context: context,
                child: SizedBox(
                  width: 500,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      30,
                      0,
                      10,
                    ),
                    itemCount: gradients.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 20.0,
                          right: 20.0,
                          bottom: 15.0,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            settingsBox.put(
                              'bottomGrad',
                              index,
                            );
                            currentTheme.bottomGrad = index;
                            switchToCustomTheme();
                            Navigator.pop(context);
                            setState(
                              () {},
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.125,
                            height: MediaQuery.of(context).size.width * 0.125,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                15.0,
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: gradients[index],
                              ),
                            ),
                            child: (currentTheme.getBottomGradient() ==
                                    gradients[index])
                                ? const Icon(
                                    Icons.done_rounded,
                                    size: 20,
                                  )
                                : const SizedBox(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            dense: true,
          ),
          ListTile(
            title: const Text(
              'Canvas color',
            ),
            onTap: () {},
            trailing: DropdownButton(
              value: canvasColor,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyText1!.color,
              ),
              underline: const SizedBox(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  switchToCustomTheme();
                  setState(
                    () {
                      currentTheme.switchCanvasColor(newValue);
                      canvasColor = newValue;
                    },
                  );
                }
              },
              items: <String>['Grey', 'Black']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            dense: true,
          ),
          ListTile(
            title: const Text('Card color'),
            onTap: () {},
            trailing: DropdownButton(
              value: cardColor,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyText1!.color,
              ),
              underline: const SizedBox(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  switchToCustomTheme();
                  setState(
                    () {
                      currentTheme.switchCardColor(newValue);
                      cardColor = newValue;
                    },
                  );
                }
              },
              items: <String>['Grey800', 'Grey850', 'Grey900', 'Black']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            dense: true,
          ),
        ],
      ),
    );
  }

  void switchToCustomTheme() {
    const custom = 'Custom';
    if (theme != custom) {
      currentTheme.setInitialTheme(custom);
      setState(
        () {
          theme = custom;
        },
      );
    }
  }
}

class BoxSwitchTile extends StatelessWidget {
  const BoxSwitchTile({
    Key? key,
    required this.title,
    this.subtitle,
    required this.keyName,
    required this.defaultValue,
    this.isThreeLine,
    this.onChanged,
  }) : super(key: key);

  final Text title;
  final Text? subtitle;
  final String keyName;
  final bool defaultValue;
  final bool? isThreeLine;
  final Function(bool, Box box)? onChanged;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (BuildContext context, Box box, Widget? widget) {
        return SwitchListTile(
          activeColor: Theme.of(context).colorScheme.secondary,
          title: title,
          subtitle: subtitle,
          isThreeLine: isThreeLine ?? false,
          dense: true,
          value: box.get(keyName, defaultValue: defaultValue) as bool? ??
              defaultValue,
          onChanged: (val) {
            box.put(keyName, val);
            onChanged?.call(val, box);
          },
        );
      },
    );
  }
}
