// lib/screens/locataire/locataire_home.dart
// Écran d'accueil du profil Locataire.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/locataire_models.dart';
import '../../services/locataire_service.dart';
import 'locataire_nouveau_signalement.dart';
import 'locataire_signalements.dart';
import 'locataire_travaux.dart';
import 'locataire_travaux_detail.dart';
import 'locataire_profil.dart';

class LocataireHomePage extends StatefulWidget {
  const LocataireHomePage({super.key});

  @override
  State<LocataireHomePage> createState() => _LocataireHomePageState();
}

class _LocataireHomePageState extends State<LocataireHomePage> {
  LocataireProfile? _profile;
  TenantDashboardModel? _dashboard;
  List<SignalementLocataire> _signalements = [];
  List<TravauxLocataire> _travaux = [];
  bool _isLoading = true;
  final _unreadNotifCount = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        LocataireService.getProfile(),
        LocataireService.getDashboard(),
        LocataireService.getSignalements(),
        LocataireService.getTravaux(),
        LocataireService.getUnreadNotificationCount(),
      ]);
      if (!mounted) return;
      setState(() {
        _profile = results[0] as LocataireProfile;
        _dashboard = results[1] as TenantDashboardModel;
        _signalements = results[2] as List<SignalementLocataire>;
        _travaux = results[3] as List<TravauxLocataire>;
        _unreadNotifCount.value = results[4] as int;
        _isLoading = false;
      });
    } catch (e, st) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showNotificationsPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LocataireNotificationsSheet(
        initialUnreadCount: _unreadNotifCount.value,
        onMarkAllRead: () async {
          await LocataireService.markAllNotificationsRead();
          _unreadNotifCount.value = 0;
        },
      ),
    );
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
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6F675E),
                ),
              ),
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
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return SizedBox(
      height: 250,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
            child: (_dashboard?.residencePhotoUrl != null && _dashboard!.residencePhotoUrl!.isNotEmpty)
                ? Image.network(
                    _dashboard!.residencePhotoUrl!,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: double.infinity,
                      height: 250,
                      color: const Color(0xFF6F675E),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: 250,
                    color: const Color(0xFF6F675E),
                  ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
            child: Container(
              width: double.infinity,
              height: 250,
              color: const Color(0x59000000),
            ),
          ),
          Positioned(
            top: 60,
            left: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour',
                  style: GoogleFonts.jost(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.white),
                ),
                Text(
                  _profile?.prenom.isNotEmpty == true ? _profile!.prenom : (_dashboard?.firstName ?? '—'),
                  style: GoogleFonts.jost(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          // Notification & Avatar initiales
          Positioned(
            top: 60,
            right: 24,
            child: Row(
              children: [
                GestureDetector(
                  onTap: _showNotificationsPanel,
                  child: Stack(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/notification.svg',
                        width: 28,
                        height: 28,
                      ),
                      ValueListenableBuilder<int>(
                        valueListenable: _unreadNotifCount,
                        builder: (_, count, _) => count > 0
                            ? Positioned(
                                top: 2,
                                right: 2,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF3B30),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: Center(
                      child: Text(
                        _profile?.initiales ?? (_dashboard?.firstName.isNotEmpty == true ? _dashboard!.firstName[0].toUpperCase() : ''),
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6F675E)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Carte appartement
          Positioned(
            top: 135,
            left: 19,
            right: 19,
            height: 92,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0x26FFFFFF),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: const Color(0x33FFFFFF), width: 0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Mon appartement',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                height: 1.1,
                                color: Colors.white.withValues(alpha: 0.8))),
                        const SizedBox(height: 2),
                        Text(_profile?.residence ?? _dashboard?.residenceName ?? '—',
                            style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                                color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        if (_profile != null || _dashboard != null) ...[
                          const SizedBox(height: 2),
                          Text(_profile?.appartement ?? _dashboard?.propertyReference ?? '',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 1.1,
                                  color: Colors.white.withValues(alpha: 0.85)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildBailBadge(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBailBadge() {
    final active = _dashboard?.bailActif ?? true;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (active ? const Color(0xFF00A63E) : const Color(0xFFFF3B30)).withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (active ? const Color(0xFF00A63E) : const Color(0xFFFF3B30)).withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
                color: active ? const Color(0xFF4ADE80) : const Color(0xFFFF6B6B), shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(active ? 'Bail actif' : 'Bail inactif',
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ],
      ),
    );
  }

  // ─── Section Signalements ─────────────────────────────────────────────────

  Widget _buildSignalementsSection() {
    final enAttente = _dashboard?.pendingReportsCount ??
        _signalements.where((s) => s.statut == SignalementStatut.enAttente).length;
    final enCours = _dashboard?.inProgressReportsCount ??
        _signalements.where((s) => s.statut == SignalementStatut.enCours).length;
    final resolus = _dashboard?.resolvedReportsCount ??
        _signalements.where((s) => s.statut == SignalementStatut.resolu).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mes signalements',
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2520))),
              GestureDetector(
                onTap: () => _navigate(const LocataireSignalementsPage()),
                child: Text('Voir plus',
                    style: GoogleFonts.beVietnamPro(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                        letterSpacing: -0.41,
                        color: const Color(0xFF6F675E))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                  child: _statCard(
                      label: 'En attente',
                      count: enAttente,
                      color: const Color(0xFFE17100),
                      bg: const Color(0xFFFFF4E6))),
              const SizedBox(width: 10),
              Expanded(
                  child: _statCard(
                      label: 'En cours',
                      count: enCours,
                      color: const Color(0xFF2B7FFF),
                      bg: const Color(0xFFEEF4FF))),
              const SizedBox(width: 10),
              Expanded(
                  child: _statCard(
                      label: 'Résolus',
                      count: resolus,
                      color: const Color(0xFF00A63E),
                      bg: const Color(0xFFEFFFF6))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCard(
      {required String label,
      required int count,
      required Color color,
      required Color bg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$count',
              style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: color)),
        ],
      ),
    );
  }

  // ─── Section Travaux ──────────────────────────────────────────────────────

  Widget _buildTravauxSection() {
    final recent = _travaux.take(2).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Travaux en cours',
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2520))),
              GestureDetector(
                onTap: () => _navigate(const LocataireTravauxPage()),
                child: Text('Voir plus',
                    style: GoogleFonts.beVietnamPro(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                        letterSpacing: -0.41,
                        color: const Color(0xFF6F675E))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_travaux.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFAF9F4),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/travaux.svg',
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                            Color(0xFF6F675E), BlendMode.srcIn),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Aucun travail en cours',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D2520)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Les demandes de travaux concernant votre résidence s\'afficheront ici.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF6A7282)),
                  ),
                ],
              ),
            ),
          )
        else
          ...recent.map((t) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _buildTravauxCard(t),
              )),
      ],
    );
  }

  Widget _buildTravauxCard(TravauxLocataire t) {
    final (statusColor, statusBg, statusLabel, statusIcon) = _travauxStatusInfo(t.statut);
    final (catIcon, catLabel) = _categorieInfo(t.categorie);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, _, _) =>
              LocataireTravauxDetailPage(travaux: t),
          transitionsBuilder: (_, anim, _, child) => FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 4))
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EDE8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: SvgPicture.asset(catIcon, width: 20, height: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.titre,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D2520)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(catLabel,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6A7282))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 11, color: statusColor),
                  const SizedBox(width: 4),
                  Text(statusLabel,
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (Color, Color, String, IconData) _travauxStatusInfo(TravauxStatut statut) {
    switch (statut) {
      case TravauxStatut.planifie:
        return (
          const Color(0xFFE17100),
          const Color(0xFFFFF4E6),
          'Planifié',
          Icons.schedule_rounded
        );
      case TravauxStatut.enCours:
        return (
          const Color(0xFF2B7FFF),
          const Color(0xFFEEF4FF),
          'En cours',
          Icons.sync_rounded
        );
      case TravauxStatut.termine:
        return (
          const Color(0xFF00A63E),
          const Color(0xFFEFFFF6),
          'Terminé',
          Icons.check_circle_outline_rounded
        );
      case TravauxStatut.annule:
        return (
          const Color(0xFFDC2626),
          const Color(0xFFFFF0F0),
          'Annulé',
          Icons.cancel_outlined
        );
    }
  }

  (String, String) _categorieInfo(TravauxCategorie cat) {
    switch (cat) {
      case TravauxCategorie.plomberie:
        return ('assets/icons/plomberie.svg', 'Plomberie');
      case TravauxCategorie.peinture:
        return ('assets/icons/photo.svg', 'Peinture');
      case TravauxCategorie.electricite:
        return ('assets/icons/electric.svg', 'Électricité');
      case TravauxCategorie.entretien:
        return ('assets/icons/nettoyage.svg', 'Entretien');
      case TravauxCategorie.autre:
        return ('assets/icons/travaux.svg', 'Autre');
    }
  }

  // ─── Bannière Signalement rapide ──────────────────────────────────────────

  Widget _buildSignalBanner() {
    return GestureDetector(
      onTap: () async {
        final created = await Navigator.of(context).push<bool>(
          PageRouteBuilder(
            pageBuilder: (_, _, _) =>
                const LocataireNouveauSignalementPage(),
            transitionsBuilder: (_, anim, _, child) => FadeTransition(
              opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
        if (created == true) {
          _loadData();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0x1AF9C20A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF9C20A), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned(
                right: 45,
                top: 0,
                bottom: 0,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SvgPicture.asset(
                    'assets/icons/illus.svg',
                    width: 84,
                    height: 84,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Signaler un problème',
                              style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFF9C20A),
                                  height: 28 / 15)),
                          const SizedBox(height: 3),
                          Text(
                            'Déclarez une réclamation ou une\nnuisance dans votre appartement.',
                            style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF6B5744),
                                height: 15 / 9),
                          ),
                        ],
                      ),
                    ),
                    Transform.rotate(
                      angle: 15 * 3.14159265 / 180,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF9C20A),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Transform.rotate(
                          angle: -15 * 3.14159265 / 180,
                          child: SvgPicture.asset(
                            'assets/icons/SVG.svg',
                            width: 32,
                            height: 32,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
              color: Color(0x1A000000),
              offset: Offset(0, -1),
              blurRadius: 32,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildNavItem('assets/icons/accueil.svg', 'Accueil', active: true),
            _buildNavItem(
              'assets/icons/signale.svg',
              'Signalements',
              onTap: () => _navigate(const LocataireSignalementsPage()),
            ),
            _buildNavItem(
              'assets/icons/travaux.svg',
              'Travaux',
              onTap: () => _navigate(const LocataireTravauxPage()),
            ),
            _buildNavItem(
              'assets/icons/profil.svg',
              'Profil',
              onTap: () => _navigate(const LocataireProfilPage()),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF6F675E), strokeWidth: 2))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFF6F675E),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildSignalBanner(),
                    const SizedBox(height: 24),
                    _buildSignalementsSection(),
                    const SizedBox(height: 24),
                    _buildTravauxSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}

