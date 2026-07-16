import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/document_model.dart';
import '../../services/coowner_service.dart';

class MesDocumentsPage extends StatefulWidget {
  const MesDocumentsPage({super.key});

  @override
  State<MesDocumentsPage> createState() => _MesDocumentsPageState();
}

class _MesDocumentsPageState extends State<MesDocumentsPage> {
  List<DocumentModel> _documents = [];
  int _totalElements = 0;
  bool _isLoading = true;
  final Set<int> _downloading = {};

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String? _typeFilter;

  bool get _hasActiveFilter => _typeFilter != null;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDocuments() async {
    try {
      final q = _searchController.text.trim();
      final result = await CoOwnerService.getDocuments(
        search: q.isEmpty ? null : q,
        documentType: _typeFilter,
      );
      if (!mounted) return;
      setState(() {
        _documents = result.content;
        _totalElements = result.totalElements;
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

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _loadDocuments);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final options = <String?, String>{
            null: 'Tous types',
            'FACTURE': 'Facture',
            'PV_AG': "PV d'AG",
            'RAPPORT': 'Rapport',
            'CONTRAT': 'Contrat',
          };
          return Container(
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
                  'Filtrer par type',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2520),
                  ),
                ),
                const SizedBox(height: 12),
                ...options.entries.map((entry) {
                  final isSelected = _typeFilter == entry.key;
                  return GestureDetector(
                    onTap: () {
                      setSheetState(() {});
                      setState(() => _typeFilter = entry.key);
                      Navigator.pop(ctx);
                      _loadDocuments();
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
          );
        },
      ),
    );
  }

  Future<void> _downloadDocument(DocumentModel doc) async {
    if (doc.source == null || doc.sourceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informations du document manquantes')),
      );
      return;
    }

    setState(() => _downloading.add(doc.id));

    try {
      final downloadUrl = await CoOwnerService.getDocumentDownloadUrl(
        source: doc.source!,
        sourceId: doc.sourceId!,
        fileName: doc.fileName,
      );

      if (downloadUrl.isEmpty) throw Exception('URL de téléchargement invalide');

      // L'URL pré-signée est déjà authentifiée, pas besoin du token Bearer
      final response = await http.get(Uri.parse(downloadUrl));

      if (response.statusCode != 200) {
        throw Exception('Erreur HTTP ${response.statusCode}');
      }

      final dir = await getTemporaryDirectory();
      final safeName = doc.fileName.replaceAll(RegExp(r'[^\w\-.]'), '_');
      final file = File('${dir.path}/$safeName');
      await file.writeAsBytes(response.bodyBytes);

      if (!mounted) return;
      setState(() => _downloading.remove(doc.id));

      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'ouvrir le fichier : ${result.message}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _downloading.remove(doc.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('\u00c9chec du t\u00e9l\u00e9chargement : ${e.toString().replaceAll('Exception: ', '')}')),
      );
    }
  }

  String _formatTag(DocumentModel doc) {
    if (doc.source != null) return doc.source!;
    if (doc.documentType != null) return doc.documentType!;
    return 'Document';
  }

  String _formatDate(DocumentModel doc) {
    if (doc.date == null) return '';
    try {
      final dt = DateTime.parse(doc.date!);
      const months = [
        'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
        'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return doc.date!;
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mes documents',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                'Consultez mes documents',
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
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
              onChanged: _onSearchChanged,
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
                  colorFilter: const ColorFilter.mode(Color(0xFF6F675E), BlendMode.srcIn),
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
    );
  }

  Widget _buildDocumentCard(BuildContext context, DocumentModel doc) {
    return GestureDetector(
      onTap: _downloading.contains(doc.id) ? null : () => _downloadDocument(doc),
      behavior: HitTestBehavior.opaque,
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/file1.svg',
                  width: 22,
                  height: 22,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.fileName,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2520),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        _formatDate(doc),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6A7282),
                        ),
                      ),
                      if (doc.fileSize != null) ...[
                        Text(
                          '  ·  ',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        Text(
                          doc.fileSize!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6A7282),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatTag(doc),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _downloading.contains(doc.id) ? null : () => _downloadDocument(doc),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF6F675E),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _downloading.contains(doc.id)
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : SvgPicture.asset(
                          'assets/icons/download2.svg',
                          width: 18,
                          height: 18,
                        ),
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
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F4),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6F675E),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildSearchBar(),
                        const SizedBox(height: 10),
                        Text(
                          '$_totalElements documents',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6F675E),
                          ),
                        ),
                        const SizedBox(height: 15),
                        if (_documents.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Text(
                                'Aucun document disponible',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF6A7282),
                                ),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: _documents.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (ctx, i) =>
                                _buildDocumentCard(ctx, _documents[i]),
                          ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
