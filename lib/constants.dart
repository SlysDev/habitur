import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitur/models/setting.dart';
import 'package:habitur/models/time_model.dart';

// Colors
const kBackgroundColor = Color.fromRGBO(13, 22, 33, 1);
const kFadedBlue = Color.fromRGBO(26, 44, 66, 1);
const kDarkGray = Color.fromRGBO(62, 83, 103, 1);
const kGray = Color.fromRGBO(128, 153, 178, 1);
const kLightRedAccent = Color.fromRGBO(209, 102, 102, 1);
const kPrimaryColor = Color.fromRGBO(136, 191, 252, 1);
const kDarkPrimaryColor = Color.fromRGBO(4, 73, 149, 1);
const kLightPrimaryColor = Color.fromRGBO(176, 212, 253, 1);
const kFadedGreen = Color.fromRGBO(98, 150, 119, 1);
const kOrangeAccent = Color.fromRGBO(252, 161, 125, 1);
const kLightGreenAccent = Color.fromRGBO(129, 193, 151, 1);
const kFadedRed = Color.fromRGBO(209, 102, 102, 0.7);
// Text Style
const kSubHeadingTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: kPrimaryColor,
);

const kHeadingTextStyle = TextStyle(
  fontSize: 26,
  fontWeight: FontWeight.bold,
  color: kPrimaryColor,
);

const kTitleTextStyle = TextStyle(
  fontSize: 42,
  fontWeight: FontWeight.bold,
  color: kPrimaryColor,
);

const kErrorTextStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
  color: Colors.red,
);

const kCtaBtnStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
);

const TextStyle kMainDescription =
    TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white);

const TextStyle kSubDescription = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w300,
  color: kGray,
);

Map<int, Color> colorCodes = {
  50: const Color.fromRGBO(1, 23, 47, .1),
  100: const Color.fromRGBO(1, 23, 47, .2),
  200: const Color.fromRGBO(1, 23, 47, .3),
  300: const Color.fromRGBO(1, 23, 47, .4),
  400: const Color.fromRGBO(1, 23, 47, .5),
  500: const Color.fromRGBO(1, 23, 47, .6),
  600: const Color.fromRGBO(1, 23, 47, .7),
  700: const Color.fromRGBO(1, 23, 47, .8),
  800: const Color.fromRGBO(1, 23, 47, .9),
  900: const Color.fromRGBO(1, 23, 47, 1),
};

MaterialColor kMaterialDarkBlueColor = MaterialColor(0xff01147f, colorCodes);

// Logos
Image kHabiturLogo = Image.asset('assets/images/logo.png');

// Settings

List<SettingModel> kDefaultSettings = [
  SettingModel(settingValue: true, settingName: 'Daily Reminders'),
  SettingModel(settingValue: 3, settingName: 'Number of Reminders'),
  SettingModel(
      settingValue: const TimeModel(hour: 10, minute: 0),
      settingName: '1st Reminder Time'),
  SettingModel(
      settingValue: const TimeModel(hour: 16, minute: 0),
      settingName: '2nd Reminder Time'),
  SettingModel(
      settingValue: const TimeModel(hour: 22, minute: 0),
      settingName: '3rd Reminder Time'),
];

const InputDecoration kTextFieldDecoration = InputDecoration(
  hintStyle: TextStyle(color: kGray, fontSize: 16),
  contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
  filled: true,
  fillColor: Color(0xFF1E2938),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
    borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
    borderSide: BorderSide(color: Color(0xFF2A3747), width: 1.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
    borderSide: BorderSide(color: kPrimaryColor, width: 2.0),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
    borderSide: BorderSide(color: Color(0xFFE57373), width: 1.0),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
    borderSide: BorderSide(color: Color(0xFFEF5350), width: 2.0),
  ),
  isDense: true,
  hintMaxLines: 1,
  alignLabelWithHint: true,
);

InputDecoration kFilledTextFieldInputDecoration = InputDecoration(
  filled: true,
  fillColor: kFadedBlue,
  contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.transparent),
    borderRadius: BorderRadius.circular(30),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.transparent),
    borderRadius: BorderRadius.circular(30),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.transparent),
    borderRadius: BorderRadius.circular(30),
  ),
  hintText: 'Enter your email',
  hintStyle: TextStyle(
    color: Colors.white.withOpacity(0.5),
  ),
);
