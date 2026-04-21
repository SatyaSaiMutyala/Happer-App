import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileMenuItem extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? svgPath;
  final String? imagePath;
  final Widget? trailingWidget;
  final double? svgWidth;
  final double? svgHeight;
  final double? imageRotation;
  final VoidCallback? onTap;

  ProfileMenuItem({
    required this.title,
    this.icon,
    this.svgPath,
    this.imagePath,
    this.trailingWidget,
    this.svgWidth = 15,
    this.svgHeight = 15,
    this.imageRotation,
    this.onTap,
  }) : assert(icon != null || svgPath != null || imagePath != null || trailingWidget != null, 'Either icon, svgPath, imagePath, or trailingWidget must be provided');

  Widget _buildTrailingWidget() {
    if (trailingWidget != null) {
      return trailingWidget!;
    } else if (imagePath != null) {
      Widget imageWidget = Image.asset(
        imagePath!,
        width: svgWidth,
        height: svgHeight,
        color: Color(0xFF5C5C5C),
      );
      if (imageRotation != null) {
        imageWidget = Transform.rotate(
          angle: imageRotation!,
          child: imageWidget,
        );
      }
      return imageWidget;
    } else if (svgPath != null) {
      return SvgPicture.asset(
        svgPath!,
        width: svgWidth,
        height: svgHeight,
      );
    } else {
      return Icon(icon, color: Color(0xFF5C5C5C));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              title, 
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.0, // This corresponds to line-height: 100%
                letterSpacing: 0.0,
                color: Color(0xFF5C5C5C),
              ),
              textAlign: TextAlign.left, // Changed from center to left for list tile items
            ),
            trailing: _buildTrailingWidget(),
            onTap: onTap,
          ),
          Divider(color: Colors.grey.shade300, thickness: 1),
        ],
      ),
    );
  }
}
