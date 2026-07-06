import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/features/creator/screens/liked_products_screen.dart';
import 'package:happer_app/features/creator/screens/selfie_details_screen.dart';
import 'package:happer_app/features/profile/bindings/liked_selfies_binding.dart';
import 'package:happer_app/features/profile/controllers/liked_selfies_controller.dart';
import 'package:happer_app/features/profile/models/liked_selfie_model.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:shimmer/shimmer.dart';

class LikedImagesScreen extends StatefulWidget {
  @override
  _LikedImagesScreenState createState() => _LikedImagesScreenState();
}

class _LikedImagesScreenState extends State<LikedImagesScreen> {
  late final LikedSelfiesController _controller;
  final _scrollController = ScrollController();
  int _tab = 0; // 0 = liked posts (selfies), 1 = liked products

  @override
  void initState() {
    super.initState();
    Get.delete<LikedSelfiesController>(force: true);
    LikedSelfiesBinding().dependencies();
    _controller = Get.find<LikedSelfiesController>();
    _scrollController.addListener(_onScroll);
    _controller.refresh();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    Get.delete<LikedSelfiesController>(force: true);
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _controller.loadMore();
    }
  }

  void _onTap(LikedSelfieModel selfie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelfieDetailsScreen(
          selfieId: selfie.id,
          initialLikes: selfie.likesCount,
          isLikedByMe: selfie.isLikedByMe,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HapperAppBar(title: l.mesFavorisTitle),
      body: Column(
        children: [
          _buildToggle(l),
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: [
                _buildSelfiesTab(l),
                const LikedProductsView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Segmented pill toggle: Posts | Products.
  Widget _buildToggle(AppLocalizations l) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _segment(l.favTabPosts, 0),
          _segment(l.favTabProducts, 1),
        ],
      ),
    );
  }

  Widget _segment(String label, int index) {
    final selected = _tab == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_tab != index) setState(() => _tab = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.3,
              color: selected ? Colors.white : const Color(0xFF8D8D8D),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelfiesTab(AppLocalizations l) {
    return Obx(() {
        final isLoading = _controller.isLoading.value;
        final selfies = _controller.selfies;
        final isLoadingMore = _controller.isLoadingMore.value;

        if (isLoading) return _ShimmerGrid();

        if (selfies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_border, size: 64, color: Colors.black),
                const SizedBox(height: 16),
                Text(
                  l.noFavoritesYet,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lato',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l.favoritesWillAppearHere,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Lato',
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _controller.refresh,
          color: Colors.black,
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8),
            itemCount: selfies.length + (isLoadingMore ? 2 : 0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              if (index >= selfies.length) return _ShimmerCell();

              final selfie = selfies[index];
              return GestureDetector(
                onTap: () => _onTap(selfie),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: selfie.hasImage
                            ? CachedNetworkImage(
                                imageUrl: selfie.primaryImage,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  color: Colors.grey.shade200,
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.broken_image,
                                      color: Colors.grey),
                                ),
                              )
                            : Container(color: Colors.grey.shade200),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => _controller.unlike(selfie.id),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.redAccent,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      });
  }
}

class _ShimmerGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 12,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemBuilder: (_, __) => _ShimmerCell(),
      ),
    );
  }
}

class _ShimmerCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(color: Colors.white),
      ),
    );
  }
}
