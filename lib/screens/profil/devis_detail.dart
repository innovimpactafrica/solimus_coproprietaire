import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class DevisDetailPage extends StatelessWidget {
  const DevisDetailPage({super.key});

  Widget _infoRow(String iconPath, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: SvgPicture.asset(iconPath, width: 16, height: 16),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                height: 1.0,
                color: const Color(0xFF99A1AF),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 20 / 14,
                letterSpacing: -0.15,
                color: const Color(0xFF231F20),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _lineItem(String name, String detail, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 20 / 14,
                letterSpacing: -0.15,
                color: const Color(0xFF231F20),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              detail,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                height: 1.0,
                color: const Color(0xFF6A7282),
              ),
            ),
          ],
        ),
        Text(
          price,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            height: 20 / 14,
            letterSpacing: -0.15,
            color: const Color(0xFF6F675E),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String iconPath, String title, Color iconBg) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: SvgPicture.asset(iconPath, width: 16, height: 16)),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            height: 30 / 20,
            letterSpacing: -0.45,
            color: const Color(0xFF231F20),
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
            SizedBox(
              height: 135,
              child: Stack(
                children: [
                  Container(width: double.infinity, height: 135, color: const Color(0xFF6F675E)),
                  Container(width: double.infinity, height: 135, color: const Color(0x66000000)),
                  Positioned(
                    top: 48,
                    left: 24,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0x33FFFFFF),
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
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'DEV-584729',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                height: 32 / 20,
                                letterSpacing: 0.07,
                                color: const Color(0xFFFFFFFF),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Réparation fuite d\'eau',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                height: 20 / 14,
                                letterSpacing: -0.15,
                                color: const Color(0xFFFFFFFF),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Carte statut
            Container(
              width: 365,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6F675E),
                    Color(0xFF6D655C),
                    Color(0xFF6A625A),
                    Color(0xFF686058),
                    Color(0xFF665E55),
                    Color(0xFF635B53),
                    Color(0xFF615951),
                    Color(0xFF5F574F),
                    Color(0xFF5C544D),
                    Color(0xFF5A524B),
                  ],
                  stops: [0.0, 0.1111, 0.2222, 0.3333, 0.4444, 0.5556, 0.6667, 0.7778, 0.8889, 1.0],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Statut
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Statut',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: const Color(0xFF99A1AF),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                SvgPicture.asset('assets/icons/valid.svg', width: 20, height: 20),
                                const SizedBox(width: 6),
                                Text(
                                  'Validé',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: const Color(0xFFFFFFFF),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Montant
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Montant total',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: const Color(0xFF99A1AF),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '56 200 FCFA',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              letterSpacing: 0.07,
                              color: const Color(0xFFFFFFFF),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0x33FFFFFF), thickness: 0.5, height: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Envoyé le',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: const Color(0xFF99A1AF),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '08 Mai 2026',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: const Color(0xFFFFFFFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Validé le',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: const Color(0xFF99A1AF),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '10 Mai 2026',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: const Color(0xFFFFFFFF),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Informations client
            Container(
              width: 365,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('assets/icons/infoclient.svg', 'Informations client', const Color(0x1A6F675E)),
                  const SizedBox(height: 16),
                  _infoRow('assets/icons/nom.svg', 'Nom', 'Marie Diop'),
                  const SizedBox(height: 14),
                  _infoRow('assets/icons/telephone.svg', 'Téléphone', '+221 77 234 56 78'),
                  const SizedBox(height: 14),
                  _infoRow('assets/icons/Email.svg', 'Email', 'marie.diop@email.com'),
                  const SizedBox(height: 14),
                  _infoRow('assets/icons/adress.svg', 'Adresse', 'Résidence Les Palmiers, Apt 205, Dakar'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Matériels
            Container(
              width: 365,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('assets/icons/materiel.svg', 'Matériels', const Color(0x1A6F675E)),
                  const SizedBox(height: 16),
                  _lineItem('Tuyau PVC Ø32mm', '3 × 2 500 FCFA', '7 500 FCFA'),
                  const SizedBox(height: 12),
                  _lineItem('Raccords T', '2 × 1 800 FCFA', '3 600 FCFA'),
                  const SizedBox(height: 12),
                  _lineItem('Colle PVC', '1 × 3 500 FCFA', '3 500 FCFA'),
                  const SizedBox(height: 12),
                  _lineItem('Ruban téflon', '2 × 800 FCFA', '1 600 FCFA'),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFF3F4F6), thickness: 1, height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sous-total matériels',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: const Color(0xFF2D2520),
                        ),
                      ),
                      Text(
                        '16 200 FCFA',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: const Color(0xFF2D2520),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Main d'œuvre
            Container(
              width: 365,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('assets/icons/mainoeuvre.svg', 'Main d\'œuvre', const Color(0xFFFEF3C6)),
                  const SizedBox(height: 16),
                  _lineItem('Diagnostic et localisation fuite', '1h × 8 000 FCFA/h', '8 000 FCFA'),
                  const SizedBox(height: 12),
                  _lineItem('Réparation canalisation', '3h × 8 000 FCFA/h', '24 000 FCFA'),
                  const SizedBox(height: 12),
                  _lineItem('Test étanchéité', '1h × 8 000 FCFA/h', '8 000 FCFA'),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFF3F4F6), thickness: 1, height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sous-total main d\'œuvre',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: const Color(0xFF2D2520),
                        ),
                      ),
                      Text(
                        '40 000 FCFA',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: const Color(0xFF2D2520),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Total TTC
            Container(
              width: 365,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF231F20),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total TTC',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                  Text(
                    '56 200 FCFA',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      letterSpacing: 0.07,
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Notes
            Container(
              width: 365,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFBEB),
                border: Border(
                  top: BorderSide(color: Color(0xFFFEE685), width: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset('assets/icons/note.svg', width: 16, height: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Notes',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          height: 20 / 14,
                          letterSpacing: -0.15,
                          color: const Color(0xFF7B3306),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Intervention en urgence - Fuite détectée sous l\'évier de la cuisine',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      height: 20 / 14,
                      letterSpacing: -0.15,
                      color: const Color(0xFF973C00),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Bouton télécharger
            Container(
              width: 365,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF6F675E),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/icons/download2.svg', width: 20, height: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Télécharger le devis PDF',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      height: 24 / 16,
                      letterSpacing: -0.31,
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
