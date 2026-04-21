import 'package:flutter/material.dart';
import 'package:happer_app/app_manager.dart';
import 'package:happer_app/features/dashboard/screens/cart_screen.dart';
import 'package:happer_app/core/utils/snackbar.dart';

class CartIconButton extends StatelessWidget {
  final int cartItemCount;
  final VoidCallback? onNavigateBack;

  const CartIconButton({
    super.key,
    required this.cartItemCount,
    this.onNavigateBack,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (AppManager.isLoginAsGuest) {
          showAppSnackBar('Please Login to access Cart', isSuccess: false);
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CartScreen()),
        ).then((_) => onNavigateBack?.call());
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset('assets/images/b3bag.png', width: 24, height: 24, color: Colors.black),
            if (cartItemCount > 0)
              Positioned(
                top: 0,
                right: -1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                  child: Text(
                    '$cartItemCount',
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
