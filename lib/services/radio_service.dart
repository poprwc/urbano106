import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

class NowPlayingInfo {
  final String title;
  final String artist;
  final String? artUrl;
  const NowPlayingInfo({required this.title, required this.artist, this.artUrl});
  factory NowPlayingInfo.empty() =>
      const NowPlayingInfo(title: 'Urbano 106 FM', artist: 'En Vivo');
}

class RadioService extends ChangeNotifier {
  static const String streamUrl =
      'https://usa18.fastcast4u.com/proxy/rmoohhrw?mp=/1';
  static const String metaUrl =
      'https://usa18.fastcast4u.com/proxy/rmoohhrw/currentsong?sid=1';

  final AudioPlayer _player = AudioPlayer();
  NowPlayingInfo _nowPlaying = NowPlayingInfo.empty();
  bool _isPlaying = false;
  bool _isLoading = false;
  String? _lastError;
  Timer? _metaTimer;

  NowPlayingInfo get nowPlaying => _nowPlaying;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  RadioService() {
    _player.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      if (state == PlayerState.playing) {
        _isLoading = false;
        _lastError = null;
      }
      if (state == PlayerState.stopped || state == PlayerState.completed) {
        _isLoading = false;
        _isPlaying = false;
      }
      notifyListeners();
    });

    _player.onLog.listen((msg) {
      debugPrint('AudioPlayer log: $msg');
    });
  }

  Future<void> playUrl(String url) async {
    _isLoading = true;
    _lastError = null;
    _nowPlaying = NowPlayingInfo.empty();
    notifyListeners();
    try {
      await _player.stop();
      _metaTimer?.cancel();
      await _player.play(UrlSource(url));
      _startMetaPolling();
    } catch (e) {
      _lastError = e.toString();
      _isLoading = false;
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> togglePlay() async {
    if (_isPlaying) {
      await stop();
    } else {
      await playUrl(streamUrl);
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _metaTimer?.cancel();
    _nowPlaying = NowPlayingInfo.empty();
    _isLoading = false;
    _isPlaying = false;
    _lastError = null;
    notifyListeners();
  }

  void _startMetaPolling() {
    _fetchMeta();
    _metaTimer = Timer.periodic(
        const Duration(seconds: 15), (_) => _fetchMeta());
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
