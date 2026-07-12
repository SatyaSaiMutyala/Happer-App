import 'package:happer_app/core/utils/deep_link_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/app_manager.dart';
import 'package:happer_app/features/creator/bindings/creator_binding.dart';
import 'package:happer_app/features/creator/data/repositories/creator_repository.dart';
import 'package:happer_app/features/creator/models/creator_model.dart';
import 'package:happer_app/features/creator/screens/brand_details_screen.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/features/dashboard/bindings/cart_binding.dart';
import 'package:happer_app/features/dashboard/data/repositories/cart_repository.dart';
import 'package:happer_app/shared/controllers/cart_controller.dart';
import 'package:happer_app/shared/widgets/image_carousel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import 'package:happer_app/features/profile/screens/image_grid_screen.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:happer_app/shared/widgets/cart_preview_pill.dart';
import 'package:happer_app/shared/widgets/product_card.dart';

class SelfieDetailsScreen extends StatefulWidget {
  final String selfieId;
  final int? initialLikes;
  final bool? isLikedByMe;
  final CreatorModel? model;

  const SelfieDetailsScreen({
    Key? key,
    required this.selfieId,
    this.initialLikes,
    this.isLikedByMe,
    this.model,
  }) : super(key: key);

  @override
  _SelfieDetailsScreenState createState() => _SelfieDetailsScreenState();
}

