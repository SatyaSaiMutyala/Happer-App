import 'package:flutter/material.dart';
import 'package:happer_app/app_manager.dart';
import 'package:happer_app/dashboard/screens/dashboard_screen.dart';
import 'package:happer_app/login_screen.dart';
import 'package:happer_app/profile/api/profile_api.dart';
import 'package:happer_app/signup_screen.dart';
import 'package:happer_app/webservices/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
  Future<void> _saveIsGuestLogin(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_guest_login', value);
    AppManager.isLoginAsGuest = value;
  }

  @override
  Widget build(BuildContext context) {
 

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Top Images
              Expanded(
                flex: 6,
                child: Row(
                  children: [
                    // Left tall image
                    Expanded(
                      flex: 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/img1.jpg',
                          fit: BoxFit.cover,
                          height: double.infinity,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right two stacked images
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/images/img2.jpg',
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/images/img3.jpg',
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Title and Description
              SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Adjusted the tagline layout to match the screenshot
                    Column(
                      //crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     Text.rich(
                        //       TextSpan(
                        //         text: "The ",
                        //         style: TextStyle(
                        //           fontFamily: "Lato",
                        //           fontWeight: FontWeight.w700,
                        //           fontSize: 23,
                        //           height: 1.0,
                        //           letterSpacing: 0.0,
                        //           color: Colors.grey,
                        //         ),
                        //         children: [
                        //           TextSpan(
                        //             text: "Fashion App ",
                        //             style: TextStyle(
                        //               fontWeight: FontWeight.w700,
                        //               color: Colors.black,
                        //             ),
                        //           ),
                        //           TextSpan(
                        //             text: "For Content",
                        //             style: TextStyle(
                        //               fontWeight: FontWeight.w700,
                        //               color: Colors.grey,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //       textAlign: TextAlign.center,
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 4),
                        // const Text(
                        //   "Creators",
                        //   style: TextStyle(
                        //     fontFamily: "",
                        //     fontWeight: FontWeight.w700,
                        //     fontSize: 24,
                        //     height: 1.0,
                        //     letterSpacing: 0.0,
                        //     color: Colors.black,
                        //   ),
                        //   textAlign: TextAlign.center,
                        // ),
                        Image.asset('assets/images/logo_header.png', 
                                fit: BoxFit.cover,
                                width: 150),
                        SizedBox(height: 16),
                        Text(
                          style: TextStyle(
                            fontFamily: "Lato",
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            height: 1.0,
                            letterSpacing: 0.0,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                          // 'Lorem ipsum is a dummy or placeholder text commonly used in graphic design, and web development.',
                          'Rejoignez une communauté de passionnés de mode, découvrez des looks incroyables et partagez votre style.'
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // const Text(
                    //   "Lorem ipsum is a dummy or placeholder text commonly used in graphic design, and web development.",
                    //   style: TextStyle(
                    //     color: Colors.grey,
                    //     fontSize: 14,
                    //   ),
                    //   textAlign: TextAlign.center,
                    // ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          _saveIsGuestLogin(false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          // "Let’s Get Started",
                          "Commencer",
                          style: TextStyle(
                            fontFamily: "Lato",
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            height: 1.0,
                            letterSpacing: 0.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          // "Already have an account? ",
                          "Vous avez déjà un compte ?",
                          style: TextStyle(
                            fontFamily: "Lato",
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            height: 1.0,
                            letterSpacing: 0.0,
                            color: Colors.grey,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _saveIsGuestLogin(false);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            // " Sign In",
                            "Se connecter",
                            style: TextStyle(
                              fontFamily: "Lato",
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              height: 1.0,
                              letterSpacing: 0.0,
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // const SizedBox(height: 8),
                    TextButton(
                      onPressed: () async {
                        final authService = AuthService();
                        final success = await authService.loginUser(
                          "dk@gmail.com",
                          "123456",
                        );
                        if (success) {
                          await _saveIsGuestLogin(true);
                          AppManager.isLoginAsGuest = true;

                          // Add small delay to ensure token is fully saved before navigation
                          await Future.delayed(const Duration(milliseconds: 300));

                          if (!context.mounted) return;

                          // Use pushAndRemoveUntil to clear all previous routes
                          // This prevents back button from showing login screen again
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DashboardScreen(),
                            ),
                            (route) => false, // Remove all previous routes
                          );
                        } else {
                          // Show error if guest login fails
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to continue as guest. Please try again.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                        // "Login as a guest",
                        "Continuer en tant qu’invité",
                        style: TextStyle(
                          fontFamily: "Lato",
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 1.0,
                          letterSpacing: 0.0,
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
