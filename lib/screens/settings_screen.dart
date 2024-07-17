import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habitur/components/aside_button.dart';
import 'package:habitur/components/navbar.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/providers/user_data.dart';
import 'package:habitur/screens/welcome_screen.dart';
import '../providers/settings_data.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsData>(
      builder: (context, settingsData, child) {
        return Scaffold(
          body: Column(children: [
            SizedBox(
              height: 500,
              child: ListView.builder(
                itemCount: settingsData.settingsList.length,
                itemBuilder: (BuildContext context, index) {
                  return SwitchListTile(
                    activeColor: Colors.white,
                    activeTrackColor: kLightPrimaryColor,
                    inactiveTrackColor: kFadedBlue,
                    inactiveThumbColor: Colors.white,
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                    value: settingsData.settingsList[index].settingValue,
                    selected: settingsData.settingsList[index].settingValue,
                    title: Text(
                      settingsData.settingsList[index].settingName,
                      style: kMainDescription.copyWith(color: Colors.white),
                    ),
                    onChanged: (newValue) {
                      settingsData.settingsList[index].settingValue = newValue;
                      settingsData.updateSettings();
                    },
                  );
                },
              ),
            ),
            AsideButton(
                text: 'Log out',
                onPressed: () {
                  late final _auth = FirebaseAuth.instance;
                  _auth.signOut();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => WelcomeScreen()),
                      (route) => false);
                  Navigator.popAndPushNamed(context, 'welcome_screen');
                }),
            Provider.of<UserData>(context, listen: false).currentUser.isAdmin
                ? AsideButton(
                    text: 'Admin Panel',
                    onPressed: () {
                      Navigator.popAndPushNamed(context, 'admin_screen');
                    })
                : Container(),
          ]),
          bottomNavigationBar: NavBar(
            currentPage: 'settings',
          ),
        );
      },
    );
  }
}
