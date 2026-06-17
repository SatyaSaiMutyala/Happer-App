import 'package:get/get.dart';
import 'package:happer_app/core/network/api_client.dart';
import 'package:happer_app/features/dashboard/data/repositories/cart_repository.dart';

class CartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    Get.lazyPut<CartRepository>(() => CartRepository(Get.find()), fenix: true);
  }
}
