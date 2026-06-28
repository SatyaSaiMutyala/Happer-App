import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/features/creator/creator_tab_key.dart';
import 'package:happer_app/features/selfies/controllers/selfie_controller.dart';
import 'package:happer_app/features/selfies/bindings/selfie_binding.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:shimmer/shimmer.dart';

class _Product {
  final String id;
  final String brandId;
  final String variantId;
  final String name;
  final String brandName;
  final String imageUrl;
  bool isSelected = false;

  _Product({
    required this.id,
    required this.brandId,
    required this.variantId,
    required this.name,
    required this.brandName,
    required this.imageUrl,
  });

  factory _Product.fromJson(Map<String, dynamic> json) {
    final brandRaw = json['brand_id'];
    final brandId = brandRaw is Map
        ? (brandRaw['_id'] as String? ?? '')
        : (brandRaw as String? ?? '');
    final brandName =
        brandRaw is Map ? (brandRaw['name'] as String? ?? '') : '';

    // API returns variant_id as an object with an images array
    final variantRaw = json['variant_id'];
    final variantId = variantRaw is Map
        ? (variantRaw['_id'] as String? ?? '')
        : (variantRaw as String? ?? '');

    // Prefer variant image; fall back to product_image
    String imageUrl = '';
    if (variantRaw is Map) {
      final imgs = (variantRaw['images'] as List?)
          ?.whereType<String>()
          .where((s) => s.trim().isNotEmpty)
          .toList();
      if (imgs != null && imgs.isNotEmpty) imageUrl = imgs.first.trim();
    }
    if (imageUrl.isEmpty) {
      imageUrl = (json['product_image'] as String? ?? '').trim();
    }

    return _Product(
      id: json['_id'] as String? ?? '',
      brandId: brandId,
      variantId: variantId,
      name: json['name'] as String? ?? 'Unknown',
      brandName: brandName,
      imageUrl: imageUrl,
    );
  }

  Map<String, dynamic> toLinkedProduct() => {
        'product_id': id,
        'brand_id': brandId,
        'variant_id': variantId,
      };
}

class ImageCropScreen extends StatefulWidget {
  final File imageFile;

  const ImageCropScreen({super.key, required this.imageFile});

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  bool _isLoadingProducts = false;
  List<_Product> _products = [];
  int _userType = 0;
  final TextEditingController _captionController = TextEditingController();

  late final SelfieController _selfieController;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<SelfieController>()) {
      SelfieBinding().dependencies();
    }
    _selfieController = Get.find<SelfieController>();
    _loadUserTypeAndProducts();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _loadUserTypeAndProducts() async {
    // Ensure user is loaded before checking type
    if (_selfieController.currentUser.value == null) {
      await _selfieController.fetchCurrentUser();
    }
    final userType = _selfieController.currentUser.value?.usersType ?? 0;
    setState(() {
      _userType = userType;
      _isLoadingProducts = userType == 1;
    });
    if (userType != 1) return;

    await _selfieController.fetchProductsList();
    if (!mounted) return;
    setState(() {
      _products = _selfieController.productsList
          .map((e) => _Product.fromJson(e))
          .toList();
      _isLoadingProducts = false;
    });
  }

  void _toggleProduct(_Product product) {
    setState(() => product.isSelected = !product.isSelected);
  }

  Future<void> _uploadSelfie() async {
    final l10n = AppLocalizations.of(context);
    final selected = _products.where((p) => p.isSelected).toList();

    if (_userType == 1 && selected.isEmpty) {
      showAppSnackBar(l10n.selectAtLeastOneProduct, isSuccess: false);
      return;
    }

    final linkedProducts = selected.map((p) => p.toLinkedProduct()).toList();

    final success = await _selfieController.uploadAndSubmitSelfie(
      widget.imageFile.path,
      linkedProducts: linkedProducts,
      caption: _captionController.text,
    );
    if (success && mounted) {
      _selfieController.fetchMySelfies(refresh: true);
      Navigator.of(context).popUntil((route) => route.isFirst);
      creatorTabKey.currentState?.forceRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: HapperAppBar(title: l10n.sharePhotoTitle),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Stack(
                          children: [
                            Image.file(
                              widget.imageFile,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            CustomPaint(
                              size:
                                  const Size(double.infinity, double.infinity),
                              painter: _GridPainter(),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.captionLabel,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Lato',
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _captionController,
                              minLines: 1,
                              maxLines: 4,
                              maxLength: 300,
                              textCapitalization: TextCapitalization.sentences,
                              style: const TextStyle(fontFamily: 'Lato'),
                              decoration: InputDecoration(
                                hintText: l10n.captionHint,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_userType == 1)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.linkProductsTitle,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Lato',
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_isLoadingProducts)
                                _buildShimmerCards()
                              else
                                _buildProductList(l10n),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Obx(() {
                  final isUploading = _selfieController.isSubmitting.value;
                  return ElevatedButton(
                    onPressed: isUploading ? null : _uploadSelfie,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(l10n.shareButton),
                  );
                }),
              ),
              const SizedBox(height: 40),
            ],
          ),
          Obx(() {
            if (!_selfieController.isSubmitting.value)
              return const SizedBox.shrink();
            return Container(
              color: Colors.black.withValues(alpha: 0.55),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.uploading,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.pleaseWaitMoment,
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
            );
          }),
        ],
      ),
    );
  }

  Widget _buildShimmerCards() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: 150,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      Container(height: 150, width: 110, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Container(height: 12, width: 120, color: Colors.white),
                const SizedBox(height: 4),
                Container(height: 10, width: 80, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductList(AppLocalizations l10n) {
    if (_products.isEmpty) {
      return Center(
        child: Text(l10n.noProductAvailable),
      );
    }
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return GestureDetector(
            onTap: () => _toggleProduct(product),
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: product.imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: product.imageUrl,
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) =>
                                    _imagePlaceholder(),
                              )
                            : _imagePlaceholder(),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.black,
                          radius: 12,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: product.isSelected
                                ? Colors.black
                                : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey),
                          ),
                          child: product.isSelected
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 20)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lato',
                    ),
                  ),
                  Text(
                    product.brandName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontFamily: 'Lato',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
        height: 150,
        width: 110,
        color: Colors.grey.shade200,
        child: const Icon(Icons.shopping_bag_outlined,
            size: 40, color: Colors.grey),
      );
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(Offset(0, size.height * i / 3),
          Offset(size.width, size.height * i / 3), paint);
      canvas.drawLine(Offset(size.width * i / 3, 0),
          Offset(size.width * i / 3, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
