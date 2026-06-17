import 'package:get/get.dart';
import 'package:happer_app/core/network/api_client.dart';
import 'package:happer_app/features/selfies/controllers/selfie_controller.dart';
import 'package:happer_app/features/selfies/data/repositories/selfie_repository.dart';

class SelfieBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    Get.lazyPut<SelfieRepository>(() => SelfieRepository(Get.find()), fenix: true);
    Get.lazyPut<SelfieController>(() => SelfieController(Get.find()), fenix: true);
  }
}
