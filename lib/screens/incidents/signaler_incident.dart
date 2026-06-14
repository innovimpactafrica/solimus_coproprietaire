import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/intervention_model.dart';
import '../../models/residence_model.dart';
import '../../models/property_model.dart';
import '../../services/coowner_service.dart';

class SignalerIncidentPage extends StatefulWidget {
  const SignalerIncidentPage({super.key});

  @override
  State<SignalerIncidentPage> createState() => _SignalerIncidentPageState();
}

class _SignalerIncidentPageState extends State<SignalerIncidentPage> {
  SpecialtyModel? _selectedSpecialty;
  int _locationType = 0;
  int _urgency = 1;
  bool _isSubmitting = false;

  // Spécialités dynamiques
  List<SpecialtyModel> _specialties = [];
  bool _loadingSpecialties = true;

  // Résidences & propriétés
  List<ResidenceModel> _residences = [];
  List<PropertyModel> _properties = [];
  ResidenceModel? _selectedResidence;
  PropertyModel? _selectedProperty;
  bool _loadingResidences = true;
  bool _loadingProperties = false;

  // Parties communes dynamiques
  List<CommonFacilityModel> _commonFacilities = [];
  CommonFacilityModel? _selectedFacility;
  bool _loadingFacilities = false;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedImage;
  final _imagePicker = ImagePicker();

  static const _locationTypes = ['PARTIE_COMMUNE', 'APPARTEMENT'];
  static const _urgencyLevels = ['FAIBLE', 'MOYEN', 'URGENT'];

