import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

showErrorSnackbar(BuildContext context, e, s) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: Duration(seconds: 5),
      backgroundColor: kOrangeAccent,
      content: Text(
          'Error--Take a screenshot and send to our team: \n \n ${e.toString()}, $s'),
    ),
  );
}
