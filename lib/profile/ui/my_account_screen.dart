import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:happer_app/login_screen.dart';
import 'package:happer_app/profile/api/profile_api.dart';
import 'package:happer_app/profile/ui/change_password_screen.dart';
import 'package:happer_app/profile/ui/my_address_screen.dart';
import 'package:happer_app/utils/url_launcher_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  final profileApiService = ProfileApiService();
  String provider = '';

  @override
  void initState() {
    super.initState();
    _loadLoginProvider();
  }

  Future<void> _loadLoginProvider() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      provider = prefs.getString('login_method') ?? 'email';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'MON COMPTE',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            height: 1.0,
            letterSpacing: 0.0,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildListTile(
                  context,
                  title: 'Mon Addresse',
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
                    title: 'Changer mon mot de passe',
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
                  title: 'CGV',
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
                  title: 'CGU',
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
                  title: 'Politique Privée',
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
                  title: 'Supprimer Mon Compte',
                  iconPath: 'assets/images/delete_account.svg',
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final userId = prefs.getString('myId');

                    if (userId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User ID not found')),
                      );
                      return;
                    }

                    // Step 1: Trigger delete_procedure API
                    await profileApiService.initiateDeleteAccount(
                      userId,
                      context,
                    );

                    // Step 2: Show dialog to enter verification code
                    final TextEditingController codeController =
                        TextEditingController();

                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Delete Account'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Enter the verification code sent to your email.',
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: codeController,
                                decoration: const InputDecoration(
                                  labelText: 'Verification Code',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final code = codeController.text.trim();
                                if (code.isNotEmpty) {
                                  if (context.mounted)
                                    Navigator.of(context).pop();

                                  try {
                                    final response = await profileApiService
                                        .deleteAccount(context, code);
                                    // If deleteAccount returns void, just navigate after successful call
                                    if (context.mounted) {
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const LoginScreen()),
                                        (route) => false,
                                      );
                                    }
                                  } catch (e) {
                                    debugPrint('Error in deleteAccount: $e');
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('Error: ${e.toString()}')),
                                      );
                                    }
                                  }
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Please enter the code')),
                                    );
                                  }
                                }
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
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
                await profileApiService.logout(context);
              },
              child: const Text(
                'SE DECONNECTER',
                style: TextStyle(
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
      padding: EdgeInsets.only(left: 20),
      child: Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
    );
  }
}
