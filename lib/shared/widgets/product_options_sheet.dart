import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/app_manager.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/features/creator/bindings/creator_binding.dart';
import 'package:happer_app/features/creator/data/repositories/creator_repository.dart';
import 'package:happer_app/features/dashboard/bindings/cart_binding.dart';
import 'package:happer_app/features/dashboard/data/repositories/cart_repository.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/shared/controllers/cart_controller.dart';
import 'package:shimmer/shimmer.dart';

/// Result returned when an item is successfully added to the cart from the
/// options sheet.
class ProductSheetResult {
  final String variantId;
  final String cartItemId;
  final int quantity;

  const ProductSheetResult({
    required this.variantId,
    required this.cartItemId,
    required this.quantity,
  });
}

/// Opens the "choose size / color / quantity" bottom sheet for a product and
/// returns a [ProductSheetResult] when the item was added to the cart, or
/// `null` if the sheet was dismissed without adding.
Future<ProductSheetResult?> showProductOptionsSheet(
  BuildContext context, {
  required Map<String, dynamic> product,
  String affiliateId = '',
}) {
  return showModalBottomSheet<ProductSheetResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ProductOptionsSheet(
      product: product,
      affiliateId: affiliateId,
    ),
  );
}

// Each API variant = one specific Color+Size combination with its own
// price / images / quantity (stock).
class _Variant {
  final String id;
  final List<String> images;
  final double price;
  final String color;
  final String size;
  final int quantity;

  _Variant({
    required this.id,
    required this.images,
    required this.price,
    required this.color,
    required this.size,
    required this.quantity,
  });

