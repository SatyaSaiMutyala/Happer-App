import 'package:get/get.dart';
import 'package:happer_app/features/creator/data/models/creator_selfie_model.dart';
import 'package:happer_app/features/creator/data/repositories/creator_repository.dart';

/// Drives the "Inspirations {brand}" screen: paginated creator selfies filtered
/// by a single brand (get-creator-selfies?brand_id=…).
class BrandInspirationsController extends GetxController {
  final CreatorRepository _repo;
  final String brandId;

  BrandInspirationsController(this._repo, this.brandId);

  final selfies = <CreatorSelfieModel>[].obs;
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
      isLoading.value = selfies.isEmpty;
    } else {
      isLoadingMore.value = true;
    }
    try {
      final result = await _repo.getCreatorSelfies(
        page: _page,
        perPage: _perPage,
        brandId: brandId,
      );
      if (firstLoad) {
        selfies.assignAll(result);
      } else {
        selfies.addAll(result);
      }
      hasMore.value = result.length >= _perPage;
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
}
