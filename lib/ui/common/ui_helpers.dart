import 'dart:math';

import 'package:flutter/material.dart';

// old stacked defaults

const double _tinySize = 5.0;
const double _smallSize = 10.0;
const double _mediumSize = 25.0;
const double _largeSize = 50.0;
const double _massiveSize = 120.0;

const Widget horizontalSpaceTiny = SizedBox(width: _tinySize);
const Widget horizontalSpaceSmall = SizedBox(width: _smallSize);
const Widget horizontalSpaceMedium = SizedBox(width: _mediumSize);
const Widget horizontalSpaceLarge = SizedBox(width: _largeSize);

const Widget verticalSpaceTiny = SizedBox(height: _tinySize);
const Widget verticalSpaceSmall = SizedBox(height: _smallSize);
const Widget verticalSpaceMedium = SizedBox(height: _mediumSize);
const Widget verticalSpaceLarge = SizedBox(height: _largeSize);
const Widget verticalSpaceMassive = SizedBox(height: _massiveSize);

Widget spacedDivider = const Column(
  children: <Widget>[
    verticalSpaceMedium,
    Divider(color: Colors.blueGrey, height: 5.0),
    verticalSpaceMedium,
  ],
);

Widget verticalSpace(double height) => SizedBox(height: height);

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

double screenHeightFraction(BuildContext context,
        {int dividedBy = 1, double offsetBy = 0, double max = 3000}) =>
    min((screenHeight(context) - offsetBy) / dividedBy, max);

double screenWidthFraction(BuildContext context,
        {int dividedBy = 1, double offsetBy = 0, double max = 3000}) =>
    min((screenWidth(context) - offsetBy) / dividedBy, max);

double halfScreenWidth(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 2);

double thirdScreenWidth(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 3);

double quarterScreenWidth(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 4);

double getResponsiveHorizontalSpaceMedium(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 10);
double getResponsiveSmallFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 14, max: 15);

double getResponsiveMediumFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 16, max: 17);

double getResponsiveLargeFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 21, max: 31);

double getResponsiveExtraLargeFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 25);

double getResponsiveMassiveFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 30);

double getResponsiveFontSize(BuildContext context,
    {double? fontSize, double? max}) {
  max ??= 100;

  var responsiveSize = min(
      screenWidthFraction(context, dividedBy: 10) * ((fontSize ?? 100) / 100),
      max);

  return responsiveSize;
}

// new Habitur defaults

// Vertical Spacing
const Widget verticalSpaceTinyNew = SizedBox(height: 4);
const Widget verticalSpaceSmallNew = SizedBox(height: 8);
const Widget verticalSpaceMediumNew = SizedBox(height: 16);
const Widget verticalSpaceLargeNew = SizedBox(height: 24);
const Widget verticalSpaceXLargeNew = SizedBox(height: 32);
const Widget verticalSpaceXXLargeNew = SizedBox(height: 48);

// Horizontal Spacing
const Widget horizontalSpaceTinyNew = SizedBox(width: 4);
const Widget horizontalSpaceSmallNew = SizedBox(width: 8);
const Widget horizontalSpaceMediumNew = SizedBox(width: 16);
const Widget horizontalSpaceLargeNew = SizedBox(width: 24);
const Widget horizontalSpaceXLargeNew = SizedBox(width: 32);

// Screen Size Helpers
double screenWidthNew(BuildContext context) =>
    MediaQuery.of(context).size.width;
double screenHeightNew(BuildContext context) =>
    MediaQuery.of(context).size.height;

// Padding
const EdgeInsets defaultPadding = EdgeInsets.all(16);
const EdgeInsets defaultHorizontalPadding =
    EdgeInsets.symmetric(horizontal: 16);
const EdgeInsets defaultVerticalPadding = EdgeInsets.symmetric(vertical: 16);

// Border Radius
const double defaultBorderRadius = 12;
BorderRadius defaultRadius = BorderRadius.circular(defaultBorderRadius);
