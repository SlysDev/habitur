import 'package:flutter/material.dart';

class StatChangeIndicator extends StatelessWidget {
  final double oldValue;
  final double newValue;

  const StatChangeIndicator({
    Key? key,
    required this.oldValue,
    required this.newValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (oldValue == newValue) {
      return Row(
        children: [
          Icon(Icons.remove, color: Colors.grey, size: 16),
          SizedBox(width: 4),
          Text('', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      );
    }

    final isIncrease = newValue > oldValue;
    
    // Handle case where old value is 0
    final percentChange = oldValue == 0 
        ? null  // Don't show percentage for 0 to non-0 transitions
        : ((newValue - oldValue) / oldValue * 100).abs();
    
    final changeText = percentChange == null 
        ? 'New!' 
        : '${percentChange.toStringAsFixed(1)}%';

    return Row(
      children: [
        Icon(
          isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
          color: isIncrease ? Colors.greenAccent : Colors.redAccent,
          size: 16,
        ),
        SizedBox(width: 4),
        Text(
          changeText,
          style: TextStyle(
            color: isIncrease ? Colors.greenAccent : Colors.redAccent,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
