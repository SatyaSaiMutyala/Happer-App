import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/core/utils/storage_service.dart';

class LocaleController extends GetxController {
  static const _key = 'app_locale';

  final locale = const Locale('fr').obs;

  LocaleController({String initialCode = 'fr'}) {
    locale.value = Locale(initialCode);
  }

  Future<void> changeLocale(String languageCode) async {
    locale.value = Locale(languageCode);
    Get.updateLocale(Locale(languageCode));
    await StorageService.setString(_key, languageCode);
  }

  String get currentCode => locale.value.languageCode;
}
