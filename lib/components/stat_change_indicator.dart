import 'package:flutter/material.dart';
import 'package:habitur/components/static_card.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/modules/stats_calculator.dart';

class StatChangeIndicator extends StatelessWidget {
  final String statName;
  final List<StatPoint> stats;

  StatChangeIndicator({required this.statName, required this.stats, super.key});

  @override
  Widget build(BuildContext context) {
    StatsCalculator statsCalculator = StatsCalculator();
    double valueChange = statsCalculator.calculateStatChange(stats, statName);
    String changeSymbol = valueChange > 0 ? '↑' : '↓';
    changeSymbol = valueChange == 0 ? '–' : changeSymbol;
    Color changeColor = valueChange > 0 ? Colors.green : Colors.red;
    changeColor = valueChange == 0 ? Colors.white60 : changeColor;

    return StaticCard(
      padding: MediaQuery.of(context).size.width * 0.05,
      color: changeColor,
      opacity: 0.2,
      child: Text(
        '${valueChange.toStringAsFixed(2)} $changeSymbol',
        style: TextStyle(
          color: changeColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
