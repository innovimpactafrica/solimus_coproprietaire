import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/charge_model.dart';
import '../../services/coowner_service.dart';
import '../profil/touchpay_webview.dart';
import 'paiement_success.dart';

enum ChargeStatus { enAttente, enRetard, paye }

class ChargeDetailPage extends StatefulWidget {
  final int chargeId;

  const ChargeDetailPage({super.key, required this.chargeId});

  @override
  State<ChargeDetailPage> createState() => _ChargeDetailPageState();
}

class _ChargeDetailPageState extends State<ChargeDetailPage> {
  ChargeDetailModel? _detail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final detail = await CoOwnerService.getChargeDetail(widget.chargeId);
      if (!mounted) return;
      setState(() { _detail = detail; _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  ChargeStatus _mapStatus(String s) {
    switch (s.toUpperCase()) {
      case 'PAYEE':     return ChargeStatus.paye;
      case 'EN_RETARD': return ChargeStatus.enRetard;
      default:          return ChargeStatus.enAttente;
    }
  }

  String _formatAmount(double amount) {
    final str = amount.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(' ');
      buf.write(str[i]);
    }
    return buf.toString();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr);
      const months = ['', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
        'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildStatusBadge(ChargeStatus status) {
    switch (status) {
      case ChargeStatus.enAttente:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4E6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE17100).withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/icons/pendig1.svg', width: 13, height: 13),
              const SizedBox(width: 5),
              Text('En attente', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFFE17100))),
            ],
          ),
        );
      case ChargeStatus.enRetard:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F0),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 13, color: Color(0xFFDC2626)),
              const SizedBox(width: 5),
              Text('En retard', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFFDC2626))),
            ],
          ),
        );
      case ChargeStatus.paye:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFEFFFF6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00A63E).withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/icons/donee.svg', width: 13, height: 13),
              const SizedBox(width: 5),
              Text('Payé', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF00A63E))),
            ],
          ),
        );
    }
  }

  Widget _repartitionRow(String label, double amount, {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF6A7282))),
              Text('${_formatAmount(amount)} FCFA', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520))),
            ],
          ),
        ),
        if (showDivider) const Divider(color: Color(0xFFF3F4F6), thickness: 1, height: 1),
      ],
    );
  }

  Widget _documentItem(String url) {
    final name = url.contains('/') ? url.split('/').last : url;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Center(child: SvgPicture.asset('assets/icons/file1.svg', width: 20, height: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF2D2520))),
          ),
          SvgPicture.asset('assets/icons/download1.svg', width: 22, height: 22),
        ],
      ),
    );
  }

  Widget _infoRow(String label, Widget value, {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF6A7282))),
              value,
            ],
          ),
        ),
        if (showDivider) const Divider(color: Color(0xFFF3F4F6), thickness: 1, height: 1),
      ],
    );
  }

  Future<void> _showPaymentSheet(BuildContext context, ChargeDetailModel d) async {
    final pageNav = Navigator.of(context);
    final scaffoldMsg = ScaffoldMessenger.of(context);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (_) => _PaymentSheetContent(
        allocationId: d.idAllocation,
        chargeTitle: d.title,
        amount: _formatAmount(d.amount),
        pageNav: pageNav,
        scaffoldMsg: scaffoldMsg,
        onPaymentDone: () => _loadDetail(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = _detail;
    final status = d != null ? _mapStatus(d.status) : ChargeStatus.enAttente;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F4),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF6F675E),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 20, left: 16, right: 16,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), shape: BoxShape.circle),
                    child: Center(child: SvgPicture.asset('assets/icons/fleche gauche.svg', width: 20, height: 20)),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d?.residenceName ?? '—',
                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    Text(
                      d?.reference ?? '',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.white.withValues(alpha: 0.75)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6F675E)))
                : _error != null
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0F0),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Erreur de chargement', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFDC2626))),
                                  const SizedBox(height: 6),
                                  Text('ID envoyé: ${widget.chargeId}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF2D2520))),
                                  const SizedBox(height: 4),
                                  Text(_error!, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6A7282))),
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: _loadDetail,
                                    child: Text('Réessayer', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF6F675E))),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                : d == null
                    ? Center(child: Text('Données indisponibles', style: GoogleFonts.inter(color: const Color(0xFF6A7282))))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Amount card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: const Color(0xFF6F675E), borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Montant', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.white.withValues(alpha: 0.75))),
                                  const SizedBox(height: 6),
                                  Text('${_formatAmount(d.amount)} FCFA', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      SvgPicture.asset('assets/icons/calen.svg', width: 16, height: 16),
                                      const SizedBox(width: 8),
                                      Text('Échéance: ${_formatDate(d.dueDate)}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.white.withValues(alpha: 0.85))),
                                    ],
                                  ),
                                  if (d.residenceName != null || d.propertyReference != null) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 16, color: Colors.white70),
                                        const SizedBox(width: 8),
                                        Text(
                                          [d.residenceName, d.propertyReference].where((e) => e != null && e.isNotEmpty).join(' • '),
                                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.white.withValues(alpha: 0.85)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Informations
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 4))]),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 14),
                                  Text('Informations', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520))),
                                  const SizedBox(height: 4),
                                  _infoRow('Type', Text(d.type, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520)))),
                                  if (d.period != null)
                                    _infoRow('Période', Text(d.period!, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520)))),
                                  _infoRow("Date d'émission", Text(_formatDate(d.createdAt), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520)))),
                                  _infoRow('Statut', _buildStatusBadge(status), showDivider: false),
                                ],
                              ),
                            ),
                            if (d.description != null && d.description!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 4))]),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Description', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520))),
                                    const SizedBox(height: 10),
                                    Text(d.description!, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, height: 1.6, color: const Color(0xFF6A7282))),
                                  ],
                                ),
                              ),
                            ],
                            if (d.lines.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 4))]),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Répartition des frais', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520))),
                                    const SizedBox(height: 4),
                                    ...d.lines.asMap().entries.map((e) =>
                                        _repartitionRow(e.value.label, e.value.amount, showDivider: e.key < d.lines.length - 1)),
                                    const SizedBox(height: 8),
                                    const Divider(color: Color(0xFFE5E7EB), thickness: 1.5, height: 1),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Total', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520))),
                                        Text('${_formatAmount(d.totalAmount)} FCFA', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF6F675E))),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                ),
                              ),
                            ],
                            if (d.documentUrls.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 4))]),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Documents', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520))),
                                    const SizedBox(height: 12),
                                    ...d.documentUrls.asMap().entries.map((e) => Padding(
                                      padding: EdgeInsets.only(bottom: e.key < d.documentUrls.length - 1 ? 10 : 0),
                                      child: _documentItem(e.value),
                                    )),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            if (status != ChargeStatus.paye)
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showPaymentSheet(context, d),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF9A826),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                                    elevation: 0,
                                  ),
                                  icon: SvgPicture.asset('assets/icons/charges.svg', width: 20, height: 20, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                                  label: Text('Payer cette charge', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
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

class _PaymentSheetContent extends StatefulWidget {
  final int allocationId;
  final String chargeTitle;
  final String amount;
  final NavigatorState pageNav;
  final ScaffoldMessengerState scaffoldMsg;
  final VoidCallback onPaymentDone;

  const _PaymentSheetContent({
    required this.allocationId,
    required this.chargeTitle,
    required this.amount,
    required this.pageNav,
    required this.scaffoldMsg,
    required this.onPaymentDone,
  });

  @override
  State<_PaymentSheetContent> createState() => _PaymentSheetContentState();
}

class _PaymentSheetContentState extends State<_PaymentSheetContent> {
  int? _selected;
  bool _waiting = false;

  void _onMethodTap(int i) {
    if (_waiting) return;
    setState(() { _selected = i; _waiting = true; });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      Navigator.of(context).pop();
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        isScrollControlled: true,
        builder: (_) => _ConfirmationSheetContent(
          allocationId: widget.allocationId,
          chargeTitle: widget.chargeTitle,
          amount: widget.amount,
          methodName: _methods[i].name,
          methodKey: _methods[i].methodKey,
          pageNav: widget.pageNav,
          scaffoldMsg: widget.scaffoldMsg,
          onPaymentDone: widget.onPaymentDone,
        ),
      );
    });
  }

  static const _methods = [
    _PaymentMethod(name: 'Wave', subtitle: 'Paiement sécurisé', imagePath: 'assets/images/wave.png', methodKey: 'WAVE'),
    _PaymentMethod(name: 'Orange Money', subtitle: 'Paiement sécurisé', imagePath: 'assets/images/om.png', methodKey: 'ORANGE_MONEY'),
    _PaymentMethod(name: 'Carte bancaire', subtitle: 'Paiement sécurisé', imagePath: null, methodKey: 'CARD'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Choisir une méthode de paiement', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520))),
          ),
          const SizedBox(height: 20),
          ...List.generate(_methods.length, (i) {
            final method = _methods[i];
            final isSelected = _selected == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => _onMethodTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 77,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0x1AF9C20A) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? const Color(0xFFF9C20A) : const Color(0xFFE5E7EB), width: isSelected ? 1.51 : 1.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: method.imagePath != null
                              ? Image.asset(method.imagePath!, width: 52, height: 52, fit: BoxFit.cover)
                              : Container(
                                  width: 52, height: 52,
                                  decoration: BoxDecoration(color: const Color(0xFF1A3A8A), borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(Icons.credit_card, color: Colors.white, size: 28),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(method.name, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520))),
                            Text(method.subtitle, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: const Color(0xFF6F675E))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                side: const BorderSide(color: Color(0xFF6F675E), width: 1),
              ),
              child: Text('Annuler', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF6A7282))),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

