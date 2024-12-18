import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:habitur/ui/widgets/modern_card.dart';

class SmartNotificationsToggle extends StatelessWidget {
  const SmartNotificationsToggle({
    super.key,
    required this.smartNotificationsEnabled,
    required this.onSmartNotificationsChanged,
  });

  final bool smartNotificationsEnabled;
  final ValueChanged<bool> onSmartNotificationsChanged;

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      color: kFadedGreen,
      opacity: 0.1,
      padding: 10,
      child: SwitchListTile.adaptive(
        title: Row(
          children: [
            Icon(
              Icons.bolt,
              color: kLightGreenAccent,
              size: 30,
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: Text(
                  screenWidth(context) > 400
                      ? 'Smart Notifications'
                      : 'Smart \n Notifications',
                  textAlign: TextAlign.center,
                  style: kMainDescription.copyWith(fontSize: 16)),
            ),
          ],
        ),
        onChanged: onSmartNotificationsChanged,
        value: smartNotificationsEnabled,
      ),
    );
  }
}
