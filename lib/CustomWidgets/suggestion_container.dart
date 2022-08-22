import 'package:flutter/material.dart';

class SuggestionConatiner extends StatelessWidget {
  final Color? color;

  final double? height;
  final double? width;
  final Widget? widget;

  const SuggestionConatiner(
    this.color,
    this.widget, {
    this.height = 300,
    this.width = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color,
      ),
      height: MediaQuery.of(context).size.height * 0.5,
      width: width,
      child: Center(
        child: widget,
      ),
    );
  }
}
