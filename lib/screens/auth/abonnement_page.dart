import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solimus_coproprietaire/screens/home/home.dart';

/// Page de sélection d'abonnement (Basic / Premium / Entreprise).
/// Affiche les plans avec toggle mensuel/annuel et ouvre un modal de paiement.
class AbonnementPage extends StatefulWidget {
  const AbonnementPage({super.key});

  @override
  State<AbonnementPage> createState() => _AbonnementPageState();
}

class _AbonnementPageState extends State<AbonnementPage> {
  bool _isAnnuel = false;

  final _plans = [
    {
      'nom': 'Basic',
      'desc': 'Pour commencer simplement',
      'prix_mensuel': '15 000',
      'prix_annuel': '10 000',
      'features': ['100 devis', '100 réponses / mois'],
      'features_off': ['Export PDF/Excel'],
      'recommande': false,
    },
    {
      'nom': 'Premium',
      'desc': 'Boostez votre productivité',
      'prix_mensuel': '50 000',
      'prix_annuel': '40 000',
      'features': ['Devis illimités', '2500 réponses / mois', 'Export PDF & Excel', 'Support prioritaire'],
      'features_off': <String>[],
      'recommande': true,
    },
    {
      'nom': 'Entreprise',
      'desc': 'Pour les grandes équipes',
      'prix_mensuel': '150 000',
      'prix_annuel': '120 000',
      'features': ['Tout ce qui est dans Pro', 'Utilisateurs illimités', 'Marque blanche (White label)', 'Accès API complet'],
      'features_off': <String>[],
      'recommande': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header
          Container(
            color: const Color(0xFF6F675E),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Abonnement',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Choisissez votre pack d'abonnement",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Toggle Mensuel / Annuel
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: const Color(0xFFE8E8E8)),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _toggleBtn('Mensuel', !_isAnnuel, () => setState(() => _isAnnuel = false)),
                        _toggleBtn('Annuel', _isAnnuel, () => setState(() => _isAnnuel = true)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Plans
                  ..._plans.map((plan) => _PlanCard(
                    plan: plan,
                    isAnnuel: _isAnnuel,
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit un bouton toggle Mensuel/Annuel.
  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF6F675E) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: active ? Colors.white : const Color(0xFF6F675E),
          ),
        ),
      ),
    );
  }
}

/// Carte affichant les détails d'un plan (nom, prix, fonctionnalités, bouton).
class _PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool isAnnuel;

  const _PlanCard({required this.plan, required this.isAnnuel});

  @override
  Widget build(BuildContext context) {
    final bool recommande = plan['recommande'] as bool;
    final String prix = isAnnuel ? plan['prix_annuel'] as String : plan['prix_mensuel'] as String;
    final List<String> features = List<String>.from(plan['features'] as List);
    final List<String> featuresOff = List<String>.from(plan['features_off'] as List);

    return Container(
      margin: EdgeInsets.only(bottom: recommande ? 20 : 16, top: recommande ? 8 : 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: recommande ? const Color(0xFFF9C20A) : const Color(0x806B7280),
          width: recommande ? 2 : 1,
        ),
        boxShadow: recommande
            ? [BoxShadow(color: const Color(0x1F97392D), blurRadius: 30, offset: const Offset(0, 8))]
            : [],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recommande) const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan['nom'] as String,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            color: const Color(0xFF1C1B1B),
                          ),
                        ),
                        Text(
                          plan['desc'] as String,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            color: const Color(0xFF696159),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$prix FCFA',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: const Color(0xFFF9C20A),
                          ),
                        ),
                        Text(
                          '/ mois',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: const Color(0xFF696159),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...features.map((f) => _featureRow(f, true)),
                ...featuresOff.map((f) => _featureRow(f, false)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _showPaiementModal(
                      context,
                      nomPack: plan['nom'] as String,
                      prix: prix,
                      isAnnuel: isAnnuel,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF9C20A),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Choisir ce pack',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (recommande)
            Positioned(
              top: -14,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9C20A),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'RECOMMANDÉ',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Ouvre le modal de paiement pour le plan sélectionné.
  void _showPaiementModal(BuildContext context, {required String nomPack, required String prix, required bool isAnnuel}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaiementModal(nomPack: nomPack, prix: prix, isAnnuel: isAnnuel),
    );
  }

  Widget _featureRow(String label, bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/donee.svg',
            width: 16,
            height: 16,
            colorFilter: active
                ? null
                : const ColorFilter.mode(Color(0xFFBBBBBB), BlendMode.srcIn),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: active ? const Color(0xFF1C1B1B) : const Color(0xFFBBBBBB),
            ),
          ),
        ],
      ),
    );
  }
}

