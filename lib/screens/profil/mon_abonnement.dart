import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/subscription_models.dart';
import '../../services/coowner_service.dart';
import 'touchpay_webview.dart';

class MonAbonnementPage extends StatefulWidget {
  const MonAbonnementPage({super.key});

  @override
  State<MonAbonnementPage> createState() => _MonAbonnementPageState();
}

class _MonAbonnementPageState extends State<MonAbonnementPage> {
  SubscriptionInfo? _data;
  bool _loading = true;
  String? _error;
  bool _noSubscription = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _noSubscription = false;
    });
    try {
      final data = await CoOwnerService.getSubscription();
      if (mounted) setState(() { _data = data; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      if (msg.contains('404') || msg.contains('abonnement') || msg.contains('subscription')) {
        setState(() { _noSubscription = true; _loading = false; });
      } else {
        setState(() { _error = msg.replaceFirst('Exception: ', ''); _loading = false; });
      }
    }
  }

  Future<void> _showPremiumSheet() async {
    int selectedMethod = 0;
    bool renouvAuto = true;
    bool submitting = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFFAF9F4),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6D2C9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Passer à Premium',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 20, color: const Color(0xFF2D2520)),
              ),
              const SizedBox(height: 6),
              Text(
                'Choisissez votre méthode de paiement',
                style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14, color: const Color(0xFF6A7282)),
              ),
              const SizedBox(height: 20),
              _methodTile(0, 'Wave', 'assets/images/wave.png', selectedMethod, (v) => setSheetState(() => selectedMethod = v)),
              const SizedBox(height: 10),
              _methodTile(1, 'Orange Money', 'assets/images/om.png', selectedMethod, (v) => setSheetState(() => selectedMethod = v)),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => setSheetState(() => renouvAuto = !renouvAuto),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: renouvAuto ? const Color(0xFF6F675E) : Colors.transparent,
                        border: Border.all(color: const Color(0xFF6F675E), width: 1.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: renouvAuto
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Renouvellement automatique',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14, color: const Color(0xFF2D2520)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: submitting
                    ? null
                    : () async {
                        setSheetState(() => submitting = true);
                        final sheetNav = Navigator.of(ctx);
                        final pageNav = Navigator.of(context);
                        final scaffoldMsg = ScaffoldMessenger.of(context);
                        try {
                          const methods = ['WAVE', 'ORANGE_MONEY'];
                          final paymentInit = await CoOwnerService.subscribeToPremium(
                            moyenPaiement: methods[selectedMethod],
                            renouvellementAuto: renouvAuto,
                          );
                          if (!mounted) return;
                          sheetNav.pop();

                          final result = await pageNav.push<bool>(
                            MaterialPageRoute(
                              builder: (_) => TouchPayWebViewPage(url: paymentInit.paymentUrl),
                            ),
                          );

                          if (!mounted) return;
                          if (result == true) {
                            scaffoldMsg.showSnackBar(
                              const SnackBar(
                                content: Text('Paiement effectué avec succès !'),
                                backgroundColor: Color(0xFF00A63E),
                              ),
                            );
                            _load();
                          } else if (result == false) {
                            scaffoldMsg.showSnackBar(
                              const SnackBar(
                                content: Text('Paiement échoué. Veuillez réessayer.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          if (!mounted) return;
                          sheetNav.pop();
                          scaffoldMsg.showSnackBar(
                            SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                          );
                        }
                      },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6F675E),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: submitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Confirmer',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _methodTile(int index, String label, String imagePath, int selected, void Function(int) onSelect) {
    final bool isSelected = selected == index;
    return GestureDetector(
      onTap: () => onSelect(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF6F675E) : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(imagePath, width: 36, height: 36, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: const Color(0xFF2D2520)),
              ),
            ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF6F675E) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFF6F675E) : const Color(0xFFD1D5DC),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['', 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month]} ${d.year}';
  }

  String _formatDateShort(DateTime d) {
    const months = ['', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month]} ${d.year}';
  }

  String _formatAmount(double amount) {
    final str = amount.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(' ');
      buf.write(str[i]);
    }
    return '${buf.toString()} FCFA';
  }

  String _formatPaymentMethod(String raw) {
    switch (raw.toUpperCase()) {
      case 'WAVE':         return 'Wave';
      case 'ORANGE_MONEY': return 'Orange Money';
      default:             return raw;
    }
  }

  Widget _infoBox(String iconPath, String label, String value, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 155,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(iconPath, width: 14, height: 14),
                const SizedBox(width: 6),
                Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 12, color: const Color(0xFFBBBBBB))),
              ],
            ),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: const Color(0xFFFFFFFF))),
          ],
        ),
      ),
    );
  }

  Widget _paymentRow(PaymentHistory p, {bool showDivider = true}) {
    final isPaid = p.statut.toUpperCase().contains('PAI') || p.statut.toUpperCase().contains('PAY');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(p.plan, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: const Color(0xFF2D2520))),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isPaid ? 'Payé' : p.statut,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12,
                        color: isPaid ? const Color(0xFF00A63E) : const Color(0xFF6A7282)),
                  ),
                ),
              ],
            ),
            Text(_formatAmount(p.montant), style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: const Color(0xFF6F675E))),
          ],
        ),
        const SizedBox(height: 4),
        Text(p.reference, style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 12, color: const Color(0xFF6A7282))),
        const SizedBox(height: 2),
        Text(
          '${_formatDateShort(p.date)} • ${_formatPaymentMethod(p.moyenPaiement)}',
          style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 12, color: const Color(0xFF6A7282)),
        ),
        if (showDivider) ...[
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFF3F4F6), thickness: 1, height: 1),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F4),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            SizedBox(
              height: 135,
              child: Stack(
                children: [
                  Container(width: double.infinity, height: 135, color: const Color(0xFF6F675E)),
                  Container(width: double.infinity, height: 135, color: const Color(0x66000000)),
                  Positioned(
                    top: 48,
                    left: 24,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(color: Color(0x33FFFFFF), shape: BoxShape.circle),
                            child: Center(child: SvgPicture.asset('assets/icons/fleche gauche.svg', width: 20, height: 20)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Mon abonnement', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 20, height: 32 / 20, letterSpacing: 0.07, color: const Color(0xFFFFFFFF))),
                            const SizedBox(height: 2),
                            Text('Consultez et gérez mon abonnement', style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14, height: 20 / 14, letterSpacing: -0.15, color: const Color(0xFFFFFFFF))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: CircularProgressIndicator(color: Color(0xFF6F675E)),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                child: Column(
                  children: [
                    Text(_error!, textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.red)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _load,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6F675E)),
                      child: const Text('Réessayer', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              )
            else if (_noSubscription) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(color: const Color(0x1A6F675E), borderRadius: BorderRadius.circular(16)),
                            child: Center(child: SvgPicture.asset('assets/icons/premium.svg', width: 28, height: 28)),
                          ),
                          const SizedBox(height: 16),
                          Text('Aucun abonnement actif', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18, color: const Color(0xFF2D2520))),
                          const SizedBox(height: 8),
                          Text(
                            'Passez à Premium pour accéder à toutes les fonctionnalités.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14, color: const Color(0xFF6A7282)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _showPremiumSheet,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(color: const Color(0xFF6F675E), borderRadius: BorderRadius.circular(15)),
                        child: Center(
                          child: Text("Passer à l'abonnement Premium", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Carte abonnement
              Container(
                width: 365,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6F675E), Color(0xFF6D655C), Color(0xFF6A625A), Color(0xFF686058),
                      Color(0xFF665E55), Color(0xFF635B53), Color(0xFF615951), Color(0xFF5F574F),
                      Color(0xFF5C544D), Color(0xFF5A524B),
                    ],
                    stops: [0.0, 0.1111, 0.2222, 0.3333, 0.4444, 0.5556, 0.6667, 0.7778, 0.8889, 1.0],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: const Color(0x1AFFFFFF), borderRadius: BorderRadius.circular(12)),
                          child: Center(child: SvgPicture.asset('assets/icons/actif.svg', width: 24, height: 24)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(d!.plan, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 20, height: 1.0, color: const Color(0xFFFFFFFF))),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: d.active ? const Color(0xFF00A63E) : const Color(0xFF6A7282),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset('assets/icons/renew.svg', width: 12, height: 12),
                                        const SizedBox(width: 4),
                                        Text(
                                          d.active ? 'Actif' : 'Inactif',
                                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12, color: const Color(0xFFFFFFFF)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Abonnement actif jusqu\'au ${_formatDate(d.dateExpiration)}',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 12, color: const Color(0xFFBBBBBB)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _infoBox('assets/icons/calen.svg', 'Activation', _formatDateShort(d.dateActivation)),
                        const SizedBox(width: 12),
                        _infoBox('assets/icons/premium.svg', 'Paiement', _formatPaymentMethod(d.moyenPaiement), onTap: _showPremiumSheet),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0x33FFFFFF), thickness: 0.5, height: 1),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        SvgPicture.asset('assets/icons/renew.svg', width: 16, height: 16),
                        const SizedBox(width: 8),
                        Text(
                          d.renouvellementAuto ? 'Renouvellement automatique activé' : 'Renouvellement automatique désactivé',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 13, color: const Color(0xFFBBBBBB)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              if (!d.active) ...[
                GestureDetector(
                  onTap: _showPremiumSheet,
                  child: Container(
                    width: 365,
                    height: 56,
                    decoration: BoxDecoration(color: const Color(0xFF6F675E), borderRadius: BorderRadius.circular(15)),
                    child: Center(
                      child: Text("Passer à l'abonnement Premium", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (d.avantages.isNotEmpty)
                Container(
                  width: 365,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset('assets/icons/avantage.svg', width: 20, height: 20),
                          const SizedBox(width: 10),
                          Text('Avantages inclus', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: -0.45, color: const Color(0xFF231F20))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...d.avantages.asMap().entries.map((e) => Padding(
                        padding: EdgeInsets.only(bottom: e.key < d.avantages.length - 1 ? 14 : 0),
                        child: Row(
                          children: [
                            SvgPicture.asset('assets/icons/donee.svg', width: 20, height: 20),
                            const SizedBox(width: 10),
                            Expanded(child: Text(e.value, style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 15, height: 1.0, color: const Color(0xFF2D2520)))),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              if (d.historiquePaiements.isNotEmpty)
                Container(
                  width: 365,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(10)),
                            child: Center(child: SvgPicture.asset('assets/icons/cash.svg', width: 16, height: 16)),
                          ),
                          const SizedBox(width: 10),
                          Text('Historique des paiements', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: -0.45, color: const Color(0xFF231F20))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...d.historiquePaiements.asMap().entries.map((e) => _paymentRow(
                        e.value,
                        showDivider: e.key < d.historiquePaiements.length - 1,
                      )),
                    ],
                  ),
                ),

              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }
}
