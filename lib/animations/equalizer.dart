// ignore_for_file: require_trailing_commas

import 'package:flutter/material.dart';

class VisualComponent extends StatefulWidget {
  const VisualComponent(
      {super.key, required this.color, required this.duration});
  final int duration;
  final Color color;
  @override
  State<VisualComponent> createState() => _VisualComponentState();
}

class _VisualComponentState extends State<VisualComponent>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animController;

  @override
  void initState() {
    animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration),
    );

    final curvedAnimation =
        CurvedAnimation(parent: animController, curve: Curves.decelerate);

    animation = Tween<double>(begin: 0, end: 100).animate(curvedAnimation)
      ..addListener(() {
        setState(() {});
      });
    animController.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: animation.value / 2,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

// ignore: must_be_immutable
class MusicVisualizer extends StatelessWidget {
  List<Color> colors = [
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.redAccent,
    Colors.yellowAccent,
  ];
  List<int> duration = [900, 600, 800, 500, 404];

  MusicVisualizer({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        colors.length,
        (index) => VisualComponent(
          color: colors[index],
          duration: duration[index],
        ),
      ),
    );
  }
}
