// lib/screens/locataire/locataire_travaux_detail.dart
// Écran de détail des travaux pour le Locataire.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/intervention_model.dart';
import '../../models/locataire_models.dart';
import '../../services/locataire_service.dart';

class LocataireTravauxDetailPage extends StatefulWidget {
  final TravauxLocataire? travaux;
  final int? interventionId;

  const LocataireTravauxDetailPage({
    super.key,
    this.travaux,
    this.interventionId,
  });

  @override
  State<LocataireTravauxDetailPage> createState() =>
      _LocataireTravauxDetailPageState();
}

class _LocataireTravauxDetailPageState
    extends State<LocataireTravauxDetailPage> {
  InterventionDetailModel? _detail;
  bool _isLoading = true;

  int get _targetId {
    if (widget.interventionId != null) return widget.interventionId!;
    if (widget.travaux != null) {
      return int.tryParse(widget.travaux!.id) ?? 0;
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
      final detail = await LocataireService.getTenantInterventionDetail(id);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  (Color, Color, String, IconData) _statutInfo(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
      case 'PLANIFIE':
        return (
          const Color(0xFFE17100),
          const Color(0xFFFFF4E6),
          'Intervention planifiée',
          Icons.schedule_rounded
        );
      case 'STARTED':
      case 'IN_PROGRESS':
      case 'EN_COURS':
        return (
          const Color(0xFF2B7FFF),
          const Color(0xFFEEF4FF),
          'Travaux en cours',
          Icons.sync_rounded
        );
      case 'FINISHED':
      case 'FINAL_VALIDATION':
      case 'RESOLVED':
      case 'TERMINE':
        return (
          const Color(0xFF00A63E),
          const Color(0xFFEFFFF6),
          'Travaux terminés',
          Icons.check_circle_outline_rounded
        );
      case 'CANCELLED':
      case 'ANNULE':
        return (
          const Color(0xFFDC2626),
          const Color(0xFFFFF0F0),
          'Travaux annulés',
          Icons.cancel_outlined
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

  (String, String) _categorieInfo(String? specName, TravauxCategorie? cat) {
    if (specName != null && specName.isNotEmpty) {
      final lower = specName.toLowerCase();
      if (lower.contains('plomb')) return ('assets/icons/plomberie.svg', specName);
      if (lower.contains('peint')) return ('assets/icons/photo.svg', specName);
      if (lower.contains('electr')) return ('assets/icons/electric.svg', specName);
      if (lower.contains('nettoy') || lower.contains('entret')) return ('assets/icons/nettoyage.svg', specName);
      return ('assets/icons/travaux.svg', specName);
    }
    switch (cat) {
      case TravauxCategorie.plomberie:
        return ('assets/icons/plomberie.svg', 'Plomberie');
      case TravauxCategorie.peinture:
        return ('assets/icons/photo.svg', 'Peinture');
      case TravauxCategorie.electricite:
        return ('assets/icons/electric.svg', 'Électricité');
      case TravauxCategorie.entretien:
        return ('assets/icons/nettoyage.svg', 'Entretien');
      default:
        return ('assets/icons/travaux.svg', 'Travaux');
    }
  }

  String _formatDateRaw(String? raw) {
    if (raw == null || raw.isEmpty) return 'Non communiquée';
    try {
      final dt = DateTime.parse(raw);
      const months = [
        '', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
        'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  String _formatDate(DateTime? d) {
    if (d == null) return 'Non communiquée';
    const months = [
      '', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final d = _detail;
    final fallback = widget.travaux;

    final statusStr = d?.status ?? fallback?.statut.name ?? 'PENDING';
    final (statusColor, statusBg, statusLabel, statusIcon) = _statutInfo(statusStr);
    final (catIcon, catLabel) = _categorieInfo(d?.specialtyName, fallback?.categorie);

    final title = d?.title ?? fallback?.titre ?? 'Détail des travaux';
    final description = d?.description != null && d!.description!.isNotEmpty
        ? d.description!
        : (fallback?.description.isNotEmpty == true ? fallback!.description : 'Aucune description fournie.');

    final providerName = d?.selectedProvider?.fullName ??
        (d?.specialtyName != null ? 'Spécialité: ${d!.specialtyName}' : (fallback?.entreprise.isNotEmpty == true ? fallback!.entreprise : 'Syndic / Gestionnaire'));

    final locationStr = d != null ? d.location : 'Résidence';
    final photoUrls = d?.photoUrls ?? [];

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
                          Text('Détail des travaux',
                              style: GoogleFonts.jost(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          Text('RÉF #${_targetId > 0 ? _targetId : (fallback?.id ?? "")}',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.75))),
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
                        // Card Categorie & Statut principal
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
                                  Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0EDE8),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: SvgPicture.asset(catIcon,
                                              width: 22, height: 22),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(catLabel,
                                          style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF6A7282))),
                                    ],
                                  ),
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
                                ],
                              ),
                              const SizedBox(height: 16),
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
                                  Text(
                                      'Émis le : ${_formatDateRaw(d?.createdAt) != "Non communiquée" ? _formatDateRaw(d?.createdAt) : _formatDate(fallback?.datePrevue)}',
                                      style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF6A7282))),
                                ],
                              ),
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
                              Text('Description de l\'intervention',
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
                              Text('Photos de l\'intervention',
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

                        // Entreprise prestataire
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
                                  child: SvgPicture.asset('assets/icons/infoclient.svg',
                                      width: 20, height: 20),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Prestataire',
                                        style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFF6A7282))),
                                    const SizedBox(height: 2),
                                    Text(providerName,
                                        style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF2D2520))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Localisation
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
                                  child: SvgPicture.asset('assets/icons/adress.svg',
                                      width: 20, height: 20),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Localisation',
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

                        const SizedBox(height: 16),

                        // Timeline / Suivi
                        if (d != null && d.timeline.isNotEmpty)
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
                                Text('Suivi des travaux',
                                    style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF2D2520))),
                                const SizedBox(height: 16),
                                ...List.generate(d.timeline.length, (i) {
                                  final step = d.timeline[i];
                                  final isLast = i == d.timeline.length - 1;
                                  return _timelineItem(
                                    title: step.label,
                                    subtitle: step.type ?? (step.completed ? 'Terminé' : 'En attente'),
                                    dateStr: step.date != null ? _formatDateRaw(step.date) : '',
                                    isDone: step.completed,
                                    isLast: isLast,
                                  );
                                }),
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
                  Text(dateStr,
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
