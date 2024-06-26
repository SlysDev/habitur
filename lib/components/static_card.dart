import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

class StaticCard extends StatelessWidget {
  StaticCard(
      {super.key,
      required this.child,
      this.color = kFadedBlue,
      this.opacity = 0.5});
  Widget child;
  Color color;
  double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: color.withOpacity(opacity),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: Offset(0, 10),
                spreadRadius: 1,
                blurRadius: 30),
          ]),
      child: child,
    );
  }
}
