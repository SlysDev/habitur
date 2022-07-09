import 'package:flutter/material.dart';

const kHeadingTextStyle = TextStyle(
  fontSize: 26,
  fontWeight: FontWeight.bold,
  color: kDarkBlue,
);

const kTitleTextStyle = TextStyle(
  fontSize: 36,
  fontWeight: FontWeight.bold,
  color: kDarkBlue,
);

const kErrorTextStyle = TextStyle(
  fontSize: 36,
  fontWeight: FontWeight.bold,
  color: kDarkBlue,
);

const kDarkBlue = Color.fromRGBO(1, 23, 47, 1);
const kSlateGray = Color.fromRGBO(108, 121, 135, 1);
const kAoEnglish = Color.fromRGBO(25, 131, 11, 1);
const kBarnRed = Color.fromRGBO(111, 26, 7, 1);
const kNeutralBlue = Color.fromRGBO(51, 70, 89, 1);

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

const kHabiturLogo = Image(
  image: AssetImage('assets/images/logo.png'),
  width: 200,
);

InputDecoration kFilledTextFieldInputDecoration = InputDecoration(
  filled: true,
  fillColor: kSlateGray,
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
  hintStyle: const TextStyle(color: Colors.white),
);
