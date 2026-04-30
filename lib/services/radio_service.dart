import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class NowPlayingInfo {
  final String title;
  final String artist;
  final String? artUrl;

  const NowPlayingInfo({
    required this.title,
    required this.artist,
    this.artUrl,
  });

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
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;

      if (state.playing) {
        _isLoading = false;
        _lastError = null;
      }

      if (state.processingState == ProcessingState.idle ||
          state.processingState == ProcessingState.completed) {
        _isLoading = false;
        _isPlaying = false;
      }

      notifyListeners();
    });
  }

  Future<void> playUrl(String url) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      await _player.stop();
      _metaTimer?.cancel();

      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          headers: const {
            'User-Agent': 'Mozilla/5.0 (Android) Urbano106/5.0',
            'Icy-MetaData': '1',
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
          },
          tag: MediaItem(
            id: streamUrl,
            album: 'Urbano 106 FM',
            title: _nowPlaying.title,
            artist: _nowPlaying.artist,
            artUri: Uri.parse(
              _nowPlaying.artUrl ??
                  'https://www.urbano106.com/wp-content/uploads/2025/06/logo-urbano-106-bc-nuevo-03-1.png',
            ),
          ),
        ),
      );

      await _player.play();
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
      const Duration(seconds: 10),
      (_) => _fetchMeta(),
    );
  }

  Future<void> _fetchMeta() async {
    try {
      final res = await http.get(
        Uri.parse(metaUrl),
        headers: const {
          'User-Agent': 'Mozilla/5.0 (Android) Urbano106/5.0',
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
      ).timeout(const Duration(seconds: 8));

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
        if (artist != 'Urbano 106 FM') {
          artUrl = await _fetchArt(artist, title);
        }

        _nowPlaying = NowPlayingInfo(
          title: title,
          artist: artist,
          artUrl: artUrl,
        );

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Meta: $e');
    }
  }

  Future<String?> _fetchArt(String artist, String title) async {
    try {
      final q = Uri.encodeComponent('$artist $title');
      final res = await http
          .get(
            Uri.parse(
              'https://itunes.apple.com/search?term=$q&media=music&limit=1',
            ),
          )
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
  void dispose() {
    _metaTimer?.cancel();
    _player.dispose();
    super.dispose();
  }
}
