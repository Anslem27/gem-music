// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:gem/CustomWidgets/gradient_containers.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String? appVersion;

  @override
  void initState() {
    main();
    super.initState();
  }

  Future<void> main() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Stack(
        children: [
          Positioned(
            left: MediaQuery.of(context).size.width / 2,
            top: MediaQuery.of(context).size.width / 5,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: const Image(
                fit: BoxFit.fill,
                image: AssetImage(
                  //transparent back image
                  'assets/icon-white-trans.png',
                ),
              ),
            ),
          ),
          const GradientContainer(
            child: null,
            opacity: true,
          ),
          Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.secondary,
              elevation: 0,
              title: const Text(
                "About",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
            backgroundColor: Colors.transparent,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Card(
                      elevation: 15,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: const SizedBox(
                        width: 150,
                        child:
                            Image(image: AssetImage('assets/ic_launcher.png')),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Gem",
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('v$appVersion'),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Contact me",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () {
                          launchUrl(
                            Uri.parse(
                              'https://github.com/Anslem27',
                            ),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 4,
                          child: Image(
                            image: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? const AssetImage(
                                    'assets/GitHub_Logo_White.png',
                                  )
                                : const AssetImage('assets/GitHub_Logo.png'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: const [
                    // TextButton(
                    //   style: TextButton.styleFrom(
                    //     padding: EdgeInsets.zero,
                    //     backgroundColor: Colors.transparent,
                    //     primary: Colors.transparent,
                    //   ),
                    //   onPressed: () {
                    //     const String upiUrl =
                    //         'upi://pay?pa=ankit.sangwan.5688@oksbi&pn=BlackHole&mc=5732&aid=uGICAgIDn98OpSw&tr=BCR2DN6T37O6DB3Q';
                    //     launchUrl(
                    //       Uri.parse(upiUrl),
                    //       mode: LaunchMode.externalApplication,
                    //     );
                    //   },
                    //   onLongPress: () {
                    //     copyToClipboard(
                    //       context: context,
                    //       text: 'ankit.sangwan.5688@oksbi',
                    //       displayText: AppLocalizations.of(
                    //         context,
                    //       )!
                    //           .upiCopied,
                    //     );
                    //   },
                    //   child: SizedBox(
                    //     width: MediaQuery.of(context).size.width / 2,
                    //     child: Image(
                    //       image: AssetImage(
                    //         Theme.of(context).brightness == Brightness.dark
                    //             ? 'assets/gpay-white.png'
                    //             : 'assets/gpay-white.png',
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
