import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

class ToggleButton extends StatefulWidget {
  final bool isToggled;
  final ValueChanged<bool> onToggle;
  final String text;

  const ToggleButton(
      {Key? key,
      required this.isToggled,
      required this.onToggle,
      required this.text})
      : super(key: key);

  @override
  _ToggleButtonState createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  late bool toggled;

  @override
  void initState() {
    super.initState();
    toggled = widget.isToggled;
  }

  void _handleToggle() {
    setState(() {
      toggled = !toggled;
    });
    widget.onToggle(toggled);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 120,
        height: 40,
        decoration: BoxDecoration(
          color: toggled ? const Color(0xFF81c197) : const Color(0xFF1a2c42),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3), // shadow offset
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          widget.text,
          style: TextStyle(
            color: toggled
                ? Color(0xFF0d1621)
                : kGray, // Text color to contrast the background
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
