import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/intervention_model.dart';
import '../../services/coowner_service.dart';
import 'signalement_detail.dart';
import 'nouveau_signalement.dart';

class MesSignalementsPage extends StatefulWidget {
  const MesSignalementsPage({super.key});

  @override
  State<MesSignalementsPage> createState() => _MesSignalementsPageState();
}

class _MesSignalementsPageState extends State<MesSignalementsPage> {
  List<SignalementModel> _items = [];
  int _total = 0;
  bool _isLoading = true;
  String? _error;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await CoOwnerService.getSignalements(
        search: _search.text.trim().isEmpty ? null : _search.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _items = data.items;
        _total = data.totalElements;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  String _formatDate(String? raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw);
      const months = ['', 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
        'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) { return raw; }
  }

  String _statusLabel(SignalementModel item) {
    switch (item.status.toUpperCase()) {
      case 'PENDING':            return 'En attente';
      case 'IN_PROGRESS':        return 'En cours';
      case 'RESOLVED':           return 'Résolu';
      case 'CONVERTED_TO_WORK':  return 'Converti en travaux';
      default: return item.status;
    }
  }

  Color _statusTextColor(String status) {
    switch (status.toUpperCase()) {
      case 'RESOLVED':          return const Color(0xFF00A63E);
      case 'CONVERTED_TO_WORK': return const Color(0xFF6A7282);
      default:                  return const Color(0xFFE17100);
    }
  }

  Color _statusBgColor(String status) {
    switch (status.toUpperCase()) {
      case 'RESOLVED':          return const Color(0xFFEFFFF6);
      case 'CONVERTED_TO_WORK': return const Color(0xFFF3F4F6);
      default:                  return const Color(0xFFFFF9E6);
    }
  }

  Color _urgencyTextColor(String? urgency) {
    switch ((urgency ?? '').toUpperCase()) {
      case 'HAUTE': case 'HIGH': case 'CRITIQUE': return const Color(0xFFDC2626);
      case 'MOYENNE': case 'MEDIUM':              return const Color(0xFFE17100);
      case 'FAIBLE': case 'LOW':                  return const Color(0xFF00A63E);
      default:                                    return const Color(0xFF6A7282);
    }
  }

  Color _urgencyBgColor(String? urgency) {
    switch ((urgency ?? '').toUpperCase()) {
      case 'HAUTE': case 'HIGH': case 'CRITIQUE': return const Color(0xFFFFF0F0);
      case 'MOYENNE': case 'MEDIUM':              return const Color(0xFFFFF4E6);
      case 'FAIBLE': case 'LOW':                  return const Color(0xFFEFFFF6);
      default:                                    return const Color(0xFFF3F4F6);
    }
  }

  Widget _buildCard(SignalementModel item) {
    final statusLabel = _statusLabel(item);
    final statusTxtColor = _statusTextColor(item.status);
    final statusBg = _statusBgColor(item.status);
    final urgencyTxtColor = _urgencyTextColor(item.urgencyLevel);
    final urgencyBg = _urgencyBgColor(item.urgencyLevel);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status badge top-right
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: statusTxtColor),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Title
                Text(
                  item.title,
                  style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: const Color(0xFF1C1C1E)),
                ),
                const SizedBox(height: 10),
                // Location
                Row(children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF6A7282)),
                  const SizedBox(width: 6),
                  Text(
                    item.positionLabel ?? '—',
                    style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6A7282)),
                  ),
                ]),
                const SizedBox(height: 6),
                // Date
                Row(children: [
                  const Icon(Icons.calendar_today_outlined, size: 15, color: Color(0xFF6A7282)),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(item.createdAt),
                    style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6A7282)),
                  ),
                ]),
                if (item.urgencyLevel != null && item.urgencyLevel!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: urgencyBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.urgencyLevel!,
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: urgencyTxtColor),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Divider + bouton
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          GestureDetector(
            onTap: () => Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (c, a, s) => SignalementDetailPage(interventionId: item.id),
              transitionsBuilder: (c, anim, s, child) => FadeTransition(
                opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut), child: child),
              transitionDuration: const Duration(milliseconds: 300),
            )),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFFF9F9F7),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Center(
                child: Text(
                  'VOIR DÉTAIL',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520), letterSpacing: 0.5),
                ),
              ),
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
      floatingActionButton: GestureDetector(
        onTap: () => Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (c, a, s) => const NouveauSignalementPage(),
          transitionsBuilder: (c, anim, s, child) => FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut), child: child),
          transitionDuration: const Duration(milliseconds: 300),
        )).then((_) => _load()),
        child: Container(
          width: 56, height: 56,
          decoration: const BoxDecoration(color: Color(0xFF6F675E), shape: BoxShape.circle),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      body: Column(
        children: [
          // Header
          Container(
            color: const Color(0xFF6F675E),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 20, left: 16, right: 16,
            ),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), shape: BoxShape.circle),
                  child: Center(child: SvgPicture.asset('assets/icons/fleche gauche.svg', width: 20, height: 20)),
                ),
              ),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Mes signalement', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('Consultez mes signalement', style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.75))),
              ]),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(children: [
                      const SizedBox(width: 16),
                      const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _search,
                          onChanged: (_) => Future.delayed(const Duration(milliseconds: 500), _load),
                          style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF2D2520)),
                          decoration: InputDecoration(
                            hintText: 'Rechercher',
                            hintStyle: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF9CA3AF)),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      Container(width: 1, height: 24, color: const Color(0xFFE5E7EB)),
                      const SizedBox(width: 14),
                      SvgPicture.asset(
                        'assets/icons/Filter.svg',
                        width: 22, height: 22,
                        colorFilter: const ColorFilter.mode(Color(0xFF6F675E), BlendMode.srcIn),
                      ),
                      const SizedBox(width: 16),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  if (!_isLoading && _error == null)
                    Text(
                      '$_total document${_total > 1 ? 's' : ''}',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFE17100)),
                    ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: Color(0xFF6F675E)))
                  else if (_error != null)
                    Center(child: Column(children: [
                      Text('Erreur de chargement', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6A7282))),
                      const SizedBox(height: 8),
                      GestureDetector(onTap: _load, child: Text('Réessayer', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF6F675E)))),
                    ]))
                  else if (_items.isEmpty)
                    Center(child: Text('Aucun signalement', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6A7282))))
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (_, i) => _buildCard(_items[i]),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