  factory _Variant.fromJson(Map<String, dynamic> json) {
    final options = (json['option_ids'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final color = options
            .where((o) => o['name'] == 'Color')
            .map((o) => o['value'] as String? ?? '')
            .firstOrNull ??
        '';
    final size = options
            .where((o) => o['name'] == 'Size')
            .map((o) => o['value'] as String? ?? '')
            .firstOrNull ??
        '';
    return _Variant(
      id: json['_id'] as String? ?? '',
      images: (json['images'] as List<dynamic>? ?? [])
          .whereType<String>()
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      color: color,
      size: size,
      quantity: json['quantity'] as int? ?? 0,
    );
  }
}

class _ProductOptionsSheet extends StatefulWidget {
  final Map<String, dynamic> product;
  final String affiliateId;

  const _ProductOptionsSheet({required this.product, this.affiliateId = ''});

  @override
  State<_ProductOptionsSheet> createState() => _ProductOptionsSheetState();
}

class _ProductOptionsSheetState extends State<_ProductOptionsSheet> {
  bool _isLoading = true;
  bool _isAdding = false;

  String _productName = '';
  String _brandName = '';
  String _brandId = '';
  String _productImage = '';
  List<_Variant> _allVariants = [];
  String _selectedColor = '';
  String? _selectedSize;
  int _quantity = 1;

  static const Map<String, Color> _colorMap = {
    'black': Colors.black,
    'white': Colors.white,
    'blue': Color(0xFF0000FF),
    'navy': Color(0xFF001F5B),
    'gray': Color(0xFF5A5A5A),
    'grey': Color(0xFF5A5A5A),
    'gold': Color(0xFFD4AF37),
    'red': Colors.red,
    'green': Colors.green,
    'yellow': Colors.yellow,
    'orange': Colors.orange,
    'purple': Colors.purple,
    'pink': Colors.pink,
    'brown': Colors.brown,
    'beige': Color(0xFFF5F0DC),
  };

  String get _productId => widget.product['_id'] as String? ?? '';

  @override
  void initState() {
    super.initState();
    _productImage = (widget.product['product_image'] as String? ?? '').trim();
    _fetchDetails();
  }

  // ── Derived selectors ───────────────────────────────────────────────────
  List<String> get _distinctColors {
    final seen = <String>{};
    return _allVariants
        .map((v) => v.color)
        .where((c) => c.isNotEmpty && seen.add(c))
        .toList();
  }

  bool get _hasColors => _distinctColors.isNotEmpty;

  // Sizes shown depend on the selected color (when colors exist).
  List<_Variant> get _variantsForSelection => _hasColors
      ? _allVariants.where((v) => v.color == _selectedColor).toList()
      : _allVariants;

  _Variant? get _selectedVariant {
    if (_selectedSize == null) {
      // No size dimension at all → a color (or single) variant is enough.
      final pool = _variantsForSelection;
      final hasSizes = pool.any((v) => v.size.isNotEmpty);
      if (!hasSizes) return pool.firstOrNull;
      return null;
    }
    return _variantsForSelection
        .where((v) => v.size == _selectedSize)
        .firstOrNull;
  }

  double get _displayPrice {
    final sv = _selectedVariant;
    if (sv != null) return sv.price;
    final pool = _variantsForSelection;
    if (pool.isNotEmpty) return pool.first.price;
    if (_allVariants.isNotEmpty) return _allVariants.first.price;
    return 0;
  }

  int get _maxQuantity {
    final sv = _selectedVariant;
    return (sv?.quantity ?? 0).clamp(0, 99);
  }

  bool get _canAdd => _selectedVariant != null && _maxQuantity > 0;

  String get _displayImage {
    final sv = _selectedVariant;
    if (sv != null && sv.images.isNotEmpty) return sv.images.first;
    final pool = _variantsForSelection;
    if (pool.isNotEmpty && pool.first.images.isNotEmpty) {
      return pool.first.images.first;
    }
    if (_allVariants.isNotEmpty && _allVariants.first.images.isNotEmpty) {
      return _allVariants.first.images.first;
    }
    return _productImage;
  }

  // ── Data ────────────────────────────────────────────────────────────────
  Future<void> _fetchDetails() async {
    try {
      CreatorBinding().dependencies();
      final repo = Get.find<CreatorRepository>();
      final data = await repo.getProductDetail(_productId);
      if (!mounted) return;
      final brandRaw = data['brand_id'];
      final variants = (data['variants'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(_Variant.fromJson)
          .toList();
      setState(() {
        _productName = data['name'] as String? ?? '';
        _brandName = brandRaw is Map ? (brandRaw['name'] as String? ?? '') : '';
        _brandId = brandRaw is Map
            ? (brandRaw['_id'] as String? ?? '')
            : (brandRaw as String? ?? '');
        _allVariants = variants;
        _selectedColor = variants.isNotEmpty ? variants.first.color : '';
        _selectedSize = null;
        _quantity = 1;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showAppSnackBar(e.toString(), isSuccess: false);
      }
    }
  }

  Future<void> _addToCart() async {
    final variant = _selectedVariant;
    if (variant == null || _isAdding) return;
    if (AppManager.isLoginAsGuest) {
      showAppSnackBar(AppLocalizations.of(context).loginToAddToCart,
          isSuccess: false);
      return;
    }
    setState(() => _isAdding = true);
    try {
      CartBinding().dependencies();
      final repo = Get.find<CartRepository>();
      final affiliateId =
          widget.affiliateId.isNotEmpty ? widget.affiliateId : _brandId;
      final cartItemId = await repo.addToCart(
        productId: _productId,
        variantId: variant.id,
        affiliateId: affiliateId,
        quantity: _quantity,
      );
      if (!mounted) return;
      try {
        if (cartItemId != null) {
          Get.find<CartController>().markVariantAdded(variant.id, cartItemId);
        }
        Get.find<CartController>().fetchCartItemCount();
      } catch (_) {}
      showAppSnackBar('Produit ajouté au panier', isSuccess: true);
      Navigator.pop(
        context,
        ProductSheetResult(
          variantId: variant.id,
          cartItemId: cartItemId ?? '',
          quantity: _quantity,
        ),
      );
    } catch (e) {
      if (mounted) showAppSnackBar(e.toString(), isSuccess: false);
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Color _colorFromName(String colorName) {
    final key = colorName.split('/').first.trim().toLowerCase();
    return _colorMap[key] ?? Colors.grey.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? _buildShimmer()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: _buildContent(),
                    ),
            ),
            if (!_isLoading) _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // ── Content ───────────────────────────────────────────────────────────
  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: thumbnail + name/brand/price + close
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 72,
                height: 88,
                child: _displayImage.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: _displayImage,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: Colors.grey.shade200),
                        errorWidget: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_brandName.isNotEmpty)
                    Text(
                      _brandName.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.8,
                        color: Color(0xFF8D8D8D),
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    _productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      height: 1.25,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_displayPrice.round()}€',
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.black87),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Colors
        if (_hasColors) ...[
          _sectionTitle('COULEUR'),
          const SizedBox(height: 12),
          _buildColorSelector(),
          const SizedBox(height: 22),
        ],

        // Sizes (only if any variant carries a size value)
        if (_variantsForSelection.any((v) => v.size.isNotEmpty)) ...[
          _sectionTitle('TAILLE'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _variantsForSelection
                .where((v) => v.size.isNotEmpty)
                .map((v) => _buildSizeChip(v.size, v.quantity))
                .toList(),
          ),
          const SizedBox(height: 22),
        ],

        // Quantity
        _sectionTitle('QUANTITÉ'),
        const SizedBox(height: 12),
        _buildQuantityStepper(),
        const SizedBox(height: 10),
        _buildStockHint(),
      ],
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
          fontFamily: 'Lato',
          fontWeight: FontWeight.w800,
          fontSize: 14,
          letterSpacing: 0.8,
          color: Colors.black,
        ),
      );

