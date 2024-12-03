import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/stat_point.dart';
import 'habit_heat_map_model.dart';

class HabitHeatMap extends StackedView<HabitHeatMapModel> {
  final double size;
  final List<StatPoint> data;

  const HabitHeatMap({
    this.size = 40.0,
    required this.data,
    Key? key,
  }) : super(key: key);

  @override
  Widget builder(
      BuildContext context, HabitHeatMapModel viewModel, Widget? child) {
    return Column(
      children: [
        Text('Completion Heatmap',
            style: kSubHeadingTextStyle.copyWith(color: Colors.white)),
        DefaultTextStyle(
          style: TextStyle(fontWeight: FontWeight.bold),
          child: HeatMapCalendar(
            size: size,
            flexible: true,
            textColor: kBackgroundColor,
            fontSize: size / 2.5,
            margin: const EdgeInsets.all(5),
            datasets: viewModel.formattedData,
            colorMode: ColorMode.opacity,
            defaultColor: kFadedBlue,
            showColorTip: false,
            colorsets: {
              1: kLightGreenAccent,
            },
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('less', style: kMainDescription),
            SizedBox(width: 10),
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
            SizedBox(width: 10),
            Text('more', style: kMainDescription),
          ],
        ),
      ],
    );
  }

  @override
  HabitHeatMapModel viewModelBuilder(BuildContext context) {
    final model = HabitHeatMapModel();
    model.initialize(data);
    return model;
  }
}
