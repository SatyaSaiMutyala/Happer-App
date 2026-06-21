import 'package:get/get.dart';
import 'package:happer_app/features/creator/data/models/creator_selfie_model.dart';
import 'package:happer_app/features/creator/data/repositories/creator_repository.dart';

class CreatorController extends GetxController {
  final CreatorRepository _repo;

  CreatorController(this._repo);

  final selfies = <CreatorSelfieModel>[].obs;
  final isLoading = false.obs;
  final hasMore = true.obs;
  final errorMessage = Rxn<String>();
  final searchQuery = ''.obs;
  final showScrollToTop = false.obs;

  int _page = 1;
  static const _perPage = 20;
  bool _fetching = false;

  @override
  void onReady() {
    super.onReady();
    fetchSelfies(firstLoad: true);
  }

  Future<void> fetchSelfies({bool firstLoad = false}) async {
    if (_fetching || (!hasMore.value && !firstLoad)) return;
    _fetching = true;
    if (firstLoad) {
      _page = 1;
      hasMore.value = true;
      errorMessage.value = null;
    }
    // Don't clear the list before the new data arrives — keeps existing
    // content visible during a refresh instead of flashing the full-screen
    // shimmer placeholder.
    isLoading.value = selfies.isEmpty;
    try {
      final result = await _repo.getCreatorSelfies(page: _page, perPage: _perPage);
      if (firstLoad) {
        selfies.assignAll(result);
      } else {
        selfies.addAll(result);
      }
      hasMore.value = result.length >= _perPage;
      _page++;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      _fetching = false;
    }
  }

  @override
  Future<void> refresh() => fetchSelfies(firstLoad: true);

  /// Called by other controllers (e.g. LikedSelfiesController) to keep like
  /// state in sync without making an additional API call.
  void syncLikeState(String selfieId, {required bool isLiked}) {
    final idx = selfies.indexWhere((s) => s.id == selfieId);
    if (idx == -1) return;
    final selfie = selfies[idx];
    selfie.isLikedByMe = isLiked;
    selfie.likesCount = (selfie.likesCount + (isLiked ? 1 : -1)).clamp(0, 999999);
    selfies.refresh();
  }

  Future<void> toggleLike(String selfieId) async {
    final idx = selfies.indexWhere((s) => s.id == selfieId);
    if (idx == -1) return;
    final selfie = selfies[idx];
    final wasLiked = selfie.isLikedByMe;
    // Optimistic update
    selfie.isLikedByMe = !wasLiked;
    selfie.likesCount = (selfie.likesCount + (wasLiked ? -1 : 1)).clamp(0, 999999);
    selfies.refresh();
    try {
      if (wasLiked) {
        await _repo.unlikeSelfie(selfieId);
      } else {
        await _repo.likeSelfie(selfieId);
      }
    } catch (_) {
      // Rollback on error
      selfie.isLikedByMe = wasLiked;
      selfie.likesCount = (selfie.likesCount + (wasLiked ? 1 : -1)).clamp(0, 999999);
      selfies.refresh();
    }
  }
}
