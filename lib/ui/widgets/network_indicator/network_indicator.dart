import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:stacked/stacked.dart';

import 'network_indicator_model.dart';

class NetworkIndicator extends StackedView<NetworkIndicatorModel> {
  const NetworkIndicator({super.key});

  @override
  Widget builder(
    BuildContext context,
    NetworkIndicatorModel viewModel,
    Widget? child,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: 32,
      decoration: BoxDecoration(
        color: viewModel.isConnected
            ? kFadedGreen.withOpacity(0.15)
            : kLightRedAccent.withOpacity(0.15),
        border: Border(
          bottom: BorderSide(
            color: viewModel.isConnected
                ? kFadedGreen.withOpacity(0.3)
                : kLightRedAccent.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              viewModel.isConnected
                  ? Icons.wifi_rounded
                  : Icons.wifi_off_rounded,
              key: ValueKey(viewModel.isConnected),
              size: 16,
              color: viewModel.isConnected ? kFadedGreen : kLightRedAccent,
            ),
          ),
          const SizedBox(width: 8),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: viewModel.isConnected ? kFadedGreen : kLightRedAccent,
            ),
            child: Text(
              viewModel.isConnected ? 'Connected' : 'No Connection',
            ),
          ),
        ],
      ),
    );
  }

  @override
  NetworkIndicatorModel viewModelBuilder(
    BuildContext context,
  ) =>
      NetworkIndicatorModel();
}
