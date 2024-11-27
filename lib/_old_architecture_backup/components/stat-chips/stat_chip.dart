import 'package:flutter/material.dart';

class StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double? size;

  StatChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.size = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final scale = size ?? 1.0;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8 * scale,
        vertical: 4 * scale,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8 * scale),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16 * scale,
            color: color,
          ),
          SizedBox(width: 4 * scale),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