// ─── Notifications Sheet ──────────────────────────────────────────────────────

class _LocataireNotificationsSheet extends StatefulWidget {
  final Future<void> Function() onMarkAllRead;
  final int initialUnreadCount;

  const _LocataireNotificationsSheet({
    required this.onMarkAllRead,
    required this.initialUnreadCount,
  });

  @override
  State<_LocataireNotificationsSheet> createState() =>
      _LocataireNotificationsSheetState();
}

class _LocataireNotificationsSheetState
    extends State<_LocataireNotificationsSheet> {
  List<LocataireNotification> _notifications = [];
  bool _loading = true;
  late int _unreadCount;

  @override
  void initState() {
    super.initState();
    _unreadCount = widget.initialUnreadCount;
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await LocataireService.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = res;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatNotifDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFAF9F4),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Notifications',
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D2520))),
                  GestureDetector(
                    onTap: _unreadCount > 0
                        ? () async {
                            await widget.onMarkAllRead();
                            setState(() {
                              _unreadCount = 0;
                              _notifications = _notifications
                                  .map((n) => n.copyWith(read: true))
                                  .toList();
                            });
                          }
                        : null,
                    child: Text('Tout marquer comme lu',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _unreadCount > 0
                                ? const Color(0xFF6F675E)
                                : const Color(0xFFD1D5DB))),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF6F675E), strokeWidth: 2))
                  : _notifications.isEmpty
                      ? Center(
                          child: Text('Aucune notification',
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF6A7282))))
                      : ListView.separated(
                          controller: controller,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: _notifications.length,
                          separatorBuilder: (_, _) => const Divider(
                              height: 1, color: Color(0xFFF3F4F6)),
                          itemBuilder: (_, i) {
                            final n = _notifications[i];
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                color: n.read
                                    ? Colors.transparent
                                    : const Color(0xFFF0EDE8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!n.read)
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 6, right: 8),
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                          color: Color(0xFF6F675E),
                                          shape: BoxShape.circle),
                                    )
                                  else
                                    const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(n.title,
                                            style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    const Color(0xFF2D2520))),
                                        const SizedBox(height: 4),
                                        Text(n.body,
                                            style: GoogleFonts.inter(
                                                fontSize: 13,
                                                color:
                                                    const Color(0xFF6A7282))),
                                        const SizedBox(height: 4),
                                        Text(_formatNotifDate(n.createdAt),
                                            style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color:
                                                    const Color(0xFF9CA3AF))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
