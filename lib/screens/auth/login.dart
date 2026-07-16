import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/auth_storage.dart';
import 'forgot_password.dart';
import 'inscription.dart';
import '../home/home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _passwordVisible = false;
  bool _isLoading = false;

  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  TextStyle get _labelStyle => GoogleFonts.beVietnamPro(
        fontWeight: FontWeight.w600,
        fontSize: 15,
        height: 1.0,
        letterSpacing: 0,
        color: const Color(0xFF646B78),
      );

  TextStyle get _hintStyle => GoogleFonts.beVietnamPro(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        height: 1.0,
        letterSpacing: 0,
        color: const Color(0x802022214D).withValues(alpha: 0.3),
      );

  InputDecoration _inputDecoration({
    required String hint,
    Widget? suffixIcon,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: _hintStyle,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        filled: true,
        fillColor: const Color(0x1A6F675E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFD6D2C9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFD6D2C9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF6F675E)),
        ),
        suffixIcon: suffixIcon,
      );

  Future<void> _onSeConnecter() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await AuthService.login(
        identifier: identifier,
        password: password,
      );

      await AuthStorage.save(
        token: result.accessToken,
        userId: result.id,
        firstName: result.firstName,
        lastName: result.lastName,
        email: result.email,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F4),
      body: Stack(
        children: [
          Positioned(
            top: 62,
            left: 275,
            width: 95,
            height: 36,
            child: SvgPicture.asset(
              'assets/images/solimus logo2.svg',
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 62,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF6F675E),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomPaint(
                    size: const Size(6.67, 13.33),
                    painter: _ChevronPainter(),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONNEXION',
                  style: GoogleFonts.beVietnamPro(
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    height: 1.0,
                    letterSpacing: 24 * 0.05,
                    color: const Color(0xFF231F20),
                  ),
                ),
                const SizedBox(height: 28),
                Text('Identifiant', style: _labelStyle),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: TextField(
                    controller: _identifierController,
                    decoration: _inputDecoration(hint: 'Saisir'),
                    style: GoogleFonts.beVietnamPro(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Mot de passe', style: _labelStyle),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    decoration: _inputDecoration(
                      hint: '•••••••',
                      suffixIcon: GestureDetector(
                        onTap: () => setState(
                            () => _passwordVisible = !_passwordVisible),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SvgPicture.asset(
                            'assets/icons/oeil masquer.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    style: GoogleFonts.beVietnamPro(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) =>
                              const ForgotPasswordPage(),
                          transitionsBuilder: (_, anim, __, child) =>
                              FadeTransition(opacity: anim, child: child),
                          transitionDuration:
                              const Duration(milliseconds: 300),
                        ),
                      );
                    },
                    child: Text(
                      'Mot de passe oublié ?',
                      style: GoogleFonts.beVietnamPro(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 1.0,
                        letterSpacing: 0,
                        color: const Color(0xFF6F675E),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 398,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onSeConnecter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6F675E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 17,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Se connecter',
                            style: GoogleFonts.barlow(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              height: 1.0,
                              letterSpacing: 0,
                              color: const Color(0xFFFFFFFF),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 55,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Vous n\'avez pas de compte ?',
                  style: GoogleFonts.beVietnamPro(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 1.0,
                    letterSpacing: 0,
                    color: const Color(0x99231F20),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const InscriptionPage()),
                  ),
                  child: Text(
                    'S\'inscrire',
                    style: GoogleFonts.beVietnamPro(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      height: 1.0,
                      letterSpacing: 0,
                      color: const Color(0xFFF9C20A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 1.11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, size.height / 2)
      ..lineTo(size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
