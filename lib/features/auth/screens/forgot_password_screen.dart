import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/core/constants/app_colors.dart';
import 'package:happer_app/core/constants/app_dimensions.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/features/auth/controllers/auth_controller.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/shared/widgets/app_button.dart';
import 'package:happer_app/shared/widgets/app_input_field.dart';
import 'package:happer_app/shared/widgets/app_loader.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  late final AuthController _auth;

  static final _emailRegex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');

  @override
  void initState() {
    super.initState();
    _auth = Get.find<AuthController>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _validate() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      showAppSnackBar('Please enter your email', isSuccess: false);
      return false;
    }
    if (!_emailRegex.hasMatch(email)) {
      showAppSnackBar('Please enter a valid email address', isSuccess: false);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HapperAppBar(
          title: AppLocalizations.of(context).forgotPasswordTitle),
      body: Obx(() {
        return Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppDimensions.p40),
                    const Text(
                      'Mot de passe oublié',
                      style: TextStyle(
                        fontSize: AppDimensions.fontXXL,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.p8),
                    const Text(
                      'Veuillez saisir votre adresse e-mail enregistrée pour obtenir votre nouveau mot de passe',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: AppDimensions.fontM,
                          color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppDimensions.p40),
                    AppInputField(
                      controller: _emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (v) {
                        if (v != v.toLowerCase()) {
                          _emailController.value = TextEditingValue(
                            text: v.toLowerCase(),
                            selection: TextSelection.collapsed(offset: v.length),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: AppDimensions.p24),
                    AppButton(
                      text: 'Envoyer le code',
                      isLoading: _auth.isLoading.value,
                      onPressed: () {
                        if (!_validate()) return;
                        _auth.forgotPassword(_emailController.text.trim());
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (_auth.isLoading.value) const AppLoader(),
          ],
        );
      }),
    );
  }
}
