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

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _showPassword = false;
  bool _showConfirm = false;

  late final AuthController _auth;
  late final String _email;

  @override
  void initState() {
    super.initState();
    _auth = Get.find<AuthController>();
    final args = Get.arguments as Map<String, dynamic>?;
    _email = args?['email'] as String? ?? '';
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _validate() {
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    if (password.isEmpty) {
      showAppSnackBar('Please enter a password', isSuccess: false);
      return false;
    }
    if (password.length < 6) {
      showAppSnackBar('Password must be at least 6 characters', isSuccess: false);
      return false;
    }
    if (password != confirm) {
      showAppSnackBar(AppLocalizations.of(context).passwordMustBeTheSame, isSuccess: false);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HapperAppBar(
          title: AppLocalizations.of(context).resetPasswordTitle),
      body: Obx(() {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.p16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppDimensions.p40),
                      Text(
                        AppLocalizations.of(context).resetPasswordHeading,
                        style: const TextStyle(
                          fontSize: AppDimensions.fontXXL,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.p8),
                      Text(
                        AppLocalizations.of(context).resetPasswordInstructions,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: AppDimensions.fontM,
                            color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppDimensions.p40),

                      // New Password
                      AppInputField(
                        controller: _passwordController,
                        hintText: AppLocalizations.of(context).newPasswordHint,
                        obscureText: !_showPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.p16),

                      // Confirm Password
                      AppInputField(
                        controller: _confirmController,
                        hintText:
                            AppLocalizations.of(context).confirmPasswordField,
                        obscureText: !_showConfirm,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () =>
                              setState(() => _showConfirm = !_showConfirm),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.p24),

                      AppButton(
                        text: AppLocalizations.of(context).confirmButton,
                        isLoading: _auth.isLoading.value,
                        onPressed: () {
                          if (!_validate()) return;
                          _auth.resetPassword(
                            _email,
                            _passwordController.text,
                            _confirmController.text,
                          );
                        },
                      ),
                      const SizedBox(height: AppDimensions.p24),
                    ],
                  ),
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
