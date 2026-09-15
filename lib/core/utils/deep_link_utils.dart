import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/core/utils/app_l10n.dart';

const String kDeepLinkBase = 'https://api.happer.fr';

String buildProfileDeepLink(String username) =>
    '$kDeepLinkBase/store/$username';

String buildOutfitDeepLink(String username, String selfieId) =>
    '$kDeepLinkBase/store/$username/$selfieId';

String shareProfileMessage(String creatorName, String link) =>
    appL10n.creatorShareProfileMessage(creatorName, link);

String shareOutfitMessage(String creatorName, String link) =>
    appL10n.creatorShareOutfitMessage(creatorName, link);

Future<void> shareOutfit({
  required String username,
  required String selfieId,
  Rect? sharePositionOrigin,
}) async {
  if (username.isEmpty || selfieId.isEmpty) {
    debugPrint('[shareOutfit] aborted — username or selfieId empty');
    return;
  }
  final link = buildOutfitDeepLink(username, selfieId);
  debugPrint('[shareOutfit] sharing link=$link');
  try {
    final result = await SharePlus.instance.share(ShareParams(
      text: shareOutfitMessage(username, link),
      sharePositionOrigin: sharePositionOrigin,
    ));
    debugPrint('[shareOutfit] result=${result.status}');
  } catch (e, st) {
    debugPrint('[shareOutfit] FAILED: $e\n$st');
    showAppSnackBar(appL10n.creatorShareFailed,
        isSuccess: false);
  }
}

Future<void> shareProfile({
  required String username,
  Rect? sharePositionOrigin,
}) async {
  if (username.isEmpty) {
    debugPrint('[shareProfile] aborted — username empty');
    return;
  }
  final link = buildProfileDeepLink(username);
  debugPrint('[shareProfile] sharing link=$link');
  try {
    final result = await SharePlus.instance.share(ShareParams(
      text: shareProfileMessage(username, link),
      sharePositionOrigin: sharePositionOrigin,
    ));
    debugPrint('[shareProfile] result=${result.status}');
  } catch (e, st) {
    debugPrint('[shareProfile] FAILED: $e\n$st');
    showAppSnackBar(appL10n.creatorShareFailed,
        isSuccess: false);
  }
}
