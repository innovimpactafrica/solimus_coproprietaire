import 'package:flutter/material.dart';
import 'splash1.dart';

class Splash0 extends StatefulWidget {
  const Splash0({super.key});

  @override
  State<Splash0> createState() => _Splash0State();
}

class _Splash0State extends State<Splash0> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      _controller.forward().then((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const Splash1(),
            transitionDuration: Duration.zero,
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: const Scaffold(
        backgroundColor: Color(0xFF6F675E),
        body: SizedBox.expand(),
      ),
    );
  }
}
