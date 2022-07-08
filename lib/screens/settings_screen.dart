import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import '../providers/settings_data.dart';
import 'package:provider/provider.dart';
import '../models/setting.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsData>(
      builder: (context, settingsData, child) {
        return Scaffold(
          body: ListView.builder(
            itemCount: settingsData.settingsList.length,
            itemBuilder: (BuildContext context, index) {
              return SwitchListTile(
                activeColor: kSlateGray,
                activeTrackColor: kDarkBlue,
                inactiveTrackColor: kSlateGray,
                inactiveThumbColor: Colors.white,
                visualDensity: VisualDensity.comfortable,
                value: settingsData.settingsList[index].settingValue,
                selected: settingsData.settingsList[index].settingValue,
                title: Text(
                  settingsData.settingsList[index].settingName,
                ),
                onChanged: (newValue) {
                  settingsData.settingsList[index].settingValue = newValue;
                  settingsData.updateSettings();
                },
              );
            },
          ),
        );
      },
    );
  }
}
