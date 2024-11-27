import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'leaderboard_card_model.dart';

class LeaderboardCard extends StackedView<LeaderboardCardModel> {
  const LeaderboardCard({super.key});

  @override
  Widget builder(
    BuildContext context,
    LeaderboardCardModel viewModel,
    Widget? child,
  ) {
    return const SizedBox.shrink();
  }

  @override
  LeaderboardCardModel viewModelBuilder(
    BuildContext context,
  ) =>
      LeaderboardCardModel();
}
