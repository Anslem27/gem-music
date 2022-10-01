import 'package:flutter/material.dart';
import 'package:gem/CustomWidgets/bouncy_sliver_scroll_view.dart';
import 'package:gem/CustomWidgets/gradient_containers.dart';
import '../../../CustomWidgets/miniplayer.dart';

class BouncyPage extends StatefulWidget {
  final Widget body;
  final String title, imageUrl;

  const BouncyPage({
    Key? key,
    required this.title,
    required this.body,
    this.imageUrl = "assets/album.png",
  }) : super(key: key);

  @override
  State<BouncyPage> createState() => _BouncyPageState();
}

class _BouncyPageState extends State<BouncyPage> {
  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Column(
        children: [
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: BouncyImageSliverScrollView(
                imageUrl: widget.imageUrl,
                placeholderImage: widget.imageUrl,
                sliverList: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      const MiniPlayer(),

                      //page body

                      Expanded(child: widget.body),
                    ],
                  ),
                ),
                title: widget.title,
                shrinkWrap: true,
              ),
            ),
          )
        ],
      ),
    );
  }
}
