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
      child: HeatMapCalendar(
        size: size,
        flexible: true,
        fontSize: size / 2.5,
        margin: EdgeInsets.all(5),
        datasets: data,
        colorMode: ColorMode.opacity,
        defaultColor: Colors.white,
        colorsets: {
          1: kPrimaryColor,
        },
      ),
    );
  }
}
