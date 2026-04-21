import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:happer_app/app_manager.dart';
import 'package:happer_app/features/product/api/api_client.dart';

import 'package:happer_app/features/creator/api/cart_api.dart';
import 'package:happer_app/features/creator/screens/creator_tab_screen.dart';
import 'package:happer_app/shared/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:happer_app/features/dashboard/screens/game_contest_screen.dart';
import 'package:happer_app/features/dashboard/screens/image_display_screen.dart';
import 'package:happer_app/features/dashboard/screens/nogame_screen.dart';
import 'package:happer_app/features/discover/screens/discover_tab_screen.dart';
import 'package:happer_app/features/auth/screens/login_screen.dart';
import 'package:happer_app/features/profile/api/profile_api.dart';
import 'package:happer_app/features/profile/screens/liked_images_screen.dart';
import 'package:happer_app/features/auth/screens/register_screen.dart';
import 'package:happer_app/core/utils/search_service.dart'; // Import SearchService
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/core/network/user_service.dart'; // Import UserService
import 'package:happer_app/core/services/notification_service.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:happer_app/features/profile/screens/profile_screen.dart';
import 'address_screen.dart';
import 'cart_screen.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

// import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:happer_app/l10n/app_localizations.dart';

// Global key for CreatorTabScreen - keep only this definition
final GlobalKey<CreatorTabScreenState> creatorTabKey =
    GlobalKey<CreatorTabScreenState>();

