import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/profile_model.dart';
import '../../services/auth_service.dart';
import '../../services/auth_storage.dart';
import '../../services/coowner_service.dart';
import '../../services/user_session.dart';
import '../auth/login.dart';
import '../home/home.dart';
import '../charges/mes_charges.dart';
import '../incidents/mes_incidents.dart';
import '../reunions/reunions.dart';
import 'informations_personnelles.dart';
import '../documents/mes_documents.dart';
import '../profil/mes_signalements.dart';
// import 'mon_abonnement.dart'; // ABONNEMENT - commenté temporairement

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  bool _notificationsEnabled = true;
  ProfileModel? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _initNotificationState();
  }

  Future<void> _initNotificationState() async {
    try {
      final enabled = await CoOwnerService.getNotificationSettings();
      if (!mounted) return;
      setState(() => _notificationsEnabled = enabled);
    } catch (_) {}
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    try {
      await CoOwnerService.updateNotificationSettings(value);
    } catch (_) {
      // Revenir à l'état précédent si l'appel échoue
      if (!mounted) return;
      setState(() => _notificationsEnabled = !value);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la mise à jour des notifications')),
      );
    }
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await CoOwnerService.getProfile();
      if (!mounted) return;
      setState(() => _profile = profile);
      // Sync photo depuis le serveur
    } catch (_) {}
  }

  Future<void> _onLogout() async {
    final token = await AuthStorage.getToken();
    if (token != null) {
      try {
        await AuthService.logout(token: token);
      } catch (_) {}
    }
    await AuthStorage.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  Widget _navItem(BuildContext ctx, String iconPath, String label,
      {VoidCallback? onTap, bool active = false}) {
    if (active) {
      return Container(
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
              fontWeight: FontWeight.w500,
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultAvatar() {
    return Center(
      child: SvgPicture.asset(
        'assets/icons/person.svg',
        width: 44,
        height: 44,
        colorFilter: const ColorFilter.mode(Color(0xFF6F675E), BlendMode.srcIn),
      ),
    );
  }

  Widget _menuCard({required Widget child}) {
    return Container(
      width: 365,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  Widget _menuItem({
    required String iconPath,
    required String title,
    String? subtitle,
    required Color iconBgColor,
    Widget? trailing,
    VoidCallback? onTap,
    Color titleColor = const Color(0xFF2F3542),
    double iconSize = 24,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 365,
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
        decoration: const BoxDecoration(),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(iconPath, width: iconSize, height: iconSize),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      height: 1.0,
                      letterSpacing: 0,
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        height: 16 / 12,
                        letterSpacing: 0,
                        color: const Color(0xFF6A7282),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F4),
      bottomNavigationBar: Builder(
        builder: (ctx) => Container(
          height: 75,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF6F675E),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
            boxShadow: [
              BoxShadow(color: Color(0x1A000000), offset: Offset(0, -1), blurRadius: 32),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _navItem(ctx, 'assets/icons/accueil.svg', 'Accueil',
                onTap: () => Navigator.of(ctx).pushReplacement(PageRouteBuilder(
                  pageBuilder: (c, a, s) => const HomePage(),
                  transitionsBuilder: (c, anim, s, child) => FadeTransition(
                    opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut), child: child),
                  transitionDuration: const Duration(milliseconds: 300),
                ))),
              _navItem(ctx, 'assets/icons/charges.svg', 'Charges',
                onTap: () => Navigator.of(ctx).pushReplacement(PageRouteBuilder(
                  pageBuilder: (c, a, s) => const MesChargesPage(),
                  transitionsBuilder: (c, anim, s, child) => FadeTransition(
                    opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut), child: child),
                  transitionDuration: const Duration(milliseconds: 300),
                ))),
              _navItem(ctx, 'assets/icons/travaux.svg', 'Demandes',
                onTap: () => Navigator.of(ctx).pushReplacement(PageRouteBuilder(
                  pageBuilder: (c, a, s) => const MesIncidentsPage(),
                  transitionsBuilder: (c, anim, s, child) => FadeTransition(
                    opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut), child: child),
                  transitionDuration: const Duration(milliseconds: 300),
                ))),
              _navItem(ctx, 'assets/icons/reunion.svg', 'Réunion',
                onTap: () => Navigator.of(ctx).pushReplacement(PageRouteBuilder(
                  pageBuilder: (c, a, s) => const ReunionPage(),
                  transitionsBuilder: (c, anim, s, child) => FadeTransition(
                    opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut), child: child),
                  transitionDuration: const Duration(milliseconds: 300),
                ))),
              _navItem(ctx, 'assets/icons/profil.svg', 'Profil', active: true),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              color: const Color(0xFF6F675E),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 32,
                left: 16,
                right: 16,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Profil',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ValueListenableBuilder<String?>(
                    valueListenable: UserSession.instance.localPhotoPath,
                    builder: (_, localPath, __) {
                      return Container(
                        width: 88,
                        height: 88,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: localPath != null
                              ? Image.file(
                                  File(localPath),
                                  key: ValueKey(localPath),
                                  width: 88, height: 88, fit: BoxFit.cover,
                                )
                              : _defaultAvatar(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _profile?.fullName ?? '—',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Copropriétaire',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Menu items
            _menuCard(child: _menuItem(
              iconPath: 'assets/icons/edit.svg',
              title: 'Informations personnelles',
              iconBgColor: const Color(0x1A6F675E),
              trailing: const Icon(Icons.chevron_right, color: Color(0xFF2F3542), size: 20),
              onTap: () async {
                final updated = await Navigator.of(context).push<bool>(
                  PageRouteBuilder(
                    pageBuilder: (c, a, s) =>
                        InformationsPersonnellesPage(profile: _profile),
                    transitionsBuilder: (c, anim, s, child) => FadeTransition(
                        opacity: CurvedAnimation(
                            parent: anim, curve: Curves.easeOut),
                        child: child),
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
                if (updated == true) _loadProfile();
              },
            )),
            const SizedBox(height: 9),
            _menuCard(child: _menuItem(
              iconPath: 'assets/icons/devis.svg',
              title: 'Mes documents',
              iconBgColor: const Color(0x1A6F675E),
              trailing: const Icon(Icons.chevron_right, color: Color(0xFF2F3542), size: 20),
              onTap: () => Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (c, a, s) => const MesDocumentsPage(),
                transitionsBuilder: (c, anim, s, child) => FadeTransition(
                  opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut), child: child),
                transitionDuration: const Duration(milliseconds: 300),
              )),
            )),
            const SizedBox(height: 9),
            _menuCard(child: _menuItem(
              iconPath: 'assets/icons/warn.svg',
              title: 'Mes signalements',
              iconBgColor: const Color(0x1A6F675E),
              iconSize: 16,
              trailing: const Icon(Icons.chevron_right, color: Color(0xFF2F3542), size: 20),
              onTap: () => Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (c, a, s) => const MesSignalementsPage(),
                transitionsBuilder: (c, anim, s, child) => FadeTransition(
                  opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut), child: child),
                transitionDuration: const Duration(milliseconds: 300),
              )),
            )),
            const SizedBox(height: 9),
            // ABONNEMENT - commenté temporairement
            // _menuCard(child: _menuItem(
            //   iconPath: 'assets/icons/souscrip.svg',
            //   title: 'Mon abonnement',
            //   iconBgColor: const Color(0x1A6F675E),
            //   trailing: const Icon(Icons.chevron_right, color: Color(0xFF2F3542), size: 20),
            //   onTap: () => Navigator.of(context).push(PageRouteBuilder(
            //     pageBuilder: (c, a, s) => const MonAbonnementPage(),
            //     transitionsBuilder: (c, anim, s, child) => FadeTransition(
            //       opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut), child: child),
            //     transitionDuration: const Duration(milliseconds: 300),
            //   )),
            // )),
            // const SizedBox(height: 9),
            _menuCard(child: _menuItem(
              iconPath: 'assets/icons/notif.svg',
              title: 'Notifications',
              subtitle: 'Alertes et rappels',
              iconBgColor: const Color(0x1A6F675E),
              trailing: GestureDetector(
                onTap: () => _toggleNotifications(!_notificationsEnabled),
                child: SvgPicture.asset(
                  'assets/icons/Button.svg',
                  width: 48,
                  height: 24,
                  colorFilter: _notificationsEnabled
                      ? null
                      : const ColorFilter.mode(Color(0xFFD1D5DB), BlendMode.srcIn),
                ),
              ),
            )),
            const SizedBox(height: 9),
            _menuCard(child: _menuItem(
              iconPath: 'assets/icons/logout.svg',
              title: 'Se déconnecter',
              iconBgColor: const Color(0x0DFF6B6B),
              titleColor: const Color(0xFFFF6B6B),
              trailing: const SizedBox.shrink(),
              onTap: () => _onLogout(),
            )),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
