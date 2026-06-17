import 'package:get/get.dart';
import 'package:happer_app/features/profile/data/repositories/image_grid_repository.dart';
import 'package:happer_app/features/profile/models/user_profile_stats_model.dart';
import 'package:happer_app/features/profile/models/user_selfie_model.dart';

class ImageGridController extends GetxController {
  final ImageGridRepository _repo;
  final String userId;

  ImageGridController(this._repo, this.userId);

  final isProfileLoading = true.obs;
  final isSelfiesLoading = true.obs;
  final isLoadingMore = false.obs;
  final profile = Rxn<UserProfileStatsModel>();
  final selfies = <UserSelfieModel>[].obs;
  final profileError = Rxn<String>();
  final hasMore = false.obs;

  int _page = 1;
  static const int _perPage = 12;

  @override
  void onInit() {
    super.onInit();
    _fetchProfile();
    _fetchSelfies(reset: true);
  }

  @override
  Future<void> refresh() {
    profileError.value = null;
    return Future.wait([_fetchProfile(), _fetchSelfies(reset: true)]);
  }

  Future<void> _fetchProfile() async {
    isProfileLoading.value = true;
    profileError.value = null;
    try {
      profile.value = await _repo.fetchStats(userId);
    } catch (e) {
      profileError.value = e.toString();
    } finally {
      isProfileLoading.value = false;
    }
  }

  Future<void> _fetchSelfies({bool reset = false}) async {
    if (reset) {
      _page = 1;
      selfies.clear();
      hasMore.value = false;
    }
    isSelfiesLoading.value = true;
    try {
      final result =
          await _repo.fetchSelfies(userId, page: _page, perPage: _perPage);
      selfies.addAll(result.selfies);
      hasMore.value = result.hasMore;
    } catch (_) {
    } finally {
      isSelfiesLoading.value = false;
    }
  }

  Future<void> loadMoreSelfies() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    _page++;
    try {
      final result =
          await _repo.fetchSelfies(userId, page: _page, perPage: _perPage);
      selfies.addAll(result.selfies);
      hasMore.value = result.hasMore;
    } catch (_) {
      _page--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> toggleFollow() async {
    final current = profile.value;
    if (current == null) return;
    final wasFollowing = current.isFollowing;
    profile.value = current.copyWith(
      isFollowing: !wasFollowing,
      followersCount: wasFollowing
          ? (current.followersCount - 1).clamp(0, 999999999)
          : current.followersCount + 1,
    );
    try {
      if (wasFollowing) {
        await _repo.unfollowUser(userId);
      } else {
        await _repo.followUser(userId);
      }
    } catch (_) {
      profile.value = current;
    }
  }
}
