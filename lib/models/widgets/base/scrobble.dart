import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

import '../../services/generic.dart';
import '../../services/lastfm/lastfm.dart';
import '../../util/constants.dart';
import '../../util/preferences.dart';
import 'app_bar.dart';
import 'header_list_tile.dart';

class ScrobbleView extends StatefulWidget {
  final Track? track;
  final bool isModal;

  const ScrobbleView({super.key, this.track, this.isModal = false});

  @override
  State<StatefulWidget> createState() => _ScrobbleViewState();
}

class _ScrobbleViewState extends State<ScrobbleView> {
  final _formKey = GlobalKey<FormState>();

  final _trackController = TextEditingController();
  final _artistController = TextEditingController();
  final _albumController = TextEditingController();
  final _albumArtistController = TextEditingController();

  var _useCustomTimestamp = false;
  DateTime? _customTimestamp;

  var _isLoading = false;

  late StreamSubscription _showAlbumArtistFieldSubscription;
  StreamSubscription? _appleMusicChangeSubscription;
  late bool _showAlbumArtistField;

  @override
  void initState() {
    super.initState();
    _trackController.text = widget.track?.name ?? '';
    _artistController.text = widget.track?.artistName ?? '';
    _albumController.text = widget.track?.albumName ?? '';

    _showAlbumArtistFieldSubscription =
        Preferences.showAlbumArtistField.changes.listen((value) {
      setState(() {
        _showAlbumArtistField = value;
      });
    });

    _showAlbumArtistField = Preferences.showAlbumArtistField.value;
  }

  String? _required(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Required';
    }

    return null;
  }

  Future<void> _scrobble(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    final response = await Lastfm.scrobble([
      BasicConcreteTrack(_trackController.text, _artistController.text,
          _albumController.text, _albumArtistController.text),
    ], [
      _useCustomTimestamp ? _customTimestamp! : DateTime.now()
    ]);

    setState(() {
      _isLoading = false;
    });

    if (widget.isModal) {
      Navigator.pop(context, response.ignored == 0);
      return;
    }

    if (response.ignored == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Scrobbled successfully!')));
      _trackController.text = '';
      _artistController.text = '';
      _albumController.text = '';

      // Ask for a review
      if (await InAppReview.instance.isAvailable()) {
        InAppReview.instance.requestReview();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred while scrobbling')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(
        'Scrobble',
        actions: [
          Builder(
            builder: (context) => _isLoading
                ? const AppBarLoadingIndicator()
                : IconButton(
                    icon: const Icon(scrobbleIcon),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _scrobble(context);
                      }
                    },
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const ScrollPhysics(),
            children: [
              if (!widget.isModal) ...[
                if (isMobile) ...[],
                const SizedBox(height: 8),
                const HeaderListTile('Manual'),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _trackController,
                  decoration: const InputDecoration(labelText: 'Song *'),
                  validator: _required,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _artistController,
                  decoration: const InputDecoration(labelText: 'Artist *'),
                  validator: _required,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _albumController,
                  decoration: const InputDecoration(labelText: 'Album'),
                ),
              ),
              if (_showAlbumArtistField)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: _albumArtistController,
                    decoration:
                        const InputDecoration(labelText: 'Album Artist'),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SwitchListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Custom timestamp'),
                  value: _useCustomTimestamp,
                  onChanged: (value) {
                    setState(
                      () {
                        _useCustomTimestamp = value;

                        if (_useCustomTimestamp) {
                          _customTimestamp = DateTime.now();
                        }
                      },
                    );
                  },
                ),
              ),
              // Visibility(
              //   visible: _useCustomTimestamp,
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 16),
              //     child: DateTimeField(
              //       initialValue: _customTimestamp,
              //       onChanged: (dateTime) {
              //         setState(() {
              //           _customTimestamp = dateTime;
              //         });
              //       },
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _showAlbumArtistFieldSubscription.cancel();
    _appleMusicChangeSubscription?.cancel();
    _trackController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    _albumArtistController.dispose();
  }
}
