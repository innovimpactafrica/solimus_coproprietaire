import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

/// Page d'initiation et de suivi du paiement TouchPay.
/// Ouvre le guichet de paiement directement dans le navigateur mobile natif (Chrome / Safari),
/// garantissant un fonctionnement 100 % identique à Swagger et la préservation
/// des cookies et callbacks de session.
class TouchPayWebViewPage extends StatefulWidget {
  final String url;
  const TouchPayWebViewPage({super.key, required this.url});

  @override
  State<TouchPayWebViewPage> createState() => _TouchPayWebViewPageState();
}

class _TouchPayWebViewPageState extends State<TouchPayWebViewPage> {
  bool _browserOpened = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _openNativeBrowser();
  }

  Future<void> _openNativeBrowser() async {
    final uri = Uri.parse(widget.url);
    setState(() { _errorMessage = null; _browserOpened = false; });
    
    try {
      // First check if URL can be launched
      final canLaunch = await canLaunchUrl(uri);
      
      if (canLaunch) {
        // Try external application mode first (opens in separate browser)
        final launched = await launchUrl(
          uri, 
          mode: LaunchMode.externalApplication,
        );
        
        if (launched) {
          if (mounted) setState(() => _browserOpened = true);
        } else {
          // Fallback to platform default mode
          final fallbackLaunched = await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
          
          if (fallbackLaunched) {
            if (mounted) setState(() => _browserOpened = true);
          } else {
            if (mounted) {
              setState(() => _errorMessage = 'Impossible d\'ouvrir le navigateur. Veuillez vérifier qu\'un navigateur est installé sur votre appareil.');
            }
          }
        }
      } else {
        // canLaunchUrl returned false - try anyway with platform default as last resort
        try {
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
          if (launched) {
            if (mounted) setState(() => _browserOpened = true);
          } else {
            if (mounted) {
              setState(() => _errorMessage = 'Aucun navigateur disponible pour ouvrir le lien de paiement.');
            }
          }
        } catch (e) {
          if (mounted) {
            setState(() => _errorMessage = 'Impossible d\'ouvrir le navigateur : $e');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Erreur lors de l\'ouverture du navigateur : $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6F675E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Text(
          'Paiement TouchPay',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0x1A6F675E),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.open_in_browser_rounded,
                    color: Color(0xFF6F675E),
                    size: 44,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 32),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.5,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Appuyez sur le bouton ci-dessous pour réessayer d\'ouvrir le navigateur.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.5,
                    color: const Color(0xFF6A7282),
                  ),
                ),
              ] else if (_browserOpened) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFFFF6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00A63E).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Color(0xFF00A63E), size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Le portail TouchPay / Wave a été ouvert dans votre navigateur.\n\nEffectuez le prélèvement sur Wave puis revenez sur l\'application pour valider.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.5,
                          color: const Color(0xFF00A63E),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const CircularProgressIndicator(color: Color(0xFF6F675E)),
                const SizedBox(height: 16),
                Text(
                  'Ouverture du navigateur de paiement...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.5,
                    color: const Color(0xFF6A7282),
                  ),
                ),
              ],
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                label: Text(
                  'J\'ai effectué le paiement',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A63E),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _openNativeBrowser,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  'Réouvrir la page de paiement',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6F675E),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  side: const BorderSide(color: Color(0xFFD6D2C9)),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Annuler',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF8B7355),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
