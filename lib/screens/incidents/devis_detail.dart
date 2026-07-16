import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/intervention_model.dart';
import '../../services/coowner_service.dart';
import 'devis_valide.dart';

class DevisDetailPage extends StatefulWidget {
  final VoidCallback? onValidated;
  final int interventionId;
  final int quoteId;

  const DevisDetailPage({
    super.key,
    this.onValidated,
    required this.interventionId,
    required this.quoteId,
  });

  @override
  State<DevisDetailPage> createState() => _DevisDetailPageState();
}

class _DevisDetailPageState extends State<DevisDetailPage> {
  bool _isValidating = false;
  QuoteModel? _quote;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuote();
  }

  Future<void> _loadQuote() async {
    try {
      final q = await CoOwnerService.getQuoteDetail(widget.interventionId, widget.quoteId);
      if (!mounted) return;
      setState(() { _quote = q; _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
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
      const months = ['', 'jan.', 'fév.', 'mars', 'avr.', 'mai', 'juin',
        'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) { return dateStr; }
  }

  Widget _contactRow(String iconPath, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF9F9F7), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        SvgPicture.asset(iconPath, width: 18, height: 18),
        const SizedBox(width: 12),
        Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF2D2520))),
      ]),
    );
  }

  Widget _statColumn(String value, String label) {
    return Expanded(
      child: Column(children: [
        Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF6F675E))),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF9CA3AF), letterSpacing: 0.3), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _lineItem(String name, String detail, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF2D2520))),
              if (detail.isNotEmpty) Text(detail, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF))),
            ],
          )),
          Text(price, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520))),
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
          Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520))),
          Text(price, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520))),
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
          Container(
            color: const Color(0xFF6F675E),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 20, left: 16, right: 16,
            ),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), shape: BoxShape.circle),
                  child: Center(child: SvgPicture.asset('assets/icons/fleche gauche.svg', width: 20, height: 20)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  _quote?.displayName ?? 'Détail du devis',
                  style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6F675E)))
                : _quote == null
                    ? Center(child: Text('Données indisponibles', style: GoogleFonts.inter(color: const Color(0xFF6A7282))))
                    : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final q = _quote!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF6F675E), Color(0xFF5A524B)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(
                        width: 36, height: 36, padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0x33FFFFFF), borderRadius: BorderRadius.circular(10)),
                        child: SvgPicture.asset('assets/icons/check.svg', width: 20, height: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Statut', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                        const SizedBox(height: 2),
                        Text(q.status, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                      ]),
                    ]),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('Montant total', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                      const SizedBox(height: 4),
                      RichText(text: TextSpan(children: [
                        TextSpan(text: '${_formatAmount(q.totalAmount)} ', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                        TextSpan(text: 'FCFA', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                      ])),
                    ]),
                  ],
                ),
                if (q.createdAt != null) ...[
                  const SizedBox(height: 16),
                  Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
                  const SizedBox(height: 16),
                  Text('Envoyé le', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                  const SizedBox(height: 2),
                  Text(_formatDate(q.createdAt), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                ],
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
              boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 4))],
            ),
            child: Column(children: [
              Row(children: [
                Stack(children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFF3F4F6), width: 2)),
                    child: ClipOval(child: q.providerPhotoUrl != null
                        ? Image.network(q.providerPhotoUrl!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset('assets/images/prof.jpg', fit: BoxFit.cover))
                        : Image.asset('assets/images/prof.jpg', fit: BoxFit.cover)),
                  ),
                  if (q.verified)
                    Positioned(bottom: 0, right: 0,
                        child: SvgPicture.asset('assets/icons/certif.svg', width: 18, height: 18)),
                ]),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(q.displayName, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520))),
                  const SizedBox(height: 3),
                  Row(children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFF9C20A), size: 16),
                    const SizedBox(width: 3),
                    Text('${q.providerRating} (${q.reviewCount} avis)', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6A7282))),
                  ]),
                ]),
              ]),
              const SizedBox(height: 14),
              if (q.providerPhone != null) ...[_contactRow('assets/icons/indic.svg', q.providerPhone!), const SizedBox(height: 8)],
              if (q.providerEmail != null) ...[_contactRow('assets/icons/send.svg', q.providerEmail!), const SizedBox(height: 8)],
              if (q.providerCity != null) _contactRow('assets/icons/pos.svg', q.providerCity!),
              if (q.interventionCount != null || q.satisfactionRate != null || q.avgInterventionTime != null) ...[
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFF3F4F6), height: 1),
                const SizedBox(height: 14),
                Row(children: [
                  if (q.interventionCount != null) _statColumn('${q.interventionCount}', 'INTERVENTIONS'),
                  if (q.satisfactionRate != null) ...[
                    Container(width: 1, height: 36, color: const Color(0xFFF3F4F6)),
                    _statColumn('${q.satisfactionRate!.toInt()}%', 'SATISFACTION'),
                  ],
                  if (q.avgInterventionTime != null) ...[
                    Container(width: 1, height: 36, color: const Color(0xFFF3F4F6)),
                    _statColumn(q.avgInterventionTime!, 'TEMPS MOY.'),
                  ],
                ]),
                const SizedBox(height: 4),
              ],
            ]),
          ),
          const SizedBox(height: 16),
          // Matériels card
          if (q.materialLines.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 4))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 32, height: 32, padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(color: const Color(0x1A6F675E), borderRadius: BorderRadius.circular(10)),
                      child: SvgPicture.asset('assets/icons/mats.svg', width: 16, height: 16)),
                  const SizedBox(width: 8),
                  Text('Matériels', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520))),
                ]),
                const SizedBox(height: 12),
                ...q.materialLines.map((l) => _lineItem(l.description, '', '${_formatAmount(l.subtotal)} FCFA')),
                const Divider(color: Color(0xFFF3F4F6), height: 16),
                _sousTotal('Sous-total matériels', '${_formatAmount(q.materialTotalAmount)} FCFA'),
              ]),
            ),
            const SizedBox(height: 16),
          ],
          // Main d'œuvre card
          if (q.laborLines.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 4))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 32, height: 32, padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(color: const Color(0xFFFEF3C6), borderRadius: BorderRadius.circular(10)),
                      child: SvgPicture.asset('assets/icons/mo.svg', width: 16, height: 16)),
                  const SizedBox(width: 8),
                  Text("Main d'œuvre", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520))),
                ]),
                const SizedBox(height: 12),
                ...q.laborLines.map((l) => _lineItem(l.description, '', '${_formatAmount(l.subtotal)} FCFA')),
                const Divider(color: Color(0xFFF3F4F6), height: 16),
                _sousTotal("Sous-total main d'œuvre", '${_formatAmount(q.laborTotalAmount)} FCFA'),
              ]),
            ),
            const SizedBox(height: 16),
          ],
          // Total TTC
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(color: const Color(0xFF2D2520), borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total TTC', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                RichText(text: TextSpan(children: [
                  TextSpan(text: '${_formatAmount(q.totalAmount)} ', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                  TextSpan(text: 'FCFA', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                ])),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 56,
            child: ElevatedButton(
              onPressed: _isValidating ? null : () async {
                setState(() => _isValidating = true);
                try {
                  await CoOwnerService.acceptQuote(
                    interventionId: widget.interventionId,
                    quoteId: widget.quoteId,
                  );
                  if (!mounted) return;
                  widget.onValidated?.call();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => DevisValidePage(interventionId: widget.interventionId),
                  ));
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), duration: const Duration(seconds: 6)),
                  );
                } finally {
                  if (mounted) setState(() => _isValidating = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF9A826),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 0,
              ),
              child: _isValidating
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Valider le devis', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity, height: 56,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                side: const BorderSide(color: Color(0xFF6F675E), width: 1),
              ),
              child: Text('Annuler', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF6A7282))),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
