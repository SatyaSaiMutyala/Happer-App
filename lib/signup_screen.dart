import 'package:flutter/material.dart';
import 'package:happer_app/login_screen.dart';
import 'package:happer_app/webservices/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard/screens/dashboard_screen.dart';

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
            const SnackBar(content: Text('Échec de la connexion Google au backend.')),
          );
        }
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Échec de la connexion Google.')));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
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
          const SnackBar(content: Text('Échec de la connexion Apple.')),
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
      String errorMessage = 'Échec de la connexion Apple.';

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
          const SnackBar(content: Text('Login failed after registration.')),
        );
      }
    } else {
      // Show a snackbar with registration failed message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "S\u2019inscrire",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
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
                child: const Text(
                  'Remplissez les champs ci-dessous ou inscrivez-vous avec votre compte de réseau social.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              /// First Name
              _buildTextField(
                controller: firstNameController,
                hintText: 'Prénom',
              ),
              const SizedBox(height: 12),

              /// Last Name
              _buildTextField(
                controller: lastNameController,
                hintText: 'Nom',
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
                hintText: 'Mot De Passe',
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
                hintText: 'Confirmer Mot De Passe',
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
                hintText: 'Code Parrainage (Optionnel)',
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
                        const Text("J'accepte toutes les "),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'Conditions Générales',
                            style: TextStyle(
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
                        const SnackBar(
                          content: Text(
                            "Veuillez accepter les Conditions Générales pour continuer.",
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
                  child: const Text(
                    "S'INSCRIRE",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              /// Divider With Text
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Ou inscrivez-vous avec',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Expanded(child: Divider()),
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
