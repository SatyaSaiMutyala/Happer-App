import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/app_manager.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/features/creator/bindings/creator_binding.dart';
import 'package:happer_app/features/creator/controllers/creator_controller.dart';
import 'package:happer_app/features/creator/data/models/creator_selfie_model.dart';
import 'package:happer_app/features/creator/screens/brand_details_screen.dart';
import 'package:happer_app/features/creator/screens/selfie_details_screen.dart';
import 'package:happer_app/features/profile/screens/image_grid_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CreatorShimmer extends StatelessWidget {
  final int itemCount;
  const CreatorShimmer({this.itemCount = 5, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: [
              ListTile(
                leading: const CircleAvatar(
                    radius: 20, backgroundColor: Colors.white),
                title: Container(height: 10, width: 100, color: Colors.white),
                subtitle: Container(height: 10, width: 50, color: Colors.white),
              ),
              AspectRatio(
                aspectRatio: 4 / 5,
                child: Container(width: double.infinity, color: Colors.white),
              ),
              const Divider(),
            ],
          ),
        );
      },
    );
  }
}

class CreatorTabScreen extends StatefulWidget {
  const CreatorTabScreen({Key? key}) : super(key: key);

  @override
  CreatorTabScreenState createState() => CreatorTabScreenState();
}

class CreatorTabScreenState extends State<CreatorTabScreen> {
  late final CreatorController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    CreatorBinding().dependencies();
    _controller = Get.find<CreatorController>();
    _scrollController.addListener(_onScroll);
    // Controller may already be alive (onReady won't fire again) — trigger load if not started.
    if (_controller.selfies.isEmpty && !_controller.isLoading.value) {
      _controller.fetchSelfies(firstLoad: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> forceRefresh() => _controller.refresh();

  void searchCreators(String query) {
    _controller.setSearchQuery(query);
  }

  /// Filter the feed to a single brand's selfies (from a search suggestion).
  void applyBrandFilter(String brandId) {
    _controller.applyBrandFilter(brandId);
  }

  void _onScroll() {
    final pixels = _scrollController.position.pixels;
    final max = _scrollController.position.maxScrollExtent;
    final viewport = _scrollController.position.viewportDimension;

    if (pixels > 300 && !_controller.showScrollToTop.value) {
      _controller.showScrollToTop.value = true;
    } else if (pixels <= 300 && _controller.showScrollToTop.value) {
      _controller.showScrollToTop.value = false;
    }

    if (pixels + viewport >= max) {
      _controller.fetchSelfies();
    }
  }

  /// Smoothly scrolls the feed back to the top (Instagram-style: re-tapping
  /// the home icon while already on this tab). Safe to call when the list
  /// isn't attached yet.
  void scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
  }

  Widget _buildBrandLogos(
      BuildContext context, List<Map<String, dynamic>> brands,
      {String affiliateId = ''}) {
    const logoSize = 48.0;
    const overlap = 16.0;
    final totalWidth = brands.length * logoSize - (brands.length - 1) * overlap;
    return SizedBox(
      width: totalWidth,
      height: logoSize,
      child: Stack(
        children: List.generate(brands.length, (i) {
          final brand = brands[i];
          final picture = brand['picture'] as String;
          return Positioned(
            left: i * (logoSize - overlap),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BrandDetailsScreen(
                      brandId: brand['_id'] as String? ?? '',
                      brandName: brand['name'] as String? ?? '',
                      brandDescription: brand['description'] as String? ?? '',
                      brandLogo: picture,
                      affiliateId: affiliateId,
                    ),
                  ),
                );
              },
              child: Container(
                height: logoSize,
                width: logoSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(1, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(6),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: picture,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => Container(color: Colors.grey.shade200),
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.image, size: 24, color: Colors.grey),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<void> _onImageTap(CreatorSelfieModel selfie) async {
    await Navigator.push(
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

  Widget _buildMainImage(String url) {
    if (url.isEmpty) {
      return AspectRatio(
        aspectRatio: 4 / 5,
        child: Container(
          width: double.infinity,
          color: Colors.grey.shade200,
          child: const Icon(Icons.image, size: 50, color: Colors.grey),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: CachedNetworkImage(
        imageUrl: url,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: Colors.grey.shade200),
        errorWidget: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image)),
      ),
    );
  }

  String _getTimeDifference(String? createdAt, AppLocalizations l) {
    if (createdAt == null) return '';
    try {
      final diff = DateTime.now().difference(DateTime.parse(createdAt));
      if (diff.inMinutes < 1) return l.justNow;
      if (diff.inMinutes < 60) return l.minutesAgo(diff.inMinutes);
      if (diff.inHours < 24) return l.hoursAgo(diff.inHours);
      if (diff.inDays < 7) return l.daysAgo(diff.inDays);
      if (diff.inDays < 30) {
        final w = (diff.inDays / 7).floor();
        return w == 1 ? l.weekAgo(w) : l.weeksAgo(w);
      }
      if (diff.inDays < 365) return l.monthsAgo((diff.inDays / 30).floor());
      final y = (diff.inDays / 365).floor();
      return y == 1 ? l.yearAgo(y) : l.yearsAgo(y);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Obx(() {
      // Search is performed server-side (see CreatorController.setSearchQuery),
      // so the list already reflects the active query.
      final allSelfies = _controller.selfies;
      final selfies = allSelfies;
      final isLoading = _controller.isLoading.value;
      final errorMessage = _controller.errorMessage.value;

      if (allSelfies.isEmpty && isLoading) {
        return const CreatorShimmer();
      }

      if (allSelfies.isEmpty && errorMessage != null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(errorMessage, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _controller.refresh,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        );
      }

      if (allSelfies.isEmpty) {
        return Center(child: Text(l.noDataFound));
      }

      return Stack(
        children: [
          RefreshIndicator(
            onRefresh: _controller.refresh,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: selfies.length + 1,
              itemBuilder: (context, index) {
                if (index == selfies.length) {
                  if (isLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: CreatorShimmer(itemCount: 1),
                    );
                  }
                  if (!_controller.hasMore.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              'Vous êtes à jour.',
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'De nouveaux looks arrivent bientôt.',
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Color(0xFF8D8D8D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }

                final selfie = selfies[index];
                final imageUrl =
                    selfie.images.isNotEmpty ? selfie.images.first : '';
                final user = selfie.user;
                final displayName = user?.username.isNotEmpty == true
                    ? user!.username
                    : (user?.fullname ?? '');

                return GestureDetector(
                  onTap: () => _onImageTap(selfie),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (AppManager.isLoginAsGuest) {
                                  showAppSnackBar('Please login first',
                                      isSuccess: false);
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ImageGridScreen(userId: user?.id ?? ''),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey.shade200,
                                    child: ClipOval(
                                      child: user?.hasPicture == true
                                          ? CachedNetworkImage(
                                              imageUrl: user!.profileImage!,
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                              errorWidget: (_, __, ___) =>
                                                  const Icon(Icons.person,
                                                      size: 20),
                                            )
                                          : const Icon(Icons.person, size: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    displayName,
                                    style: const TextStyle(
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (user?.role == 1) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.verified,
                                        color: Colors.black, size: 18),
                                  ],
                                ],
                              ),
                            ),
                            Text(
                              _getTimeDifference(selfie.createdAt, l),
                              style: const TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Color(0xFF8D8D8D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Stack(
                        children: [
                          Builder(builder: (context) {
                            final tc = TransformationController();
                            return InteractiveViewer(
                              transformationController: tc,
                              panEnabled: true,
                              scaleEnabled: true,
                              minScale: 1.0,
                              maxScale: 4.0,
                              clipBehavior: Clip.none,
                              onInteractionEnd: (_) =>
                                  tc.value = Matrix4.identity(),
                              child: _buildMainImage(imageUrl),
                            );
                          }),
                          if (selfie.uniqueBrands.isNotEmpty)
                            Positioned(
                              bottom: 12,
                              left: 12,
                              child: _buildBrandLogos(
                                  context, selfie.uniqueBrands,
                                  affiliateId: user?.id ?? ''),
                            ),
                          if (!AppManager.isLoginAsGuest)
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => _controller.toggleLike(selfie.id),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0x33000000),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.favorite,
                                    color: selfie.isLikedByMe
                                        ? Colors.red
                                        : Colors.white,
                                    size: 25,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
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
