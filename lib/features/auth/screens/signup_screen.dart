import 'package:flutter/material.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:happer_app/features/auth/screens/login_screen.dart';
import 'package:happer_app/core/network/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:happer_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:happer_app/l10n/app_localizations.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<SignupScreen> {
  bool showPassword = false;
  bool showConfirmPassword = false;
  String? selectedCountry;
  bool isChecked = false; // Add a state variable to manage the checkbox state
  bool _isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController sponsorshipCodeController =
      TextEditingController();

  final AuthService _authService =
      AuthService(); // Create an instance of AuthService

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

  Future<void> _registerUser() async {
    final userData = {
      "email": emailController.text,
      "first_name": firstNameController.text,
      "last_name": lastNameController.text,
      "gender": genderController.text,
      "password": passwordController.text,
      "password_confirmation": confirmPasswordController.text,
      "code": sponsorshipCodeController.text,
      "country": selectedCountry ?? "",
    };

    final success = await _authService.registerUser(userData);

    if (success) {
      final loginSuccess = await _authService.loginUser(
          userData['email']!, userData['password']!);
      if (loginSuccess) {
        // Clear guest login flag
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_guest_login', false);
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => DashboardScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).loginFailed)),
        );
      }
    } else {
      // Show a snackbar with registration failed message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).registrationFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HapperAppBar(title: AppLocalizations.of(context).sInscrire),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              /// Subtitle
              Container(
                margin: const EdgeInsets.only(left: 16, right: 16),
                child: Text(
                  AppLocalizations.of(context).signupSubtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              /// First Name
              _buildTextField(
                controller: firstNameController,
                hintText: AppLocalizations.of(context).firstNameHint,
              ),
              const SizedBox(height: 12),

              /// Last Name
              _buildTextField(
                controller: lastNameController,
                hintText: AppLocalizations.of(context).lastNameHint,
              ),
              const SizedBox(height: 12),

              /// Email
              _buildTextField(
                controller: emailController,
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              /// Password
              _buildPasswordField(
                controller: passwordController,
                hintText: AppLocalizations.of(context).passwordHint,
                obscureText: !showPassword,
                toggleVisibility: () {
                  setState(() {
                    showPassword = !showPassword;
                  });
                },
              ),
              const SizedBox(height: 12),

              /// Confirm Password
              _buildPasswordField(
                controller: confirmPasswordController,
                hintText: AppLocalizations.of(context).confirmPasswordHint,
                obscureText: !showConfirmPassword,
                toggleVisibility: () {
                  setState(() {
                    showConfirmPassword = !showConfirmPassword;
                  });
                },
              ),
              const SizedBox(height: 12),

              /// Sponsor Code
              _buildTextField(
                controller: sponsorshipCodeController,
                hintText: AppLocalizations.of(context).sponsorCodeHint,
              ),
              const SizedBox(height: 8),

              /// Terms and Conditions
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Wrap(
                      children: [
                        Text(AppLocalizations.of(context).iAcceptAllThe),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            AppLocalizations.of(context).conditionsGenerales,
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
              const SizedBox(height: 16),

              /// Sign Up Button
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (!isChecked) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context).acceptTermsToContinue,
                          ),
                        ),
                      );
                      return;
                    }
                    _registerUser();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).signUpButton,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              /// Divider With Text
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      AppLocalizations.of(context).orSignUpWith,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),

              /// Google & Apple Sign In
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _handleGoogleSignIn,
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey.shade200,
                      child: Image.asset('assets/images/google_button.png'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: _handleAppleSignIn,
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.black,
                      child: Image.asset('assets/images/apple_button.png'),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: (value) {
          if (hintText.toLowerCase() == 'email') {
            final lower = value.toLowerCase();
            if (value != lower) {
              controller.value = TextEditingValue(
                text: lower,
                selection: TextSelection.collapsed(offset: lower.length),
              );
            }
          }
        },
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback toggleVisibility,
  }) {
    return Container(
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
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: toggleVisibility,
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndPrivacy() {
    return Column(
      children: [
        const Text(
          'By signing up, you agree to our',
          style: TextStyle(fontSize: 11, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // Navigate to Terms of Use
              },
              child: const Text('Terms of Use', style: TextStyle(fontSize: 11)),
            ),
            TextButton(
              onPressed: () {
                // Navigate to Privacy Policies
              },
              child: const Text(
                'Privacy Policies',
                style: TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
