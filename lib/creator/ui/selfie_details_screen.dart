import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:happer_app/app_manager.dart';
import 'package:happer_app/creator/api/creator_api.dart';
import 'package:happer_app/creator/model/creator_model.dart';
import 'package:happer_app/creator/model/items_model.dart' hide BrandId;
import 'package:happer_app/creator/ui/product_details_screen.dart';
import 'package:happer_app/creator/ui/brand_details_screen.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../profile/ui/image_grid_screen.dart';

class SelfieDetailsScreen extends StatefulWidget {
  final String selfieId;
  final int? initialLikes;
  final bool? isLikedByMe;

  const SelfieDetailsScreen({
    Key? key,
    required this.selfieId,
    this.initialLikes,
    this.isLikedByMe,
  }) : super(key: key);

  @override
  _SelfieDetailsScreenState createState() => _SelfieDetailsScreenState();
}

class _SelfieDetailsScreenState extends State<SelfieDetailsScreen>
    with SingleTickerProviderStateMixin {
  late CreatorModel? _selfie;
  late int _likes;
  late bool _isLiked;
  bool _isLoading = true;
  bool _isToggling = false;
  Map<String, List<ItemsModel>> _brandItemsMap = {};
  Map<String, BrandId> _brandInfoMap = {};
  bool _isBrandItemsLoading = false;
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

    _fetchSelfieDetails();
  }

  Future<void> _fetchSelfieDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    print(
        "Fetching selfie details for ID: ${widget.selfieId} with token: $token");
    final service = CreatorApiService(token: token);

    try {
      final fetchedSelfie = await service.getSelfieById(widget.selfieId);
      setState(() {
        _selfie = fetchedSelfie;
        _likes = fetchedSelfie.nbLike ?? _likes;
        _isLiked = fetchedSelfie.isLikedByMe ?? _isLiked;
        _isLoading = false;
      });

      // Fetch brand items after selfie details are loaded
      _fetchBrandItems();
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      // Handle error (e.g., show a snackbar or log the error)
    }
  }

  Future<void> _fetchBrandItems() async {
    // Get all unique brands from exact match items
    final seenIds = <String>{};
    final uniqueBrands = <BrandId>[];
    for (final item in _selfie?.itemsId ?? []) {
      if (item.exactMatch == true &&
          item.item?.brandId?.sId != null &&
          seenIds.add(item.item!.brandId!.sId!)) {
        uniqueBrands.add(item.item!.brandId!);
      }
    }

    if (uniqueBrands.isEmpty) return;

    setState(() {
      _isBrandItemsLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final service = CreatorApiService(token: token);

    try {
      for (final brand in uniqueBrands) {
        final brandResponse = await service.fetchBrandAllItems(brand.sId!, page: 1, limit: 10);
        _brandItemsMap[brand.sId!] = brandResponse.items;
        _brandInfoMap[brand.sId!] = brand;
      }

      setState(() {
        _isBrandItemsLoading = false;
      });
    } catch (error) {
      debugPrint('Error fetching brand items: $error');
      setState(() {
        _isBrandItemsLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isToggling) return;
    setState(() => _isToggling = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final service = CreatorApiService(token: token);

    try {
      if (_isLiked) {
        await service.dislikeSelfie(_selfie!.sId ?? '');
        setState(() {
          _isLiked = false;
          _likes = _likes > 0 ? _likes - 1 : 0;
        });
      } else {
        await service.likeSelfie(_selfie!.sId ?? '');
        setState(() {
          _isLiked = true;
          _likes++;
        });
      }
      await _fetchSelfieDetails();
      // Navigator.pop(context, true);
    } catch (_) {}

    setState(() => _isToggling = false);
  }

  String _getTimeDifference(String createdAt) {
    final createdTime = DateTime.parse(createdAt);
    final currentTime = DateTime.now();
    final difference = currentTime.difference(createdTime);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'il y a ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'il y a ${difference.inDays} j';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'il y a $weeks ${weeks == 1 ? 'semaine' : 'semaines'}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'il y a $months mois';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'il y a $years ${years == 1 ? 'an' : 'ans'}';
    }
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    if (AppManager.isLoginAsGuest) return;

    setState(() => _showHeart = true);
    _heartAnimationController.forward(from: 0.0);

    if (!_isLiked) {
      _toggleFavorite();
    }
  }

  String _truncateWithEllipsis(String? text, {int maxLength = 10}) {
    if (text == null || text.isEmpty) return 'Unknown';
    return text.length > maxLength
        ? '${text.substring(0, maxLength)}...'
        : text;
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
            // Main image placeholder
            Stack(
              children: [
                Container(
                  height: 400,
                  width: double.infinity,
                  color: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 20, backgroundColor: Colors.white),
                      const SizedBox(width: 8),
                      Container(height: 14, width: 100, color: Colors.white),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: CircleAvatar(radius: 24, backgroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Time + like row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(height: 14, width: 80, color: Colors.white),
                  Container(height: 20, width: 20, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(height: 1, width: double.infinity, color: Colors.white),
            ),
            const SizedBox(height: 16),
            // Section title
            Padding(
              padding: const EdgeInsets.only(left: 11),
              child: Container(height: 14, width: 160, color: Colors.white),
            ),
            const SizedBox(height: 12),
            // Horizontal product cards
            SizedBox(
              height: 210,
              child: Padding(
                padding: const EdgeInsets.only(left: 11),
                child: Row(
                  children: List.generate(4, (index) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 180, width: 125, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(height: 8),
                        Container(height: 12, width: 100, color: Colors.white),
                      ],
                    ),
                  )),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Second section title
            Padding(
              padding: const EdgeInsets.only(left: 11),
              child: Container(height: 14, width: 130, color: Colors.white),
            ),
            const SizedBox(height: 12),
            // Second horizontal product cards
            SizedBox(
              height: 210,
              child: Padding(
                padding: const EdgeInsets.only(left: 11),
                child: Row(
                  children: List.generate(4, (index) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 180, width: 125, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(height: 8),
                        Container(height: 12, width: 100, color: Colors.white),
                      ],
                    ),
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(
              context,
            ).pop(); // Simple navigation back without custom routing
          },
        ),
        title: const Text(
          // 'SHOP THE STYLE',
          'SHOP LE LOOK',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            height: 1.0, // line-height 100%
            letterSpacing: 0.0,
          ),
        ),
      ),
      body: _isLoading
          ? _buildShimmerLoading()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display the selfie image with user details
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onDoubleTap: _onDoubleTap,
                    child: Stack(
                      children: [
                        PinchZoom(
                          zoomEnabled: true,
                          maxScale: 4.0,
                          onZoomStart: () {},
                          onZoomEnd: () {},
                        child: CachedNetworkImage(
                          imageUrl: _selfie?.picture ?? '',
                          height: 400,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                              height: 400,
                              width: double.infinity,
                              color: Colors.white,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 400,
                            width: double.infinity,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 56),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ImageGridScreen(
                                          userId: _selfie!.user!.sId ?? '',
                                        ),
                                      ),
                                    );
                                  },
                                  child: CircleAvatar(
                                    backgroundImage: _selfie!.user?.picture !=
                                                null &&
                                            _selfie!.user!.picture!.isNotEmpty
                                        ? CachedNetworkImageProvider(
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
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ImageGridScreen(
                                          userId: _selfie!.user!.sId ?? '',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    _selfie!.user?.userName ??
                                        '${_selfie!.user?.firstName ?? ''} ${_selfie!.user?.lastName ?? ''}'
                                            .trim(),
                                    style: const TextStyle(
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      height: 1.0, // line-height 100%
                                      letterSpacing: 0.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.verified,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Color(
                                  0x33000000,
                                ), // Updated grey circular background
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.share,
                                  size: 24,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  final selfieId = _selfie?.sId ?? '';
                                  if (selfieId.isNotEmpty) {
                                    final encodedId = base64Url.encode(utf8.encode(selfieId));
                                    final deepLink =
                                        'https://newapi.happer.fr/store/$encodedId';
                                    // On iPad (iOS) the share sheet needs a non-zero
                                    // source rect for the popover. Provide a
                                    // `sharePositionOrigin` using the button's
                                    // RenderBox so the platform plugin can present
                                    // the share sheet safely.
                                    try {
                                      final RenderBox? box = context
                                          .findRenderObject() as RenderBox?;
                                      if (box != null && box.hasSize) {
                                        final origin =
                                            box.localToGlobal(Offset.zero) &
                                                box.size;
                                        Share.share(
                                          'Check out this selfie on Happer! $deepLink',
                                          sharePositionOrigin: origin,
                                        );
                                      } else {
                                        // Fallback if RenderBox not available
                                        Share.share(
                                            'Check out this selfie on Happer! $deepLink');
                                      }
                                    } catch (e) {
                                      // If anything goes wrong, fall back to basic share
                                      Share.share(
                                          'Check out this selfie on Happer! $deepLink');
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --- BRAND LOGOS (bottom-left on main image) ---
                      if (_selfie?.itemsId != null &&
                          _selfie!.itemsId!.any((item) =>
                              item.exactMatch == true &&
                              item.item?.brandId?.picture != null))
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: () {
                            final seenBrandIds = <String>{};
                            final uniqueBrandItems = <ItemsId>[];
                            for (final item in _selfie!.itemsId!) {
                              if (item.exactMatch == true &&
                                  item.item?.brandId?.picture != null &&
                                  item.item?.brandId?.sId != null &&
                                  seenBrandIds.add(item.item!.brandId!.sId!)) {
                                uniqueBrandItems.add(item);
                              }
                            }
                            final logoSize = 48.0;
                            final overlap = 16.0;
                            final totalWidth = uniqueBrandItems.length * logoSize - (uniqueBrandItems.length - 1) * overlap;
                            return SizedBox(
                              width: totalWidth,
                              height: logoSize,
                              child: Stack(
                                children: List.generate(uniqueBrandItems.length, (i) {
                                  final brand = uniqueBrandItems[i].item!.brandId!;
                                  return Positioned(
                                    left: i * (logoSize - overlap),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BrandDetailsScreen(
                                              brandId: brand.sId ?? '',
                                              brandName: brand.name ?? '',
                                              brandDescription: brand.description ?? '',
                                              brandLogo: brand.picture ?? '',
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
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 6,
                                              offset: Offset(1, 2),
                                            )
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl: brand.picture!,
                                            fit: BoxFit.contain,
                                            placeholder: (context, url) => Container(
                                              color: Colors.grey.shade200,
                                            ),
                                            errorWidget: (context, url, error) => Icon(
                                              Icons.image,
                                              size: 24,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            );
                          }(),
                        ),

                        // Add a share button at the right end of the image
                        if (_showHeart)
                          Positioned.fill(
                            child: Center(
                              child: AnimatedBuilder(
                                animation: _heartAnimationController,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _heartOpacityAnimation.value,
                                    child: Transform.scale(
                                      scale: _heartScaleAnimation.value,
                                      child: const Icon(
                                        Icons.favorite,
                                        color: Colors.white,
                                        size: 100,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 20,
                                            color: Colors.black38,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            _getTimeDifference(
                              _selfie!.createdAt ??
                                  DateTime.now().toIso8601String(),
                            ),
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              height:
                                  1.0, // Line height as a multiplier of font size
                              letterSpacing: 0.0,
                              color: Color(0xFF8D8D8D), // Text color
                            ),
                          ),
                        ),
                        if (!AppManager.isLoginAsGuest)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Text(
                              //   '$_likes',
                              //   style: const TextStyle(
                              //     fontSize: 14,
                              //     fontWeight: FontWeight.w700,
                              //     color: Colors.black,
                              //   ),
                              // ),
                              IconButton(
                                icon: Icon(
                                  Icons.favorite,
                                  size: 20,
                                  color: _isLiked ? Colors.red : Colors.grey,
                                ),
                                onPressed: _isToggling ? null : _toggleFavorite,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Divider(thickness: 1),
                  ),

                  // Display the exact match product with horizontal scrollable images
                  if (_selfie!.itemsId != null &&
                      _selfie!.itemsId!.any(
                        (item) => item.exactMatch == true,
                      ))
                    Column(
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
                                letterSpacing: 0.0,
                                color: Color(0xFF8D8D8D),
                              ),
                              children: [
                                const TextSpan(text: 'La Séléction de '),
                                TextSpan(
                                  text: _selfie!.user?.userName ??
                                      _selfie!.user?.firstName ??
                                      '',
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
                          height: 210,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 11),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: _selfie!.itemsId!
                                  .where(
                                    (item) => item.exactMatch == true,
                                  )
                                  .map(
                                    (item) => Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (item.item?.pictures != null &&
                                              item.item!.pictures!.isNotEmpty)
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (
                                                      context,
                                                    ) =>
                                                        ProductDetailsScreen(
                                                      itemId: item.item!.sId ??
                                                          '', // Pass only the specific item ID
                                                      userId: _selfie!
                                                              .user?.sId ??
                                                          '', // Pass the userId
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(0),
                                                child: Stack(
                                                  children: [
                                                    // --- MAIN PRODUCT IMAGE ----
                                                    PinchZoom(
                                                      maxScale: 3.0,
                                                      onZoomStart: () {},
                                                      onZoomEnd: () {},
                                                      child: CachedNetworkImage(
                                                        imageUrl: item.item!
                                                            .pictures!.first,
                                                        height: 180,
                                                        width: 125,
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (context, url) =>
                                                                Shimmer.fromColors(
                                                          baseColor: Colors.grey.shade300,
                                                          highlightColor: Colors.grey.shade100,
                                                          child: Container(
                                                            height: 180,
                                                            width: 125,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Container(
                                                          height: 180,
                                                          width: 125,
                                                          color: Colors
                                                              .grey.shade200,
                                                          child: const Center(
                                                            child: Icon(
                                                                Icons
                                                                    .broken_image,
                                                                size: 36),
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    // --- BRAND LOGO (top-left circle) ---
                                                    if (item.item?.brandId
                                                            ?.picture !=
                                                        null)
                                                      Positioned(
                                                        top: 6,
                                                        left: 6,
                                                        child: Container(
                                                          height: 32,
                                                          width: 32,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Colors
                                                                .white, // white background for clarity
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black26,
                                                                blurRadius: 4,
                                                                offset: Offset(
                                                                    1, 1),
                                                              )
                                                            ],
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4),
                                                          child: ClipOval(
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl: item
                                                                  .item!
                                                                  .brandId!
                                                                  .picture!,
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),

                                              //   child: ClipRRect(
                                              //     borderRadius:
                                              //         BorderRadius.circular(
                                              //       14,
                                              //     ),
                                              //       child: PinchZoom(
                                              //       maxScale: 3.0,
                                              //       onZoomStart: () {},
                                              //       onZoomEnd: () {},
                                              //       child: CachedNetworkImage(
                                              //         imageUrl:
                                              //             item.item!.pictures!.first,
                                              //         height: 180,
                                              //         width: 125,
                                              //         fit: BoxFit.cover,
                                              //         placeholder: (context, url) => Container(
                                              //           height: 180,
                                              //           width: 125,
                                              //           color: Colors.grey.shade200,
                                              //           child: const Center(
                                              //               child:
                                              //                   CircularProgressIndicator()),
                                              //         ),
                                              //         errorWidget:
                                              //             (context, url, error) => Container(
                                              //           height: 180,
                                              //           width: 125,
                                              //           color: Colors.grey.shade200,
                                              //           child: const Center(
                                              //             child: Icon(Icons.broken_image, size: 36),
                                              //           ),
                                              //         ),
                                              //       ),
                                              //   ),
                                              // ),
                                            ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '${_truncateWithEllipsis(item.item?.name)} ${(item.item?.price ?? 0).toStringAsFixed(0)}€',
                                            style: const TextStyle(
                                              fontFamily: 'Lato',
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.italic,
                                              fontSize: 14,
                                              height: 1.0,
                                              letterSpacing: 0.0,
                                              color: Color(0xFF8D8D8D),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // Updated the ListView style and text style for similar products to match the exact match style
                  if (_selfie!.itemsId != null &&
                      _selfie!.itemsId!.any(
                        (item) => item.exactMatch != true,
                      ))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 11),
                          child: const Text(
                            'Autour de ce look',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Lato',

                              fontStyle: FontStyle.italic,
                              height: 1.0, // line-height 100%
                              letterSpacing: 0.0,
                              color: Color(0xFF8D8D8D),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 210,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 11),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: _selfie!.itemsId!
                                  .where(
                                    (item) => item.exactMatch != true,
                                  )
                                  .map(
                                    (item) => Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (item.item?.pictures != null &&
                                              item.item!.pictures!.isNotEmpty)
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (
                                                      context,
                                                    ) =>
                                                        ProductDetailsScreen(
                                                      itemId: item.item!.sId ??
                                                          '', // Pass only the specific item ID
                                                      userId: _selfie!
                                                              .user?.sId ??
                                                          '', // Pass the userId
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(0),
                                                child: Stack(
                                                  children: [
                                                    // --- MAIN PRODUCT IMAGE ----
                                                    PinchZoom(
                                                      maxScale: 3.0,
                                                      onZoomStart: () {},
                                                      onZoomEnd: () {},
                                                      child: CachedNetworkImage(
                                                        imageUrl: item.item!
                                                            .pictures!.first,
                                                        height: 180,
                                                        width: 125,
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (context, url) =>
                                                                Shimmer.fromColors(
                                                          baseColor: Colors.grey.shade300,
                                                          highlightColor: Colors.grey.shade100,
                                                          child: Container(
                                                            height: 180,
                                                            width: 125,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Container(
                                                          height: 180,
                                                          width: 125,
                                                          color: Colors
                                                              .grey.shade200,
                                                          child: const Center(
                                                            child: Icon(
                                                                Icons
                                                                    .broken_image,
                                                                size: 36),
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    // --- BRAND LOGO (top-left circle) ---
                                                    if (item.item?.brandId
                                                            ?.picture !=
                                                        null)
                                                      Positioned(
                                                        top: 6,
                                                        left: 6,
                                                        child: Container(
                                                          height: 32,
                                                          width: 32,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Colors
                                                                .white, // white background for clarity
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black26,
                                                                blurRadius: 4,
                                                                offset: Offset(
                                                                    1, 1),
                                                              )
                                                            ],
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4),
                                                          child: ClipOval(
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl: item
                                                                  .item!
                                                                  .brandId!
                                                                  .picture!,
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '${_truncateWithEllipsis(item.item?.name)} ${(item.item?.price ?? 0).toStringAsFixed(0)}€',
                                            style: const TextStyle(
                                              fontFamily: 'Lato',
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.italic,
                                              fontSize: 14,
                                              height: 1.0,
                                              letterSpacing: 0.0,
                                              color: Color(0xFF8D8D8D),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // Display brand items sections (one per brand)
                  ..._brandItemsMap.entries.where((entry) => entry.value.isNotEmpty).map((entry) {
                    final brandId = entry.key;
                    final items = entry.value;
                    final brand = _brandInfoMap[brandId];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 11),
                          child: Text(
                            'Autour de ${brand?.name ?? 'la Marque'}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Lato',
                              fontStyle: FontStyle.italic,
                              height: 1.0,
                              letterSpacing: 0.0,
                              color: Color(0xFF8D8D8D),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 210,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 11),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductDetailsScreen(
                                                itemId: item.id,
                                                userId:
                                                    _selfie?.user?.sId ?? '',
                                              ),
                                            ),
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(0),
                                          child: Stack(
                                            children: [
                                              // --- MAIN PRODUCT IMAGE ----
                                              PinchZoom(
                                                maxScale: 3.0,
                                                onZoomStart: () {},
                                                onZoomEnd: () {},
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      item.pictures.isNotEmpty
                                                          ? item.pictures.first
                                                          : '',
                                                  height: 180,
                                                  width: 125,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      Shimmer.fromColors(
                                                    baseColor: Colors.grey.shade300,
                                                    highlightColor: Colors.grey.shade100,
                                                    child: Container(
                                                      height: 180,
                                                      width: 125,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Container(
                                                    height: 180,
                                                    width: 125,
                                                    color: Colors.grey.shade200,
                                                    child: const Center(
                                                      child: Icon(
                                                          Icons.broken_image,
                                                          size: 36),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // --- BRAND LOGO (top-left circle) ---
                                              if (brand?.picture != null)
                                                Positioned(
                                                  top: 6,
                                                  left: 6,
                                                  child: Container(
                                                    height: 32,
                                                    width: 32,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black26,
                                                          blurRadius: 4,
                                                          offset: Offset(1, 1),
                                                        )
                                                      ],
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    child: ClipOval(
                                                      child: CachedNetworkImage(
                                                        imageUrl: brand!.picture!,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${_truncateWithEllipsis(item.name)} ${item.price.toStringAsFixed(0)}€',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'Lato',
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 14,
                                          height: 1.0,
                                          letterSpacing: 0.0,
                                          color: Color(0xFF8D8D8D),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // Explorer la collection button for this brand
                        Padding(
                          padding: const EdgeInsets.only(right: 16, top: 8),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BrandDetailsScreen(
                                      brandId: brand?.sId ?? '',
                                      brandName: brand?.name ?? '',
                                      brandDescription: brand?.description ?? '',
                                      brandLogo: brand?.picture ?? '',
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'Explorer la collection',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Lato',
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),

                  const SizedBox(height: 50),

                  // Display the category name
                  // Text(
                  //   selfie.category?.name?.en ?? 'Unknown Category',
                  //   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  // ),
                  // const SizedBox(height: 8),
                  //
                  // // Display the number of likes
                  // Text(
                  //   'Likes: ${selfie.nbLike ?? 0}',
                  //   style: const TextStyle(fontSize: 16),
                  // ),
                  // const SizedBox(height: 8),
                  //
                  // // Display the creation date
                  // Text(
                  //   'Created At: ${selfie.createdAt ?? 'Unknown Date'}',
                  //   style: const TextStyle(fontSize: 16),
                  // ),
                  // const SizedBox(height: 16),
                  //
                  // // Display user details if available
                  // if (selfie.user != null) ...[
                  //   Stack(
                  //     children: [
                  //       CircleAvatar(
                  //         backgroundImage: NetworkImage(selfie.user?.picture ?? ''),
                  //         radius: 20,
                  //       ),
                  //       Positioned(
                  //         bottom: 0,
                  //         right: 0,
                  //         child: CircleAvatar(
                  //           backgroundColor: Colors.white,
                  //           radius: 8,
                  //           child: Icon(Icons.verified, color: Colors.blue, size: 12),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  //   const SizedBox(width: 8),
                  //   Text(
                  //     selfie.user?.firstName ?? 'Unknown',
                  //     style: const TextStyle(
                  //       fontFamily: 'Lato',
                  //       fontWeight: FontWeight.w400,
                  //       fontSize: 16,
                  //       height: 1.0, // line-height 100%
                  //       letterSpacing: 0.0,
                  //       color: Colors.white,
                  //     ),
                  //   ),
                  //   const SizedBox(height: 8),
                  //   Text(
                  //     'Creator: ${selfie.user?.firstName ?? ''} ${selfie.user?.lastName ?? ''}',
                  //     style: const TextStyle(
                  //       fontSize: 18,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  //   const SizedBox(height: 8),
                  //   Text(
                  //     'Email: ${selfie.user?.email ?? 'N/A'}',
                  //     style: const TextStyle(fontSize: 16),
                  //   ),
                  //   const SizedBox(height: 8),
                  //   Text(
                  //     'City: ${selfie.user?.city ?? 'N/A'}',
                  //     style: const TextStyle(fontSize: 16),
                  //   ),
                  // ],
                  //
                  // const SizedBox(height: 16),
                  //
                  // // Display additional details if available
                  // if (selfie.container != null)
                  //   Text(
                  //     'Container: ${selfie.container}',
                  //     style: const TextStyle(fontSize: 16),
                  //   ),
                ],
              ),
            ),
    );
  }
}
