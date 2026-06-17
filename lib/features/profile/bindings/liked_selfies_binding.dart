import 'package:get/get.dart';
import 'package:happer_app/core/network/api_client.dart';
import 'package:happer_app/features/profile/data/repositories/liked_selfies_repository.dart';
import 'package:happer_app/features/profile/controllers/liked_selfies_controller.dart';

class LikedSelfiesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    Get.put<LikedSelfiesController>(
      LikedSelfiesController(LikedSelfiesRepository(Get.find<ApiClient>())),
    );
  }
}
