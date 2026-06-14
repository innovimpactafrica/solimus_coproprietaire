import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import 'reset_password.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;

  const OtpVerificationPage({super.key, required this.email});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  Future<void> _onVerifier() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir le code complet')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final token = await AuthService.verifyResetCode(
        emailOrPhone: widget.email,
        code: code,
      );
      if (!mounted) return;
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              ResetPasswordPage(email: widget.email, token: token),
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

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 84.5,
      height: 60,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
        style: GoogleFonts.beVietnamPro(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: const Color(0xFF231F20),
        ),
        decoration: InputDecoration(
          hintText: '*',
          hintStyle: GoogleFonts.beVietnamPro(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            height: 1.0,
            color: const Color(0xFF6F675E),
          ),
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
            borderSide: const BorderSide(color: Color(0xFF1EA438)),
          ),
        ),
      ),
    );
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
                  'Vérification OTP',
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
                  "Entrez le code de vérification que nous venons d'envoyer sur votre adresse e-mail.",
                  style: GoogleFonts.beVietnamPro(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    height: 30 / 16,
                    letterSpacing: 0,
                    color: const Color(0x99212121),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, _buildOtpBox),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onVerifier,
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
                            'Vérifier',
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
          Positioned(
            bottom: 55,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Vous n'avez pas reçu le code ?",
                  style: GoogleFonts.beVietnamPro(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    height: 1.0,
                    color: const Color(0x99231F20),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Renvoyer',
                    style: GoogleFonts.beVietnamPro(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      height: 1.0,
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
