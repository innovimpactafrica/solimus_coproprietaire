import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/intervention_model.dart';
import '../../services/coowner_service.dart';

class SignalementDetailPage extends StatefulWidget {
  final int interventionId;
  const SignalementDetailPage({super.key, required this.interventionId});

  @override
  State<SignalementDetailPage> createState() => _SignalementDetailPageState();
}

class _SignalementDetailPageState extends State<SignalementDetailPage> {
  SignalementDetailModel? _detail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await CoOwnerService.getSignalementDetail(widget.interventionId);
      if (!mounted) return;
      setState(() { _detail = d; _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), duration: const Duration(seconds: 6)),
      );
    }
  }

  String _formatDate(String? raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw);
      const months = ['', 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
        'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
      return '${dt.day} ${months[dt.month]} ${dt.year} à ${dt.hour.toString().padLeft(2, '0')}h${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) { return raw; }
  }

  String _formatTimeOnly(String? raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) { return ''; }
  }

  String _formatDateShort(String? raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw);
      const months = ['', 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
        'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) { return raw; }
  }

  Color _urgencyTextColor(String? u) {
    switch ((u ?? '').toUpperCase()) {
      case 'HAUTE': case 'HIGH': case 'CRITIQUE': return const Color(0xFFDC2626);
      case 'MOYENNE': case 'MEDIUM':              return const Color(0xFFE17100);
      case 'FAIBLE': case 'LOW':                  return const Color(0xFF00A63E);
      default:                                    return const Color(0xFF6A7282);
    }
  }

  Color _urgencyBgColor(String? u) {
    switch ((u ?? '').toUpperCase()) {
      case 'HAUTE': case 'HIGH': case 'CRITIQUE': return const Color(0xFFFFF0F0);
      case 'MOYENNE': case 'MEDIUM':              return const Color(0xFFFFF4E6);
      case 'FAIBLE': case 'LOW':                  return const Color(0xFFEFFFF6);
      default:                                    return const Color(0xFFF3F4F6);
    }
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Text(
      title,
      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700,
          color: const Color(0xFF9CA3AF), letterSpacing: 1.2),
    ),
  );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 20, color: const Color(0xFF8B7355)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600,
            color: const Color(0xFF9CA3AF), letterSpacing: 0.8)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600,
            color: const Color(0xFF1C1C1E))),
      ]),
    ]),
  );

  Widget _section({required String title, required Widget child}) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 2))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle(title),
      child,
    ]),
  );

  Widget _buildTimeline() {
    final d = _detail!;
    // history est ordonné du plus récent au plus ancien (index 0 = actif)
    final entries = d.history.isNotEmpty
        ? d.history
        : [
            SignalementHistoryEntry(status: d.status, label: 'Signalement envoyé', date: d.createdAt),
          ];
    return Column(
      children: List.generate(entries.length, (i) {
        final e = entries[i];
        final isActive = i == 0;
        final isLast = i == entries.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 36,
                child: Column(children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFF9C20A) : const Color(0xFFE5E7EB),
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : const Color(0xFF9CA3AF),
                        shape: BoxShape.circle,
                      ),
                    )),
                  ),
                  if (!isLast)
                    Expanded(child: Container(
                      width: 2, color: const Color(0xFFE5E7EB),
                      margin: const EdgeInsets.symmetric(vertical: 2),
                    )),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.label,
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1C1C1E))),
                            const SizedBox(height: 3),
                            Text(
                              isActive ? 'En attente' : _formatDateShort(e.date),
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500,
                                  color: isActive ? const Color(0xFFE17100) : const Color(0xFF9CA3AF)),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatTimeOnly(e.date),
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500,
                            color: const Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = _detail;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F4),
      body: Column(children: [
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
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  d?.title ?? '—',
                  style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                Text(
                  d?.residenceName ?? '—',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.75)),
                ),
              ]),
            ),
          ]),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF6F675E)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                  child: Column(children: [
                    _section(
                      title: 'INFORMATIONS GÉNÉRALES',
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (d?.reference != null && d!.reference!.isNotEmpty)
                          _infoRow(Icons.tag_outlined, 'RÉFÉRENCE', d.reference!),
                        _infoRow(Icons.location_on_outlined, 'RÉSIDENCE', d?.residenceName ?? '—'),
                        _infoRow(Icons.push_pin_outlined, 'POSITION', d?.positionLabel ?? '—'),
                        _infoRow(Icons.calendar_today_outlined, 'DATE DU SIGNALEMENT', _formatDate(d?.createdAt)),
                        if (d?.declaredByName != null || d?.tenantName != null)
                          _infoRow(Icons.person_outline, 'DÉCLARÉ PAR', d!.fromTenant ? '${d.tenantName ?? "Locataire"} (Locataire)' : '${d.declaredByName ?? "Copropriétaire"} (Copropriétaire)'),
                        if (d?.urgencyLevel != null && d!.urgencyLevel!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: _urgencyBgColor(d.urgencyLevel),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              d.urgencyLevel!,
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
                                  color: _urgencyTextColor(d.urgencyLevel)),
                            ),
                          ),
                      ]),
                    ),
                    _section(
                      title: 'DESCRIPTION',
                      child: Text(
                        d?.description != null && d!.description!.isNotEmpty
                            ? d.description!
                            : 'Aucune description fournie.',
                        style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: const Color(0xFF374151)),
                      ),
                    ),
                    _section(
                      title: 'PHOTOS',
                      child: d != null && d.photoUrls.isNotEmpty
                          ? Wrap(
                              spacing: 10, runSpacing: 10,
                              children: d.photoUrls.map((url) => ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(url,
                                  width: (MediaQuery.of(context).size.width - 72) / 2,
                                  height: 120, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: (MediaQuery.of(context).size.width - 72) / 2,
                                    height: 120,
                                    decoration: BoxDecoration(color: const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(10)),
                                    child: const Icon(Icons.image_not_supported_outlined, color: Color(0xFF9CA3AF)),
                                  ),
                                ),
                              )).toList(),
                            )
                          : Center(child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text('Aucun image ajouté',
                                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF))),
                            )),
                    ),
                    _section(
                      title: 'HISTORIQUE DU TRAITEMENT',
                      child: d != null ? _buildTimeline()
                          : Text('Aucun historique',
                              style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF))),
                    ),
                  ]),
                ),
        ),
      ]),
    );
  }
}