/// Page de confirmation affichée après une souscription réussie.
/// Redirige automatiquement vers l'accueil après 3,5 secondes.
class _AbonnementSuccessPage extends StatefulWidget {
  const _AbonnementSuccessPage();

  @override
  State<_AbonnementSuccessPage> createState() => _AbonnementSuccessPageState();
}

class _AbonnementSuccessPageState extends State<_AbonnementSuccessPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
          (_) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: const Color(0xFF4CAF50),
                  width: 0,
                ),
              ),
              child: const Icon(Icons.verified, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 24),
            Text(
              'Abonnement activé  avec succès !',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: const Color(0xFF1C1B1B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Bienvenu dans votre espace personnel',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                fontSize: 15,
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal de paiement : sélection de la méthode (Wave, Orange Money, Carte).
class _PaiementModal extends StatefulWidget {
  final String nomPack;
  final String prix;
  final bool isAnnuel;

  const _PaiementModal({required this.nomPack, required this.prix, required this.isAnnuel});

  @override
  State<_PaiementModal> createState() => _PaiementModalState();
}

class _PaiementModalState extends State<_PaiementModal> {
  int _selected = 0;

  final _methodes = [
    {'label': 'Wave', 'image': 'assets/images/wave.png'},
    {'label': 'Orange Money', 'image': 'assets/images/om.png'},
    {'label': 'Carte bancaire', 'image': 'assets/images/carte bancaire.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Finaliser le paiement',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: const Color(0xFF1C1B1B),
            ),
          ),
          const SizedBox(height: 16),
          // Résumé pack
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6F675E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/pack.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pack ${widget.nomPack}',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: const Color(0xFF1C1B1B)),
                      ),
                      Text(
                        'Facturation ${widget.isAnnuel ? 'annuelle' : 'mensuel'}',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 13, color: const Color(0xFF696159)),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${widget.prix} FCFA',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: const Color(0xFF1C1B1B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Info box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Effectuez le paiement via Wave, Orange Money ou carte bancaire. Votre abonnement sera activé immédiatement.',
              style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14, color: const Color(0xFF696159), height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          // Méthodes de paiement
          ..._methodes.asMap().entries.map((e) {
            final i = e.key;
            final m = e.value;
            final bool sel = _selected == i;
            return GestureDetector(
              onTap: () => setState(() => _selected = i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel ? const Color(0xFFF9C20A) : const Color(0x806B7280),
                    width: sel ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(m['image']!, width: 40, height: 40, fit: BoxFit.contain),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        m['label']!,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, color: const Color(0xFF1C1B1B)),
                      ),
                    ),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: sel ? const Color(0xFFF9C20A) : const Color(0xFF9E9E9E),
                          width: sel ? 2 : 1.5,
                        ),
                      ),
                      child: sel
                          ? Center(
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFF9C20A),
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          // Bouton confirmer
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const _AbonnementSuccessPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF9C20A),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Confirmer et payer',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    'assets/icons/right.svg',
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 14, color: Color(0xFF9E9E9E)),
              const SizedBox(width: 6),
              Text(
                'Paiement 100% sécurisé',
                style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 13, color: const Color(0xFF9E9E9E)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
