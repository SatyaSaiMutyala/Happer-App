import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:happer_app/features/creator/bindings/creator_binding.dart';
import 'package:happer_app/features/creator/data/repositories/creator_repository.dart';
import 'package:happer_app/features/dashboard/bindings/cart_binding.dart';
import 'package:happer_app/shared/widgets/product_card.dart';
import 'package:happer_app/features/dashboard/data/repositories/cart_repository.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/shared/controllers/cart_controller.dart';
import 'package:happer_app/shared/widgets/cart_preview_pill.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:shimmer/shimmer.dart';

class BrandDetailsScreen extends StatefulWidget {
  final String brandId;
  final String brandName;
  final String brandDescription;
  final String brandLogo;
  final String affiliateId;

  const BrandDetailsScreen({
    super.key,
    required this.brandId,
    required this.brandName,
    required this.brandDescription,
    required this.brandLogo,
    this.affiliateId = '',
  });

  @override
  _BrandDetailsScreenState createState() => _BrandDetailsScreenState();
}

class _BrandDetailsScreenState extends State<BrandDetailsScreen> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreItems = true;
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  List<Map<String, dynamic>> _brandItems = [];
  final ScrollController _scrollController = ScrollController();

  // Brand header data. Seeded from the navigation args (which, coming from the
  // creator feed's `linked_brands`, lack a description) and then enriched from
  // the products-list response, whose items embed the full `brand_id` object.
  late String _brandName = widget.brandName;
  late String _brandDescription = widget.brandDescription;
  late String _brandLogo = widget.brandLogo;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _init();
  }

  /// Pulls the brand's own data from the first product's populated `brand_id`,
  /// keeping existing values when the response omits a field.
  void _applyBrandFromItems(List<Map<String, dynamic>> items) {
    final brand = items
        .map((p) => p['brand_id'])
        .whereType<Map<String, dynamic>>()
        .firstOrNull;
    if (brand == null) return;
    final name = brand['name'] as String?;
    final description = brand['description'] as String?;
    final picture = brand['picture'] as String?;
    if (name != null && name.isNotEmpty) _brandName = name;
    if (description != null && description.isNotEmpty) {
      _brandDescription = description;
    }
    if (picture != null && picture.isNotEmpty) _brandLogo = picture;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Trigger loading when 200px from bottom for smoother experience
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_hasMoreItems && !_isLoadingMore) {
        _loadMoreItems();
      }
    }
  }

  Future<void> _init() async {
    // Cart must load first so ProductCard.initState can read cartItemsByVariant correctly
    await _fetchCartItemCount();
    await _fetchBrandItems();
  }

  Future<void> _fetchCartItemCount() async {
    await Get.find<CartController>().fetchCartItemCount();
  }

  Future<void> _fetchBrandItems() async {
    try {
      CreatorBinding().dependencies();
      final repo = Get.find<CreatorRepository>();
      final items = await repo.fetchBrandProducts(
        widget.brandId,
        page: _currentPage,
        perPage: _itemsPerPage,
      );
      if (!mounted) return;
      setState(() {
        _brandItems = items;
        _applyBrandFromItems(items);
        _currentPage = 2;
        _hasMoreItems = items.length >= _itemsPerPage;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String?> _addProductToCart(String productId, String variantId) async {
    try {
      CartBinding().dependencies();
      final repo = Get.find<CartRepository>();
      final cartItemId = await repo.addToCart(
        productId: productId,
        variantId: variantId,
        affiliateId: widget.affiliateId,
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
      final repo = Get.find<CartRepository>();
      await repo.removeCartItem(cartItemId);
      if (!mounted) return;
      Get.find<CartController>().fetchCartItemCount();
    } catch (e) {
      if (mounted) showAppSnackBar(e.toString(), isSuccess: false);
    }
  }

  Future<void> _loadMoreItems() async {
    if (_isLoadingMore || !_hasMoreItems) return;
    setState(() => _isLoadingMore = true);
    try {
      CreatorBinding().dependencies();
      final repo = Get.find<CreatorRepository>();
      final items = await repo.fetchBrandProducts(
        widget.brandId,
        page: _currentPage,
        perPage: _itemsPerPage,
      );
      if (!mounted) return;
      setState(() {
        _brandItems.addAll(items);
        _currentPage++;
        _hasMoreItems = items.length >= _itemsPerPage;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient area. Reserved, not painted: the real thing is a black
            // 0.3 → transparent wash over white, so shimmering a solid block
            // here put a heavy grey band across the top of the screen that
            // simply isn't there once the brand loads.
            const SizedBox(height: 80),
            Transform.translate(
              offset: const Offset(0, -40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header keeps its own 16px inset.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand logo circle
                        const CircleAvatar(
                            radius: 40, backgroundColor: Colors.white),
                        const SizedBox(height: 16),
                        // Brand name — 16px Lato w700.
                        Container(height: 19, width: 140, color: Colors.white),
                        const SizedBox(height: 8),
                        // Description — 12px at height 1.5, so each line
                        // occupies 18px. Two lines is the common case; a
                        // one-line description leaves the grid 18px lower here
                        // than it lands, which is as close as a fixed skeleton
                        // gets to text of unknown length.
                        Container(
                            height: 12,
                            width: double.infinity,
                            color: Colors.white),
                        const SizedBox(height: 6),
                        Container(height: 12, width: 200, color: Colors.white),
                        const SizedBox(height: 6),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                  // Grid is a sibling of the header padding, not nested inside
                  // it, so its padding and delegate can mirror the real
                  // SliverPadding + SliverGrid exactly. Nesting it under the
                  // header's 16px inset made every placeholder tile narrower
                  // than the card it stands in for.
                  GridView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 8),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 290,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) => _shimmerCardSkeleton(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Placeholder shaped like a real ProductCard: image block, then the name,
  /// price and button rows. A single filled rectangle spanning the whole cell
  /// read as a much heavier, bigger card than the one it stands in for.
  ///
  /// Every measurement below is taken from ProductCard rather than guessed, so
  /// the skeleton lands on the same pixels as the card that replaces it. The
  /// image block in particular must be derived from the cell width — filling
  /// the leftover space with an Expanded made it 21–55px too tall depending on
  /// the device, so the card visibly jumped once the images arrived, and by a
  /// different amount on every screen size.
  Widget _shimmerCardSkeleton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // ProductCard: imageHeight = cardWidth * (180 / 125).
        final imageHeight = constraints.maxWidth * (180 / 125);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area — the tallest part of the real card.
            Container(
              height: imageHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 6),
            // Product name — 13px Lato at height 1.3.
            Container(height: 17, width: 90, color: Colors.white),
            const SizedBox(height: 2),
            // Price — 13px Lato.
            Container(height: 16, width: 50, color: Colors.white),
            const SizedBox(height: 6),
            // "Ajouter" button — 7px vertical padding around a 14px icon row,
            // plus the 1px border on each side.
            Container(
              height: 31,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    final productId = item['_id'] as String? ?? '';
    final variants = item['variants'] as List<dynamic>? ?? [];
    final variant = variants.isNotEmpty
        ? variants.first as Map<String, dynamic>
        : <String, dynamic>{};
    final variantId = variant['_id'] as String? ?? '';

    // Keep each built card alive so scrolling back up doesn't rebuild it and
    // reload its image.
    return _KeepAlive(
      child: LayoutBuilder(builder: (context, constraints) {
        return ProductCard(
          product: item,
          cardWidth: constraints.maxWidth,
          affiliateId: widget.affiliateId,
          onAddToCart: productId.isEmpty || variantId.isEmpty
              ? null
              : () => _addProductToCart(productId, variantId),
          onRemoveFromCart: _removeProductFromCart,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      appBar: HapperAppBar(
        title: 'LA COLLECTION',
      ),
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
      body: _isLoading
          ? _buildShimmerLoading()
          : CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Brand header (gradient + overlapping brand info)
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      // Gradient at top
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Brand info overlapping gradient by 40px
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 40, left: 16, right: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(12),
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: _brandLogo,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey.shade200,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                    Icons.image,
                                    size: 30,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _brandName.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.black,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _brandDescription,
                              style: const TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w300,
                                fontSize: 12,
                                color: Colors.black,
                                fontStyle: FontStyle.italic,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Products Grid (lazily built — only visible items in memory)
                if (_brandItems.isNotEmpty)
                  SliverPadding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 290,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildProductCard(_brandItems[index]),
                        childCount: _brandItems.length,
                      ),
                    ),
                  ),

                // Loading shimmer for pagination
                if (_isLoadingMore)
                  SliverPadding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 290,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        // No extra margin: the grid delegate already provides the
                        // spacing, so a margin here made these tiles smaller
                        // than the real cards they stand in for. Same skeleton
                        // as the first-load shimmer so both states match.
                        (context, index) => Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: _shimmerCardSkeleton(),
                        ),
                        childCount: 4,
                      ),
                    ),
                  ),

                // End of list message
                if (!_hasMoreItems && _brandItems.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'No more products',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Empty state
                if (!_isLoading && _brandItems.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No products available',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Check back later for new arrivals',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
    );
  }
}

/// Keeps its [child] alive when scrolled off-screen in a lazy sliver list, so
/// it isn't rebuilt (and its images reloaded) when scrolled back into view.
class _KeepAlive extends StatefulWidget {
  final Widget child;

  const _KeepAlive({required this.child});

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}