import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/profile_model.dart';
import '../../services/coowner_service.dart';
import '../../services/user_session.dart';

class InformationsPersonnellesPage extends StatefulWidget {
  final ProfileModel? profile;

  const InformationsPersonnellesPage({super.key, this.profile});

  @override
  State<InformationsPersonnellesPage> createState() =>
      _InformationsPersonnellesPageState();
}

class _InformationsPersonnellesPageState
    extends State<InformationsPersonnellesPage> {
  late final TextEditingController _prenomController;
  late final TextEditingController _nomController;
  late final TextEditingController _telephoneController;
  late final TextEditingController _emailController;
  bool _isLoading = false;
  String? _selectedPhotoPath;

  @override
  void initState() {
    super.initState();
    _prenomController =
        TextEditingController(text: widget.profile?.firstName ?? '');
    _nomController =
        TextEditingController(text: widget.profile?.lastName ?? '');
    _telephoneController =
        TextEditingController(text: widget.profile?.phone ?? '');
    _emailController =
        TextEditingController(text: widget.profile?.email ?? '');
  }

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFAF9F4),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _photoOption(Icons.camera_alt_rounded, 'Prendre une photo', ImageSource.camera),
            const SizedBox(height: 12),
            _photoOption(Icons.photo_library_rounded, 'Choisir depuis la galerie', ImageSource.gallery),
          ],
        ),
      ),
    );
  }

  Widget _photoOption(IconData icon, String label, ImageSource source) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        final picked = await ImagePicker().pickImage(
          source: source,
          imageQuality: 80,
          maxWidth: 800,
        );
        if (picked != null) {
          setState(() => _selectedPhotoPath = picked.path);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6F675E), size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF2D2520)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onMettreAJour() async {
    final firstName = _prenomController.text.trim();
    final lastName = _nomController.text.trim();
    final phone = _telephoneController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await CoOwnerService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        photoPath: _selectedPhotoPath,
      );
      await CoOwnerService.getProfile();
      // Sauvegarder la photo localement (évite le problème d'auth Minio)
      if (_selectedPhotoPath != null) {
        await UserSession.instance.saveLocalPhoto(_selectedPhotoPath!);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour avec succès')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _field(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: const Color(0xFF2D2520),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0x1A6F675E),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFD6D2C9), width: 1),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF2D2520),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF9CA3AF),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F4),
      body: SingleChildScrollView(
        child: Column(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations personnelles',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Consultez mes informations personnelles',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Avatar
            GestureDetector(
              onTap: _pickPhoto,
              child: Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: ClipOval(
                      child: _selectedPhotoPath != null
                          ? Image.file(
                              File(_selectedPhotoPath!),
                              width: 90, height: 90, fit: BoxFit.cover,
                            )
                          : (UserSession.instance.localPhotoPath.value != null)
                              ? Image.file(
                                  File(UserSession.instance.localPhotoPath.value!),
                                  width: 90, height: 90, fit: BoxFit.cover,
                                )
                              : Image.asset('assets/images/cop.png', width: 90, height: 90, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF9C20A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Text(
              widget.profile?.fullName ?? '—',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: const Color(0xFF2D2520),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              widget.profile?.memberSinceFormatted ?? '',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF747D8C),
              ),
            ),

            const SizedBox(height: 32),

            // Formulaire
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _field('Prénom', _prenomController, 'Saisir'),
                  const SizedBox(height: 16),
                  _field('Nom', _nomController, 'Saisir'),
                  const SizedBox(height: 16),
                  _field('Téléphone', _telephoneController, '+221 77 567 89 90'),
                  const SizedBox(height: 16),
                  _field('Email', _emailController, 'example@gmail.com'),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onMettreAJour,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF9C20A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Mettre à jour',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