class _SelfieDetailsScreenState extends State<SelfieDetailsScreen>
    with SingleTickerProviderStateMixin {
  CreatorModel? _selfie;
  late int _likes;
  late bool _isLiked;
  bool _isLoading = true;
  bool _isToggling = false;
  List<Map<String, dynamic>> _linkedProducts = [];
  List<Map<String, dynamic>> _similarProducts = [];
  List<Map<String, dynamic>> _brandCollections = [];
  bool _showHeart = false;
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScaleAnimation;
  late Animation<double> _heartOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _likes = widget.initialLikes ?? 0;
    _isLiked = widget.isLikedByMe ?? false;

    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _heartScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_heartAnimationController);
    _heartOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_heartAnimationController);
    _heartAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showHeart = false);
      }
    });

    _selfie = widget.model;
    _isLoading = widget.model == null;
    _fetchSelfieDetails();
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
  }

  // ─── Network helpers ──────────────────────────────────────────────────────

  Future<void> _fetchSelfieDetails() async {
    try {
      CreatorBinding().dependencies();
      final repo = Get.find<CreatorRepository>();
      final result = await repo.getSelfieDetail(widget.selfieId);
      if (!mounted) return;
      setState(() {
        _selfie = result.selfie;
        _linkedProducts = result.linkedProducts;
        _similarProducts = result.similarProducts;
        _brandCollections = result.brandCollections;
        _likes = result.selfie.nbLike ?? widget.initialLikes ?? 0;
        _isLiked = result.selfie.isLikedByMe ?? widget.isLikedByMe ?? false;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isToggling) return;
    final wasLiked = _isLiked;
    setState(() {
      _isToggling = true;
      _isLiked = !wasLiked;
      _likes = _isLiked ? _likes + 1 : (_likes > 0 ? _likes - 1 : 0);
    });
    try {
      CreatorBinding().dependencies();
      final repo = Get.find<CreatorRepository>();
      if (wasLiked) {
        await repo.unlikeSelfie(widget.selfieId);
      } else {
        await repo.likeSelfie(widget.selfieId);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLiked = wasLiked;
          _likes = wasLiked ? _likes + 1 : (_likes > 0 ? _likes - 1 : 0);
        });
      }
    } finally {
      if (mounted) setState(() => _isToggling = false);
    }
  }

  // Opens the "complete the look" sheet: every linked product with its size
  // options (colour is fixed to the one shown in the look) and a per-item
  // quantity. Adds the chosen size-variants to the cart on confirm.
  Future<void> _openLookSheet() async {
    if (_linkedProducts.isEmpty) return;
    final items = _linkedProducts
        .map(_LookLineItem.fromProduct)
        .whereType<_LookLineItem>()
        .toList();
    if (items.isEmpty) {
      showAppSnackBar('Aucun article disponible', isSuccess: false);
      return;
    }
    final added = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LookCartSheet(
        items: items,
        onConfirm: _confirmLookAddToCart,
      ),
    );
    if (!mounted || added == null) return;
    if (added > 0) {
      showAppSnackBar(
          '$added article${added > 1 ? 's' : ''} ajouté${added > 1 ? 's' : ''} au panier',
          isSuccess: true);
    } else {
      showAppSnackBar('Impossible d\'ajouter les articles au panier',
          isSuccess: false);
    }
  }

  // Adds the sheet's selections to the cart and returns how many succeeded.
  Future<int> _confirmLookAddToCart(List<_LookLineItem> items) async {
    CartBinding().dependencies();
    final cartRepo = Get.find<CartRepository>();
    final affiliateId = _selfie?.user?.sId ?? '';
    int added = 0;
    for (final item in items) {
      final variantId = item.selectedVariantId;
      if (item.productId.isEmpty || variantId.isEmpty) continue;
      try {
        await cartRepo.addToCart(
          productId: item.productId,
          variantId: variantId,
          affiliateId: affiliateId,
          quantity: item.quantity,
        );
        added++;
      } catch (e) {
        debugPrint('Failed to add product ${item.productId} to cart: $e');
      }
    }
    if (mounted) Get.find<CartController>().fetchCartItemCount();
    return added;
  }

  Future<String?> _addProductToCart(
      String productId, String variantId, String affiliateId) async {
    try {
      CartBinding().dependencies();
      final cartRepo = Get.find<CartRepository>();
      final cartItemId = await cartRepo.addToCart(
        productId: productId,
        variantId: variantId,
        affiliateId: affiliateId,
        quantity: 1,
      );
      if (!mounted) return null;
      Get.find<CartController>().fetchCartItemCount();
      showAppSnackBar('Article ajouté au panier', isSuccess: true);
      return cartItemId;
    } catch (e) {
      if (mounted) showAppSnackBar(e.toString(), isSuccess: false);
      return null;
    }
  }

  Future<void> _removeProductFromCart(String cartItemId) async {
    try {
      CartBinding().dependencies();
      final cartRepo = Get.find<CartRepository>();
      await cartRepo.removeCartItem(cartItemId);
      if (!mounted) return;
      Get.find<CartController>().fetchCartItemCount();
    } catch (e) {
      if (mounted) showAppSnackBar(e.toString(), isSuccess: false);
    }
  }

  // ─── Utilities ────────────────────────────────────────────────────────────

  int get _lookTotalPrice => _linkedProducts.fold(0, (sum, p) {
        final variants = p['variants'] as List<dynamic>? ?? [];
        if (variants.isEmpty) return sum;
        final v = variants.first as Map<String, dynamic>;
        return sum + ((v['price'] as num?)?.toInt() ?? 0);
      });

  String _getTimeDifference(String createdAt) {
    final diff = DateTime.now().difference(DateTime.parse(createdAt));
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
    if (diff.inDays < 30) {
      final w = (diff.inDays / 7).floor();
      return 'il y a $w ${w == 1 ? 'semaine' : 'semaines'}';
    }
    if (diff.inDays < 365) {
      return 'il y a ${(diff.inDays / 30).floor()} mois';
    }
    final y = (diff.inDays / 365).floor();
    return 'il y a $y ${y == 1 ? 'an' : 'ans'}';
  }

  void _onDoubleTap() {
    if (AppManager.isLoginAsGuest) return;
    setState(() => _showHeart = true);
    _heartAnimationController.forward(from: 0.0);
    if (!_isLiked) _toggleFavorite();
  }

  // ─── Shared image builders ────────────────────────────────────────────────

  ImageProvider _profileProvider(String path) {
    if (path.startsWith('assets/')) return AssetImage(path);
    return CachedNetworkImageProvider(path);
  }

  Widget _buildBrandLogoImg(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.contain);
    }
    return CachedNetworkImage(
      imageUrl: path,
      fit: BoxFit.contain,
      placeholder: (_, __) => Container(color: Colors.grey.shade200),
      errorWidget: (_, __, ___) =>
          const Icon(Icons.image, size: 24, color: Colors.grey),
    );
  }

  // ─── Reusable product card ────────────────────────────────────────────────

  Widget _buildProductCard(Map<String, dynamic> product,
      {double cardWidth = 125}) {
    final productId = product['_id'] as String? ?? '';
    final variants = product['variants'] as List<dynamic>? ?? [];
    final variant = variants.isNotEmpty
        ? variants.first as Map<String, dynamic>
        : <String, dynamic>{};
    final variantId = variant['_id'] as String? ?? '';
    final affiliateId = _selfie?.user?.sId ?? '';

    return ProductCard(
      product: product,
      cardWidth: cardWidth,
      affiliateId: affiliateId,
      onAddToCart: productId.isEmpty || variantId.isEmpty
          ? null
          : () => _addProductToCart(productId, variantId, affiliateId),
      onRemoveFromCart: _removeProductFromCart,
    );
  }

  // ─── Section builders ─────────────────────────────────────────────────────

  Widget _buildLinkedProductsSection() {
    if (_linkedProducts.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 11),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Lato',
                fontStyle: FontStyle.italic,
                height: 1.0,
                color: Color(0xFF8D8D8D),
              ),
              children: [
                const TextSpan(text: 'La Séléction de '),
                TextSpan(
                  text:
                      _selfie!.user?.userName ?? _selfie!.user?.firstName ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 268,
          child: Padding(
            padding: const EdgeInsets.only(left: 11),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _linkedProducts.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildProductCard(_linkedProducts[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarProductsSection() {
    if (_similarProducts.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 11),
          child: Text(
            'Autour du look',
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 268,
          child: Padding(
            padding: const EdgeInsets.only(left: 11),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _similarProducts.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildProductCard(_similarProducts[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandCollectionsSection() {
    if (_brandCollections.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _brandCollections.map((group) {
        final brand = group['brand'] as Map<String, dynamic>? ?? {};
        final products = (group['products'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();
        final brandId = brand['_id'] as String? ?? '';
        final brandName = brand['name'] as String? ?? '';
        final brandLogo = brand['picture'] as String? ?? '';

        final visibleProducts = products.take(10).toList();
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Collection ',
                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: brandName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 290,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 11),
                  itemCount: visibleProducts.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child:
                        _buildProductCard(visibleProducts[i], cardWidth: 130),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 11),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BrandDetailsScreen(
                          brandId: brandId,
                          brandName: brandName,
                          brandDescription: '',
                          brandLogo: brandLogo,
                          affiliateId: _selfie?.user?.sId ?? '',
                        ),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 1))
                        ],
                      ),
                      child: const Text(
                        'Explorer la collection',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─── Shimmer ──────────────────────────────────────────────────────────────

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 5,
              child: Container(width: double.infinity, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(height: 14, width: 80, color: Colors.white),
                  Container(
                      height: 20,
                      width: 20,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                  height: 1, width: double.infinity, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 11),
              child: Container(height: 14, width: 160, color: Colors.white),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 268,
              child: Padding(
                padding: const EdgeInsets.only(left: 11),
                child: Row(
                  children: List.generate(
                    3,
                    (_) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              height: 180, width: 125, color: Colors.white),
                          const SizedBox(height: 8),
                          Container(
                              height: 12, width: 100, color: Colors.white),
                          const SizedBox(height: 6),
                          Container(height: 10, width: 60, color: Colors.white),
                          const SizedBox(height: 6),
                          Container(
                              height: 30,
                              width: 125,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      appBar: HapperAppBar(title: 'SHOP LE LOOK', actions: const []),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CartPreviewPill(),
          SafeArea(
            top: false,
            child: const SizedBox(height: kBottomNavigationBarHeight),
          ),
        ],
      ),
      body: (_isLoading || _selfie == null)
          ? _buildShimmerLoading()
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 170.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Main selfie image ──────────────────────────────────
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onDoubleTap: _onDoubleTap,
                    child: Stack(
                      children: [
                        // Full-width 4:5 portrait carousel: pages through all
                        // images with dots + arrows, falling back to the single
                        // `picture` when the images list isn't populated yet.
                        ImageCarousel(
                          images: (_selfie?.images != null &&
                                  _selfie!.images!.isNotEmpty)
                              ? _selfie!.images!
                              : [_selfie?.picture ?? ''],
                          // Details page: swipe to change images, dots only,
                          // no side arrows.
                          enableSwipe: true,
                          showArrows: false,
                        ),
                        // User avatar + name row
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ImageGridScreen(
                                            userId: _selfie!.user!.sId ?? ''),
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      backgroundImage: _selfie!.user?.picture !=
                                                  null &&
                                              _selfie!.user!.picture!.isNotEmpty
                                          ? _profileProvider(
                                              _selfie!.user!.picture!)
                                          : null,
                                      backgroundColor: Colors.grey.shade200,
                                      radius: 20,
                                      child: (_selfie!.user?.picture == null ||
                                              _selfie!.user!.picture!.isEmpty)
                                          ? const Icon(Icons.person,
                                              color: Colors.grey)
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ImageGridScreen(
                                            userId: _selfie!.user!.sId ?? ''),
                                      ),
                                    ),
                                    child: Text(
                                      _selfie!.user?.userName ??
                                          '${_selfie!.user?.firstName ?? ''} ${_selfie!.user?.lastName ?? ''}'
                                              .trim(),
                                      style: const TextStyle(
                                        fontFamily: 'Lato',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.verified,
                                      color: Colors.white, size: 24),
                                ],
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                  color: Color(0x33000000),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.share,
                                      size: 24, color: Colors.white),
                                  onPressed: () {
                                    final selfieId = _selfie?.sId ?? '';
                                    if (selfieId.isEmpty) {
                                      showAppSnackBar(
                                          'Partage indisponible pour le moment',
                                          isSuccess: false);
                                      return;
                                    }
                                    // The username segment in the share link is
                                    // cosmetic — the app opens the outfit using
                                    // selfieId alone. Fall back to the user's id
                                    // so sharing still works for creators who
                                    // haven't set a username.
                                    final username =
                                        _selfie?.user?.userName?.isNotEmpty ==
                                                true
                                            ? _selfie!.user!.userName!
                                            : (_selfie?.user?.sId ?? '');
                                    if (username.isEmpty) {
                                      showAppSnackBar(
                                          'Partage indisponible pour le moment',
                                          isSuccess: false);
                                      return;
                                    }
                                    final box = context.findRenderObject() as RenderBox?;
                                    shareOutfit(
                                      username: username,
                                      selfieId: selfieId,
                                      creatorName: '${_selfie?.user?.firstName ?? ''} ${_selfie?.user?.lastName ?? ''}'.trim(),
                                      sharePositionOrigin: box != null && box.hasSize
                                          ? box.localToGlobal(Offset.zero) & box.size
                                          : null,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Brand logos (bottom-left overlapping circles)
                        if (_linkedProducts.any((p) =>
                            p['brand_id'] is Map &&
                            ((p['brand_id'] as Map)['picture'] as String? ?? '')
                                .isNotEmpty))
                          Positioned(
                            bottom: 12,
                            left: 12,
                            child: () {
                              final seen = <String>{};
                              final brands = <Map<String, dynamic>>[];
                              for (final p in _linkedProducts) {
                                final b = p['brand_id'];
                                if (b is Map<String, dynamic> &&
                                    b['_id'] != null &&
                                    (b['picture'] as String? ?? '')
                                        .isNotEmpty &&
                                    seen.add(b['_id'] as String)) {
                                  brands.add(b);
                                }
                              }
                              const size = 48.0;
                              const overlap = 16.0;
                              return SizedBox(
                                width: brands.length * size -
                                    (brands.length - 1) * overlap,
                                height: size,
                                child: Stack(
                                  children: List.generate(brands.length, (i) {
                                    final b = brands[i];
                                    return Positioned(
                                      left: i * (size - overlap),
                                      child: GestureDetector(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BrandDetailsScreen(
                                              brandId:
                                                  b['_id'] as String? ?? '',
                                              brandName:
                                                  b['name'] as String? ?? '',
                                              brandDescription:
                                                  b['description'] as String? ??
                                                      '',
                                              brandLogo:
                                                  b['picture'] as String? ?? '',
                                              affiliateId:
                                                  _selfie?.user?.sId ?? '',
                                            ),
                                          ),
                                        ),
                                        child: Container(
                                          height: size,
                                          width: size,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                            border: Border.all(
                                                color: Colors.white, width: 2),
                                            boxShadow: const [
                                              BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 6,
                                                  offset: Offset(1, 2))
                                            ],
                                          ),
                                          padding: const EdgeInsets.all(6),
                                          child: ClipOval(
                                              child: _buildBrandLogoImg(
                                                  b['picture'] as String)),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              );
                            }(),
                          ),
                        // Double-tap heart animation
                        if (_showHeart)
                          Positioned.fill(
                            child: Center(
                              child: AnimatedBuilder(
                                animation: _heartAnimationController,
                                builder: (_, __) => Opacity(
                                  opacity: _heartOpacityAnimation.value,
                                  child: Transform.scale(
                                    scale: _heartScaleAnimation.value,
                                    child: const Icon(Icons.favorite,
                                        color: Colors.white,
                                        size: 100,
                                        shadows: [
                                          Shadow(
                                              blurRadius: 20,
                                              color: Colors.black38)
                                        ]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Time + like ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getTimeDifference(_selfie!.createdAt ??
                              DateTime.now().toIso8601String()),
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Color(0xFF8D8D8D),
                          ),
                        ),
                        if (!AppManager.isLoginAsGuest)
                          IconButton(
                            icon: Icon(Icons.favorite,
                                size: 20,
                                color: _isLiked ? Colors.red : Colors.grey),
                            onPressed: _isToggling ? null : _toggleFavorite,
                          ),
                      ],
                    ),
                  ),

                  // ── Caption ───────────────────────────────────────────
                  if ((_selfie!.caption ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _selfie!.caption!.trim(),
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                          height: 1.4,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  // ── "Look composé avec" brand names ───────────────────
                  if (_linkedProducts.any((p) =>
                      p['brand_id'] is Map &&
                      ((p['brand_id'] as Map)['name'] as String? ?? '')
                          .isNotEmpty))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            height: 1.4,
                            color: Color(0xFF8D8D8D),
                          ),
                          children: [
                            const TextSpan(text: 'Look composé avec '),
                            TextSpan(
                              text: () {
                                final seen = <String>{};
                                final names = <String>[];
                                for (final p in _linkedProducts) {
                                  final b = p['brand_id'];
                                  if (b is Map<String, dynamic>) {
                                    final n = b['name'] as String? ?? '';
                                    if (n.isNotEmpty && seen.add(n)) {
                                      names.add(n);
                                    }
                                  }
                                }
                                return names.join(' - ');
                              }(),
                              style: const TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                height: 1.4,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child:
                        const Divider(thickness: 0.5, color: Color(0xFFD0D0D0)),
                  ),

                  // ── Prix Exclusif / Livraison ──────────────────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(right: 16, top: 4, bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text('Prix Exclusif Happer',
                              style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Color(0xFF8D8D8D))),
                          Text('Livraison Offerte',
                              style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Color(0xFF8D8D8D))),
                        ],
                      ),
                    ),
                  ),

                  // ── La Séléction de ────────────────────────────────────
                  _buildLinkedProductsSection(),
                  const SizedBox(height: 16),

                  // ── AJOUTER LE LOOK AU PANIER button ──────────────────
                  if (_linkedProducts.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GestureDetector(
                        onTap: _openLookSheet,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/b3bag.png',
                                  width: 23, height: 23, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                _lookTotalPrice > 0
                                    ? 'AJOUTER LE LOOK AU PANIER - $_lookTotalPrice€'
                                    : 'AJOUTER LE LOOK AU PANIER',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // ── Autour du look ─────────────────────────────────────
                  _buildSimilarProductsSection(),
                  const SizedBox(height: 16),

                  // ── Brand collections ──────────────────────────────────
                  _buildBrandCollectionsSection(),

                  const SizedBox(height: 50),
                ],
              ),
            ),
    );
  }
}

// ─── "Complete the look" cart sheet ─────────────────────────────────────────

/// One selectable size for a linked product (colour is fixed to the look's).
class _LookSizeOption {
  final String size;
  final String variantId;
  final double price;
  final int stock;
  const _LookSizeOption({
    required this.size,
    required this.variantId,
    required this.price,
    required this.stock,
  });
}

/// A linked product with its size options + the user's (mutable) selection.
class _LookLineItem {
  final String productId;
  final String name;
  final String brandName;
  final String brandPicture;
  final String imageUrl;
  final double basePrice;
  final double? compareAtPrice;
  final List<_LookSizeOption> sizes;
  final String fallbackVariantId;

  String? selectedSize;
  int quantity = 1;

  _LookLineItem({
    required this.productId,
    required this.name,
    required this.brandName,
    required this.brandPicture,
    required this.imageUrl,
    required this.basePrice,
    required this.compareAtPrice,
    required this.sizes,
    required this.fallbackVariantId,
  });

  bool get hasSizes => sizes.any((s) => s.size.isNotEmpty);

  _LookSizeOption? get _selected =>
      selectedSize == null ? null : _sizeFor(selectedSize!);

  _LookSizeOption? _sizeFor(String size) {
    for (final s in sizes) {
      if (s.size == size) return s;
    }
    return null;
  }

  String get selectedVariantId {
    final sel = _selected;
    if (sel != null) return sel.variantId;
    // A product with sizes must have one chosen before it can be added.
    if (hasSizes) return '';
    return sizes.isNotEmpty ? sizes.first.variantId : fallbackVariantId;
  }

  double get unitPrice => _selected?.price ?? basePrice;

  int get selectedStock => _selected?.stock ?? (hasSizes ? 0 : 9999);

  // Reads the linked-product JSON exactly like ProductDetails does (option_ids
  // with EN/FR names). Returns null when there's nothing addable.
  static _LookLineItem? fromProduct(Map<String, dynamic> product) {
    final productId = product['_id'] as String? ?? '';
    final variants = (product['variants'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
    if (productId.isEmpty || variants.isEmpty) return null;

    String optionOf(Map<String, dynamic> v, bool Function(String) matches) {
      final options = (v['option_ids'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>();
      for (final o in options) {
        final n = (o['name'] as String? ?? '').trim().toLowerCase();
        if (matches(n)) return o['value'] as String? ?? '';
      }
      return '';
    }

    bool isSize(String n) => n == 'size' || n == 'taille';

    final firstVariant = variants.first;

    // Every distinct size across all variants becomes a selectable box.
    final sizeOptions = <_LookSizeOption>[];
    final seen = <String>{};
    for (final v in variants) {
      final variantId = v['_id'] as String? ?? '';
      if (variantId.isEmpty) continue;
      final size = optionOf(v, isSize);
      if (size.isNotEmpty && !seen.add(size)) continue;
      sizeOptions.add(_LookSizeOption(
        size: size,
        variantId: variantId,
        price: (v['price'] as num?)?.toDouble() ?? 0,
        stock: v['quantity'] as int? ?? 0,
      ));
    }

    final images = (firstVariant['images'] as List<dynamic>? ?? [])
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final imageUrl =
        images.isNotEmpty ? images.first : (product['product_image'] as String? ?? '');

    final brand = product['brand_id'];
    final compareRaw = firstVariant['compare_at_price'];
    final compareAt = compareRaw is num
        ? compareRaw.toDouble()
        : (compareRaw is String ? double.tryParse(compareRaw) : null);

    // No default size — the user must pick one themselves.
    return _LookLineItem(
      productId: productId,
      name: product['name'] as String? ?? '',
      brandName: brand is Map ? (brand['name'] as String? ?? '') : '',
      brandPicture: brand is Map ? (brand['picture'] as String? ?? '') : '',
      imageUrl: imageUrl,
      basePrice: (firstVariant['price'] as num?)?.toDouble() ?? 0,
      compareAtPrice: compareAt,
      sizes: sizeOptions,
      fallbackVariantId: firstVariant['_id'] as String? ?? '',
    );
  }
}

class _LookCartSheet extends StatefulWidget {
  final List<_LookLineItem> items;
  final Future<int> Function(List<_LookLineItem>) onConfirm;

  const _LookCartSheet({required this.items, required this.onConfirm});

  @override
  State<_LookCartSheet> createState() => _LookCartSheetState();
}

class _LookCartSheetState extends State<_LookCartSheet> {
  bool _isSubmitting = false;

  static const _accent = Colors.black;
  static const _grey = Color(0xFF8D8D8D);

  double get _total =>
      widget.items.fold(0.0, (s, it) => s + it.unitPrice * it.quantity);

  double get _savings => widget.items.fold(0.0, (s, it) {
        final c = it.compareAtPrice;
        if (c != null && c > it.unitPrice) {
          return s + (c - it.unitPrice) * it.quantity;
        }
        return s;
      });

  int get _totalQty => widget.items.fold(0, (s, it) => s + it.quantity);

  // Every product that has sizes must have one selected before checkout.
  bool get _allChosen =>
      widget.items.every((it) => !it.hasSizes || it.selectedSize != null);

  String _fmt(double v) {
    final s = v.toStringAsFixed(2);
    return s.endsWith('.00') ? s.substring(0, s.length - 3) : s;
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    final added = await widget.onConfirm(widget.items);
    if (!mounted) return;
    Navigator.pop(context, added);
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.88;
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Compléter le look',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w800,
                          fontSize: 19,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Choisissez votre taille pour chaque pièce',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 12.5,
                          color: _grey,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          // ── Product list ──
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              shrinkWrap: true,
              itemCount: widget.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _buildRow(widget.items[i]),
            ),
          ),
          // ── Footer ──
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildRow(_LookLineItem item) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 72,
                  height: 90,
                  color: Colors.grey.shade100,
                  child: item.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: Colors.grey.shade100),
                          errorWidget: (_, __, ___) => const Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey),
                        )
                      : const Icon(Icons.image, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              // Brand + name + price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.brandName.isNotEmpty)
                      Text(
                        item.brandName.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 0.4,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w500,
                        fontSize: 13.5,
                        height: 1.25,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_fmt(item.unitPrice)} €',
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        if (item.compareAtPrice != null &&
                            item.compareAtPrice! > item.unitPrice) ...[
                          const SizedBox(width: 6),
                          Text(
                            '${_fmt(item.compareAtPrice!)} €',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 12,
                              color: Colors.grey.shade400,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.hasSizes) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  'SÉLECTION TAILLE',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.6,
                    color: _grey,
                  ),
                ),
                if (item.selectedSize == null) ...[
                  const SizedBox(width: 6),
                  const Text(
                    '· requise',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 10.5,
                      color: Color(0xFFE53935),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: item.sizes
                  .where((s) => s.size.isNotEmpty)
                  .map((s) => _buildSizeChip(item, s))
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          // Quantity stepper
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quantité',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
              _buildQtyStepper(item),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSizeChip(_LookLineItem item, _LookSizeOption s) {
    final selected = item.selectedSize == s.size;
    return GestureDetector(
      onTap: () => setState(() => item.selectedSize = s.size),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 46,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _accent : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? _accent : Colors.grey.shade300,
            width: 1.2,
          ),
        ),
        child: Text(
          s.size.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: selected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildQtyStepper(_LookLineItem item) {
    final maxQty = item.selectedStock > 0 ? item.selectedStock : 99;
    final canDec = item.quantity > 1;
    final canInc = item.quantity < maxQty;
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _qtyBtn(Icons.remove, canDec,
              () => setState(() => item.quantity -= 1)),
          Container(
            constraints: const BoxConstraints(minWidth: 30),
            alignment: Alignment.center,
            child: Text(
              '${item.quantity}',
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
          _qtyBtn(Icons.add, canInc,
              () => setState(() => item.quantity += 1)),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: enabled ? Colors.black : Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, 14 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total ($_totalQty)',
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 11.5,
                  color: _grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_fmt(_total)} €',
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              if (_savings > 0)
                Text(
                  'Économie ${_fmt(_savings)} €',
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: Color(0xFF2E7D32),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: (_isSubmitting || !_allChosen) ? null : _submit,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _allChosen ? Colors.black : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white)),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _allChosen
                                ? Icons.shopping_bag_outlined
                                : Icons.straighten,
                            color: _allChosen
                                ? Colors.white
                                : Colors.grey.shade600,
                            size: 19,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _allChosen
                                ? 'Ajouter au panier'
                                : 'Choisir les tailles',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: _allChosen
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
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
}
