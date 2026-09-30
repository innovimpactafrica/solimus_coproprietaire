// lib/screens/locataire/locataire_signalement_detail.dart
// Écran de détail d'un signalement pour le Locataire.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/locataire_models.dart';
import '../../services/locataire_service.dart';

class LocataireSignalementDetailPage extends StatefulWidget {
  final SignalementLocataire? signalement;
  final int? signalementId;

  const LocataireSignalementDetailPage({
    super.key,
    this.signalement,
    this.signalementId,
  });

  @override
  State<LocataireSignalementDetailPage> createState() =>
      _LocataireSignalementDetailPageState();
}

class _LocataireSignalementDetailPageState
    extends State<LocataireSignalementDetailPage> {
  TenantSignalementDetailModel? _detail;
  bool _isLoading = true;
  String? _errorMessage;

  int get _targetId {
    if (widget.signalementId != null) return widget.signalementId!;
    if (widget.signalement != null) {
      return int.tryParse(widget.signalement!.id) ?? 0;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = _targetId;
    if (id <= 0) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final detail = await LocataireService.getSignalementDetail(id);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  (Color, Color, String, IconData) _statutInfo(String status) {
    switch (status.toUpperCase()) {
      case 'EN_ATTENTE':
      case 'PENDING':
        return (
          const Color(0xFFE17100),
          const Color(0xFFFFF4E6),
          'En attente',
          Icons.hourglass_top_rounded
        );
      case 'IN_PROGRESS':
      case 'EN_COURS':
      case 'ENCOURS':
        return (
          const Color(0xFF2B7FFF),
          const Color(0xFFEEF4FF),
          'En cours',
          Icons.sync_rounded
        );
      case 'RESOLVED':
      case 'RÉSOLU':
      case 'RESOLU':
      case 'FINAL_VALIDATION':
        return (
          const Color(0xFF00A63E),
          const Color(0xFFEFFFF6),
          'Résolu',
          Icons.check_circle_outline_rounded
        );
      default:
        return (
          const Color(0xFF6A7282),
          const Color(0xFFF3F4F6),
          status,
          Icons.info_outline_rounded
        );
    }
  }

  (Color, Color, String) _urgencyInfo(String? urgency) {
    switch ((urgency ?? '').toUpperCase()) {
      case 'HAUTE':
      case 'HIGH':
      case 'URGENT':
      case 'CRITIQUE':
        return (const Color(0xFFDC2626), const Color(0xFFFFF0F0), 'Priorité Haute');
      case 'MOYENNE':
      case 'MEDIUM':
      case 'MOYEN':
        return (const Color(0xFFE17100), const Color(0xFFFFF4E6), 'Priorité Moyenne');
      case 'FAIBLE':
      case 'LOW':
        return (const Color(0xFF00A63E), const Color(0xFFEFFFF6), 'Priorité Faible');
      default:
        return (const Color(0xFF6A7282), const Color(0xFFF3F4F6), 'Priorité Normale');
    }
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    const months = [
      '', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${d.day} ${months[d.month]} ${d.year} à ${d.hour.toString().padLeft(2, '0')}h${d.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateShort(DateTime? d) {
    if (d == null) return '';
    const months = [
      '', 'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  String _formatTimeOnly(DateTime? d) {
    if (d == null) return '';
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final d = _detail;
    final fallback = widget.signalement;

    final title = d?.title ?? fallback?.titre ?? 'Signalement';
    final ref = d?.reference ?? (fallback != null ? 'SIG-${fallback.id}' : '');
    final statusStr = d?.status ?? fallback?.statut.name ?? 'PENDING';
    final (statusColor, statusBg, statusLabel, statusIcon) = _statutInfo(statusStr);
    final (urgencyColor, urgencyBg, urgencyLabel) = _urgencyInfo(d?.urgencyLevel ?? fallback?.priorite.name);

    final description = d?.description != null && d!.description!.isNotEmpty
        ? d.description!
        : (fallback?.description.isNotEmpty == true ? fallback!.description : 'Aucune description fournie.');

    final photoUrls = d?.photoUrls ?? fallback?.photoUrls ?? [];

    final authorName = d != null
        ? (d.fromTenant
            ? '${d.tenantName ?? "Locataire"} (Locataire)'
            : '${d.declaredByName ?? "Copropriétaire"} (Copropriétaire)')
        : null;

    final locationStr = [
      d?.residenceName,
      d?.positionLabel,
    ].where((e) => e != null && e.isNotEmpty).join(' • ');

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F4),
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(
                16, MediaQuery.of(context).padding.top + 16, 16, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF6F675E),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Détail du signalement',
                              style: GoogleFonts.jost(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          if (ref.isNotEmpty)
                            Text(ref,
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6F675E)))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Statut principal & Urgence
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0x0D000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 4))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: statusBg,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: statusColor.withValues(alpha: 0.4)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(statusIcon,
                                            size: 13, color: statusColor),
                                        const SizedBox(width: 5),
                                        Text(statusLabel,
                                            style: GoogleFonts.inter(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: statusColor)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: urgencyBg,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(urgencyLabel,
                                        style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: urgencyColor)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(title,
                                  style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF2D2520))),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  SvgPicture.asset('assets/icons/calendar.svg',
                                      width: 14, height: 14),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Déclaré le ${_formatDate(d?.createdAt ?? fallback?.date)}',
                                      style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: const Color(0xFF6A7282)),
                                    ),
                                  ),
                                ],
                              ),
                              if (authorName != null) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline_rounded,
                                        size: 14, color: Color(0xFF6A7282)),
                                    const SizedBox(width: 6),
                                    Text('Par : $authorName',
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF2D2520))),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Description
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0x0D000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 4))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Description',
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF2D2520))),
                              const SizedBox(height: 8),
                              Text(description,
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: const Color(0xFF374151),
                                      height: 1.5)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Photos
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0x0D000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 4))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Photos du signalement',
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF2D2520))),
                              const SizedBox(height: 12),
                              photoUrls.isNotEmpty
                                  ? Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: photoUrls.map((url) {
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.network(
                                            url,
                                            width: (MediaQuery.of(context).size.width - 72) / 2,
                                            height: 120,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              width: (MediaQuery.of(context).size.width - 72) / 2,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF3F4F6),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                  Icons.image_not_supported_outlined,
                                                  color: Color(0xFF9CA3AF)),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Text(
                                        'Aucune photo jointe',
                                        style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color: const Color(0xFF9CA3AF)),
                                      ),
                                    ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Logement concerné
                        if (locationStr.isNotEmpty)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0x0D000000),
                                    blurRadius: 20,
                                    offset: Offset(0, 4))
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0EDE8),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset('assets/icons/clef.svg',
                                        width: 20, height: 20),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Logement / Localisation',
                                          style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFF6A7282))),
                                      const SizedBox(height: 2),
                                      Text(locationStr,
                                          style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF2D2520))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Suivi / Timeline de traitement
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0x0D000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 4))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Historique du traitement',
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF2D2520))),
                              const SizedBox(height: 16),
                              if (d != null && d.history.isNotEmpty)
                                ...List.generate(d.history.length, (i) {
                                  final h = d.history[i];
                                  final isLast = i == d.history.length - 1;
                                  return _timelineItem(
                                    title: h.label,
                                    subtitle: h.changedByName != null && h.changedByName!.isNotEmpty
                                        ? 'Par ${h.changedByName}'
                                        : (h.status.isNotEmpty ? h.status : 'Mise à jour'),
                                    dateStr: h.date != null ? _formatDateShort(h.date) : '',
                                    timeStr: h.date != null ? _formatTimeOnly(h.date) : '',
                                    isDone: true,
                                    isLast: isLast,
                                  );
                                })
                              else ...[
                                _timelineItem(
                                  title: 'Signalement transmis',
                                  subtitle: 'Enregistré auprès du syndic',
                                  dateStr: _formatDateShort(d?.createdAt ?? fallback?.date),
                                  timeStr: _formatTimeOnly(d?.createdAt ?? fallback?.date),
                                  isDone: true,
                                  isLast: true,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _timelineItem({
    required String title,
    required String subtitle,
    required String dateStr,
    String timeStr = '',
    required bool isDone,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isDone ? const Color(0xFF00A63E) : const Color(0xFFD6D2C9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 12, color: Colors.white),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isDone ? const Color(0xFF00A63E) : const Color(0xFFE5E7EB),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(title,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D2520))),
                  ),
                  Text('$dateStr $timeStr'.trim(),
                      style: GoogleFonts.inter(
                          fontSize: 11, color: const Color(0xFF6A7282))),
                ],
              ),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: const Color(0xFF6A7282))),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
