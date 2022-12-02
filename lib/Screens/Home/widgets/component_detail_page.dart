import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class HomeComponentDetailPage extends StatelessWidget {
  final Widget body;
  final String title;
  const HomeComponentDetailPage(
      {super.key, required this.body, required this.title});

  @override
  Widget build(BuildContext context) {
    final bool rotated =
        MediaQuery.of(context).size.height < MediaQuery.of(context).size.width;
    double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.height / 2.5;
    return Scaffold(
      body: NestedScrollView(
        physics: const BouncingScrollPhysics(),
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              elevation: 0,
              stretch: true,
              pinned: true,
              centerTitle: true,
              expandedHeight: MediaQuery.of(context).size.height * 0.3,
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  double top = constraints.biggest.height;
                  if (top > MediaQuery.of(context).size.height * 0.45) {
                    top = MediaQuery.of(context).size.height * 0.45;
                  }
                  return FlexibleSpaceBar(
                    expandedTitleScale: 1,
                    centerTitle: true,
                    title: Text(
                      title,
                      style: const TextStyle(fontSize: 17),
                    ),
                    background: GlassmorphicContainer(
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
                            Colors.white30.withOpacity(0.9),
                            Colors.white30.withOpacity(0.05),
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
                      child: Stack(
                        children: [
                          if (!rotated)
                            Align(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0),
                                    child: SizedBox(
                                      height: boxSize - 40,
                                      child: Image.asset("assets/cover.jpg"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (rotated)
                            Align(
                              alignment: const Alignment(-0.85, 0.5),
                              child: Card(
                                elevation: 5,
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  child: Image.asset("assets/cover.jpg"),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ];
        },
        body: body,
      ),
    );
  }
}
