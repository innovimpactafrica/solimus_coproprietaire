// lib/screens/locataire/locataire_signalements.dart
// Écran Signalements du profil Locataire.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/locataire_models.dart';
import '../../services/locataire_service.dart';
import 'locataire_home.dart';
import 'locataire_nouveau_signalement.dart';
import 'locataire_signalement_detail.dart';
import 'locataire_travaux.dart';
import 'locataire_profil.dart';

class LocataireSignalementsPage extends StatefulWidget {
  const LocataireSignalementsPage({super.key});

  @override
  State<LocataireSignalementsPage> createState() =>
      _LocataireSignalementsPageState();
}

class _LocataireSignalementsPageState
    extends State<LocataireSignalementsPage> {
  List<SignalementLocataire> _signalements = [];
  bool _isLoading = true;
  SignalementStatut? _filterStatut;

  List<SignalementLocataire> get _filtered => _filterStatut == null
      ? _signalements
      : _signalements.where((s) => s.statut == _filterStatut).toList();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await LocataireService.getSignalements();
      if (mounted) setState(() { _signalements = data; _isLoading = false; });
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

  // ─── Status badge ─────────────────────────────────────────────────────────

  Widget _buildStatutBadge(SignalementStatut statut) {
    final (color, bg, label, icon) = _statutInfo(statut);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildPrioriteBadge(SignalementPriorite priorite) {
    final (color, bg, label) = _prioriteInfo(priorite);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }

  (Color, Color, String, IconData) _statutInfo(SignalementStatut s) {
    switch (s) {
      case SignalementStatut.enAttente:
        return (const Color(0xFFE17100), const Color(0xFFFFF4E6),
            'En attente', Icons.hourglass_top_rounded);
      case SignalementStatut.enCours:
        return (const Color(0xFF2B7FFF), const Color(0xFFEEF4FF),
            'En cours', Icons.sync_rounded);
      case SignalementStatut.resolu:
        return (const Color(0xFF00A63E), const Color(0xFFEFFFF6),
            'Résolu', Icons.check_circle_outline_rounded);
    }
  }

  (Color, Color, String) _prioriteInfo(SignalementPriorite p) {
    switch (p) {
      case SignalementPriorite.haute:
        return (const Color(0xFFDC2626), const Color(0xFFFFF0F0), 'Haute');
      case SignalementPriorite.moyenne:
        return (const Color(0xFFE17100), const Color(0xFFFFF4E6), 'Moyenne');
      case SignalementPriorite.faible:
        return (const Color(0xFF6A7282), const Color(0xFFF3F4F6), 'Faible');
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      '', 'jan.', 'fév.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  // ─── Filter chips ─────────────────────────────────────────────────────────

  Widget _buildFilterChip(String label, SignalementStatut? value) {
    final isSelected = _filterStatut == value;
    return GestureDetector(
      onTap: () => setState(
          () => _filterStatut = isSelected ? null : value),
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
                color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF6A7282))),
      ),
    );
  }

  // ─── Card ─────────────────────────────────────────────────────────────────

  Widget _buildCard(SignalementLocataire s) {
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, _, _) =>
                LocataireSignalementDetailPage(signalement: s),
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
                color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(s.titre,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D2520)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                _buildStatutBadge(s.statut),
              ],
            ),
            const SizedBox(height: 6),
            Text(s.description,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6A7282),
                    height: 1.5),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            const Divider(color: Color(0xFFF3F4F6), thickness: 1, height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset('assets/icons/calendar.svg',
                        width: 14, height: 14),
                    const SizedBox(width: 5),
                    Text(_formatDate(s.date),
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6A7282))),
                  ],
                ),
                _buildPrioriteBadge(s.priorite),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F4),
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
                color: Color(0x1A000000), offset: Offset(0, -1), blurRadius: 32)
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildNavItem('assets/icons/accueil.svg', 'Accueil',
                onTap: () => _navigate(const LocataireHomePage())),
            _buildNavItem('assets/icons/signale.svg', 'Signalements',
                active: true),
            _buildNavItem('assets/icons/travaux.svg', 'Travaux',
                onTap: () => _navigate(const LocataireTravauxPage())),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Mes signalements',
                        style: GoogleFonts.jost(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    // Bouton nouveau signalement
                    GestureDetector(
                      onTap: () async {
                        final created = await Navigator.of(context).push<bool>(
                          PageRouteBuilder(
                            pageBuilder: (_, _, _) =>
                                const LocataireNouveauSignalementPage(),
                            transitionsBuilder: (_, anim, _, child) =>
                                FadeTransition(
                              opacity: CurvedAnimation(
                                  parent: anim, curve: Curves.easeOut),
                              child: child,
                            ),
                            transitionDuration:
                                const Duration(milliseconds: 300),
                          ),
                        );
                        if (created == true) {
                          _load();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.add, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text('Nouveau',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${_signalements.length} signalement(s) au total',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.75))),
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
                  _buildFilterChip('En attente', SignalementStatut.enAttente),
                  const SizedBox(width: 8),
                  _buildFilterChip('En cours', SignalementStatut.enCours),
                  const SizedBox(width: 8),
                  _buildFilterChip('Résolus', SignalementStatut.resolu),
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
                            SvgPicture.asset('assets/icons/signale.svg',
                                width: 48, height: 48,
                                colorFilter: const ColorFilter.mode(
                                    Color(0xFFD6D2C9), BlendMode.srcIn)),
                            const SizedBox(height: 12),
                            Text('Aucun signalement',
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
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => _buildCard(filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
