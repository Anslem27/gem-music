import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem/CustomWidgets/snackbar.dart';
import 'package:gem/CustomWidgets/textinput_dialog.dart';
import 'package:gem/Helpers/local_music_functions.dart';
import 'package:gem/Screens/LocalMusic/local_music.dart';
import 'package:google_fonts/google_fonts.dart';
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
    double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.height / 2.5;

    if (playlistDetails.isEmpty) {
      playlistDetails = widget.playlistDetails;
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: ListTile(
              title: Text(
                "Create Playlist",
                style: GoogleFonts.roboto(fontSize: 18),
              ),
              leading: const Card(
                elevation: 0,
                color: Colors.transparent,
                child: SizedBox.square(
                  dimension: 50,
                  child: Center(
                    child: Icon(Iconsax.add),
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
          ),
          if (playlistDetails.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SvgPicture.asset("assets/svg/playlist.svg",
                      height: 140, width: 100),
                ],
              ),
            )
          else
            StaggeredGridView.countBuilder(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 0,
              itemCount: playlistDetails.length,
              physics: const BouncingScrollPhysics(),
              staggeredTileBuilder: (int index) {
                return const StaggeredTile.count(1, 1.2);
              },
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
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
                  child: Stack(
                    children: [
                      Card(
                        color: Colors.transparent,
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            QueryArtworkWidget(
                                id: playlistDetails[index].id,
                                type: ArtworkType.PLAYLIST,
                                artworkHeight: boxSize - 35,
                                artworkWidth:
                                    MediaQuery.of(context).size.width / 2.5,
                                artworkBorder: BorderRadius.circular(7.0),
                                nullArtworkWidget: ClipRRect(
                                  borderRadius: BorderRadius.circular(7.0),
                                  child: Image(
                                    fit: BoxFit.cover,
                                    height: boxSize - 35,
                                    width:
                                        MediaQuery.of(context).size.width / 2.5,
                                    image: const AssetImage('assets/cover.jpg'),
                                  ),
                                )),
                            Padding(
                              padding: const EdgeInsets.only(left: 6.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                            playlistDetails[index].playlist,
                                            textAlign: TextAlign.center,
                                            softWrap: false,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.roboto(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5.0, right: 5),
                                          child: Text(
                                            playlistDetails[index].numOfSongs >
                                                    0
                                                ? "${playlistDetails[index].numOfSongs} songs"
                                                : "Empty playlist",
                                            textAlign: TextAlign.start,
                                            softWrap: false,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.roboto(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton(
                                    itemBuilder: (_) => [
                                      PopupMenuItem(
                                        value: 0,
                                        child: Row(
                                          children: const [
                                            Icon(Iconsax.trash),
                                            SizedBox(width: 10.0),
                                            Text('Delete'),
                                          ],
                                        ),
                                      ),
                                      // PopupMenuItem(
                                      //   value: 1,
                                      //   child: Row(
                                      //     children: const [
                                      //       Icon(Icons.edit),
                                      //       SizedBox(width: 10.0),
                                      //       Text('Rename'),
                                      //     ],
                                      //   ),
                                      // )
                                    ],
                                    onSelected: (int? value) async {
                                      if (value == 0) {
                                        if (await widget.offlineAudioQuery
                                            .removePlaylist(
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
                                      // if (value == 1) {
                                      //   await showTextInputDialog(
                                      //     context: context,
                                      //     title: 'Add new playlist name',
                                      //     initialText: '',
                                      //     keyboardType: TextInputType.text,
                                      //     onSubmitted: (name) async {
                                      //       Navigator.pop(context);
                                      //       await widget.offlineAudioQuery
                                      //           .renamePlaylist(
                                      //         playlistId:
                                      //             playlistDetails[index].id,
                                      //         newName: name,
                                      //       );

                                      //       setState(() {});
                                      //     },
                                      //   );

                                      //   setState(() {});
                                      // }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
        ],
      ),
    );
  }
}
