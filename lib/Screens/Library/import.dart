// ignore_for_file: use_super_parameters, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gem/widgets/gradient_containers.dart';
import 'package:gem/widgets/miniplayer.dart';
import 'package:gem/widgets/snackbar.dart';
import 'package:gem/widgets/textinput_dialog.dart';
import 'package:gem/Helpers/import_export_playlist.dart';
import 'package:gem/Helpers/search_add_playlist.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ImportPlaylist extends StatelessWidget {
  ImportPlaylist({Key? key}) : super(key: key);

  final Box settingsBox = Hive.box('settings');
  final List playlistNames =
      Hive.box('settings').get('playlistNames')?.toList() as List? ??
          ['Favorite Songs'];

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Column(
        children: [
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text(
                  "Import Playlist",
                  style: GoogleFonts.roboto(fontSize: 20),
                ),
                centerTitle: true,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.transparent
                    : Theme.of(context).colorScheme.secondary,
                elevation: 0,
              ),
              body: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: 2,
                itemBuilder: (cntxt, index) {
                  return ListTile(
                    title: Text(
                      index == 0 ? 'Import from file' : 'Import from youtube',
                    ),
                    leading: SizedBox.square(
                      dimension: 50,
                      child: Center(
                        child: Icon(
                          index == 0 ? MdiIcons.import : MdiIcons.youtube,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    ),
                    onTap: () {
                      index == 0
                          ? importFile(
                              cntxt,
                              playlistNames,
                              settingsBox,
                            )
                          : importYt(
                              cntxt,
                              playlistNames,
                              settingsBox,
                            );
                    },
                  );
                },
              ),
            ),
          ),
          const MiniPlayer(),
        ],
      ),
    );
  }
}

Future<void> importFile(
  BuildContext context,
  List playlistNames,
  Box settingsBox,
) async {
  final newPlaylistNames = await importPlaylist(context, playlistNames);
  settingsBox.put('playlistNames', newPlaylistNames);
}

Future<void> importYt(
  BuildContext context,
  List playlistNames,
  Box settingsBox,
) async {
  await showTextInputDialog(
    context: context,
    title: 'Paste Link Url',
    initialText: '',
    keyboardType: TextInputType.url,
    onSubmitted: (value) async {
      final String link = value.trim();
      Navigator.pop(context);
      final Map data = await SearchAddPlaylist.addYtPlaylist(link);
      if (data.isNotEmpty) {
        if (data['title'] == '' && data['count'] == 0) {
          ShowSnackBar().showSnackBar(
            context,
            'Failed to import',
            duration: const Duration(seconds: 3),
          );
        } else {
          playlistNames.add(
            data['title'] == '' ? 'Yt Playlist' : data['title'],
          );
          settingsBox.put(
            'playlistNames',
            playlistNames,
          );

          await SearchAddPlaylist.showProgress(
            data['count'] as int,
            context,
            SearchAddPlaylist.ytSongsAdder(
              data['title'].toString(),
              data['tracks'] as List,
            ),
          );
        }
      } else {
        ShowSnackBar().showSnackBar(
          context,
          'Failed to import',
        );
      }
    },
  );
}
