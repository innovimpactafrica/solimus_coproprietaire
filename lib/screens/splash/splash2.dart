import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'splash3.dart';

class Splash2 extends StatelessWidget {
  const Splash2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/image1.png',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Color(0xFF6F675E),
                ],
                stops: [0.0, 0.5787, 0.7721],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 155,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Simplifiez la gestion de votre logement',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jost(
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      height: 32 / 24,
                      letterSpacing: 24 * 0.005,
                      color: const Color(0xFFFEFEFE),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Que vous soyez copropriétaire ou locataire, suivez vos demandes, signalements et informations en toute simplicité.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jost(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      height: 22 / 16,
                      letterSpacing: 16 * 0.005,
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9C20A),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 52,
            child: SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const Splash3()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF9C20A),
                  foregroundColor: const Color(0xFF6F675E),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Suivant',
                  style: GoogleFonts.jost(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    height: 26 / 18,
                    letterSpacing: 18 * 0.005,
                    color: const Color(0xFFFEFEFE),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
