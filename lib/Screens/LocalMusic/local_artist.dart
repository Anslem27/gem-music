import 'package:flutter/material.dart';
import 'package:gem/CustomWidgets/bouncy_sliver_scroll_view.dart';
import 'package:gem/CustomWidgets/gradient_containers.dart';
import 'package:iconsax/iconsax.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LocalArtist extends StatefulWidget {
  final String title;

  const LocalArtist({Key? key, required this.title}) : super(key: key);

  @override
  State<LocalArtist> createState() => _LocalArtistState();
}

class _LocalArtistState extends State<LocalArtist> {
  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Column(
        children: [
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: BouncyImageSliverScrollView(
                actions: [
                  IconButton(
                    splashRadius: 24,
                    onPressed: () {},
                    icon: const Icon(Iconsax.shuffle),
                  ),
                  IconButton(
                    splashRadius: 24,
                    onPressed: () {},
                    icon: const Icon(MdiIcons.pictureInPictureTopRight),
                  ),
                ],
                imageUrl: "assets/album.png",
                sliverList: SliverList(
                  delegate: SliverChildListDelegate([]),
                ),
                title: widget.title,
              ),
            ),
          )
        ],
      ),
    );
  }
}
