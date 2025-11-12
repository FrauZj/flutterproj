import 'package:nakama/nakama.dart';

const serverKey = String.fromEnvironment('NAKAMA_SERVER_KEY', defaultValue: 'defaultkey');
const host = String.fromEnvironment('NAKAMA_HOST', defaultValue: '127.0.0.1');
const ssl = bool.fromEnvironment('NAKAMA_SSL', defaultValue: false);
const leaderboardName = 'main_leaderboard';

class NakamaDataSource {
  final client = getNakamaClient(
    host: host,
    ssl: ssl,
    serverKey: serverKey,
    grpcPort: 7349,
    httpPort: 7350,
  );

  late Session _currentSession;

  Future<Session> initSession(String deviceId) async {
    _currentSession = await client.authenticateDevice(
      deviceId: 'test-device',
      username: 'player-default'
    );
    return _currentSession;
  }
  
  Future<LeaderboardRecordList> getLeaderboard([String leaderboardName = leaderboardName]) async {
    final LeaderboardRecordList list = await client.listLeaderboardRecords(
      session: _currentSession,
      leaderboardName: leaderboardName,
    );
    return list;
  }

  Future<LeaderboardRecord> submitScore(int score, [String leaderboardName = leaderboardName]) async {
    return client.writeLeaderboardRecord(
      session: _currentSession, 
      leaderboardName: leaderboardName, 
      score: score
    );
  }
}