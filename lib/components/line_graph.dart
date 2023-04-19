import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/providers/statistics_manager.dart';
import 'package:provider/provider.dart';

class LineGraph extends StatelessWidget {
  List data;
  double height;
  double width;
  LineGraph({required this.data, this.width = 400, this.height = 200});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
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
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
                isStrokeCapRound: true,
                barWidth: 8,
                belowBarData: BarAreaData(
                    gradient:
                        const LinearGradient(colors: [kMainBlue, kSlateGray])),
                color: kMainBlue,
                dotData: FlDotData(show: false),
                isCurved: true,
                spots: data
                    .map((dataPoint) => FlSpot(
                        dataPoint.date.millisecondsSinceEpoch.toDouble(),
                        dataPoint.value.toDouble()))
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
        swapAnimationCurve: Curves.ease,
      ),
    );
  }
}
