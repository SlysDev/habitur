import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/modules/statistics_recorder.dart';
import 'package:provider/provider.dart';

class LineGraph extends StatelessWidget {
  List data;
  double height;
  double width;
  LineGraph({required this.data, this.width = 400, this.height = 200});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(40),
      height: height,
      width: width,
      child: LineChart(
        LineChartData(
          maxY: 2,
          minY: 0,
          borderData: FlBorderData(show: false),
          // borderData: FlBorderData(
          //   show: true,
          //   border: Border(
          //     top: BorderSide(color: kMainBlue),
          //     bottom: BorderSide(color: kMainBlue),
          //   ),
          // ),
          titlesData: FlTitlesData(
            show: false,
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
                barWidth: 5,
                belowBarData: BarAreaData(
                    gradient:
                        const LinearGradient(colors: [kPrimaryColor, kGray])),
                color: kPrimaryColor,
                dotData: FlDotData(show: false),
                isCurved: true,
                preventCurveOverShooting: false,
                curveSmoothness: 0.2,
                spots: data
                    .map((dataPoint) => FlSpot(
                        (dataPoint.date.millisecondsSinceEpoch)
                            .ceil()
                            .toDouble(),
                        double.parse(dataPoint.value.toStringAsFixed(2))))
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
