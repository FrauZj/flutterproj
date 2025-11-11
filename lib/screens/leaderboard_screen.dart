import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF121212),
        ),
        child: const Center(
          child: Text(
            'Leaderboard Coming Soon...',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}