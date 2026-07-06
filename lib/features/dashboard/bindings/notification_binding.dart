import 'package:get/get.dart';
import 'package:happer_app/core/network/api_client.dart';
import 'package:happer_app/features/dashboard/controllers/notification_controller.dart';
import 'package:happer_app/features/dashboard/data/repositories/notification_repository.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    Get.lazyPut<NotificationRepository>(
        () => NotificationRepository(Get.find()),
        fenix: true);
    Get.lazyPut<NotificationController>(
        () => NotificationController(Get.find()),
        fenix: true);
  }
}
