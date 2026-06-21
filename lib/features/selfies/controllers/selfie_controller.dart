import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:happer_app/core/network/api_exceptions.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/features/selfies/data/models/selfie_model.dart';
import 'package:happer_app/features/selfies/data/repositories/selfie_repository.dart';

class SelfieController extends GetxController {
  final SelfieRepository _repo;

  SelfieController(this._repo);

  // Feed (all selfies)
  final feedSelfies = <SelfieModel>[].obs;
  final isFeedLoading = true.obs;
  final isFeedLoadingMore = false.obs;
  final hasFeedMore = true.obs;
  int _feedPage = 1;

  // My selfies
  final mySelfies = <SelfieModel>[].obs;
  final isMyLoading = true.obs;
  final isMyLoadingMore = false.obs;
  final hasMyMore = true.obs;
  final myError = RxnString();
  int _myPage = 1;
  static const int _myPerPage = 10;

  // Discover selfies (normal users)
  final discoverSelfies = <SelfieModel>[].obs;
  final isDiscoverLoading = true.obs;
  final isDiscoverLoadingMore = false.obs;
  final hasDiscoverMore = true.obs;
  final discoverError = RxnString();
  int _discoverPage = 1;
  static const int _discoverPerPage = 10;

  // Current user profile (cached from /auth/me)
  final currentUser = Rxn<SelfieUser>();

  // Detail
  final detailSelfie = Rxn<SelfieModel>();
  final isDetailLoading = false.obs;

  // Upload/Submit
  final isSubmitting = false.obs;

  // UI scroll state (used by Discover & Feed tabs)
  final showScrollToTop = false.obs;

