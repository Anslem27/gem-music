// ignore_for_file: require_trailing_commas, use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:gem/widgets/collage.dart';
import 'package:gem/widgets/snackbar.dart';
import 'package:gem/widgets/textinput_dialog.dart';
import 'package:gem/Helpers/import_export_playlist.dart';
import 'package:gem/Screens/Library/favorites_section.dart';
import 'package:gem/Screens/Library/import.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class OnlinePlaylistScreen extends StatefulWidget {
  const OnlinePlaylistScreen({Key? key}) : super(key: key);

  @override
  _OnlinePlaylistScreenState createState() => _OnlinePlaylistScreenState();
}

class _OnlinePlaylistScreenState extends State<OnlinePlaylistScreen> {
  final Box settingsBox = Hive.box('settings');
  final List playlistNames =
      Hive.box('settings').get('playlistNames')?.toList() as List? ??
          ['Favorite Songs'];
  Map playlistDetails =
      Hive.box('settings').get('playlistDetails', defaultValue: {}) as Map;
  @override
  Widget build(BuildContext context) {
    if (!playlistNames.contains('Favorite Songs')) {
      playlistNames.insert(0, 'Favorite Songs');
      settingsBox.put('playlistNames', playlistNames);
    }

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 5),
                ListTile(
                  title: const Text("Create Playlist",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                  leading: const SizedBox.square(
                    dimension: 50,
                    child: Center(
                      child: Icon(
                        Icons.add_rounded,
                      ),
                    ),
                  ),
                  onTap: () async {
                    await showTextInputDialog(
                      context: context,
                      title: 'Create New Playlist',
                      initialText: '',
                      keyboardType: TextInputType.name,
                      onSubmitted: (String value) async {
                        final RegExp avoid = RegExp(r'[\.\\\*\:\"\?#/;\|]');
                        value.replaceAll(avoid, '').replaceAll('  ', ' ');
                        if (value.trim() == '') {
                          value = 'Playlist ${playlistNames.length}';
                        }
                        while (playlistNames.contains(value) ||
                            await Hive.boxExists(value)) {
                          // ignore: use_string_buffers
                          value = '$value (1)';
                        }
                        playlistNames.add(value);
                        settingsBox.put('playlistNames', playlistNames);
                        Navigator.pop(context);
                        setState(() {});
                      },
                    );
                  },
                ),
                ListTile(
                  title: const Text(
                    "Import Playlist",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                  leading: const SizedBox.square(
                    dimension: 50,
                    child: Center(
                      child: Icon(
                        MdiIcons.import,
                      ),
                    ),
                  ),
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImportPlaylist(),
                      ),
                    );
                  },
                ),
                if (playlistNames.length > 1)
                  ListTile(
                    title: const Text('Merge Playlists',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w400)),
                    leading: const SizedBox.square(
                      dimension: 50,
                      child: Center(
                        child: Icon(
                          Icons.merge_type_rounded,
                        ),
                      ),
                    ),
                    onTap: () async {
                      final List<int> checked = [];
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder: (
                              BuildContext context,
                              StateSetter setStt,
                            ) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    10.0,
                                  ),
                                ),
                                content: SizedBox(
                                  width: 500,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 30, 0, 10),
                                    itemCount: playlistNames.length,
                                    itemBuilder: (context, index) {
                                      final String name =
                                          playlistNames[index].toString();
                                      final String showName =
                                          playlistDetails.containsKey(name)
                                              ? playlistDetails[name]['name']
                                                      ?.toString() ??
                                                  name
                                              : name;
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
                                        value: checked.contains(index),
                                        onChanged: (value) {
                                          if (value ?? false) {
                                            checked.add(index);
                                          } else {
                                            checked.remove(index);
                                          }
                                          setStt(() {});
                                        },
                                        title: Text(
                                          showName,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle:
                                            playlistDetails[name] == null ||
                                                    playlistDetails[name]
                                                            ['count'] ==
                                                        null ||
                                                    playlistDetails[name]
                                                            ['count'] ==
                                                        0
                                                ? null
                                                : Text(
                                                    '${playlistDetails[name]['count']} songs',
                                                  ),
                                        secondary: (playlistDetails[name] ==
                                                    null ||
                                                playlistDetails[name]
                                                        ['imagesList'] ==
                                                    null ||
                                                (playlistDetails[name]
                                                        ['imagesList'] as List)
                                                    .isEmpty)
                                            ? Card(
                                                elevation: 5,
                                                color: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    7.0,
                                                  ),
                                                ),
                                                clipBehavior: Clip.antiAlias,
                                                child: SizedBox(
                                                  height: 50,
                                                  width: 50,
                                                  child:
                                                      name == 'Favorite Songs'
                                                          ? const Image(
                                                              image: AssetImage(
                                                                'assets/cover.jpg',
                                                              ),
                                                            )
                                                          : const Image(
                                                              image: AssetImage(
                                                                'assets/album.png',
                                                              ),
                                                            ),
                                                ),
                                              )
                                            : Collage(
                                                imageList: playlistDetails[name]
                                                    ['imagesList'] as List,
                                                showGrid: true,
                                                placeholderImage:
                                                    'assets/cover.jpg',
                                              ),
                                      );
                                    },
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          Theme.of(context).brightness ==
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
                                      foregroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .secondary ==
                                              Colors.white
                                          ? Colors.black
                                          : null,
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    onPressed: () async {
                                      try {
                                        final List<String> playlistsToMerge =
                                            checked
                                                .map(
                                                  (int e) => playlistNames[e]
                                                      .toString(),
                                                )
                                                .toList();
                                        if (playlistsToMerge
                                            .contains('Favorite Songs')) {
                                          playlistsToMerge
                                              .remove('Favorite Songs');
                                          playlistsToMerge.insert(
                                            0,
                                            'Favorite Songs',
                                          );
                                        }
                                        if (playlistsToMerge.length > 1) {
                                          final finalMap = {};
                                          for (final String playlistName
                                              in playlistsToMerge.sublist(1)) {
                                            try {
                                              final Box playlistBox =
                                                  await Hive.openBox(
                                                playlistName,
                                              );
                                              final Map songsMap =
                                                  playlistBox.toMap();
                                              finalMap.addAll(songsMap);
                                              await playlistDetails
                                                  .remove(playlistName);
                                              playlistNames
                                                  .remove(playlistName);
                                              await playlistBox
                                                  .deleteFromDisk();
                                            } catch (e) {
                                              ShowSnackBar().showSnackBar(
                                                context,
                                                'Error merging $playlistName: $e',
                                              );
                                            }
                                          }
                                          final Box finalPlaylistBox =
                                              await Hive.openBox(
                                            playlistsToMerge.first,
                                          );
                                          finalPlaylistBox.putAll(finalMap);

                                          await settingsBox.put(
                                            'playlistDetails',
                                            playlistDetails,
                                          );

                                          await settingsBox.put(
                                            'playlistNames',
                                            playlistNames,
                                          );
                                        }
                                      } catch (e) {
                                        ShowSnackBar().showSnackBar(
                                          context,
                                          'Error: $e',
                                        );
                                      }
                                      Navigator.pop(context);
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
                ValueListenableBuilder(
                  valueListenable: settingsBox.listenable(),
                  builder: (
                    BuildContext context,
                    Box box,
                    Widget? child,
                  ) {
                    final List playlistNamesValue = box.get(
                          'playlistNames',
                          defaultValue: ['Favorite Songs'],
                        )?.toList() as List? ??
                        ['Favorite Songs'];
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: playlistNamesValue.length,
                      itemBuilder: (context, index) {
                        final String name =
                            playlistNamesValue[index].toString();
                        final String showName = playlistDetails
                                .containsKey(name)
                            ? playlistDetails[name]['name']?.toString() ?? name
                            : name;
                        return ListTile(
                          leading: (playlistDetails[name] == null ||
                                  playlistDetails[name]['imagesList'] == null ||
                                  (playlistDetails[name]['imagesList'] as List)
                                      .isEmpty)
                              ? Card(
                                  elevation: 5,
                                  color: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7.0),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: name == 'Favorite Songs'
                                        ? const Image(
                                            image: AssetImage(
                                              'assets/cover.jpg',
                                            ),
                                          )
                                        : const Image(
                                            image: AssetImage(
                                              'assets/album.png',
                                            ),
                                          ),
                                  ),
                                )
                              : Collage(
                                  imageList: playlistDetails[name]['imagesList']
                                      as List,
                                  showGrid: true,
                                  placeholderImage: 'assets/cover.jpg',
                                ),
                          title: Text(
                            showName,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: playlistDetails[name] == null ||
                                  playlistDetails[name]['count'] == null ||
                                  playlistDetails[name]['count'] == 0
                              ? null
                              : Text(
                                  '${playlistDetails[name]['count']} songs',
                                ),
                          trailing: PopupMenuButton(
                            splashRadius: 24,
                            icon: Icon(
                              Icons.more_vert_rounded,
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15.0),
                              ),
                            ),
                            onSelected: (int? value) async {
                              if (value == 1) {
                                exportPlaylist(
                                  context,
                                  name,
                                  playlistDetails.containsKey(name)
                                      ? playlistDetails[name]['name']
                                              ?.toString() ??
                                          name
                                      : name,
                                );
                              }
                              if (value == 2) {
                                sharePlaylist(
                                  context,
                                  name,
                                  playlistDetails.containsKey(name)
                                      ? playlistDetails[name]['name']
                                              ?.toString() ??
                                          name
                                      : name,
                                );
                              }
                              if (value == 0) {
                                ShowSnackBar().showSnackBar(
                                  context,
                                  'Deleted $showName',
                                );
                                playlistDetails.remove(name);
                                await settingsBox.put(
                                  'playlistDetails',
                                  playlistDetails,
                                );
                                await playlistNames.removeAt(index);
                                await settingsBox.put(
                                  'playlistNames',
                                  playlistNames,
                                );
                                await Hive.openBox(name);
                                await Hive.box(name).deleteFromDisk();
                              }
                              if (value == 3) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    final controller = TextEditingController(
                                      text: showName,
                                    );
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Rename Playlist',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          TextField(
                                            autofocus: true,
                                            textAlignVertical:
                                                TextAlignVertical.bottom,
                                            controller: controller,
                                            onSubmitted: (value) async {
                                              Navigator.pop(context);
                                              playlistDetails[name] == null
                                                  ? playlistDetails.addAll({
                                                      name: {
                                                        'name': value.trim()
                                                      }
                                                    })
                                                  : playlistDetails[name]
                                                      .addAll({
                                                      'name': value.trim()
                                                    });

                                              await settingsBox.put(
                                                'playlistDetails',
                                                playlistDetails,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            foregroundColor: Theme.of(context)
                                                .iconTheme
                                                .color,
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
                                            foregroundColor: Colors.white,
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            playlistDetails[name] == null
                                                ? playlistDetails.addAll({
                                                    name: {
                                                      'name':
                                                          controller.text.trim()
                                                    }
                                                  })
                                                : playlistDetails[name].addAll({
                                                    'name':
                                                        controller.text.trim()
                                                  });

                                            await settingsBox.put(
                                              'playlistDetails',
                                              playlistDetails,
                                            );
                                          },
                                          child: Text(
                                            'Ok',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary ==
                                                      Colors.white
                                                  ? Colors.black
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              if (name != 'Favorite Songs')
                                PopupMenuItem(
                                  value: 3,
                                  child: Row(
                                    children: const [
                                      Icon(Icons.edit_rounded),
                                      SizedBox(width: 10.0),
                                      Text(
                                        'Rename',
                                      ),
                                    ],
                                  ),
                                ),
                              if (name != 'Favorite Songs')
                                PopupMenuItem(
                                  value: 0,
                                  child: Row(
                                    children: const [
                                      Icon(Iconsax.trash),
                                      SizedBox(width: 10.0),
                                      Text(
                                        'Delete',
                                      ),
                                    ],
                                  ),
                                ),
                              PopupMenuItem(
                                value: 1,
                                child: Row(
                                  children: const [
                                    Icon(MdiIcons.export),
                                    SizedBox(width: 10.0),
                                    Text('Export'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 2,
                                child: Row(
                                  children: const [
                                    Icon(MdiIcons.share),
                                    SizedBox(width: 10.0),
                                    Text(
                                      'Share',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () async {
                            await Hive.openBox(name);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LikedSongs(
                                  playlistName: name,
                                  showName: playlistDetails.containsKey(name)
                                      ? playlistDetails[name]['name']
                                              ?.toString() ??
                                          name
                                      : name,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
