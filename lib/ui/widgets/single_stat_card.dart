import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/widgets/modern_card.dart';
import 'package:habitur/ui/widgets/static_card.dart';

class SingleStatCard extends StatelessWidget {
  const SingleStatCard({
    super.key,
    required this.statText,
    required this.statDescription,
    required this.color,
    this.fontSize = 35,
  });
  final String statText;
  final String statDescription;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      padding: 20,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              statText,
              style: kTitleTextStyle.copyWith(
                  color: Colors.white, fontSize: fontSize),
              textAlign: TextAlign.center,
            ),
            Text(
              statDescription,
              style: kMainDescription.copyWith(
                  color: Colors.grey, fontSize: fontSize / 2.30),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      color: color,
      opacity: 0.1,
    );
  }
}
