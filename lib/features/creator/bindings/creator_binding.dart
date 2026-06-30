import 'package:get/get.dart';
import 'package:happer_app/core/network/api_client.dart';
import 'package:happer_app/features/creator/controllers/creator_controller.dart';
import 'package:happer_app/features/creator/controllers/product_like_controller.dart';
import 'package:happer_app/features/creator/data/repositories/creator_repository.dart';

class CreatorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    Get.lazyPut<CreatorRepository>(() => CreatorRepository(Get.find()), fenix: true);
    Get.lazyPut<CreatorController>(() => CreatorController(Get.find()), fenix: true);
    Get.lazyPut<ProductLikeController>(
        () => ProductLikeController(Get.find()), fenix: true);
  }
}
