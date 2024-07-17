import 'package:flutter/material.dart';
import 'package:habitur/components/static_card.dart';
import 'package:habitur/constants.dart';

class InsightDisplay extends StatelessWidget {
  const InsightDisplay({
    super.key,
    required this.insightPreText,
    required this.insightPercentChange,
    required this.insightPostText,
  });

  final String insightPreText;
  final String insightPercentChange;
  final String insightPostText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StaticCard(
          child: Icon(Icons.lightbulb),
          color: kOrangeAccent,
        ),
        const SizedBox(width: 20),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: insightPreText,
                  style: kMainDescription,
                ),
                insightPercentChange == '0.0%'
                    ? TextSpan()
                    : TextSpan(
                        text: ' $insightPercentChange ',
                        style: kMainDescription.copyWith(
                          color: kOrangeAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                TextSpan(
                  text: insightPostText,
                  style: kMainDescription,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
