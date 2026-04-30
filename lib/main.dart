import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'screens/main_scaffold.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.radio.urbanocr.audio',
      androidNotificationChannelName: 'Urbano 106 Audio',
      androidNotificationOngoing: true,
    );
  } catch (e, st) {
    debugPrint('JustAudioBackground init failed: $e');
    debugPrintStack(stackTrace: st);
  }

  runApp(Urbano106App());
}

class Urbano106App extends StatelessWidget {
  const Urbano106App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Urbano 106',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: MainScaffold(),
    );
  }
}
