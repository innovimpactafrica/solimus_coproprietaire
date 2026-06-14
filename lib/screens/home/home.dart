import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/dashboard_model.dart';
import '../../models/charge_model.dart';
import '../../models/meeting_model.dart';
import '../../services/auth_storage.dart';
import '../../services/coowner_service.dart';
import '../../services/user_session.dart';
import '../profil/profil.dart';
import '../documents/mes_documents.dart';
import '../charges/mes_charges.dart';
import '../charges/charge_detail.dart';
import '../incidents/mes_incidents.dart';
import '../reunions/reunions.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DashboardModel? _dashboard;
  String? _token;
  int? _selectedPropertyId;

  DashboardProperty? get _selectedProperty {
    if (_dashboard == null) return null;
    final id = _selectedPropertyId ?? _dashboard!.selectedPropertyId;
    try {
      return _dashboard!.properties.firstWhere((p) => p.id == id);
    } catch (_) {
      return _dashboard!.properties.isNotEmpty ? _dashboard!.properties.first : null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        CoOwnerService.getDashboard(),
        AuthStorage.getToken(),
      ]);
      if (!mounted) return;
      setState(() {
        _dashboard = results[0] as DashboardModel;
        _token = results[1] as String?;
        _selectedPropertyId = (_dashboard as DashboardModel).selectedPropertyId;
      });
    } catch (_) {}
  }

  void _showPropertyPicker() {
    if (_dashboard == null || _dashboard!.properties.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFAF9F4),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Mes biens',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D2520),
              ),
            ),
            const SizedBox(height: 12),
            ..._dashboard!.properties.map((p) {
              final isSelected = p.id == (_selectedPropertyId ?? _dashboard!.selectedPropertyId);
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedPropertyId = p.id);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF6F675E) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.residenceName,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF2D2520),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p.reference,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.75)
                                  : const Color(0xFF6A7282),
                            ),
                          ),
                        ],
                      ),
                      if (isSelected)
                        const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
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
            child: Image.asset(
              'assets/images/cop.png',
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
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
          // Greeting
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
                    color: Colors.white,
                  ),
                ),
                Text(
                  _dashboard?.fullName ?? '—',
                  style: GoogleFonts.jost(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Notification + Avatar
          Positioned(
            top: 60,
            right: 24,
            child: Row(
              children: [
                Stack(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/notification.svg',
                      width: 28,
                      height: 28,
                    ),
                    Positioned(
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
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                ValueListenableBuilder<String?>(
                  valueListenable: UserSession.instance.localPhotoPath,
                  builder: (_, localPath, __) {
                    return Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipOval(
                        child: localPath != null
                            ? Image.file(
                                File(localPath),
                                key: ValueKey(localPath),
                                width: 36, height: 36, fit: BoxFit.cover,
                              )
                            : Image.asset('assets/images/plumbing.png', width: 36, height: 36, fit: BoxFit.cover),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Property info card
          Positioned(
            top: 118,
            left: 19,
            right: 19,
            height: 76,
            child: GestureDetector(
              onTap: _showPropertyPicker,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0x26FFFFFF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0x33FFFFFF),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Mon bien',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            height: 1.1,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        Text(
                          _selectedProperty?.residenceName ?? '—',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _selectedProperty?.reference ?? '—',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.1,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                    AnimatedRotation(
                      turns: 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Financial cards overlapping header bottom
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
                    label: 'Solde actuel',
                    amount: '${_formatAmount(_dashboard?.soldeActuelResidence ?? 0)} FCFA',
                    iconBgColor: const Color(0xFFE6F7F1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _financialCard(
                    iconPath: 'assets/icons/montant.svg',
                    label: 'Montant arriérés',
                    amount: '${_formatAmount(_dashboard?.montantArrieresResidence ?? 0)} FCFA',
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

  Widget _buildDocumentsBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (c, a, s) => const MesDocumentsPage(),
          transitionsBuilder: (c, anim, s, child) => FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF6F675E),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voir mes documents',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_dashboard?.totalDocuments ?? 0} document${(_dashboard?.totalDocuments ?? 0) > 1 ? 's' : ''}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/doc.svg',
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ChargeStatus _mapStatus(String s) {
    switch (s.toUpperCase()) {
      case 'PAYEE':     return ChargeStatus.paye;
      case 'EN_RETARD': return ChargeStatus.enRetard;
      default:          return ChargeStatus.enAttente;
    }
  }

  Widget _buildStatusBadge(ChargeStatus status) {
    switch (status) {
      case ChargeStatus.enAttente:
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
      case ChargeStatus.enRetard:
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
      case ChargeStatus.paye:
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
        SizedBox(
          height: 190,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16, right: 8),
            children: _dashboard == null || _dashboard!.chargesEnAttente.isEmpty
                ? [_buildChargeCard(ChargeModel(
                    id: 0, allocationId: 0, title: 'Charges mensuelles',
                    amount: 0, status: 'EN_ATTENTE'))]
                : _dashboard!.chargesEnAttente.take(5).expand((c) => [
                    _buildChargeCard(c),
                    const SizedBox(width: 12),
                  ]).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildChargeCard(ChargeModel charge) {
    final status = _mapStatus(charge.status);
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 6),
          Text(
            [charge.residenceName, charge.propertyReference]
                .where((e) => e != null && e.isNotEmpty).join(' • '),
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: const Color(0xFF6A7282)),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(20)),
            child: Text(
              charge.status,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF4B5563)),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF3F4F6), thickness: 1, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  SvgPicture.asset('assets/icons/calendar.svg', width: 14, height: 14),
                  const SizedBox(width: 6),
                  Text(
                    charge.status == 'PAYEE'
                        ? 'Payé le ${_formatDate(charge.dueDate)}'
                        : 'Échéance: ${_formatDate(charge.dueDate)}',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF6A7282)),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatAmount(charge.amount),
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

  String _typeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'ASSEMBLEE_GENERALE': return 'Assemblée Générale';
      case 'CONSEIL_SYNDICAL':   return 'Conseil Syndical';
      case 'TECHNIQUE':          return 'Technique';
      default:                   return type;
    }
  }

  Color _typeColor(String type) {
    switch (type.toUpperCase()) {
      case 'ASSEMBLEE_GENERALE': return const Color(0xFFDC2626);
      case 'CONSEIL_SYNDICAL':   return const Color(0xFF2B7FFF);
      case 'TECHNIQUE':          return const Color(0xFF9B59B6);
      default:                   return const Color(0xFF6F675E);
    }
  }

  Color _typeBg(String type) {
    switch (type.toUpperCase()) {
      case 'ASSEMBLEE_GENERALE': return const Color(0xFFFFF0F0);
      case 'CONSEIL_SYNDICAL':   return const Color(0xFFEEF4FF);
      case 'TECHNIQUE':          return const Color(0xFFF5EEFF);
      default:                   return const Color(0x1A6F675E);
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'A_VENIR':  return const Color(0xFF00A63E);
      case 'EN_COURS': return const Color(0xFFE17100);
      case 'TERMINEE': return const Color(0xFF6A7282);
      default:         return const Color(0xFF6A7282);
    }
  }

  Color _statusBg(String status) {
    switch (status.toUpperCase()) {
      case 'A_VENIR':  return const Color(0xFFEFFFF6);
      case 'EN_COURS': return const Color(0xFFFFF4E6);
      case 'TERMINEE': return const Color(0xFFF3F4F6);
      default:         return const Color(0xFFF3F4F6);
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

  String _formatMeetingDate(MeetingModel m) {
    if (m.meetingDate == null) return '';
    final dt = _parseMeetingDate(m.meetingDate);
    if (dt == null) return m.meetingDate!;
    const days = ['dimanche', 'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi'];
    const months = ['', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
        'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];
    return '${days[dt.weekday % 7]} ${dt.day} ${months[dt.month]} ${dt.year}';
  }

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
        if (_dashboard == null || _dashboard!.prochainesReunions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Aucune réunion à venir',
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6A7282))),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _dashboard!.prochainesReunions.take(5).expand((m) => [
                  SizedBox(width: 300, child: _buildMeetingCard(m)),
                  const SizedBox(width: 12),
                ]).toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMeetingCard(MeetingModel m) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(m.title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520))),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              _buildMeetingTag(_typeLabel(m.type), _typeColor(m.type), _typeBg(m.type)),
              _buildMeetingTag(_meetingStatusLabel(m.status), _statusColor(m.status), _statusBg(m.status)),
            ],
          ),
          if (m.meetingDate != null && m.meetingDate!.isNotEmpty)
            _buildMeetingInfoRow('assets/icons/1.svg', _formatMeetingDate(m)),
          if (m.meetingStartTime != null && m.meetingStartTime!.isNotEmpty)
            _buildMeetingInfoRow('assets/icons/2.svg',
                m.meetingEndTime != null && m.meetingEndTime!.isNotEmpty
                    ? '${m.meetingStartTime} - ${m.meetingEndTime}'
                    : m.meetingStartTime!),
          if (m.location != null && m.location!.isNotEmpty)
            _buildMeetingInfoRow('assets/icons/3.svg', m.location!),
          _buildMeetingInfoRow('assets/icons/4.svg', '${m.participantCount} participants'),
          _buildMeetingInfoRow('assets/icons/5.svg', '${m.documentCount} document(s)'),
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
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F4),
      bottomNavigationBar: Container(
        height: 82,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              'assets/icons/incident.svg',
              'Incidents',
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildDocumentsBanner(context),
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
