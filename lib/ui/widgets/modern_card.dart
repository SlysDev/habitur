import 'package:flutter/material.dart';

import '../../constants.dart';

class ModernCard extends StatelessWidget {
  const ModernCard(
      {Key? key, required this.child, this.opacity = 0.20, this.color})
      : super(key: key);

  final Widget child;
  final double opacity;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: (color ?? kFadedBlue).withOpacity(opacity),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kPrimaryColor.withOpacity(0.1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: child,
      ),
    );
  }
}
