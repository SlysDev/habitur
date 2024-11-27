import 'package:stacked/stacked.dart';

import '../../../app/app.locator.dart';
import '../../../models/stat_point.dart';
import '../../../services/insight_generator_service.dart';

class InsightDisplayModel extends BaseViewModel {
  final _insightGeneratorService = locator<InsightGeneratorService>();
  late List<StatPoint> stats;
  late Map<String, dynamic> _improvementData;
  late String _insightPreText;
  late String _insightPercentChange;
  late String _insightPostText;

  get insightPreText => _insightPreText;
  get insightPercentChange => _insightPercentChange;
  get insightPostText => _insightPostText;

  void initialize(List<StatPoint> stats, bool isSummary) {
    this.stats = stats;
    _improvementData = _insightGeneratorService.findAreaForImprovement(stats,
        isSummary: isSummary);

    _insightPreText = _improvementData['message']['preText'];
    _insightPercentChange =
        _improvementData['message']['percentChange'].toString();
    _insightPostText = _improvementData['message']['postText'];

    if (stats.isEmpty) {
      _insightPreText =
          'Looks like you haven\'t logged any stats yet! Complete your first habit to get started.';
      _insightPercentChange = '';
      _insightPostText = '';
    }
    notifyListeners();
  }
}
