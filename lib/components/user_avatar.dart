import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String username;
  final double size;

  const UserAvatar({
    Key? key,
    required this.username,
    this.size = 40.0,
  }) : super(key: key);

  Color _generateColorFromString(String str) {
    // Generate a consistent color for the same username
    int hash = str.codeUnits.fold(0, (prev, curr) => prev + curr);
    // Use predefined material colors for better aesthetics
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.red,
      Colors.cyan,
      Colors.amber,
    ];
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final String initial = username.isNotEmpty ? username[0].toUpperCase() : '?';
    final Color backgroundColor = _generateColorFromString(username);
    
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
