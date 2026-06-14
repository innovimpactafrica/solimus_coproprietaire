import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login.dart';

class PasswordSuccessPage extends StatefulWidget {
  const PasswordSuccessPage({super.key});

  @override
  State<PasswordSuccessPage> createState() => _PasswordSuccessPageState();
}

class _PasswordSuccessPageState extends State<PasswordSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      _controller.forward().then((_) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginPage(),
            transitionDuration: Duration.zero,
          ),
          (_) => false,
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
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9F4),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/Successmark.svg',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 24),
              Text(
                'Mot de passe modifié !',
                textAlign: TextAlign.center,
                style: GoogleFonts.beVietnamPro(
                  fontWeight: FontWeight.w600,
                  fontSize: 26,
                  height: 1.0,
                  letterSpacing: 0,
                  color: const Color(0xFF1E232C),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 259,
                child: Text(
                  'Votre mot de passe a été modifié avec succès.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    height: 1.5,
                    letterSpacing: 0,
                    color: const Color(0xFF8391A1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
