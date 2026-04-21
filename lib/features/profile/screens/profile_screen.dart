import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/core/controllers/locale_controller.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:gal/gal.dart';
import 'package:happer_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:happer_app/features/dashboard/screens/nogame_screen.dart';
import 'package:happer_app/features/dashboard/screens/notifications_screen.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/features/profile/api/profile_api.dart';
import 'package:happer_app/features/profile/api/profile_upload_service.dart';
import 'package:happer_app/features/profile/screens/code_credit_screen.dart';
import 'package:happer_app/features/profile/screens/game_contest_profile_screen.dart';
import 'package:happer_app/features/profile/screens/my_account_screen.dart';
import 'package:happer_app/features/profile/screens/my_purchases_screen.dart';
import 'package:happer_app/features/profile/screens/profile_menu_item.dart';
import 'package:happer_app/features/profile/screens/profile_product_screen.dart';
import 'package:happer_app/features/profile/screens/profile_styles_screen.dart';
import 'package:happer_app/features/profile/screens/return_refund_screen.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _userProfile;
  final ImagePicker _imagePicker = ImagePicker();
  final ProfileUploadService _uploadService = ProfileUploadService();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _userProfile = ProfileApiService().fetchCurrentUserProfile();
  }

  Future<void> _takePicture() async {
    // Request camera permission
    final status = await Permission.camera.request();
    if (status.isGranted) {
      try {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.camera,
        );
        if (image != null) {
          // Save original photo to device gallery
          _saveToDeviceGallery(File(image.path));
          _uploadProfilePicture(File(image.path));
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur lors de la prise de photo: $e')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).cameraPermissionRequired)));
    }
  }

  Future<void> _saveToDeviceGallery(File imageFile) async {
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

      await Gal.putImage(imageFile.path);
      debugPrint('Image saved to gallery successfully');
    } catch (e) {
      debugPrint('Failed to save image to gallery: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        _uploadProfilePicture(File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur lors de la sélection de la photo: $e')));
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).editProfilePhoto),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.camera_alt, color: Colors.black),
                        SizedBox(width: 10),
                        Text(AppLocalizations.of(context).prendreUnePhoto),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _takePicture();
                  },
                ),
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.photo_library, color: Colors.black),
                        SizedBox(width: 10),
                        Text(AppLocalizations.of(context).chooseFromGallery),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImageFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _uploadProfilePicture(File imageFile) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final result = await _uploadService.uploadProfilePicture(imageFile);
      if (result != null) {
        if (result.containsKey('error')) {
          setState(() {
            _isUploading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error']),
              duration: Duration(seconds: 5),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        } else {
          // Success! Navigate to dashboard and refresh user profile data
          setState(() {
            _isUploading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).profilePhotoUpdated),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to the dashboard with a delay to ensure server processes the update
          Future.delayed(Duration(milliseconds: 500), () {
            // Navigate to dashboard screen explicitly to avoid going back to login/register screen
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (route) => false,
            );
          });
        }
      } else {
        setState(() {
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).profilePhotoUpdateFailed)),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  void _showLanguagePicker() {
    final localeController = Get.find<LocaleController>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bsCtx) => Obx(() {
        final current = localeController.currentCode;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(bsCtx).languageLabel,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              _buildLanguageOption(
                label: 'Français',
                code: 'fr',
                current: current,
                localeController: localeController,
              ),
              const Divider(color: Color(0xFFE8E8E8)),
              _buildLanguageOption(
                label: 'English',
                code: 'en',
                current: current,
                localeController: localeController,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLanguageOption({
    required String label,
    required String code,
    required String current,
    required LocaleController localeController,
  }) {
    final isSelected = current == code;
    return GestureDetector(
      onTap: () {
        localeController.changeLocale(code);
        Navigator.pop(context);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 14,
                  color: isSelected ? Colors.black : const Color(0xFF5C5C5C),
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, size: 18, color: Colors.black),
          ],
        ),
      ),
    );
  }

  String _getInitials(String firstName, String lastName) {
    String initials = '';
    if (firstName.isNotEmpty) {
      initials += firstName[0].toUpperCase();
    }
    if (lastName.isNotEmpty) {
      initials += lastName[0].toUpperCase();
    }
    return initials.isNotEmpty ? initials : 'NA';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HapperAppBar(title: AppLocalizations.of(context).monCompteTitleLabel),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final userData = snapshot.data!;
            return Column(
              children: [
                SizedBox(height: 20),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: userData['picture'] != null &&
                                userData['picture'].isNotEmpty
                            ? NetworkImage(userData['picture'])
                            : null,
                        child: userData['picture'] == null ||
                                userData['picture'].isEmpty
                            ? Text(
                                _getInitials(
                                  userData['first_name'] ?? '',
                                  userData['last_name'] ?? '',
                                ),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showImageSourceDialog,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                            padding: EdgeInsets.all(5),
                            child: _isUploading
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Image.asset(
                                    'assets/images/camera_icon.png',
                                    color: Colors.white,
                                    width: 16,
                                    height: 16,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                //  SizedBox(height: 10),
                Text(
                  '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 40),
                // Text(
                //   userData['email'],
                //   style: TextStyle(fontSize: 14, color: Colors.grey),
                // ),
                // SizedBox(height: 30),
                ProfileMenuItem(
                  title: AppLocalizations.of(context).mesCommandesTitle,
                  svgPath: 'assets/images/product_svg.svg',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyPurchasesScreen()),
                    );
                  },
                ),
                ProfileMenuItem(
                  title: AppLocalizations.of(context).mesLooksTitle,
                  svgPath: 'assets/images/styles_Svg.svg',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StylesScreen()),
                    );
                  },
                ),
                ProfileMenuItem(
                  title: AppLocalizations.of(context).gameContestTitle,
                  imagePath: 'assets/images/gift.png',
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => DummyGameContestScreen()),
                    // );
                    showAppSnackBar("Le jeu concours arrive bientôt",
                        isSuccess: false);
                  },
                ),

                ProfileMenuItem(
                  title: AppLocalizations.of(context).notifications,
                  imagePath: 'assets/images/notification.png',
                  imageRotation: 0.3,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationsScreen(),
                      ),
                    );
                  },
                ),

                ProfileMenuItem(
                  title: AppLocalizations.of(context).monCompte,
                  svgPath: 'assets/images/my_account_svg.svg',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyAccountScreen(),
                      ),
                    );
                  },
                ),
                Obx(() {
                  final code = Get.find<LocaleController>().currentCode;
                  return ProfileMenuItem(
                    title: AppLocalizations.of(context).languageLabel,
                    trailingWidget: Text(
                      code == 'fr' ? 'FR' : 'EN',
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: Color(0xFF5C5C5C),
                      ),
                    ),
                    onTap: _showLanguagePicker,
                  );
                }),
                const Spacer(),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Image.asset(
                    "assets/images/singleLogo.png",
                    width: 60,
                    height: 60,
                  ),
                ),
              ],
            );
          } else {
            return Center(child: Text('Aucune donnée disponible'));
          }
        },
      ),
    );
  }
}