  // Products (for creator selfie upload)
  final isProductsLoading = false.obs;
  final productsList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMySelfies();
    fetchDiscoverSelfies();
    fetchCurrentUser();
  }

  Future<void> fetchCurrentUser() async {
    try {
      currentUser.value = await _repo.getCurrentUser();
    } catch (e) {
      debugPrint('fetchCurrentUser failed: $e');
    }
  }

  // ─── Feed ────────────────────────────────────────────────────────────────

  Future<void> fetchFeed({bool refresh = false}) async {
    if (refresh) {
      _feedPage = 1;
      hasFeedMore.value = true;
      feedSelfies.clear();
    }
    isFeedLoading.value = feedSelfies.isEmpty;
    try {
      final data = await _repo.getSelfies(page: _feedPage);
      if (data.length < 15) hasFeedMore.value = false;
      if (refresh) {
        feedSelfies.assignAll(data);
      } else {
        feedSelfies.addAll(data);
      }
      _feedPage++;
    } on UnauthorizedException {
      _showError('Session expired. Please log in again.');
    } catch (e) {
      _showError('Failed to load selfies.');
    } finally {
      isFeedLoading.value = false;
    }
  }

  Future<void> loadMoreFeed() async {
    if (isFeedLoadingMore.value || !hasFeedMore.value) return;
    isFeedLoadingMore.value = true;
    try {
      final data = await _repo.getSelfies(page: _feedPage);
      if (data.length < 15) hasFeedMore.value = false;
      feedSelfies.addAll(data);
      _feedPage++;
    } catch (_) {
    } finally {
      isFeedLoadingMore.value = false;
    }
  }

  // ─── My Selfies ──────────────────────────────────────────────────────────

  Future<void> fetchMySelfies({bool refresh = false}) async {
    if (refresh) {
      _myPage = 1;
      hasMyMore.value = true;
    }
    myError.value = null;
    isMyLoading.value = mySelfies.isEmpty;
    try {
      final data = await _repo.getOwnSelfies(page: _myPage, perPage: _myPerPage);
      if (data.length < _myPerPage) hasMyMore.value = false;
      if (refresh) {
        mySelfies.assignAll(data);
      } else {
        mySelfies.addAll(data);
      }
      _myPage++;
    } on UnauthorizedException {
      myError.value = 'Session expired. Please log in again.';
    } catch (e) {
      myError.value = 'Failed to load selfies. Please try again.';
    } finally {
      isMyLoading.value = false;
    }
  }

  Future<void> loadMoreMySelfies() async {
    if (isMyLoadingMore.value || !hasMyMore.value) return;
    isMyLoadingMore.value = true;
    try {
      final data = await _repo.getOwnSelfies(page: _myPage, perPage: _myPerPage);
      if (data.length < _myPerPage) hasMyMore.value = false;
      mySelfies.addAll(data);
      _myPage++;
    } catch (_) {
    } finally {
      isMyLoadingMore.value = false;
    }
  }

  // ─── Discover Selfies (normal users) ─────────────────────────────────────

  Future<void> fetchDiscoverSelfies({bool refresh = false}) async {
    if (refresh) {
      _discoverPage = 1;
      hasDiscoverMore.value = true;
    }
    discoverError.value = null;
    // Don't clear the list before the new data arrives — the old content
    // (and RefreshIndicator's own spinner) stays visible during a refresh
    // instead of flashing the full-screen shimmer placeholder.
    isDiscoverLoading.value = discoverSelfies.isEmpty;
    try {
      final data = await _repo.getNormalUserSelfies(
          page: _discoverPage, perPage: _discoverPerPage);
      if (data.length < _discoverPerPage) hasDiscoverMore.value = false;
      if (refresh) {
        discoverSelfies.assignAll(data);
      } else {
        discoverSelfies.addAll(data);
      }
      _discoverPage++;
    } on UnauthorizedException {
      discoverError.value = 'Session expired. Please log in again.';
    } catch (e) {
      discoverError.value = 'Failed to load selfies. Please try again.';
    } finally {
      isDiscoverLoading.value = false;
    }
  }

  Future<void> loadMoreDiscoverSelfies() async {
    if (isDiscoverLoadingMore.value || !hasDiscoverMore.value) return;
    isDiscoverLoadingMore.value = true;
    try {
      final data = await _repo.getNormalUserSelfies(
          page: _discoverPage, perPage: _discoverPerPage);
      if (data.length < _discoverPerPage) hasDiscoverMore.value = false;
      discoverSelfies.addAll(data);
      _discoverPage++;
    } catch (_) {
    } finally {
      isDiscoverLoadingMore.value = false;
    }
  }

  // ─── Detail ──────────────────────────────────────────────────────────────

  Future<void> fetchDetail(String id) async {
    // Clear stale data from a previously viewed selfie
    if (detailSelfie.value?.id != id) {
      detailSelfie.value = null;
    }
    isDetailLoading.value = true;
    try {
      detailSelfie.value = await _repo.getSelfieDetail(id);
    } catch (_) {
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<bool> deleteSelfie(String id) async {
    try {
      await _repo.deleteSelfie(id);
      mySelfies.removeWhere((s) => s.id == id);
      if (detailSelfie.value?.id == id) detailSelfie.value = null;
      return true;
    } catch (e) {
      _showError('Failed to delete. Please try again.');
      return false;
    }
  }

  // ─── Like / Unlike ───────────────────────────────────────────────────────

  Future<void> toggleLike(String selfieId) async {
    final idx = feedSelfies.indexWhere((s) => s.id == selfieId);
    final myIdx = mySelfies.indexWhere((s) => s.id == selfieId);
    final discoverIdx = discoverSelfies.indexWhere((s) => s.id == selfieId);

    // Resolve current model — prefer lists, fall back to detailSelfie
    SelfieModel? current;
    if (idx != -1) current = feedSelfies[idx];
    if (myIdx != -1) current ??= mySelfies[myIdx];
    if (discoverIdx != -1) current ??= discoverSelfies[discoverIdx];
    current ??= detailSelfie.value?.id == selfieId ? detailSelfie.value : null;
    if (current == null) return;

    final wasLiked = current.isLikedByMe;
    final updated = current.copyWith(
      isLikedByMe: !wasLiked,
      nbLike: wasLiked ? current.nbLike - 1 : current.nbLike + 1,
    );

    // Optimistic update across all lists
    if (idx != -1) feedSelfies[idx] = updated;
    if (myIdx != -1) mySelfies[myIdx] = updated;
    if (discoverIdx != -1) discoverSelfies[discoverIdx] = updated;
    if (detailSelfie.value?.id == selfieId) detailSelfie.value = updated;

    try {
      if (wasLiked) {
        await _repo.unlikeSelfie(selfieId);
        showAppSnackBar('Removed from your likes');
      } else {
        await _repo.likeSelfie(selfieId);
        showAppSnackBar('Added to your likes');
      }
    } catch (_) {
      // Revert on failure
      if (idx != -1) feedSelfies[idx] = current;
      if (myIdx != -1) mySelfies[myIdx] = current;
      if (discoverIdx != -1) discoverSelfies[discoverIdx] = current;
      if (detailSelfie.value?.id == selfieId) detailSelfie.value = current;
      showAppSnackBar('Failed to update like. Please try again.', isSuccess: false);
    }
  }

  // ─── Products ────────────────────────────────────────────────────────────

  Future<void> fetchProductsList() async {
    isProductsLoading.value = true;
    try {
      productsList.assignAll(await _repo.getProductsList());
    } catch (_) {
    } finally {
      isProductsLoading.value = false;
    }
  }

  // ─── Submit ──────────────────────────────────────────────────────────────

  Future<bool> uploadAndSubmitSelfie(String filePath, {List<Map<String, dynamic>> linkedProducts = const []}) async {
    isSubmitting.value = true;
    try {
      final url = await _repo.uploadSelfieImage(filePath);
      if (url.isEmpty) throw Exception('Upload returned empty URL');
      await _repo.submitSelfie([url], linkedProducts: linkedProducts);
      _showSuccess('Selfie posted successfully!');
      return true;
    } on UnauthorizedException {
      _showError('Session expired. Please log in again.');
    } catch (e) {
      _showError('Failed to post selfie. Please try again.');
    } finally {
      isSubmitting.value = false;
    }
    return false;
  }

  Future<bool> submitSelfieUrls(List<String> urls) async {
    isSubmitting.value = true;
    try {
      await _repo.submitSelfie(urls);
      await fetchMySelfies(refresh: true);
      _showSuccess('Selfie posted successfully!');
      return true;
    } on UnauthorizedException {
      _showError('Session expired. Please log in again.');
    } catch (e) {
      _showError('Failed to post selfie. Please try again.');
    } finally {
      isSubmitting.value = false;
    }
    return false;
  }

  // ─── Sync helpers (called by other controllers) ──────────────────────────

  /// Called when a like is toggled externally (e.g. from LikedImagesScreen).
  void syncLikeState(String selfieId, {required bool isLiked}) {
    final delta = isLiked ? 1 : -1;
    SelfieModel apply(SelfieModel s) => s.copyWith(
          isLikedByMe: isLiked,
          nbLike: (s.nbLike + delta).clamp(0, 999999),
        );

    final feedIdx = feedSelfies.indexWhere((s) => s.id == selfieId);
    if (feedIdx != -1) feedSelfies[feedIdx] = apply(feedSelfies[feedIdx]);

    final myIdx = mySelfies.indexWhere((s) => s.id == selfieId);
    if (myIdx != -1) mySelfies[myIdx] = apply(mySelfies[myIdx]);

    final discoverIdx = discoverSelfies.indexWhere((s) => s.id == selfieId);
    if (discoverIdx != -1) discoverSelfies[discoverIdx] = apply(discoverSelfies[discoverIdx]);

    if (detailSelfie.value?.id == selfieId) {
      detailSelfie.value = apply(detailSelfie.value!);
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  void _showError(String msg) => showAppSnackBar(msg, isSuccess: false);

  void _showSuccess(String msg) => showAppSnackBar(msg);
}
