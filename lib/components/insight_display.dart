import 'package:flutter/material.dart';
import 'package:habitur/components/static_card.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/modules/insights_generator.dart';
import 'package:provider/provider.dart';

class InsightDisplay extends StatelessWidget {
  InsightDisplay({super.key, required this.stats});

  List<StatPoint> stats;

  @override
  Widget build(BuildContext context) {
    InsightsGenerator insightsGenerator = InsightsGenerator(stats);
    Map<String, dynamic> improvementData =
        insightsGenerator.findAreaForImprovement();
    String insightPreText = improvementData['message']['preText'];
    String insightPercentChange =
        improvementData['message']['percentChange'].toString();
    String insightPostText = improvementData['message']['postText'];
    if (stats.isEmpty) {
      insightPreText =
          'Looks like you haven\'t logged any stats yet! Complete your first habit to get started.';
      insightPercentChange = '';
      insightPostText = '';
    }
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
