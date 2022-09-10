import 'package:flutter/material.dart';
import 'package:gem/CustomWidgets/snackbar.dart';
import 'package:gem/CustomWidgets/textinput_dialog.dart';
import 'package:gem/Helpers/local_music_functions.dart';
import 'package:gem/Screens/LocalMusic/local_music.dart';
import 'package:iconsax/iconsax.dart';
import 'package:on_audio_query/on_audio_query.dart';

class LocalPlaylists extends StatefulWidget {
  final List<PlaylistModel> playlistDetails;
  final OfflineAudioQuery offlineAudioQuery;
  const LocalPlaylists({
    Key? key,
    required this.playlistDetails,
    required this.offlineAudioQuery,
  }) : super(key: key);
  @override
  _LocalPlaylistsState createState() => _LocalPlaylistsState();
}

class _LocalPlaylistsState extends State<LocalPlaylists> {
  List<PlaylistModel> playlistDetails = [];
  @override
  Widget build(BuildContext context) {
    if (playlistDetails.isEmpty) {
      playlistDetails = widget.playlistDetails;
    }
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 5),
          ListTile(
            title: const Text("Create Playlist"),
            leading: Card(
              elevation: 0,
              color: Colors.transparent,
              child: SizedBox.square(
                dimension: 50,
                child: Center(
                  child: Icon(
                    Iconsax.add,
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary,
                  ),
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
                  if (value.trim() != '') {
                    Navigator.pop(context);
                    await widget.offlineAudioQuery.createPlaylist(
                      name: value,
                    );
                    widget.offlineAudioQuery.getPlaylists().then((value) {
                      playlistDetails = value;
                      setState(() {});
                    });
                  }
                },
              );
              setState(() {});
            },
          ),
          if (playlistDetails.isEmpty)
            const SizedBox()
          else
            // MasonryGridView.count(
            //     padding: const EdgeInsets.all(5),
            //     crossAxisCount: 2,
            //     itemBuilder: (_, index) {
            //       return Card(
            //         color: Colors.transparent,
            //         elevation: 0,
            //         margin: EdgeInsets.zero,
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(
            //             10.0,
            //           ),
            //         ),
            //         clipBehavior: Clip.antiAlias,
            //         child: Expanded(
            //           child: Column(
            //             children: [
            //               SizedBox(
            //                 child: QueryArtworkWidget(
            //                   id: playlistDetails[index].id,
            //                   type: ArtworkType.PLAYLIST,
            //                   keepOldArtwork: true,
            //                   artworkBorder: BorderRadius.circular(7.0),
            //                   nullArtworkWidget: ClipRRect(
            //                     borderRadius: BorderRadius.circular(7.0),
            //                     child: const Image(
            //                       fit: BoxFit.cover,
            //                       height: 100.0,
            //                       width: 100.0,
            //                       image: AssetImage('assets/cover.jpg'),
            //                     ),
            //                   ),
            //                 ),
            //               ),
            //               Padding(
            //                 padding: const EdgeInsets.symmetric(
            //                   horizontal: 10.0,
            //                 ),
            //                 child: Column(
            //                   mainAxisSize: MainAxisSize.min,
            //                   children: [
            //                     Text(
            //                       playlistDetails[index].playlist,
            //                       textAlign: TextAlign.center,
            //                       softWrap: false,
            //                       overflow: TextOverflow.ellipsis,
            //                       style: const TextStyle(
            //                         fontWeight: FontWeight.w500,
            //                       ),
            //                     ),
            //                     Text(
            //                       '${playlistDetails[index].numOfSongs} ${playlistDetails[index].numOfSongs > 0 ? 'songs' : 'song'}',
            //                       textAlign: TextAlign.center,
            //                       softWrap: false,
            //                       overflow: TextOverflow.ellipsis,
            //                       style: TextStyle(
            //                           fontSize: 11,
            //                           color: Theme.of(context)
            //                               .textTheme
            //                               .caption!
            //                               .color),
            //                     )
            //                   ],
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       );
            //     })
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: playlistDetails.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: QueryArtworkWidget(
                      id: playlistDetails[index].id,
                      type: ArtworkType.PLAYLIST,
                      keepOldArtwork: true,
                      artworkBorder: BorderRadius.circular(7.0),
                      nullArtworkWidget: ClipRRect(
                        borderRadius: BorderRadius.circular(7.0),
                        child: const Image(
                          fit: BoxFit.cover,
                          height: 50.0,
                          width: 50.0,
                          image: AssetImage('assets/cover.jpg'),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    playlistDetails[index].playlist,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${playlistDetails[index].numOfSongs} ${playlistDetails[index].numOfSongs > 0 ? 'songs' : 'song'}',
                  ),
                  trailing: PopupMenuButton(
                    splashRadius: 24,
                    icon: const Icon(Icons.more_vert_rounded),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(15.0),
                      ),
                    ),
                    onSelected: (int? value) async {
                      if (value == 0) {
                        if (await widget.offlineAudioQuery.removePlaylist(
                          playlistId: playlistDetails[index].id,
                        )) {
                          ShowSnackBar().showSnackBar(
                            context,
                            'Deleted ${playlistDetails[index].playlist}',
                          );
                          playlistDetails.removeAt(index);
                          setState(() {});
                        } else {
                          ShowSnackBar().showSnackBar(
                            context,
                            'Failed to delete',
                          );
                        }
                      }
                    },
                    itemBuilder: (context) => [
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
                    ],
                  ),
                  onTap: () async {
                    final songs =
                        await widget.offlineAudioQuery.getPlaylistSongs(
                      playlistDetails[index].id,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DownloadedSongs(
                          title: playlistDetails[index].playlist,
                          cachedSongs: songs,
                          playlistId: playlistDetails[index].id,
                        ),
                      ),
                    );
                  },
                );
              },
            )
        ],
      ),
    );
  }
}
