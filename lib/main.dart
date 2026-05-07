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
  late AudioPlayer _player;
  bool isPlaying = false;
  bool isLoading = false;
  
  // Usaremos el Stream F (HTTPS) como predeterminado por ser el más seguro
  String url = 'https://usa18.fastcast4u.com/proxy/rmoohhrw?mp=/1';

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    
    // CONFIGURACIÓN CRÍTICA PARA ANDROID
    _player.setReleaseMode(ReleaseMode.stop);
    _player.setPlayerMode(PlayerMode.mediaPlayer); // Optimizado para streams largos
    
    // Configurar el contexto de audio para que Android sepa que es música
    _player.setAudioContext(const AudioContext(
      android: AudioContextAndroid(
        isContentMusic: true,
        usageType: AndroidUsageType.media,
        contentType: AndroidContentType.music,
        audioFocus: AndroidAudioFocus.gain,
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
        // PASO A PASO: Primero set, luego play
        await _player.setSource(UrlSource(url));
        await _player.resume();
        
        setState(() {
          isPlaying = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("ERROR DETECTADO: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de reproducción: $e'), backgroundColor: Colors.red),
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
            begin: Alignment.topCenter, colors: [Colors.black, Color(0xFF222222)]
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("URBANO 106", style: TextStyle(color: Colors.yellow, fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 5)),
            const SizedBox(height: 60),
            GestureDetector(
              onTap: _togglePlay,
              child: Container(
                width: 150, height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.yellow,
                  boxShadow: [BoxShadow(color: Colors.yellow.withOpacity(0.3), blurRadius: 20)]
                ),
                child: Icon(
                  isLoading ? Icons.hourglass_top : (isPlaying ? Icons.stop : Icons.play_arrow),
                  size: 80, color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(isPlaying ? "EN VIVO" : "RADIO PAUSADA", style: const TextStyle(color: Colors.white70)),
            if (isLoading) const Padding(
              padding: EdgeInsets.only(top: 20),
              child: CircularProgressIndicator(color: Colors.yellow),
            ),
          ],
        ),
      ),
    );
  }
}
