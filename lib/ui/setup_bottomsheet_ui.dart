import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import '../app/app.locator.dart';
import '../constants.dart';
import '../enums/bottom_sheet_type.dart';

void setupBottomSheetUi() {
  final bottomSheetService = locator<BottomSheetService>();

  final builders = {
    BottomSheetType.addHabit: (context, request, completer) => Container(
          margin: const EdgeInsets.all(25),
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: kBackgroundColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                request.title ?? 'Add New Habit',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              request.customWidget ?? const SizedBox(),
            ],
          ),
        ),
  };

  bottomSheetService.setCustomSheetBuilders(builders);
}
