// change_bubble.dart
import 'package:flutter/material.dart';

class ChangeBubble extends StatelessWidget {
  final int changeAmount;
  final bool isPositive;
  final double scale;

  const ChangeBubble({
    super.key,
    required this.changeAmount,
    required this.isPositive,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSignificant = changeAmount.abs() >= 30;
    
    // For significant changes, only scale changes
    final double bubbleSize = isSignificant 
        ? 15 + (scale * 6) 
        : 15 + (scale * 3); 

    return Container(
      margin: const EdgeInsets.only(bottom: 8), // Space between bubble and progress bar
      child: Transform.scale(
        scale: 1.0, // Remove the additional scale transform
        child: Container(
          width: bubbleSize,
          height: bubbleSize,
          decoration: BoxDecoration(
            color: isPositive ? Colors.green : Colors.red,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (isPositive ? Colors.green : Colors.red).withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}