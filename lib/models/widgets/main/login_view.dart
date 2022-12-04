// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gem/models/widgets/main/main_view.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../../APIs/env.dart';
import '../../services/image_id.dart';
import '../../services/lastfm/artist.dart';
import '../../services/lastfm/lastfm.dart';
import '../../util/constants.dart';
import '../../util/preferences.dart';
import '../entity/entity_image.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  static void popAllAndShow(BuildContext context) {
    Navigator.popUntil(context, (_) => false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
    );
  }

  void _logIn(BuildContext context) async {
    final result = await FlutterWebAuth.authenticate(
        url: Uri.https('last.fm', 'api/auth',
            {'api_key': apiKey, 'cb': authCallbackUrl}).toString(),
        callbackUrlScheme: 'finale');
    final token = Uri.parse(result).queryParameters['token']!;
    final session = await Lastfm.authenticate(token);

    Preferences.name.value = session.name;
    Preferences.key.value = session.key;

    await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MainView(username: session.name)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          FutureBuilder<List<LTopArtistsResponseArtist>>(
            future: Lastfm.getGlobalTopArtists(50),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }

              return GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                crossAxisCount:
                    max(MediaQuery.of(context).size.width ~/ 200, 3),
                children: snapshot.data!
                    .map(
                      (artist) => FutureBuilder<List<LArtistTopAlbum>>(
                        future: ArtistGetTopAlbumsRequest(artist.name)
                            .getData(1, 1),
                        builder: (context, snapshot) => snapshot.hasData
                            ? EntityImage(
                                entity: snapshot.data!.first,
                                quality: ImageQuality.high,
                                placeholderBehavior: PlaceholderBehavior.none,
                              )
                            : GlassmorphicContainer(
                                width: double.maxFinite,
                                height: double.maxFinite,
                                borderRadius: 0,
                                blur: 20,
                                alignment: Alignment.bottomCenter,
                                border: 2,
                                linearGradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Theme.of(context).colorScheme.secondary,
                                      const Color(0xFFFFFFFF).withOpacity(0.05),
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
                                child: null,
                              ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          ////////////////////////////////
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GlassmorphicContainer(
                  width: double.maxFinite,
                  height: 200,
                  borderRadius: 8,
                  blur: 20,
                  alignment: Alignment.bottomCenter,
                  border: 2,
                  linearGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFffffff).withOpacity(0.1),
                        const Color(0xFFFFFFFF).withOpacity(0.05),
                      ],
                      stops: const [
                        0.1,
                        1,
                      ]),
                  borderGradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.transparent, Colors.transparent],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SCROBBLER',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Gem's last fm scrobbler.\nMaking your music even more personal",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: () => _logIn(context),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context).colorScheme.secondary),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(FontAwesomeIcons.lastfm,
                                  color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                'Log in with Last.fm',
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            "Click here to learn more".toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 15,
                            ),
                          ),
                        )
                      ],
                    ),
                  )),
            ),
          )
        ],
      ),
    );
  }
}
