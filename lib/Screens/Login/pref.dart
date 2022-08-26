import 'package:flutter/material.dart';
import 'package:gem/CustomWidgets/gradient_containers.dart';
import 'package:google_fonts/google_fonts.dart';

class PrefScreen extends StatefulWidget {
  const PrefScreen({super.key});

  @override
  _PrefScreenState createState() => _PrefScreenState();
}

class _PrefScreenState extends State<PrefScreen> {
  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Scaffold(
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
                        onPressed: () {
                          Navigator.popAndPushNamed(context, '/');
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
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      text: 'Gem Music\n',
                                      style: TextStyle(
                                        fontSize: 65,
                                        height: 1.0,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                      children: const <TextSpan>[
                                        TextSpan(
                                          text: 'All your music\nin one app\n',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 50,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ListTile(
                                  title: Text(
                                    "Sure you'll love the experience...",
                                    style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                  // trailing: Container(
                                  //   padding: const EdgeInsets.only(
                                  //     top: 5,
                                  //     bottom: 5,
                                  //     left: 10,
                                  //     right: 10,
                                  //   ),
                                  //   height: 57.0,
                                  //   width: 150,
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
                                  //   child: Center(
                                  //     child: Text(
                                  //       preferredLanguage.isEmpty
                                  //           ? 'None'
                                  //           : preferredLanguage.join(', '),
                                  //       maxLines: 2,
                                  //       overflow: TextOverflow.ellipsis,
                                  //       textAlign: TextAlign.end,
                                  //     ),
                                  //   ),
                                  // ),
                                  dense: true,
                                  onTap: () {
                                    // showModalBottomSheet(
                                    //   isDismissible: true,
                                    //   backgroundColor: Colors.transparent,
                                    //   context: context,
                                    //   builder: (BuildContext context) {
                                    //     final List checked =
                                    //         List.from(preferredLanguage);
                                    //     return StatefulBuilder(
                                    //       builder: (
                                    //         BuildContext context,
                                    //         StateSetter setStt,
                                    //       ) {
                                    //         return BottomGradientContainer(
                                    //           borderRadius:
                                    //               BorderRadius.circular(20.0),
                                    //           child: Column(
                                    //             children: [
                                    //               Expanded(
                                    //                 child: ListView.builder(
                                    //                   physics:
                                    //                       const BouncingScrollPhysics(),
                                    //                   shrinkWrap: true,
                                    //                   padding: const EdgeInsets
                                    //                       .fromLTRB(
                                    //                     0,
                                    //                     10,
                                    //                     0,
                                    //                     10,
                                    //                   ),
                                    //                   itemCount:
                                    //                       languages.length,
                                    //                   itemBuilder:
                                    //                       (context, idx) {
                                    //                     return CheckboxListTile(
                                    //                       activeColor: Theme.of(
                                    //                         context,
                                    //                       )
                                    //                           .colorScheme
                                    //                           .secondary,
                                    //                       value:
                                    //                           checked.contains(
                                    //                         languages[idx],
                                    //                       ),
                                    //                       title: Text(
                                    //                         languages[idx],
                                    //                       ),
                                    //                       onChanged:
                                    //                           (bool? value) {
                                    //                         value!
                                    //                             ? checked.add(
                                    //                                 languages[
                                    //                                     idx],
                                    //                               )
                                    //                             : checked
                                    //                                 .remove(
                                    //                                 languages[
                                    //                                     idx],
                                    //                               );
                                    //                         setStt(() {});
                                    //                       },
                                    //                     );
                                    //                   },
                                    //                 ),
                                    //               ),
                                    //               Row(
                                    //                 mainAxisAlignment:
                                    //                     MainAxisAlignment.end,
                                    //                 children: [
                                    //                   TextButton(
                                    //                     style: TextButton
                                    //                         .styleFrom(
                                    //                       primary:
                                    //                           Theme.of(context)
                                    //                               .colorScheme
                                    //                               .secondary,
                                    //                     ),
                                    //                     onPressed: () {
                                    //                       Navigator.pop(
                                    //                         context,
                                    //                       );
                                    //                     },
                                    //                     child: Text(
                                    //                       AppLocalizations.of(
                                    //                         context,
                                    //                       )!
                                    //                           .cancel,
                                    //                     ),
                                    //                   ),
                                    //                   TextButton(
                                    //                     style: TextButton
                                    //                         .styleFrom(
                                    //                       primary:
                                    //                           Theme.of(context)
                                    //                               .colorScheme
                                    //                               .secondary,
                                    //                     ),
                                    //                     onPressed: () {
                                    //                       setState(() {
                                    //                         preferredLanguage =
                                    //                             checked;
                                    //                         Navigator.pop(
                                    //                           context,
                                    //                         );
                                    //                         Hive.box('settings')
                                    //                             .put(
                                    //                           'preferredLanguage',
                                    //                           checked,
                                    //                         );
                                    //                       });
                                    //                       if (preferredLanguage
                                    //                           .isEmpty) {
                                    //                         ShowSnackBar()
                                    //                             .showSnackBar(
                                    //                           context,
                                    //                           AppLocalizations
                                    //                                   .of(
                                    //                             context,
                                    //                           )!
                                    //                               .noLangSelected,
                                    //                         );
                                    //                       }
                                    //                     },
                                    //                     child: Text(
                                    //                       AppLocalizations.of(
                                    //                         context,
                                    //                       )!
                                    //                           .ok,
                                    //                       style:
                                    //                           const TextStyle(
                                    //                         fontWeight:
                                    //                             FontWeight.w600,
                                    //                       ),
                                    //                     ),
                                    //                   ),
                                    //                 ],
                                    //               ),
                                    //             ],
                                    //           ),
                                    //         );
                                    //       },
                                    //     );
                                    //   },
                                    // );
                                  },
                                ),
                                const SizedBox(
                                  height: 30.0,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.popAndPushNamed(context, '/');
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 10.0,
                                    ),
                                    height: 55.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      // color: Theme.of(context).accentColor,
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
