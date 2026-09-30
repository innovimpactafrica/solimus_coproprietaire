import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import '../../models/meeting_model.dart';
import '../../services/auth_storage.dart';
import '../../services/coowner_service.dart';
import '../documents/document_viewer.dart';
import '../../services/user_session.dart';

class ReunionDetailPage extends StatefulWidget {
  final int meetingId;

  const ReunionDetailPage({super.key, required this.meetingId});

  @override
  State<ReunionDetailPage> createState() => _ReunionDetailPageState();
}

class _ReunionDetailPageState extends State<ReunionDetailPage> {
  MeetingDetailModel? _detail;
  bool _isLoading = true;
  final Set<String> _downloading = {};
  String? _attendanceStatus; // null, 'CONFIRMED', 'PROXY'
  String? _proxyName;
  bool _submittingAttendance = false;

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
    _loadSavedAttendance();
    _loadDetail();
  }

  void _loadSavedAttendance() async {
    await UserSession.instance.loadMeetingAttendances([widget.meetingId]);
    final saved = UserSession.instance.getMeetingAttendance(widget.meetingId);
    if (saved != null && mounted) {
      setState(() {
        if (saved == 'CONFIRMED') {
          _attendanceStatus = 'CONFIRMED';
        } else if (saved.startsWith('PROXY:')) {
          _attendanceStatus = 'PROXY';
          _proxyName = saved.substring(6);
        }
      });
    }
  }

  void _showProcurationModal() {
    final nameController = TextEditingController(text: _proxyName ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
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
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Donner une procuration',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520)),
              ),
              const SizedBox(height: 4),
              Text(
                'Désignez votre mandataire pour cette réunion',
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6A7282)),
              ),
              const SizedBox(height: 20),
              Text(
                'Nom et prénom du mandataire',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF2D2520)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Ex: Amadou Diallo',
                  hintStyle: GoogleFonts.inter(color: const Color(0x66202221)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD6D2C9))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD6D2C9))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6F675E), width: 1.5)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        side: const BorderSide(color: Color(0xFFD6D2C9)),
                      ),
                      child: Text('Annuler', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF6A7282))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submittingAttendance
                          ? null
                          : () async {
                              final val = nameController.text.trim();
                              if (val.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Veuillez saisir le nom du mandataire')),
                                );
                                return;
                              }
                              Navigator.of(ctx).pop();
                              setState(() => _submittingAttendance = true);
                              try {
                                await CoOwnerService.giveMeetingProxy(widget.meetingId, val);
                                if (!mounted) return;
                                setState(() {
                                  _attendanceStatus = 'PROXY';
                                  _proxyName = val;
                                  _submittingAttendance = false;
                                });
                                UserSession.instance.setMeetingAttendance(widget.meetingId, 'PROXY:$val');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Procuration enregistrée pour $val avec succès'),
                                    backgroundColor: const Color(0xFF00A63E),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              } catch (e) {
                                if (!mounted) return;
                                setState(() => _submittingAttendance = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString().replaceFirst('Exception: ', '')),
                                    backgroundColor: Colors.red.shade700,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6F675E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      child: Text('Valider', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceSection() {
    final isConfirmed = _attendanceStatus == 'CONFIRMED';
    final isProxy     = _attendanceStatus == 'PROXY';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6F675E), Color(0xFF3D3830)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(child: Icon(Icons.how_to_vote_rounded, color: Colors.white, size: 17)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Votre réponse',
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF2D2520))),
                    Text('Indiquez comment vous participez',
                        style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF8B7355))),
                  ],
                ),
              ],
            ),
          ),

          // ── Carte 1 : Confirmer présence ─────────────────────────────────
          if (!isProxy) ...[
            GestureDetector(
              onTap: _submittingAttendance
                  ? null
                  : () async {
                      setState(() => _submittingAttendance = true);
                      try {
                        await CoOwnerService.markMeetingPresent(widget.meetingId);
                        if (!mounted) return;
                        setState(() {
                          _attendanceStatus = 'CONFIRMED';
                          _proxyName = null;
                          _submittingAttendance = false;
                        });
                        UserSession.instance.setMeetingAttendance(widget.meetingId, 'CONFIRMED');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text('Présence enregistrée avec succès',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                            ]),
                            backgroundColor: const Color(0xFF059669),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        setState(() => _submittingAttendance = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString().replaceFirst('Exception: ', '')),
                            backgroundColor: Colors.red.shade700,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                decoration: BoxDecoration(
                  gradient: isConfirmed
                      ? const LinearGradient(
                          colors: [Color(0xFF059669), Color(0xFF047857)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        )
                      : null,
                  color: isConfirmed ? null : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isConfirmed ? Colors.transparent : const Color(0xFFE6E0D8),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isConfirmed
                          ? const Color(0xFF059669).withValues(alpha: 0.35)
                          : const Color(0x0A000000),
                      blurRadius: isConfirmed ? 24 : 12,
                      offset: const Offset(0, 6),
                      spreadRadius: isConfirmed ? 2 : 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icône
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: isConfirmed
                            ? Colors.white.withValues(alpha: 0.2)
                            : const Color(0xFFF0FAF5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Icon(
                          isConfirmed ? Icons.check_circle_rounded : Icons.how_to_reg_outlined,
                          color: isConfirmed ? Colors.white : const Color(0xFF059669),
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Texte
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isConfirmed ? 'Présence confirmée ✓' : 'Je serai présent(e)',
                            style: GoogleFonts.inter(
                              fontSize: 15, fontWeight: FontWeight.w800,
                              color: isConfirmed ? Colors.white : const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            isConfirmed
                                ? 'Votre participation est enregistrée'
                                : 'Confirmer votre présence physique',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isConfirmed
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : const Color(0xFF8B7355),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Indicateur droite
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isConfirmed
                            ? Colors.white.withValues(alpha: 0.25)
                            : const Color(0xFFF0FAF5),
                        border: Border.all(
                          color: isConfirmed ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF059669).withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        isConfirmed ? Icons.check_rounded : Icons.arrow_forward_ios_rounded,
                        color: isConfirmed ? Colors.white : const Color(0xFF059669),
                        size: isConfirmed ? 16 : 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (!isConfirmed && !isProxy) const SizedBox(height: 12),

          // ── Carte 2 : Procuration ────────────────────────────────────────
          if (!isConfirmed) ...[
            GestureDetector(
              onTap: _showProcurationModal,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                decoration: BoxDecoration(
                  gradient: isProxy
                      ? const LinearGradient(
                          colors: [Color(0xFFD97706), Color(0xFFB45309)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        )
                      : null,
                  color: isProxy ? null : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isProxy ? Colors.transparent : const Color(0xFFE6E0D8),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isProxy
                          ? const Color(0xFFD97706).withValues(alpha: 0.35)
                          : const Color(0x0A000000),
                      blurRadius: isProxy ? 24 : 12,
                      offset: const Offset(0, 6),
                      spreadRadius: isProxy ? 2 : 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icône
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: isProxy
                            ? Colors.white.withValues(alpha: 0.2)
                            : const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Icon(
                          isProxy ? Icons.assignment_ind_rounded : Icons.assignment_ind_outlined,
                          color: isProxy ? Colors.white : const Color(0xFFD97706),
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Texte
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isProxy ? 'Procuration donnée' : 'Donner procuration',
                            style: GoogleFonts.inter(
                              fontSize: 15, fontWeight: FontWeight.w800,
                              color: isProxy ? Colors.white : const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            isProxy && _proxyName != null
                                ? 'Mandataire : $_proxyName'
                                : 'Désigner quelqu\'un à votre place',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isProxy
                                  ? Colors.white.withValues(alpha: 0.85)
                                  : const Color(0xFF8B7355),
                              fontWeight: isProxy ? FontWeight.w600 : FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Indicateur droite
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isProxy
                            ? Colors.white.withValues(alpha: 0.25)
                            : const Color(0xFFFFF7ED),
                        border: Border.all(
                          color: isProxy ? Colors.white.withValues(alpha: 0.5) : const Color(0xFFD97706).withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        isProxy ? Icons.edit_rounded : Icons.arrow_forward_ios_rounded,
                        color: isProxy ? Colors.white : const Color(0xFFD97706),
                        size: isProxy ? 14 : 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (isConfirmed || isProxy) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _attendanceStatus = null;
                    _proxyName = null;
                  });
                  UserSession.instance.setMeetingAttendance(widget.meetingId, '');
                },
                icon: const Icon(Icons.swap_horiz_rounded, size: 14, color: Color(0xFF8B7355)),
                label: Text(
                  'Modifier mon choix',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF8B7355)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
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

  void _openViewer(MeetingDocument doc) {
    if (doc.fileUrl == null || doc.fileUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL du document manquante')),
      );
      return;
    }
    final rawUrl = doc.fileUrl!;
    final fullUrl = rawUrl.startsWith('http') ? rawUrl : 'https://api.solimus.sn/uploads/$rawUrl';
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => DocumentViewerPage(
        fileName: doc.fileName,
        fileUrl: fullUrl,
      ),
    ));
  }

  Future<void> _downloadDocument(MeetingDocument doc) async {
    final rawUrl = doc.fileUrl;
    if (rawUrl == null || rawUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL du document manquante')),
      );
      return;
    }

    final downloadUrl = rawUrl.startsWith('http') ? rawUrl : 'https://api.solimus.sn/uploads/$rawUrl';
    setState(() => _downloading.add(doc.fileName));

    try {
      final token = await AuthStorage.getToken();
      final response = await http.get(
        Uri.parse(downloadUrl),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur HTTP ${response.statusCode}');
      }

      final safeName = doc.fileName.replaceAll(RegExp(r'[^\w\-.]'), '_');
      final filePath = '${Directory.systemTemp.path}/$safeName';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      if (!mounted) return;
      setState(() => _downloading.remove(doc.fileName));

      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'ouvrir le fichier : ${result.message}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _downloading.remove(doc.fileName));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec du téléchargement : ${e.toString().replaceAll('Exception: ', '')}')),
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

  Widget _buildDocument(BuildContext context, MeetingDocument doc) {
    final isDownloading = _downloading.contains(doc.fileName);
    return GestureDetector(
      onTap: () => _openViewer(doc),
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
                  Text(doc.sizeLabel.isNotEmpty ? doc.sizeLabel : (doc.documentTypeLabel ?? 'Document'),
                      style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF))),
                ],
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: isDownloading ? null : () => _downloadDocument(doc),
              child: Container(
                width: 36, height: 36,
                decoration: const BoxDecoration(color: Color(0xFF2D2520), shape: BoxShape.circle),
                child: Center(
                  child: isDownloading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : SvgPicture.asset('assets/icons/download2.svg', width: 18, height: 18,
                          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                ),
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

                            _buildAttendanceSection(),

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
