import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/app/routes/app_routes.dart';
import 'package:happer_app/app_manager.dart';
import 'package:happer_app/core/utils/storage_service.dart';
import 'package:happer_app/features/auth/controllers/auth_controller.dart';
import 'package:happer_app/l10n/app_localizations.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  Future<void> _saveIsGuestLogin(bool value) async {
    await StorageService.setGuestLogin(value);
    AppManager.isLoginAsGuest = value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Top Images
              Expanded(
                flex: 6,
                child: Row(
                  children: [
                    // Left tall image
                    Expanded(
                      flex: 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/img1.jpg',
                          fit: BoxFit.cover,
                          height: double.infinity,
                          cacheWidth: 500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right two stacked images
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/images/img2.jpg',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                cacheWidth: 500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/images/img3.jpg',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                cacheWidth: 500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Title and Description
              SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Image.asset(
                          'assets/images/logo_header.png',
                          fit: BoxFit.cover,
                          width: 150,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context).registerTagline,
                          style: const TextStyle(
                            fontFamily: "Lato",
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            height: 1.0,
                            letterSpacing: 0.0,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          _saveIsGuestLogin(false);
                          Get.toNamed(AppRoutes.signup);
                        },
                        child: Text(
                          AppLocalizations.of(context).getStartedButton,
                          style: const TextStyle(
                            fontFamily: "Lato",
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            height: 1.0,
                            letterSpacing: 0.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context).alreadyHaveAccount,
                          style: const TextStyle(
                            fontFamily: "Lato",
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            height: 1.0,
                            letterSpacing: 0.0,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            _saveIsGuestLogin(false);
                            Get.toNamed(AppRoutes.login);
                          },
                          child: Text(
                            AppLocalizations.of(context).signInTitle,
                            style: const TextStyle(
                              fontFamily: "Lato",
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              height: 1.0,
                              letterSpacing: 0.0,
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () =>
                          Get.find<AuthController>().loginAsGuest(),
                      child: Text(
                        AppLocalizations.of(context).continueAsGuest,
                        style: const TextStyle(
                          fontFamily: "Lato",
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 1.0,
                          letterSpacing: 0.0,
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
