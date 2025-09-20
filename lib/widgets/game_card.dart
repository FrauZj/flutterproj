import 'package:flutter/material.dart';

class GameCard extends StatelessWidget {
  final Map<String, dynamic> cardData;

  const GameCard({
    super.key,
    required this.cardData,
  });


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.help_outline, size: 40, color: Colors.white54),
            const SizedBox(height: 20),
            Text(
              cardData['text'],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 40),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   children: [
            //     Column(
            //       children: [
            //         const Icon(Icons.arrow_back, color: Colors.red),
            //         const SizedBox(height: 8),
            //         Text(
            //           cardData['leftChoice'],
            //           style: const TextStyle(color: Colors.red),
            //         ),
            //       ],
            //     ),
            //     Column(
            //       children: [
            //         const Icon(Icons.arrow_forward, color: Colors.green),
            //         const SizedBox(height: 8),
            //         Text(
            //           cardData['rightChoice'],
            //           style: const TextStyle(color: Colors.green),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}