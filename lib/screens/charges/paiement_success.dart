import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mes_charges.dart';

class PaiementSuccessPage extends StatefulWidget {
  final String amount;
  final String methodName;
  final String chargeTitle;
  final String? reference;
  final String? paidAt;

  const PaiementSuccessPage({
    super.key,
    required this.amount,
    required this.methodName,
    required this.chargeTitle,
    this.reference,
    this.paidAt,
  });

  @override
  State<PaiementSuccessPage> createState() => _PaiementSuccessPageState();
}

class _PaiementSuccessPageState extends State<PaiementSuccessPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (c, a, s) => const MesChargesPage(),
          transitionsBuilder: (c, anim, s, child) => FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 300),
        ),
        (route) => false,
      );
    });
  }

  String _getRef() {
    if (widget.reference != null && widget.reference!.isNotEmpty) {
      return widget.reference!;
    }
    final prefix = widget.methodName == 'Wave'
        ? 'WA'
        : widget.methodName == 'Orange Money'
            ? 'OM'
            : 'CB';
    return 'TRX-$prefix-${DateTime.now().millisecondsSinceEpoch}';
  }

  String _getDate() {
    if (widget.paidAt != null) {
      try {
        final dt = DateTime.parse(widget.paidAt!);
        return '${dt.day.toString().padLeft(2, '0')}/'
            '${dt.month.toString().padLeft(2, '0')}/'
            '${dt.year}';
      } catch (_) {}
    }
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}';
  }

  Widget _infoRow(String label, String value, {bool bold = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6A7282),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: bold ? 16 : 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D2520),
                ),
              ),
            ],
          ),
        ),
        const Divider(color: Color(0xFFF3F4F6), thickness: 1, height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ref = _getRef();
    final date = _getDate();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Confetti background
          Positioned(
            top: 41,
            left: 19,
            child: Image.asset(
              'assets/images/scale.png',
              width: 393,
              height: 852,
              fit: BoxFit.cover,
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Paiement réussi !',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2520),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Votre paiement a été effectué avec succès',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6A7282),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),
                  _infoRow('Montant payé', '${widget.amount} FCFA', bold: true),
                  _infoRow('Méthode', widget.methodName),
                  _infoRow('Date', date),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Référence',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6A7282),
                          ),
                        ),
                        Text(
                          ref,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D2520),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
