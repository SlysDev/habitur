import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:habitur/components/accent_elevated_button.dart';
import 'package:habitur/components/aside_button.dart';
import 'package:habitur/components/custom_alert_dialog.dart';
import 'package:habitur/components/filled_text_field.dart';
import 'package:habitur/components/inactive_elevated_button.dart';
import 'package:habitur/components/navbar.dart';
import 'package:habitur/components/network_indicator.dart';
import 'package:habitur/components/primary-button.dart';
import 'package:habitur/components/static_card.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/data/local/habits_local_storage.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/models/setting.dart';
import 'package:habitur/models/time_model.dart';
import 'package:habitur/notifications/notification_manager.dart';
import 'package:habitur/notifications/notification_scheduler.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/providers/network_state_provider.dart';
import 'package:habitur/screens/login_screen.dart';
import 'package:habitur/screens/splash_screen.dart';
import 'package:habitur/screens/welcome_screen.dart';
import 'package:habitur/data/local/settings_local_storage.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double gap = 20.0;
  bool isVerifyingEmail = false;
  bool hasUpdatedUsername = false;
  bool hasFailed = false;

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    SettingsLocalStorage settingsData =
        Provider.of<SettingsLocalStorage>(context, listen: false);
    Database db = Database();
    String email = Provider.of<UserLocalStorage>(context).currentUser.email;
    String username =
        Provider.of<UserLocalStorage>(context).currentUser.username;
    return Scaffold(
      body: FutureBuilder(
        future: settingsData.init(),
        builder: (context, snapshot) {
          Setting dailyReminders =
              Provider.of<SettingsLocalStorage>(context).dailyReminders;
          Setting numReminders =
              Provider.of<SettingsLocalStorage>(context).numberOfReminders;
          Setting firstReminderTime =
              settingsData.getSettingByName('1st Reminder Time');
          Setting secondReminderTime =
              settingsData.getSettingByName('2nd Reminder Time');
          Setting thirdReminderTime =
              settingsData.getSettingByName('3rd Reminder Time');
          return Container(
            margin: EdgeInsets.all(20),
            child: ListView(
              children: [
                Center(
                  child: Text(
                    'Reminders',
                    style: kHeadingTextStyle,
                  ),
                ),
                SizedBox(height: gap),
                StaticCard(
                  child: Provider.of<HabitManager>(context).habits.isEmpty
                      ? Center(
                          child: Text(
                            "You don't have any habits yet!",
                            style:
                                kMainDescription.copyWith(color: Colors.white),
                          ),
                        )
                      : Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  bottom:
                                      dailyReminders.settingValue ? gap : 0),
                              child: SwitchListTile(
                                activeColor: Colors.white,
                                activeTrackColor: kLightPrimaryColor,
                                inactiveTrackColor: kFadedBlue,
                                inactiveThumbColor: Colors.white,
                                visualDensity:
                                    VisualDensity.adaptivePlatformDensity,
                                value: settingsData
                                    .getSettingByName(
                                        dailyReminders.settingName)
                                    .settingValue,
                                selected: dailyReminders.settingValue,
                                title: Text(
                                  dailyReminders.settingName,
                                  style: kMainDescription.copyWith(
                                      color: Colors.white),
                                ),
                                onChanged: (newValue) async {
                                  NotificationManager notificationManager =
                                      NotificationManager();
                                  await settingsData.updateSetting(
                                      dailyReminders.settingName, newValue);
                                  await db.settingsDatabase.updateSetting(
                                      dailyReminders.settingName, newValue);
                                  settingsData.updateSettings();
                                  notificationManager
                                      .cancelAllScheduledNotifications();
                                  if (newValue) {
                                    NotificationScheduler
                                        notificationScheduler =
                                        NotificationScheduler();
                                    await notificationScheduler
                                        .scheduleDefaultTrack(
                                            context,
                                            settingsData.numberOfReminders
                                                .settingValue);
                                  }
                                  notificationManager.printNotifications();
                                },
                              ),
                            ),
                            dailyReminders.settingValue
                                ? Container(
                                    margin: EdgeInsets.only(bottom: gap),
                                    child: ListTile(
                                      title: Text(
                                        numReminders.settingName,
                                        style: kMainDescription.copyWith(
                                            color: Colors.white),
                                      ),
                                      trailing: DropdownButton(
                                          onChanged: (value) async {
                                            NotificationManager
                                                notificationManager =
                                                NotificationManager();
                                            NotificationScheduler
                                                notificationScheduler =
                                                NotificationScheduler();
                                            await settingsData.updateSetting(
                                                numReminders.settingName,
                                                value);
                                            await db.settingsDatabase
                                                .updateSetting(
                                                    numReminders.settingName,
                                                    value);
                                            settingsData.updateSettings();
                                            await notificationManager
                                                .cancelAllScheduledNotifications();
                                            await notificationScheduler
                                                .scheduleDefaultTrack(
                                                    context,
                                                    settingsData
                                                        .numberOfReminders
                                                        .settingValue);
                                          },
                                          value: numReminders.settingValue,
                                          items: [
                                            DropdownMenuItem(
                                              value: 1,
                                              child: Text('1',
                                                  style:
                                                      kMainDescription.copyWith(
                                                          color: Colors.white)),
                                            ),
                                            DropdownMenuItem(
                                              value: 2,
                                              child: Text('2',
                                                  style:
                                                      kMainDescription.copyWith(
                                                          color: Colors.white)),
                                            ),
                                            DropdownMenuItem(
                                              value: 3,
                                              child: Text('3',
                                                  style:
                                                      kMainDescription.copyWith(
                                                          color: Colors.white)),
                                            ),
                                          ]),
                                    ),
                                  )
                                : Container(),
                            dailyReminders.settingValue
                                ? Container(
                                    margin: EdgeInsets.only(bottom: gap),
                                    child: TimeSettingsListTile(
                                        timeSetting: firstReminderTime),
                                  )
                                : Container(),
                            dailyReminders.settingValue &&
                                    numReminders.settingValue > 1
                                ? Container(
                                    margin: EdgeInsets.only(bottom: gap),
                                    child: TimeSettingsListTile(
                                        timeSetting: secondReminderTime),
                                  )
                                : Container(),
                            dailyReminders.settingValue &&
                                    numReminders.settingValue > 2
                                ? Container(
                                    margin: EdgeInsets.only(bottom: gap),
                                    child: TimeSettingsListTile(
                                        timeSetting: thirdReminderTime),
                                  )
                                : Container(),
                          ],
                        ),
                ),
                SizedBox(height: 40),
                Center(
                  child: Text(
                    'Profile',
                    style: kHeadingTextStyle,
                  ),
                ),
                SizedBox(height: gap),
                StaticCard(
                  child: Column(
                    children: [
                      !Provider.of<NetworkStateProvider>(context, listen: false)
                              .isConnected
                          ? SizedBox(height: 10)
                          : Container(),
                      const NetworkIndicator(),
                      !Provider.of<NetworkStateProvider>(context, listen: false)
                              .isConnected
                          ? SizedBox(height: 25)
                          : Container(),
                      ListTile(
                        title: Text(
                          'Username',
                          style: kMainDescription.copyWith(color: Colors.white),
                        ),
                        trailing: Container(
                          width: 200,
                          child: FilledTextField(
                            enabled: auth.currentUser == null ||
                                Provider.of<NetworkStateProvider>(context,
                                        listen: true)
                                    .isConnected,
                            hintText: 'Username',
                            initialValue: Provider.of<UserLocalStorage>(context)
                                .currentUser
                                .username,
                            onChanged: (newValue) {
                              username = newValue;
                            },
                          ),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Email',
                          style: kMainDescription.copyWith(color: Colors.white),
                        ),
                        trailing: Container(
                          width: 200,
                          child: FilledTextField(
                            enabled: Provider.of<NetworkStateProvider>(context,
                                    listen: true)
                                .isConnected,
                            hintText: 'Email',
                            initialValue: Provider.of<UserLocalStorage>(context)
                                .currentUser
                                .email,
                            onChanged: (newValue) {
                              email = newValue;
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 800),
                        height: isVerifyingEmail ? 52 : 0,
                        curve: Curves.easeInOutSine,
                        child: Center(
                          child: AnimatedOpacity(
                            duration: Duration(milliseconds: 800),
                            opacity: isVerifyingEmail ? 1 : 0,
                            curve: Curves.easeInOutSine,
                            child: Text(
                              'A verification email has been sent to $email',
                              style: kMainDescription.copyWith(
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 800),
                        height:
                            hasUpdatedUsername && !isVerifyingEmail ? 40 : 0,
                        curve: Curves.ease,
                        child: Center(
                          child: AnimatedOpacity(
                            duration: Duration(milliseconds: 800),
                            opacity:
                                hasUpdatedUsername && !isVerifyingEmail ? 1 : 0,
                            curve: Curves.ease,
                            child: Text(
                              'Username updated!',
                              style: kMainDescription.copyWith(
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 800),
                        height: hasFailed &&
                                !Provider.of<NetworkStateProvider>(context)
                                    .isConnected
                            ? 70
                            : hasFailed
                                ? 40
                                : 0,
                        curve: Curves.ease,
                        child: Center(
                          child: AnimatedOpacity(
                            duration: Duration(milliseconds: 800),
                            opacity: hasFailed ? 1 : 0,
                            curve: Curves.ease,
                            child: Text(
                              'Failed to upload new profile online.' +
                                  (!Provider.of<NetworkStateProvider>(context)
                                          .isConnected
                                      ? ' Looks like you\'re offline.'
                                      : ''),
                              style: kMainDescription.copyWith(
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      auth.currentUser == null ||
                              Provider.of<NetworkStateProvider>(context,
                                      listen: true)
                                  .isConnected
                          ? PrimaryButton(
                              text: 'Update Profile',
                              onPressed: () async {
                                if (email !=
                                    Provider.of<UserLocalStorage>(context,
                                            listen: false)
                                        .currentUser
                                        .email) {
                                  try {
                                    Provider.of<UserLocalStorage>(context,
                                            listen: false)
                                        .updateUserProperty('email', email);
                                    auth.currentUser!
                                        .verifyBeforeUpdateEmail(email);
                                    db.userDatabase.uploadUserData(context);
                                    Provider.of<NetworkStateProvider>(context,
                                            listen: false)
                                        .isConnected = true;
                                    setState(() {
                                      isVerifyingEmail = true;
                                    });
                                    Future.delayed(Duration(seconds: 5), () {
                                      setState(() {
                                        isVerifyingEmail = false;
                                      });
                                    });
                                  } catch (e) {
                                    Provider.of<NetworkStateProvider>(context,
                                            listen: false)
                                        .isConnected = false;
                                    setState(() {
                                      hasFailed = true;
                                    });
                                    Future.delayed(Duration(seconds: 5), () {
                                      setState(() {
                                        hasFailed = false;
                                      });
                                    });
                                  }
                                }
                                if (username !=
                                    Provider.of<UserLocalStorage>(context,
                                            listen: false)
                                        .currentUser
                                        .username) {
                                  try {
                                    Provider.of<UserLocalStorage>(context,
                                            listen: false)
                                        .updateUserProperty(
                                            'username', username);
                                    if (auth.currentUser != null) {
                                      auth.currentUser!
                                          .updateDisplayName(username);
                                      db.userDatabase.uploadUserData(context);
                                      Provider.of<NetworkStateProvider>(context,
                                              listen: false)
                                          .isConnected = true;
                                    }
                                    setState(() {
                                      hasUpdatedUsername = true;
                                    });
                                    Future.delayed(Duration(seconds: 5), () {
                                      setState(() {
                                        hasUpdatedUsername = false;
                                      });
                                    });
                                  } catch (e) {
                                    Provider.of<NetworkStateProvider>(context,
                                            listen: false)
                                        .isConnected = false;
                                    setState(() {
                                      hasFailed = true;
                                    });
                                    Future.delayed(Duration(seconds: 5), () {
                                      setState(() {
                                        hasFailed = false;
                                      });
                                    });
                                  }
                                }
                                Provider.of<UserLocalStorage>(context,
                                        listen: false)
                                    .saveData();
                              },
                            )
                          : InactiveElevatedButton(
                              child: Text('Update Profile')),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          db.userDatabase.isLoggedIn
                              ? AsideButton(
                                  text: 'Log out',
                                  onPressed: () async {
                                    late final _auth = FirebaseAuth.instance;
                                    await _auth.signOut();
                                    Provider.of<UserLocalStorage>(context,
                                            listen: false)
                                        .updateUserProperty('email', 'N/A');
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                WelcomeScreen()),
                                        (route) => false);
                                    Navigator.popAndPushNamed(
                                        context, 'welcome_screen');
                                  })
                              : AsideButton(
                                  text: 'Log in',
                                  onPressed: () async {
                                    late final _auth = FirebaseAuth.instance;
                                    await _auth.signOut();
                                    Navigator.pushNamed(
                                        context, 'login_screen');
                                  }),
                          AsideButton(
                              text: 'Delete Account',
                              onPressed: () async {
                                late final _auth = FirebaseAuth.instance;
                                await _auth.currentUser!.delete();
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => WelcomeScreen()),
                                    (route) => false);
                                Navigator.popAndPushNamed(
                                    context, 'welcome_screen');
                              }),
                          AsideButton(
                              text: 'Clear Data',
                              onPressed: () async {
                                dynamic result = await showDialog(
                                  context: context,
                                  builder: (context) => CustomAlertDialog(
                                    title: 'Warning',
                                    content: Text(
                                        'Are you sure you want to clear all account data (habits, stats, etc.)? This cannot be undone.'),
                                    actions: [
                                      AsideButton(
                                          onPressed: () {
                                            Navigator.pop(context, true);
                                          },
                                          text: 'Yes'),
                                      SizedBox(width: 10),
                                      AsideButton(
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          },
                                          text: 'No'),
                                    ],
                                  ),
                                );
                                result == null ? result = false : null;
                                if (result) {
                                  await Provider.of<HabitsLocalStorage>(context,
                                          listen: false)
                                      .deleteData();
                                  Provider.of<UserLocalStorage>(context,
                                          listen: false)
                                      .clearStats();
                                  await Provider.of<SettingsLocalStorage>(
                                          context,
                                          listen: false)
                                      .populateDefaultSettingsData();
                                  Provider.of<SettingsLocalStorage>(context,
                                          listen: false)
                                      .updateSettings();
                                  db.settingsDatabase
                                      .populateDefaultSettingsData();
                                  if (db.userDatabase.isLoggedIn) {
                                    await db.habitDatabase.clearHabits(context);
                                    await db.statsDatabase
                                        .clearStatistics(context);
                                  }
                                }
                              }),
                        ],
                      ),
                      Provider.of<UserLocalStorage>(context, listen: false)
                              .currentUser
                              .isAdmin
                          ? AsideButton(
                              text: 'Admin Panel',
                              onPressed: () {
                                Navigator.popAndPushNamed(
                                    context, 'admin_screen');
                              })
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: NavBar(
        currentPage: 'settings',
      ),
    );
  }
}

class TimeSettingsListTile extends StatelessWidget {
  Setting timeSetting;
  TimeSettingsListTile({super.key, required this.timeSetting});

  @override
  Widget build(BuildContext context) {
    SettingsLocalStorage settingsData =
        Provider.of<SettingsLocalStorage>(context);
    Database db = Database();
    return ListTile(
      title: Text(
        timeSetting.settingName,
        style: kMainDescription.copyWith(color: Colors.white),
      ),
      trailing: GestureDetector(
        onTap: () async {
          NotificationManager notificationManager = NotificationManager();
          NotificationScheduler notificationScheduler = NotificationScheduler();
          TimeOfDay? newTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(
                  hour: timeSetting.settingValue.hour,
                  minute: timeSetting.settingValue.minute));
          TimeModel newTimeFormatted = newTime == null
              ? timeSetting.settingValue
              : TimeModel(hour: newTime.hour, minute: newTime.minute);
          await settingsData.updateSetting(
              timeSetting.settingName, newTimeFormatted);
          await db.settingsDatabase
              .updateSetting(timeSetting.settingName, newTimeFormatted);

          await notificationManager.cancelAllScheduledNotifications();
          await notificationScheduler.scheduleDefaultTrack(
              context, settingsData.numberOfReminders.settingValue);
          settingsData.updateSettings();
        },
        child: StaticCard(
          child: Text(
              '${timeSetting.settingValue.hour}:${timeSetting.settingValue.minute > 9 ? timeSetting.settingValue.minute.toString() : '0' + timeSetting.settingValue.minute.toString()}',
              // basically just nicely displays the time
              style:
                  kMainDescription.copyWith(color: Colors.white, fontSize: 14)),
        ),
      ),
    );
  }
}
