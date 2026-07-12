import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/app_manager.dart';
import 'package:happer_app/features/profile/bindings/user_profile_binding.dart';
import 'package:happer_app/features/profile/controllers/user_profile_controller.dart';
import 'package:happer_app/features/creator/screens/creator_tab_screen.dart';
import 'package:happer_app/features/creator/creator_tab_key.dart';
import 'package:happer_app/features/discover/discover_tab_key.dart';
import 'package:happer_app/shared/controllers/cart_controller.dart';
import 'package:happer_app/shared/widgets/cart_preview_pill.dart';
import 'package:happer_app/features/dashboard/screens/image_display_screen.dart';
import 'package:happer_app/features/discover/screens/discover_tab_screen.dart';
import 'package:happer_app/features/auth/screens/esign_popup.dart';
import 'package:happer_app/features/profile/screens/liked_images_screen.dart';
import 'package:happer_app/features/profile/screens/image_grid_screen.dart';
import 'package:happer_app/features/creator/data/models/suggestion_model.dart';
import 'package:happer_app/features/creator/screens/brand_inspirations_screen.dart';
import 'package:happer_app/features/auth/screens/register_screen.dart';
import 'package:happer_app/core/utils/search_service.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/core/utils/storage_service.dart';
import 'package:happer_app/core/services/notification_service.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:happer_app/features/profile/screens/profile_screen.dart';

import 'package:path_provider/path_provider.dart';

