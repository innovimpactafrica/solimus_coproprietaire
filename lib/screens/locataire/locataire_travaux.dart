// lib/screens/locataire/locataire_travaux.dart
// Écran Travaux du profil Locataire (connecté à GET /api/tenant/interventions).

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/intervention_model.dart';
import '../../services/locataire_service.dart';
import 'locataire_home.dart';
import 'locataire_nouvelle_demande_travaux.dart';
import 'locataire_signalements.dart';
import 'locataire_travaux_detail.dart';
import 'locataire_profil.dart';

class LocataireTravauxPage extends StatefulWidget {
  const LocataireTravauxPage({super.key});

  @override
  State<LocataireTravauxPage> createState() => _LocataireTravauxPageState();
}

class _LocataireTravauxPageState extends State<LocataireTravauxPage> {
  List<InterventionModel> _interventions = [];
  bool _isLoading = true;
  String? _filterStatus; // null, PENDING, IN_PROGRESS, FINISHED, CANCELLED

  List<InterventionModel> get _filtered {
    if (_filterStatus == null) return _interventions;
    final target = _filterStatus!.toUpperCase();
    return _interventions.where((item) {
      final s = item.status.toUpperCase();
      if (target == 'PENDING') return s == 'PENDING' || s == 'EN_ATTENTE';
      if (target == 'IN_PROGRESS') return s == 'STARTED' || s == 'IN_PROGRESS' || s == 'EN_COURS';
      if (target == 'FINISHED') return s == 'FINISHED' || s == 'FINAL_VALIDATION' || s == 'RESOLVED' || s == 'TERMINE';
      if (target == 'CANCELLED') return s == 'CANCELLED' || s == 'ANNULE';
      return s == target;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await LocataireService.getTenantInterventions();
      if (mounted) {
        setState(() {
          _interventions = res.content;
          _isLoading = false;
        });
      }
    } catch (e, st) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigate(Widget page) {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, anim, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 300),
    ));
  }

  // ─── Nav bar ─────────────────────────────────────────────────────────────

  Widget _buildNavItem(
    String iconPath,
    String label, {
    bool active = false,
    VoidCallback? onTap,
  }) {
    if (active) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(iconPath, width: 20, height: 20),
              const SizedBox(width: 6),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6F675E))),
            ],
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(iconPath, width: 22, height: 22),
          const SizedBox(height: 3),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.85))),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  (Color, Color, String, IconData) _statutInfo(String status, String? label) {
    final s = status.toUpperCase();
    if (s == 'PENDING' || s == 'PLANIFIE' || s == 'EN_ATTENTE') {
      return (
        const Color(0xFFE17100),
        const Color(0xFFFFF4E6),
        label ?? 'En attente',
        Icons.schedule_rounded
      );
    }
    if (s == 'STARTED' || s == 'IN_PROGRESS' || s == 'EN_COURS') {
      return (
        const Color(0xFF2B7FFF),
        const Color(0xFFEEF4FF),
        label ?? 'En cours',
        Icons.sync_rounded
      );
    }
    if (s == 'FINISHED' || s == 'FINAL_VALIDATION' || s == 'RESOLVED' || s == 'TERMINE') {
      return (
        const Color(0xFF00A63E),
        const Color(0xFFEFFFF6),
        label ?? 'Terminé',
        Icons.check_circle_outline_rounded
      );
    }
    if (s == 'CANCELLED' || s == 'ANNULE') {
      return (
        const Color(0xFFDC2626),
        const Color(0xFFFFF0F0),
        label ?? 'Annulé',
        Icons.cancel_outlined
      );
    }
    return (
      const Color(0xFF6A7282),
      const Color(0xFFF3F4F6),
      label ?? status,
      Icons.info_outline_rounded
    );
  }

  String _formatDateRaw(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    try {
      final dt = DateTime.parse(raw);
      const months = [
        '', 'jan.', 'fév.', 'mars', 'avr.', 'mai', 'juin',
        'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  // ─── Filter chip ──────────────────────────────────────────────────────────

  Widget _buildFilterChip(String label, String? value) {
    final isSelected = _filterStatus == value;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = isSelected ? null : value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6F675E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected
                  ? const Color(0xFF6F675E)
                  : const Color(0xFFD6D2C9)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 4,
                offset: Offset(0, 2))
          ],
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF6A7282))),
      ),
    );
  }

  // ─── Card ─────────────────────────────────────────────────────────────────

  Widget _buildCard(InterventionModel t) {
    final (statusColor, statusBg, statusLabelText, statusIcon) =
        _statutInfo(t.status, t.statusLabel);

    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, _, _) =>
                LocataireTravauxDetailPage(interventionId: t.id),
            transitionsBuilder: (_, anim, _, child) => FadeTransition(
              opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
        // Rafraîchir la liste après être revenu du détail
        _load();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EDE8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: t.specialtyIcon != null && t.specialtyIcon!.isNotEmpty
                        ? Image.network(
                            t.specialtyIcon!,
                            width: 24,
                            height: 24,
                            errorBuilder: (_, __, ___) => SvgPicture.asset(
                                'assets/icons/travaux.svg',
                                width: 22,
                                height: 22),
                          )
                        : SvgPicture.asset('assets/icons/travaux.svg',
                            width: 22, height: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.title,
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2D2520))),
                      const SizedBox(height: 2),
                      Text(t.location,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: const Color(0xFF6A7282))),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(statusLabelText,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 4),
                    Text('Créé le ${_formatDateRaw(t.createdAt)}',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6A7282))),
                  ],
                ),
                if (t.specialtyName != null && t.specialtyName!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      t.specialtyName!,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4B5563)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final pendingCount = _interventions.where((i) => ['PENDING', 'EN_ATTENTE'].contains(i.status.toUpperCase())).length;
    final inProgressCount = _interventions.where((i) => ['STARTED', 'IN_PROGRESS', 'EN_COURS'].contains(i.status.toUpperCase())).length;
    final finishedCount = _interventions.where((i) => ['FINISHED', 'FINAL_VALIDATION', 'RESOLVED', 'TERMINE'].contains(i.status.toUpperCase())).length;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F4),
      floatingActionButton: GestureDetector(
        onTap: () async {
          final created = await Navigator.of(context).push<bool>(
            PageRouteBuilder(
              pageBuilder: (c, a, s) => const LocataireNouvelleDemandeTravauxPage(),
              transitionsBuilder: (c, anim, s, child) => FadeTransition(
                opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
                child: child,
              ),
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
          if (created == true) {
            _load();
          }
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: Color(0xFF6F675E),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/add.svg',
              width: 26,
              height: 26,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 82 + MediaQuery.of(context).padding.bottom,
        padding: EdgeInsets.only(left: 8, right: 8, top: 10, bottom: MediaQuery.of(context).padding.bottom + 10),
        decoration: const BoxDecoration(
          color: Color(0xFF6F675E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, -1),
                blurRadius: 32)
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildNavItem('assets/icons/accueil.svg', 'Accueil',
                onTap: () => _navigate(const LocataireHomePage())),
            _buildNavItem('assets/icons/signale.svg', 'Signalements',
                onTap: () => _navigate(const LocataireSignalementsPage())),
            _buildNavItem('assets/icons/travaux.svg', 'Travaux', active: true),
            _buildNavItem('assets/icons/profil.svg', 'Profil',
                onTap: () => _navigate(const LocataireProfilPage())),
          ],
        ),
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(
                16, MediaQuery.of(context).padding.top + 20, 16, 20),
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
                Text('Travaux',
                    style: GoogleFonts.jost(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text('${_interventions.length} demande(s) de travaux',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.75))),
                const SizedBox(height: 16),
                // KPI row
                Row(
                  children: [
                    _kpiChip(
                      '$pendingCount',
                      'En attente',
                      const Color(0xFFE17100),
                    ),
                    const SizedBox(width: 10),
                    _kpiChip(
                      '$inProgressCount',
                      'En cours',
                      const Color(0xFF4ADE80),
                    ),
                    const SizedBox(width: 10),
                    _kpiChip(
                      '$finishedCount',
                      'Terminés',
                      Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Filtres
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tous', null),
                  const SizedBox(width: 8),
                  _buildFilterChip('En attente', 'PENDING'),
                  const SizedBox(width: 8),
                  _buildFilterChip('En cours', 'IN_PROGRESS'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Terminés', 'FINISHED'),
                ],
              ),
            ),
          ),
          // Liste
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF6F675E), strokeWidth: 2))
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset('assets/icons/travaux.svg',
                                width: 48, height: 48,
                                colorFilter: const ColorFilter.mode(
                                    Color(0xFFD6D2C9), BlendMode.srcIn)),
                            const SizedBox(height: 12),
                            Text('Aucune demande de travaux',
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF6A7282))),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: const Color(0xFF6F675E),
                        child: ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => _buildCard(filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _kpiChip(String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('$count $label',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ],
      ),
    );
  }
}
