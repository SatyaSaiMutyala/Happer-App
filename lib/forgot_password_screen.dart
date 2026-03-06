import 'package:flutter/material.dart';
import 'package:happer_app/reset_password_screen.dart';
import 'package:happer_app/webservices/auth_service.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                // 'Forgot Password',
                'Mot de passe oublié',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                // 'please enter your registered email to get\nyour new password',
                'Veuillez saisir votre adresse e-mail enregistrée pour obtenir votre nouveau mot de passe',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
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
                    final authService = AuthService();
                    final success = await authService.sendPasswordResetCode(
                      emailController.text,
                    );
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Password reset code sent to your email.',
                          ),
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResetPasswordScreen(email: emailController.text),
                        ),
                      );
                    } else if (emailController.text.isEmpty) {
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Failed to send password reset code. Please try again.',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    // 'SEND CODE',
                    'Envoyer le code',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
