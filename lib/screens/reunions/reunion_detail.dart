import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/meeting_model.dart';
import '../../services/coowner_service.dart';

class ReunionDetailPage extends StatefulWidget {
  final int meetingId;

  const ReunionDetailPage({super.key, required this.meetingId});

  @override
  State<ReunionDetailPage> createState() => _ReunionDetailPageState();
}

class _ReunionDetailPageState extends State<ReunionDetailPage> {
  MeetingDetailModel? _detail;
  bool _isLoading = true;

  static const _monthNames = [
    '', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];
  static const _dayNames = [
    'dimanche', 'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi'
  ];

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final detail = await CoOwnerService.getMeetingDetail(widget.meetingId);
      if (!mounted) return;
      setState(() { _detail = detail; _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  String _typeLabel(MeetingDetailModel d) => d.typeLabel.isNotEmpty ? d.typeLabel : d.type;

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

  String _formatDate(MeetingDetailModel d) {
    final dt = d.dateTime;
    if (dt != null) {
      return '${_dayNames[dt.weekday % 7]} ${dt.day} ${_monthNames[dt.month]} ${dt.year}';
    }
    return d.meetingDate ?? '';
  }

  Widget _buildInfoRow(String svgPath, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          SvgPicture.asset(svgPath, width: 16, height: 16,
              colorFilter: const ColorFilter.mode(Color(0xFFF5F1EA), BlendMode.srcIn)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.9))),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendaItem(int index, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(color: const Color(0x1A6F675E), borderRadius: BorderRadius.circular(20)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
            child: Center(
              child: Text('$index',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF6A7282))),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF2D2520))),
          ),
        ],
      ),
    );
  }

  void _showDocumentViewer(BuildContext context, String docName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: MediaQuery.of(ctx).size.height * 0.9,
            decoration: const BoxDecoration(
              color: Color(0xFFFAF9F4),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4,
                    decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(docName,
                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520)),
                      textAlign: TextAlign.center),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset('assets/images/pv.jpg', width: double.infinity, fit: BoxFit.fitWidth),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Positioned(
            top: -22, right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(ctx).pop(),
              child: Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded, color: Color(0xFF2D2520), size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocument(BuildContext context, MeetingDocument doc) {
    return GestureDetector(
      onTap: () => _showDocumentViewer(context, doc.fileName),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(color: const Color(0x1A6F675E), borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: const Color(0xFF2B7FFF), borderRadius: BorderRadius.circular(10)),
              child: Center(
                child: SvgPicture.asset('assets/icons/file.svg', width: 20, height: 20,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doc.fileName,
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF2D2520)),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(doc.sizeLabel,
                      style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF))),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 36, height: 36,
              decoration: const BoxDecoration(color: Color(0xFF2D2520), shape: BoxShape.circle),
              child: Center(
                child: SvgPicture.asset('assets/icons/download2.svg', width: 20, height: 20,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = _detail;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F4),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF6F675E),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 20, left: 16, right: 16,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), shape: BoxShape.circle),
                    child: Center(child: SvgPicture.asset('assets/icons/fleche gauche.svg', width: 20, height: 20)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d?.title ?? '—',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      Text(d?.location ?? '',
                          style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.75))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6F675E)))
                : d == null
                    ? Center(child: Text('Données indisponibles',
                        style: GoogleFonts.inter(color: const Color(0xFF6A7282))))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Info card
                            Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [Color(0xFF6F675E), Color(0x996F675E)],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: _typeBg(d.type),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: _typeColor(d.type).withValues(alpha: 0.4)),
                                        ),
                                        child: Text(_typeLabel(d),
                                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _typeColor(d.type))),
                                      ),
                                      if (d.meetingDate != null && d.meetingDate!.isNotEmpty)
                                        _buildInfoRow('assets/icons/1.svg', _formatDate(d)),
                                      if (d.meetingStartTime != null && d.meetingStartTime!.isNotEmpty)
                                        _buildInfoRow('assets/icons/2.svg',
                                            d.meetingEndTime != null && d.meetingEndTime!.isNotEmpty
                                                ? '${d.meetingStartTime} - ${d.meetingEndTime}'
                                                : d.meetingStartTime!),
                                      if (d.location != null && d.location!.isNotEmpty)
                                        _buildInfoRow('assets/icons/3.svg', d.location!),
                                      if (d.organizerName != null && d.organizerName!.isNotEmpty)
                                        _buildInfoRow('assets/icons/4.svg', d.organizerName!),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 0, left: 0, right: 0,
                                  child: Container(
                                    height: 0.5,
                                    decoration: const BoxDecoration(
                                      color: Color(0x33FFFFFF),
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            if (d.description != null && d.description!.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              Text('À propos', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520))),
                              const SizedBox(height: 10),
                              Text(d.description!,
                                  style: GoogleFonts.inter(fontSize: 13, height: 1.6, color: const Color(0xFF8B7355))),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                SvgPicture.asset('assets/icons/4.svg', width: 16, height: 16),
                                const SizedBox(width: 8),
                                Text('${d.participantCount} participants attendus',
                                    style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF8B7355))),
                              ],
                            ),

                            if (d.agendaItems.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Ordre du jour',
                                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520))),
                                    const SizedBox(height: 16),
                                    ...d.agendaItems.map((item) => _buildAgendaItem(item.orderIndex, item.title)),
                                  ],
                                ),
                              ),
                            ],

                            if (d.documents.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Documents joints',
                                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520))),
                                        Text('${d.documentsTotalCount} fichier(s)',
                                            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6A7282))),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    ...d.documents.map((doc) => _buildDocument(context, doc)),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
