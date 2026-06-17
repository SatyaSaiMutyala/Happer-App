import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/app/routes/app_routes.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:happer_app/features/profile/screens/change_password_screen.dart';
import 'package:happer_app/features/profile/screens/my_address_screen.dart';
import 'package:happer_app/features/profile/screens/my_profile_screen.dart';
import 'package:happer_app/core/utils/url_launcher_util.dart';
import 'package:happer_app/core/utils/storage_service.dart';
import 'package:happer_app/shared/widgets/confirm_dialog.dart';
import 'package:happer_app/l10n/app_localizations.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  String provider = '';

  @override
  void initState() {
    super.initState();
    _loadLoginProvider();
  }

  Future<void> _loadLoginProvider() async {
    setState(() {
      provider = StorageService.getLoginMethod() ?? 'email';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HapperAppBar(title: AppLocalizations.of(context).monCompteTitleLabel),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildListTile(
                  context,
                  title: AppLocalizations.of(context).myProfileTitle,
                  iconPath: 'assets/images/myaccount.svg',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyProfileScreen(),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  context,
                  title: AppLocalizations.of(context).myAddressTitle,
                  iconPath: 'assets/images/my_address.svg',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyAddressScreen(),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                if (provider != 'google' && provider != 'apple') ...[
                  _buildListTile(
                    context,
                    title: AppLocalizations.of(context).changePasswordTitle,
                    iconPath: 'assets/images/change_password.svg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                ],
                _buildListTile(
                  context,
                  title: AppLocalizations.of(context).termsAndConditions,
                  iconPath: 'assets/images/cgv.svg',
                  onTap: () {
                    UrlLauncherUtil.launchUrl(
                      context,
                      url: 'https://happer.fr/cgv',
                    );
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  context,
                  title: AppLocalizations.of(context).termsOfUse,
                  iconPath: 'assets/images/cgu.svg',
                  onTap: () {
                    UrlLauncherUtil.launchUrl(
                      context,
                      url: 'https://happer.fr/cgu',
                    );
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  context,
                  title: AppLocalizations.of(context).privacyPolicy,
                  iconPath: 'assets/images/privacy_policy.svg',
                  onTap: () {
                    UrlLauncherUtil.launchUrl(
                      context,
                      url: 'https://happer.fr/rgpd',
                    );
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  context,
                  title: AppLocalizations.of(context).deleteMyAccount,
                  iconPath: 'assets/images/delete_account.svg',
                  onTap: () async {
                    final l = AppLocalizations.of(context);
                    final userId = StorageService.getUserId();

                    if (userId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User ID not found')),
                      );
                      return;
                    }

                    final confirmed = await showConfirmDialog(
                      context,
                      title: l.deleteMyAccount,
                      message:
                          'Cette action est définitive. Toutes vos données seront supprimées et ne pourront pas être récupérées.',
                      confirmLabel: l.delete,
                      cancelLabel: l.cancel,
                      icon: Icons.delete_outline_rounded,
                      type: ConfirmType.danger,
                    );
                    if (!confirmed) return;

                    // Dummy: deleteAccount API will be wired when integrated
                    StorageService.clearAuth();
                    Get.offAllNamed(AppRoutes.login);
                  },
                ),
              ],
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(
          //     horizontal: 20.0,
          //     vertical: 24.0,
          //   ),
          //   child: SizedBox(
          //     width: double.infinity,
          //     child: ElevatedButton(
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: Color(0xFF1E1E1E),
          //         padding: EdgeInsets.symmetric(vertical: 16),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.zero,
          //         ),
          //       ),
          //       onPressed: () async {
          //         await profileApiService.logout(context);
          //       },
          //       child: Text(
          //         'SE DECONNECTER',
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontSize: 14,
          //           fontWeight: FontWeight.w600,
          //           fontFamily: 'Lato',
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E1E1E),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              onPressed: () async {
                final l = AppLocalizations.of(context);
                final confirmed = await showConfirmDialog(
                  context,
                  title: l.logout,
                  message: 'Voulez-vous vraiment vous déconnecter ?',
                  confirmLabel: l.logout,
                  cancelLabel: l.cancel,
                  icon: Icons.logout_rounded,
                  isDangerous: true,
                );
                if (!confirmed) return;
                StorageService.clearAuth();
                Get.offAllNamed(AppRoutes.login);
              },
              child: Text(
                AppLocalizations.of(context).logout,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Lato',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    required String iconPath,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Lato',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF5C5C5C),
        ),
      ),
      trailing: SvgPicture.asset(
        iconPath,
        width: 15,
        height: 15,
        color: Color(0xFF5C5C5C),
      ),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
    );
  }
}
