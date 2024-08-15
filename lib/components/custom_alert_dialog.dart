import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog(
      {super.key,
      required this.title,
      this.content = const SizedBox(),
      this.actions = const []});
  final String title;
  final Widget content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: Colors.black,
      backgroundColor: kBackgroundColor,
      title: Text(
        title,
        style: kHeadingTextStyle.copyWith(color: Colors.white),
      ),
      content: content,
      actions: actions,
    );
  }
}
