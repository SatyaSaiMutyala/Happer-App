import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

const String kDeepLinkBase = 'https://newapi.happer.fr';

String buildProfileDeepLink(String username) =>
    '$kDeepLinkBase/store/$username';

String buildOutfitDeepLink(String username, String selfieId) =>
    '$kDeepLinkBase/store/$username/$selfieId';

String shareProfileMessage(String creatorName, String link) =>
    "J'ai découvert la boutique de mode de $creatorName sur Happer et j'adore son style ✨\n\nJe te partage son profil !\n\n$link";

String shareOutfitMessage(String creatorName, String link) =>
    "J'ai trouvé l'outfit de $creatorName sur Happer, je pense qu'il pourrait te plaire ✨\n\n$link";

void shareOutfit({
  required String username,
  required String selfieId,
  String creatorName = '',
  Rect? sharePositionOrigin,
}) {
  if (username.isEmpty || selfieId.isEmpty) return;
  final link = buildOutfitDeepLink(username, selfieId);
  final name = creatorName.isNotEmpty ? creatorName : 'un créateur';
  SharePlus.instance.share(ShareParams(
    text: shareOutfitMessage(name, link),
    sharePositionOrigin: sharePositionOrigin,
  ));
}

void shareProfile({
  required String username,
  String creatorName = '',
  Rect? sharePositionOrigin,
}) {
  if (username.isEmpty) return;
  final link = buildProfileDeepLink(username);
  final name = creatorName.isNotEmpty ? creatorName : 'un créateur';
  SharePlus.instance.share(ShareParams(
    text: shareProfileMessage(name, link),
    sharePositionOrigin: sharePositionOrigin,
  ));
}
