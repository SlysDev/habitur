import 'package:flutter/material.dart';

class EmptyStatsWidget extends StatelessWidget {
  bool abbreviated;
  EmptyStatsWidget({this.abbreviated = false});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Ensures widget takes up more space
      child: Stack(
        children: [
          Container(
            // Background decoration
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Content fits within
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 80,
                    color: Colors.white,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Looks like this is a new habit!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Check back once you\'ve logged a completion to see your stats!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  abbreviated ? Container() : SizedBox(height: 20),
                  // Inspirational quote
                  abbreviated
                      ? Container()
                      : Text(
                          '"The journey of a thousand miles begins with a single step." - Lao Tzu',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
