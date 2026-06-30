import 'package:get/get.dart';
import 'package:happer_app/features/creator/data/repositories/creator_repository.dart';

/// Holds the set of product variant ids the current user has liked and exposes
/// optimistic like/unlike toggling. Product likes are keyed by VARIANT id on
/// the backend, so all state here is per-variant.
///
/// Registered as a permanent GetX controller so the liked state is shared
/// across screens (product details, liked list, etc.).
class ProductLikeController extends GetxController {
  final CreatorRepository _repo;

  ProductLikeController(this._repo);

  /// Variant ids the user has liked.
  final RxSet<String> likedVariantIds = <String>{}.obs;

  /// Variant ids with an in-flight like/unlike request (guards double taps).
  final RxSet<String> _pending = <String>{}.obs;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadLiked();
  }

  bool isLiked(String variantId) => likedVariantIds.contains(variantId);

  bool isPending(String variantId) => _pending.contains(variantId);

  /// Loads the user's liked variant ids from the server to seed heart state.
  Future<void> loadLiked() async {
    isLoading.value = true;
    try {
      final ids = await _repo.getLikedVariantIds();
      likedVariantIds.assignAll(ids);
    } catch (_) {
      // Non-fatal: leave whatever we already have.
    } finally {
      isLoading.value = false;
    }
  }

  /// Optimistically toggles the like for [variantId], reverting on failure.
  /// Returns the resulting liked state.
  Future<bool> toggleLike(String variantId) async {
    if (variantId.isEmpty || _pending.contains(variantId)) {
      return isLiked(variantId);
    }
    final wasLiked = isLiked(variantId);

    // Optimistic update.
    if (wasLiked) {
      likedVariantIds.remove(variantId);
    } else {
      likedVariantIds.add(variantId);
    }
    _pending.add(variantId);

    try {
      if (wasLiked) {
        await _repo.unlikeProduct(variantId);
      } else {
        await _repo.likeProduct(variantId);
      }
      return !wasLiked;
    } catch (_) {
      // Roll back on error.
      if (wasLiked) {
        likedVariantIds.add(variantId);
      } else {
        likedVariantIds.remove(variantId);
      }
      return wasLiked;
    } finally {
      _pending.remove(variantId);
    }
  }
}
