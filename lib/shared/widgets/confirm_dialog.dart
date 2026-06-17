import 'package:flutter/material.dart';
import 'package:happer_app/core/constants/app_colors.dart';
import 'package:happer_app/core/constants/app_dimensions.dart';

/// Confirmation dialog type — controls icon and button accent colour.
enum ConfirmType {
  normal,   // black accent (default — save, update, proceed, etc.)
  danger,   // red accent  (delete, remove, deactivate, etc.)
  warning,  // amber accent (irreversible but non-destructive actions)
}

/// Shows a project-themed confirm dialog. Returns `true` if confirmed.
///
/// ```dart
/// final ok = await showConfirmDialog(
///   context,
///   title: l.deleteAddressTitle,
///   message: l.deleteAddressConfirm,
///   confirmLabel: l.delete,
///   cancelLabel: l.cancel,
///   icon: Icons.delete_outline_rounded,
///   type: ConfirmType.danger,
/// );
/// if (ok) { ... }
/// ```
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  IconData icon = Icons.help_outline_rounded,
  ConfirmType type = ConfirmType.normal,

  /// Kept for backward-compatibility — prefer [type] for new call-sites.
  bool isDangerous = false,
}) async {
  final resolvedType =
      isDangerous ? ConfirmType.danger : type;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.60),
    builder: (_) => _ConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      icon: icon,
      type: resolvedType,
    ),
  );
  return result ?? false;
}

// ─────────────────────────────────────────────────────────────────────────────

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final IconData icon;
  final ConfirmType type;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.icon,
    required this.type,
  });

  Color get _accentColor => switch (type) {
        ConfirmType.danger  => AppColors.error,
        ConfirmType.warning => const Color(0xFFF57C00),
        ConfirmType.normal  => AppColors.primary,
      };

  Color get _iconBg => switch (type) {
        ConfirmType.danger  => const Color(0xFFFDECEC),
        ConfirmType.warning => const Color(0xFFFFF3E0),
        ConfirmType.normal  => const Color(0xFFF5F5F5),
      };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEEEEEE), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Grey header — icon ──────────────────────────────────────────
            Container(
              color: const Color(0xFFF7F7F7),
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _iconBg,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusL),
                    border: Border.all(
                      color: _accentColor.withValues(alpha: 0.15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 26, color: _accentColor),
                ),
              ),
            ),

            // ── Text content ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                      fontSize: AppDimensions.fontL,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: AppDimensions.fontM,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

            // ── Buttons ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppDimensions.p16),
              child: Row(
                children: [
                  Expanded(
                    child: _DialogButton(
                      label: cancelLabel,
                      onTap: () => Navigator.pop(context, false),
                      outlined: true,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.p12),
                  Expanded(
                    child: _DialogButton(
                      label: confirmLabel,
                      onTap: () => Navigator.pop(context, true),
                      bgColor: _accentColor,
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
}

// ─────────────────────────────────────────────────────────────────────────────

class _DialogButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool outlined;
  final Color bgColor;

  const _DialogButton({
    required this.label,
    required this.onTap,
    this.outlined = false,
    this.bgColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppDimensions.buttonHeight,
        decoration: BoxDecoration(
          color: outlined ? Colors.white : bgColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          border: Border.all(
            color: outlined ? const Color(0xFFDDDDDD) : bgColor,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: AppDimensions.fontM,
            color: outlined ? AppColors.textPrimary : Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
