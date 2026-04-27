import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProgramacionScreen extends StatefulWidget {
  @override
  State<ProgramacionScreen> createState() => _ProgramacionScreenState();
}

class _ProgramacionScreenState extends State<ProgramacionScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _loading = true),
        onPageFinished: (_) => setState(() => _loading = false),
      ))
      ..loadRequest(Uri.parse('https://www.urbano106.com/programacion-app/'));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      WebViewWidget(controller: _controller),
      if (_loading)
        const Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFF1DB954)))),
    ]);
  }
}
