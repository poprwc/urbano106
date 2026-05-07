import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

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
      theme: ThemeData(
        brightness: Brightness.dark, 
        scaffoldBackgroundColor: Colors.black,
      ),
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
  late AudioPlayer _player;
  bool isPlaying = false;
  bool isLoading = false;
  
  // Stream HTTPS de Urbano 106
  final String url = 'https://usa18.fastcast4u.com/proxy/rmoohhrw?mp=/1';

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    
    _player.setReleaseMode(ReleaseMode.stop);
    _player.setPlayerMode(PlayerMode.mediaPlayer);
    
    // CORRECCIÓN PARA VERSIÓN 7.1.1:
    // 1. Se eliminó 'isContentMusic' (ya no existe).
    // 2. Se quitaron los 'const' de los sub-constructores para evitar el error de compilación.
    _player.setAudioContext(AudioContext(
      android: AudioContextAndroid(
        contentType: AudioContentType.music,
        usageType: AudioUsageType.media,
        audioFocus: AudioAudioFocus.gain,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
      ),
    ));
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    try {
      if (isPlaying) {
        await _player.stop();
        setState(() {
          isPlaying = false;
          isLoading = false;
        });
      } else {
        await _player.setSource(UrlSource(url));
        await _player.resume();
        setState(() {
          isPlaying = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error de audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
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
            
            GestureDetector(
              onTap: _togglePlay,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.yellow,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellow.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Icon(
                      isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                      size: 100,
                      color: Colors.black,
                    ),
                  ),
                  if (isLoading)
                    const SizedBox(
                      width: 150,
                      height: 150,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 8,
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 50),
            Text(
              isPlaying ? "AL AIRE" : "RADIO EN PAUSA",
              style: TextStyle(
                color: isPlaying ? Colors.yellow : Colors.white24,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
