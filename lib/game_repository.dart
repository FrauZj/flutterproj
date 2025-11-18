import 'package:nakama/nakama.dart';
import 'package:try3/local/device_data_source.dart';
import 'package:try3/remote/nakama_data_source.dart';

class GameRepository {
  final DeviceDataSource _deviceDataSource;
  final NakamaDataSource _nakamaDataSource;
  Session? _currentSession;

  GameRepository(this._deviceDataSource, this._nakamaDataSource);

  Future<Session> initSession({String? username}) async {
    try {
      final deviceId = await _deviceDataSource.getDeviceId();
      _currentSession = await _nakamaDataSource.initSession(deviceId, username: username);
      return _currentSession!;
    } catch (e) {
      throw Exception('Failed to initialize session: $e');
    }
  } 

  Future<void> updateUsername(String newUsername) async {
    try {
      // Ensure we have a session
      if (_currentSession == null) {
        await initSession();
      }
      
      await _nakamaDataSource.updateAccountUsername(newUsername);
      
      // Update the session with the new username
      _currentSession = await _nakamaDataSource.initSession(
        await _deviceDataSource.getDeviceId(),
        username: newUsername,
      );
    } catch (e) {
      throw Exception('Failed to update username: $e');
    }
  }

  Future<LeaderboardRecordList> getLeaderboardRecords(String leaderboardName) async {
    try {
      return await _nakamaDataSource.getLeaderboard(leaderboardName);
    } catch (e) {
      throw Exception('Failed to get leaderboard: $e');
    }
  }

  Future<LeaderboardRecord> submitScore(int score, String leaderboardName) async { 
    try {
      return await _nakamaDataSource.submitScore(score, leaderboardName);
    } catch (e) {
      throw Exception('Failed to submit score: $e');
    }
  }
}