import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habitur/components/stat_change_indicator.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/modules/user_stats_handler.dart';
import 'package:provider/provider.dart';

class LineGraph extends StatelessWidget {
  List<StatPoint> data;
  String statName;
  double height;
  double width;
  double yAxisInterval;
  String yAxisTitle;
  bool showDots;
  bool showChangeIndicator;
  bool showStatTitle;
  LineGraph(
      {required this.data,
      this.statName = 'confidenceLevel',
      this.width = 400,
      this.height = 200,
      this.yAxisInterval = 0,
      this.yAxisTitle = '',
      this.showDots = true,
      this.showChangeIndicator = false,
      this.showStatTitle = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      height: height,
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: LineChart(
              duration: Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              LineChartData(
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    top: BorderSide(color: kDarkGray, width: 2),
                    bottom: BorderSide(color: kDarkGray, width: 2),
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    axisNameSize: yAxisTitle != '' ? width * 0.05 : 0,
                    axisNameWidget: Text(yAxisTitle,
                        style: kMainDescription.copyWith(
                            fontSize: 18, color: kGray.withOpacity(0.6))),
                    sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: width * 0.15,
                        interval: yAxisInterval != 0 ? yAxisInterval : 40,
                        getTitlesWidget: (value, meta) {
                          return Center(
                            child: Text(value.toStringAsFixed(1),
                                style: kMainDescription.copyWith(fontSize: 14)),
                          );
                        }),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                      isStrokeCapRound: true,
                      isStrokeJoinRound: true,
                      barWidth: 1,
                      belowBarData: BarAreaData(
                          gradient: const LinearGradient(
                              colors: [kPrimaryColor, kGray])),
                      color: kPrimaryColor,
                      dotData: FlDotData(show: showDots),
                      spots: data
                          .map((statPoint) => FlSpot(
                              (statPoint.date.millisecondsSinceEpoch)
                                  .ceil()
                                  .toDouble(),
                              double.parse(statPoint
                                  .getStatByName(statName)
                                  .toStringAsFixed(2))))
                          .toList())
                  // spots: [
                  //   FlSpot(0, 3),
                  //   FlSpot(2.6, 2),
                  //   FlSpot(4.9, 5),
                  //   FlSpot(6.8, 3.1),
                  //   FlSpot(8, 4),
                  //   FlSpot(9.5, 3),
                  //   FlSpot(11, 4),
                  // ])
                ],
              ),
            ),
          ),
          SizedBox(height: 40),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              showStatTitle
                  ? Text(
                      statName == 'confidenceLevel'
                          ? 'Confidence level'
                          : statName == 'difficultyRating'
                              ? 'Difficulty'
                              : statName == 'consistencyFactor'
                                  ? 'Consistency'
                                  : 'Completions',
                      style: kHeadingTextStyle.copyWith(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.06),
                    )
                  : Container(),
              showStatTitle && showChangeIndicator
                  ? const SizedBox(width: 20)
                  : Container(),
              showChangeIndicator
                  ? StatChangeIndicator(statName: statName, stats: data)
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }
}
