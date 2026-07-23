import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/features/creator/bindings/creator_binding.dart';
import 'package:happer_app/features/creator/controllers/liked_products_controller.dart';
import 'package:happer_app/features/creator/data/models/liked_product_model.dart';
import 'package:happer_app/features/creator/data/repositories/creator_repository.dart';
import 'package:happer_app/features/creator/screens/product_details_screen.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:shimmer/shimmer.dart';

class LikedProductsScreen extends StatelessWidget {
  const LikedProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          HapperAppBar(title: AppLocalizations.of(context).likedProductsTitle),
      body: const LikedProductsView(),
    );
  }
}

/// Reusable liked-products grid (no Scaffold) so it can be embedded standalone
/// or inside a tab (e.g. the favourites screen toggle).
class LikedProductsView extends StatefulWidget {
  const LikedProductsView({super.key});

  @override
  State<LikedProductsView> createState() => _LikedProductsViewState();
}

class _LikedProductsViewState extends State<LikedProductsView> {
  late final LikedProductsController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    CreatorBinding().dependencies();
    final alreadyRegistered = Get.isRegistered<LikedProductsController>();
    if (!alreadyRegistered) {
      Get.put(LikedProductsController(Get.find<CreatorRepository>()));
    }
    _controller = Get.find<LikedProductsController>();
    // A freshly-put controller already fetches in onInit. An existing one may
    // be stale — a product liked elsewhere won't be in its list — so refetch on
    // entry instead of showing data from a previous visit (which only refreshed
    // on app restart).
    if (alreadyRegistered) _controller.refresh();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        _controller.hasMore.value &&
        !_controller.isLoadingMore.value) {
      _controller.fetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Obx(() {
      final items = _controller.products;
      final isLoading = _controller.isLoading.value;

      if (isLoading && items.isEmpty) return _buildShimmerGrid();
      if (items.isEmpty) return _buildEmptyState(l);

      return RefreshIndicator(
        color: Colors.black,
        onRefresh: _controller.refresh,
        child: GridView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
            childAspectRatio: 0.56,
          ),
          itemCount: items.length + (_controller.isLoadingMore.value ? 2 : 0),
          itemBuilder: (context, index) {
            if (index >= items.length) return _buildCardSkeleton();
            return _LikedProductCard(
              item: items[index],
              onUnlike: () => _controller.unlike(items[index]),
            );
          },
        ),
      );
    });
  }

  Widget _buildEmptyState(AppLocalizations l) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: constraints.maxHeight,
          width: double.infinity,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    l.noLikedProducts,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.noLikedProductsDesc,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        childAspectRatio: 0.56,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => _buildCardSkeleton(),
    );
  }

  Widget _buildCardSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 12, width: double.infinity, color: Colors.white),
          const SizedBox(height: 6),
          Container(height: 12, width: 80, color: Colors.white),
        ],
      ),
    );
  }
}

class _LikedProductCard extends StatelessWidget {
  final LikedProductModel item;
  final VoidCallback onUnlike;

  const _LikedProductCard({required this.item, required this.onUnlike});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(
            itemId: item.productId,
            userId: '',
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image + brand logo + heart ──
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  item.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: Colors.grey.shade200),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image,
                                color: Colors.grey),
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                  if (item.brandPicture.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(1, 1)),
                          ],
                        ),
                        padding: const EdgeInsets.all(4),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: item.brandPicture,
                            fit: BoxFit.contain,
                            errorWidget: (_, __, ___) =>
                                const Icon(Icons.store, size: 14),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: onUnlike,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(1, 1)),
                          ],
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.favorite,
                            color: Colors.red, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Brand ──
          if (item.brandName.isNotEmpty)
            Text(
              item.brandName.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.3,
                color: Colors.grey.shade700,
              ),
            ),

          // ── Name ──
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),

          // ── Price ──
          _buildPrice(),
        ],
      ),
    );
  }

  Widget _buildPrice() {
    final compareAt = item.compareAtPrice;
    final hasDiscount = compareAt != null && compareAt > item.price;
    if (!hasDiscount) {
      return Text(
        '${item.price}€',
        style: const TextStyle(
          fontFamily: 'Lato',
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Colors.black,
        ),
      );
    }
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: [
        TextSpan(
          text: '${item.price}€ ',
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.black,
          ),
        ),
        TextSpan(
          text: '$compareAt€ ',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: Colors.grey.shade500,
            decoration: TextDecoration.lineThrough,
            decorationColor: Colors.grey.shade500,
          ),
        ),
        // TextSpan(
        //   text: '-${item.discountPercent}%',
        //   style: const TextStyle(
        //     fontFamily: 'Lato',
        //     fontWeight: FontWeight.bold,
        //     fontSize: 12,
        //     color: Color(0xFFE53935),
        //   ),
        // ),
      ]),
    );
  }
}
