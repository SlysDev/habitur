import 'package:flutter/material.dart';

const kHeadingTextStyle = TextStyle(
  fontSize: 26,
  fontWeight: FontWeight.bold,
  color: kDarkBlueColor,
);

const kTitleTextStyle = TextStyle(
  fontSize: 36,
  fontWeight: FontWeight.bold,
  color: kDarkBlueColor,
);

const kErrorTextStyle = TextStyle(
  fontSize: 36,
  fontWeight: FontWeight.bold,
  color: kDarkBlueColor,
);

const kDarkBlueColor = Color.fromRGBO(1, 23, 47, 1);
const kLightAccent = Color.fromRGBO(108, 121, 135, 1);
const kTurqoiseAccent = Color.fromRGBO(0, 45, 45, 1);
const kBeige = Color.fromRGBO(226, 232, 206, 1);

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
  fillColor: kLightAccent,
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
