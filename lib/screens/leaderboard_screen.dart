import 'package:flutter/material.dart';
import 'package:nakama/nakama.dart';
import 'package:try3/game_repository.dart';
import 'package:try3/local/device_data_source.dart';
import 'package:try3/remote/nakama_data_source.dart';
import 'package:try3/preferences_service.dart';

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
    final username = record.username ?? 'Unknown'; // Handle null username
    final score = record.score;
    final rank = index + 1; // Calculate rank from index
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          // Position (with smoothed edges)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Name
          Expanded(
            child: Text(
              username,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Days survived
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue),
            ),
            child: Text(
              '$score days',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 14,
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
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  )
                : _leaderboardRecords.isEmpty
                    ? const Center(
                        child: Text(
                          'No leaderboard records yet',
                          style: TextStyle(
                            fontSize: 24,
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