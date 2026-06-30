import 'package:get/get.dart';
import 'package:happer_app/features/creator/controllers/product_like_controller.dart';
import 'package:happer_app/features/creator/data/models/liked_product_model.dart';
import 'package:happer_app/features/creator/data/repositories/creator_repository.dart';

/// Drives the "Liked products" screen: paginated list backed by
/// GET /user/products/get-liked-products, plus unlike (remove) support.
class LikedProductsController extends GetxController {
  final CreatorRepository _repo;

  LikedProductsController(this._repo);

  final products = <LikedProductModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = RxnString();

  int _page = 1;
  static const int _perPage = 20;
  bool _fetching = false;

  @override
  void onInit() {
    super.onInit();
    fetch(firstLoad: true);
  }

  Future<void> fetch({bool firstLoad = false}) async {
    if (_fetching || (!hasMore.value && !firstLoad)) return;
    _fetching = true;
    if (firstLoad) {
      _page = 1;
      hasMore.value = true;
      errorMessage.value = null;
    }
    if (firstLoad) {
      isLoading.value = products.isEmpty;
    } else {
      isLoadingMore.value = true;
    }
    try {
      final result = await _repo.getLikedProducts(page: _page, perPage: _perPage);
      if (firstLoad) {
        products.assignAll(result.items);
      } else {
        products.addAll(result.items);
      }
      hasMore.value = result.hasMore;
      _page++;
    } catch (e) {
      if (firstLoad) errorMessage.value = 'Une erreur est survenue';
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
      _fetching = false;
    }
  }

  @override
  Future<void> refresh() => fetch(firstLoad: true);

  /// Removes a liked product (optimistic), reverting on failure. Keeps the
  /// shared [ProductLikeController] heart state in sync when it's registered.
  Future<void> unlike(LikedProductModel item) async {
    final index = products.indexWhere((p) => p.likeId == item.likeId);
    if (index == -1) return;
    final removed = products[index];
    products.removeAt(index);

    if (Get.isRegistered<ProductLikeController>()) {
      Get.find<ProductLikeController>().likedVariantIds.remove(item.variantId);
    }

    try {
      await _repo.unlikeProduct(item.variantId);
    } catch (_) {
      // Revert on failure.
      products.insert(index.clamp(0, products.length), removed);
      if (Get.isRegistered<ProductLikeController>()) {
        Get.find<ProductLikeController>().likedVariantIds.add(item.variantId);
      }
    }
  }
}
