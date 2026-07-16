import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/intervention_model.dart';
import '../../services/coowner_service.dart';
import 'cloture_success.dart';
import 'devis_detail.dart';

class IncidentDetailPage extends StatefulWidget {
  final int interventionId;
  const IncidentDetailPage({super.key, required this.interventionId});

  @override
  State<IncidentDetailPage> createState() => _IncidentDetailPageState();
}

class _IncidentDetailPageState extends State<IncidentDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _selectedDevis;
  InterventionDetailModel? _detail;
  List<QuoteModel> _quotes = [];
  bool _isLoading = true;
  bool _syndicManagesQuotes = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAll();
  }

  Future<void> _loadAll() async {
    try {
      _detail = await CoOwnerService.getInterventionDetail(widget.interventionId);
      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), duration: const Duration(seconds: 6)),
      );
      return;
    }
    // Charger les devis séparément — une 403 signifie que le syndic gère les devis
    try {
      final quotes = await CoOwnerService.getQuotes(widget.interventionId);
      if (!mounted) return;
      setState(() => _quotes = quotes);
    } catch (e) {
      final msg = e.toString();
      if (!msg.contains('403')) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), duration: const Duration(seconds: 6)),
        );
      }
      // 403 = devis gérés par le syndic, on ignore silencieusement
      if (msg.contains('403')) setState(() => _syndicManagesQuotes = true);
    }
  }

  List<_TimelineStep> get _timeline {
    if (_detail == null || _detail!.timeline.isEmpty) return const [];
    return _detail!.timeline.map((t) => _TimelineStep(
      t.label,
      _formatDate(t.date),
      t.completed,
    )).toList();
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
      return '${dt.day} ${months[dt.month]} ${dt.year} - ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) { return dateStr; }
  }

  void _onDevisValidated() {
    _tabController.animateTo(0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildTimelineItem(_TimelineStep step, bool isLast) {
    final done = step.done;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: done ? const Color(0xFF22C55E) : const Color(0xFFE5E7EB),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: done
                      ? SvgPicture.asset(
                          'assets/icons/donew.svg',
                          width: 14,
                          height: 14,
                        )
                      : null,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 36,
                  color: done
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFE5E7EB),
                ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: done
                        ? const Color(0xFF2D2520)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
                if (step.datetime.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    step.datetime,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6A7282),
                    ),
                  ),
                ],
                if (!isLast) const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6A7282),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2520),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF6F675E)));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              SvgPicture.asset('assets/icons/calendar.svg', width: 14, height: 14),
              const SizedBox(width: 6),
              Text(
                'Signalé le ${_formatDate(_detail?.createdAt)}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF6A7282),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              SvgPicture.asset('assets/icons/adress.svg', width: 14, height: 14),
              const SizedBox(width: 6),
              Text(
                _detail?.location ?? '—',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF6A7282),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SvgPicture.asset('assets/icons/donee.svg', width: 16, height: 16),
              const SizedBox(width: 5),
              Text(
                'Terminé',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF00A63E),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Urgent',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Description card
          Container(
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
                  'Description',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2520),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _detail?.description ?? '—',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                    color: const Color(0xFF6A7282),
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(color: Color(0xFFF3F4F6), thickness: 1, height: 1),
                if (_detail?.specialtyName != null)
                  _detailRow('Catégorie', _detail!.specialtyName!),
                if (_detail?.selectedProvider != null) ...[
                  const Divider(color: Color(0xFFF3F4F6), thickness: 1, height: 1),
                  _detailRow('Prestataire', _detail!.selectedProvider!.fullName),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Photos card
          Container(
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
                  'Photos du problème',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2520),
                  ),
                ),
                const SizedBox(height: 12),
                if (_detail != null && _detail!.photoUrls.isNotEmpty)
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _detail!.photoUrls.map((url) =>
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(url,
                          width: (MediaQuery.of(context).size.width - 72) / 2,
                          height: 120, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: (MediaQuery.of(context).size.width - 72) / 2,
                            height: 120,
                            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.image_not_supported_outlined, color: Color(0xFF9CA3AF)),
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Timeline card
          Container(
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
                  "Suivi de l'incident",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2520),
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(
                  _timeline.length,
                  (i) => _buildTimelineItem(
                    _timeline[i],
                    i == _timeline.length - 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Clôturer button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (c, a, s) => const ClotureSuccessPage(),
                  transitionsBuilder: (c, anim, s, child) => FadeTransition(
                    opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
                    child: child,
                  ),
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF9A826),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: Text(
                'Clôturer',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDevisCard({
    required String logoPath,
    required String name,
    required double rating,
    required int reviews,
    required String location,
    required String price,
    required String delay,
    required String description,
    bool recommended = false,
    bool selected = false,
    VoidCallback? onTap,
    int quoteId = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: selected
            ? Border.all(color: const Color(0xFF8B7355), width: 2)
            : recommended
                ? Border.all(color: const Color(0xFF8B7355), width: 1.2)
                : Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recommended) const SizedBox(height: 8),
                // Company row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        logoPath,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2D2520),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Color(0xFFF9C20A), size: 14),
                              const SizedBox(width: 3),
                              Text(
                                '$rating ($reviews avis)',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF6A7282),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF9CA3AF)),
                              const SizedBox(width: 2),
                              Text(
                                location,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RichText(
                          textAlign: TextAlign.right,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: price.replaceAll(' FCFA', ''),
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  height: 28 / 20,
                                  letterSpacing: 0,
                                  color: const Color(0xFF8B7355),
                                ),
                              ),
                              TextSpan(
                                text: ' FCFA',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  height: 16 / 12,
                                  letterSpacing: 0,
                                  color: const Color(0xFF8B7355),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x0DF9C20A),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            delay,
                            textAlign: TextAlign.right,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              height: 15 / 10,
                              letterSpacing: 0,
                              color: const Color(0xFFF9C20A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: const Color(0xFF6A7282),
                  ),
                ),
                const SizedBox(height: 12),
                // Horizontal divider
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFF3F4F6), width: 1),
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset('assets/icons/check_badge.svg', width: 14, height: 14),
                        const SizedBox(width: 5),
                        Text(
                          'Prestataire vérifié',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 38,
                      child: recommended
                          ? ElevatedButton(
                              onPressed: () => Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (c, a, s) => DevisDetailPage(
                                    onValidated: _onDevisValidated,
                                    interventionId: widget.interventionId,
                                    quoteId: quoteId,
                                  ),
                                  transitionsBuilder: (c, anim, s, child) => FadeTransition(
                                    opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
                                    child: child,
                                  ),
                                  transitionDuration: const Duration(milliseconds: 300),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B7355),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              child: Text(
                                'Choisir ce devis',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                side: const BorderSide(color: Color(0xFF8B7355)),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              child: Text(
                                'Choisir ce devis',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF8B7355),
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
          if (recommended)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(
                  color: Color(0xFF8B7355),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Text(
                  'RECOMMANDÉ',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }

  Widget _buildDevisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Devis reçus',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2520),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Vous avez reçu ${_quotes.length} devis pour cette intervention',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6A7282),
            ),
          ),
          const SizedBox(height: 16),
          if (_syndicManagesQuotes)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Les devis de cette intervention sont gérés par le syndic.',
                  style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6A7282)),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (_quotes.isEmpty)
            Center(child: Text('Aucun devis reçu pour le moment', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6A7282))))
          else
            ...List.generate(_quotes.length, (i) {
              final q = _quotes[i];
              final formattedAmount = _formatAmount(q.totalAmount);
              return Column(
                children: [
                  if (i > 0) const SizedBox(height: 12),
                  _buildDevisCard(
                    logoPath: 'assets/images/plumbing.png',
                    name: q.displayName,
                    rating: q.providerRating,
                    reviews: q.reviewCount,
                    location: q.providerCity ?? 'Dakar, Sénégal',
                    price: '$formattedAmount FCFA',
                    delay: q.estimatedDelayLabel ?? '—',
                    description: q.additionalComments ?? '—',
                    recommended: q.bestOffer,
                    selected: _selectedDevis == i,
                    onTap: () => setState(() => _selectedDevis = i),
                    quoteId: q.id,
                  ),
                ],
              );
            }),
          const SizedBox(height: 16),
          // Info box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0x0DF9C20A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset('assets/icons/info_border.svg', width: 40, height: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comment choisir ?',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D2520),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Comparez les prix, les délais et les avis des prestataires. Une fois votre choix fait, le prestataire sera notifié et pourra commencer l\'intervention.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                          color: const Color(0xFF6A7282),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F4),
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
                  onTap: () => Navigator.of(context).pop(),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _detail?.title ?? '—',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _detail?.location ?? '—',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tab bar — séparé, fond blanc
          Container(
            height: 66.5,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF6F675E),
              indicatorWeight: 2,
              labelColor: const Color(0xFF6F675E),
              unselectedLabelColor: const Color(0xFF9CA3AF),
              labelStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              tabs: [
                Tab(
                  icon: SvgPicture.asset(
                    'assets/icons/file1.svg',
                    width: 18,
                    height: 18,
                    colorFilter: ColorFilter.mode(
                      _tabController.index == 0
                          ? const Color(0xFF6F675E)
                          : const Color(0xFF9CA3AF),
                      BlendMode.srcIn,
                    ),
                  ),
                  text: 'Détails',
                ),
                Tab(
                  icon: SvgPicture.asset(
                    'assets/icons/devis.svg',
                    width: 18,
                    height: 18,
                    colorFilter: ColorFilter.mode(
                      _tabController.index == 1
                          ? const Color(0xFF6F675E)
                          : const Color(0xFF9CA3AF),
                      BlendMode.srcIn,
                    ),
                  ),
                  text: 'Devis',
                ),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(),
                _buildDevisTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep {
  final String label;
  final String datetime;
  final bool done;
  const _TimelineStep(this.label, this.datetime, this.done);
}
