import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/app_manager.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/features/dashboard/screens/cart_screen.dart';
import 'package:happer_app/shared/controllers/cart_controller.dart';

class CartPreviewPill extends StatelessWidget {
  const CartPreviewPill({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();

    return Obx(() {
      if (cart.cartItemCount.value == 0) return const SizedBox.shrink();

      final images = cart.previewImageUrls;
      final imageCount = images.length.clamp(1, 3);
      const double iconSize = 54.0;
      const double iconStep = 34.0;
      final stackWidth = iconSize + (imageCount - 1) * iconStep;

      return GestureDetector(
        onTap: () {
          if (AppManager.isLoginAsGuest) {
            showAppSnackBar(
              'Veuillez vous connecter pour accéder au panier',
              isSuccess: false,
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CartScreen()),
          ).then((_) => cart.fetchCartItemCount());
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
          child: Align(
            alignment: Alignment.center,
            heightFactor: 1.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  height: 59,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0x3DCECECE),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4), width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x40000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: stackWidth,
                        height: iconSize,
                        child: Stack(
                          children: [
                            for (int i = 0; i < imageCount; i++)
                              Positioned(
                                left: i * iconStep,
                                child: Container(
                                  width: iconSize,
                                  height: iconSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 1.5),
                                    color: Colors.grey.shade200,
                                  ),
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: images[i],
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => const Icon(
                                        Icons.image_outlined,
                                        size: 24,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Voir le panier',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              height: 1.0,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${cart.cartItemCount.value} article${cart.cartItemCount.value > 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                              height: 1.0,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
