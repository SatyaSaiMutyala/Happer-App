import 'package:get/get.dart';
import 'package:happer_app/core/network/api_client.dart';
import 'package:happer_app/features/profile/data/repositories/address_repository.dart';
import 'package:happer_app/features/profile/controllers/address_controller.dart';

class AddressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    Get.lazyPut<AddressRepository>(() => AddressRepository(Get.find<ApiClient>()), fenix: true);
    Get.lazyPut<AddressController>(() => AddressController(Get.find()), fenix: true);
  }
}
