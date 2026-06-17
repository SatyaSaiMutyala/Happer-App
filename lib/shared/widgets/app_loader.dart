import 'package:flutter/material.dart';
import 'package:happer_app/core/constants/app_colors.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.loadingOverlay,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.loadingIndicator),
        ),
      ),
    );
  }
}
