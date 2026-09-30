import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../services/auth_storage.dart';

class DocumentViewerPage extends StatefulWidget {
  final String fileName;
  final String fileUrl;

  const DocumentViewerPage({
    super.key,
    required this.fileName,
    required this.fileUrl,
  });

  @override
  State<DocumentViewerPage> createState() => _DocumentViewerPageState();
}

class _DocumentViewerPageState extends State<DocumentViewerPage> {
  WebViewController? _controller;
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    final token = await AuthStorage.getToken();
    final url = _buildViewerUrl(widget.fileUrl);
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _isLoading = false),
        onWebResourceError: (_) => setState(() => _isLoading = false),
      ))
      ..loadRequest(
        Uri.parse(url),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );
    if (mounted) setState(() => _controller = controller);
  }

  String _buildViewerUrl(String url) {
    final lower = url.toLowerCase();
    if (lower.endsWith('.pdf') || lower.contains('.pdf?')) return url;
    if (lower.endsWith('.docx') || lower.endsWith('.doc') ||
        lower.endsWith('.xlsx') || lower.endsWith('.xls') ||
        lower.endsWith('.pptx') || lower.endsWith('.ppt')) {
      return 'https://docs.google.com/viewer?url=${Uri.encodeComponent(url)}&embedded=true';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F4),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF6F675E),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 20,
              left: 16,
              right: 16,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/fleche gauche.svg',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.fileName,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                if (_controller != null)
                  WebViewWidget(controller: _controller!),
                if (_isLoading || _controller == null)
                  const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6F675E)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
