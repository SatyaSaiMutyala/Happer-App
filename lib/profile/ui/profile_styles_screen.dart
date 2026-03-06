import 'package:flutter/material.dart';
import 'package:happer_app/profile/ui/liked_images_screen.dart';
import 'package:happer_app/profile/ui/my_images_screen.dart'; // Add import for MyImagesScreen

class StylesScreen extends StatelessWidget {
  const StylesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'MES LOOKS',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            height: 1.0,
            letterSpacing: 0.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Divider(height: 1),
            _buildListTile(
              title: 'Mes looks',
              icon: Image.asset('assets/images/myimages.png', width: 24, height: 24),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const MyImagesScreen()),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const Divider(height: 1),
            ),
            _buildListTile(
              title: 'Mes favoris',
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      onTap: onTap,
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Lato',
          fontWeight: FontWeight.w500,
          fontSize: 14,
          height:
              1.0, // line-height: 100% in Flutter is represented as height = 1.0
          letterSpacing: 0.0,
          color: Color(0xFF5C5C5C), // Updated text color
        ),
      ),
      trailing:icon,
    );
  }
}
