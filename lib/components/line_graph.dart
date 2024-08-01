import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/modules/summary_statistics_recorder.dart';
import 'package:provider/provider.dart';

class LineGraph extends StatelessWidget {
  List<StatPoint> data;
  double height;
  double width;
  double yAxisInterval;
  String yAxisTitle;
  bool showDots;
  LineGraph({
    required this.data,
    this.width = 400,
    this.height = 200,
    this.yAxisInterval = 0,
    this.yAxisTitle = '',
    this.showDots = true,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      height: height,
      width: width,
      child: LineChart(
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
                  interval:
                      yAxisInterval != 0 ? yAxisInterval : double.infinity,
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
                    gradient:
                        const LinearGradient(colors: [kPrimaryColor, kGray])),
                color: kPrimaryColor,
                dotData: FlDotData(show: showDots),
                spots: data
                    .map((statPoint) => FlSpot(
                        (statPoint.date.millisecondsSinceEpoch)
                            .ceil()
                            .toDouble(),
                        double.parse(
                            statPoint.confidenceLevel.toStringAsFixed(2))))
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
    );
  }
}
