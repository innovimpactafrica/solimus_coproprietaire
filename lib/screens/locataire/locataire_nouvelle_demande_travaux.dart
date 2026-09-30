// lib/screens/locataire/locataire_nouvelle_demande_travaux.dart
// Écran de création d'une nouvelle demande de travaux pour le Locataire.

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/intervention_model.dart';
import '../../models/locataire_models.dart';
import '../../services/coowner_service.dart';
import '../../services/locataire_service.dart';

class LocataireNouvelleDemandeTravauxPage extends StatefulWidget {
  const LocataireNouvelleDemandeTravauxPage({super.key});

  @override
  State<LocataireNouvelleDemandeTravauxPage> createState() =>
      _LocataireNouvelleDemandeTravauxPageState();
}

class _LocataireNouvelleDemandeTravauxPageState
    extends State<LocataireNouvelleDemandeTravauxPage> {
  final _formKey = GlobalKey<FormState>();
  final _titreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  SpecialtyModel? _selectedSpecialty;
  String _locationType = 'APPARTEMENT'; // APPARTEMENT ou PARTIE_COMMUNE
  String _urgencyLevel = 'MOYEN'; // FAIBLE, MOYEN, URGENT
  CommonFacilityModel? _selectedFacility;

  List<SpecialtyModel> _specialties = [];
  bool _loadingSpecialties = true;

  List<CommonFacilityModel> _commonFacilities = [];
  bool _loadingFacilities = true;

  final List<File> _photos = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  LocataireProfile? _profile;
  TenantPropertyModel? _property;

  static const _fallbackSpecialties = [
    SpecialtyModel(id: 1, name: 'Plomberie'),
    SpecialtyModel(id: 2, name: 'Électricité'),
    SpecialtyModel(id: 3, name: 'Peinture'),
    SpecialtyModel(id: 4, name: 'Serrurerie'),
    SpecialtyModel(id: 5, name: 'Entretien & Nettoyage'),
    SpecialtyModel(id: 6, name: 'Autre'),
  ];

  static const _fallbackCommonFacilities = [
    CommonFacilityModel(id: 1, label: 'Ascenseur'),
    CommonFacilityModel(id: 2, label: 'Hall d\'entrée'),
    CommonFacilityModel(id: 3, label: 'Parking / Garages'),
    CommonFacilityModel(id: 4, label: 'Escaliers & Couloirs'),
    CommonFacilityModel(id: 5, label: 'Jardin & Cour'),
    CommonFacilityModel(id: 6, label: 'Toiture & Terrasse'),
    CommonFacilityModel(id: 7, label: 'Portail & Clôture'),
    CommonFacilityModel(id: 8, label: 'Local Poubelles'),
    CommonFacilityModel(id: 9, label: 'Éclairage extérieur'),
  ];

  Future<void> _fetchFacilities() async {
    try {
      final facs = await LocataireService.getTenantCommonFacilities();
      if (mounted) {
        setState(() {
          _commonFacilities = facs.isNotEmpty ? facs : _fallbackCommonFacilities;
          _loadingFacilities = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _commonFacilities = _fallbackCommonFacilities;
          _loadingFacilities = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. Specialties
    try {
      final specs = await CoOwnerService.getSpecialties();
      if (mounted) {
        setState(() {
          _specialties = specs.isNotEmpty ? specs : _fallbackSpecialties;
          _loadingSpecialties = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _specialties = _fallbackSpecialties;
          _loadingSpecialties = false;
        });
      }
    }

    // 2. Common Facilities
    await _fetchFacilities();

    // 3. Profile
    try {
      final prof = await LocataireService.getProfile();
      if (mounted) setState(() => _profile = prof);
    } catch (e) {
    }

    // 4. Property
    try {
      final prop = await LocataireService.getMyProperty();
      if (mounted) setState(() => _property = prop);
    } catch (e) {
    }
  }

  @override
  void dispose() {
    _titreCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFAF9F4),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text('Ajouter une photo',
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2520))),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: const Color(0xFF6F675E).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: Color(0xFF6F675E)),
                ),
                title: Text('Prendre une photo',
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2D2520))),
                onTap: () async {
                  Navigator.pop(context);
                  final xfile =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (xfile != null && mounted) {
                    setState(() => _photos.add(File(xfile.path)));
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: const Color(0xFF6F675E).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.photo_library_rounded,
                      color: Color(0xFF6F675E)),
                ),
                title: Text('Choisir dans la galerie',
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2D2520))),
                onTap: () async {
                  Navigator.pop(context);
                  final files = await _picker.pickMultiImage();
                  if (files.isNotEmpty && mounted) {
                    setState(() =>
                        _photos.addAll(files.map((x) => File(x.path))));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSpecialty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir une spécialité/catégorie.')),
      );
      return;
    }
    if (_locationType == 'PARTIE_COMMUNE' && _selectedFacility == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner la partie commune concernée.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await LocataireService.createTenantIntervention(
        title: _titreCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        specialtyId: _selectedSpecialty!.id,
        locationType: _locationType,
        urgencyLevel: _urgencyLevel,
        commonFacilityId: _locationType == 'PARTIE_COMMUNE' ? _selectedFacility?.id : null,
        photos: _photos.map((f) => f.path).toList(),
      );

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: const Color(0xFFFAF9F4),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFFFF6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF00A63E), size: 40),
              ),
              const SizedBox(height: 16),
              Text('Demande transmise',
                  style: GoogleFonts.jost(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2520))),
              const SizedBox(height: 8),
              Text(
                'Votre demande de travaux a bien été créée avec succès. Le syndic en a été informé.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 13, color: const Color(0xFF6A7282), height: 1.4),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6F675E),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                  ),
                  child: Text('Voir mes travaux',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
            fontSize: 14, color: const Color(0xFF9CA3AF)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD6D2C9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD6D2C9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6F675E), width: 1.5),
        ),
      );

  Widget _buildUrgencyChip(String label, String value, Color color, Color bg) {
    final isSelected = _urgencyLevel == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _urgencyLevel = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? bg : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isSelected ? color : const Color(0xFFD6D2C9),
                width: isSelected ? 1.5 : 1.0),
          ),
          child: Column(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(height: 6),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? color : const Color(0xFF6A7282))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationTypeChip(String label, String value, IconData icon) {
    final isSelected = _locationType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _locationType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6F675E).withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF6F675E) : const Color(0xFFD6D2C9),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? const Color(0xFF6F675E) : const Color(0xFF6A7282)),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF6F675E) : const Color(0xFF6A7282),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _profile;
    final resName = (_property?.residenceName.isNotEmpty == true)
        ? _property!.residenceName
        : ((p?.residence != null && p!.residence.isNotEmpty) ? p.residence : 'Résidence principale');
    final propRef = (_property?.propertyReference.isNotEmpty == true)
        ? _property!.propertyReference
        : ((p?.appartement != null && p!.appartement.isNotEmpty) ? p.appartement : 'Mon appartement');
    final locationText = (resName.isNotEmpty && propRef.isNotEmpty) ? '$resName • $propRef' : (resName.isNotEmpty ? resName : 'Mon appartement');

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F4),
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(
                16, MediaQuery.of(context).padding.top + 16, 16, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF6F675E),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('Demande de travaux',
                        style: GoogleFonts.jost(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 48),
                  child: Text(
                    'Transmettez une demande de travaux au syndic',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.8)),
                  ),
                ),
              ],
            ),
          ),
          // Formulaire
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Emplacement actuel
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6F675E).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.home_work_outlined,
                                color: Color(0xFF6F675E), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Logement concerné',
                                    style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: const Color(0xFF9CA3AF),
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 2),
                                Text(locationText,
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF2D2520))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Emplacement : Appartement ou Partie commune
                    Text('Emplacement',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D2520))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildLocationTypeChip('Mon logement', 'APPARTEMENT', Icons.home_rounded),
                        const SizedBox(width: 12),
                        _buildLocationTypeChip('Partie commune', 'PARTIE_COMMUNE', Icons.domain_rounded),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Si Partie commune -> sélection de l'équipement commun
                    if (_locationType == 'PARTIE_COMMUNE') ...[
                      Text('Équipement commun',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2D2520))),
                      const SizedBox(height: 8),
                      _loadingFacilities
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6F675E)))
                          : Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFD6D2C9)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<CommonFacilityModel>(
                                  isExpanded: true,
                                  value: _selectedFacility,
                                  hint: Text('Sélectionner l\'équipement commun',
                                      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF9CA3AF))),
                                  items: _commonFacilities.map((f) {
                                    return DropdownMenuItem<CommonFacilityModel>(
                                      value: f,
                                      child: Text(f.name, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF2D2520))),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setState(() => _selectedFacility = val),
                                ),
                              ),
                            ),
                      const SizedBox(height: 20),
                    ],

                    // Spécialité / Catégorie
                    Text('Spécialité / Catégorie',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D2520))),
                    const SizedBox(height: 8),
                    _loadingSpecialties
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF6F675E)))
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFD6D2C9)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<SpecialtyModel>(
                                isExpanded: true,
                                value: _selectedSpecialty,
                                hint: Text('Choisir une catégorie',
                                    style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF9CA3AF))),
                                items: _specialties.map((s) {
                                  return DropdownMenuItem<SpecialtyModel>(
                                    value: s,
                                    child: Text(s.name, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF2D2520))),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedSpecialty = val),
                              ),
                            ),
                          ),
                    const SizedBox(height: 20),

                    // Titre
                    Text('Intitulé de la demande',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D2520))),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titreCtrl,
                      decoration: _inputDecoration('Ex: Fuite d\'eau sous le lavabo'),
                      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF2D2520)),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Veuillez saisir un intitulé' : null,
                    ),
                    const SizedBox(height: 20),

                    // Description
                    Text('Description détaillée',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D2520))),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 4,
                      decoration: _inputDecoration('Décrivez le problème constaté...'),
                      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF2D2520)),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Veuillez décrire votre demande' : null,
                    ),
                    const SizedBox(height: 20),

                    // Urgence
                    Text('Niveau d\'urgence',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D2520))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildUrgencyChip('Faible', 'FAIBLE', const Color(0xFF00A63E), const Color(0xFFEFFFF6)),
                        const SizedBox(width: 8),
                        _buildUrgencyChip('Moyen', 'MOYEN', const Color(0xFFE17100), const Color(0xFFFFF4E6)),
                        const SizedBox(width: 8),
                        _buildUrgencyChip('Urgent', 'URGENT', const Color(0xFFDC2626), const Color(0xFFFFF0F0)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Photos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Photos du problème',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2D2520))),
                        Text('${_photos.length} photo(s)',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: const Color(0xFF6A7282))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: const Color(0xFFD6D2C9),
                                    style: BorderStyle.solid),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset('assets/icons/photo.svg',
                                      width: 22, height: 22),
                                  const SizedBox(height: 4),
                                  Text('Ajouter',
                                      style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF6F675E))),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ..._photos.asMap().entries.map((entry) {
                            final i = entry.key;
                            final f = entry.value;
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    image: DecorationImage(
                                        image: FileImage(f),
                                        fit: BoxFit.cover),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 14,
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _photos.removeAt(i)),
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle),
                                      child: const Icon(Icons.close,
                                          color: Colors.white, size: 12),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6F675E),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : Text('Transmettre la demande',
                                style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
