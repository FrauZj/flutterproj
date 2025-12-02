import 'package:flutter/material.dart';
import 'game_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GameApp());
}

// void _initializeNakama() async{
//   const serverKey = String.fromEnvironment('NAKAMA_SERVER_KEY', defaultValue: 'defaultkey');
//   const host = String.fromEnvironment('NAKAMA_HOST', defaultValue: '127.0.0.1');
//   const ssl = bool.fromEnvironment('NAKAMA_SSL', defaultValue: false);
  
//   final client = getNakamaClient(
//     host: host,
//     ssl: ssl,
//     serverKey: serverKey,
//     grpcPort: 7349,
//     httpPort: 7350,
//   );
//   final session = await client.authenticateDevice(
//     deviceId: 'test-device',
//     username: 'player-default'
//   );
//   print('Session is: ${session.token}');

// }