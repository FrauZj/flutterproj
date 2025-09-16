import 'package:flutter/material.dart';

class ResourceIndicator extends StatelessWidget {
  final String title;
  final IconData icon;
  final int value;
  final Color color;

  const ResourceIndicator({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RotatedBox(
          quarterTurns: -1,
          child: SizedBox(
            width: 40,
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.grey[800],
          
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        
        const SizedBox(width: 6),
        Icon(icon, color: color, size: 30),
        // Text(title, style: TextStyle(color: color, fontSize: 12)),
        // Text('$value%', style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}