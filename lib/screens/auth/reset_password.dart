import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import 'password_success.dart';


class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String token;

  const ResetPasswordPage({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isLoading = false;

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  TextStyle get _labelStyle => GoogleFonts.beVietnamPro(
        fontWeight: FontWeight.w600,
        fontSize: 15,
        height: 1.0,
        letterSpacing: 0,
        color: const Color(0xFF646B78),
      );

  InputDecoration _inputDecoration(
          {required bool visible, required VoidCallback onToggle}) =>
      InputDecoration(
        hintText: '•••••••',
        hintStyle: GoogleFonts.beVietnamPro(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          height: 1.0,
          color: const Color(0x4D202221),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset(
              'assets/icons/oeil masquer.svg',
              fit: BoxFit.contain,
            ),
          ),
        ),
      );

  Future<void> _onReinitialiser() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Les mots de passe ne correspondent pas')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.resetPassword(
        token: widget.token,
        newPassword: password,
        confirmPassword: confirmPassword,
      );
      if (!mounted) return;
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const PasswordSuccessPage(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
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
                  'Création mot de passe',
                  style: GoogleFonts.beVietnamPro(
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    height: 1.0,
                    letterSpacing: 24 * 0.05,
                    color: const Color(0xFF231F20),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Votre nouveau mot de passe doit être unique par rapport à ceux précédemment utilisés.',
                  style: GoogleFonts.beVietnamPro(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    height: 30 / 16,
                    letterSpacing: 0,
                    color: const Color(0x99212121),
                  ),
                ),
                const SizedBox(height: 28),
                Text('Nouveau mot de passe', style: _labelStyle),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: !_newPasswordVisible,
                    decoration: _inputDecoration(
                      visible: _newPasswordVisible,
                      onToggle: () => setState(
                          () => _newPasswordVisible = !_newPasswordVisible),
                    ),
                    style: GoogleFonts.beVietnamPro(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Confirmez le mot de passe', style: _labelStyle),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: TextField(
                    controller: _confirmPasswordController,
                    obscureText: !_confirmPasswordVisible,
                    decoration: _inputDecoration(
                      visible: _confirmPasswordVisible,
                      onToggle: () => setState(() =>
                          _confirmPasswordVisible = !_confirmPasswordVisible),
                    ),
                    style: GoogleFonts.beVietnamPro(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onReinitialiser,
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
                            'Réinitialiser le mot de passe',
                            style: GoogleFonts.barlow(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              height: 1.0,
                              color: const Color(0xFFFFFFFF),
                            ),
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
