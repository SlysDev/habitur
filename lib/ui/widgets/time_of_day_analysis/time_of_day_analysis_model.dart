import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/services/measurement_analytics_service.dart';
import 'package:stacked/stacked.dart';

class TimeBlock {
  final String name;
  final int completions;
  final double percentage;

  TimeBlock({
    required this.name,
    required this.completions,
    required this.percentage,
  });
}

class TimeOfDayAnalysisModel extends BaseViewModel {
  final _analyticsService = locator<MeasurementAnalyticsService>();
  final List<StatPoint> stats;

  TimeOfDayAnalysisModel({required this.stats});

  List<TimeBlock> get timeBlocks {
    final completions = _analyticsService.analyzeOptimalTimes(stats);
    if (completions.isEmpty) return [];

    final maxCompletions = completions.values.reduce((a, b) => a > b ? a : b);

    return completions.entries.map((entry) {
      return TimeBlock(
        name: entry.key,
        completions: entry.value,
        percentage: entry.value / maxCompletions,
      );
    }).toList()
      ..sort((a, b) => b.completions.compareTo(a.completions));
  }

  String get bestTimeBlock {
    if (timeBlocks.isEmpty) return 'Not enough data';
    return timeBlocks.first.name;
  }

  bool get hasEnoughData => stats.length >= 7;

  List<String> get patterns {
    if (!hasEnoughData) return [];

    final blocks = timeBlocks;
    final patterns = <String>[];

    // Analyze morning vs evening performance
    final morningBlock = blocks.firstWhere(
      (block) => block.name == 'Morning',
      orElse: () => TimeBlock(name: 'Morning', completions: 0, percentage: 0),
    );
    final eveningBlock = blocks.firstWhere(
      (block) => block.name == 'Evening',
      orElse: () => TimeBlock(name: 'Evening', completions: 0, percentage: 0),
    );

    if (morningBlock.completions > eveningBlock.completions * 1.5) {
      patterns.add("You're significantly more productive in the morning");
    } else if (eveningBlock.completions > morningBlock.completions * 1.5) {
      patterns.add("Evening seems to be your power hour");
    }

    // Check for consistent time blocks
    final mostConsistentBlock = blocks.first;
    if (mostConsistentBlock.percentage > 0.7) {
      patterns.add(
        "You're very consistent with ${mostConsistentBlock.name.toLowerCase()} completions",
      );
    }

    // Add time-specific recommendations
    switch (bestTimeBlock) {
      case 'Morning':
        patterns.add('Try to maintain your morning routine for best results');
        break;
      case 'Afternoon':
        patterns.add('Mid-day seems to work well for you');
        break;
      case 'Evening':
        patterns.add('Consider setting evening reminders to maintain momentum');
        break;
      case 'Night':
        patterns.add('You tend to be more active at night');
        break;
    }

    return patterns;
  }
}
