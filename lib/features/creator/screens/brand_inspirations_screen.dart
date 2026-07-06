import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:happer_app/features/creator/bindings/creator_binding.dart';
import 'package:happer_app/features/creator/controllers/brand_inspirations_controller.dart';
import 'package:happer_app/features/creator/data/models/creator_selfie_model.dart';
import 'package:happer_app/features/creator/data/repositories/creator_repository.dart';
import 'package:happer_app/features/creator/screens/selfie_details_screen.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:shimmer/shimmer.dart';

/// "INSPIRATIONS {BRAND}" — a DECOUVRIR-style masonry grid of selfies linked to
/// one brand, with the brand logos shown on each card.
class BrandInspirationsScreen extends StatefulWidget {
  final String brandId;
  final String brandName;

  const BrandInspirationsScreen({
    super.key,
    required this.brandId,
    required this.brandName,
  });

  @override
  State<BrandInspirationsScreen> createState() =>
      _BrandInspirationsScreenState();
}

class _BrandInspirationsScreenState extends State<BrandInspirationsScreen> {
  late final BrandInspirationsController _controller;
  final ScrollController _scrollController = ScrollController();
  late final String _tag;

  @override
  void initState() {
    super.initState();
    CreatorBinding().dependencies();
    _tag = 'brand_insp_${widget.brandId}';
    _controller = Get.put(
      BrandInspirationsController(Get.find<CreatorRepository>(), widget.brandId),
      tag: _tag,
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    Get.delete<BrandInspirationsController>(tag: _tag);
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 600 &&
        _controller.hasMore.value &&
        !_controller.isLoadingMore.value) {
      _controller.fetch();
    }
  }

  void _openSelfie(CreatorSelfieModel selfie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelfieDetailsScreen(
          selfieId: selfie.id,
          initialLikes: selfie.likesCount,
          isLikedByMe: selfie.isLikedByMe,
          model: selfie.toCreatorModel(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          HapperAppBar(title: 'INSPIRATIONS ${widget.brandName.toUpperCase()}'),
      body: Obx(() {
        final selfies = _controller.selfies;
        final isLoading = _controller.isLoading.value;
        final isLoadingMore = _controller.isLoadingMore.value;
        final error = _controller.errorMessage.value;

        if (isLoading && selfies.isEmpty) return _buildShimmerGrid();
        if (error != null && selfies.isEmpty) return _buildError();
        if (selfies.isEmpty) return _buildEmpty();

        return RefreshIndicator(
          color: Colors.black,
          onRefresh: _controller.refresh,
          child: MasonryGridView.count(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(3),
            crossAxisCount: 2,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            itemCount: selfies.length + (isLoadingMore ? 2 : 0),
            itemBuilder: (context, index) {
              if (index >= selfies.length) return _buildShimmerCard();
              return _buildCard(selfies[index]);
            },
          ),
        );
      }),
    );
  }

  Widget _buildCard(CreatorSelfieModel selfie) {
    final image = selfie.images.isNotEmpty ? selfie.images.first : '';
    final brands = selfie.uniqueBrands;
    return GestureDetector(
      onTap: () => _openSelfie(selfie),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 2.5),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
        child: AspectRatio(
          aspectRatio: 0.7,
          child: Stack(
            fit: StackFit.expand,
            children: [
              image.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: image,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                            child: Icon(Icons.broken_image, size: 40)),
                      ),
                    )
                  : Container(color: Colors.grey.shade200),
              if (brands.isNotEmpty)
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: _buildBrandLogos(brands),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Overlapping circular brand logos, bottom-left of the card.
  Widget _buildBrandLogos(List<Map<String, dynamic>> brands) {
    const double size = 34;
    const double overlap = 12;
    final shown = brands.take(3).toList();
    final totalWidth = shown.length * size - (shown.length - 1) * overlap;
    return SizedBox(
      width: totalWidth,
      height: size,
      child: Stack(
        children: List.generate(shown.length, (i) {
          final picture = (shown[i]['picture'] as String? ?? '').trim();
          return Positioned(
            left: i * (size - overlap),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26, blurRadius: 4, offset: Offset(1, 1)),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: ClipOval(
                child: picture.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: picture,
                        fit: BoxFit.contain,
                        placeholder: (_, __) =>
                            Container(color: Colors.grey.shade200),
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.store, size: 16, color: Colors.grey),
                      )
                    : const Icon(Icons.store, size: 16, color: Colors.grey),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return MasonryGridView.count(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(3),
      crossAxisCount: 2,
      itemCount: 8,
      itemBuilder: (_, __) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 2.5),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
      child: AspectRatio(
        aspectRatio: 0.7,
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
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
                children: [
                  Icon(Icons.image_outlined,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune inspiration',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
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

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 64, color: Colors.black38),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _controller.refresh,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            child: const Text('Réessayer',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
