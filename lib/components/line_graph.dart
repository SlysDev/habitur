import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/stat_point.dart';
import 'dart:math';
import 'stat_change_indicator.dart';

class LineGraph extends StatelessWidget {
  final List<StatPoint> data;
  final String title;
  final String statName;
  final double height;
  final double width;
  final Color color;
  final bool showStatTitle;
  final bool showChangeIndicator;

  const LineGraph({
    Key? key,
    required this.data,
    required this.title,
    required this.statName,
    this.height = 200,
    this.width = double.infinity,
    this.color = kLightGreenAccent,
    this.showStatTitle = true,
    this.showChangeIndicator = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        width: width,
        child: Card(
          color: kDarkGray.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showStatTitle) ...[
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                ],
                Center(
                  child: Text(
                    'No data available',
                    style: TextStyle(color: kGray),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Handle single data point
    if (data.length == 1) {
      return Container(
        width: width,
        child: Card(
          color: kDarkGray.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showStatTitle) ...[
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                ],
                SizedBox(
                  height: height,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.show_chart_rounded,
                          color: color.withOpacity(0.5),
                          size: 48,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'More data points needed',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Keep tracking to see your progress graph',
                          style: TextStyle(
                            color: kGray,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final spots = data.map((stat) {
      return FlSpot(
        stat.date.millisecondsSinceEpoch.toDouble(),
        stat.getStatByName(statName).toDouble(),
      );
    }).toList();

    // Calculate date interval to prevent overcrowding
    final totalDays = (spots.last.x - spots.first.x) / (24 * 60 * 60 * 1000);
    final daysInterval = max(1, (totalDays / 5).ceil());
    final dateInterval = daysInterval * 24 * 60 * 60 * 1000;

    // Sort dates for label filtering
    final allDates = spots.map((spot) => DateTime.fromMillisecondsSinceEpoch(spot.x.toInt())).toList();
    allDates.sort();

    // Calculate min and max Y values
    final yValues = spots.map((spot) => spot.y).toList();
    final minY = yValues.reduce(min);
    final maxY = yValues.reduce(max);
    
    // Calculate a nice interval for the Y axis
    final range = maxY - minY;
    final rawInterval = range / 3;
    
    // Round to a nice number (1, 2, 5, 10, 20, 50, etc.)
    final magnitude = pow(10, (log(max(rawInterval, 0.0001)) / ln10).floor());
    final niceInterval = [1, 2, 5, 10]
        .map((base) => base * magnitude)
        .firstWhere((interval) => interval >= rawInterval).toDouble();

    // Determine number of decimal places based on interval size
    final decimalPlaces =  
                         niceInterval >= 0.1 ? 1 :
                         niceInterval >= 0.01 ? 2 : 3;

    // Adjust min and max to be nice multiples of the interval
    final adjustedMinY = (minY / niceInterval).floor() * niceInterval;
    final adjustedMaxY = ((maxY / niceInterval).ceil() * niceInterval) + niceInterval;

    return Container(
      width: width,
      child: Card(
        color: kDarkGray.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showStatTitle) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (showChangeIndicator && data.length >= 2)
                      StatChangeIndicator(
                        oldValue: data[data.length - 2].getStatByName(statName).toDouble(),
                        newValue: data.last.getStatByName(statName).toDouble(),
                      ),
                  ],
                ),
                SizedBox(height: 15),
              ],
              SizedBox(
                height: height,
                width: width,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: niceInterval,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: kGray.withOpacity(0.3),
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: kGray.withOpacity(0.3),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                            // Only show dates that are at the interval points
                            if ((value - spots.first.x) % dateInterval != 0) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                '${date.month}/${date.day}',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                          interval: dateInterval.toDouble(),
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: niceInterval,
                          reservedSize: 35,
                          getTitlesWidget: (value, meta) {
                            return Container(
                              margin: EdgeInsets.only(right: 8),
                              child: Text(
                                value.toStringAsFixed(decimalPlaces),
                                style: TextStyle(
                                  color: kGray,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: kGray.withOpacity(0.3)),
                    ),
                    minX: spots.first.x,
                    maxX: spots.last.x,
                    minY: adjustedMinY,
                    maxY: adjustedMaxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.25,
                        color: color,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: color.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
