import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'splash2.dart';

class Splash1 extends StatefulWidget {
  const Splash1({super.key});

  @override
  State<Splash1> createState() => _Splash1State();
}

class _Splash1State extends State<Splash1> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Splash2()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6F675E),
      body: Center(
        child: SvgPicture.asset(
          'assets/images/solimus logo.svg',
          width: 250,
          height: 95.62841796875,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
