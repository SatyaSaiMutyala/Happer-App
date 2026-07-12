import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';
import 'package:happer_app/core/constants/app_colors.dart';
import 'package:happer_app/core/constants/app_dimensions.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/features/profile/bindings/user_profile_binding.dart';
import 'package:happer_app/features/profile/controllers/user_profile_controller.dart';
import 'package:happer_app/features/profile/models/user_profile_model.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:country_picker/country_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class MyProfileScreen extends StatefulWidget {
  final bool openEditOnLoad;
  const MyProfileScreen({super.key, this.openEditOnLoad = false});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  late final UserProfileController _controller;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    UserProfileBinding().dependencies();
    _controller = Get.find<UserProfileController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchProfile();
      if (widget.openEditOnLoad) {
        _openEditWhenReady();
      }
    });
  }

  void _openEditWhenReady() {
    bool opened = false;
    ever(_controller.user, (user) {
      if (!opened && user != null && mounted) {
        opened = true;
        _showEditSheet(user);
      }
    });
  }

  Future<void> _takePicture() async {
    final l = AppLocalizations.of(context);
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
      showAppSnackBar(l.cameraPermissionRequired, isSuccess: false);
    }
  }

  Future<void> _saveToDeviceGallery(File imageFile) async {
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) await Gal.requestAccess();
      await Gal.putImage(imageFile.path);
    } catch (e) {
      debugPrint('Failed to save image to gallery: $e');
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
              ctx: ctx,
              icon: Icons.camera_alt_outlined,
              label: l.prendreUnePhoto,
              onTap: _takePicture,
            ),
            const Divider(height: 1, color: Color(0xFFE8E8E8)),
            _buildSheetOption(
              ctx: ctx,
              icon: Icons.photo_library_outlined,
              label: l.chooseFromGallery,
              onTap: _pickImageFromGallery,
            ),
            const Divider(height: 1, color: Color(0xFFE8E8E8)),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetOption({
    required BuildContext ctx,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(ctx).pop();
        onTap();
      },
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
    _controller.isUploading.value = true;
    try {
      await _controller.uploadProfileImage(imageFile.path);
      if (!mounted) return;
      showAppSnackBar(AppLocalizations.of(context).profilePhotoUpdated,
          isSuccess: true);
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(AppLocalizations.of(context).profilePhotoUpdateFailed,
          isSuccess: false);
    } finally {
      _controller.isUploading.value = false;
    }
  }

  void _showEditSheet(UserProfileModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditProfileSheet(user: user),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: HapperAppBar(
        title: l.myProfileTitle,
        actions: [
          Obx(() {
            final user = _controller.user.value;
            if (user == null) return const SizedBox.shrink();
            return GestureDetector(
              onTap: () => _showEditSheet(user),
              child: const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.edit_outlined, size: 20, color: Colors.black),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.user.value == null) {
          return const _ProfileShimmer();
        }

        if (_controller.errorMessage.value != null &&
            _controller.user.value == null) {
          return _ErrorView(
            message: _controller.errorMessage.value!,
            onRetry: _controller.fetchProfile,
          );
        }

        final user = _controller.user.value;
        if (user == null) return const SizedBox.shrink();

        return RefreshIndicator(
          onRefresh: _controller.fetchProfile,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProfileHeader(
                  user: user,
                  isUploading: _controller.isUploading.value,
                  onCameraPressed: _showImageSourceDialog,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(label: l.personalInfoSection),
                      const SizedBox(height: 12),
                      _InfoCard(
                        rows: [
                          _InfoRowData(
                            icon: Icons.person_outline_rounded,
                            label: l.fullNameLabel,
                            value:
                                user.fullName.isNotEmpty ? user.fullName : '—',
                          ),
                          _InfoRowData(
                            icon: Icons.alternate_email_rounded,
                            label: l.usernameLabel,
                            value: user.username.isNotEmpty
                                ? '@${user.username}'
                                : '—',
                          ),
                          _InfoRowData(
                            icon: Icons.mail_outline_rounded,
                            label: l.adresseEmail,
                            value: user.email.isNotEmpty ? user.email : '—',
                          ),
                          if (user.fullPhone != null)
                            _InfoRowData(
                              icon: Icons.phone_outlined,
                              label: l.phoneLabel,
                              value: user.fullPhone!,
                            ),
                          if (user.dob != null && user.dob!.isNotEmpty)
                            _InfoRowData(
                              icon: Icons.cake_outlined,
                              label: l.dobLabel,
                              value: _formatDate(user.dob),
                            ),
                          if (user.createdAt != null)
                            _InfoRowData(
                              icon: Icons.calendar_today_outlined,
                              label: l.memberSinceLabel,
                              value: _formatDate(user.createdAt),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final UserProfileModel user;
  final bool isUploading;
  final VoidCallback onCameraPressed;

  const _ProfileHeader({
    required this.user,
    required this.isUploading,
    required this.onCameraPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          // Avatar with camera button
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFEEEEEE), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.primary,
                  child: user.hasPicture
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: user.picture!,
                            width: 104,
                            height: 104,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _InitialsAvatar(
                                initials: user.initials, radius: 52),
                            errorWidget: (_, __, ___) => _InitialsAvatar(
                                initials: user.initials, radius: 52),
                          ),
                        )
                      : _InitialsAvatar(initials: user.initials, radius: 52),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: isUploading ? null : onCameraPressed,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: isUploading
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

          const SizedBox(height: 16),

          // Full name (+ verified badge for creators only)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  user.fullName.isNotEmpty ? user.fullName : '—',
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              if (user.role == 1) ...[
                const SizedBox(width: 5),
                const Icon(Icons.verified,
                    size: 20, color: AppColors.textPrimary),
              ],
            ],
          ),

          const SizedBox(height: 4),

          // @username
          if (user.username.isNotEmpty)
            Text(
              '@${user.username}',
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                fontSize: 13,
                color: AppColors.textSecondary,
                letterSpacing: 0.2,
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _InitialsAvatar extends StatelessWidget {
  final String initials;
  final double radius;
  const _InitialsAvatar({required this.initials, required this.radius});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: radius * 2,
        height: radius * 2,
        color: AppColors.primary,
        alignment: Alignment.center,
        child: Text(
          initials,
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            fontSize: radius * 0.55,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'Lato',
        fontWeight: FontWeight.w600,
        fontSize: 11,
        color: AppColors.textSecondary,
        letterSpacing: 1.4,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _InfoRowData {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRowData({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _InfoCard extends StatelessWidget {
  final List<_InfoRowData> rows;
  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            _InfoRow(data: rows[i]),
            if (i < rows.length - 1)
              const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF2F2F2),
                  indent: 52),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final _InfoRowData data;
  const _InfoRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.p16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Icon(data.icon, size: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppDimensions.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.value,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: AppDimensions.fontM,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              ),
              child: const Icon(Icons.person_off_outlined,
                  size: 32, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Text(
              l.anErrorOccurred,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                fontSize: AppDimensions.fontM,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: AppDimensions.fontS,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  l.tryAgainButton,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600,
                    fontSize: AppDimensions.fontM,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EditProfileSheet extends StatefulWidget {
  final UserProfileModel user;
  const _EditProfileSheet({required this.user});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _dobCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _instagramCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _postalCtrl;
  late final TextEditingController _cityCtrl;
  late String _countryCode;
  int? _selectedGender;

  late final UserProfileController _controller;

  static const _genderOptions = [
    (label: 'Homme', value: 1),
    (label: 'Femme', value: 2),
    (label: 'Autre', value: 3),
  ];

  @override
  void initState() {
    super.initState();
    _controller = Get.find<UserProfileController>();
    _firstNameCtrl = TextEditingController(text: widget.user.firstName);
    _lastNameCtrl = TextEditingController(text: widget.user.lastName);
    _usernameCtrl = TextEditingController(text: widget.user.username);
    _dobCtrl = TextEditingController(
      text: widget.user.dob != null && widget.user.dob!.isNotEmpty
          ? _isoToDisplay(widget.user.dob!)
          : '',
    );
    _bioCtrl = TextEditingController(text: widget.user.bio ?? '');
    _instagramCtrl =
        TextEditingController(text: widget.user.instagramLink ?? '');
    _phoneCtrl = TextEditingController(text: widget.user.phone ?? '');
    _streetCtrl = TextEditingController(text: widget.user.streetAddress ?? '');
    _postalCtrl = TextEditingController(text: widget.user.postalCode ?? '');
    _cityCtrl = TextEditingController(text: widget.user.city ?? '');
    _countryCode = widget.user.countryCode?.isNotEmpty == true
        ? widget.user.countryCode!
        : '+33';
    final g = widget.user.gender;
    _selectedGender = (g != null && g >= 1 && g <= 3) ? g : null;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _dobCtrl.dispose();
    _bioCtrl.dispose();
    _instagramCtrl.dispose();
    _phoneCtrl.dispose();
    _streetCtrl.dispose();
    _postalCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  // "15 Jun 1995" ← "1995-06-15T00:00:00.000Z"
  static String _isoToDisplay(String iso) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  // "1995-06-15" → for API
  static String? _displayToIso(String display) {
    if (display.trim().isEmpty) return null;
    try {
      return DateFormat('yyyy-MM-dd')
          .format(DateFormat('dd MMM yyyy').parse(display));
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickDob() async {
    DateTime initial = DateTime(1995);
    if (_dobCtrl.text.isNotEmpty) {
      try {
        initial = DateTime.parse(_dobCtrl.text);
      } catch (e) {
        debugPrint('Failed to parse DOB text: $e');
      }
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.black),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _dobCtrl.text = DateFormat('dd MMM yyyy').format(picked);
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final mobileNumber =
        _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim();
    try {
      final success = await _controller.editProfile(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        dob: _displayToIso(_dobCtrl.text.trim()),
        gender: _selectedGender,
        bio: _bioCtrl.text.trim(),
        instagramLink: _instagramCtrl.text.trim(),
        mobileNumber: mobileNumber,
        countryCode: _countryCode,
        streetAddress: _streetCtrl.text.trim(),
        postalCode: _postalCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
      );
      if (success && mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  e.toString(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  InputDecoration _dec(String label, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
          fontFamily: 'Lato', color: AppColors.textSecondary, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      suffixIcon: suffix,
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    TextInputType? keyboard,
    bool required = true,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffix,
  }) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(fontFamily: 'Lato', fontSize: 15),
        decoration: _dec(label, suffix: suffix),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? l.fieldRequired : null
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  const SizedBox(width: 36),
                  Expanded(
                    child: Text(
                      l.editProfileTitle,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 0.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 18, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _field(l.firstNameLabel, _firstNameCtrl),
              _field(l.lastNameLabel, _lastNameCtrl),
              _field(l.usernameLabel, _usernameCtrl),

              // Read-only email
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  initialValue: widget.user.email,
                  readOnly: true,
                  enableInteractiveSelection: false,
                  style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 15,
                      color: AppColors.textSecondary),
                  decoration: _dec(l.adresseEmail,
                          suffix: const Icon(Icons.lock_outline,
                              size: 16, color: AppColors.textSecondary))
                      .copyWith(
                    fillColor: const Color(0xFFF2F2F2),
                  ),
                ),
              ),

              // Phone number row: country code + number
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Country code selector
                    GestureDetector(
                      onTap: () async {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: true,
                          onSelect: (country) {
                            setState(
                                () => _countryCode = '+${country.phoneCode}');
                          },
                        );
                      },
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusS),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _countryCode,
                              style: const TextStyle(
                                  fontFamily: 'Lato', fontSize: 15),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down,
                                size: 18, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Phone number input
                    Expanded(
                      child: TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        style:
                            const TextStyle(fontFamily: 'Lato', fontSize: 15),
                        decoration: _dec(l.phoneLabel),
                      ),
                    ),
                  ],
                ),
              ),

              // Date of birth (date picker)
              _field(
                l.dobLabel,
                _dobCtrl,
                required: false,
                readOnly: true,
                onTap: _pickDob,
                suffix: const Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppColors.textSecondary),
              ),

              // Gender picker
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<int>(
                  value: _selectedGender,
                  decoration: _dec('Genre'),
                  style: const TextStyle(
                      fontFamily: 'Lato', fontSize: 15, color: Colors.black),
                  items: _genderOptions
                      .map((g) => DropdownMenuItem(
                            value: g.value,
                            child: Text(g.label,
                                style: const TextStyle(fontFamily: 'Lato')),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedGender = v),
                ),
              ),

              _field('Bio', _bioCtrl,
                  required: false,
                  maxLines: 3,
                  keyboard: TextInputType.multiline),
              _field('Instagram', _instagramCtrl,
                  required: false, keyboard: TextInputType.url),
              _field('Adresse', _streetCtrl, required: false),
              _field('Code postal', _postalCtrl,
                  required: false, keyboard: TextInputType.number),
              _field('Ville', _cityCtrl, required: false),

              const SizedBox(height: 8),

              // Save button
              Obx(() {
                final saving = _controller.isSaving.value;
                return GestureDetector(
                  onTap: saving ? null : _submit,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: AppDimensions.buttonHeight,
                    decoration: BoxDecoration(
                      color: saving
                          ? AppColors.primary.withValues(alpha: 0.55)
                          : AppColors.primary,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    alignment: Alignment.center,
                    child: saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            l.saveButton,
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w700,
                              fontSize: AppDimensions.fontM,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shimmer skeleton ─────────────────────────────────────────────────────────

class _ProfileShimmer extends StatelessWidget {
  const _ProfileShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8E8E8),
      highlightColor: const Color(0xFFF5F5F5),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header block (white bg)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Column(
                children: [
                  // Avatar circle
                  Container(
                    width: 108,
                    height: 108,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Name
                  Container(
                    width: 120,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Username
                  Container(
                    width: 80,
                    height: 13,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            // Info card block
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section label
                  Container(
                    width: 160,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Info card rows
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: List.generate(4, (i) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          width: 160,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (i < 3) const Divider(height: 1, indent: 64),
                          ],
                        );
                      }),
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
