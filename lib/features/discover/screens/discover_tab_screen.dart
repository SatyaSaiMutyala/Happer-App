import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:happer_app/app_manager.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/features/selfies/bindings/selfie_binding.dart';
import 'package:happer_app/features/selfies/controllers/selfie_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import 'package:happer_app/features/discover/models/discover_model.dart';
import 'package:happer_app/features/discover/screens/discover_detail_screen.dart';
import 'package:happer_app/features/selfies/data/models/selfie_model.dart';
import 'package:happer_app/l10n/app_localizations.dart';

class DiscoverTabScreen extends StatefulWidget {
  const DiscoverTabScreen({Key? key}) : super(key: key);

  @override
  State<DiscoverTabScreen> createState() => DiscoverTabScreenState();
}

class DiscoverTabScreenState extends State<DiscoverTabScreen> {
  late final SelfieController _controller;
  final ScrollController _scrollController = ScrollController();
  bool _hasShownGuestSnackBar = false;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<SelfieController>()) {
      SelfieBinding().dependencies();
    }
    _controller = Get.find<SelfieController>();
    _scrollController.addListener(_onScroll);
    // Controller may already be alive from another tab — trigger load if not started.
    if (_controller.discoverSelfies.isEmpty && !_controller.isDiscoverLoading.value) {
      _controller.fetchDiscoverSelfies();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.position.pixels;
    final max = _scrollController.position.maxScrollExtent;

    if (offset > 300 && !_controller.showScrollToTop.value) {
      _controller.showScrollToTop.value = true;
    } else if (offset <= 300 && _controller.showScrollToTop.value) {
      _controller.showScrollToTop.value = false;
    }

    if (offset >= max - 600 && !_controller.isDiscoverLoadingMore.value && _controller.hasDiscoverMore.value) {
      if (AppManager.isLoginAsGuest && _controller.discoverSelfies.length >= 10) {
        if (!_hasShownGuestSnackBar) {
          showAppSnackBar(AppLocalizations.of(context).loginToSeeContent, isSuccess: false);
          _hasShownGuestSnackBar = true;
        }
        return;
      }
      _controller.loadMoreDiscoverSelfies();
    }
  }

  void scrollToTop() {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
  }

  DiscoverModel _toDiscoverModel(SelfieModel s) {
    return DiscoverModel.fromJson({
      '_id': s.id,
      'state': s.state ?? '',
      'created_at': s.createdAt ?? '',
      'likes': [],
      'users_type': s.user?.usersType ?? 0,
      'items_id': [],
      'picture': s.primaryImage,
      'nb_like': s.nbLike,
      'isLikedByMe': s.isLikedByMe,
      'user': s.user != null
          ? {
              '_id': s.user!.id,
              'username': s.user!.username,
              'first_name': s.user!.firstName,
              'last_name': s.user!.lastName,
              'picture': s.user!.picture,
            }
          : null,
    });
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selfies = _controller.discoverSelfies;
      final isLoading = _controller.isDiscoverLoading.value;
      final isLoadingMore = _controller.isDiscoverLoadingMore.value;
      final error = _controller.discoverError.value;

      if (isLoading) {
        return MasonryGridView.count(
          physics: const AlwaysScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          itemCount: 8,
          itemBuilder: (_, __) => _buildShimmerCard(),
        );
      }

      if (error != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 64, color: Colors.black38),
              const SizedBox(height: 16),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _controller.fetchDiscoverSelfies(refresh: true),
                child: Text(AppLocalizations.of(context).tryAgainButton),
              ),
            ],
          ),
        );
      }

      if (selfies.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => _controller.fetchDiscoverSelfies(refresh: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.3),
              const Icon(Icons.image_outlined, size: 64, color: Colors.black38),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).noImagesFound,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).noImagesFoundSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black38),
              ),
            ],
          ),
        );
      }

      return Stack(
        children: [
          RefreshIndicator(
            onRefresh: () {
              _hasShownGuestSnackBar = false;
              return _controller.fetchDiscoverSelfies(refresh: true);
            },
            child: MasonryGridView.count(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
              itemCount: selfies.length + (isLoadingMore ? 2 : 0),
              itemBuilder: (context, index) {
                if (index >= selfies.length) return _buildShimmerCard();

                final selfie = selfies[index];
                return GestureDetector(
                  onTap: () {
                    if (AppManager.isLoginAsGuest) {
                      showAppSnackBar(
                          AppLocalizations.of(context).pleaseLoginFirst,
                          isSuccess: false);
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DiscoverDetailScreen(
                          selfieModel: _toDiscoverModel(selfie),
                          isFromMyImages: false,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 2.5, vertical: 2.5),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1)),
                    child: AspectRatio(
                      aspectRatio: 0.7,
                      child: CachedNetworkImage(
                        imageUrl: selfie.primaryImage,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(height: 150, color: Colors.white),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          height: 150,
                          color: Colors.grey[300],
                          child: const Center(
                              child: Icon(Icons.broken_image, size: 50)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_controller.showScrollToTop.value)
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                backgroundColor: Colors.black.withValues(alpha: 0.6),
                mini: true,
                onPressed: scrollToTop,
                child: const Icon(Icons.arrow_upward, color: Colors.white),
              ),
            ),
        ],
      );
    });
  }
}
