import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_storage.dart';

class AuthImage extends StatefulWidget {
  final String url;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget fallback;

  const AuthImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    required this.fallback,
  });

  @override
  State<AuthImage> createState() => _AuthImageState();
}

class _AuthImageState extends State<AuthImage> {
  Uint8List? _bytes;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load(widget.url);
  }

  @override
  void didUpdateWidget(AuthImage old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) {
      setState(() { _bytes = null; _error = false; });
      _load(widget.url);
    }
  }

  Future<void> _load(String url) async {
    try {
      final token = await AuthStorage.getToken();
      final res = await http.get(
        Uri.parse(url),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        setState(() => _bytes = res.bodyBytes);
      } else {
        setState(() => _error = true);
      }
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) return widget.fallback;
    if (_bytes == null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Center(
          child: SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }
    return Image.memory(
      _bytes!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
    );
  }
}
