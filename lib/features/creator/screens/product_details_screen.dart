import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/app_manager.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/features/creator/bindings/creator_binding.dart';
import 'package:happer_app/features/creator/controllers/product_like_controller.dart';
import 'package:happer_app/features/creator/data/repositories/creator_repository.dart';
import 'package:happer_app/features/dashboard/bindings/cart_binding.dart';
import 'package:happer_app/features/dashboard/data/repositories/cart_repository.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:happer_app/shared/controllers/cart_controller.dart';
import 'package:happer_app/shared/widgets/cart_preview_pill.dart';
import 'package:happer_app/features/dashboard/screens/cart_screen.dart';

// Each API variant = one specific Color+Size combination with its own price/images/quantity.
class _Variant {
  final String id;
  final List<String> images;
  final double price;
  final double? compareAtPrice;
  final String color;
  final String size;
  final int quantity;

  _Variant({
    required this.id,
    required this.images,
    required this.price,
    required this.compareAtPrice,
    required this.color,
    required this.size,
    required this.quantity,
  });

  factory _Variant.fromJson(Map<String, dynamic> json) {
    final options = (json['option_ids'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
    // Match option names the same way the backend does — case-insensitive and
    // both EN/FR ("Color"/"Couleur", "Size"/"Taille") — so products whose
    // options use French names (e.g. pure cachemire) still show colours/sizes.
    String optionValue(bool Function(String) matches) => options
            .where((o) => matches((o['name'] as String? ?? '').trim().toLowerCase()))
            .map((o) => o['value'] as String? ?? '')
            .firstOrNull ??
        '';
    final color = optionValue((n) => n == 'color' || n == 'couleur');
    final size = optionValue((n) => n == 'size' || n == 'taille');
    final compareAtPriceRaw = json['compare_at_price'];
    final compareAtPrice = compareAtPriceRaw is num
        ? compareAtPriceRaw.toDouble()
        : (compareAtPriceRaw is String
            ? double.tryParse(compareAtPriceRaw)
            : null);
    return _Variant(
      id: json['_id'] as String? ?? '',
      images: (json['images'] as List<dynamic>? ?? [])
          .whereType<String>()
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      compareAtPrice: compareAtPrice,
      color: color,
      size: size,
      quantity: json['quantity'] as int? ?? 0,
    );
  }
}

class ProductDetailsScreen extends StatefulWidget {
  final String itemId;
  final String userId;
  final Map<String, dynamic>? initialData;

  const ProductDetailsScreen({
    Key? key,
    required this.itemId,
    required this.userId,
    this.initialData,
  }) : super(key: key);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _isLoading = true;
  bool _isAddingToCart = false;
  String _productName = '';
  String _brandName = '';
  String _brandPicture = '';
  String _brandId = '';
  String _description = '';
  List<_Variant> _allVariants = [];
  String _selectedColor = '';
  String? _selectedSize;
  int _currentPage = 0;
  PageController? _pageController;
  late final ProductLikeController _likeController;

  // Unique colors across all variants, preserving first-seen order.
  List<String> get _distinctColors {
    final seen = <String>{};
    return _allVariants
        .map((v) => v.color)
        .where((c) => c.isNotEmpty && seen.add(c))
        .toList();
  }

  // Variants that match the currently selected color.
  List<_Variant> get _variantsForSelectedColor =>
      _allVariants.where((v) => v.color == _selectedColor).toList();

  // The specific variant matching selected color + size (null until both chosen).
  _Variant? get _selectedVariant => _selectedSize == null
      ? null
      : _allVariants
          .where((v) => v.color == _selectedColor && v.size == _selectedSize)
          .firstOrNull;

  // Images to display: matched variant → any variant for color → first variant.
  List<String> get _displayImages {
    final sv = _selectedVariant;
    if (sv != null && sv.images.isNotEmpty) return sv.images;
    final forColor = _variantsForSelectedColor;
    if (forColor.isNotEmpty && forColor.first.images.isNotEmpty)
      return forColor.first.images;
    if (_allVariants.isNotEmpty) return _allVariants.first.images;
    return [];
  }

  // Price to display: matched variant → first variant for color → first overall.
  double get _displayPrice {
    final sv = _selectedVariant;
    if (sv != null) return sv.price;
    final forColor = _variantsForSelectedColor;
    if (forColor.isNotEmpty) return forColor.first.price;
    if (_allVariants.isNotEmpty) return _allVariants.first.price;
    return 0;
  }

  // Original (struck-through) price, mirroring _displayPrice's fallback chain.
  double? get _displayCompareAtPrice {
    final sv = _selectedVariant;
    if (sv != null) return sv.compareAtPrice;
    final forColor = _variantsForSelectedColor;
    if (forColor.isNotEmpty) return forColor.first.compareAtPrice;
    if (_allVariants.isNotEmpty) return _allVariants.first.compareAtPrice;
    return null;
  }

  // Discount percentage off the original price, rounded — null when there's
  // no compare-at price to discount from.
  int? get _discountPercent {
    final compareAt = _displayCompareAtPrice;
    if (compareAt == null || compareAt <= 0 || compareAt <= _displayPrice) {
      return null;
    }
    return (((compareAt - _displayPrice) / compareAt) * 100).round();
  }

  String _formatPrice(double value) =>
      value.toStringAsFixed(2).replaceAll('.', ',');

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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    CreatorBinding().dependencies();
    _likeController = Get.find<ProductLikeController>();
    // Always fetch from API — initialData may have unpopulated option_ids (string IDs only).
    _fetchProductDetails();
  }

  // The variant the heart applies to: selected variant → first for color →
  // first overall (mirrors the price/image fallback chain).
  String get _currentVariantId {
    final sv = _selectedVariant;
    if (sv != null) return sv.id;
    final forColor = _variantsForSelectedColor;
    if (forColor.isNotEmpty) return forColor.first.id;
    if (_allVariants.isNotEmpty) return _allVariants.first.id;
    return '';
  }

  void _onToggleLike() {
    if (AppManager.isLoginAsGuest) {
      showAppSnackBar(AppLocalizations.of(context).loginToAddToCart,
          isSuccess: false);
      return;
    }
    final variantId = _currentVariantId;
    if (variantId.isEmpty) return;
    _likeController.toggleLike(variantId);
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void _applyData(Map<String, dynamic> data) {
    final brandRaw = data['brand_id'];
    final brandName =
        brandRaw is Map ? (brandRaw['name'] as String? ?? '') : '';
    final brandPicture =
        brandRaw is Map ? (brandRaw['picture'] as String? ?? '') : '';
    final brandId = brandRaw is Map
        ? (brandRaw['_id'] as String? ?? '')
        : (brandRaw as String? ?? '');
    final variants = (data['variants'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(_Variant.fromJson)
        .toList();

    // Pre-select the color of the variant that was linked to the selfie.
    // initialData carries the linked variant's _id — find it in the full list.
    String selectedColor = variants.isNotEmpty ? variants.first.color : '';
    if (widget.initialData != null) {
      final initVariants = widget.initialData!['variants'] as List?;
      final firstVariant = (initVariants != null && initVariants.isNotEmpty)
          ? initVariants.first as Map<String, dynamic>?
          : null;
      final linkedVariantId = firstVariant?['_id'] as String?;
      if (linkedVariantId != null) {
        final matched =
            variants.where((v) => v.id == linkedVariantId).firstOrNull;
        if (matched != null && matched.color.isNotEmpty) {
          selectedColor = matched.color;
        }
      }
    }

    setState(() {
      _productName = data['name'] as String? ?? '';
      _brandName = brandName;
      _brandPicture = brandPicture;
      _brandId = brandId;
      _description = data['description'] as String? ?? '';
      _allVariants = variants;
      _selectedColor = selectedColor;
      _selectedSize = null;
      _isLoading = false;
    });
  }

  Future<void> _addToCart() async {
    final variant = _selectedVariant;
    if (variant == null) return;
    setState(() => _isAddingToCart = true);
    try {
      CartBinding().dependencies();
      final repo = Get.find<CartRepository>();
      // widget.userId is the creator/selfie-poster ID = affiliate_id.
      // Fall back to brand ID when navigating directly from brand screen.
      final affiliateId = widget.userId.isNotEmpty ? widget.userId : _brandId;
      await repo.addToCart(
        productId: widget.itemId,
        variantId: variant.id,
        affiliateId: affiliateId,
        quantity: 1,
      );
      if (!mounted) return;
      Get.find<CartController>().fetchCartItemCount();
      showAppSnackBar('Produit ajouté au panier', isSuccess: true);
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const CartScreen()));
    } catch (e) {
      if (mounted) showAppSnackBar(e.toString(), isSuccess: false);
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

  Future<void> _fetchProductDetails() async {
    try {
      CreatorBinding().dependencies();
      final repo = Get.find<CreatorRepository>();
      final data = await repo.getProductDetail(widget.itemId);
      if (!mounted) return;
      _applyData(data);
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool get _canAddToCart => _selectedVariant != null;

  Color _colorFromName(String colorName) {
    final key = colorName.split('/').first.trim().toLowerCase();
    return _colorMap[key] ?? Colors.grey.shade400;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      appBar: HapperAppBar(title: 'DÉTAILS PRODUIT', actions: const []),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CartPreviewPill(),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _canAddToCart ? Colors.black : Colors.grey.shade300,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _canAddToCart && !_isAddingToCart
                  ? () {
                      if (AppManager.isLoginAsGuest) {
                        showAppSnackBar(
                            AppLocalizations.of(context).loginToAddToCart,
                            isSuccess: false);
                        return;
                      }
                      _addToCart();
                    }
                  : null,
              icon: _isAddingToCart
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.shopping_bag_outlined,
                      color: _canAddToCart ? Colors.white : Colors.black),
              label: Text(
                'AJOUTER AU PANIER',
                style: TextStyle(
                    color: _canAddToCart ? Colors.white : Colors.black),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? _buildShimmer()
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildImageCarousel(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_brandName.isNotEmpty)
                          Text(
                            _brandName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        const SizedBox(height: 5),
                        Text(
                          _productName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 5),
                        if (_description.isNotEmpty)
                          ExpandableDescription(text: _description),
                        const SizedBox(height: 10),
                        if (_displayCompareAtPrice != null &&
                            _displayCompareAtPrice! > _displayPrice)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${_formatPrice(_displayPrice)} €',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_formatPrice(_displayCompareAtPrice!)}€',
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: Colors.grey.shade500),
                              ),
                              if (_discountPercent != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '-$_discountPercent%',
                                  style: const TextStyle(
                                      color: Color(0xFFE53935),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ],
                            ],
                          )
                        else
                          Text(
                            '${_formatPrice(_displayPrice)} €',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                        const SizedBox(height: 20),
                        if (_distinctColors.any((c) => c.isNotEmpty)) ...[
                          const Text(
                            'SELECTION COULEUR',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          _buildColorSelector(),
                          const SizedBox(height: 20),
                        ],
                        const Text(
                          'SELECTION TAILLE',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: _variantsForSelectedColor
                              .map((v) => _buildSizeChip(v.size, v.quantity))
                              .toList(),
                        ),
                        const SizedBox(height: 20),
                        if (_brandName.isNotEmpty)
                          Text(
                            'Vendu par $_brandName',
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                              color: Color(0xFF8D8D8D),
                            ),
                          ),
                        const Divider(thickness: 0.5, color: Color(0xFFD0D0D0)),
                        const SizedBox(height: 160),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildImageCarousel() {
    final images = _displayImages;
    return Column(
      children: [
        Stack(
          children: [
            SizedBox(
              height: 490,
              width: double.infinity,
              child: images.isEmpty
                  ? Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                          child:
                              Icon(Icons.image, size: 60, color: Colors.grey)),
                    )
                  : PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemBuilder: (context, index) => PinchZoom(
                        maxScale: 4.0,
                        child: CachedNetworkImage(
                          imageUrl: images[index],
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: Colors.grey.shade200),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image, size: 50),
                          ),
                        ),
                      ),
                    ),
            ),
            if (_brandPicture.isNotEmpty)
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: _brandPicture,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.store, size: 24),
                    ),
                  ),
                ),
              ),
            // Like (wishlist) heart — toggles the like for the current variant.
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: _onToggleLike,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Obx(() {
                    final liked = _likeController.isLiked(_currentVariantId);
                    return Icon(
                      liked ? Icons.favorite : Icons.favorite_border,
                      color: liked ? Colors.red : Colors.black,
                      size: 24,
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDotsIndicator(images.length),
      ],
    );
  }