class DashboardScreen extends StatefulWidget {
  final bool refreshAfterUpload;
  const DashboardScreen({super.key, this.refreshAfterUpload = false});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  String? _userProfilePicture;
  String _userInitials = '';
  final UserService _userService = UserService();
  int _activePointers = 0;
  ScrollPhysics _tabPhysics = const BouncingScrollPhysics();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
    _fetchUserProfile();
    // Fetch cart count using provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().fetchCartItemCount();
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
      context.read<CartProvider>().fetchCartItemCount();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when the screen becomes visible again
    // Added an artificial delay to ensure the server has time to process the update
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        _fetchUserProfile();
        context.read<CartProvider>().fetchCartItemCount(); // Refresh cart count when screen becomes visible
      }
    });
  }

  // Fetch user profile data
  Future<void> _fetchUserProfile() async {
    try {
      // Add a small delay to ensure server has processed any updates
      await Future.delayed(Duration(milliseconds: 300));

      // Add cache-busting parameter to ensure we get fresh data
      final profileData = await _userService.fetchUserProfile(
        forceRefresh: true,
      );

      debugPrint(
        'Profile refresh: Got profile data with picture: ${profileData?['picture']}',
      );

      if (mounted) {
        setState(() {
          if (profileData != null) {
            // If picture exists and is not empty, use it
            if (profileData['picture'] != null &&
                profileData['picture'].toString().isNotEmpty) {
              _userProfilePicture = profileData['picture'];
              debugPrint('Updated profile picture URL: $_userProfilePicture');
            } else {
              _userProfilePicture =
                  null; // Explicitly set to null if no picture
            }

            // Get initials for fallback avatar
            final firstName = profileData['first_name'] as String? ?? '';
            final lastName = profileData['last_name'] as String? ?? '';

            String initials = '';
            if (firstName.isNotEmpty) {
              initials += firstName[0].toUpperCase();
            }
            if (lastName.isNotEmpty) {
              initials += lastName[0].toUpperCase();
            }
            _userInitials = initials;
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    }
  }

  // Public method to force refresh the profile data
  Future<void> forceRefreshProfile() async {
    debugPrint('Force refreshing profile data from external call');

    // Add a small delay to ensure the server has processed any updates
    await Future.delayed(Duration(milliseconds: 800));

    // Force refresh profile data from API
    if (mounted) {
      await _fetchUserProfile();
      debugPrint('Profile data refreshed successfully after force refresh');
    }
  }

  final profileApiService = ProfileApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 50),
        child: Column(
          children: [
            AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: !AppManager.isLoginAsGuest
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(),
                            ),
                          ).then((_) {
                            // Refresh profile when returning from ProfileScreen
                            debugPrint(
                              'Returned from ProfileScreen, refreshing profile data',
                            );
                            _fetchUserProfile();
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(2), // Border thickness
                          child: _userProfilePicture != null &&
                                  _userProfilePicture!.isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    _userProfilePicture! +
                                        '?nocache=${DateTime.now().millisecondsSinceEpoch}',
                                  ),
                                  key: ValueKey(
                                    DateTime.now().toString(),
                                  ), // Force recreate widget on update
                                )
                              : CircleAvatar(
                                  backgroundColor: Colors.grey[300],
                                  child: Text(
                                    _userInitials.isNotEmpty
                                        ? _userInitials
                                        : 'NA',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ), // Circular Border
                          ),
                        ),
                      ),
                    )
                  : null,
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
                          // Implement login logic here
                          AppManager.isLoginAsGuest = false;
                          profileApiService.logout(context);
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => LoginScreen(),
                          //   ),
                          // );
                        },
                        child: Text("Se connecter"),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 8,
                            ), // Adjust padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color:
                                    Color(0xFFF2ECEC), // Updated border color
                                width: 0.5, // Updated border width
                              ),
                            ),
                          ),
                          onPressed: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     // builder: (context) => GameContestScreen(),
                            //     builder: (context) => DummyGameContestScreen(),
                            //   ),
                            // );
                            showAppSnackBar(
                                "Le jeu concours arrive bientôt",
                                isSuccess: false);
                          },
                          child: Text(
                            // "Game Contest",
                            "Jeu Concours",
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              height:
                                  1.0, // Line height as a multiplier of font size
                              letterSpacing: 0.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300, // Outline border color
                  width: 1, // Border width
                ),
                borderRadius: BorderRadius.zero, // Border radius for TabBar
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                controller: _tabController,
                indicatorColor: Colors.black,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                onTap: (index) {
                  if (index == 1 && AppManager.isLoginAsGuest) {
                    showAppSnackBar('Veuillez vous connecter pour acc\u00e9der \u00e0 la communaut\u00e9',
                        isSuccess: false);
                    _tabController.animateTo(_tabController.previousIndex);
                  }
                },
                // tabs: [Tab(text: "CREATOR"), Tab(text: "DISCOVER")],
                tabs: [Tab(text: "CRÉATEUR"), Tab(text: "COMMUNAUTÉ")],
              ),
            ),
          ],
        ),
      ),
      // body: TabBarView(
      //   controller: _tabController,
      //   physics: AppManager.isLoginAsGuest
      //       ? const NeverScrollableScrollPhysics() // disable swipe for guest
      //       : const BouncingScrollPhysics(),
      //   children: [CreatorTabScreen(key: creatorTabKey), DiscoverTabScreen()],
      // ),
      body: Listener(
        behavior:
            HitTestBehavior.translucent, // ✅ let children still receive events
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
            CreatorTabScreen(key: creatorTabKey),
            DiscoverTabScreen(),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal:22),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            _onTabTapped(index);
          },
          items: [
            /// Home
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/b3home.png',
                width: 32,
                height: 32,
                color: Colors.black,
              ),
              label: "",
            ),

            /// Search
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/b3search.png',
                width: 32,
                height: 32,
                color: Colors.grey,
              ),
              label: "",
            ),

            /// Camera
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/b3cam.png',
                width: 32,
                height: 32,
                color: Colors.grey,
              ),
              label: "",
            ),

            /// Favorites
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/b3heart.png',
                width: 32,
                height: 32,
                color: Colors.grey,
              ),
              label: "",
            ),

            /// Cart (Bag icon EXACT size & style)
            BottomNavigationBarItem(
              icon: Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Image.asset(
                        'assets/images/b3bag.png',
                        width: 32,
                        height: 32,
                        color: Colors.grey,
                      ),
                      if (cartProvider.cartItemCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: CircleAvatar(
                            radius: 8,
                            backgroundColor: Colors.black,
                            child: Text(
                              cartProvider.cartItemCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              label: "",
            ),
          ],
        ),
      ),

      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   type: BottomNavigationBarType.fixed,
      //   currentIndex: _currentIndex,
      //   selectedItemColor: Colors.black,
      //   unselectedItemColor: Colors.grey,
      //   showSelectedLabels: false,
      //   showUnselectedLabels: false,
      //   selectedFontSize: 0,
      //   unselectedFontSize: 0,
      //   iconSize: 34,
      //   onTap: (index) {
      //     setState(() {
      //       _currentIndex = index;
      //     });
      //     _onTabTapped(index); // use your existing function
      //   },
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: SizedBox(
      //           height: 24,
      //           child: Image.asset(
      //             "assets/images/home.png",
      //             color: Colors.black,
      //           )),
      //       label: "",
      //     ),
      //     BottomNavigationBarItem(
      //       icon: SizedBox(
      //           height: 30,
      //           child: Image.asset(
      //             "assets/images/search.png",
      //             color: Colors.grey,
      //           )),
      //       label: "",
      //     ),
      //     BottomNavigationBarItem(
      //       icon: SizedBox(
      //           height: 35,
      //           child: Image.asset(
      //             "assets/images/camera.png",
      //             color: Colors.grey,
      //           )),
      //       label: "",
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(
      //         Icons.favorite_outline,
      //         color: Colors.grey,
      //         size: 30,
      //       ),
      //       label: "",
      //     ),
      //     BottomNavigationBarItem(
      //       icon: SizedBox(
      //         height: 30,
      //         child: Stack(
      //           clipBehavior: Clip.none,
      //           children: [
      //             Image.asset(
      //               "assets/images/bag.png",
      //               color: Colors.grey,
      //             ),
      //             if (_cartItemCount >= 0)
      //               Positioned(
      //                 right: 0,
      //                 child: CircleAvatar(
      //                   radius: 8,
      //                   backgroundColor: Colors.black,
      //                   child: Text(
      //                     _cartItemCount.toString(),
      //                     style: TextStyle(
      //                       color: Colors.white,
      //                       fontSize: 12,
      //                       fontWeight: FontWeight.bold,
      //                     ),
      //                   ),
      //                 ),
      //               )
      //           ],
      //         ),
      //       ),
      //       label: "",
      //     ),
      //   ],
      // ),
    );
  }

  void _onTabTapped(int index) async {
    if (index == 4) {
      if (AppManager.isLoginAsGuest) {
        showAppSnackBar('Veuillez vous connecter pour acc\u00e9der au panier', isSuccess: false);
        return;
      }
      // Cart button index
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CartScreen()),
      ).then((value) {
        if (mounted) {
          context.read<CartProvider>().fetchCartItemCount();
        }
        if (value == 'checkout') {
          // Navigate to address screen with the cart ID
          _proceedToCheckout();
        }
      });
    } else if (index == 3) {
      // ⭐ WISHLIST
      if (AppManager.isLoginAsGuest) {
        showAppSnackBar('Veuillez vous connecter pour acc\u00e9der aux favoris', isSuccess: false);
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LikedImagesScreen()),
      );
    } else if (index == 2) {
      if (AppManager.isLoginAsGuest) {
        showAppSnackBar('Veuillez vous connecter pour publier une photo', isSuccess: false);
        return;
      }
      // Open camera directly with the camera mode
      _showImageSourceOptions(context);
    } else if (index == 1) {
      // Search button index
      // If currently on the discover tab (index 1), switch to creator tab (index 0) first
      if (AppManager.isLoginAsGuest) {
        showAppSnackBar('Veuillez vous connecter pour rechercher', isSuccess: false);
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
      );
    }
  }

  // New method to handle checkout process
  void _proceedToCheckout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez vous connecter pour proc\u00e9der au paiement')),
      );
      return;
    }

    final CartApi cartApi = CartApi(token: token);

    try {
      final cartModel = await cartApi.getCartDetails();
      if (cartModel.data?.id != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddressScreen(cartId: cartModel.data!.id!),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).cartEmpty)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching cart details')));
    }
  }

  // Method to open camera directly
  void _openCameraDirectly() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userType = prefs.getString('users_type');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).loginToTakeSelfie)),
        );
        return;
      }

      if (userType == '0') {
        bool canPost = true;
        try {
          canPost = await ApiClient().checkCanPostSelfie(token);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error checking selfie limit')),
          );
          return;
        }

        if (!canPost) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You have reached your daily selfie limit')),
          );
          return;
        }
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Camera permission is required')));
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

  void _showImageSourceOptions(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.2,
          minChildSize: 0.2,
          maxChildSize: 0.5,
          expand: false,
          builder: (_, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.all(16),
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text(AppLocalizations.of(context).prendreUnePhoto),
                  onTap: () async {
                    Navigator.pop(sheetContext);

                    final image = await ImagePicker()
                        .pickImage(source: ImageSource.camera);

                    if (image == null) return;

                    // Save original photo to device gallery
                    await _saveToDeviceGallery(File(image.path));

                    final File appFile = await moveImageToAppFolder(
                      image.path,
                      deleteOriginal: true, // ✅ camera only
                    );

                    if (!parentContext.mounted) return;

                    await _cropAndNavigate(appFile.path, parentContext);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(AppLocalizations.of(context).selectFromLibrary),
                  onTap: () async {
                    Navigator.pop(sheetContext);

                    final image = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);

                    if (image == null) return;

                    // Commented out save to gallery functionality
                    // final croppedImage = File(image.path);
                    // await saveImageToGallery(croppedImage);

                    final File appFile = await moveImageToAppFolder(
                      image.path,
                      deleteOriginal: false, // ✅ gallery safe
                    );

                    if (!parentContext.mounted) return;

                    await _cropAndNavigate(appFile.path, parentContext);
                  },
                ),
              ],
            );
          },
        );
      },
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
    print(
        'START CROPPING IMAGE: $imagePath name: ${path.basename(imagePath)} ');

    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      maxWidth: 800,
      maxHeight: 800,
      compressQuality: 50,
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recadrez votre photo',
          toolbarColor: Colors.white,
          statusBarColor: Colors.white,
          backgroundColor: Colors.black,
        ),
        IOSUiSettings(title: 'Crop Image'),
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

// Custom camera screen with gallery button in the top right