class _PaymentMethod {
  final String name;
  final String subtitle;
  final String? imagePath;
  final String methodKey;
  const _PaymentMethod({required this.name, required this.subtitle, required this.imagePath, required this.methodKey});
}

class _ConfirmationSheetContent extends StatefulWidget {
  final int allocationId;
  final String chargeTitle;
  final String amount;
  final String methodName;
  final String methodKey;
  final NavigatorState pageNav;
  final ScaffoldMessengerState scaffoldMsg;
  final VoidCallback onPaymentDone;

  const _ConfirmationSheetContent({
    required this.allocationId,
    required this.chargeTitle,
    required this.amount,
    required this.methodName,
    required this.methodKey,
    required this.pageNav,
    required this.scaffoldMsg,
    required this.onPaymentDone,
  });

  @override
  State<_ConfirmationSheetContent> createState() => _ConfirmationSheetContentState();
}

class _ConfirmationSheetContentState extends State<_ConfirmationSheetContent> {
  bool _submitting = false;

  Future<void> _onConfirmer() async {
    setState(() => _submitting = true);
    final sheetNav = Navigator.of(context);
    try {
      final result = await CoOwnerService.payCharge(
        allocationId: widget.allocationId,
        method: widget.methodKey,
      );
      if (!mounted) return;
      sheetNav.pop();

      const baseUrl = 'https://api.solimus.innovimpactdev.cloud';
      final bridgeUrl = '$baseUrl/touchpay-bridge.html'
          '?ref=${result.transactionReference}'
          '&apiBaseUrl=$baseUrl';

      final webResult = await widget.pageNav.push<bool>(
        MaterialPageRoute(
          builder: (_) => TouchPayWebViewPage(url: bridgeUrl),
        ),
      );

      if (webResult == true) {
        widget.onPaymentDone();
        try {
          final receipt = await CoOwnerService.getPaymentReceipt(result.transactionReference);
          if (!mounted) return;
          widget.pageNav.push(PageRouteBuilder(
            pageBuilder: (_, __, ___) => PaiementSuccessPage(
              amount: receipt.amount.toInt().toString(),
              methodName: receipt.method,
              chargeTitle: receipt.chargeTitle,
              reference: receipt.reference,
              paidAt: receipt.paidAt,
            ),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(
                opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
                child: child),
            transitionDuration: const Duration(milliseconds: 300),
          ));
        } catch (_) {
          widget.scaffoldMsg.showSnackBar(
            const SnackBar(
              content: Text('Paiement effectué avec succès !'),
              backgroundColor: Color(0xFF00A63E),
            ),
          );
        }
      } else if (webResult == false) {
        widget.scaffoldMsg.showSnackBar(
          const SnackBar(
            content: Text('Paiement échoué. Veuillez réessayer.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      widget.scaffoldMsg.showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: bold ? FontWeight.w700 : FontWeight.w400, color: bold ? const Color(0xFF2D2520) : const Color(0xFF6A7282))),
          Text(value, style: GoogleFonts.inter(fontSize: bold ? 20 : 14, fontWeight: FontWeight.w700, color: bold ? const Color(0xFF6F675E) : const Color(0xFF2D2520))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Confirmer le paiement', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520))),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _summaryRow('Charge', widget.chargeTitle),
                const Divider(color: Color(0xFFE5E7EB), height: 1),
                _summaryRow('Méthode', widget.methodName),
                const Divider(color: Color(0xFFE5E7EB), height: 1),
                _summaryRow('Total', '${widget.amount} FCFA', bold: true),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _submitting ? null : _onConfirmer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF9A826),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 0,
              ),
              child: _submitting
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Confirmer le paiement', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                side: const BorderSide(color: Color(0xFF6F675E), width: 1),
              ),
              child: Text('Annuler', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF6A7282))),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}
