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

  Session? _currentSession;

  Future<Session> initSession(String deviceId, {String? username}) async {
    _currentSession = await client.authenticateDevice(
      deviceId: deviceId,
      username: username,
    );
    return _currentSession!;
  }
  
  // Update username for existing session
  Future<void> updateAccountUsername(String newUsername) async {
    if (_currentSession == null) {
      throw Exception('No active session');
    }

    
    await client.updateAccount(
      session: _currentSession!,
      username: newUsername,
    );
  }
  
  Future<LeaderboardRecordList> getLeaderboard([String leaderboardName = leaderboardName]) async {
    if (_currentSession == null) {
      throw Exception('No active session');
    }
    
    final LeaderboardRecordList list = await client.listLeaderboardRecords(
      session: _currentSession!,
      leaderboardName: leaderboardName,
    );
    return list;
  }

  Future<LeaderboardRecord> submitScore(int score, [String leaderboardName = leaderboardName]) async {
    if (_currentSession == null) {
      throw Exception('No active session');
    }
    
    return client.writeLeaderboardRecord(
      session: _currentSession!, 
      leaderboardName: leaderboardName, 
      score: score
    );
  }
}