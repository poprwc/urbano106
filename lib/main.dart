import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Urbano 106',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
  final String url = 'TU_URL_DE_STREAMING_AQUI'; // Asegúrate de que sea la correcta

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  @override
  void dispose() {
    _player.dispose();
    super.initState();
  }

  Future<void> _togglePlay() async {
    if (isPlaying) {
      await _player.stop();
    } else {
      // CORRECCIÓN AQUÍ: Se eliminó el parámetro 'headers' incompatible
      await _player.play(UrlSource(url));
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Urbano 106'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Escuchando Urbano 106',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            IconButton(
              iconSize: 64,
              icon: Icon(isPlaying ? Icons.stop_circle : Icons.play_circle_fill),
              onPressed: _togglePlay,
            ),
          ],
        ),
      ),
    );
  }
}
