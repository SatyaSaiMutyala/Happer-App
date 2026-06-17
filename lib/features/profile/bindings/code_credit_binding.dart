import 'package:get/get.dart';
import 'package:happer_app/core/network/api_client.dart';
import 'package:happer_app/features/profile/controllers/code_credit_controller.dart';
import 'package:happer_app/features/profile/data/repositories/code_credit_repository.dart';

class CodeCreditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    Get.lazyPut<CodeCreditRepository>(
        () => CodeCreditRepository(Get.find()), fenix: true);
    Get.lazyPut<CodeCreditController>(
        () => CodeCreditController(Get.find()), fenix: true);
  }
}
