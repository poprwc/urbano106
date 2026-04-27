import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class TvScreen extends StatefulWidget {
  @override
  State<TvScreen> createState() => _TvScreenState();
}

class _TvScreenState extends State<TvScreen> {
  VideoPlayerController? _vc;
  ChewieController? _cc;
  bool _loading = true;
  bool _error = false;

  static const String _url =
      'https://59ef525c24caa.streamlock.net/tvurbano/tvurbano/playlist.m3u8';
  static const MethodChannel _pip = MethodChannel('com.radio.urbanocr/pip');

  @override
  void initState() { super.initState(); _init(); }

  Future<void> _enterPiP() async {
    try { await _pip.invokeMethod('enterPiP'); }
    catch (e) { debugPrint('PiP: $e'); }
  }

  Future<void> _init() async {
    setState(() { _loading = true; _error = false; });
    try {
      _cc?.dispose(); _vc?.dispose();
      _vc = VideoPlayerController.networkUrl(Uri.parse(_url),
          httpHeaders: {'User-Agent': 'Mozilla/5.0'});
      await _vc!.initialize();
      _cc = ChewieController(
        videoPlayerController: _vc!,
        autoPlay: true,
        looping: true,
        isLive: true,
        allowFullScreen: true,
        allowMuting: true,
        placeholder: Container(color: Colors.black),
      );
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      debugPrint('TV: $e');
      if (mounted) setState(() { _loading = false; _error = true; });
    }
  }

  @override
  void dispose() { _cc?.dispose(); _vc?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Color(0xFF1DB954))));
    if (_error || _cc == null) return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.signal_wifi_bad, color: Colors.black38, size: 48),
        const SizedBox(height: 12),
        const Text('No se pudo cargar la TV',
            style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 16),
        TextButton(onPressed: _init,
            child: const Text('Reintentar',
                style: TextStyle(color: Color(0xFF1DB954)))),
      ],
    ));
    return Container(
      color: Colors.black,
      child: Stack(children: [
        Center(child: AspectRatio(aspectRatio: 16/9,
            child: Chewie(controller: _cc!))),
        Positioned(top: 12, right: 12,
          child: GestureDetector(
            onTap: _enterPiP,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.black54,
                  borderRadius: BorderRadius.circular(8)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.picture_in_picture_alt, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text('Flotante', style: TextStyle(color: Colors.white, fontSize: 11)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}
