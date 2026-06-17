import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/core/constants/app_colors.dart';
import 'package:happer_app/core/constants/app_dimensions.dart';
import 'package:happer_app/core/constants/app_images.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/features/auth/controllers/auth_controller.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/shared/widgets/app_button.dart';
import 'package:happer_app/shared/widgets/app_input_field.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isChecked = false;
  bool _usernameError = false;
  bool _isCheckingUsername = false;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _referralCodeController = TextEditingController();
  final _usernameFocusNode = FocusNode();

  late final AuthController _auth;

  @override
  void initState() {
    super.initState();
    _auth = Get.find<AuthController>();
    _usernameFocusNode.addListener(_onUsernameFocusChange);
  }

  @override
  void dispose() {
    _usernameFocusNode.removeListener(_onUsernameFocusChange);
    _usernameFocusNode.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  void _onUsernameFocusChange() {
    if (!_usernameFocusNode.hasFocus) {
      _checkUsernameAvailability();
    }
  }

  Future<void> _checkUsernameAvailability() async {
    final username = _usernameController.text.trim();
    if (username.length < 3) return;
    if (!mounted) return;

    setState(() => _isCheckingUsername = true);
    try {
      final isAvailable = await _auth.checkUsernameAvailability(username);
      if (!mounted) return;
      setState(() => _usernameError = !isAvailable);
    } catch (_) {
      // Silently fail — don't block user on network error
    } finally {
      if (mounted) setState(() => _isCheckingUsername = false);
    }
  }

  static final _emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
  static final _usernameRegex = RegExp(r'^[a-z0-9_.]{3,20}$');

  bool _validate() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (firstName.isEmpty) {
      showAppSnackBar('Please enter your first name', isSuccess: false);
      return false;
    }
    if (lastName.isEmpty) {
      showAppSnackBar('Please enter your last name', isSuccess: false);
      return false;
    }
    if (username.isEmpty) {
      showAppSnackBar('Please enter a username', isSuccess: false);
      return false;
    }
    if (username.length < 3) {
      showAppSnackBar('Username must be at least 3 characters',
          isSuccess: false);
      return false;
    }
    if (!_usernameRegex.hasMatch(username)) {
      showAppSnackBar(
          'Username can only contain lowercase letters, numbers, _ and .',
          isSuccess: false);
      return false;
    }
    if (email.isEmpty) {
      showAppSnackBar('Please enter your email', isSuccess: false);
      return false;
    }
    if (!_emailRegex.hasMatch(email)) {
      showAppSnackBar('Please enter a valid email address', isSuccess: false);
      return false;
    }
    if (password.isEmpty) {
      showAppSnackBar('Please enter a password', isSuccess: false);
      return false;
    }
    if (password.length < 6) {
      showAppSnackBar('Password must be at least 6 characters',
          isSuccess: false);
      return false;
    }
    if (password != confirm) {
      showAppSnackBar(AppLocalizations.of(context).passwordMustBeTheSame,
          isSuccess: false);
      return false;
    }
    if (!_isChecked) {
      showAppSnackBar(AppLocalizations.of(context).acceptTermsToContinue,
          isSuccess: false);
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

  void _submit() {
    if (_usernameError) {
      showAppSnackBar('Username is already taken. Please choose another.',
          isSuccess: false);
      return;
    }
    if (!_validate()) return;
    _auth.signup(
      email: _emailController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      referredByCode: _referralCodeController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HapperAppBar(title: AppLocalizations.of(context).sInscrire),
      body: Obx(() {
        final loading = _auth.isLoading.value;
        return Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppDimensions.p20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Subtitle
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.p16),
                      child: Text(
                        AppLocalizations.of(context).signupSubtitle,
                        style: const TextStyle(
                            fontSize: AppDimensions.fontM,
                            color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.p16),

                    // First Name
                    AppInputField(
                      controller: _firstNameController,
                      hintText: 'First Name',
                    ),
                    const SizedBox(height: AppDimensions.p12),

                    // Last Name
                    AppInputField(
                      controller: _lastNameController,
                      hintText: 'Last Name',
                    ),
                    const SizedBox(height: AppDimensions.p12),

                    // Username
                    AppInputField(
                      controller: _usernameController,
                      focusNode: _usernameFocusNode,
                      hintText: 'Username',
                      maxLength: 20,
                      borderColor: _usernameError ? Colors.red : null,
                      suffixIcon: _isCheckingUsername
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : null,
                      onChanged: (v) {
                        final filtered = v
                            .toLowerCase()
                            .replaceAll(RegExp(r'[^a-z0-9_.]'), '');
                        if (filtered != v) {
                          _usernameController.value = TextEditingValue(
                            text: filtered,
                            selection: TextSelection.collapsed(
                                offset: filtered.length),
                          );
                        }
                        if (_usernameError)
                          setState(() => _usernameError = false);
                      },
                    ),
                    if (_usernameError) ...[
                      const SizedBox(height: 4),
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Text(
                          'Username is already used, choose another',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontFamily: 'Lato',
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppDimensions.p12),

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
                    const SizedBox(height: AppDimensions.p12),

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

                    // Confirm Password
                    AppInputField(
                      controller: _confirmPasswordController,
                      hintText:
                          AppLocalizations.of(context).confirmPasswordHint,
                      obscureText: !_showConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setState(
                            () => _showConfirmPassword = !_showConfirmPassword),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.p12),

                    // Referral Code
                    AppInputField(
                      controller: _referralCodeController,
                      hintText: AppLocalizations.of(context).sponsorCodeHint,
                    ),
                    const SizedBox(height: AppDimensions.p8),

                    // Terms & Conditions
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _isChecked,
                          activeColor: AppColors.checkboxActive,
                          onChanged: (v) =>
                              setState(() => _isChecked = v ?? false),
                        ),
                        Expanded(
                          child: Wrap(
                            children: [
                              Text(AppLocalizations.of(context).iAcceptAllThe),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  AppLocalizations.of(context)
                                      .conditionsGenerales,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.p16),

                    // Sign Up Button
                    AppButton(
                      text: AppLocalizations.of(context).signUpButton,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppDimensions.p20),

                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.p12),
                          child: Text(
                            AppLocalizations.of(context).orSignUpWith,
                            style:
                                const TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.p16),

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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 28),
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
                          AppLocalizations.of(context).signingUp,
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