  @override
  void initState() {
    super.initState();
    _loadSpecialties();
    _loadResidences();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadSpecialties() async {
    try {
      final data = await CoOwnerService.getSpecialties();
      if (!mounted) return;
      setState(() { _specialties = data; _loadingSpecialties = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingSpecialties = false);
    }
  }

  Future<void> _loadResidences() async {
    try {
      final data = await CoOwnerService.getInterventionResidences();
      if (!mounted) return;
      setState(() { _residences = data; _loadingResidences = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingResidences = false);
    }
  }

  Future<void> _loadProperties(int residenceId) async {
    setState(() { _loadingProperties = true; _selectedProperty = null; _properties = []; });
    try {
      final data = await CoOwnerService.getInterventionProperties(residenceId);
      if (!mounted) return;
      setState(() { _properties = data; _loadingProperties = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingProperties = false);
    }
  }

  Future<void> _loadCommonFacilities(int residenceId) async {
    setState(() { _loadingFacilities = true; _selectedFacility = null; _commonFacilities = []; });
    try {
      final data = await CoOwnerService.getCommonFacilities(residenceId);
      if (!mounted) return;
      setState(() { _commonFacilities = data; _loadingFacilities = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingFacilities = false);
    }
  }

  Future<void> _onSubmit(String managementMode) async {
    if (_selectedSpecialty == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez choisir une catégorie')));
      return;
    }
    if (_selectedResidence == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez choisir une résidence')));
      return;
    }
    if (_locationType == 0 && _selectedFacility == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez choisir une partie commune')));
      return;
    }
    if (_locationType == 1 && _selectedProperty == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez choisir un appartement')));
      return;
    }
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez saisir un titre')));
      return;
    }
    final desc = _descriptionController.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez décrire l\'incident')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await CoOwnerService.createIntervention(
        title: title,
        description: desc,
        residenceId: _selectedResidence!.id,
        propertyId: _locationType == 1 ? _selectedProperty?.id : null,
        commonFacilityId: _locationType == 0 ? _selectedFacility?.id : null,
        specialtyId: _selectedSpecialty!.id,
        locationType: _locationTypes[_locationType],
        managementMode: managementMode,
        urgencyLevel: _urgencyLevels[_urgency],
        photos: _selectedImage != null ? [_selectedImage!.path] : [],
      );
      if (!mounted) return;
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (c, a, s) => managementMode == 'OWNER'
            ? const IncidentSignaleSuccessPage(
                title: 'Intervention affectée avec succès',
                subtitle: 'Les prestataires ont bien reçu la mission et vous enverront un devis pour validation avant le démarrage des travaux.',
              )
            : const IncidentSignaleSuccessPage(),
        transitionsBuilder: (c, anim, s, child) => FadeTransition(opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut), child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          duration: const Duration(seconds: 10),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  static String _iconForSpecialty(String name) {
    final n = name.toLowerCase();
    if (n.contains('plomb')) return 'assets/icons/plomberie.svg';
    if (n.contains('electr') || n.contains('électr')) return 'assets/icons/electric.svg';
    if (n.contains('ascen')) return 'assets/icons/ascen.svg';
    if (n.contains('secur') || n.contains('sécur')) return 'assets/icons/securite.svg';
    if (n.contains('nettoy')) return 'assets/icons/nettoyage.svg';
    return 'assets/icons/incident.svg';
  }

  static Color _colorForSpecialty(String name) {
    final n = name.toLowerCase();
    if (n.contains('plomb')) return const Color(0xFF2B7FFF);
    if (n.contains('electr') || n.contains('électr')) return const Color(0xFFF0B100);
    if (n.contains('ascen')) return const Color(0xFFAD46FF);
    if (n.contains('secur') || n.contains('sécur')) return const Color(0xFFFB2C36);
    if (n.contains('nettoy')) return const Color(0xFF00C950);
    return const Color(0xFF6A7282);
  }

  static const _urgencies = [
    _Urgency('Faible', Color(0xFF2B7FFF)),
    _Urgency('Moyen', Color(0xFFE17100)),
    _Urgency('Urgent', Color(0xFFDC2626)),
  ];

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _imagePicker.pickImage(source: source, imageQuality: 80);
    if (picked != null && mounted) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFAF9F4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Ajouter une photo',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D2520),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9C20A).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFFF9A826)),
                ),
                title: Text(
                  'Prendre une photo',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2D2520),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B7FFF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF2B7FFF)),
                ),
                title: Text(
                  'Choisir dans la galerie',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2D2520),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialtyCard(SpecialtyModel specialty) {
    final selected = _selectedSpecialty?.id == specialty.id;
    final color = _colorForSpecialty(specialty.name);
    final icon = _iconForSpecialty(specialty.name);
    return GestureDetector(
      onTap: () => setState(() => _selectedSpecialty = specialty),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 107,
        height: 99,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : const Color(0xFFE5E7EB),
            width: 1.51,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 17),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SvgPicture.asset(icon, width: 20, height: 20),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                specialty.name,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2D2520),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationButton(int index, String label, String svgPath) {
    final selected = _locationType == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _locationType = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 107.72,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF9C20A) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: selected
                ? null
                : Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
          ),
          padding: const EdgeInsets.only(
            top: 24,
            right: 24,
            left: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgPicture.asset(
                svgPath,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  selected ? Colors.white : const Color(0xFF6A7282),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : const Color(0xFF2D2520),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUrgency(int index) {
    final u = _urgencies[index];
    final selected = _urgency == index;
    return GestureDetector(
      onTap: () => setState(() => _urgency = index),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 107,
            height: 59,
            decoration: BoxDecoration(
              color: selected ? const Color(0x0DF9C20A) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? const Color(0x00000000)
                    : const Color(0xFFE5E7EB),
                width: 1.51,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration:
                      BoxDecoration(color: u.color, shape: BoxShape.circle),
                ),
                const SizedBox(height: 6),
                Text(
                  u.label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? const Color(0xFF2D2520) : const Color(0xFF6A7282),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResidenceDropdown() {
    return DropdownButtonFormField<ResidenceModel>(
      value: _selectedResidence,
      hint: Text(
        _loadingResidences ? 'Chargement...' : 'Choisir une résidence',
        style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF9CA3AF)),
      ),
      items: _residences.map((r) => DropdownMenuItem(
        value: r,
        child: Text(r.name, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF2D2520))),
      )).toList(),
      onChanged: _loadingResidences ? null : (v) {
        setState(() {
          _selectedResidence = v;
          _selectedProperty = null;
          _properties = [];
          _selectedFacility = null;
          _commonFacilities = [];
        });
        if (v != null) {
          _loadProperties(v.id);
          _loadCommonFacilities(v.id);
        }
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 0.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 0.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFF6F675E))),
      ),
      dropdownColor: const Color(0xFFFAF9F4),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF6A7282)),
      isExpanded: true,
    );
  }

  Widget _buildPropertyDropdown() {
    return DropdownButtonFormField<PropertyModel>(
      value: _selectedProperty,
      hint: Text(
        _loadingProperties ? 'Chargement...' : (_selectedResidence == null ? 'Choisir d\'abord une résidence' : 'Choisir un appartement'),
        style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF9CA3AF)),
      ),
      items: _properties.map((p) => DropdownMenuItem(
        value: p,
        child: Text(p.name, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF2D2520))),
      )).toList(),
      onChanged: (_loadingProperties || _selectedResidence == null) ? null : (v) => setState(() => _selectedProperty = v),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 0.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 0.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFF6F675E))),
      ),
      dropdownColor: const Color(0xFFFAF9F4),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF6A7282)),
      isExpanded: true,
    );
  }

  Widget _buildCommonFacilityDropdown() {
    return DropdownButtonFormField<CommonFacilityModel>(
      value: _selectedFacility,
      hint: Text(
        _selectedResidence == null
            ? 'Choisir d\'abord une résidence'
            : _loadingFacilities
                ? 'Chargement...'
                : _commonFacilities.isEmpty
                    ? 'Aucune partie commune'
                    : 'Choisir une partie commune',
        style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF9CA3AF)),
      ),
      items: _commonFacilities.map((f) => DropdownMenuItem(
        value: f,
        child: Text(f.label, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF2D2520))),
      )).toList(),
      onChanged: (_loadingFacilities || _selectedResidence == null) ? null : (v) => setState(() => _selectedFacility = v),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 0.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 0.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFF6F675E))),
      ),
      dropdownColor: const Color(0xFFFAF9F4),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF6A7282)),
      isExpanded: true,
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2D2520),
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
                Text(
                  'Signaler un incidents',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _sectionLabel('Titre'),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: TextField(
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: _locationType == 1 ? 'Ex: Fuite d\'eau salle de bain' : 'Ex: Éclairage défectueux dans le couloir',
                        hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF9CA3AF)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(14),
                      ),
                      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF2D2520)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionLabel('Catégorie'),
                  if (_loadingSpecialties)
                    const Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(color: Color(0xFFF9A826), strokeWidth: 2),
                    ))
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _specialties.map(_buildSpecialtyCard).toList(),
                    ),
                  const SizedBox(height: 24),
                  _sectionLabel('Résidences'),
                  _buildResidenceDropdown(),
                  const SizedBox(height: 24),
                  _sectionLabel("Ou se situe l'incident ?"),
                  Row(
                    children: [
                      _buildLocationButton(
                          0, 'Partie commune', 'assets/icons/partie.svg'),
                      const SizedBox(width: 12),
                      _buildLocationButton(
                          1, 'Appartement privé', 'assets/icons/app.svg'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _sectionLabel('Espace concerné'),
                  _locationType == 1 ? _buildPropertyDropdown() : _buildCommonFacilityDropdown(),
                  const SizedBox(height: 24),
                  _sectionLabel('Description'),
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: "Décrivez l'incident en détail...",
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF9CA3AF),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(14),
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF2D2520),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionLabel("Niveau d'urgence"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [0, 1, 2].map(_buildUrgency).toList(),
                  ),
                  const SizedBox(height: 24),
                  _sectionLabel('Photo'),
                  GestureDetector(
                    onTap: _showImageSourceSheet,
                    child: _selectedImage != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(
                                  _selectedImage!,
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedImage = null),
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : CustomPaint(
                            painter: _DashedBorderPainter(
                              color: const Color(0x266B5744),
                              strokeWidth: 1.51,
                              borderRadius: 20,
                              dashLength: 3.01,
                              gapLength: 1.51,
                            ),
                            child: Container(
                              width: double.infinity,
                              height: 127,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/cameo.svg',
                                    width: 32,
                                    height: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Ajouter une photo',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF8B7355),
                                      height: 20 / 14,
                                      letterSpacing: -0.15,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : () => _onSubmit(_locationType == 1 ? 'OWNER' : 'SYNDIC'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF9A826),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              _locationType == 1 ? 'Envoyer aux prestataires' : 'Envoyer le signalement',
                              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : _locationType == 1
                              ? () => _onSubmit('SYNDIC')
                              : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        side: const BorderSide(color: Color(0xFF6F675E), width: 1),
                      ),
                      child: Text(
                        _locationType == 1 ? 'Envoyer au syndic' : 'Annuler',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF6A7282)),
                      ),
                    ),
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