  Widget _buildDotsIndicator(int count) {
    if (count <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 10 : 6,
          height: _currentPage == index ? 10 : 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Colors.black : Colors.grey,
          ),
        );
      }),
    );
  }

  // Whether the colour name maps to a real swatch colour. Unknown names (which
  // would otherwise fall back to grey) show the variant's picture instead.
  bool _isKnownColor(String color) =>
      _colorMap.containsKey(color.split('/').first.trim().toLowerCase());

  // First available image for a colour, used as its swatch for unknown colours.
  String _imageForColor(String color) {
    for (final v in _allVariants.where((v) => v.color == color)) {
      if (v.images.isNotEmpty) return v.images.first;
    }
    return '';
  }

  Widget _buildColorSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _distinctColors.map((color) {
        final isSelected = _selectedColor == color;
        final image = _imageForColor(color);
        final useImage = !_isKnownColor(color) && image.isNotEmpty;

        Widget swatch;
        if (useImage) {
          swatch = Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: image,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.grey.shade200),
                  errorWidget: (_, __, ___) =>
                      Container(color: Colors.grey.shade200),
                ),
                if (isSelected)
                  Container(
                    color: Colors.black.withValues(alpha: 0.25),
                    child: const Icon(Icons.check, color: Colors.white, size: 20),
                  ),
              ],
            ),
          );
        } else {
          final colorValue = _colorFromName(color);
          final isLight = colorValue == Colors.white ||
              colorValue == const Color(0xFFD4AF37) ||
              colorValue == const Color(0xFFF5F0DC) ||
              colorValue == Colors.yellow;
          swatch = Container(
            width: 38,
            height: 38,
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
          );
        }

        return GestureDetector(
          onTap: () => setState(() {
            _selectedColor = color;
            _selectedSize = null;
            _currentPage = 0;
            _pageController?.jumpToPage(0);
          }),
          child: Column(
            children: [
              swatch,
              const SizedBox(height: 4),
              Text(
                color.split('/').first.trim(),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSizeChip(String size, int quantity) {
    final isAvailable = quantity > 0;
    return ChoiceChip(
      color: WidgetStateProperty.all<Color>(Colors.white),
      label: Text(
        size,
        style: TextStyle(
          color: isAvailable ? Colors.black : Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      selected: _selectedSize == size,
      onSelected: isAvailable
          ? (isSelected) =>
              setState(() => _selectedSize = isSelected ? size : null)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isAvailable ? Colors.black : Colors.grey),
      ),
      backgroundColor: Colors.white,
      selectedColor: Colors.black,
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 490, width: double.infinity, color: Colors.white),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: 80, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 22, width: 220, color: Colors.white),
                  const SizedBox(height: 12),
                  Container(
                      height: 12, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 4),
                  Container(height: 12, width: 280, color: Colors.white),
                  const SizedBox(height: 20),
                  Container(height: 22, width: 70, color: Colors.white),
                  const SizedBox(height: 20),
                  Container(height: 16, width: 160, color: Colors.white),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(
                      3,
                      (_) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 38,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(height: 16, width: 160, color: Colors.white),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: List.generate(
                      6,
                      (_) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        width: 50,
                        height: 36,
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
          ],
        ),
      ),
    );
  }
}

class ExpandableDescription extends StatefulWidget {
  final String? text;

  const ExpandableDescription({Key? key, required this.text}) : super(key: key);

  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription>
    with TickerProviderStateMixin {
  bool _expanded = false;

  static const _textStyle =
      TextStyle(color: Colors.grey, fontSize: 14, height: 1.5);

  bool _exceedsThreeLines(String text, double maxWidth, BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: _textStyle),
      maxLines: 3,
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: maxWidth);
    return painter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final String displayText = widget.text?.trim().isNotEmpty == true
        ? widget.text!
        : 'No description available';

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isLong =
            _exceedsThreeLines(displayText, constraints.maxWidth, context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Text(
                displayText,
                maxLines: _expanded ? null : 3,
                overflow:
                    _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: _textStyle,
              ),
            ),
            if (isLong) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Row(
                  children: [
                    Text(
                      _expanded ? 'Voir moins' : 'Voir plus',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.black,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