import 'package:happer_app/l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  final bool refreshAfterUpload;
  const DashboardScreen({super.key, this.refreshAfterUpload = false});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  late UserProfileController _profileController;
  int _activePointers = 0;
  ScrollPhysics _tabPhysics = const BouncingScrollPhysics();
  int _currentIndex = 0;
  bool _esignPopupShown = false;
  bool _tabBarVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
    UserProfileBinding().dependencies();
    _profileController = Get.find<UserProfileController>();
    ever(_profileController.user, (user) {
      if (!mounted) return;
      if (!_esignPopupShown &&
          user != null &&
          user.role == 1 &&
          !user.isEsignCompleted &&
          !AppManager.isLoginAsGuest) {
        _esignPopupShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
            _showEsignPopup(user);
          }
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshProfile();
    });
    // Fetch cart count using provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CartController>().fetchCartItemCount();
      // Initialize notification service after first frame
      _initializeNotifications();
    });

    // After uploading a selfie, schedule a delayed refresh so the new post appears
    if (widget.refreshAfterUpload) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          creatorTabKey.currentState?.forceRefresh();
        }
      });
    }
  }

  void _showEsignPopup(user) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => EsignPopup(
        user: user,
        onDone: () {
          if (mounted) {
            showAppSnackBar(
              AppLocalizations.of(context).creatorAccountActivated,
              isSuccess: true,
            );
          }
        },
      ),
    );
  }

  // Initialize notification service with permission request
  Future<void> _initializeNotifications() async {
    try {
      await NotificationService.instance.initialize();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh cart count when app comes back to foreground
      Get.find<CartController>().fetchCartItemCount();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when the screen becomes visible again
    // Added an artificial delay to ensure the server has time to process the update
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        Get.find<CartController>().fetchCartItemCount();
      }
    });
  }

  void _refreshProfile() {
    _profileController.fetchProfile();
  }

  Future<void> forceRefreshProfile() async {
    if (mounted) _refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        // Tapping anywhere on the bar scrolls the active tab to top
        // (Instagram-style). HitTestBehavior.opaque makes the whole bar
        // tappable, but the Jeu Concours button (and any other button in
        // `actions`) still wins the gesture arena for taps directly on it,
        // so its own onPressed keeps firing independently.
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _scrollActiveTabToTop,
          child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: MediaQuery.of(context).size.width * 0.35,
        leading: Obx(() {
          final profile = _profileController.user.value;
          if (profile != null &&
              profile.role == 1 &&
              !profile.isEsignCompleted) {
            return GestureDetector(
              onTap: () => _showEsignPopup(profile),
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.workspace_premium,
                            color: Colors.white, size: 13),
                        const SizedBox(width: 5),
                        Text(
                          AppLocalizations.of(context).activateCreatorAccount,
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF4C4C),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        centerTitle: true,
        title: Image.asset(
          width: 36,
          height: 36,
          'assets/images/singleLogo.png',
          fit: BoxFit.cover,
        ),
        actions: [
          // FCM test button
          AppManager.isLoginAsGuest
              ? TextButton(
                  onPressed: () async {
                    AppManager.isLoginAsGuest = false;
                    await StorageService.clearAuth();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context).seConnecter),
                )
              : const _GameContestButton(),
        ],
          ),
        ),
      ),
      //   controller: _tabController,
      //   physics: AppManager.isLoginAsGuest
      //       ? const NeverScrollableScrollPhysics() // disable swipe for guest
      //       : const BouncingScrollPhysics(),
      //   children: [CreatorTabScreen(key: creatorTabKey), DiscoverTabScreen()],
      // ),
      body: Column(
        children: [
          ClipRect(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              height: _tabBarVisible ? 50.0 : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  borderRadius: BorderRadius.zero,
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  controller: _tabController,
                  indicatorColor: Colors.black,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  onTap: (index) {
                    if (index == 1 && AppManager.isLoginAsGuest) {
                      showAppSnackBar(
                          'Veuillez vous connecter pour accéder à la communauté',
                          isSuccess: false);
                      _tabController.animateTo(_tabController.previousIndex);
                    }
                  },
                  tabs: [Tab(text: "CRÉATEUR"), Tab(text: "DÉCOUVRIR")],
                ),
              ),
            ),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.axis != Axis.vertical) return false;
                if (notification is ScrollUpdateNotification) {
                  final delta = notification.scrollDelta ?? 0;
                  // Only hide when genuinely scrolling down past the top. The
                  // pull-to-refresh overscroll (and its spring-back to 0) happens
                  // at pixels <= 0 and produces a positive delta, so guarding on
                  // pixels > 0 keeps the bars visible during a refresh.
                  if (delta > 2 && _tabBarVisible &&
                      notification.metrics.pixels > 0) {
                    setState(() => _tabBarVisible = false);
                  } else if (delta < -2 && !_tabBarVisible) {
                    setState(() => _tabBarVisible = true);
                  }
                }
                if (notification is ScrollEndNotification &&
                    notification.metrics.pixels <= 0 &&
                    !_tabBarVisible) {
                  setState(() => _tabBarVisible = true);
                }
                return false;
              },
              child: Listener(
                behavior: HitTestBehavior
                    .translucent, // ✅ let children still receive events
                onPointerDown: (event) {
                  _activePointers++;
                  if (_activePointers >= 2 &&
                      _tabPhysics is! NeverScrollableScrollPhysics &&
                      !AppManager.isLoginAsGuest) {
                    setState(() {
                      _tabPhysics = const NeverScrollableScrollPhysics();
                    });
                  }
                },
                onPointerUp: (event) {
                  _activePointers =
                      (_activePointers - 1).clamp(0, double.infinity).toInt();
                  if (_activePointers < 2 &&
                      _tabPhysics is! BouncingScrollPhysics &&
                      !AppManager.isLoginAsGuest) {
                    setState(() {
                      _tabPhysics = const BouncingScrollPhysics();
                    });
                  }
                },
                onPointerCancel: (event) {
                  _activePointers = 0;
                  if (_tabPhysics is! BouncingScrollPhysics &&
                      !AppManager.isLoginAsGuest) {
                    setState(() {
                      _tabPhysics = const BouncingScrollPhysics();
                    });
                  }
                },
                child: TabBarView(
                  controller: _tabController,
                  physics: AppManager.isLoginAsGuest
                      ? const NeverScrollableScrollPhysics()
                      : _tabPhysics,
                  children: [
                    CreatorTabScreen(
                      key: creatorTabKey,
                      // Swiping past the last image of a post moves to Discover.
                      onSwipeToDiscover: () => _tabController.animateTo(1),
                    ),
                    DiscoverTabScreen(key: discoverTabKey),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Bottom nav hides on scroll down and reappears on scroll up, in sync
      // with the top tab bar (both driven by _tabBarVisible). AnimatedAlign
      // collapses the height to 0 without hardcoding it, so the cart pill and
      // safe-area inset are handled automatically.
      bottomNavigationBar: ClipRect(
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          heightFactor: _tabBarVisible ? 1.0 : 0.0,
          child: _DashboardBottomNav(
            currentIndex: _currentIndex,
            profileController: _profileController,
            onTap: (index) {
              // Instagram-style: tapping the home icon while already on the home
              // tab smoothly scrolls the active feed back to the top.
              if (index == 0 && _currentIndex == 0 && _tabController.index == 0) {
                creatorTabKey.currentState?.scrollToTop();
                return;
              }
              setState(() => _currentIndex = index);
              _onTabTapped(index);
            },
          ),
        ),
      ),
    );
  }

  void _scrollActiveTabToTop() {
    if (_currentIndex != 0) return;
    if (_tabController.index == 0) {
      creatorTabKey.currentState?.scrollToTop();
    } else {
      discoverTabKey.currentState?.scrollToTop();
    }
  }

  void _onTabTapped(int index) async {
    if (index == 4) {
      if (AppManager.isLoginAsGuest) {
        showAppSnackBar('Veuillez vous connecter pour accéder au profil',
            isSuccess: false);
        setState(() => _currentIndex = 0);
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      ).then((_) {
        _refreshProfile();
        if (mounted) setState(() => _currentIndex = 0);
      });
    } else if (index == 3) {
      // ⭐ WISHLIST
      if (AppManager.isLoginAsGuest) {
        showAppSnackBar('Veuillez vous connecter pour acc\u00e9der aux favoris',
            isSuccess: false);
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LikedImagesScreen()),
      );
    } else if (index == 2) {
      if (AppManager.isLoginAsGuest) {
        showAppSnackBar('Veuillez vous connecter pour publier une photo',
            isSuccess: false);
        return;
      }
      final profile = _profileController.user.value;
      if (profile != null && profile.role == 1 && !profile.isEsignCompleted) {
        _showEsignPopup(profile);
        return;
      }
      // Open camera directly with the camera mode
      _showImageSourceOptions(context);
    } else if (index == 1) {
      // Search button index
      // If currently on the discover tab (index 1), switch to creator tab (index 0) first
      if (AppManager.isLoginAsGuest) {
        showAppSnackBar('Veuillez vous connecter pour rechercher',
            isSuccess: false);
        return;
      }
      if (_tabController.index == 1) {
        _tabController.animateTo(0);
      }

      // Show search overlay using the global search service with the search callback
      SearchService.showSearchOverlay(
        context,
        onSearch: (query) {
          _performCreatorSearch(query);
        },
        onSelectSuggestion: _onSelectSuggestion,
      );
    }
  }

  // Method to open camera directly
  void _openCameraDirectly() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera permission is required')),
      );
    }
  }

  // Method to handle the creator search
  void _performCreatorSearch(String query) {
    // Get reference to the CreatorTabScreen state using the global key
    final creatorTabState = creatorTabKey.currentState;

    if (creatorTabState != null) {
      // If we have a reference to the state, call its search method directly
      creatorTabState.searchCreators(query);
    } else {
      // If we can't access the state directly, show a message to the user

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Searching for creator: $query'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Handle a tapped autocomplete suggestion: a creator opens their profile,
  // a brand opens its dedicated "Inspirations" screen (selfies for that brand).
  void _onSelectSuggestion(SuggestionModel item) {
    if (item.id.isEmpty) return;
    if (item.isBrand) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BrandInspirationsScreen(
            brandId: item.id,
            brandName: item.title,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageGridScreen(userId: item.id),
        ),
      );
    }
  }

  void _showImageSourceOptions(BuildContext parentContext) {
    final l = AppLocalizations.of(parentContext);
    showModalBottomSheet(
      context: parentContext,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
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
              l.addPhoto,
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
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final image =
                    await ImagePicker().pickImage(source: ImageSource.camera);
                if (image == null) return;
                await _saveToDeviceGallery(File(image.path));
                final File appFile = await moveImageToAppFolder(image.path,
                    deleteOriginal: true);
                if (!parentContext.mounted) return;
                await _cropAndNavigate(appFile.path, parentContext);
              },
            ),
            const Divider(height: 1, color: Color(0xFFE8E8E8)),
            _buildSheetOption(
              icon: Icons.photo_library_outlined,
              label: l.chooseFromGallery,
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final image =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                if (image == null) return;
                final File appFile = await moveImageToAppFolder(image.path,
                    deleteOriginal: false);
                if (!parentContext.mounted) return;
                await _cropAndNavigate(appFile.path, parentContext);
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

  Future<File> moveImageToAppFolder(
    String imagePath, {
    required bool deleteOriginal,
  }) async {
    // 🔍 Original image path (camera / gallery)
    debugPrint('ORIGINAL IMAGE PATH: $imagePath');

    final appDir = await getApplicationDocumentsDirectory();
    debugPrint('APP DOCUMENT DIRECTORY: ${appDir.path}');

    final imagesDir = Directory('${appDir.path}/images');
    debugPrint('TARGET IMAGES FOLDER: ${imagesDir.path}');

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
      debugPrint('IMAGES FOLDER CREATED');
    }

    final newPath =
        '${imagesDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    debugPrint('NEW IMAGE PATH: $newPath');

    final File newFile = await File(imagePath).copy(newPath);

    debugPrint(
      'IMAGE COPIED SUCCESSFULLY: ${newFile.path}',
    );

    if (deleteOriginal) {
      try {
        await File(imagePath).delete();
        debugPrint(
          'ORIGINAL IMAGE DELETED (CAMERA ONLY)',
        );
      } catch (e) {
        debugPrint(
          'FAILED TO DELETE ORIGINAL IMAGE: $e',
        );
      }
    } else {
      debugPrint(
        'ORIGINAL IMAGE KEPT (GALLERY IMAGE)',
      );
    }

    return newFile;
  }

  Future<void> _saveToDeviceGallery(File imageFile) async {
    try {
      // Request access using Gal's built-in permission handling
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

  Future<void> _cropAndNavigate(
    String imagePath,
    BuildContext context,
  ) async {
    const ratio4x5 = _Portrait4x5();

    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      maxWidth: 800,
      maxHeight: 1000,
      compressQuality: 50,
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recadrez votre photo',
          toolbarColor: Colors.white,
          statusBarColor: Colors.white,
          backgroundColor: Colors.black,
          aspectRatioPresets: [ratio4x5],
          lockAspectRatio: true,
          initAspectRatio: ratio4x5,
        ),
        IOSUiSettings(
          title: 'Recadrez votre photo',
          aspectRatioPresets: [ratio4x5],
          aspectRatioLockEnabled: true,
          aspectRatioPickerButtonHidden: true,
          resetAspectRatioEnabled: false,
          rotateButtonsHidden: true,
        ),
      ],
    );

    if (croppedFile == null) {
      debugPrint('CROPPING CANCELED BY USER');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image editing canceled')),
        );
      }
      return;
    }

    debugPrint(
      'CROPPED IMAGE PATH: ${croppedFile.path}',
    );

    // Commented out save to gallery functionality
    // final croppedImage = File(croppedFile.path);
    // await saveImageToGallery(croppedImage);
    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageCropScreen(imageFile: File(croppedFile.path)),
      ),
    );
  }
}