class IncidentSignaleSuccessPage extends StatefulWidget {
  final String title;
  final String subtitle;

  const IncidentSignaleSuccessPage({
    super.key,
    this.title = 'Incident signalé !',
    this.subtitle =
        'Votre signalement a été envoyé avec succès.\nNotre équipe va le prendre en charge rapidement.',
  });

  @override
  State<IncidentSignaleSuccessPage> createState() =>
      _IncidentSignaleSuccessPageState();
}

class _IncidentSignaleSuccessPageState
    extends State<IncidentSignaleSuccessPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      // Pop back to MesIncidentsPage (already on stack)
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: Color(0xFF00C950),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/signale.svg',
                    width: 56,
                    height: 56,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                widget.title,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D2520),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                widget.subtitle,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6A7282),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Urgency {
  final String label;
  final Color color;
  const _Urgency(this.label, this.color);
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double borderRadius;
  final double dashLength;
  final double gapLength;

  const _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(
          strokeWidth / 2,
          strokeWidth / 2,
          size.width - strokeWidth,
          size.height - strokeWidth,
        ),
        Radius.circular(borderRadius),
      ));

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final len = draw ? dashLength : gapLength;
        if (draw) {
          canvas.drawPath(metric.extractPath(distance, distance + len), paint);
        }
        distance += len;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.borderRadius != borderRadius ||
      old.dashLength != dashLength ||
      old.gapLength != gapLength;
}
