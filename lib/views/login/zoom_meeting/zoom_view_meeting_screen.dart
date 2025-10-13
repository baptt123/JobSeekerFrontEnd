import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ZoomWebViewScreen extends StatefulWidget {
  final String meetingUrl;

  const ZoomWebViewScreen({super.key, required this.meetingUrl});

  @override
  State<ZoomWebViewScreen> createState() => _ZoomWebViewScreenState();
}

class _ZoomWebViewScreenState extends State<ZoomWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (request) async {
            final uri = Uri.parse(request.url);
            // ✅ Bổ sung thêm scheme 'zoomus'
            if (uri.scheme == 'zoommtg' || uri.scheme == 'zoomus') {
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                debugPrint('⚠️ Không thể mở URL: $uri');
              }
              return NavigationDecision.prevent; // Ngăn WebView điều hướng
            }
            return NavigationDecision
                .navigate; // Cho phép điều hướng trong WebView
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.meetingUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phỏng vấn Zoom')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
