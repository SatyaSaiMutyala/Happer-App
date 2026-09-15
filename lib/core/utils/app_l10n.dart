import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/core/controllers/locale_controller.dart';
import 'package:happer_app/l10n/app_localizations.dart';

/// Localized strings for code that has no [BuildContext]
/// (controllers, services, snackbars fired from async callbacks).
/// Inside widgets prefer `AppLocalizations.of(context)`.
AppLocalizations get appL10n {
  final code = Get.isRegistered<LocaleController>()
      ? Get.find<LocaleController>().currentCode
      : (Get.locale?.languageCode ?? 'fr');
  try {
    return lookupAppLocalizations(Locale(code));
  } catch (_) {
    return lookupAppLocalizations(const Locale('fr'));
  }
}
