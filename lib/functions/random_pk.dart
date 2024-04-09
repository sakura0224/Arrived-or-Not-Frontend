import 'dart:math';
import 'package:flutter/material.dart';

class RandomColor {
  static final Random _random = Random();

  /// Returns a random color.
  static Color next() {
    return Color(0xFF000000 + _random.nextInt(0x00FFFFFF));
  }
}

class RandomContainer extends StatefulWidget {
  final double width;
  final double height;
  final Widget? child;
  final bool changeOnRedraw;

  const RandomContainer({
    super.key,
    this.width = double.infinity,
    this.height = double.infinity,
    this.child,
    this.changeOnRedraw = true,
  });

  @override
  RandomContainerState createState() => RandomContainerState();
}

class RandomContainerState extends State<RandomContainer> {
  late Color randomColor;

  @override
  void initState() {
    super.initState();
    randomColor = RandomColor.next();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: widget.changeOnRedraw ? RandomColor.next() : randomColor,
      child: widget.child,
    );
  }
}
