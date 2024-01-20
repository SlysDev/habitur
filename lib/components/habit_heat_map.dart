import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:habitur/constants.dart';

class HabitHeatMap extends StatelessWidget {
  double size;
  Map<DateTime, int> data;
  HabitHeatMap({this.size = 40.0, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: DefaultTextStyle(
        style: TextStyle(fontWeight: FontWeight.bold),
        child: HeatMapCalendar(
          size: size,
          flexible: true,
          textColor: kBackgroundColor,
          fontSize: size / 2.5,
          margin: const EdgeInsets.all(5),
          datasets: data,
          colorMode: ColorMode.opacity,
          defaultColor: kFadedBlue,
          showColorTip: true,
          colorsets: {
            1: kLightGreenAccent,
          },
        ),
      ),
    );
  }
}
