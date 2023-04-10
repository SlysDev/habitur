import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LineGraph extends StatelessWidget {
  List data;
  LineGraph({required this.data});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(),
          ],
        ),
      ),
    );
  }
}
