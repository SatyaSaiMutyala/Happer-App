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

  /// Every variant id this card can stand for: the entries in `variants` plus
  /// the remaining sizes the API returns under `other_sizes` (keyed
  /// `variant_id`).
  ///
  /// The selfie details screen only puts the *tagged* variant in `variants`, so
  /// scanning that alone missed a different size added from the product details
  /// screen — the card kept showing "Ajouter" for a product already in the cart.
  Iterable<String> _allKnownVariantIds() {
    final ids = <String>{};
    for (final v in (widget.product['variants'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()) {
      final id = v['_id'] as String? ?? '';
      if (id.isNotEmpty) ids.add(id);
    }
    for (final o in (widget.product['other_sizes'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()) {
      final id = o['variant_id'] as String? ?? '';
      if (id.isNotEmpty) ids.add(id);
    }
    return ids;
  }

  // Keeps the card's "in cart" state in sync when the cart changes elsewhere
  // (e.g. the item is removed from the cart screen).
  Worker? _cartWorker;

  @override
  void initState() {
    super.initState();
    _syncFromCart();
    try {
      _cartWorker = ever(
        Get.find<CartController>().cartItemsByVariant,
        (_) {
          if (mounted) setState(_syncFromCart);
        },
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _cartWorker?.dispose();
    super.dispose();
  }

  void _syncFromCart() {
    try {
      final cartCtrl = Get.find<CartController>();
      // Recompute fully so the card reflects both additions and removals made
      // elsewhere. Check the explicitly-chosen variant first (it may not be in
      // widget.product['variants'], which often only holds the linked variant),
      // then fall back to any of the product's known variants.
      String? foundItemId;
      String foundVid = '';

      if (_selectedVariantId.isNotEmpty) {
        final id = cartCtrl.cartItemIdForVariant(_selectedVariantId);
        if (id != null) {
          foundItemId = id;
          foundVid = _selectedVariantId;
        }
      }

      if (foundItemId == null) {
        for (final vid in _allKnownVariantIds()) {
          final existingItemId = cartCtrl.cartItemIdForVariant(vid);
          if (existingItemId != null) {
            foundItemId = existingItemId;
            foundVid = vid;
            break;
          }
        }
      }

      _isInCart = foundItemId != null;
      _cartItemId = foundItemId ?? '';
      if (foundVid.isNotEmpty) _selectedVariantId = foundVid;
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
      // Open the sheet on the same variant/colour shown on this card.
      preselectVariantId: _variantId,
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
              // Re-read the cart on the way back so a product added from the
              // details screen shows as "in cart" here, without depending on
              // that screen having refreshed the controller itself.
            ).then((_) {
              if (!mounted) return;
              Get.find<CartController>().fetchCartItemCount();
            }),
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
                  text: '$compareAtPrice€',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.grey.shade500,
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
                        children: [
                          const Icon(Icons.check,
                              size: 14, color: Colors.black),
                          // scaleDown lets the label shrink on a narrow card
                          // instead of wrapping onto a second line. maxLines/
                          // softWrap keep it on one line no matter the width,
                          // and the quantity can grow to two digits safely.
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                                child: Text(
                                  'Au panier ($_quantity)',
                                  maxLines: 1,
                                  softWrap: false,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _handleRemove,
                            // The icon alone is a 14px target; opaque hit
                            // testing makes the whole slot tappable.
                            behavior: HitTestBehavior.opaque,
                            child: const Icon(Icons.delete_outline,
                                size: 14, color: Colors.black),
                          ),
                        ],
                      ),
                    )
                  : GestureDetector(
                      onTap: canAdd ? _handleAdd : null,
                      child: _buttonShell(
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 14, color: Colors.black),
                              SizedBox(width: 4),
                              Text(
                                'Ajouter',
                                maxLines: 1,
                                softWrap: false,
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
                    ),
        ],
      ),
    );
  }

  Widget _buttonShell({Widget? child, VoidCallback? onTap}) {
    return Container(
      width: widget.cardWidth,
      // Fixed height so the button keeps its shape whatever it holds. It used
      // to size to its content, so as soon as the label wrapped — which it did
      // on narrow cards — the button grew a second line and the card jumped.
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black87),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(child: child),
    );
  }
}
