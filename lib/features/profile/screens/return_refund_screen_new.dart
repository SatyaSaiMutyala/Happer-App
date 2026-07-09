import 'package:flutter/material.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

/// "CONTACTER LE SUPPORT" — support entry point with FAQ, WhatsApp and email
/// contact options.
class ReturnRefundScreen extends StatelessWidget {
  const ReturnRefundScreen({super.key});

  // Support contact details.
  static const _supportEmail = 'support@happer.fr';
  // TODO: replace with the real WhatsApp business number and FAQ URL.
  static const _whatsappNumber = '33600000000';
  static const _faqUrl = 'https://happer.fr/faq';

  Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _sendEmail() => _launch(Uri(
        scheme: 'mailto',
        path: _supportEmail,
        queryParameters: {'subject': 'Demande de support'},
      ));

  Future<void> _openWhatsApp() =>
      _launch(Uri.parse('https://wa.me/$_whatsappNumber'));

  Future<void> _openFaq() => _launch(Uri.parse(_faqUrl));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const HapperAppBar(title: 'CONTACTER LE SUPPORT'),
      body: Column(
        children: [
          const SizedBox(height: 24),
          const Text(
            'Procédure',
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          const SizedBox(height: 28),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Pour toute question, besoin ou disfonctionnalité rencontré, merci de contacter le service client via $_supportEmail.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 16,
                height: 1.5,
                color: Color(0xFF6B6B6B),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Les délais de réponses sont en moyenne de 72h.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 16,
                height: 1.5,
                color: Color(0xFF6B6B6B),
              ),
            ),
          ),
          const Spacer(),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                children: [
                  // FAQ (outlined)
                  _supportButton(
                    label: 'CONSULTER LA FAQ',
                    icon: Icons.quiz_outlined,
                    onTap: _openFaq,
                    background: Colors.white,
                    foreground: Colors.black,
                    border: const Color(0xFF1A1A1A),
                  ),
                  const SizedBox(height: 12),
                  // WhatsApp (green)
                  _supportButton(
                    label: 'CONTACTER PAR WHATSAPP',
                    icon: Icons.chat,
                    onTap: _openWhatsApp,
                    background: const Color(0xFF32C25A),
                    foreground: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  // Email (black)
                  _supportButton(
                    label: 'CONTACTER PAR E-MAIL',
                    icon: Icons.mail_outline,
                    onTap: _sendEmail,
                    background: Colors.black,
                    foreground: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _supportButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required Color background,
    required Color foreground,
    Color? border,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
          border: border != null ? Border.all(color: border, width: 1.5) : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 20,
              child: Icon(icon, color: foreground, size: 22),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 0.3,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
