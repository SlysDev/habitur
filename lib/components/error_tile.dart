import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

class ErrorTile extends StatelessWidget {
  String errorText;
  Color color;
  ErrorTile({required this.errorText, this.color = kRed});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.error,
        color: color,
      ),
      title: Text(
        errorText,
        style: kErrorTextStyle.copyWith(color: color),
      ),
    );
  }
}
