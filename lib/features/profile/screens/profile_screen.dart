import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gal/gal.dart';
// import 'package:happer_app/core/controllers/locale_controller.dart';
import 'package:happer_app/features/dashboard/screens/notifications_screen.dart';
import 'package:happer_app/features/profile/bindings/user_profile_binding.dart';
import 'package:happer_app/features/profile/controllers/user_profile_controller.dart';
import 'package:happer_app/features/profile/screens/my_account_screen.dart';
import 'package:happer_app/features/profile/screens/my_purchases_screen.dart';
import 'package:happer_app/features/profile/screens/profile_menu_item.dart';
import 'package:happer_app/features/profile/screens/profile_styles_screen.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final UserProfileController _controller;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    UserProfileBinding().dependencies();
    _controller = Get.find<UserProfileController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchProfile();
    });
  }

  // ─── Camera / Gallery ────────────────────────────────────────────────────────

  Future<void> _takePicture() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      try {
        final XFile? image =
            await _imagePicker.pickImage(source: ImageSource.camera);
        if (image != null) {
          _saveToDeviceGallery(File(image.path));
          _uploadProfilePicture(File(image.path));
        }
      } catch (e) {
        showAppSnackBar('$e', isSuccess: false);
      }
    } else {
      if (!mounted) return;
      showAppSnackBar(
          AppLocalizations.of(context).cameraPermissionRequired,
          isSuccess: false);
    }
  }

  Future<void> _saveToDeviceGallery(File imageFile) async {
    try {
      if (!await Gal.hasAccess()) await Gal.requestAccess();
      await Gal.putImage(imageFile.path);
    } catch (e) {
      debugPrint('Gallery save failed: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) _uploadProfilePicture(File(image.path));
    } catch (e) {
      showAppSnackBar('$e', isSuccess: false);
    }
  }

  void _showImageSourceDialog() {
    final l = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l.editProfilePhoto,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFE8E8E8)),
            _buildSheetOption(
              icon: Icons.camera_alt_outlined,
              label: l.prendreUnePhoto,
              onTap: () {
                Navigator.of(ctx).pop();
                _takePicture();
              },
            ),
            const Divider(height: 1, color: Color(0xFFE8E8E8)),
            _buildSheetOption(
              icon: Icons.photo_library_outlined,
              label: l.chooseFromGallery,
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImageFromGallery();
              },
            ),
            const Divider(height: 1, color: Color(0xFFE8E8E8)),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadProfilePicture(File imageFile) async {
    setState(() => _isUploading = true);
    try {
      await _controller.uploadProfileImage(imageFile.path);
      if (!mounted) return;
      showAppSnackBar(
          AppLocalizations.of(context).profilePhotoUpdated,
          isSuccess: true);
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
          AppLocalizations.of(context).profilePhotoUpdateFailed,
          isSuccess: false);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // ─── Language picker ─────────────────────────────────────────────────────────

  // void _showLanguagePicker() {
  //   final localeController = Get.find<LocaleController>();
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.white,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //     builder: (bsCtx) => Obx(() {
  //       final current = localeController.currentCode;
  //       return Padding(
  //         padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 40),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               AppLocalizations.of(bsCtx).languageLabel,
  //               style: const TextStyle(
  //                 fontFamily: 'Lato',
  //                 fontWeight: FontWeight.w600,
  //                 fontSize: 16,
  //                 color: Colors.black,
  //               ),
  //             ),
  //             const SizedBox(height: 16),
  //             _buildLanguageOption(
  //                 label: 'Français',
  //                 code: 'fr',
  //                 current: current,
  //                 controller: localeController),
  //             const Divider(color: Color(0xFFE8E8E8)),
  //             _buildLanguageOption(
  //                 label: 'English',
  //                 code: 'en',
  //                 current: current,
  //                 controller: localeController),
  //             const SizedBox(height: 16),
  //           ],
  //         ),
  //       );
  //     }),
  //   );
  // }

  // Widget _buildLanguageOption({
  //   required String label,
  //   required String code,
  //   required String current,
  //   required LocaleController controller,
  // }) {
  //   final isSelected = current == code;
  //   return GestureDetector(
  //     onTap: () {
  //       controller.changeLocale(code);
  //       Navigator.pop(context);
  //     },
  //     behavior: HitTestBehavior.opaque,
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(vertical: 12),
  //       child: Row(
  //         children: [
  //           Expanded(
  //             child: Text(
  //               label,
  //               style: TextStyle(
  //                 fontFamily: 'Lato',
  //                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
  //                 fontSize: 14,
  //                 color: isSelected ? Colors.black : const Color(0xFF5C5C5C),
  //               ),
  //             ),
  //           ),
  //           if (isSelected)
  //             const Icon(Icons.check, size: 18, color: Colors.black),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HapperAppBar(title: l.monCompteTitleLabel),
      body: RefreshIndicator(
        onRefresh: _controller.fetchProfile,
        color: Colors.black,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ── Avatar + name (shimmer while loading) ──
              Obx(() {
                final isLoading = _controller.isLoading.value &&
                    _controller.user.value == null;
                if (isLoading) return _HeaderShimmer();

                final user = _controller.user.value;
                final picture = user?.picture;
                final hasPicture =
                    picture != null && picture.trim().isNotEmpty;
                final initials = user?.initials ?? '?';
                final fullName =
                    '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();

                return Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.black,
                          child: hasPicture
                              ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: picture,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => _initialsWidget(
                                        initials),
                                    errorWidget: (_, __, ___) =>
                                        _initialsWidget(initials),
                                  ),
                                )
                              : ClipOval(child: _initialsWidget(initials)),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _isUploading
                                ? null
                                : _showImageSourceDialog,
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                              padding: const EdgeInsets.all(5),
                              child: _isUploading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
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
                    const SizedBox(height: 10),
                    Text(
                      fullName.isNotEmpty ? fullName : '—',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 40),

              // ── Menu items (always visible, no API dependency) ──
              ProfileMenuItem(
                title: l.mesCommandesTitle,
                svgPath: 'assets/images/product_svg.svg',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => MyPurchasesScreen())),
              ),
              ProfileMenuItem(
                title: l.mesLooksTitle,
                svgPath: 'assets/images/styles_Svg.svg',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => StylesScreen())),
              ),
              ProfileMenuItem(
                title: l.gameContestTitle,
                imagePath: 'assets/images/gift.png',
                onTap: () => showAppSnackBar(
                    'Le jeu concours arrive bientôt',
                    isSuccess: false),
              ),
              ProfileMenuItem(
                title: l.notifications,
                imagePath: 'assets/images/notification.png',
                imageRotation: 0.3,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => NotificationsScreen())),
              ),
              ProfileMenuItem(
                title: l.monCompte,
                svgPath: 'assets/images/my_account_svg.svg',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => MyAccountScreen())),
              ),
              // Obx(() {
              //   final code = Get.find<LocaleController>().currentCode;
              //   return ProfileMenuItem(
              //     title: l.languageLabel,
              //     trailingWidget: Text(
              //       code == 'fr' ? 'FR' : 'EN',
              //       style: const TextStyle(
              //         fontFamily: 'Lato',
              //         fontWeight: FontWeight.w500,
              //         fontSize: 13,
              //         color: Color(0xFF5C5C5C),
              //       ),
              //     ),
              //     onTap: _showLanguagePicker,
              //   );
              // }),

              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Image.asset('assets/images/singleLogo.png',
                    width: 60, height: 60),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _initialsWidget(String initials) {
    return Container(
      width: 100,
      height: 100,
      color: Colors.black,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ─── Shimmer for avatar + name ────────────────────────────────────────────────

class _HeaderShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8E8E8),
      highlightColor: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 120,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}
