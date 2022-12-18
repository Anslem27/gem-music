import 'package:flutter/material.dart';
import 'package:gem/CustomWidgets/gradient_containers.dart';
import 'package:gem/Screens/LocalMusic/widgets/preview_page.dart';
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
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: PreviewPage(
                    localImage: true,
                    isSong: true,
                    imageUrl: widget.imageUrl,
                    placeholderImage: widget.imageUrl,
                    sliverList: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          //page body

                          widget.body,
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
          const Align(
            alignment: Alignment.bottomCenter,
            child: MiniPlayer(),
          )
        ],
      ),
    );
  }
}
