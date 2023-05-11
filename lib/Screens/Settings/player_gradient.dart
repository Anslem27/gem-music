// ignore_for_file: use_super_parameters, use_decorated_box

import 'package:flutter/material.dart';
import 'package:gem/widgets/gradient_containers.dart';
import 'package:gem/Helpers/app_config.dart';
import 'package:get_it/get_it.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PlayerGradientSelection extends StatefulWidget {
  const PlayerGradientSelection({Key? key}) : super(key: key);

  @override
  State<PlayerGradientSelection> createState() =>
      _PlayerGradientSelectionState();
}

class _PlayerGradientSelectionState extends State<PlayerGradientSelection> {
  final List<String> types = [
    'simple',
    'halfLight',
    'halfDark',
    'fullLight',
    'fullDark',
    'fullMix'
  ];
  final MyTheme currentTheme = GetIt.I<MyTheme>();
  String gradientType = Hive.box('settings')
      .get('gradientType', defaultValue: 'halfDark')
      .toString();

  @override
  Widget build(BuildContext context) {
    final List<Color?> gradientColor = [
      const Color((0xFFFFFFFF)).withOpacity(0.05),
      Theme.of(context).colorScheme.secondary.withOpacity(0.5)
    ];
    return GradientContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text(
            'Music Player Screen Theme',
          ),
        ),
        body: SafeArea(
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: MediaQuery.of(context).size.width >
                    MediaQuery.of(context).size.height
                ? 4
                : 2,
            physics: const BouncingScrollPhysics(),
            childAspectRatio: 0.6,
            children: types
                .map(
                  (type) => GestureDetector(
                    onTap: () {
                      setState(() {
                        gradientType = type;
                        Hive.box('settings').put('gradientType', type);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: GlassmorphicContainer(
                        width: 350,
                        height: 350,
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
                        borderGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color((0xFFFFFFFF)).withOpacity(0.5),
                            const Color((0xFFFFFFFF)).withOpacity(0.5),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: type == 'simple'
                                      ? Alignment.topLeft
                                      : Alignment.topCenter,
                                  end: type == 'simple'
                                      ? Alignment.bottomRight
                                      : (type == 'halfLight' ||
                                              type == 'halfDark')
                                          ? Alignment.center
                                          : Alignment.bottomCenter,
                                  colors: type == 'simple'
                                      ? Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? currentTheme.getBackGradient()
                                          : [
                                              const Color(0xfff5f9ff),
                                              Colors.white,
                                            ]
                                      : Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? [
                                              if (type == 'halfDark' ||
                                                  type == 'fullDark')
                                                gradientColor[1] ??
                                                    Colors.grey[900]!
                                              else
                                                gradientColor[0] ??
                                                    Colors.grey[900]!,
                                              if (type == 'fullMix')
                                                gradientColor[1] ?? Colors.black
                                              else
                                                Colors.black
                                            ]
                                          : [
                                              gradientColor[0] ??
                                                  const Color(0xfff5f9ff),
                                              Colors.white,
                                            ],
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                const Spacer(
                                  flex: 3,
                                ),
                                Center(
                                  child: Card(
                                    elevation: 5,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: FittedBox(
                                      child: SizedBox.square(
                                        dimension:
                                            MediaQuery.of(context).size.width /
                                                4.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const Spacer(flex: 3),
                                Center(
                                  child: Card(
                                    elevation: 5,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: FittedBox(
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                5,
                                        height:
                                            MediaQuery.of(context).size.width /
                                                25,
                                      ),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Center(
                                  child: Card(
                                    elevation: 5,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 20.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: FittedBox(
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                5,
                                        height:
                                            MediaQuery.of(context).size.width /
                                                25,
                                      ),
                                    ),
                                  ),
                                ),
                                const Spacer(
                                  flex: 3,
                                ),
                              ],
                            ),
                            if (gradientType == type)
                              const Center(
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 40,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
