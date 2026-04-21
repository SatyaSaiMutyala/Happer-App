import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends GetxController {
  static const _key = 'app_locale';

  final locale = const Locale('fr').obs;

  LocaleController({String initialCode = 'fr'}) {
    locale.value = Locale(initialCode);
  }

  Future<void> changeLocale(String languageCode) async {
    locale.value = Locale(languageCode);
    Get.updateLocale(Locale(languageCode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, languageCode);
  }

  String get currentCode => locale.value.languageCode;
}
