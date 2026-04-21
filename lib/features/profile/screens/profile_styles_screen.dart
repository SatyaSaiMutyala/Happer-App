import 'package:flutter/material.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:happer_app/features/profile/screens/liked_images_screen.dart';
import 'package:happer_app/features/profile/screens/my_images_screen.dart'; // Add import for MyImagesScreen
import 'package:happer_app/l10n/app_localizations.dart';

class StylesScreen extends StatelessWidget {
  const StylesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HapperAppBar(title: AppLocalizations.of(context).mesLooksTitle),
      body: SafeArea(
        child: Column(
          children: [
            const Divider(height: 1),
            _buildListTile(
              title: AppLocalizations.of(context).mesLooksTitle,
              icon: Image.asset('assets/images/myimages.png', width: 24, height: 24),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const MyImagesScreen()),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
            ),
            _buildListTile(
              title: AppLocalizations.of(context).mesFavorisTitle,
              icon: Image.asset('assets/images/likedimages.png', width: 24, height: 24),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => LikedImagesScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({required String title, required Widget icon, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      onTap: onTap,
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Lato',
          fontWeight: FontWeight.w500,
          fontSize: 14,
          height: 1.0,
          letterSpacing: 0.0,
          color: Color(0xFF5C5C5C),
        ),
      ),
      trailing: icon,
    );
  }
}
