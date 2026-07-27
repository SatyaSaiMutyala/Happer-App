import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Instagram-style share icon (paper plane) used everywhere the user can share
/// an outfit, a product or a profile. Kept in one widget so every share button
/// stays visually identical.
class ShareIcon extends StatelessWidget {
  final double size;
  final Color color;

  const ShareIcon({
    super.key,
    this.size = 20,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/ic_share.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
