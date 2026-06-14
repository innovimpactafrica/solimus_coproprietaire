import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/intervention_model.dart';
import '../../services/coowner_service.dart';
import '../home/home.dart';
import 'incident_detail.dart';
import 'signaler_incident.dart';
import '../reunions/reunions.dart';
import '../charges/mes_charges.dart';
import '../profil/profil.dart';

class MesIncidentsPage extends StatefulWidget {
  const MesIncidentsPage({super.key});

  @override
  State<MesIncidentsPage> createState() => _MesIncidentsPageState();
}

class _MesIncidentsPageState extends State<MesIncidentsPage> {
  List<InterventionModel> _interventions = [];
  int _totalIncidents = 0;
  int _enCoursCount = 0;
  bool _isLoading = true;
  String? _error;

  final TextEditingController _searchController = TextEditingController();
  String? _statusFilter;

  bool get _hasActiveFilter => _statusFilter != null;

  List<InterventionModel> get _filtered => _interventions;

  @override
  void initState() {
    super.initState();
    _loadInterventions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInterventions() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await CoOwnerService.getInterventions(
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        status: _statusFilter,
      );
      if (!mounted) return;
      setState(() {
        _interventions = data.interventions;
        _totalIncidents = data.totalIncidents;
        _enCoursCount = data.enCoursCount;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final options = <String?, String>{
            null: 'Tous',
            'PENDING': 'En attente',
            'SYNDIC_ASSIGNED': 'Syndic assigné',
            'QUOTE_SENT': 'Devis envoyé',
            'SYNDIC_VALIDATED': 'Validé',
            'STARTED': 'Démarré',
            'FINISHED': 'Terminé',
            'FINAL_VALIDATION': 'Validation finale',
            'CANCELLED': 'Annulé',
          };
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFAF9F4),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: SingleChildScrollView(
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
                    'Filtrer par statut',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2520),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...options.entries.map((entry) {
                    final isSelected = _statusFilter == entry.key;
                    return GestureDetector(
                      onTap: () {
                        setSheetState(() {});
                        setState(() => _statusFilter = entry.key);
                        Navigator.pop(ctx);
                        _loadInterventions();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6F675E)
                              : Colors.white,
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
                            Text(
                              entry.value,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF2D2520),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr);
      const months = ['', 'jan.', 'fév.', 'mars', 'avr.', 'mai', 'juin',
        'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
      return '${dt.day} ${months[dt.month]} ${dt.year} - ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) { return dateStr; }
  }

  _TagType _statusTagType(String status) {
    switch (status.toUpperCase()) {
      case 'FINISHED': case 'FINAL_VALIDATION': return _TagType.statusDone;
      case 'STARTED': case 'SYNDIC_ASSIGNED': case 'QUOTE_SENT': case 'SYNDIC_VALIDATED': return _TagType.statusInProgress;
      case 'CANCELLED': return _TagType.statusTaken;
      default: return _TagType.statusInProgress;
    }
  }

  String _statusLabel(String status, String? label) {
    if (label != null && label.isNotEmpty) return label;
    switch (status.toUpperCase()) {
      case 'PENDING':           return 'En attente';
      case 'SYNDIC_ASSIGNED':   return 'Syndic assigné';
      case 'QUOTE_SENT':        return 'Devis envoyé';
      case 'SYNDIC_VALIDATED':  return 'Validé';
      case 'STARTED':           return 'Démarré';
      case 'FINISHED':          return 'Terminé';
      case 'FINAL_VALIDATION':  return 'Validation finale';
      case 'CANCELLED':         return 'Annulé';
      default: return status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'FINISHED': case 'FINAL_VALIDATION': return const Color(0xFF00A63E);
      case 'STARTED': return const Color(0xFF2B7FFF);
      case 'SYNDIC_ASSIGNED': case 'QUOTE_SENT': case 'SYNDIC_VALIDATED': return const Color(0xFF9B59B6);
      case 'CANCELLED': return const Color(0xFF6A7282);
      default: return const Color(0xFFE17100);
    }
  }

  int get _enCoursDisplay => _enCoursCount;

  _TagType _urgencyTagType(String? urgency) {
    switch ((urgency ?? '').toUpperCase()) {
      case 'HAUTE': case 'HIGH': case 'CRITIQUE': return _TagType.priorityHigh;
      case 'MOYENNE': case 'MEDIUM': return _TagType.priorityMedium;
      default: return _TagType.category;
    }
  }

  Widget _buildNavItem(
    BuildContext context,
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

  Widget _buildTag(_Tag tag) {
    Color textColor;
    Color bgColor;
    Color borderColor;

    switch (tag.type) {
      case _TagType.statusDone:
        textColor = const Color(0xFF00A63E);
        bgColor = const Color(0xFFEFFFF6);
        borderColor = const Color(0xFF00A63E);
      case _TagType.statusInProgress:
        textColor = const Color(0xFF2B7FFF);
        bgColor = const Color(0xFFEEF4FF);
        borderColor = const Color(0xFF2B7FFF);
      case _TagType.statusTaken:
        textColor = const Color(0xFF9B59B6);
        bgColor = const Color(0xFFF5EEFF);
        borderColor = const Color(0xFF9B59B6);
      case _TagType.priorityHigh:
        textColor = const Color(0xFFDC2626);
        bgColor = const Color(0xFFFFF0F0);
        borderColor = const Color(0xFFDC2626);
      case _TagType.priorityMedium:
        textColor = const Color(0xFFE17100);
        bgColor = const Color(0xFFFFF4E6);
        borderColor = const Color(0xFFE17100);
      case _TagType.category:
        textColor = const Color(0xFF4B5563);
        bgColor = const Color(0xFFF3F4F6);
        borderColor = const Color(0xFFD1D5DB);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
      ),
      child: Text(
        tag.label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildIncidentCard(InterventionModel incident) {
    final statusType = _statusTagType(incident.status);
    final sLabel = _statusLabel(incident.status, incident.statusLabel);
    final tags = <_Tag>[
      _Tag(sLabel, statusType),
      if (incident.urgencyLabel != null && incident.urgencyLabel!.isNotEmpty)
        _Tag(incident.urgencyLabel!, _urgencyTagType(incident.urgencyLevel)),
      if (incident.specialtyName != null && incident.specialtyName!.isNotEmpty)
        _Tag(incident.specialtyName!, _TagType.category),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _statusColor(incident.status),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.build_outlined, color: Colors.white, size: 26),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D2520),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      incident.location,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6A7282),
                      ),
                    ),
                    Text(
                      _formatDate(incident.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6A7282),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags.map(_buildTag).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F4),
      floatingActionButton: GestureDetector(
        onTap: () => Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (c, a, s) => const SignalerIncidentPage(),
            transitionsBuilder: (c, anim, s, child) => FadeTransition(
              opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        ),
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
            _buildNavItem(
              context,
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
              context,
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
              context,
              'assets/icons/incident.svg',
              'Incidents',
              active: true,
            ),
            _buildNavItem(
              context,
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
              context,
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
                      'Incidents',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Consultez et créez un incidents',
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFF6F675E),
                          Color(0x996F675E),
                        ],
                        stops: [0.0209, 0.9558],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: const Border(
                        top: BorderSide(
                          color: Color(0x33FFFFFF),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total incidents',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_totalIncidents',
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'En cours',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_enCoursDisplay',
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        SvgPicture.asset(
                          'assets/icons/Search.svg',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) {
                            setState(() {});
                            Future.delayed(const Duration(milliseconds: 500), _loadInterventions);
                          },
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF2D2520),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Rechercher',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF9CA3AF),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 24,
                          color: const Color(0xFFE5E7EB),
                        ),
                        const SizedBox(width: 14),
                        GestureDetector(
                          onTap: _showFilterSheet,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/Filter.svg',
                                width: 22,
                                height: 22,
                              ),
                              if (_hasActiveFilter)
                                Positioned(
                                  top: -2,
                                  right: -2,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF6F675E),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Liste des incidents',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2520),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: Color(0xFF6F675E)))
                  else if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Erreur de chargement', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFDC2626))),
                          const SizedBox(height: 6),
                          Text(_error!, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6A7282))),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _loadInterventions,
                            child: Text('Réessayer', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF6F675E))),
                          ),
                        ],
                      ),
                    )
                  else if (_filtered.isEmpty)
                    Center(child: Text('Aucun incident disponible', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6A7282))))
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        final incident = _filtered[i];
                        return GestureDetector(
                          onTap: () => Navigator.of(ctx).push(
                            PageRouteBuilder(
                              pageBuilder: (c, a, s) => IncidentDetailPage(interventionId: incident.id),
                              transitionsBuilder: (c, anim, s, child) => FadeTransition(
                                opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
                                child: child,
                              ),
                              transitionDuration: const Duration(milliseconds: 300),
                            ),
                          ),
                          child: _buildIncidentCard(incident),
                        );
                      },
                    ),
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

enum _TagType {
  statusDone,
  statusInProgress,
  statusTaken,
  priorityHigh,
  priorityMedium,
  category,
}

class _Tag {
  final String label;
  final _TagType type;
  const _Tag(this.label, this.type);
}

