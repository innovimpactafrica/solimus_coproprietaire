import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/dashboard_model.dart';
import '../../models/meeting_model.dart';
import '../../services/auth_storage.dart';
import '../../services/coowner_service.dart';
import '../../services/user_session.dart';
import '../auth/login.dart';
import '../profil/profil.dart';
import '../profil/nouveau_signalement.dart';
import '../charges/mes_charges.dart';
import '../incidents/mes_incidents.dart';
import '../reunions/reunions.dart';
import '../reunions/reunion_detail.dart';

enum _ChargeStatus { enAttente, enRetard, paye }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DashboardHeader? _header;
  DashboardKpis? _kpis;
  List<DashboardPendingCharge> _pendingCharges = [];
  List<MeetingModel> _meetings = [];
  int? _selectedResidenceId;
  int? _selectedPropertyId;
  List<DashboardProperty> _properties = [];
  String? _errorMessage;
  final _unreadNotifCount = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _errorMessage = null);
    try {
      final results = await Future.wait([
        CoOwnerService.getDashboardHeader(),
        CoOwnerService.getDashboardProperties(),
      ]);
      if (!mounted) return;

      final header = results[0] as DashboardHeader;
      final properties = results[1] as List<DashboardProperty>;

      setState(() {
        _header = header;
        _properties = properties;
        _unreadNotifCount.value = header.unreadNotificationsCount;
        if (properties.isNotEmpty) {
          _selectedPropertyId ??= properties.first.propertyId;
          _selectedResidenceId ??= properties.first.residenceId;
        }
      });

      if (_selectedResidenceId != null) {
        await _reloadForResidence(_selectedResidenceId!);
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      if (msg.contains('401') || msg.contains('403') || msg.contains('Unauthorized')) {
        await AuthStorage.clear();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (_) => false,
        );
        return;
      }
      if (msg.contains('500') || msg.contains('502') || msg.contains('503')) return;
      setState(() => _errorMessage = msg);
    }
  }

  DashboardProperty? get _selectedProperty {
    if (_properties.isEmpty) return null;
    try {
      return _properties.firstWhere((p) => p.propertyId == _selectedPropertyId);
    } catch (_) {
      return _properties.first;
    }
  }

  void _showResidencePicker() {
    if (_properties.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFAF9F4),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text('Mon Appartement', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520))),
              const SizedBox(height: 12),
              ..._properties.map((p) {
                final isSelected = p.propertyId == _selectedPropertyId;
                return GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    setState(() {
                      _selectedPropertyId = p.propertyId;
                      _selectedResidenceId = p.residenceId;
                    });
                    await _reloadForResidence(p.residenceId);
                  },
                  child: _pickerItem(
                    title: p.residenceName,
                    subtitle: p.propertyReference,
                    isSelected: isSelected,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _reloadForResidence(int residenceId) async {
    try {
      final kpis = await CoOwnerService.getDashboardKpis(residenceId);
      final charges = await CoOwnerService.getDashboardPendingCharges(residenceId);
      final meetings = await CoOwnerService.getDashboardUpcomingMeetings(residenceId);
      if (mounted) setState(() { _kpis = kpis; _pendingCharges = charges; _meetings = meetings; });
    } catch (_) {}
  }

  Widget _pickerItem({required String title, String? subtitle, required bool isSelected}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF6F675E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF2D2520))),
              if (subtitle != null) ...
                [
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 12,
                      color: isSelected ? Colors.white.withValues(alpha: 0.75) : const Color(0xFF6A7282))),
                ],
            ],
          ),
          if (isSelected) const Icon(Icons.check_rounded, color: Colors.white, size: 20),
        ],
      ),
    );
  }

  void _showNotificationsPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _NotificationsSheet(
        initialUnreadCount: _unreadNotifCount.value,
        onMarkAllRead: () async {
          await CoOwnerService.markAllNotificationsRead();
          _unreadNotifCount.value = 0;
          final header = await CoOwnerService.getDashboardHeader();
          if (mounted) setState(() => _header = header);
        },
      ),
    );
  }

  String _formatAmount(double amount) {
    final intPart = amount.truncate();
    final decimals = amount - intPart;
    final str = intPart.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(' ');
      buf.write(str[i]);
    }
    if (decimals > 0.001) {
      buf.write(',');
      buf.write((decimals * 100).round().toString().padLeft(2, '0'));
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

String _meetingStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'A_VENIR':  return 'À venir';
      case 'EN_COURS': return 'En cours';
      default:         return 'Planifié';
    }
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 286,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
            child: (_header?.residencePhotoUrl != null && _header!.residencePhotoUrl!.isNotEmpty)
                ? Image.network(
                    _header!.residencePhotoUrl!,
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
                  style: GoogleFonts.jost(fontWeight: FontWeight.w400, fontSize: 14, color: Colors.white),
                ),
                Text(
                  _header?.firstName ?? '—',
                  style: GoogleFonts.jost(fontWeight: FontWeight.w700, fontSize: 24, color: Colors.white),
                ),
              ],
            ),
          ),
          Positioned(
            top: 60,
            right: 24,
            child: Row(
              children: [
                GestureDetector(
                  onTap: _showNotificationsPanel,
                  child: Stack(
                    children: [
                      SvgPicture.asset('assets/icons/notification.svg', width: 28, height: 28),
                      ValueListenableBuilder<int>(
                        valueListenable: _unreadNotifCount,
                        builder: (_, count, __) => count > 0
                            ? Positioned(
                                top: 2, right: 2,
                                child: Container(
                                  width: 8, height: 8,
                                  decoration: const BoxDecoration(color: Color(0xFFFF3B30), shape: BoxShape.circle),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ValueListenableBuilder<String?>(
                  valueListenable: UserSession.instance.localPhotoPath,
                  builder: (_, localPath, __) {
                    final initial = _header?.firstName.isNotEmpty == true
                        ? _header!.firstName[0].toUpperCase()
                        : '';
                    return Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipOval(
                        child: localPath != null
                            ? Image.file(File(localPath), key: ValueKey(localPath), width: 36, height: 36, fit: BoxFit.cover)
                            : Center(
                                child: initial.isNotEmpty
                                    ? Text(initial, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF6F675E)))
                                    : const Icon(Icons.person, size: 20, color: Color(0xFF6F675E)),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Carte Mon Appartement
          Positioned(
            top: 118,
            left: 19,
            right: 19,
            height: 76,
            child: GestureDetector(
              onTap: _showResidencePicker,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0x26FFFFFF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x33FFFFFF), width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Mon Appartement',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, height: 1.1,
                                color: Colors.white.withValues(alpha: 0.8))),
                        Text(_selectedProperty?.residenceName ?? '—',
                            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, height: 1.2, color: Colors.white)),
                        if (_selectedProperty != null)
                          Text(_selectedProperty!.propertyReference,
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, height: 1.1,
                                  color: Colors.white.withValues(alpha: 0.85))),
                      ],
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 26),
                  ],
                ),
              ),
            ),
          ),
          // KPI cards
          Positioned(
            bottom: 0,
            left: 19,
            right: 19,
            height: 72,
            child: Row(
              children: [
                Expanded(
                  child: _financialCard(
                    iconPath: 'assets/icons/solde actu.svg',
                    label: 'Charge annuelle',
                    amount: '${_formatAmount(_kpis?.annualCharge ?? 0)} FCFA',
                    iconBgColor: const Color(0xFFE6F7F1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _financialCard(
                    iconPath: 'assets/icons/montant.svg',
                    label: 'Restant à payer',
                    amount: '${_formatAmount(_kpis?.remainingToPay ?? 0)} FCFA',
                    iconBgColor: const Color(0xFFFFECED),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _financialCard({
    required String iconPath,
    required String label,
    required String amount,
    required Color iconBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: SvgPicture.asset(iconPath, width: 24, height: 24),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6A7282),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  amount,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2520),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalementBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (c, a, s) => const NouveauSignalementPage(),
          transitionsBuilder: (c, anim, s, child) => FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: child,
          ),
          transitionDuration: Duration.zero,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 23),
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0x1AF9C20A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF9C20A), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // illus en fond à droite
              Positioned(
                right: 45,
                top: 0,
                bottom: 0,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SvgPicture.asset(
                    'assets/icons/illus.svg',
                    width: 84,
                    height: 96,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Contenu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Textes à gauche
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Signaler un problème',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFF9C20A),
                              height: 28 / 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Déclarez une réclamation, une nuisance\nou tout autre problème dans votre résidence.',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6B5744),
                              height: 15 / 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Icône mégaphone à droite
                    Transform.rotate(
                      angle: 15 * 3.14159265 / 180,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF9C20A),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Transform.rotate(
                          angle: -15 * 3.14159265 / 180,
                          child: SvgPicture.asset(
                            'assets/icons/SVG.svg',
                            width: 40,
                            height: 40,
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

  _ChargeStatus _mapStatus(String s) {
    final upper = s.toUpperCase();
    if (upper == 'PAYEE' || upper == 'PAYÉ' || upper == 'PAYE' || s == 'Payé') return _ChargeStatus.paye;
    if (upper == 'EN_RETARD' || upper == 'EN RETARD') return _ChargeStatus.enRetard;
    return _ChargeStatus.enAttente;
  }

  Widget _buildStatusBadge(_ChargeStatus status) {
    switch (status) {
      case _ChargeStatus.enAttente:
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
      case _ChargeStatus.enRetard:
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
      case _ChargeStatus.paye:
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

  Widget _buildChargesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Charges en attentes',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520)),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (c, a, s) => const MesChargesPage(),
                    transitionsBuilder: (c, anim, s, child) => FadeTransition(
                      opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut), child: child),
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                ),
                child: Text(
                  'Voir plus',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    height: 1.0, letterSpacing: -0.41, color: const Color(0xFF6F675E),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_pendingCharges.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Aucune charge en attente',
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6A7282))),
          )
        else
          SizedBox(
            height: 155,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16, right: 8),
              children: _pendingCharges.take(2).expand((c) => [
                _buildPendingChargeCard(c),
                const SizedBox(width: 12),
              ]).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildPendingChargeCard(DashboardPendingCharge charge) {
    final status = _mapStatus(charge.status);
    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  charge.title,
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520)),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            [charge.residenceName, charge.propertyReference]
                .where((e) => e != null && e.isNotEmpty).join(' • '),
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF6A7282)),
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFF3F4F6), thickness: 1, height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  SvgPicture.asset('assets/icons/calendar.svg', width: 14, height: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Échéance: ${_formatDate(charge.dueDate)}',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF6A7282)),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatAmount(charge.remainingAmount),
                    style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520), height: 1.1),
                  ),
                  Text('FCFA', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF6A7282))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  String _typeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'ASSEMBLEE_GENERALE': return 'Assemblée Générale';
      case 'CONSEIL_SYNDICAL':   return 'Conseil Syndical';
      case 'TECHNIQUE':          return 'Technique';
      default:                   return type;
    }
  }

  // ignore: unused_element
  Color _typeColor(String type) {
    switch (type.toUpperCase()) {
      case 'ASSEMBLEE_GENERALE': return const Color(0xFFDC2626);
      case 'CONSEIL_SYNDICAL':   return const Color(0xFF2B7FFF);
      case 'TECHNIQUE':          return const Color(0xFF9B59B6);
      case 'ORDINARY':           return const Color(0xFF2B7FFF);
      case 'EXTRAORDINARY':      return const Color(0xFFDC2626);
      default:                   return const Color(0xFF6F675E);
    }
  }

  // ignore: unused_element
  Color _typeBg(String type) {
    switch (type.toUpperCase()) {
      case 'ASSEMBLEE_GENERALE': return const Color(0xFFFFF0F0);
      case 'CONSEIL_SYNDICAL':   return const Color(0xFFEEF4FF);
      case 'TECHNIQUE':          return const Color(0xFFF5EEFF);
      case 'ORDINARY':           return const Color(0xFFEEF4FF);
      case 'EXTRAORDINARY':      return const Color(0xFFFFF0F0);
      default:                   return const Color(0x1A6F675E);
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'A_VENIR':   return const Color(0xFF00A63E);
      case 'EN_COURS':  return const Color(0xFFE17100);
      case 'TERMINEE':  return const Color(0xFF6A7282);
      case 'DRAFT':     return const Color(0xFF6A7282);
      case 'SCHEDULED': return const Color(0xFF00A63E);
      case 'ONGOING':   return const Color(0xFFE17100);
      case 'COMPLETED': return const Color(0xFF6A7282);
      default:          return const Color(0xFF6A7282);
    }
  }

  // ignore: unused_element
  Color _statusBg(String status) {
    switch (status.toUpperCase()) {
      case 'A_VENIR':   return const Color(0xFFEFFFF6);
      case 'EN_COURS':  return const Color(0xFFFFF4E6);
      case 'TERMINEE':  return const Color(0xFFF3F4F6);
      case 'DRAFT':     return const Color(0xFFF3F4F6);
      case 'SCHEDULED': return const Color(0xFFEFFFF6);
      case 'ONGOING':   return const Color(0xFFFFF4E6);
      case 'COMPLETED': return const Color(0xFFF3F4F6);
      default:          return const Color(0xFFF3F4F6);
    }
  }

  DateTime? _parseMeetingDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try { return DateTime.parse(raw); } catch (_) {}
    final parts = raw.split('/');
    if (parts.length == 3) {
      try { return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0])); } catch (_) {}
    }
    return null;
  }

  // ignore: unused_element
  String _formatMeetingDate(MeetingModel m) {
    if (m.meetingDate == null) return '';
    final dt = _parseMeetingDate(m.meetingDate);
    if (dt == null) return m.meetingDate!;
    const days = ['dimanche', 'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi'];
    const months = ['', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
        'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];
    return '${days[dt.weekday % 7]} ${dt.day} ${months[dt.month]} ${dt.year}';
  }

  // ignore: unused_element
  Widget _buildMeetingTag(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: textColor)),
    );
  }

  // ignore: unused_element
  Widget _buildMeetingInfoRow(String svgPath, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          SvgPicture.asset(svgPath, width: 16, height: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: const Color(0xFF8B7355)),
              overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Prochaine réunions',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520)),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (c, a, s) => const ReunionPage(),
                    transitionsBuilder: (c, anim, s, child) => FadeTransition(
                      opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut), child: child),
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                ),
                child: Text(
                  'Voir plus',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    height: 1.0, letterSpacing: -0.41, color: const Color(0xFF6F675E),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_meetings.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Aucune réunion à venir',
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6A7282))),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _meetings.expand((m) => [
                _buildMeetingCard(m),
                const SizedBox(width: 12),
              ]).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildMeetingCard(MeetingModel m) {
    final timeStr = m.meetingStartTime != null && m.meetingStartTime!.isNotEmpty
        ? (m.meetingEndTime != null && m.meetingEndTime!.isNotEmpty
            ? '${m.meetingStartTime} - ${m.meetingEndTime}'
            : m.meetingStartTime!)
        : null;
    final subtitle = [if (timeStr != null) timeStr, if (m.location != null && m.location!.isNotEmpty) m.location!].join(' | ');
    final statusLabel = m.statusLabel.isNotEmpty ? m.statusLabel : _meetingStatusLabel(m.status);
    final statusColor = _statusColor(m.status);

    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barre verticale gauche
              Container(
                width: 3,
                height: 40,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2520),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.title,
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty) ...
                      [
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF6A7282)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                statusLabel,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset('assets/icons/lucide_paperclip.svg', width: 16, height: 16),
                  const SizedBox(width: 6),
                  Text('${m.documentCount}',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF6A7282))),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (c, a, s) => ReunionDetailPage(meetingId: m.id),
                    transitionsBuilder: (c, anim, s, child) => FadeTransition(
                      opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut), child: child),
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                ),
                child: const Icon(Icons.arrow_forward, size: 18, color: Color(0xFF2D2520)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    String iconPath,
    String label, {
    bool active = false,
    VoidCallback? onTap,
  }) {
    final childWidget = active
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(iconPath, width: 18, height: 18),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6F675E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.transparent,
          height: double.infinity,
          alignment: Alignment.center,
          child: childWidget,
        ),
      ),
    );
  }

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
          children: [
            _buildNavItem('assets/icons/accueil.svg', 'Accueil', active: true),
            _buildNavItem(
              'assets/icons/charges.svg',
              'Charges',
              onTap: () => Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (c, a, s) => const MesChargesPage(),
                  transitionsBuilder: (c, anim, s, child) => FadeTransition(
                    opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
                    child: child,
                  ),
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              ),
            ),
            _buildNavItem(
              'assets/icons/travaux.svg',
              'Demandes',
              onTap: () => Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (c, a, s) => const MesIncidentsPage(),
                  transitionsBuilder: (c, anim, s, child) => FadeTransition(
                    opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
                    child: child,
                  ),
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              ),
            ),
            _buildNavItem(
              'assets/icons/reunion.svg',
              'Réunion',
              onTap: () => Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (c, a, s) => const ReunionPage(),
                  transitionsBuilder: (c, anim, s, child) => FadeTransition(
                    opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
                    child: child,
                  ),
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              ),
            ),
            _buildNavItem(
              'assets/icons/profil.svg',
              'Profil',
              onTap: () => Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (c, a, s) => const ProfilPage(),
                  transitionsBuilder: (c, anim, s, child) => FadeTransition(
                    opacity: CurvedAnimation(
                      parent: anim,
                      curve: Curves.easeOut,
                    ),
                    child: child,
                  ),
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              ),
            ),
          ],
        ),
      ),
      body: _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6A7282)),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6F675E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      ),
                      child: Text('Réessayer', style: GoogleFonts.inter(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildSignalementBanner(context),
            const SizedBox(height: 24),
            _buildChargesSection(),
            const SizedBox(height: 24),
            _buildMeetingsSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _NotificationsSheet extends StatefulWidget {
  final Future<void> Function() onMarkAllRead;
  final int initialUnreadCount;
  const _NotificationsSheet({required this.onMarkAllRead, required this.initialUnreadCount});

  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  List<DashboardNotification> _notifications = [];
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
      final res = await CoOwnerService.getDashboardNotifications();
      if (mounted) setState(() { _notifications = res.notifications; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatNotifDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    } catch (_) { return raw; }
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
              width: 40, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Notifications', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520))),
                    GestureDetector(
                    onTap: _unreadCount > 0 ? () async {
                      await widget.onMarkAllRead();
                      setState(() {
                        _unreadCount = 0;
                        _notifications = _notifications.map((n) => DashboardNotification(id: n.id, title: n.title, body: n.body, read: true, createdAt: n.createdAt)).toList();
                      });
                    } : null,
                    child: Text('Tout marquer comme lu', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _unreadCount > 0 ? const Color(0xFF6F675E) : const Color(0xFFD1D5DB))),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _notifications.isEmpty
                      ? Center(child: Text('Aucune notification', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6A7282))))
                      : ListView.separated(
                          controller: controller,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _notifications.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                          itemBuilder: (_, i) {
                            final n = _notifications[i];
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              color: n.read ? Colors.transparent : const Color(0xFFF0EDE8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!n.read)
                                    Container(
                                      margin: const EdgeInsets.only(top: 6, right: 8),
                                      width: 8, height: 8,
                                      decoration: const BoxDecoration(color: Color(0xFF6F675E), shape: BoxShape.circle),
                                    )
                                  else
                                    const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(n.title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF2D2520))),
                                        const SizedBox(height: 4),
                                        Text(n.body, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6A7282))),
                                        const SizedBox(height: 4),
                                        Text(_formatNotifDate(n.createdAt), style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF))),
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
