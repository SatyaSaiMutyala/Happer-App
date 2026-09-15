import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/core/constants/app_colors.dart';
import 'package:happer_app/core/constants/app_dimensions.dart';
import 'package:happer_app/features/auth/controllers/auth_controller.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/shared/widgets/app_button.dart';
import 'package:happer_app/shared/widgets/app_input_field.dart';
import 'package:happer_app/shared/widgets/app_loader.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  const ForgotPasswordOtpScreen({super.key});

  @override
  State<ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  final _otpController = TextEditingController();
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
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HapperAppBar(title: l10n.resetPasswordHeading),
      body: Obx(() {
        return Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppDimensions.p40),
                    Text(
                      l10n.authEnterVerificationCode,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontXXL,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.p8),
                    Text(
                      l10n.authCodeSentTo(_email),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.p40),
                    AppInputField(
                      controller: _otpController,
                      hintText: l10n.authEnterSixDigitCodeHint,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.p24),
                    AppButton(
                      text: l10n.authVerifyAndContinue,
                      isLoading: _auth.isLoading.value,
                      onPressed: () => _auth.verifyForgotPasswordOtp(
                          _email, _otpController.text),
                    ),
                    const SizedBox(height: AppDimensions.p24),
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
