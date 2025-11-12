import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';
import 'package:try3/preferences_service.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final TextEditingController _nameController = TextEditingController();
  bool _isNameSaved = false;

  @override
  void initState() {
    super.initState();
    _loadPlayerName();
  }

  void _loadPlayerName() async {
    final name = await PreferencesService.getPlayerName();
    setState(() {
      _nameController.text = name;
      _isNameSaved = name.isNotEmpty;
    });
  }

  void _saveName() async {
    if (_nameController.text.trim().isNotEmpty) {
      await PreferencesService.setPlayerName(_nameController.text.trim());
      setState(() {
        _isNameSaved = true;
      });
      
      // Show a brief confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Name saved: ${_nameController.text}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF121212),
        ),
        child: Stack(
          children: [
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Game Title
                  const Text(
                    'The Lost',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 80),
                  
                  // Play Game Button
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GameScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Play Game',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Leaderboard Button
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Leaderboard',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Name input field on the right middle
            Positioned(
              right: 40,
              top: MediaQuery.of(context).size.height / 2 - 25,
              child: Container(
                width: 250,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Player Name',
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white54),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white54),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isNameSaved ? Icons.check_circle : Icons.check_circle_outline,
                            color: _isNameSaved ? Colors.grey : Colors.white54,
                          ),
                          onPressed: _saveName,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _isNameSaved = false;
                        });
                      },
                      onSubmitted: (_) => _saveName(),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your name for leaderboard',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}