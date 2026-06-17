import 'package:get/get.dart';
import 'package:happer_app/features/creator/controllers/creator_controller.dart';
import 'package:happer_app/features/profile/data/repositories/liked_selfies_repository.dart';
import 'package:happer_app/features/profile/models/liked_selfie_model.dart';
import 'package:happer_app/features/selfies/controllers/selfie_controller.dart';

class LikedSelfiesController extends GetxController {
  final LikedSelfiesRepository _repo;

  LikedSelfiesController(this._repo);

  final selfies = <LikedSelfieModel>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final hasMore = false.obs;

  int _page = 1;
  static const int _perPage = 10;

  @override
  Future<void> refresh() => _fetch(reset: true);

  Future<void> _fetch({bool reset = false}) async {
    if (reset) {
      _page = 1;
      selfies.clear();
      hasMore.value = false;
    }
    isLoading.value = selfies.isEmpty;
    try {
      final result = await _repo.fetchLikedSelfies(page: _page, perPage: _perPage);
      selfies.addAll(result.selfies);
      hasMore.value = result.hasMore;
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    _page++;
    try {
      final result = await _repo.fetchLikedSelfies(page: _page, perPage: _perPage);
      selfies.addAll(result.selfies);
      hasMore.value = result.hasMore;
    } catch (_) {
      _page--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> unlike(String selfieId) async {
    final idx = selfies.indexWhere((s) => s.id == selfieId);
    if (idx == -1) return;
    final removed = selfies[idx];

    // Optimistic update across all controllers immediately
    selfies.removeAt(idx);
    if (Get.isRegistered<SelfieController>()) {
      Get.find<SelfieController>().syncLikeState(selfieId, isLiked: false);
    }
    if (Get.isRegistered<CreatorController>()) {
      Get.find<CreatorController>().syncLikeState(selfieId, isLiked: false);
    }

    try {
      await _repo.unlikeSelfie(selfieId);
    } catch (_) {
      // Revert everything on failure
      selfies.insert(idx, removed);
      if (Get.isRegistered<SelfieController>()) {
        Get.find<SelfieController>().syncLikeState(selfieId, isLiked: true);
      }
      if (Get.isRegistered<CreatorController>()) {
        Get.find<CreatorController>().syncLikeState(selfieId, isLiked: true);
      }
    }
  }
}
