import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:happer_app/l10n/app_localizations.dart';

class UrlLauncherUtil {
  static Future<void> launchUrl(
    BuildContext context, {
    required String url,
    LaunchMode launchMode = LaunchMode.inAppWebView,
  }) async {
    final uri = Uri.parse(url);
    
    try {
      if (!await url_launcher.launchUrl(
        uri,
        mode: launchMode,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      )) {
        // If launching fails, show a snackbar
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).creatorCouldNotOpenUrl(url)),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      // Handle errors
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)
                .creatorErrorOpeningLink(e.toString())),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
