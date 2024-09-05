import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Colors
const kBackgroundColor = Color.fromRGBO(13, 22, 33, 1);
const kFadedBlue = Color.fromRGBO(26, 44, 66, 1);
const kDarkGray = Color.fromRGBO(62, 83, 103, 1);
const kGray = Color.fromRGBO(128, 153, 178, 1);
const kRed = Color.fromRGBO(209, 102, 102, 1);
const kPrimaryColor = Color.fromRGBO(136, 191, 252, 1);
const kDarkPrimaryColor = Color.fromRGBO(4, 73, 149, 1);
const kLightPrimaryColor = Color.fromRGBO(176, 212, 253, 1);
const kFadedGreen = Color.fromRGBO(98, 150, 119, 1);
const kOrangeAccent = Color.fromRGBO(252, 161, 125, 1);
const kLightGreenAccent = Color.fromRGBO(129, 193, 151, 1);

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

const TextStyle kMainDescription = TextStyle(
  fontSize: 18,
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

const kHabiturLogo = Image(
  image: AssetImage('assets/images/habitur-logo-transparent.png'),
  width: 200,
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
