import 'package:get/get.dart';
import 'package:happer_app/core/network/api_client.dart';
import 'package:happer_app/features/profile/data/repositories/image_grid_repository.dart';
import 'package:happer_app/features/profile/controllers/image_grid_controller.dart';

class ImageGridBinding extends Bindings {
  final String userId;
  ImageGridBinding(this.userId);

  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    Get.put(
      ImageGridController(
        ImageGridRepository(Get.find<ApiClient>()),
        userId,
      ),
      tag: userId,
      permanent: false,
    );
  }
}
