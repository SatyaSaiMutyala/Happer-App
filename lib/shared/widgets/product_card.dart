import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/features/creator/screens/product_details_screen.dart';
import 'package:happer_app/shared/controllers/cart_controller.dart';
import 'package:happer_app/shared/widgets/product_options_sheet.dart';
import 'package:shimmer/shimmer.dart';

class ProductCard extends StatefulWidget {
  final Map<String, dynamic> product;
  final double cardWidth;
  final String affiliateId;

  /// Called when the user taps "Ajouter". Should return the cart item _id on
  /// success, or null if the add failed (card stays in "not in cart" state).
  final Future<String?> Function()? onAddToCart;

  /// Called when the user taps the trash icon. Receives the cart item _id.
  final Future<void> Function(String cartItemId)? onRemoveFromCart;

  const ProductCard({
    super.key,
    required this.product,
    this.cardWidth = 125,
    this.affiliateId = '',
    this.onAddToCart,
    this.onRemoveFromCart,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isRemoving = false;
  bool _isInCart = false;
  int _quantity = 1;
  String _cartItemId = '';
  // The variant actually added to the cart (chosen in the options sheet).
  String _selectedVariantId = '';

  String get _variantId {
    final variants = widget.product['variants'] as List<dynamic>? ?? [];
    if (variants.isEmpty) return '';
    final variant = variants.first as Map<String, dynamic>;
    return variant['_id'] as String? ?? '';
  }

  @override
  void initState() {
    super.initState();
    _syncFromCart();
  }

  void _syncFromCart() {
    final variants = widget.product['variants'] as List<dynamic>? ?? [];
    try {
      final cartCtrl = Get.find<CartController>();
      // Any variant of this product already in the cart marks the card "added".
      for (final v in variants.whereType<Map<String, dynamic>>()) {
        final vid = v['_id'] as String? ?? '';
        if (vid.isEmpty) continue;
        final existingItemId = cartCtrl.cartItemIdForVariant(vid);
        if (existingItemId != null) {
          _isInCart = true;
          _cartItemId = existingItemId;
          _selectedVariantId = vid;
          break;
        }
      }
    } catch (_) {}
  }

  // Opens the options sheet (size / color / quantity). The sheet performs the
  // add-to-cart itself and returns the chosen variant on success.
  Future<void> _handleAdd() async {
    if (_isRemoving) return;
    final result = await showProductOptionsSheet(
      context,
      product: widget.product,
      affiliateId: widget.affiliateId,
    );
    if (!mounted || result == null) return;
    setState(() {
      _isInCart = true;
      _cartItemId = result.cartItemId;
      _selectedVariantId = result.variantId;
      _quantity = result.quantity;
    });
  }

  Future<void> _handleRemove() async {
    if (_isRemoving || widget.onRemoveFromCart == null || _cartItemId.isEmpty)
      return;
    setState(() => _isRemoving = true);
    try {
      await widget.onRemoveFromCart!(_cartItemId);
      try {
        final vId =
            _selectedVariantId.isNotEmpty ? _selectedVariantId : _variantId;
        Get.find<CartController>().markVariantRemoved(vId);
      } catch (_) {}
      if (mounted) {
        setState(() {
          _isInCart = false;
          _cartItemId = '';
          _quantity = 1;
        });
      }
    } finally {
      if (mounted) setState(() => _isRemoving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productId = widget.product['_id'] as String? ?? '';
    final name = widget.product['name'] as String? ?? '';
    final brandData = widget.product['brand_id'];
    final brandLogoUrl =
        brandData is Map ? (brandData['picture'] as String? ?? '') : '';
    final variants = widget.product['variants'] as List<dynamic>? ?? [];
    final variant = variants.isNotEmpty
        ? variants.first as Map<String, dynamic>
        : <String, dynamic>{};
    final variantId = variant['_id'] as String? ?? '';
    final variantImages =
        (variant['images'] as List<dynamic>? ?? []).cast<String>();
    final price = (variant['price'] as num?)?.toInt() ?? 0;
    final compareAtPriceRaw = variant['compare_at_price'];
    final compareAtPrice = compareAtPriceRaw is num
        ? compareAtPriceRaw.toInt()
        : (compareAtPriceRaw is String
            ? int.tryParse(compareAtPriceRaw)
            : null);
    final imageHeight = widget.cardWidth * (180 / 125);

    String imageUrl =
        variantImages.isNotEmpty ? variantImages.first.trim() : '';
    if (imageUrl.isEmpty)
      imageUrl = (widget.product['product_image'] as String? ?? '').trim();

    // The options sheet handles the actual add, so a valid product is enough.
    final canAdd = productId.isNotEmpty && variantId.isNotEmpty;

    return SizedBox(
      width: widget.cardWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ──────────────────────────────────────────────────────────
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailsScreen(
                  itemId: productId,
                  userId: widget.affiliateId,
                  initialData: widget.product,
                ),
              ),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          height: imageHeight,
                          width: widget.cardWidth,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                                height: imageHeight,
                                width: widget.cardWidth,
                                color: Colors.white),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            height: imageHeight,
                            width: widget.cardWidth,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image,
                                size: 40, color: Colors.grey),
                          ),
                        )
                      : Container(
                          height: imageHeight,
                          width: widget.cardWidth,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image,
                              size: 40, color: Colors.grey),
                        ),
                ),
                if (brandLogoUrl.isNotEmpty)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      height: 32,
                      width: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(1, 1))
                        ],
                      ),
                      padding: const EdgeInsets.all(4),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: brandLogoUrl,
                          fit: BoxFit.contain,
                          placeholder: (_, __) =>
                              Container(color: Colors.grey.shade200),
                          errorWidget: (_, __, ___) => const Icon(Icons.store,
                              size: 16, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // ── Name ───────────────────────────────────────────────────────────
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w500,
              fontSize: 13,
              height: 1.3,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 2),

          // ── Price ──────────────────────────────────────────────────────────
          if (compareAtPrice != null && compareAtPrice > price)
            RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(children: [
                TextSpan(
                  text: '$price€ ',
                  style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.black),
                ),
                TextSpan(
                  text: '$compareAtPrice€ ',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.grey.shade500,
                  ),
                ),
                TextSpan(
                  text:
                      '-${(((compareAtPrice - price) / compareAtPrice) * 100).round()}%',
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFFE53935),
                  ),
                ),
              ]),
            )
          else
            Text(
              '$price€',
              style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.black),
            ),

          const SizedBox(height: 6),

          // ── Button ─────────────────────────────────────────────────────────
          _isRemoving
              ? _buttonShell(
                  child: const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation(Colors.black)),
                ))
              : _isInCart
                  ? _buttonShell(
                      onTap: null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.check,
                              size: 14, color: Colors.black),
                          Expanded(
                            child: Text(
                              'Au panier ($_quantity)',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _handleRemove,
                            child: const Icon(Icons.delete_outline,
                                size: 14, color: Colors.black),
                          ),
                        ],
                      ),
                    )
                  : GestureDetector(
                      onTap: canAdd ? _handleAdd : null,
                      child: _buttonShell(
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 14, color: Colors.black),
                            SizedBox(width: 4),
                            Text(
                              'Ajouter',
                              style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buttonShell({Widget? child, VoidCallback? onTap}) {
    return Container(
      width: widget.cardWidth,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black87),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(child: child),
    );
  }
}