  Widget _buildColorSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _distinctColors.map((color) {
        final colorValue = _colorFromName(color);
        final isSelected = _selectedColor == color;
        final isLight = colorValue == Colors.white ||
            colorValue == const Color(0xFFD4AF37) ||
            colorValue == const Color(0xFFF5F0DC) ||
            colorValue == Colors.yellow;
        return GestureDetector(
          onTap: () => setState(() {
            _selectedColor = color;
            _selectedSize = null;
            _quantity = 1;
          }),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorValue,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isSelected
                    ? Icon(Icons.check,
                        color: isLight ? Colors.black : Colors.white, size: 20)
                    : null,
              ),
              const SizedBox(height: 5),
              Text(
                color.split('/').first.trim(),
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 11,
                  color: Color(0xFF8D8D8D),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSizeChip(String size, int quantity) {
    final isAvailable = quantity > 0;
    final isSelected = _selectedSize == size;
    return ChoiceChip(
      label: Text(
        size,
        style: TextStyle(
          fontFamily: 'Lato',
          color: isSelected
              ? Colors.white
              : (isAvailable ? Colors.black : Colors.grey),
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      onSelected: isAvailable
          ? (sel) => setState(() {
                _selectedSize = sel ? size : null;
                _quantity = 1;
              })
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isAvailable ? Colors.black : Colors.grey.shade300),
      ),
      backgroundColor: Colors.white,
      selectedColor: Colors.black,
      showCheckmark: false,
    );
  }

  Widget _buildQuantityStepper() {
    final canDecrement = _canAdd && _quantity > 1;
    final canIncrement = _canAdd && _quantity < _maxQuantity;
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black87),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              _stepperButton(
                icon: Icons.remove,
                enabled: canDecrement,
                onTap: () => setState(() => _quantity--),
              ),
              SizedBox(
                width: 44,
                child: Text(
                  '$_quantity',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              _stepperButton(
                icon: Icons.add,
                enabled: canIncrement,
                onTap: () => setState(() => _quantity++),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepperButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? Colors.black : Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildStockHint() {
    if (!_canAdd) {
      final needsSize =
          _variantsForSelection.any((v) => v.size.isNotEmpty) &&
              _selectedSize == null;
      return Text(
        needsSize
            ? 'Sélectionnez une taille'
            : (_selectedVariant != null
                ? 'Rupture de stock'
                : 'Sélectionnez vos options'),
        style: const TextStyle(
          fontFamily: 'Lato',
          fontSize: 12,
          color: Color(0xFF8D8D8D),
        ),
      );
    }
    return Text(
      '$_maxQuantity en stock',
      style: const TextStyle(
        fontFamily: 'Lato',
        fontSize: 12,
        color: Color(0xFF8D8D8D),
      ),
    );
  }

  // ── Bottom bar ──────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: GestureDetector(
          onTap: _canAdd && !_isAdding ? _addToCart : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 54,
            decoration: BoxDecoration(
              color: _canAdd ? Colors.black : const Color(0xFFCCCCCC),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: _isAdding
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined,
                          size: 18,
                          color: _canAdd ? Colors.white : Colors.white70),
                      const SizedBox(width: 8),
                      Text(
                        'AJOUTER AU PANIER',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 1.2,
                          color: _canAdd ? Colors.white : Colors.white70,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 11, width: 90, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(
                          height: 15, width: double.infinity, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(height: 18, width: 70, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(height: 14, width: 90, color: Colors.white),
            const SizedBox(height: 12),
            Row(
              children: List.generate(
                4,
                (_) => Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 40,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(height: 14, width: 70, color: Colors.white),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(
                5,
                (_) => Container(
                  width: 52,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
