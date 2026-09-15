import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/core/constants/app_colors.dart';
import 'package:happer_app/core/constants/app_dimensions.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/features/auth/controllers/auth_controller.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/shared/widgets/app_button.dart';
import 'package:happer_app/shared/widgets/app_input_field.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  late final AuthController _auth;
  late final String _email;
  late final String? _password;

  @override
  void initState() {
    super.initState();
    _auth = Get.find<AuthController>();
    final args = Get.arguments as Map<String, dynamic>?;
    _email = args?['email'] as String? ?? '';
    _password = args?['password'] as String?;
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
      appBar: HapperAppBar(title: l10n.authVerifyEmailTitle),
      body: Obx(() {
        final loading = _auth.isLoading.value;
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
                      onChanged: (v) {
                        final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
                        if (digits != v) {
                          _otpController.value = TextEditingValue(
                            text: digits,
                            selection: TextSelection.collapsed(offset: digits.length),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: AppDimensions.p24),
                    AppButton(
                      text: l10n.authVerify,
                      onPressed: () {
                        if (_otpController.text.trim().length < 6) {
                          showAppSnackBar(l10n.authEnterSixDigitCode, isSuccess: false);
                          return;
                        }
                        _auth.verifySignupOtp(_email, _otpController.text.trim(), password: _password);
                      },
                    ),
                    const SizedBox(height: AppDimensions.p24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.authDidntReceiveCode,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        GestureDetector(
                          onTap: loading ? null : () => _auth.resendSignupOtp(_email),
                          child: Text(
                            l10n.authResend,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.p24),
                  ],
                ),
              ),
            ),
            if (loading)
              Container(
                color: Colors.black.withValues(alpha: 0.55),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.verifying,
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.pleaseWaitMoment,
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
