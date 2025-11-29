import 'package:flutter/material.dart';
import 'package:nakama/nakama.dart';
import 'package:try3/game_repository.dart';
import 'package:try3/local/device_data_source.dart';
import 'package:try3/remote/nakama_data_source.dart';
import 'package:try3/preferences_service.dart';
import '../platform_utils.dart'; // Add this import

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final GameRepository _gameRepository = GameRepository(
    DeviceDataSource(),
    NakamaDataSource(),
  );
  
  List<LeaderboardRecord> _leaderboardRecords = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    try {
      await _gameRepository.initSession();
      final LeaderboardRecordList records = await _gameRepository.getLeaderboardRecords('main_leaderboard');
      setState(() {
        _leaderboardRecords = records.records ?? []; 
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load leaderboard: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildLeaderboardItem(int index, LeaderboardRecord record) {
    final username = record.username ?? 'Unknown';
    final score = record.score;
    final rank = index + 1;
    
    final isMobileLayout = isMobile || getScreenSize(context) == ScreenSize.small;
    
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: getResponsiveValue(
          context,
          mobile: 3.0,
          tablet: 4.0,
          desktop: 4.0,
        ),
        horizontal: getResponsiveValue(
          context,
          mobile: 8.0,
          tablet: 12.0,
          desktop: 16.0,
        ),
      ),
      padding: EdgeInsets.all(getResponsiveValue(
        context,
        mobile: 12.0,
        tablet: 14.0,
        desktop: 16.0,
      )),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          // Position
          Container(
            width: getResponsiveValue(
              context,
              mobile: 40.0,
              tablet: 45.0,
              desktop: 50.0,
            ),
            height: getResponsiveValue(
              context,
              mobile: 40.0,
              tablet: 45.0,
              desktop: 50.0,
            ),
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: getResponsiveValue(
                    context,
                    mobile: 14.0,
                    tablet: 15.0,
                    desktop: 16.0,
                  ),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          SizedBox(width: getResponsiveValue(
            context,
            mobile: 12.0,
            tablet: 14.0,
            desktop: 16.0,
          )),
          
          // Name
          Expanded(
            child: Text(
              username,
              style: TextStyle(
                color: Colors.white,
                fontSize: getResponsiveValue(
                  context,
                  mobile: 14.0,
                  tablet: 15.0,
                  desktop: 16.0,
                ),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          SizedBox(width: getResponsiveValue(
            context,
            mobile: 12.0,
            tablet: 14.0,
            desktop: 16.0,
          )),
          
          // Days survived
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: getResponsiveValue(
                context,
                mobile: 8.0,
                tablet: 10.0,
                desktop: 12.0,
              ),
              vertical: getResponsiveValue(
                context,
                mobile: 4.0,
                tablet: 5.0,
                desktop: 6.0,
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue),
            ),
            child: Text(
              '$score days',
              style: TextStyle(
                color: Colors.blue,
                fontSize: getResponsiveValue(
                  context,
                  mobile: 12.0,
                  tablet: 13.0,
                  desktop: 14.0,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.orange[800]!;
      default:
        return Colors.grey[800]!;
    }
  }

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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(getResponsiveValue(
                        context,
                        mobile: 16.0,
                        tablet: 20.0,
                        desktop: 0.0,
                      )),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : _leaderboardRecords.isEmpty
                    ? Center(
                        child: Text(
                          'No leaderboard records yet',
                          style: TextStyle(
                            fontSize: getResponsiveValue(
                              context,
                              mobile: 18.0,
                              tablet: 22.0,
                              desktop: 24.0,
                            ),
                            color: Colors.white70,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _leaderboardRecords.length,
                        itemBuilder: (context, index) {
                          return _buildLeaderboardItem(
                            index,
                            _leaderboardRecords[index],
                          );
                        },
                      ),
      ),
    );
  }
}