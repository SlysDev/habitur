import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'network_indicator_model.dart';

class NetworkIndicator extends StackedView<NetworkIndicatorModel> {
  const NetworkIndicator({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    NetworkIndicatorModel viewModel,
    Widget? child,
  ) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutSine,
      opacity: viewModel.isConnected ? 0.0 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutSine,
        height: false ? 0 : 20,
        padding: const EdgeInsets.all(8),
        child: const Icon(
          Icons.cloud_off_rounded,
          color: Colors.white54,
          size: 20,
        ),
      ),
    );
  }

  @override
  NetworkIndicatorModel viewModelBuilder(BuildContext context) =>
      NetworkIndicatorModel();
}
