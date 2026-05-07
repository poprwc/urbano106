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
  
  // Usando el stream HTTPS que es más estable
  final String url = 'https://usa18.fastcast4u.com/proxy/rmoohhrw?mp=/1';

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    
    // Configuración del reproductor
    _player.setReleaseMode(ReleaseMode.stop);
    _player.setPlayerMode(PlayerMode.mediaPlayer);
    
    // CORRECCIÓN: Se eliminó el 'const' que causaba el error de compilación
    _player.setAudioContext(AudioContext(
      android: const AudioContextAndroid(
        isContentMusic: true,
        usageType: AndroidUsageType.media,
        contentType: AndroidContentType.music,
        audioFocus: AndroidAudioFocus.gain,
      ),
      iOS: const AudioContextIOS(
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
        // Cargar fuente y reproducir
        await _player.setSource(UrlSource(url));
        await _player.resume();
        setState(() {
          isPlaying = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
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
            colors: [Colors.black, Color(0xFF121212)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "URBANO 106",
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 80),
            
            // Botón de Play con estado de carga
            GestureDetector(
              onTap: _togglePlay,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.yellow,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellow.withOpacity(0.3),
                          blurRadius: 25,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: Icon(
                      isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                      size: 90,
                      color: Colors.black,
                    ),
                  ),
                  if (isLoading)
                    const SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 6,
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            Text(
              isPlaying ? "REPRODUCIENDO" : "RADIO EN PAUSA",
              style: TextStyle(
                color: isPlaying ? Colors.yellow : Colors.white54,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
