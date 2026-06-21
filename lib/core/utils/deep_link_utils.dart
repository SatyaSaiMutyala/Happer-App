import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:happer_app/core/utils/snackbar.dart';

const String kDeepLinkBase = 'https://newapi.happer.fr';

String buildProfileDeepLink(String username) =>
    '$kDeepLinkBase/store/$username';

String buildOutfitDeepLink(String username, String selfieId) =>
    '$kDeepLinkBase/store/$username/$selfieId';

String shareProfileMessage(String creatorName, String link) =>
    "J'ai découvert la boutique de mode de $creatorName sur Happer et j'adore son style ✨\n\nJe te partage son profil !\n\n$link";

String shareOutfitMessage(String creatorName, String link) =>
    "J'ai trouvé l'outfit de $creatorName sur Happer, je pense qu'il pourrait te plaire ✨\n\n$link";

Future<void> shareOutfit({
  required String username,
  required String selfieId,
  String creatorName = '',
  Rect? sharePositionOrigin,
}) async {
  if (username.isEmpty || selfieId.isEmpty) {
    debugPrint('[shareOutfit] aborted — username or selfieId empty');
    return;
  }
  final link = buildOutfitDeepLink(username, selfieId);
  final name = creatorName.isNotEmpty ? creatorName : 'un créateur';
  debugPrint('[shareOutfit] sharing link=$link');
  try {
    final result = await SharePlus.instance.share(ShareParams(
      text: shareOutfitMessage(name, link),
      sharePositionOrigin: sharePositionOrigin,
    ));
    debugPrint('[shareOutfit] result=${result.status}');
  } catch (e, st) {
    debugPrint('[shareOutfit] FAILED: $e\n$st');
    showAppSnackBar('Le partage a échoué. Veuillez réessayer.',
        isSuccess: false);
  }
}

Future<void> shareProfile({
  required String username,
  String creatorName = '',
  Rect? sharePositionOrigin,
}) async {
  if (username.isEmpty) {
    debugPrint('[shareProfile] aborted — username empty');
    return;
  }
  final link = buildProfileDeepLink(username);
  final name = creatorName.isNotEmpty ? creatorName : 'un créateur';
  debugPrint('[shareProfile] sharing link=$link');
  try {
    final result = await SharePlus.instance.share(ShareParams(
      text: shareProfileMessage(name, link),
      sharePositionOrigin: sharePositionOrigin,
    ));
    debugPrint('[shareProfile] result=${result.status}');
  } catch (e, st) {
    debugPrint('[shareProfile] FAILED: $e\n$st');
    showAppSnackBar('Le partage a échoué. Veuillez réessayer.',
        isSuccess: false);
  }
}
