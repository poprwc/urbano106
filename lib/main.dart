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
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
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
  
  // --- IMPORTANTE: Reemplaza esta URL con tu enlace de streaming real ---
  // Ejemplo: 'https://sh.onlineradio.pro/8024/stream'
  final String url = 'http://usa18.fastcast4u.com:5040/'; 

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    try {
      if (isPlaying) {
        await _player.stop();
      } else {
        // SOLUCIÓN AL ERROR DE CODEMAGIC:
        // En audioplayers 6.6.0 ya no se usa el parámetro 'headers'
        await _player.play(UrlSource(url)); 
      }
      setState(() {
        isPlaying = !isPlaying;
      });
    } catch (e) {
      debugPrint("Error al reproducir: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'URBANO 106', 
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.yellow)
        ),
        centerTitle: true,
      ),
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
            // Representación visual de la radio
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                border: Border.all(color: Colors.yellow, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 10,
                  )
                ],
              ),
              child: const Icon(Icons.radio, size: 100, color: Colors.yellow),
            ),
            const SizedBox(height: 50),
            const Text(
              'ESCUCHANDO EN VIVO',
              style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.w300, letterSpacing: 1.5),
            ),
            const SizedBox(height: 10),
            const Text(
              'Urbano 106 FM',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 60),
            // Botón de Play / Stop
            GestureDetector(
              onTap: _togglePlay,
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: Colors.yellow,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? Icons.stop : Icons.play_arrow,
                  size: 60,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