class _Portrait4x5 implements CropAspectRatioPresetData {
  const _Portrait4x5();
  @override
  String get name => '4x5';
  @override
  (int, int)? get data => (4, 5);
}

// ─── Dashboard Widget Components ────────────────────────────────────────────

class _GameContestButton extends StatelessWidget {
  const _GameContestButton();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFF2ECEC), width: 0.5),
          ),
        ),
        onPressed: () => showAppSnackBar(l.restezAttentif, isSuccess: false),
        child: Text(
          l.gameContestTitle,
          style: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Colors.black),
        ),
      ),
    );
  }
}

class _DashboardBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final UserProfileController profileController;

  const _DashboardBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.profileController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CartPreviewPill(),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            currentIndex: currentIndex,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedFontSize: 0,
            unselectedFontSize: 0,
            onTap: onTap,
            items: [
              BottomNavigationBarItem(
                  icon: Image.asset('assets/images/b3home.png',
                      width: 32, height: 32, color: Colors.black),
                  label: ""),
              BottomNavigationBarItem(
                  icon: Image.asset('assets/images/b3search.png',
                      width: 32, height: 32, color: Colors.grey),
                  label: ""),
              BottomNavigationBarItem(
                  icon: Image.asset('assets/images/b3cam.png',
                      width: 32, height: 32, color: Colors.grey),
                  label: ""),
              BottomNavigationBarItem(
                  icon: Image.asset('assets/images/b3heart.png',
                      width: 32, height: 32, color: Colors.grey),
                  label: ""),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: currentIndex == 4 ? Colors.black : Colors.grey,
                        width: 1.5),
                  ),
                  child: Obx(() {
                    final picture = profileController.user.value?.picture;
                    final initials =
                        profileController.user.value?.initials ?? '?';
                    return picture != null && picture.isNotEmpty
                        ? CircleAvatar(
                            radius: 14,
                            backgroundImage: NetworkImage(picture),
                            key: ValueKey(picture))
                        : CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.black,
                            child: Text(initials.isNotEmpty ? initials : '?',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11)),
                          );
                  }),
                ),
                label: "",
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Custom camera screen with gallery button in the top right
