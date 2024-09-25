import 'package:flutter/material.dart';
import 'package:habitur/components/habit_heat_map.dart';
import 'package:habitur/components/habit_stats_card_list.dart';
import 'package:habitur/components/insight_display.dart';
import 'package:habitur/components/line_graph.dart';
import 'package:habitur/components/multi_stat_line_graph.dart';
import 'package:habitur/data/data_manager.dart';
import 'package:habitur/data/local/habits_local_storage.dart';
import 'package:habitur/modules/insights_generator.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/providers/network_state_provider.dart';
import '../components/navbar.dart';
import '../components/rounded_progress_bar.dart';
import '../constants.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../data/local/user_local_storage.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({
    super.key,
  });
  Future<void> loadData(BuildContext context) async {
    DataManager dataManager = DataManager();
    await dataManager.loadStatsData(context);
  }

  @override
  Widget build(BuildContext context) {
    Database db = Database();
    debugPrint(Provider.of<UserLocalStorage>(context, listen: false)
        .currentUser
        .stats
        .toString());
    InsightsGenerator insightsGenerator = InsightsGenerator(
        Provider.of<UserLocalStorage>(context, listen: false).currentUser.stats,
        isSummary: true);
    Map<String, dynamic> insightData =
        insightsGenerator.findAreaForImprovement();
    return FutureBuilder(
      future: loadData(context),
      builder: (context, snapshot) => Scaffold(
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              const SizedBox(height: 30),
              Center(
                child: Text(
                  Provider.of<UserLocalStorage>(context)
                      .currentUser
                      .userLevel
                      .toString(),
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
                    progress: Provider.of<UserLocalStorage>(context)
                            .currentUser
                            .userXP /
                        Provider.of<UserLocalStorage>(context)
                            .currentUser
                            .levelUpRequirement,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                    "${Provider.of<UserLocalStorage>(context).currentUser.userXP} / ${Provider.of<UserLocalStorage>(context).currentUser.levelUpRequirement}",
                    style: kHeadingTextStyle.copyWith(fontSize: 20)),
              ),
              const SizedBox(
                height: 30,
              ),
              MultiStatLineGraph(
                data: Provider.of<UserLocalStorage>(context, listen: false)
                    .currentUser
                    .stats,
                height: 250,
                showStatTitle: true,
                showChangeIndicator: true,
              ),
              const SizedBox(height: 60),
              InsightDisplay(
                stats: Provider.of<UserLocalStorage>(context, listen: false)
                    .currentUser
                    .stats,
              ),
              const SizedBox(height: 60),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: HabitHeatMap(
                  data:
                      // Converts stats array into a map (list --> iterable --> map)
                      Provider.of<UserLocalStorage>(context, listen: false)
                          .currentUser
                          .stats,
                ),
              ),
              const SizedBox(height: 60),
              snapshot.connectionState == ConnectionState.waiting
                  ? CircularProgressIndicator()
                  : HabitStatsCardList(),
              const SizedBox(height: 20),
              // ... (your existing code)
            ],
          ),
        ),
        bottomNavigationBar: NavBar(
          currentPage: 'statistics',
        ),
      ),
    );
  }
}
