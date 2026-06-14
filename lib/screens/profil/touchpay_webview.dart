import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TouchPayWebViewPage extends StatefulWidget {
  final String url;
  const TouchPayWebViewPage({super.key, required this.url});

  @override
  State<TouchPayWebViewPage> createState() => _TouchPayWebViewPageState();
}

class _TouchPayWebViewPageState extends State<TouchPayWebViewPage> {
  WebViewController? _controller;
  bool _loading = true;

  bool _isSuccess(String url) =>
      url.contains('payment-success') || url.contains('payment/success');

  bool _isFailure(String url) =>
      url.contains('payment-failed') || url.contains('payment/failed');

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() => _loading = true);
        },
        onPageFinished: (url) {
          if (mounted) setState(() => _loading = false);
          if (token.isNotEmpty) {
            _controller?.runJavaScript(
              "localStorage.setItem('accessToken', '$token');"
              "localStorage.setItem('token', '$token');"
              "localStorage.setItem('authToken', 'Bearer $token');",
            );
          }
          if (_isSuccess(url)) {
            Navigator.of(context).pop(true);
          } else if (_isFailure(url)) {
            Navigator.of(context).pop(false);
          }
        },
        onNavigationRequest: (request) {
          if (_isSuccess(request.url)) {
            Navigator.of(context).pop(true);
            return NavigationDecision.prevent;
          }
          if (_isFailure(request.url)) {
            Navigator.of(context).pop(false);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(
        Uri.parse(widget.url),
        headers: token.isNotEmpty ? {'Authorization': 'Bearer $token'} : {},
      );

    if (mounted) setState(() => _controller = controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6F675E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        title: Text(
          'Paiement TouchPay',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          if (_controller != null) WebViewWidget(controller: _controller!),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF6F675E)),
            ),
        ],
      ),
    );
  }
}
