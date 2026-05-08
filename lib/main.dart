import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const Urbano106App());
}

class Urbano106App extends StatelessWidget {
  const Urbano106App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Urbano 106',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: Colors.black),
      home: const RadioPlayerScreen(),
    );
  }
}

class RadioPlayerScreen extends StatefulWidget {
  const RadioPlayerScreen({super.key});

  @override
  State<RadioPlayerScreen> createState() => _RadioPlayerScreenState();
}

class _RadioPlayerScreenState extends State<RadioPlayerScreen> {
  // Cambiamos a AudioPlayer de just_audio
  final _player = AudioPlayer();
  bool isPlaying = false;

  // Stream HTTPS (El más seguro para probar)
  final String url = 'https://usa18.fastcast4u.com/proxy/rmoohhrw?mp=/1';

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      // Configuramos la fuente del stream
      await _player.setUrl(url);
    } catch (e) {
      debugPrint("Error inicializando el stream: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (isPlaying) {
      _player.stop();
    } else {
      _player.play();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [Colors.black, Color(0xFF1A1A1A)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "URBANO 106",
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 35,
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 100),
            
            // Monitor de estado del buffer
            StreamBuilder<PlayerState>(
              stream: _player.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final processingState = playerState?.processingState;
                final playing = playerState?.playing;

                if (processingState == ProcessingState.loading ||
                    processingState == ProcessingState.buffering) {
                  return const SizedBox(
                    width: 150, height: 150,
                    child: CircularProgressIndicator(color: Colors.yellow, strokeWidth: 8),
                  );
                }

                return GestureDetector(
                  onTap: _togglePlay,
                  child: Container(
                    width: 150, height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.yellow,
                      boxShadow: [
                        BoxShadow(color: Colors.yellow.withOpacity(0.4), blurRadius: 30)
                      ],
                    ),
                    child: Icon(
                      playing == true ? Icons.stop_rounded : Icons.play_arrow_rounded,
                      size: 100, color: Colors.black,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 50),
            const Text(
              "AL AIRE",
              style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
