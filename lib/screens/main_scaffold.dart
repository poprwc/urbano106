import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/radio_service.dart';
import 'radio_screen.dart';
import 'programacion_screen.dart';
import 'tv_screen.dart';

class MainScaffold extends StatefulWidget {
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final RadioService _radio = RadioService();
  int _idx = 0;

  static const String _logoUrl =
      'https://www.urbano106.com/wp-content/uploads/2025/06/logo-urbano-106-bc-nuevo-03-1.png';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _radio.dispose();
    super.dispose();
  }

  Future<void> _onTab(int i) async {
    if (i == 4 && _radio.isPlaying) await _radio.stop();
    setState(() => _idx = i);
  }

  Widget _screen() {
    switch (_idx) {
      case 0: return RadioScreen(radio: _radio);
      case 1: return ProgramacionScreen();
      case 4: return TvScreen();
      default: return RadioScreen(radio: _radio);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Urbano 106',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: _screen(),
      bottomNavigationBar: AnimatedBuilder(
        animation: _radio,
        builder: (context, _) => _nav(),
      ),
    );
  }

  Widget _nav() {
    return Container(
      color: Colors.black,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(children: [
            _item(0, Icons.radio, 'Radio'),
            _item(1, Icons.calendar_today, 'Programa'),
            Expanded(
              child: GestureDetector(
                onTap: _radio.togglePlay,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _radio.isPlaying
                            ? const Color(0xFF1DB954)
                            : const Color(0xFF444444),
                        width: 2.5,
                      ),
                      boxShadow: _radio.isPlaying ? [
                        BoxShadow(
                          color: const Color(0xFF1DB954).withOpacity(0.5),
                          blurRadius: 10, spreadRadius: 2,
                        )
                      ] : [],
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: _logoUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Image.asset(
                            'assets/images/logo.jpg', fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => launchUrl(Uri.parse('https://wa.me/50660651059'),
                    mode: LaunchMode.externalApplication),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/images/WhatsApp.svg',
                        width: 24, height: 24,
                        colorFilter: const ColorFilter.mode(
                            Colors.white54, BlendMode.srcIn)),
                    const SizedBox(height: 3),
                    const Text('WhatsApp', style: TextStyle(
                        fontSize: 9, color: Colors.white54,
                        fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            _item(4, Icons.live_tv, 'TV'),
          ]),
        ),
      ),
    );
  }

  Widget _item(int i, IconData icon, String label) {
    final active = _idx == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTab(i),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: active ? const Color(0xFF1DB954) : Colors.white54,
                size: 22),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(
                fontSize: 9,
                color: active ? const Color(0xFF1DB954) : Colors.white54,
                fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
