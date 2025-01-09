import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

class EmphasisCard extends StatelessWidget {
  EmphasisCard({
    super.key,
    required this.child,
    this.color = kFadedGreen,
    this.borderColor = kPrimaryColor,
    this.borderWidth = 2.0,
  });

  final Widget child;
  final Color borderColor;
  final Color color;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 800),
      curve: Curves.easeInOutSine,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(0, 10),
            spreadRadius: 1,
            blurRadius: 30,
          ),
        ],
      ),
      child: child,
    );
  }
}
