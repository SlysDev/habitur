import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

class RoundedTile extends StatelessWidget {
  final Widget child;
  final void Function() onTap;
  final Color color;
  final EdgeInsets padding;
  final double? width;
  final double? height;
  const RoundedTile(
      {required this.color,
      required this.child,
      required this.onTap,
      this.width,
      this.height,
      this.padding = const EdgeInsets.all(10)});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: EdgeInsets.all(2),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: color,
        ),
        child: DefaultTextStyle(
          style: const TextStyle(
              color: kBackgroundColor, fontWeight: FontWeight.bold),
          child: child,
        ),
      ),
    );
  }
}
