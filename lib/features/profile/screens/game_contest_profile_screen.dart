import 'package:flutter/material.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:happer_app/features/profile/screens/code_credit_screen.dart';
import 'package:happer_app/features/profile/screens/wishlist_screen.dart';
import 'package:happer_app/features/profile/screens/won_products_screen.dart';
import 'package:happer_app/l10n/app_localizations.dart';

class GameContestProfileScreen extends StatefulWidget {
  const GameContestProfileScreen({super.key});

  @override
  State<GameContestProfileScreen> createState() => _GameContestProfileScreenState();
}

class _GameContestProfileScreenState extends State<GameContestProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HapperAppBar(title: AppLocalizations.of(context).gameContestTitle),
      body: SafeArea(
        child: Column(
          children: [
            const Divider(height: 1),
            _buildListTile(
              title: 'Won Products',
              icon: Image.asset('assets/images/wonproducts.png', width: 24, height: 24),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const WonProductsScreen()),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const Divider(height: 1),
            ),
            _buildListTile(
              title: 'Wishlist',
              icon: Image.asset('assets/images/wishlist.png', width: 24, height: 24),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => WishlistScreen()),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const Divider(height: 1),
            ),
            _buildListTile(
              title: 'Referral Code',
              icon: SvgPicture.asset('assets/images/code_svg.svg', width: 24, height: 24),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CodeCreditScreen()),
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