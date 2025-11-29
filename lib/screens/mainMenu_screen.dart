import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';
import 'package:try3/preferences_service.dart';
import 'package:try3/game_repository.dart';
import 'package:try3/local/device_data_source.dart';
import 'package:try3/remote/nakama_data_source.dart';
import '../platform_utils.dart';

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
        await _gameRepository.updateUsername(newName);
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
    final isMobileLayout = isMobile || getScreenSize(context) == ScreenSize.small;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF121212),
        ),
        child: isMobileLayout ? _buildMobileLayout() : _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'The Lost',
                style: TextStyle(
                  fontSize: getResponsiveValue(
                    context,
                    mobile: 36.0,
                    tablet: 42.0,
                    desktop: 48.0,
                  ),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
              SizedBox(height: getResponsiveValue(
                context,
                mobile: 40.0,
                tablet: 60.0,
                desktop: 80.0,
              )),
              
              SizedBox(
                width: getResponsiveValue(
                  context,
                  mobile: 180.0,
                  tablet: 190.0,
                  desktop: 200.0,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GameScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(
                      vertical: getResponsiveValue(
                        context,
                        mobile: 14.0,
                        tablet: 15.0,
                        desktop: 16.0,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Play Game',
                    style: TextStyle(
                      fontSize: getResponsiveValue(
                        context,
                        mobile: 16.0,
                        tablet: 17.0,
                        desktop: 18.0,
                      ),
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: getResponsiveValue(
                context,
                mobile: 15.0,
                tablet: 18.0,
                desktop: 20.0,
              )),
              
              SizedBox(
                width: getResponsiveValue(
                  context,
                  mobile: 180.0,
                  tablet: 190.0,
                  desktop: 200.0,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(
                      vertical: getResponsiveValue(
                        context,
                        mobile: 14.0,
                        tablet: 15.0,
                        desktop: 16.0,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Leaderboard',
                    style: TextStyle(
                      fontSize: getResponsiveValue(
                        context,
                        mobile: 16.0,
                        tablet: 17.0,
                        desktop: 18.0,
                      ),
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
            width: getResponsiveValue(
              context,
              mobile: 200.0,
              tablet: 230.0,
              desktop: 250.0,
            ),
            padding: EdgeInsets.all(getResponsiveValue(
              context,
              mobile: 12.0,
              tablet: 14.0,
              desktop: 16.0,
            )),
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
                SizedBox(height: getResponsiveValue(
                  context,
                  mobile: 6.0,
                  tablet: 7.0,
                  desktop: 8.0,
                )),
                Text(
                  'Enter your name for leaderboard',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: getResponsiveValue(
                      context,
                      mobile: 10.0,
                      tablet: 11.0,
                      desktop: 12.0,
                    ),
                  ),
                ),
                SizedBox(height: getResponsiveValue(
                  context,
                  mobile: 2.0,
                  tablet: 3.0,
                  desktop: 4.0,
                )),
                Text(
                  _isNameSaved ? '✓ Name saved to leaderboard' : '',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: getResponsiveValue(
                      context,
                      mobile: 8.0,
                      tablet: 9.0,
                      desktop: 10.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Padding(
      padding: EdgeInsets.all(getResponsiveValue(
        context,
        mobile: 16.0,
        tablet: 20.0,
        desktop: 0.0,
      )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'The Lost',
            style: TextStyle(
              fontSize: getResponsiveValue(
                context,
                mobile: 36.0,
                tablet: 42.0,
                desktop: 48.0,
              ),
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2.0,
            ),
          ),
          SizedBox(height: getResponsiveValue(
            context,
            mobile: 40.0,
            tablet: 60.0,
            desktop: 80.0,
          )),
          
          // Name input field for mobile (moved to main column)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(getResponsiveValue(
              context,
              mobile: 12.0,
              tablet: 14.0,
              desktop: 16.0,
            )),
            margin: EdgeInsets.only(bottom: getResponsiveValue(
              context,
              mobile: 20.0,
              tablet: 25.0,
              desktop: 0.0,
            )),
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
                SizedBox(height: getResponsiveValue(
                  context,
                  mobile: 6.0,
                  tablet: 7.0,
                  desktop: 8.0,
                )),
                Text(
                  'Enter your name for leaderboard',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: getResponsiveValue(
                      context,
                      mobile: 10.0,
                      tablet: 11.0,
                      desktop: 12.0,
                    ),
                  ),
                ),
                SizedBox(height: getResponsiveValue(
                  context,
                  mobile: 2.0,
                  tablet: 3.0,
                  desktop: 4.0,
                )),
                Text(
                  _isNameSaved ? '✓ Name saved to leaderboard' : '',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: getResponsiveValue(
                      context,
                      mobile: 8.0,
                      tablet: 9.0,
                      desktop: 10.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(
            width: getResponsiveValue(
              context,
              mobile: 180.0,
              tablet: 190.0,
              desktop: 200.0,
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GameScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(
                  vertical: getResponsiveValue(
                    context,
                    mobile: 14.0,
                    tablet: 15.0,
                    desktop: 16.0,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Play Game',
                style: TextStyle(
                  fontSize: getResponsiveValue(
                    context,
                    mobile: 16.0,
                    tablet: 17.0,
                    desktop: 18.0,
                  ),
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: getResponsiveValue(
            context,
            mobile: 15.0,
            tablet: 18.0,
            desktop: 20.0,
          )),
          
          SizedBox(
            width: getResponsiveValue(
              context,
              mobile: 180.0,
              tablet: 190.0,
              desktop: 200.0,
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(
                  vertical: getResponsiveValue(
                    context,
                    mobile: 14.0,
                    tablet: 15.0,
                    desktop: 16.0,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Leaderboard',
                style: TextStyle(
                  fontSize: getResponsiveValue(
                    context,
                    mobile: 16.0,
                    tablet: 17.0,
                    desktop: 18.0,
                  ),
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}