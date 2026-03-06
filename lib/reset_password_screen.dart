import 'package:flutter/material.dart';
import 'package:happer_app/login_screen.dart';
import 'package:happer_app/webservices/auth_service.dart';

class ResetPasswordScreen extends StatelessWidget {
  final String email;

  const ResetPasswordScreen({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final codeController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

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
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  // 'Reset Password',
                  'Réinitialiser le mot de passe',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  // 'Enter the code received by email and\nyour new password',
                  'Saisissez le code reçu par e-mail et votre nouveau mot de passe',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: codeController,
                  decoration: InputDecoration(
                    hintText: 'Saisissez le code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Nouveau mot de passe',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Confirmez le mot de passe',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
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
                      // Validate passwords match
                      if (newPasswordController.text != confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Passwords do not match.'),
                          ),
                        );
                        return;
                      }

                      final authService = AuthService();
                      final success = await authService.resetPassword(
                        codeController.text,
                        email, // Use the email passed from the ForgotPasswordScreen
                        newPasswordController.text,
                      );

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password reset successfully.'),
                          ),
                        );
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false,
                        ); // Navigate back to the login screen
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to reset password.'),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'CONFIRM',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24), // Add padding at the bottom for keyboard
              ],
            ),
          ),
        ),
      ),
    );
  }
}
