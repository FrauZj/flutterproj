// resource_indicator.dart
import 'package:flutter/material.dart';

class ResourceIndicator extends StatelessWidget {
  final String title;
  final IconData icon;
  final int value;
  final Color color;
  final bool isHighlighted;
  final Color highlightColor;
  final double highlightIntensity;

  const ResourceIndicator({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.color,
    this.isHighlighted = false,
    this.highlightColor = Colors.transparent,
    this.highlightIntensity = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background highlight effect
        if (isHighlighted)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: highlightColor.withOpacity(0.3 * highlightIntensity),
              shape: BoxShape.circle,
            ),
          ),
        
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RotatedBox(
              quarterTurns: -1,
              child: SizedBox(
                width: 40,
                child: LinearProgressIndicator(
                  value: value / 100,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isHighlighted ? highlightColor : color,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 6),
            Icon(
              icon, 
              color: isHighlighted ? highlightColor : color, 
              size: 30 + (5 * highlightIntensity), // Slight size increase when highlighted
            ),
          ],
        ),
      ],
    );
  }
}