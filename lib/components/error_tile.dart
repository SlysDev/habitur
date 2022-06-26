import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

class ErrorTile extends StatelessWidget {
  String errorText;
  ErrorTile({required this.errorText});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.error,
        color: Colors.red,
      ),
      title: Text(
        errorText,
        style: kErrorTextStyle,
      ),
    );
  }
}
