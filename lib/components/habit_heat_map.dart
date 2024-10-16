import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:intl/intl.dart';

class HabitHeatMap extends StatelessWidget {
  double size;
  List<StatPoint> data;
  HabitHeatMap({this.size = 40.0, required this.data});

  @override
  Widget build(BuildContext context) {
    Map<DateTime, int> formattedData = {};
    for (StatPoint dataPoint in data) {
      DateTime date = dataPoint.date;
      if (dataPoint.completions != 0) {
        formattedData[DateTime(date.year, date.month, date.day)] =
            dataPoint.completions;
      }
    }
    return Column(
      children: [
        DefaultTextStyle(
          style: TextStyle(fontWeight: FontWeight.bold),
          child: HeatMapCalendar(
            size: size,
            flexible: true,
            textColor: kBackgroundColor,
            fontSize: size / 2.5,
            margin: const EdgeInsets.all(5),
            datasets: formattedData,
            colorMode: ColorMode.opacity,
            defaultColor: kFadedBlue,
            showColorTip: false,
            colorsets: {
              1: kLightGreenAccent,
            },
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('less'),
            SizedBox(
              width: 5,
            ),
            Container(
              color: kLightGreenAccent.withOpacity(0.1),
              width: 15,
              height: 15,
            ),
            Container(
              color: kLightGreenAccent.withOpacity(0.3),
              width: 15,
              height: 15,
            ),
            Container(
              color: kLightGreenAccent.withOpacity(0.5),
              width: 15,
              height: 15,
            ),
            Container(
              color: kLightGreenAccent.withOpacity(0.7),
              width: 15,
              height: 15,
            ),
            Container(
              color: kLightGreenAccent.withOpacity(1),
              width: 15,
              height: 15,
            ),
            SizedBox(
              width: 5,
            ),
            Text('more'),
          ],
        ),
      ],
    );
  }
}
