import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/property_model.dart';
import '../../models/residence_model.dart';
import '../../services/auth_service.dart';
import '../../services/coowner_service.dart';
import 'login.dart';
import 'otp_verification.dart';

class Inscription2Page extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String phone;
  final String email;

  const Inscription2Page({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
  });

  @override
  State<Inscription2Page> createState() => _Inscription2PageState();
}

class _Inscription2PageState extends State<Inscription2Page> {
  ResidenceModel? _selectedResidence;
  PropertyModel? _selectedProperty;
  bool _isLoading = false;
  bool _isLoadingResidences = true;
  bool _isLoadingProperties = false;
  List<ResidenceModel> _residences = [];
  List<PropertyModel> _properties = [];

  @override
  void initState() {
    super.initState();
    _loadResidences();
  }

  Future<void> _loadResidences() async {
    try {
      final residences = await CoOwnerService.getPublicResidences();
      if (!mounted) return;
      setState(() {
        _residences = residences;
        _isLoadingResidences = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingResidences = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  TextStyle get _labelStyle => GoogleFonts.beVietnamPro(
        fontWeight: FontWeight.w600,
        fontSize: 15,
        height: 1.0,
        letterSpacing: 0,
        color: const Color(0xFF646B78),
      );

  InputDecoration get _dropdownDecoration => InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
      );

  Future<void> _loadProperties(int residenceId) async {
    setState(() {
      _isLoadingProperties = true;
      _selectedProperty = null;
      _properties = [];
    });
    try {
      final properties = await CoOwnerService.getPublicProperties(residenceId);
      if (!mounted) return;
      setState(() {
        _properties = properties;
        _isLoadingProperties = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingProperties = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _onInscrire() async {
    if (_selectedResidence == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir votre résidence')),
      );
      return;
    }

    if (_selectedProperty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir votre appartement')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.register(
        firstName: widget.firstName,
        lastName: widget.lastName,
        phone: widget.phone,
        email: widget.email,
        residenceId: _selectedResidence!.id,
        propertyId: _selectedProperty!.id,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => OtpVerificationPage(
            email: widget.email,
            isRegistration: true,
          ),
        ),
        (route) => false,
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
          Positioned.fill(
            top: 130,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INSCRIPTION',
                    style: GoogleFonts.beVietnamPro(
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      height: 1.0,
                      letterSpacing: 24 * 0.05,
                      color: const Color(0xFF231F20),
                    ),
                  ),
                  const SizedBox(height: 28),

                  Text('Résidence', style: _labelStyle),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ResidenceModel>(
                    value: _selectedResidence,
                    hint: Text(
                      _isLoadingResidences
                          ? 'Chargement...'
                          : 'Choisir votre résidence',
                      style: GoogleFonts.beVietnamPro(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: const Color(0x4D202221),
                      ),
                    ),
                    items: _residences
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(
                                r.name,
                                style: GoogleFonts.beVietnamPro(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: const Color(0xFF231F20),
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: _isLoadingResidences
                        ? null
                        : (v) {
                            setState(() => _selectedResidence = v);
                            if (v != null) _loadProperties(v.id);
                          },
                    decoration: _dropdownDecoration,
                    dropdownColor: const Color(0xFFFAF9F4),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF6F675E)),
                    isExpanded: true,
                  ),

                  const SizedBox(height: 20),

                  Text('Appartement', style: _labelStyle),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<PropertyModel>(
                    value: _selectedProperty,
                    hint: Text(
                      _isLoadingProperties
                          ? 'Chargement...'
                          : 'Choisir votre appartement',
                      style: GoogleFonts.beVietnamPro(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: const Color(0x4D202221),
                      ),
                    ),
                    items: _properties
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(
                                p.name,
                                style: GoogleFonts.beVietnamPro(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: const Color(0xFF231F20),
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: (_isLoadingProperties || _selectedResidence == null)
                        ? null
                        : (v) => setState(() => _selectedProperty = v),
                    decoration: _dropdownDecoration,
                    dropdownColor: const Color(0xFFFAF9F4),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF6F675E)),
                    isExpanded: true,
                  ),

                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onInscrire,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6F675E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 17),
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
                              "S'inscrire",
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
          ),
          Positioned(
            bottom: 55,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Vous avez déjà un compte ?',
                  style: GoogleFonts.beVietnamPro(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 1.0,
                    color: const Color(0x99231F20),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (_) => false,
                  ),
                  child: Text(
                    'Se connecter',
                    style: GoogleFonts.beVietnamPro(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
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
