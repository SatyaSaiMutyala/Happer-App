import 'package:get/get.dart';
import 'package:happer_app/core/network/api_client.dart';
import 'package:happer_app/features/profile/data/repositories/user_profile_repository.dart';
import 'package:happer_app/features/profile/controllers/user_profile_controller.dart';

class UserProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    Get.lazyPut<UserProfileRepository>(
        () => UserProfileRepository(Get.find()), fenix: true);
    Get.lazyPut<UserProfileController>(
        () => UserProfileController(Get.find()), fenix: true);
  }
}
