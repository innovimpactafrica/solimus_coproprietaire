import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/intervention_model.dart';
import '../../services/coowner_service.dart';
import '../profil/touchpay_webview.dart';

class DevisValidePage extends StatefulWidget {
  final int interventionId;
  const DevisValidePage({super.key, required this.interventionId});

  @override
  State<DevisValidePage> createState() => _DevisValidPageState();
}

class _DevisValidPageState extends State<DevisValidePage> {
  void _showPaymentSheet(BuildContext context) {
    final pageNav = Navigator.of(context);
    final scaffoldMsg = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (_) => _AcomptePaymentSheet(
        interventionId: widget.interventionId,
        pageNav: pageNav,
        scaffoldMsg: scaffoldMsg,
      ),
    );
  }

  Widget _contactRow(String iconPath, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SvgPicture.asset(iconPath, width: 18, height: 18),
          const SizedBox(width: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2D2520),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statColumn(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6F675E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF9CA3AF),
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _lineItem(String name, String detail, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D2520),
                  ),
                ),
                Text(
                  detail,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2520),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sousTotal(String label, String price) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2520),
            ),
          ),
          Text(
            price,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2520),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F4),
      body: Column(
        children: [
          // Header
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Fuite d'eau de la salle de bien",
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Résidences les Jardins - A12',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF6F675E),
                          Color(0xFF6D655C),
                          Color(0xFF6A625A),
                          Color(0xFF686058),
                          Color(0xFF665E55),
                          Color(0xFF635B53),
                          Color(0xFF615951),
                          Color(0xFF5F574F),
                          Color(0xFF5C544D),
                          Color(0xFF5A524B),
                        ],
                        stops: [0.0, 0.1111, 0.2222, 0.3333, 0.4444, 0.5556, 0.6667, 0.7778, 0.8889, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0x33FFFFFF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/icons/check.svg',
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Statut',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.white.withValues(alpha: 0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'En attente',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 24 / 16,
                                        letterSpacing: -0.31,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Montant total',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '56 200 FCFA',
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    height: 32 / 24,
                                    letterSpacing: 0.07,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
                        const SizedBox(height: 16),
                        // Two date columns
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Envoyé le',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '08 Mai 2026',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    height: 20 / 14,
                                    letterSpacing: -0.15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 40),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Validé le',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '10 Mai 2026',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    height: 20 / 14,
                                    letterSpacing: -0.15,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Provider card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFF3F4F6), width: 2),
                                    image: const DecorationImage(
                                      image: AssetImage('assets/images/prof.jpg'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: SvgPicture.asset(
                                    'assets/icons/certif.svg',
                                    width: 18,
                                    height: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Plomberie Sénégal',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2D2520),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: Color(0xFFF9C20A), size: 16),
                                    const SizedBox(width: 3),
                                    Text(
                                      '4.8 (56 avis)',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: const Color(0xFF6A7282),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _contactRow('assets/icons/indic.svg', '+221 33 800 00 00'),
                        const SizedBox(height: 8),
                        _contactRow('assets/icons/send.svg', 'contact@plomberie-sn.com'),
                        const SizedBox(height: 8),
                        _contactRow('assets/icons/pos.svg', 'Rue 12, Dakar, Sénégal'),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFFF3F4F6), height: 1),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _statColumn('120', 'INTERVENTIONS'),
                            Container(width: 1, height: 36, color: const Color(0xFFF3F4F6)),
                            _statColumn('98%', 'SATISFACTION'),
                            Container(width: 1, height: 36, color: const Color(0xFFF3F4F6)),
                            _statColumn('3h', 'TEMPS MOY.'),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Matériels card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: const Color(0x1A6F675E),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: SvgPicture.asset(
                                'assets/icons/mats.svg',
                                width: 16,
                                height: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Matériels',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2D2520),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _lineItem('Tuyau PVC Ø32mm', '3 × 2 500 FCFA', '7 500 FCFA'),
                        _lineItem('Raccords T', '2 × 1 800 FCFA', '3 600 FCFA'),
                        _lineItem('Colle PVC', '1 × 3 500 FCFA', '3 500 FCFA'),
                        _lineItem('Ruban téflon', '2 × 800 FCFA', '1 600 FCFA'),
                        const Divider(color: Color(0xFFF3F4F6), height: 16),
                        _sousTotal('Sous-total matériels', '16 200 FCFA'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Main d'œuvre card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: SvgPicture.asset(
                                'assets/icons/mo.svg',
                                width: 16,
                                height: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Main d'œuvre",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2D2520),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _lineItem('Diagnostic et localisation fuite', '1h × 8 000 FCFA/h', '8 000 FCFA'),
                        _lineItem('Réparation canalisation', '3h × 8 000 FCFA/h', '24 000 FCFA'),
                        _lineItem('Test étanchéité', '1h × 8 000 FCFA/h', '8 000 FCFA'),
                        const Divider(color: Color(0xFFF3F4F6), height: 16),
                        _sousTotal("Sous-total main d'œuvre", '40 000 FCFA'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Total TTC
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2520),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total TTC',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '56 200 ',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: 'FCFA',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Payer l'acompte
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => _showPaymentSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF9A826),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.payment_rounded, size: 20),
                      label: Text(
                        'Payer l\'acompte',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayMethod {
  final String name;
  final String key;
  final String imagePath;
  const _PayMethod(this.name, this.key, this.imagePath);
}

class _AcomptePaymentSheet extends StatefulWidget {
  final int interventionId;
  final NavigatorState pageNav;
  final ScaffoldMessengerState scaffoldMsg;

  const _AcomptePaymentSheet({
    required this.interventionId,
    required this.pageNav,
    required this.scaffoldMsg,
  });

  @override
  State<_AcomptePaymentSheet> createState() => _AcomptePaymentSheetState();
}

class _AcomptePaymentSheetState extends State<_AcomptePaymentSheet> {
  static const _methods = [
    _PayMethod('Wave', 'WAVE', 'assets/images/wave.png'),
    _PayMethod('Orange Money', 'ORANGE_MONEY', 'assets/images/om.png'),
  ];

  BalanceSummaryModel? _summary;
  bool _loadingSummary = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    try {
      final s = await CoOwnerService.getBalanceSummary(widget.interventionId);
      if (!mounted) return;
      setState(() { _summary = s; _loadingSummary = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingSummary = false);
    }
  }

  Future<void> _onPay(String methodKey) async {
    setState(() => _submitting = true);
    final sheetNav = Navigator.of(context);
    try {
      final result = await CoOwnerService.payAcompte(
        interventionId: widget.interventionId,
        montant: _summary?.soldeRestant ?? 0,
        methode: methodKey,
      );
      if (!mounted) return;
      sheetNav.pop();

      const baseUrl = 'https://api.solimus.sn';
      final bridgeUrl = '$baseUrl/touchpay-bridge.html'
          '?ref=${result.transactionReference}'
          '&apiBaseUrl=$baseUrl';

      await widget.pageNav.push<bool>(
        MaterialPageRoute(builder: (_) => TouchPayWebViewPage(url: bridgeUrl)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      widget.scaffoldMsg.showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), duration: const Duration(seconds: 6)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Payer l\'acompte', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520))),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: _loadingSummary
                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6F675E)))
                : Text(
                    _summary != null
                        ? 'Montant : ${_summary!.soldeRestant.toInt()} FCFA'
                        : 'Choisissez votre méthode de paiement',
                    style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6A7282)),
                  ),
          ),
          const SizedBox(height: 20),
          ..._methods.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: (_submitting || _loadingSummary) ? null : () => _onPay(m.key),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2D2520),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(m.imagePath, width: 40, height: 40, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 16),
                    Text(m.name, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    if (_submitting) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6F675E))),
                  ],
                ),
              ),
            ),
          )),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: _submitting ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                side: const BorderSide(color: Color(0xFF6F675E)),
              ),
              child: Text('Annuler', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF6A7282))),
            ),
          ),
        ],
      ),
    );
  }
}
