import 'dart:io';
import 'package:flutter/material.dart';
import 'package:happer_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:happer_app/features/auth/screens/forgot_password_screen.dart';
import 'package:happer_app/features/auth/screens/signup_screen.dart';
import 'package:happer_app/core/network/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:happer_app/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showPassword = false;
  bool _isLoading = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> _saveLoginMethod(String method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('login_method', method);
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final userCredential = await authService.firebaseGoogleSignIn();

      if (userCredential != null) {
        final success = await authService.loginWithFirebaseGoogle(userCredential);
        if (success) {
          await _saveLoginMethod('google');
          // Clear guest login flag
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_guest_login', false);
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          }
        } else if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).googleLoginFailed)),
          );
        }
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).googleLoginFailed)));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).errorLabel}: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();

      // Direct Apple Sign-In → Backend (no Firebase needed)
      final success = await authService.appleSignInAndBackendLogin();

      if (!mounted) return;

      if (success) {
        await _saveLoginMethod('apple');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_guest_login', false);

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).appleLoginFailed)),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Handle user cancellation silently
      if (e.toString().contains('CANCELLED')) {
        return;
      }

      // Extract error message
      String errorMessage = AppLocalizations.of(context).appleLoginFailed;

      if (e is Exception) {
        final exceptionMessage = e.toString().replaceFirst('Exception: ', '');
        errorMessage = exceptionMessage;
      } else {
        errorMessage = e.toString();
      }

      debugPrint('Apple Sign In Error: $errorMessage');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 40),

              /// Logo + Title
              Column(
                children: [
                  Image.asset("assets/images/login_logo.png", height: 100),
                  const SizedBox(height: 12),
                  // const Text(
                  //   "Happer",
                  //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  // ),
                ],
              ),

              const SizedBox(height: 40),

              /// Title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context).signInTitle,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 20),
                  child: Text(
                    AppLocalizations.of(context).welcomeBack,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),

              /// Email Field
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: TextField(
                  controller: emailController,
                  textCapitalization: TextCapitalization.none,
                  onChanged: (value) {
                    if (value != value.toLowerCase()) {
                      final lower = value.toLowerCase();
                      emailController.value = TextEditingValue(
                        text: lower,
                        selection:
                            TextSelection.collapsed(offset: lower.length),
                      );
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: "Email",
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              /// Password Field with toggle
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: passwordController,
                        obscureText: !showPassword,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).passwordHint,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        showPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              /// Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context).forgotPasswordLink,
                    style: const TextStyle(
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              /// Login Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    final authService = AuthService();
                    final success = await authService.loginUser(
                      emailController.text,
                      passwordController.text,
                    );
                    if (success) {
                      await _saveLoginMethod('email');
                      // Clear guest login flag
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('is_guest_login', false);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DashboardScreen(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context).loginFailedCredentials,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    AppLocalizations.of(context).signInTitle,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              /// Divider With Text
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      AppLocalizations.of(context).orSignInWith,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 24),

              /// Google & Apple Sign In
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _handleGoogleSignIn,
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey.shade200,
                      child: Image.asset("assets/images/google_button.png"),
                    ),
                  ),
              // if (Platform.isIOS) ...[
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: _handleAppleSignIn,
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.black,
                    child: Image.asset("assets/images/apple_button.png"),
                  ),
                ),
              // ],
                ],
              ),
              const SizedBox(height: 32),

              /// Sign Up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context).noAccountQuestion,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      );
                    },
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

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
