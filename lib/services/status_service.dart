import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';

class StatusService {
  final _dialogService = locator<DialogService>();

  Future<T?> executeWithLoading<T>({
    required Future<T> Function() operation,
    String loadingMessage = 'Loading...',
    String successMessage = 'Completed successfully!',
  }) async {
    DialogResponse? loadingDialog;
    try {
      // Show loading dialog
      loadingDialog = await _dialogService.showDialog(
        title: 'Please Wait',
        description: loadingMessage,
        barrierDismissible: false,
      );

      // Execute operation
      final result = await operation();

      // Dismiss loading dialog
      if (loadingDialog != null) {
        _dialogService.completeDialog(
          DialogResponse(confirmed: loadingDialog.confirmed),
        );
      }

      // Show success dialog
      await _dialogService.showDialog(
        title: 'Success',
        description: successMessage,
        buttonTitle: 'OK',
      );

      return result;
    } catch (e) {
      // Dismiss loading dialog if it's showing
      if (loadingDialog != null) {
        _dialogService.completeDialog(
          DialogResponse(confirmed: loadingDialog.confirmed),
        );
      }

      // Show error dialog
      await _dialogService.showDialog(
        title: 'Error',
        description: e.toString(),
        buttonTitle: 'OK',
      );

      return null;
    }
  }
}
