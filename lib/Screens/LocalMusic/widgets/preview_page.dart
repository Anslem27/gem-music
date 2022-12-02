import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../../CustomWidgets/miniplayer.dart';

class PreviewPage extends StatelessWidget {
  final ScrollController? scrollController;
  final Widget sliverList;
  final bool shrinkWrap;
  final List<Widget>? actions;
  final String title;
  final String? imageUrl;
  final bool localImage;
  final bool isSong;
  final String placeholderImage;
  PreviewPage({
    Key? key,
    this.scrollController,
    this.shrinkWrap = false,
    required this.sliverList,
    required this.title,
    this.placeholderImage = 'assets/cover.jpg',
    this.localImage = false,
    this.imageUrl,
    this.actions,
    required this.isSong,
  }) : super(key: key);

  final ValueNotifier<double> _opacity = ValueNotifier<double>(1.0);

  @override
  Widget build(BuildContext context) {
    double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.height / 2.5;

    Widget? image = (imageUrl == null
        ? Image(
            fit: BoxFit.cover,
            image: AssetImage(placeholderImage),
          ) as ImageProvider
        : localImage
            ? Image(
                image: AssetImage(
                  imageUrl!,
                ),
                fit: BoxFit.cover,
              )
            : isSong
                ? Image(
                    image: FileImage(
                      File(
                        imageUrl!,
                      ),
                    ),
                    fit: BoxFit.cover,
                  )
                : CachedNetworkImage(
                    fit: BoxFit.cover,
                    errorWidget: (context, _, __) => Image(
                      fit: BoxFit.cover,
                      image: AssetImage(placeholderImage),
                    ),
                    imageUrl: imageUrl!,
                    placeholder: (context, url) => Image(
                      fit: BoxFit.cover,
                      image: AssetImage(placeholderImage),
                    ),
                  )) as Widget?;

    final bool rotated =
        MediaQuery.of(context).size.height < MediaQuery.of(context).size.width;
    final double expandedHeight = MediaQuery.of(context).size.height * 0.45;

//get dorminant color from image rendered
    Future<Color> getdominantColor(ImageProvider imageProvider) async {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(imageProvider);
      return paletteGenerator.dominantColor!.color;
    }

    return FutureBuilder(
      future: getdominantColor(AssetImage(imageUrl!)),
      builder: (_, AsyncSnapshot<Color> snapshot) {
        return snapshot.connectionState == ConnectionState.waiting
            ? const Center(
                child: SizedBox(),
              )
            : Stack(
                children: [
                  CustomScrollView(
                    controller: scrollController,
                    shrinkWrap: shrinkWrap,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverAppBar(
                        elevation: 0,
                        stretch: true,
                        pinned: true,
                        centerTitle: true,
                        expandedHeight: expandedHeight,
                        actions: actions,
                        title: Opacity(
                          opacity: 1 - _opacity.value,
                          child: Text(
                            title.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        flexibleSpace: LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            double top = constraints.biggest.height;
                            if (top > expandedHeight) {
                              top = expandedHeight;
                            }

                            _opacity.value = (top - 80) / (expandedHeight - 80);

                            return FlexibleSpaceBar(
                              title: Opacity(
                                opacity: max(0, _opacity.value),
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              centerTitle: true,
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
                                      snapshot.data!.withOpacity(0.9),
                                      snapshot.data!.withOpacity(0.05),
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
                                child: Stack(
                                  children: [
                                    if (!rotated)
                                      Align(
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12.0),
                                              child: SizedBox(
                                                height: boxSize + 20,
                                                child: image,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    // SizedBox.expand(
                                    //   child: ShaderMask(
                                    //     shaderCallback: (rect) {
                                    //       return const LinearGradient(
                                    //         begin: Alignment.center,
                                    //         end: Alignment.bottomCenter,
                                    //         colors: [
                                    //           Colors.black,
                                    //           Colors.transparent,
                                    //         ],
                                    //       ).createShader(
                                    //         Rect.fromLTRB(
                                    //           0,
                                    //           0,
                                    //           rect.width,
                                    //           rect.height,
                                    //         ),
                                    //       );
                                    //     },
                                    //     blendMode: BlendMode.dstIn,
                                    //     child: image,
                                    //   ),
                                    // ),
                                    if (rotated)
                                      Align(
                                        alignment: const Alignment(-0.85, 0.5),
                                        child: Card(
                                          elevation: 5,
                                          color: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(7.0),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.3,
                                            child: image,
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
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            //page body

                            sliverList,
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: MiniPlayer(),
                  )
                ],
              );
      },
    );
  }
}
