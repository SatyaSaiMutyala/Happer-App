import 'package:flutter/material.dart';
import 'package:happer_app/app_manager.dart';
import 'package:happer_app/core/utils/storage_service.dart';
import 'package:happer_app/features/auth/screens/register_screen.dart';
import 'package:happer_app/features/selfies/controllers/selfie_controller.dart';

/// Prompts a guest to sign in before an action that needs a real account.
///
/// Guests used to get an error snackbar (and for the cart, the request simply
/// failed server-side first), which read as a bug rather than a prompt. Tapping
/// "Se connecter" clears the guest session and drops the user on the register /
/// login screen, matching the header's guest sign-in button.
Future<void> showLoginRequiredDialog(
  BuildContext context, {
  String message = 'Connectez-vous pour continuer.',
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.lock_outline, color: Colors.black, size: 26),
          ),
          const SizedBox(height: 18),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Connexion requise',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Annuler',
                        style: TextStyle(
                            fontFamily: 'Lato', fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();
                      AppManager.isLoginAsGuest = false;
                      await StorageService.clearAuth();
                      SelfieController.clearIfRegistered();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => RegisterScreen()),
                        (route) => false,
                      );
                    },
                    child: const Text('Se connecter',
                        style: TextStyle(
                            fontFamily: 'Lato', fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
