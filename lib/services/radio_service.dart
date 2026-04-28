import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:http/http.dart' as http;
import 'package:audio_session/audio_session.dart';

class NowPlayingInfo {
  final String title;
  final String artist;
  final String? artUrl;
  const NowPlayingInfo({required this.title, required this.artist, this.artUrl});
  factory NowPlayingInfo.empty() =>
      const NowPlayingInfo(title: 'Urbano 106 FM', artist: 'En Vivo');
}

class RadioService extends ChangeNotifier {
  static const String metaUrl =
      'https://usa18.fastcast4u.com/proxy/rmoohhrw/currentsong?sid=1';
  static const String logoUrl =
      'https://www.urbano106.com/wp-content/uploads/2025/06/logo-urbano-106-bc-nuevo-03-1.png';

  final AudioPlayer _player = AudioPlayer();
  NowPlayingInfo _nowPlaying = NowPlayingInfo.empty();
  bool _isLoading = false;
  Timer? _metaTimer;
  String? _currentUrl;

  NowPlayingInfo get nowPlaying => _nowPlaying;
  bool get isPlaying => _player.playing;
  bool get isLoading => _isLoading;
  ProcessingState get processingState => _player.processingState;

  RadioService() { _init(); }

  Future<void> _init() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      _player.playingStream.listen((_) => notifyListeners());
      _player.processingStateStream.listen((s) {
        if (s == ProcessingState.ready) _isLoading = false;
        notifyListeners();
      });
    } catch (e) { debugPrint('Init: $e'); }
  }

  Future<void> playUrl(String url) async {
    _currentUrl = url;
    _isLoading = true;
    _nowPlaying = NowPlayingInfo.empty();
    notifyListeners();
    try {
      await _player.stop();
      _metaTimer?.cancel();
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: 'urbano106',
            title: 'Urbano 106 FM',
            artist: 'En Vivo',
            album: 'Urbano 106 FM',
            artUri: Uri.parse(logoUrl),
          ),
        ),
      );
      await _player.play();
      _startMetaPolling();
    } catch (e) {
      debugPrint('Play: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> togglePlay() async {
    if (_player.playing) {
      await stop();
    } else {
      await playUrl(_currentUrl ?? 'http://usa18.fastcast4u.com:5040/stream');
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _metaTimer?.cancel();
    _nowPlaying = NowPlayingInfo.empty();
    _isLoading = false;
    notifyListeners();
  }

  void _startMetaPolling() {
    _fetchMeta();
    _metaTimer = Timer.periodic(const Duration(seconds: 15), (_) => _fetchMeta());
  }

  Future<void> _fetchMeta() async {
    try {
      final res = await http.get(Uri.parse(metaUrl))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200 && res.body.trim().isNotEmpty) {
        final song = res.body.trim();
        String artist = 'Urbano 106 FM';
        String title = 'En Vivo';
        if (song.contains(' - ')) {
          final parts = song.split(' - ');
          artist = parts[0].trim();
          title = parts.sublist(1).join(' - ').trim();
        } else {
          title = song;
        }
        String? artUrl;
        if (artist != 'Urbano 106 FM') artUrl = await _fetchArt(artist, title);
        _nowPlaying = NowPlayingInfo(title: title, artist: artist, artUrl: artUrl);
        notifyListeners();
      }
    } catch (e) { debugPrint('Meta: $e'); }
  }

  Future<String?> _fetchArt(String artist, String title) async {
    try {
      final q = Uri.encodeComponent('$artist $title');
      final res = await http.get(Uri.parse(
          'https://itunes.apple.com/search?term=$q&media=music&limit=1'))
          .timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final results = data['results'] as List?;
        if (results != null && results.isNotEmpty) {
          return (results[0]['artworkUrl100'] as String?)
              ?.replaceAll('100x100bb', '300x300bb');
        }
      }
    } catch (_) {}
    return null;
  }

  @override
  void dispose() { _metaTimer?.cancel(); _player.dispose(); super.dispose(); }
}
