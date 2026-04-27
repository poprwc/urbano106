import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/radio_service.dart';

class RadioScreen extends StatelessWidget {
  final RadioService radio;
  RadioScreen({Key? key, required this.radio}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: radio,
      builder: (context, _) {
        final isPlaying = radio.isPlaying;
        final isLoading = radio.isLoading;
        final info = radio.nowPlaying;
        final error = radio.lastError;

        return SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: isPlaying ? 250 : 220,
                  height: isPlaying ? 250 : 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 24, offset: const Offset(0, 10),
                    )],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: (isPlaying && info.artUrl != null)
                        ? CachedNetworkImage(
                            imageUrl: info.artUrl!, fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Image.asset(
                                'assets/images/logo.jpg', fit: BoxFit.cover))
                        : Image.asset('assets/images/logo.jpg', fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 24),
                if (error != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text('Error: $error',
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                        textAlign: TextAlign.center),
                  )
                else if (isPlaying) ...[
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(width: 8, height: 8,
                        decoration: const BoxDecoration(
                            color: Color(0xFF1DB954), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text('EN VIVO', style: TextStyle(
                        fontSize: 11, color: Color(0xFF1DB954),
                        fontWeight: FontWeight.w700, letterSpacing: 2)),
                  ]),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(info.title, style: const TextStyle(
                        fontSize: 16, color: Colors.black87,
                        fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center, maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(height: 4),
                  Text(info.artist, style: const TextStyle(
                      fontSize: 13, color: Colors.black45)),
                ] else ...[
                  const Text('Urbano 106 FM', style: TextStyle(
                      fontSize: 16, color: Colors.black54,
                      fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  const Text('Presioná play para escuchar', style: TextStyle(
                      fontSize: 12, color: Colors.black38)),
                ],
                const SizedBox(height: 36),
                GestureDetector(
                  onTap: isLoading ? null : radio.togglePlay,
                  child: Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1DB954), Color(0xFFFFD600), Color(0xFFE53935)],
                      ),
                      boxShadow: [BoxShadow(
                        color: const Color(0xFF1DB954).withOpacity(0.35),
                        blurRadius: 20, spreadRadius: 2,
                      )],
                    ),
                    child: isLoading
                        ? const Padding(padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white, size: 36),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
