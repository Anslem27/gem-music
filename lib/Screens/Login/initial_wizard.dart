import 'package:flutter/material.dart';
import 'package:gem/CustomWidgets/gradient_containers.dart';
import 'package:gem/Helpers/app_config.dart';
import 'package:gem/Helpers/backup_restore.dart';
import 'package:gem/Helpers/supabase.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../Helpers/local_music_functions.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  TextEditingController controller = TextEditingController();
  Uuid uuid = const Uuid();
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future _addUserData(String name) async {
    int? status;
    await Hive.box('settings').put('name', name.trim());
    final DateTime now = DateTime.now();
    final List createDate = now
        .toUtc()
        .add(const Duration(hours: 5, minutes: 30))
        .toString()
        .split('.')
      ..removeLast()
      ..join('.');

    String userId = uuid.v1();
    status = await SupaBase().createUser({
      'id': userId,
      'name': name,
      'accountCreatedOn': '${createDate[0]} IST',
      'timeZone':
          "Zone: ${now.timeZoneName} Offset: ${now.timeZoneOffset.toString().replaceAll('.000000', '')}",
    });

    while (status == null || status == 409) {
      userId = uuid.v1();
      status = await SupaBase().createUser({
        'id': userId,
        'name': name,
        'accountCreatedOn': '${createDate[0]} IST',
        'timeZone':
            "Zone: ${now.timeZoneName} Offset: ${now.timeZoneOffset.toString().replaceAll('.000000', '')}",
      });
    }
    await Hive.box('settings').put('userId', userId);
  }

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                left: MediaQuery.of(context).size.width / 1.85,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width,
                  child: const Image(
                    image: AssetImage(
                      'assets/icon-white-trans.png',
                    ),
                  ),
                ),
              ),
              const GradientContainer(
                child: null,
                opacity: true,
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () async {
                          await restore(context);
                          GetIt.I<MyTheme>().refresh();
                          Navigator.popAndPushNamed(context, '/');
                        },
                        child: const Text('Restore'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await offlineAudioQuery.requestPermission();
                          setState(() {});
                          await _addUserData(
                            'Guest',
                          );
                          Navigator.popAndPushNamed(context, '/pref');
                        },
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: 'Gem\n',
                                    style: TextStyle(
                                      height: 0.97,
                                      fontSize: 80,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    children: <TextSpan>[
                                      const TextSpan(
                                        text: 'Music',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 80,
                                          color: Colors.white,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '.',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 80,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.1,
                            ),
                            Column(
                              children: [
                                // Container(
                                //   padding: const EdgeInsets.only(
                                //     top: 5,
                                //     bottom: 5,
                                //     left: 10,
                                //     right: 10,
                                //   ),
                                //   height: 57.0,
                                //   decoration: BoxDecoration(
                                //     borderRadius: BorderRadius.circular(10.0),
                                //     color: Colors.grey[900],
                                //     boxShadow: const [
                                //       BoxShadow(
                                //         color: Colors.black26,
                                //         blurRadius: 5.0,
                                //         offset: Offset(0.0, 3.0),
                                //       )
                                //     ],
                                //   ),
                                //   child: TextField(
                                //     controller: controller,
                                //     textAlignVertical: TextAlignVertical.center,
                                //     textCapitalization:
                                //         TextCapitalization.sentences,
                                //     keyboardType: TextInputType.name,
                                //     decoration: InputDecoration(
                                //       focusedBorder: const UnderlineInputBorder(
                                //         borderSide: BorderSide(
                                //           width: 1.5,
                                //           color: Colors.transparent,
                                //         ),
                                //       ),
                                //       prefixIcon: Icon(
                                //         Icons.person,
                                //         color: Theme.of(context)
                                //             .colorScheme
                                //             .secondary,
                                //       ),
                                //       border: InputBorder.none,
                                //       hintText: 'Enter name',
                                //       hintStyle: const TextStyle(
                                //         color: Colors.white60,
                                //       ),
                                //     ),
                                //     onSubmitted: (String value) async {
                                //       // if (value.trim() == '') {
                                //       //   await _addUserData(
                                //       //     'Guest',
                                //       //   );
                                //       // } else {
                                //       //   await _addUserData(value.trim());
                                //       // }
                                //       await _addUserData(
                                //         'Guest',
                                //       );
                                //       Navigator.popAndPushNamed(
                                //         context,
                                //         '/pref',
                                //       );
                                //     },
                                //   ),
                                //),
                                GestureDetector(
                                  onTap: () async {
                                    // if (controller.text.trim() == '') {
                                    //   await _addUserData('Guest');
                                    // } else {
                                    //   await _addUserData(
                                    //     controller.text.trim(),
                                    //   );
                                    // }
                                    await offlineAudioQuery.requestPermission();
                                    setState(() {});
                                    await _addUserData(
                                      'Guest',
                                    );
                                    Navigator.popAndPushNamed(context, '/pref');
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 10.0,
                                    ),
                                    height: 55.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 5.0,
                                          offset: Offset(0.0, 3.0),
                                        )
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Get Started',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.symmetric(
                                //     vertical: 20.0,
                                //   ),
                                //   child: Column(
                                //     children: [
                                //       Row(
                                //         children: const [
                                //           Text('Disclaimer'),
                                //         ],
                                //       ),
                                //       Text(
                                //         'We respect your privacy more than anything else. Only your name, which you will enter here, will be recorded',
                                //         style: TextStyle(
                                //           color: Colors.grey.withOpacity(0.7),
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
