import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/profile/ui/my_purchases_screen.dart';
import 'package:happer_app/profile/ui/return_refund_screen.dart';
import 'package:happer_app/profile/ui/wishlist_screen.dart';
import 'package:happer_app/profile/ui/won_products_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'MY ORDERS',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            height:
                1.0, // line-height: 100% in Flutter is represented as height = 1.0
            letterSpacing: 0.0,
            textBaseline: TextBaseline.alphabetic, // Ensures proper alignment
          ),
          textAlign: TextAlign.center, // Aligns text to the center
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0, // Removes bottom shadow line
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Divider(height: 1),
            _buildListTile(context, title: 'My Purchases', icon: Icon(Icons.shopping_bag, color: Colors.grey)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const Divider(height: 1),
            ),
            
           
            _buildListTile(context, title: 'Return and Refund', icon: SvgPicture.asset('assets/images/return_svg.svg', width: 24, height: 24)), ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, {required String title, required Widget icon}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      onTap: () {
        if (title == 'My Purchases') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyPurchasesScreen()),
          );
        } 
        else if(title == 'Return and Refund'){
          Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReturnRefundScreen(),
                      ),
                    );
        }
      },
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
      trailing: icon,
    );
  }
}
