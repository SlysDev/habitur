import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'heat_map_model.dart';

class HeatMap extends StackedView<HeatMapModel> {
  const HeatMap({super.key});

  @override
  Widget builder(
    BuildContext context,
    HeatMapModel viewModel,
    Widget? child,
  ) {
    return const SizedBox.shrink();
  }

  @override
  HeatMapModel viewModelBuilder(
    BuildContext context,
  ) =>
      HeatMapModel();
}
