import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

// Custom SnackBar widget
class CustomSnackBar extends StatelessWidget {
  final Color color;
  final String text;
  final String? actionLabel; // Optional action label
  final VoidCallback? onActionPressed; // Optional action callback
  final Duration duration;

  const CustomSnackBar({
    Key? key,
    required this.color,
    required this.text,
    this.actionLabel,
    this.onActionPressed,
    this.duration = const Duration(seconds: 4), // Default duration
  }) : super(key: key);

  // Function to show the SnackBar
  void show(BuildContext context) {
    final snackBar = SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.white), // Text color
            ),
          ),
          if (actionLabel != null && onActionPressed != null)
            TextButton(
              onPressed: () {
                if (onActionPressed != null) {
                  onActionPressed!(); // Call the action callback
                }
                ScaffoldMessenger.of(context)
                    .hideCurrentSnackBar(); // Dismiss the SnackBar
              },
              child: Text(
                actionLabel!,
                style: TextStyle(color: Colors.white), // Button text color
              ),
            ),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.fromLTRB(16, 0, 16, 20),
      duration: duration,
    );

    // Show the custom SnackBar using ScaffoldMessenger
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    // Return a GestureDetector to handle the display of the SnackBar
    return GestureDetector(
      onTap: () => show(context), // Show the SnackBar when tapped
      child: Container(
        height: 0, // Placeholder to create a tappable area
      ),
    );
  }
}

// Usage Example
void showCustomSnackBar(BuildContext context, String text, Color color) {
  CustomSnackBar(
    color: color, // Replace with your color variable
    text: text,
    actionLabel: 'Dismiss',
    onActionPressed: () {
      // Additional action logic if needed
    },
  ).show(context); // Show the SnackBar
}
