import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/app/routes/app_routes.dart';
import 'package:happer_app/core/constants/app_colors.dart';
import 'package:happer_app/core/constants/app_dimensions.dart';
import 'package:happer_app/core/constants/app_images.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/features/auth/controllers/auth_controller.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/shared/widgets/app_button.dart';
import 'package:happer_app/shared/widgets/app_input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showPassword = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthController _auth;

  @override
  void initState() {
    super.initState();
    _auth = Get.find<AuthController>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  static final _emailRegex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');

  bool _validate() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty) {
      showAppSnackBar('Please enter your email', isSuccess: false);
      return false;
    }
    if (!_emailRegex.hasMatch(email)) {
      showAppSnackBar('Please enter a valid email address', isSuccess: false);
      return false;
    }
    if (password.isEmpty) {
      showAppSnackBar('Please enter your password', isSuccess: false);
      return false;
    }
    return true;
  }

  Future<void> _handleGoogleSignIn() async {
    if (_auth.isLoading.value) return;
    await _auth.loginWithGoogle();
  }

  Future<void> _handleAppleSignIn() async {
    if (_auth.isLoading.value) return;
    await _auth.loginWithApple();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        final loading = _auth.isLoading.value;
        return Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p20),
                child: Column(
                  children: [
                    const SizedBox(height: AppDimensions.p40),

                    // Logo
                    Image.asset(AppImages.loginLogo,
                        height: AppDimensions.loginLogoHeight),
                    const SizedBox(height: AppDimensions.p40),

                    // Title
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppLocalizations.of(context).signInTitle,
                        style: const TextStyle(
                          fontSize: AppDimensions.fontXL,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: AppDimensions.p4, bottom: AppDimensions.p20),
                        child: Text(
                          AppLocalizations.of(context).welcomeBack,
                          style:
                              const TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),

                    // Email
                    AppInputField(
                      controller: _emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (v) {
                        if (v != v.toLowerCase()) {
                          _emailController.value = TextEditingValue(
                            text: v.toLowerCase(),
                            selection:
                                TextSelection.collapsed(offset: v.length),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: AppDimensions.p16),

                    // Password
                    AppInputField(
                      controller: _passwordController,
                      hintText: AppLocalizations.of(context).passwordHint,
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
                    const SizedBox(height: AppDimensions.p12),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                        child: Text(
                          AppLocalizations.of(context).forgotPasswordLink,
                          style: const TextStyle(
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.p8),

                    // Login Button
                    AppButton(
                      text: AppLocalizations.of(context).signInTitle,
                      onPressed: () {
                        if (!_validate()) return;
                        _auth.login(
                          _emailController.text,
                          _passwordController.text,
                        );
                      },
                    ),
                    const SizedBox(height: AppDimensions.p32),

                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.p12),
                          child: Text(
                            AppLocalizations.of(context).orSignInWith,
                            style: const TextStyle(
                                color: AppColors.textSecondary),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.p24),

                    // Social Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _handleGoogleSignIn,
                          child: CircleAvatar(
                            radius: AppDimensions.socialAvatarRadius,
                            backgroundColor: AppColors.googleButtonBg,
                            child: Image.asset(AppImages.googleButton),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.p20),
                        GestureDetector(
                          onTap: _handleAppleSignIn,
                          child: CircleAvatar(
                            radius: AppDimensions.socialAvatarRadius,
                            backgroundColor: AppColors.appleButtonBg,
                            child: Image.asset(AppImages.appleButton),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.p32),

                    // Sign Up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context).noAccountQuestion,
                          style:
                              const TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: AppDimensions.p4),
                        GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.signup),
                          child: Text(
                            AppLocalizations.of(context).signUpLink,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
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
                          AppLocalizations.of(context).loggingIn,
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppLocalizations.of(context).pleaseWaitMoment,
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
