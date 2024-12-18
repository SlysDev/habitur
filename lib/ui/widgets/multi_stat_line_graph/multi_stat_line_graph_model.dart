import 'package:stacked/stacked.dart';
import 'package:habitur/models/stat_point.dart';

class MultiStatLineGraphModel extends BaseViewModel {
  String _displayedStat = 'confidenceLevel';
  String get displayedStat => _displayedStat;

  late List<String> statOptions;

  String get mappedStatName {
    switch (_displayedStat) {
      case 'difficultyRating':
        return 'Difficulty Rating';
      case 'consistencyFactor':
        return 'Consistency';
      case 'completions':
        return 'Completions';
      default:
        return 'Confidence level';
    }
  }

  void initialize(List<String> statOptions) {
    this.statOptions = statOptions;
  }

  void setDisplayedStat(String newStat) {
    _displayedStat = newStat;
    notifyListeners();
  }

  // Return data needed for dropdown items without Flutter dependencies
  List<StatDisplayItem> get statDisplayItems => statOptions.map((String value) {
        return StatDisplayItem(
          value: value,
          displayName: getDisplayNameForStat(value),
        );
      }).toList();

  String getDisplayNameForStat(String stat) {
    switch (stat) {
      case 'confidenceLevel':
        return 'Confidence level';
      case 'difficultyRating':
        return 'Difficulty';
      case 'consistencyFactor':
        return 'Consistency';
      case 'completions':
        return 'Completions';
      default:
        return 'Confidence level';
    }
  }
}

// Pure Dart class for dropdown item data
class StatDisplayItem {
  final String value;
  final String displayName;

  StatDisplayItem({
    required this.value,
    required this.displayName,
  });
}
