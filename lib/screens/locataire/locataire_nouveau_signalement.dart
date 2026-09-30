// lib/screens/locataire/locataire_nouveau_signalement.dart
// Écran de création d'un nouveau signalement pour le Locataire.

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/locataire_models.dart';
import '../../services/locataire_service.dart';

class LocataireNouveauSignalementPage extends StatefulWidget {
  const LocataireNouveauSignalementPage({super.key});

  @override
  State<LocataireNouveauSignalementPage> createState() =>
      _LocataireNouveauSignalementPageState();
}

class _LocataireNouveauSignalementPageState
    extends State<LocataireNouveauSignalementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  SignalementPriorite _priorite = SignalementPriorite.moyenne;
  final List<File> _photos = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  LocataireProfile? _profile;
  TenantPropertyModel? _property;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final results = await Future.wait([
        LocataireService.getProfile(),
        LocataireService.getMyProperty(),
      ]);
      if (mounted) {
        setState(() {
          _profile = results[0] as LocataireProfile;
          _property = results[1] as TenantPropertyModel;
        });
      }
    } catch (e, st) {
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

    setState(() => _isSubmitting = true);

    try {
      await LocataireService.addSignalement(
        titre: _titreCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        priorite: _priorite,
        photos: _photos.map((f) => f.path).toList(),
      );

      if (!mounted) return;

      // Affichage du modal de succès
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
              Text('Signalement transmis',
                  style: GoogleFonts.jost(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2520))),
              const SizedBox(height: 8),
              Text(
                'Votre signalement a bien été enregistré. Le gestionnaire de la résidence en a été notifié.',
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
                    Navigator.pop(ctx); // pop dialog
                    Navigator.pop(context, true); // pop screen back to list
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6F675E),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                  ),
                  child: Text('Voir mes signalements',
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
    } catch (_) {
      if (mounted) setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur lors de la création du signalement')),
      );
    }
  }

  // ─── Input decoration ──────────────────────────────────────────────────────

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

  // ─── Priority selector ─────────────────────────────────────────────────────

  Widget _buildPriorityChip(
      String label, SignalementPriorite priority, Color color, Color bg) {
    final isSelected = _priorite == priority;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priorite = priority),
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

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final p = _profile;
    final resName = _property?.residenceName.isNotEmpty == true ? _property!.residenceName : (p?.residence ?? '—');
    final propRef = _property?.propertyReference.isNotEmpty == true ? _property!.propertyReference : (p?.appartement ?? '');
    final locationText = propRef.isNotEmpty ? '$resName • $propRef' : resName;
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
                        width: 32,
                        height: 32,
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
                    Text('Nouveau signalement',
                        style: GoogleFonts.jost(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 44),
                  child: Text(
                      'Déclarez une anomalie ou un problème dans votre logement',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8))),
                ),
              ],
            ),
          ),

          // Form Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mon logement (pre-filled info)
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
                              color: const Color(0xFFF0EDE8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: SvgPicture.asset('assets/icons/clef.svg',
                                  width: 20, height: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Logement concerné',
                                    style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF6A7282))),
                                const SizedBox(height: 2),
                                Text(
                                    locationText,
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2D2520))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Titre
                    Text('Titre du signalement *',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D2520))),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titreCtrl,
                      decoration: _inputDecoration(
                          'Ex: Fuite d\'eau, Panne d\'ascenseur...'),
                      style: GoogleFonts.inter(
                          fontSize: 14, color: const Color(0xFF2D2520)),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Veuillez saisir un titre'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Priorité
                    Text('Niveau de priorité *',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D2520))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPriorityChip(
                            'Faible',
                            SignalementPriorite.faible,
                            const Color(0xFF6A7282),
                            const Color(0xFFF3F4F6)),
                        const SizedBox(width: 10),
                        _buildPriorityChip(
                            'Moyenne',
                            SignalementPriorite.moyenne,
                            const Color(0xFFE17100),
                            const Color(0xFFFFF4E6)),
                        const SizedBox(width: 10),
                        _buildPriorityChip(
                            'Haute',
                            SignalementPriorite.haute,
                            const Color(0xFFDC2626),
                            const Color(0xFFFFF0F0)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Description
                    Text('Description détaillée *',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D2520))),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 4,
                      decoration: _inputDecoration(
                          'Décrivez le problème constaté avec le plus de détails possible...'),
                      style: GoogleFonts.inter(
                          fontSize: 14, color: const Color(0xFF2D2520)),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Veuillez saisir une description'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Photos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Photos (Optionnel)',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2D2520))),
                        Text('${_photos.length} photo(s)',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: const Color(0xFF6A7282))),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (_photos.isNotEmpty)
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _photos.length + 1,
                          separatorBuilder: (_, _) => const SizedBox(width: 10),
                          itemBuilder: (_, i) {
                            if (i == _photos.length) {
                              return GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFD6D2C9)),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo_outlined,
                                          color: Color(0xFF6F675E), size: 24),
                                      SizedBox(height: 4),
                                      Text('Ajouter',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF6F675E))),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(_photos[i],
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => setState(
                                        () => _photos.removeAt(i)),
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                          color: Color(0xCC000000),
                                          shape: BoxShape.circle),
                                      child: const Icon(Icons.close,
                                          color: Colors.white, size: 12),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: const Color(0xFFD6D2C9),
                                style: BorderStyle.solid),
                          ),
                          child: Column(
                            children: [
                              SvgPicture.asset('assets/icons/photo.svg',
                                  width: 28,
                                  height: 28,
                                  colorFilter: const ColorFilter.mode(
                                      Color(0xFF6F675E), BlendMode.srcIn)),
                              const SizedBox(height: 8),
                              Text('Ajouter une ou plusieurs photos',
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF6F675E))),
                              Text('Format JPG, PNG (Max 5Mo)',
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: const Color(0xFF9CA3AF))),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF9C20A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text('Soumettre le signalement',
                                style: GoogleFonts.beVietnamPro(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
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
