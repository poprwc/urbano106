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
  
  // Lista de streams para probar
  final List<Map<String, String>> streams = [
    {'label': 'Stream A', 'url': 'http://usa18.fastcast4u.com:5040/stream'},
    {'label': 'Stream B', 'url': 'http://usa18.fastcast4u.com:5040/;'},
    {'label': 'Stream C', 'url': 'http://usa18.fastcast4u.com:5040/;stream'},
    {'label': 'Stream D', 'url': 'http://66.70.249.70:5040/stream'},
    {'label': 'Stream E', 'url': 'http://66.70.249.70:5040'},
    {'label': 'Stream F (HTTPS)', 'url': 'https://usa18.fastcast4u.com/proxy/rmoohhrw?mp=/1'},
    {'label': 'Stream G', 'url': 'http://usa18.fastcast4u.com/proxy/rmoohhrw?mp=/1'},
  ];

  late Map<String, String> currentStream;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    currentStream = streams[0]; // Empezamos con el A
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
        setState(() => isPlaying = false);
      } else {
        await _player.play(UrlSource(currentStream['url']!));
        setState(() => isPlaying = true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('URBANO 106', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.radio, size: 80, color: Colors.yellow),
            const SizedBox(height: 20),
            
            // Selector de Stream
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.yellow),
              ),
              child: DropdownButton<Map<String, String>>(
                value: currentStream,
                dropdownColor: Colors.grey[900],
                underline: const SizedBox(),
                items: streams.map((stream) {
                  return DropdownMenuItem(
                    value: stream,
                    child: Text(stream['label']!, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) async {
                  if (isPlaying) await _player.stop();
                  setState(() {
                    currentStream = value!;
                    isPlaying = false;
                  });
                },
              ),
            ),
            
            const SizedBox(height: 40),
            Text(currentStream['url']!, 
                 textAlign: TextAlign: TextAlign.center, 
                 style: const TextStyle(fontSize: 10, color: Colors.grey)),
            const SizedBox(height: 40),

            // Botón Play
            GestureDetector(
              onTap: _togglePlay,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.yellow,
                child: Icon(isPlaying ? Icons.stop : Icons.play_arrow, size: 50, color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            Text(isPlaying ? 'REPRODUCIENDO...' : 'PAUSADO', 
                 style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
