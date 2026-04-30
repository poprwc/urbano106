import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../services/radio_service.dart';

class RadioScreen extends StatefulWidget {
  final RadioService radio;
  RadioScreen({Key? key, required this.radio}) : super(key: key);

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  final List<String> _logs = [];
  final AudioPlayer _testPlayer = AudioPlayer();
  bool _testing = false;
  int? _testingIndex;

  final List<Map<String, String>> _tests = [
    {'name': 'HTTPS proxy mp=/1', 'url': 'https://usa18.fastcast4u.com/proxy/rmoohhrw?mp=/1'},
    {'name': 'HTTP port 5040 stream', 'url': 'http://usa18.fastcast4u.com:5040/stream'},
    {'name': 'HTTP port 5040 ;', 'url': 'http://usa18.fastcast4u.com:5040/;'},
    {'name': 'HTTPS proxy (stream)', 'url': 'https://usa18.fastcast4u.com/proxy/rmoohhrw'},
    {'name': 'HTTP IP 5040 stream', 'url': 'http://66.70.249.70:5040/stream'},
  ];

  void _log(String msg) {
    final time = DateTime.now().toIso8601String().substring(11, 19);
    setState(() => _logs.insert(0, '[$time] $msg'));
  }

  @override
  void initState() {
    super.initState();
    _testPlayer.playerStateStream.listen((state) {
      if (state.playing) _log('✅ SUENA! Estado: playing');
      if (state.processingState == ProcessingState.buffering) _log('⏳ Buffering...');
      if (state.processingState == ProcessingState.ready) _log('✅ Ready - reproduciendo');
      if (state.processingState == ProcessingState.idle) _log('⚪ Idle');
    });
    _testPlayer.playbackEventStream.listen(
      (_) {},
      onError: (e, st) => _log('❌ Error playback: $e'),
    );
    _initSession();
  }

  Future<void> _initSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      _log('✅ AudioSession configurado');
    } catch (e) {
      _log('❌ AudioSession error: $e');
    }
  }

  Future<void> _testUrl(int index) async {
    if (_testing) {
      await _testPlayer.stop();
      setState(() { _testing = false; _testingIndex = null; });
      return;
    }
    setState(() { _testing = true; _testingIndex = index; });
    final url = _tests[index]['url']!;
    final name = _tests[index]['name']!;
    _log('🔄 Probando: $name');
    _log('URL: $url');
    try {
      await _testPlayer.stop();
      _log('⏳ Llamando setAudioSource...');
      await _testPlayer.setAudioSource(
        AudioSource.uri(Uri.parse(url)),
      ).timeout(const Duration(seconds: 15));
      _log('⏳ setAudioSource OK, llamando play()...');
      await _testPlayer.play();
      _log('✅ play() llamado');
    } catch (e) {
      _log('❌ FALLO: $e');
      setState(() { _testing = false; _testingIndex = null; });
    }
  }

  @override
  void dispose() {
    _testPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.black,
            child: const Row(
              children: [
                Icon(Icons.bug_report, color: Color(0xFF1DB954)),
                SizedBox(width: 8),
                Text('Diagnóstico de Audio',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          // Test buttons
          Expanded(
            flex: 2,
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                ..._tests.asMap().entries.map((e) {
                  final i = e.key;
                  final t = e.value;
                  final isActive = _testingIndex == i;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton(
                      onPressed: () => _testUrl(i),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive
                            ? const Color(0xFF1DB954)
                            : Colors.grey.shade200,
                        foregroundColor: isActive ? Colors.white : Colors.black87,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        alignment: Alignment.centerLeft,
                      ),
                      child: Row(children: [
                        Icon(isActive && _testing
                            ? Icons.stop
                            : Icons.play_arrow, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t['name']!, style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                            Text(t['url']!, style: TextStyle(
                                fontSize: 9,
                                color: isActive ? Colors.white70 : Colors.black38),
                                overflow: TextOverflow.ellipsis),
                          ],
                        )),
                      ]),
                    ),
                  );
                }),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _logs.clear()),
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Limpiar logs'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ),

          // Logs
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(4),
            child: const Text('LOGS', style: TextStyle(
                color: Colors.white38, fontSize: 10, letterSpacing: 2)),
          ),
          Expanded(
            flex: 3,
            child: Container(
              color: const Color(0xFF0D0D0D),
              child: _logs.isEmpty
                  ? const Center(child: Text('Presioná un stream para probar',
                      style: TextStyle(color: Colors.white38, fontSize: 12)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _logs.length,
                      itemBuilder: (_, i) => Text(
                        _logs[i],
                        style: TextStyle(
                          fontSize: 11,
                          color: _logs[i].contains('✅')
                              ? const Color(0xFF1DB954)
                              : _logs[i].contains('❌')
                                  ? Colors.red.shade300
                                  : Colors.white60,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
