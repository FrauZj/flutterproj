import 'package:nakama/nakama.dart';
import 'package:try3/local/device_data_source.dart';
import 'package:try3/remote/nakama_data_source.dart';

class GameRepository {
  final DeviceDataSource _deviceDataSource;
  final NakamaDataSource _nakamaDataSource;

  GameRepository(this._deviceDataSource, this._nakamaDataSource);

  Future<Session> initSession() async {
    final deviceId = await _deviceDataSource.getDeviceId();
    final session = await _nakamaDataSource.initSession(deviceId);
    return session;
  } 

  Future<LeaderboardRecordList> getLeaderboardRecords(String LeaderboardName) async {  return _nakamaDataSource.getLeaderboard(LeaderboardName);}

  Future<LeaderboardRecord> submitScore (int score, String leaderboardName) async { 
    return _nakamaDataSource.submitScore(score, leaderboardName);
    }
}