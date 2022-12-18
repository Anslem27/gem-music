import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Previously extends StatefulWidget {
  const Previously({super.key});

  @override
  State<Previously> createState() => _PreviouslyState();
}

class _PreviouslyState extends State<Previously> {
  List<MediaItem> previouslyPlayed =
      Hive.box('recently_played').get("array") as List<MediaItem>;
  @override
  Widget build(BuildContext context) {
    double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.height / 2.5;
    return SizedBox(
      height: boxSize - 20,
      width: boxSize - 30,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_homeTitleComponent("previosly played", () {}, null)],
      ),
    );
    //: const SizedBox(height: 0, width: 0);
  }
}

//title header component with actions

Row _homeTitleComponent(String title, Function()? ontap, Icon? icon) {
  return Row(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      const Spacer(),
      IconButton(
        splashRadius: 24,
        onPressed: ontap,
        icon: icon ?? const SizedBox(),
      )
    ],
  );
}
