// lib/screens/locataire/locataire_profil.dart
// Écran Profil du profil Locataire.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/locataire_models.dart';
import '../../services/locataire_service.dart';
import '../auth/login.dart';
import 'locataire_home.dart';
import 'locataire_signalements.dart';
import 'locataire_travaux.dart';
import '../profil/changer_mot_de_passe.dart';

class LocataireProfilPage extends StatefulWidget {
  const LocataireProfilPage({super.key});

  @override
  State<LocataireProfilPage> createState() => _LocataireProfilPageState();
}

class _LocataireProfilPageState extends State<LocataireProfilPage> {
  LocataireProfile? _profile;
  bool _isLoading = true;
  bool _notificationsEnabled = true;

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    try {
      await LocataireService.toggleNotifications();
    } catch (e, st) {
      if (!mounted) return;
      setState(() => _notificationsEnabled = !value);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de modifier les notifications: ${e.toString().replaceFirst('Exception: ', '')}'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await LocataireService.getProfile();
      if (mounted) setState(() { _profile = data; _isLoading = false; });
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

  Future<void> _onLogout() async {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
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

  // ─── Avatar ───────────────────────────────────────────────────────────────

  Widget _buildAvatar() {
    final initials = _profile?.initiales ?? '';
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF0EDE8),
        border: Border.all(color: const Color(0xFF6F675E), width: 2.5),
      ),
      child: Center(
        child: initials.isNotEmpty
            ? Text(initials,
                style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6F675E)))
            : SvgPicture.asset('assets/icons/person.svg',
                width: 44,
                height: 44,
                colorFilter: const ColorFilter.mode(
                    Color(0xFF6F675E), BlendMode.srcIn)),
      ),
    );
  }

  // ─── Info row ─────────────────────────────────────────────────────────────

  Widget _buildInfoRow(String iconPath, String label, String value) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EDE8),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(iconPath, width: 18, height: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6A7282))),
                const SizedBox(height: 2),
                Text(value,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D2520)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Divider(height: 1, color: Color(0xFFF3F4F6)),
      );

  Widget _buildCard({required Widget child}) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      );

  String _formatDateEntree(DateTime d) {
    const months = [
      '', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final p = _profile;
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
            _buildNavItem('assets/icons/travaux.svg', 'Travaux',
                onTap: () => _navigate(const LocataireTravauxPage())),
            _buildNavItem('assets/icons/profil.svg', 'Profil', active: true),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF6F675E), strokeWidth: 2))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header profil
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                        16,
                        MediaQuery.of(context).padding.top + 24,
                        16,
                        28),
                    decoration: const BoxDecoration(
                      color: Color(0xFF6F675E),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(36),
                        bottomRight: Radius.circular(36),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildAvatar(),
                        const SizedBox(height: 14),
                        Text(p?.nomComplet ?? '—',
                            style: GoogleFonts.jost(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(p?.email ?? '',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.75))),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color:
                                    Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                    color: Color(0xFF4ADE80),
                                    shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Text('Locataire actif',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Informations personnelles
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Informations personnelles',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2D2520))),
                        const SizedBox(height: 10),
                        _buildCard(
                          child: Column(
                            children: [
                              _buildInfoRow('assets/icons/person.svg',
                                  'Prénom', p?.prenom ?? '—'),
                              _buildDivider(),
                              _buildInfoRow('assets/icons/person.svg',
                                  'Nom', p?.nom ?? '—'),
                              _buildDivider(),
                              _buildInfoRow('assets/icons/mail.svg',
                                  'Email', p?.email ?? '—'),
                              _buildDivider(),
                              _buildInfoRow('assets/icons/telephone.svg',
                                  'Téléphone', p?.telephone ?? '—'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Mon logement
                        Text('Mon logement',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2D2520))),
                        const SizedBox(height: 10),
                        _buildCard(
                          child: Column(
                            children: [
                              _buildInfoRow('assets/icons/adress.svg',
                                  'Résidence', p?.residence ?? '—'),
                              _buildDivider(),
                              _buildInfoRow('assets/icons/clef.svg',
                                  'Appartement', p?.appartement ?? '—'),
                              _buildDivider(),
                              _buildInfoRow(
                                'assets/icons/calendar.svg',
                                'Date d\'entrée',
                                p != null
                                    ? _formatDateEntree(p.dateEntree)
                                    : '—',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Sécurité
                        Text('Sécurité',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2D2520))),
                        const SizedBox(height: 10),
                        _buildCard(
                          child: InkWell(
                            onTap: () => Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (c, a, s) =>
                                    const ChangerMotDePassePage(isLocataire: true),
                                transitionsBuilder: (c, anim, s, child) =>
                                    FadeTransition(
                                  opacity: CurvedAnimation(
                                      parent: anim, curve: Curves.easeOut),
                                  child: child,
                                ),
                                transitionDuration:
                                    const Duration(milliseconds: 300),
                              ),
                            ),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0EDE8),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.lock_outline_rounded,
                                          size: 20, color: Color(0xFF6F675E)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Changer mon mot de passe',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2D2520),
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded,
                                      color: Color(0xFF9CA3AF), size: 22),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Notifications
                        Text('Notifications',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2D2520))),
                        const SizedBox(height: 10),
                        _buildCard(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0EDE8),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.notifications_active_outlined,
                                        size: 20, color: Color(0xFF6F675E)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Notifications push',
                                          style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF2D2520))),
                                      const SizedBox(height: 2),
                                      Text(
                                          _notificationsEnabled
                                              ? 'Alertes activées'
                                              : 'Alertes désactivées',
                                          style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: const Color(0xFF6A7282))),
                                    ],
                                  ),
                                ),
                                Switch.adaptive(
                                  value: _notificationsEnabled,
                                  activeColor: const Color(0xFF6F675E),
                                  onChanged: (val) => _toggleNotifications(val),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Bouton Déconnexion
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _onLogout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFF0F0),
                              foregroundColor: const Color(0xFFDC2626),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(
                                    color: Color(0xFFDC2626),
                                    width: 0.8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset('assets/icons/logout.svg',
                                    width: 20,
                                    height: 20,
                                    colorFilter: const ColorFilter.mode(
                                        Color(0xFFDC2626),
                                        BlendMode.srcIn)),
                                const SizedBox(width: 10),
                                Text('Se déconnecter',
                                    style: GoogleFonts.beVietnamPro(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: const Color(0xFFDC2626))),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
