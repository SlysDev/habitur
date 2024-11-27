import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

enum StatusType {
  loading,
  success,
  error,
}

class StatusCardModel extends BaseViewModel {
  StatusType _status = StatusType.loading;
  String _message = "Loading...";
  VoidCallback? _onDismiss;

  StatusType get status => _status;
  String get message => _message;
  VoidCallback? get onDismiss => _onDismiss;

  // Setters
  set status(StatusType newStatus) {
    _status = newStatus;
    rebuildUi(); // Trigger UI rebuild
  }

  set message(String newMessage) {
    _message = newMessage;
    rebuildUi(); // Trigger UI rebuild
  }

  set onDismiss(VoidCallback? callback) {
    _onDismiss = callback;
    rebuildUi(); // Trigger UI rebuild
  }

  // Color and icon based on status
  Color getStatusColor() {
    switch (_status) {
      case StatusType.loading:
        return Colors.grey;
      case StatusType.success:
        return Colors.green;
      case StatusType.error:
        return Colors.red;
    }
  }

  IconData getStatusIcon() {
    switch (_status) {
      case StatusType.loading:
        return Icons.hourglass_empty;
      case StatusType.success:
        return Icons.check_circle_outline;
      case StatusType.error:
        return Icons.error_outline;
    }
  }
}
