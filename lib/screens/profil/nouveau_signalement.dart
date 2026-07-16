import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/intervention_model.dart';
import '../../models/residence_model.dart';
import '../../services/coowner_service.dart';


class NouveauSignalementPage extends StatefulWidget {
  const NouveauSignalementPage({super.key});

  @override
  State<NouveauSignalementPage> createState() => _NouveauSignalementPageState();
}

class _NouveauSignalementPageState extends State<NouveauSignalementPage> {
  // Data
  List<ResidenceModel> _residences = [];
  List<CommonFacilityModel> _facilities = [];
  ResidenceModel? _selectedResidence;
  CommonFacilityModel? _selectedFacility;
  bool _loadingResidences = true;
  bool _loadingFacilities = false;

  int _urgency = 1; // 0=Faible, 1=Moyen, 2=Urgent
  bool _isSubmitting = false;

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final List<File> _photos = [];
  final _picker = ImagePicker();

  static const _urgencyLabels = ['Faible', 'Moyen', 'Urgent'];
  static const _urgencyLevels = ['FAIBLE', 'MOYEN', 'URGENT'];
  static const _urgencyColors = [Color(0xFF2B7FFF), Color(0xFFE17100), Color(0xFFDC2626)];

  @override
  void initState() {
    super.initState();
    _loadResidences();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadResidences() async {
    try {
      final data = await CoOwnerService.getInterventionResidences();
      if (!mounted) return;
      setState(() {
        _residences = data;
        _loadingResidences = false;
        if (data.length == 1) {
          _selectedResidence = data.first;
          _loadFacilities(data.first.id);
        }
      });
    } catch (_) {
      if (mounted) setState(() => _loadingResidences = false);
    }
  }

  Future<void> _loadFacilities(int residenceId) async {
    setState(() { _loadingFacilities = true; _selectedFacility = null; _facilities = []; });
    try {
      final data = await CoOwnerService.getCommonFacilities(residenceId);
      if (!mounted) return;
      setState(() { _facilities = data; _loadingFacilities = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingFacilities = false);
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFAF9F4),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Ajouter une photo', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2D2520))),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(width: 44, height: 44,
                decoration: BoxDecoration(color: const Color(0xFFF9C20A).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.camera_alt_rounded, color: Color(0xFFF9A826))),
              title: Text('Prendre une photo', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xFF2D2520))),
              onTap: () async {
                Navigator.pop(context);
                final p = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                if (p != null && mounted) setState(() => _photos.add(File(p.path)));
              },
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(width: 44, height: 44,
                decoration: BoxDecoration(color: const Color(0xFF2B7FFF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.photo_library_rounded, color: Color(0xFF2B7FFF))),
              title: Text('Choisir dans la galerie', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xFF2D2520))),
              onTap: () async {
                Navigator.pop(context);
                final p = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                if (p != null && mounted) setState(() => _photos.add(File(p.path)));
              },
            ),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_selectedResidence == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez choisir une résidence')));
      return;
    }
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez saisir un titre')));
      return;
    }
    final desc = _descController.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez décrire le problème')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await CoOwnerService.createSignalement(
        title: title,
        description: desc,
        residenceId: _selectedResidence!.id,
        commonFacilityId: _selectedFacility?.id,
        locationType: 'PARTIE_COMMUNE',
        urgencyLevel: _urgencyLevels[_urgency],
        photos: _photos.map((f) => f.path).toList(),
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (c, a, s) => const _SignalementSuccessPage(),
        transitionsBuilder: (c, anim, s, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut), child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), duration: const Duration(seconds: 8)),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(t, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700,
        color: const Color(0xFF9CA3AF), letterSpacing: 1.2)),
  );

  Widget _fieldLabel(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF2D2520))),
  );

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 2))],
    ),
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4EF),
      body: Column(children: [
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
              Text('Nouveau signalement', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
              Text('Décrivez le problème rencontré', style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.75))),
            ]),
          ]),
        ),
        // Body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // INFORMATIONS GÉNÉRALES
              _sectionTitle('INFORMATIONS GÉNÉRALES'),
              _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Résidence
                _fieldLabel('Résidence'),
                _loadingResidences
                    ? const Center(child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: CircularProgressIndicator(color: Color(0xFF6F675E), strokeWidth: 2)))
                    : _residences.length == 1
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F4EF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(children: [
                              const Icon(Icons.domain_rounded, size: 20, color: Color(0xFF6F675E)),
                              const SizedBox(width: 10),
                              Text(_selectedResidence?.name ?? '', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF2D2520))),
                            ]),
                          )
                        : DropdownButtonFormField<ResidenceModel>(
                            initialValue: _selectedResidence,
                            hint: Text('Choisir une résidence', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF9CA3AF))),
                            items: _residences.map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(r.name, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF2D2520))),
                            )).toList(),
                            onChanged: (v) {
                              setState(() { _selectedResidence = v; });
                              if (v != null) _loadFacilities(v.id);
                            },
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              filled: true, fillColor: const Color(0xFFF5F4EF),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            dropdownColor: const Color(0xFFFAF9F4),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF6A7282)),
                            isExpanded: true,
                          ),
                const SizedBox(height: 16),
                // Position
                _fieldLabel('Position du signalement'),
                DropdownButtonFormField<CommonFacilityModel>(
                  initialValue: _selectedFacility,
                  hint: Text(
                    _loadingFacilities ? 'Chargement...' : 'Sélectionner un lieu',
                    style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF9CA3AF)),
                  ),
                  items: _facilities.map((f) => DropdownMenuItem(
                    value: f,
                    child: Text(f.label, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF2D2520))),
                  )).toList(),
                  onChanged: _loadingFacilities ? null : (v) => setState(() => _selectedFacility = v),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    filled: true, fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6F675E))),
                  ),
                  dropdownColor: const Color(0xFFFAF9F4),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF6A7282)),
                  isExpanded: true,
                ),
                const SizedBox(height: 16),
                // Titre
                _fieldLabel('Titre du signalement'),
                TextField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF2D2520)),
                  decoration: InputDecoration(
                    hintText: 'Exemple : Bruit excessif appartement B12',
                    hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF9CA3AF)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    filled: true, fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6F675E))),
                  ),
                ),
              ])),

              // NIVEAU D'URGENCE
              _sectionTitle("NIVEAU D'URGENCE"),
              _card(child: Row(children: List.generate(3, (i) {
                final selected = _urgency == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _urgency = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: EdgeInsets.only(left: i == 0 ? 0 : 8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: selected ? _urgencyColors[i].withValues(alpha: 0.08) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? _urgencyColors[i] : const Color(0xFFE5E7EB),
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Center(child: Text(
                        _urgencyLabels[i],
                        style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected ? _urgencyColors[i] : const Color(0xFF6A7282),
                        ),
                      )),
                    ),
                  ),
                );
              }))),

              // DESCRIPTION DÉTAILLÉE
              _sectionTitle('DESCRIPTION DÉTAILLÉE'),
              _card(child: TextField(
                controller: _descController,
                maxLines: 5,
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF2D2520)),
                decoration: InputDecoration(
                  hintText: 'Décrivez le problème rencontré avec le plus de détails possible (circonstances, horaires, récurrence...)',
                  hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF9CA3AF), height: 1.5),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              )),

              // PHOTOS
              _sectionTitle('PHOTOS'),
              _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('PHOTOS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700,
                      color: const Color(0xFF9CA3AF), letterSpacing: 1.2)),
                  Text('JPG, PNG supportés', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF))),
                ]),
                const SizedBox(height: 12),
                Wrap(spacing: 10, runSpacing: 10, children: [
                  // Bouton ajouter
                  GestureDetector(
                    onTap: _pickImage,
                    child: _DashedBox(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.add_a_photo_outlined, size: 26, color: Color(0xFF9CA3AF)),
                        const SizedBox(height: 6),
                        Text('Ajouter', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9CA3AF))),
                      ]),
                    ),
                  ),
                  // Photos sélectionnées
                  ..._photos.asMap().entries.map((e) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(e.value, width: 100, height: 100, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 4, right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _photos.removeAt(e.key)),
                          child: Container(
                            width: 22, height: 22,
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  )),
                ]),
              ])),

              const SizedBox(height: 8),

              // Bouton Envoyer
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF9C20A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Envoyer au syndic', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              // Bouton Annuler
              SizedBox(
                width: double.infinity, height: 56,
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  child: Text('Annuler', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF6A7282))),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _SignalementSuccessPage extends StatelessWidget {
  const _SignalementSuccessPage();

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) Navigator.of(context).pop();
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 88, height: 88,
              decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 28),
            Text(
              'Signalement envoyé avec succès.',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF1C1C1E)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Votre syndic a été informé et analysera votre signalement dans les meilleurs délais.',
              style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF8B7355), height: 1.5),
              textAlign: TextAlign.center,
            ),
          ]),
        ),
      ),
    );
  }
}

class _DashedBox extends StatelessWidget {
  final Widget child;
  const _DashedBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: SizedBox(width: 100, height: 100, child: Center(child: child)),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path()..addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
      const Radius.circular(10),
    ));
    for (final m in path.computeMetrics()) {
      double d = 0;
      bool draw = true;
      while (d < m.length) {
        final len = draw ? 5.0 : 3.0;
        if (draw) canvas.drawPath(m.extractPath(d, d + len), paint);
        d += len;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter _) => false;
}
