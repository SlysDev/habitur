import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:habitur/constants.dart';

class HabitHeatMap extends StatelessWidget {
  double size;
  Map<DateTime, int> data;
  HabitHeatMap({this.size = 20.0, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: HeatMap(
        size: size,
        datasets: data,
        startDate: DateTime.now().subtract(Duration(days: 30)),
        endDate: DateTime.now(),
        colorMode: ColorMode.opacity,
        showText: false,
        defaultColor: Colors.white,
        scrollable: true,
        colorsets: {
          1: kMainBlue,
        },
        onClick: (value) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(value.toString())));
        },
      ),
    );
  }
}
