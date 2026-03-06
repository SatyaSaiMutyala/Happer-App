import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:happer_app/dashboard/screens/dashboard_screen.dart';
import 'package:happer_app/dashboard/screens/nogame_screen.dart';
import 'package:happer_app/dashboard/screens/notifications_screen.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/profile/api/profile_api.dart';
import 'package:happer_app/profile/api/profile_upload_service.dart';
import 'package:happer_app/profile/ui/code_credit_screen.dart';
import 'package:happer_app/profile/ui/game_contest_profile_screen.dart';
import 'package:happer_app/profile/ui/my_account_screen.dart';
import 'package:happer_app/profile/ui/my_purchases_screen.dart';
import 'package:happer_app/profile/ui/profile_menu_item.dart';
import 'package:happer_app/profile/ui/profile_product_screen.dart';
import 'package:happer_app/profile/ui/profile_styles_screen.dart';
import 'package:happer_app/profile/ui/return_refund_screen.dart';
import 'package:happer_app/utils/snackbar.dart';
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
      ).showSnackBar(SnackBar(content: Text('L\'autorisation de la caméra est requise')));
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
          title: Text('Modifier la photo de profil'),
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
                        Text('Prendre une photo'),
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
                        Text('Choisir dans la galerie'),
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
              content: Text('Photo de profil mise à jour avec succès'),
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
          SnackBar(content: Text('Échec de la mise à jour de la photo de profil')),
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
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
      ),
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
                  // title: AppLocalizations.of(context).product_title,
                  title: 'Mes Commandes',
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
                  // title: AppLocalizations.of(context).myStyles,
                  title: 'Mes Looks',
                  svgPath: 'assets/images/styles_Svg.svg',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StylesScreen()),
                    );
                  },
                ),
                ProfileMenuItem(
                  title: 'Jeu Concours',
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
                  // title: AppLocalizations.of(context).myAccount,
                  title: 'Mon Compte',
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
