import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:provider/provider.dart';

class StatisticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserData>(
		builder: (context, userData, child) {
			return Scaffold(
        body: Column(
          children: [
            Text(
              '${}',
              textAlign: TextAlign.center,
              style: kTitleTextStyle,
            ),
            Text(
              'Habitur Rating',
              textAlign: TextAlign.center,
              style: kHeadingTextStyle,
            ),
          ],
        ),
      );
		},
      ,
    );
  }
}
