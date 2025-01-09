import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'status_card_model.dart';

class StatusCard extends StackedView<StatusCardModel> {
  final String message;
  final StatusType status;
  final VoidCallback? onDismiss;

  const StatusCard({
    Key? key,
    required this.message,
    required this.status,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    StatusCardModel viewModel,
    Widget? child,
  ) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: viewModel.getStatusColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: viewModel.getStatusColor().withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              viewModel.getStatusIcon(),
              color: viewModel.getStatusColor(),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                viewModel.message,
                style: TextStyle(
                  color: viewModel.getStatusColor() == Colors.grey
                      ? Colors.white
                      : viewModel.getStatusColor(),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  StatusCardModel viewModelBuilder(
    BuildContext context,
  ) =>
      StatusCardModel();
}
