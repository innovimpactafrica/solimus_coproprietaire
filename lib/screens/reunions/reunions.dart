import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/meeting_model.dart';
import '../../services/coowner_service.dart';
import 'reunion_detail.dart';
import '../home/home.dart';
import '../charges/mes_charges.dart';
import '../incidents/mes_incidents.dart';
import '../profil/profil.dart';

class ReunionPage extends StatefulWidget {
  const ReunionPage({super.key});

  @override
  State<ReunionPage> createState() => _ReunionPageState();
}

class _ReunionPageState extends State<ReunionPage> {
  int _viewMode = 0;
  DateTime _selectedDay = DateTime.now();
  DateTime _displayedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  List<MeetingModel> _meetings = [];
  Map<String, List<MeetingModel>> _calendarMeetings = {};
  int _upcomingCount = 0;
  bool _isLoading = true;
  bool _isCalendarLoading = false;

  static const _monthNames = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];
  static const _dayNames = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
  static const _dayFullNames = ['dimanche', 'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi'];

  @override
  void initState() {
    super.initState();
    _loadMeetings();
    _loadCalendar(_displayedMonth.year, _displayedMonth.month);
  }

  Future<void> _loadMeetings() async {
    try {
      final results = await Future.wait([
        CoOwnerService.getMeetings(),
        CoOwnerService.getUpcomingMeetingsCount(),
      ]);
      if (!mounted) return;
      setState(() {
        _meetings = results[0] as List<MeetingModel>;
        _upcomingCount = results[1] as int;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _loadCalendar(int year, int month) async {
    setState(() => _isCalendarLoading = true);
    try {
      final data = await CoOwnerService.getMeetingsCalendar(year: year, month: month);
      if (!mounted) return;
      setState(() {
        _calendarMeetings = data;
        _isCalendarLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCalendarLoading = false);
    }
  }

  // Type mapping helpers
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

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'A_VENIR':   return 'À venir';
      case 'EN_COURS':  return 'En cours';
      case 'TERMINEE':  return 'Terminée';
      default:          return status;
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

  /// Parse une date qui peut être "YYYY-MM-DD" ou "DD/MM/YYYY"
  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try { return DateTime.parse(raw); } catch (_) {}
    // Essai format DD/MM/YYYY
    final parts = raw.split('/');
    if (parts.length == 3) {
      try {
        return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      } catch (_) {}
    }
    return null;
  }

  String _formatDate(MeetingModel m) {
    if (m.meetingDate == null) return '';
    final dt = _parseDate(m.meetingDate);
    if (dt != null) {
      return '${_dayFullNames[dt.weekday % 7]} ${dt.day} ${_monthNames[dt.month - 1]} ${dt.year}';
    }
    return m.meetingDate!;
  }

  String _formatTime(MeetingModel m) {
    if (m.meetingStartTime != null && m.meetingStartTime!.isNotEmpty) {
      return m.meetingStartTime!;
    }
    return '';
  }

  List<MeetingModel> _meetingsForDay(DateTime day) {
    final isoKey = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    if (_calendarMeetings.containsKey(isoKey)) return _calendarMeetings[isoKey]!;
    // Essai format DD/MM/YYYY si l'API retourne ce format comme clé
    final dmyKey = '${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}/${day.year}';
    return _calendarMeetings[dmyKey] ?? [];
  }

  Widget _buildCalendarView() {
    final year = _displayedMonth.year;
    final month = _displayedMonth.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // Dart: Mon=1..Sun=7 → convert to Sun=0
    final firstOffset = DateTime(year, month, 1).weekday % 7;
    final monthLabel =
        '${_monthNames[month - 1]} $year';
    final selectedMeetings = _meetingsForDay(_selectedDay);

    // Build week rows as list of nullable day numbers
    final List<List<int?>> weeks = [];
    int d = 1;
    for (int row = 0; row < 6; row++) {
      if (d > daysInMonth) break;
      final week = List<int?>.filled(7, null);
      for (int col = 0; col < 7; col++) {
        if (row == 0 && col < firstOffset) continue;
        if (d <= daysInMonth) week[col] = d++;
      }
      weeks.add(week);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              // Month navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      final newMonth = DateTime(year, month - 1, 1);
                      setState(() => _displayedMonth = newMonth);
                      _loadCalendar(newMonth.year, newMonth.month);
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_left_rounded,
                          color: Color(0xFF6A7282), size: 22),
                    ),
                  ),
                  Text(
                    monthLabel,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2520),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      final newMonth = DateTime(year, month + 1, 1);
                      setState(() => _displayedMonth = newMonth);
                      _loadCalendar(newMonth.year, newMonth.month);
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_right_rounded,
                          color: Color(0xFF6A7282), size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Day-of-week headers
              Row(
                children: _dayNames
                    .map((n) => Expanded(
                          child: Center(
                            child: Text(
                              n,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
              // Calendar grid
              ...weeks.map((week) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: week.map((day) {
                        if (day == null) {
                          return const Expanded(child: SizedBox(height: 40));
                        }
                        final date = DateTime(year, month, day);
                        final hasMeeting = _meetingsForDay(date).isNotEmpty;
                        final isSelected = _selectedDay.year == year &&
                            _selectedDay.month == month &&
                            _selectedDay.day == day;
                        return Expanded(
                          child: GestureDetector(
                            onTap: hasMeeting
                                ? () =>
                                    setState(() => _selectedDay = date)
                                : null,
                            child: Center(
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: hasMeeting
                                          ? const BoxDecoration(
                                              color: Color(0xFFF9C20A),
                                              shape: BoxShape.circle,
                                            )
                                          : null,
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: Text(
                                              '$day',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: hasMeeting
                                                    ? FontWeight.w700
                                                    : FontWeight.w400,
                                                color: hasMeeting
                                                    ? Colors.white
                                                    : const Color(0xFF2D2520),
                                              ),
                                            ),
                                          ),
                                          if (hasMeeting)
                                            Positioned(
                                              top: 3,
                                              right: 3,
                                              child: Container(
                                                width: 7,
                                                height: 7,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFDC2626),
                                                  shape: BoxShape.circle,
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
                          ),
                        );
                      }).toList(),
                    ),
                  )),
            ],
          ),
        ),
        if (selectedMeetings.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Réunions du ${_selectedDay.day} ${_monthNames[_selectedDay.month - 1]}',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2520),
            ),
          ),
          const SizedBox(height: 12),
          ...selectedMeetings
              .map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildMeetingCard(m),
                  ))
              .toList(),
        ],
      ],
    );
  }

  Widget _buildNavItem(
    String iconPath,
    String label, {
    bool active = false,
    VoidCallback? onTap,
  }) {
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
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String svgPath, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          SvgPicture.asset(svgPath, width: 16, height: 16),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF8B7355),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingCard(MeetingModel m) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (c, a, s) => ReunionDetailPage(meetingId: m.id),
          transitionsBuilder: (c, anim, s, child) => FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              m.title,
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520)),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                _buildTag(_typeLabel(m.type), _typeColor(m.type), _typeBg(m.type)),
                _buildTag(_statusLabel(m.status), _statusColor(m.status), _statusBg(m.status)),
              ],
            ),
            if (m.meetingDate != null && m.meetingDate!.isNotEmpty)
              _buildInfoRow('assets/icons/1.svg', _formatDate(m)),
            if (m.meetingStartTime != null && m.meetingStartTime!.isNotEmpty)
              _buildInfoRow('assets/icons/2.svg', m.meetingEndTime != null && m.meetingEndTime!.isNotEmpty
                  ? '${m.meetingStartTime} - ${m.meetingEndTime}'
                  : m.meetingStartTime!),
            if (m.location != null && m.location!.isNotEmpty)
              _buildInfoRow('assets/icons/3.svg', m.location!),
            _buildInfoRow('assets/icons/4.svg', '${m.participantCount} participants'),
            _buildInfoRow('assets/icons/5.svg', '${m.documentCount} document(s)'),
          ],
        ),
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
            BoxShadow(color: Color(0x1A000000), offset: Offset(0, -1), blurRadius: 32),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildNavItem(
              'assets/icons/accueil.svg',
              'Accueil',
              onTap: () => Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (c, a, s) => const HomePage(),
                  transitionsBuilder: (c, anim, s, child) => FadeTransition(
                    opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
                    child: child,
                  ),
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              ),
            ),
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
            _buildNavItem('assets/icons/reunion.svg', 'Réunion', active: true),
            _buildNavItem(
              'assets/icons/profil.svg',
              'Profil',
              onTap: () => Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (c, a, s) => const ProfilPage(),
                  transitionsBuilder: (c, anim, s, child) => FadeTransition(
                    opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
                    child: child,
                  ),
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Header
          Container(
            color: const Color(0xFF6F675E),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 20,
              left: 16,
              right: 16,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                      pageBuilder: (c, a, s) => const HomePage(),
                      transitionsBuilder: (c, anim, s, child) => FadeTransition(
                        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
                        child: child,
                      ),
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  ),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/fleche gauche.svg',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Réunion',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Consultez mes rendez-vous',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Summary card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF6F675E), Color(0x996F675E)],
                        stops: [0.02, 0.96],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: const Border(
                        top: BorderSide(color: Color(0x33FFFFFF), width: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prochaines réunions',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_upcomingCount',
                              style: GoogleFonts.inter(

                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SvgPicture.asset(
                          'assets/icons/calendar.svg',
                          width: 36,
                          height: 36,
                          colorFilter: ColorFilter.mode(
                            Colors.white.withValues(alpha: 0.4),
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Toggle Liste / Calendrier
                  Stack(
                    children: [
                      Container(
                        height: 57,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6F675E),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _viewMode = 0),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      decoration: BoxDecoration(
                                        color: _viewMode == 0
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: _viewMode == 0
                                            ? const [
                                                BoxShadow(
                                                  color: Color(0x1A000000),
                                                  offset: Offset(0, 2),
                                                  blurRadius: 4,
                                                  spreadRadius: -2,
                                                ),
                                                BoxShadow(
                                                  color: Color(0x1A000000),
                                                  offset: Offset(0, 4),
                                                  blurRadius: 6,
                                                  spreadRadius: -1,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.format_list_bulleted_rounded,
                                            size: 18,
                                            color: _viewMode == 0
                                                ? const Color(0xFF2D2520)
                                                : Colors.white.withValues(alpha: 0.7),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Liste',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: _viewMode == 0
                                                  ? const Color(0xFF2D2520)
                                                  : Colors.white.withValues(alpha: 0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() => _viewMode = 1);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      decoration: BoxDecoration(
                                        color: _viewMode == 1
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: _viewMode == 1
                                            ? const [
                                                BoxShadow(
                                                  color: Color(0x1A000000),
                                                  offset: Offset(0, 2),
                                                  blurRadius: 4,
                                                  spreadRadius: -2,
                                                ),
                                                BoxShadow(
                                                  color: Color(0x1A000000),
                                                  offset: Offset(0, 4),
                                                  blurRadius: 6,
                                                  spreadRadius: -1,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icons/calendar.svg',
                                            width: 18,
                                            height: 18,
                                            colorFilter: ColorFilter.mode(
                                              _viewMode == 1
                                                  ? const Color(0xFF2D2520)
                                                  : Colors.white.withValues(alpha: 0.7),
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Calendrier',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: _viewMode == 1
                                                  ? const Color(0xFF2D2520)
                                                  : Colors.white.withValues(alpha: 0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      // Border-top
                      Positioned(
                        top: 0, left: 0, right: 0,
                        child: Container(
                          height: 0.5,
                          decoration: const BoxDecoration(
                            color: Color(0x33FFFFFF),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_viewMode == 0) ...[
                    Text(
                      'À venir',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520)),
                    ),
                    const SizedBox(height: 14),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator(color: Color(0xFF6F675E)))
                    else if (_meetings.isEmpty)
                      Center(
                        child: Text('Aucune réunion disponible',
                            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6A7282))),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: _meetings.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _buildMeetingCard(_meetings[i]),
                      ),
                  ] else
                    _isCalendarLoading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF6F675E)))
                        : _buildCalendarView(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

