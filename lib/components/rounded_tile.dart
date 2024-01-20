import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

class RoundedTile extends StatelessWidget {
  final Widget child;
  final void Function() onTap;
  final Color color;
  final EdgeInsets padding;
  const RoundedTile(
      {required this.color,
      required this.child,
      required this.onTap,
      this.padding = const EdgeInsets.all(10)});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
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
      ),
    );
  }
}
