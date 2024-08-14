import 'package:flutter/material.dart';
import 'package:habitur/components/habit_heat_map.dart';
import 'package:habitur/components/habit_stats_card_list.dart';
import 'package:habitur/components/insight_display.dart';
import 'package:habitur/components/line_graph.dart';
import 'package:habitur/modules/insights_generator.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/providers/summary_statistics_repository.dart';
import '../components/navbar.dart';
import '../components/rounded_progress_bar.dart';
import '../constants.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../providers/user_data.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    InsightsGenerator insightsGenerator = InsightsGenerator(
        Provider.of<SummaryStatisticsRepository>(context).statPoints,
        isSummary: true);
    Map<String, dynamic> insightData =
        insightsGenerator.findAreaForImprovement();
    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: ListView(
          children: [
            const SizedBox(height: 30),
            Center(
              child: Text(
                Provider.of<UserData>(context).currentUser.userLevel.toString(),
                style: kTitleTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
                child: RoundedProgressBar(
                  lineHeight: 25,
                  color: kPrimaryColor,
                  progress: Provider.of<UserData>(context).currentUser.userXP /
                      Provider.of<UserData>(context).levelUpRequirement,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                  "${Provider.of<UserData>(context).currentUser.userXP} / ${Provider.of<UserData>(context).levelUpRequirement}",
                  style: kHeadingTextStyle.copyWith(fontSize: 20)),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: HabitHeatMap(
                data:
                    // Converts stats array into a map (list --> iterable --> map)
                    Provider.of<SummaryStatisticsRepository>(context)
                        .statPoints,
              ),
            ),
            const SizedBox(height: 60),
            InsightDisplay(
              insightPreText: insightData['message']['preText'],
              insightPercentChange:
                  insightData['message']['percentChange'].toString(),
              insightPostText: insightData['message']['postText'],
            ),
            const SizedBox(height: 60),
            LineGraph(
              data:
                  Provider.of<SummaryStatisticsRepository>(context).statPoints,
            ),
            const SizedBox(height: 60),
            const HabitStatsCardList(),
            const SizedBox(height: 20),
            // ... (your existing code)
          ],
        ),
      ),
      bottomNavigationBar: NavBar(
        currentPage: 'statistics',
      ),
    );
  }
}
