import 'package:nakama/nakama.dart';
import 'package:try3/local/device_data_source.dart';
import 'package:try3/remote/nakama_data_source.dart';

class GameRepository {
  final DeviceDataSource _deviceDataSource;
  final NakamaDataSource _nakamaDataSource;

  GameRepository(this._deviceDataSource, this._nakamaDataSource);

  Future<Session> initSession() async {
    try {
      final deviceId = await _deviceDataSource.getDeviceId();
      final session = await _nakamaDataSource.initSession(deviceId);
      return session;
    } catch (e) {
      throw Exception('Failed to initialize session: $e');
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