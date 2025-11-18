import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';
import 'package:try3/preferences_service.dart';
import 'package:try3/game_repository.dart';
import 'package:try3/local/device_data_source.dart';
import 'package:try3/remote/nakama_data_source.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final TextEditingController _nameController = TextEditingController();
  bool _isNameSaved = false;
  final GameRepository _gameRepository = GameRepository(
    DeviceDataSource(),
    NakamaDataSource(),
  );

  @override
  void initState() {
    super.initState();
    _loadPlayerName();
    _initializeSession();
  }

  void _initializeSession() async {
    try {
      // Initialize session without username first
      await _gameRepository.initSession();
    } catch (e) {
      print('Failed to initialize session: $e');
    }
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
      final newName = _nameController.text.trim();
      
      try {
        // Update username in Nakama leaderboard
        await _gameRepository.updateUsername(newName);
        
        // Save to local preferences
        await PreferencesService.setPlayerName(newName);
        
        setState(() {
          _isNameSaved = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Name updated: $newName'),
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update name: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
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
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                            color: _isNameSaved ? Colors.green : Colors.white54,
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
                    const SizedBox(height: 4),
                    Text(
                      _isNameSaved ? '✓ Name saved to leaderboard' : '',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 10,
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