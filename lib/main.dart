import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/app/routes/app_pages.dart';
import 'package:happer_app/core/controllers/locale_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:happer_app/app_manager.dart';
import 'package:happer_app/features/product/providers/user_provider.dart';
import 'package:happer_app/shared/providers/cart_provider.dart';
import 'package:happer_app/features/creator/screens/selfie_details_screen.dart';
import 'package:happer_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:happer_app/firebase_options.dart';
import 'package:happer_app/features/profile/screens/image_grid_screen.dart';
import 'package:happer_app/features/profile/screens/profile_screen.dart';
import 'package:happer_app/features/auth/screens/register_screen.dart';
// import 'package:happer_app/core/services/websocket_notification_service.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/core/network/profile_api.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:uni_links/uni_links.dart';

// Make this function accessible from other files
Future<void> initializeStripe() async {
  await _initializeStripe();
}

StreamSubscription? _sub;

/// Handle the first URI if the app was launched from a deep link
Future<void> _handleInitialUri() async {
  try {
    final initialUri = await getInitialUri();
    if (initialUri != null) {
      _processUri(initialUri);
    }
  } on FormatException {
    debugPrint('Malformed initial URI received');
  }
}

/// Handle subsequent deep links while the app is in background/foreground
void _handleIncomingLinks() {
  _sub = uriLinkStream.listen((Uri? uri) {
    if (uri != null) {
      _processUri(uri);
    }
  }, onError: (err) {
    debugPrint('Error in incoming link listener: $err');
  });
}

void _processUri(Uri uri) async {
  debugPrint('Received deep link: $uri');

  // SharedPreferences for login check
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  // Deep link format: /store/profile/ENCODED_USER_ID → ImageGridScreen
  // Deep link format: /store/ENCODED_SELFIE_ID → SelfieDetailsScreen
  final segments = uri.pathSegments;

  if (segments.isNotEmpty && segments.first == 'store') {
    // Profile: /store/profile/ENCODED_USER_ID
    if (segments.length >= 3 && segments[1] == 'profile') {
      final encodedId = segments[2];
      try {
        final userId = utf8.decode(base64Url.decode(base64Url.normalize(encodedId)));
        debugPrint('Deep link for profile userId=$userId');

        if (userId.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 300), () {
            MyApp.navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (_) => ImageGridScreen(userId: userId),
              ),
            );
          });
          return;
        }
      } catch (e) {
        debugPrint('Failed to decode profile deep link: $e');
      }
    }

    // Selfie: /store/ENCODED_SELFIE_ID
    if (segments.length >= 2 && segments[1] != 'profile') {
      final encodedId = segments[1];
      try {
        final selfieId = utf8.decode(base64Url.decode(base64Url.normalize(encodedId)));
        debugPrint('Deep link for selfieId=$selfieId');

        if (selfieId.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 300), () {
            MyApp.navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (_) => SelfieDetailsScreen(selfieId: selfieId),
              ),
            );
          });
          return;
        }
      } catch (e) {
        debugPrint('Failed to decode selfie deep link: $e');
      }
    }
  }

  if (uri.path.contains('/api/selfies/profile/username')) {
    final username = uri.queryParameters['username'];
    debugPrint('Deep link for username=$username');

    if (token != null) {
      final response = await http.get(
        Uri.parse(uri.toString()),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('User profile data: $data');

        MyApp.navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => ProfileScreen()),
        );
      } else {
        debugPrint('Failed to fetch profile: ${response.statusCode}');
      }
    } else {
      debugPrint('User not logged in, redirecting to login page');
      MyApp.navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
      );
    }

    return;
  }

  // 🧩 Unhandled
  debugPrint('Unhandled deep link path: ${uri.path}');
}

void main() async {
  try {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);


    // Initialize Firebase only if it hasn't been initialized already
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {}

    // Notification service initialization moved to dashboard screen
  } catch (e) {}

  // WebSocket notification service disabled — host is not available
  // await WebSocketNotificationService().initialize();

  // Initialize Stripe with retry mechanism
  try {
    Stripe.publishableKey =
        'pk_live_51RJuR0046lfAB8p8NvHnmRemc8OSqnmTxbkfc9uhhIVeRe6EibAIASIOR0c9H2gxqdGScuAhqK21kKZ0JDmpvtiz00moL7MXTY';
    // Apply settings and configure for Apple Pay
    await Stripe.instance.applySettings();
    // IMPORTANT: Must match the merchant identifier in Runner.entitlements
    Stripe.merchantIdentifier = 'merchant.fr.happer';
    debugPrint('Stripe initialized successfully with publishable key');
  } catch (e) {
    debugPrint('Error initializing Stripe: $e');
    // Wait a moment and try again
    await Future.delayed(Duration(seconds: 1));
    try {
      Stripe.publishableKey =
          'pk_live_51RJuR0046lfAB8p8NvHnmRemc8OSqnmTxbkfc9uhhIVeRe6EibAIASIOR0c9H2gxqdGScuAhqK21kKZ0JDmpvtiz00moL7MXTY';
      await Stripe.instance.applySettings();
      debugPrint('Stripe initialized successfully on second attempt');
    } catch (e) {
      debugPrint('Failed to initialize Stripe after retry: $e');
    }
  }

  // Check if user is already logged in
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final isGuestLogin = prefs.getBool('is_guest_login') ?? false;
  AppManager.isLoginAsGuest = isGuestLogin;
  final isLoggedIn = token != null;
  final savedLocale = prefs.getString('app_locale') ?? 'fr';

  // If user is already logged in, initialize Stripe properly with stored key
  if (isLoggedIn) {
    await _initializeStripe();
  }

  await _handleInitialUri();
  _handleIncomingLinks();

  FlutterNativeSplash.remove();
  runApp(MyApp(isLoggedIn: isLoggedIn, token: token, initialLocaleCode: savedLocale));
}

// Function to initialize Stripe with the correct publishable key
Future<void> _initializeStripe() async {
  try {
    // Try to get a stored key first
    final storedKey = await ProfileApi.getStoredPublishableKey();

    if (storedKey != null && storedKey.isNotEmpty) {
      // Use the stored key if available
      Stripe.publishableKey = storedKey;
      await Stripe.instance.applySettings();
    } else {
      // If no stored key, fetch a new one
      final profileApi = ProfileApi();
      final stripeConfig = await profileApi.getStripeConfig();

      // If we couldn't get a key, use a default as fallback
      if (stripeConfig == null || stripeConfig['publishableKey'] == null) {
        Stripe.publishableKey =
            'pk_live_51RJuR0046lfAB8p8NvHnmRemc8OSqnmTxbkfc9uhhIVeRe6EibAIASIOR0c9H2gxqdGScuAhqK21kKZ0JDmpvtiz00moL7MXTY';
        await Stripe.instance.applySettings();
      }
    }
  } catch (e) {
    // Use default key as fallback
    Stripe.publishableKey =
        'pk_live_51RJuR0046lfAB8p8NvHnmRemc8OSqnmTxbkfc9uhhIVeRe6EibAIASIOR0c9H2gxqdGScuAhqK21kKZ0JDmpvtiz00moL7MXTY';
    await Stripe.instance.applySettings();
  }
}

// class MyApp extends StatelessWidget {
//   static final GlobalKey<NavigatorState> navigatorKey =
//       GlobalKey<NavigatorState>();
//   final bool isLoggedIn;
//   final String? token;

//   const MyApp({super.key, this.isLoggedIn = false, this.token});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'Happer',
//         // Localization configuration
//         localizationsDelegates: AppLocalizations.localizationsDelegates,
//         supportedLocales: AppLocalizations.supportedLocales,
//         // Let Flutter automatically detect device language
//         // Falls back to French if device language isn't supported
//         localeResolutionCallback: (locale, supportedLocales) {
//           // Check if the device's locale is supported
//           for (var supportedLocale in supportedLocales) {
//             if (supportedLocale.languageCode == locale?.languageCode) {
//               return supportedLocale;
//             }
//           }
//           // Default fallback to French as requested
//           return const Locale('fr', '');
//         },
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           scaffoldBackgroundColor: Colors.white,
//         ),
//         scaffoldMessengerKey: rootScaffoldMessengerKey,
//         home: isLoggedIn ? const DashboardScreen() : RegisterScreen(),
//       ),
//     );
//   }

//   static void navigateToCreatorTabWithSearch() {
//     navigatorKey.currentState?.push(
//       MaterialPageRoute(builder: (context) => const DashboardScreen()),
//     );
//   }
// }

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  final bool isLoggedIn;
  final String? token;
  final String initialLocaleCode;

  const MyApp({super.key, this.isLoggedIn = false, this.token, this.initialLocaleCode = 'fr'});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _linkSub;
  String? _latestLink;

  @override
  void initState() {
    super.initState();
    Get.put(LocaleController(initialCode: widget.initialLocaleCode));
    _initDeepLinkHandling();
  }

  Future<void> _initDeepLinkHandling() async {
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        _handleIncomingUri(initialUri);
      }
    } catch (e) {
      print('Initial URI error: $e');
    }

    _linkSub = uriLinkStream.listen((Uri? uri) {
      if (uri != null) _handleIncomingUri(uri);
    }, onError: (err) {
      print('URI Stream error: $err');
    });
  }

  void _handleIncomingUri(Uri uri) {
    print("🔗 Received deep link: ${uri.toString()}");
    setState(() => _latestLink = uri.toString());

    // Example: happerapp://open/profile/123
    if (uri.host == 'open' && uri.pathSegments.isNotEmpty) {
      final page = uri.pathSegments.first;
      final id = uri.pathSegments.length > 1 ? uri.pathSegments[1] : '';

      if (page == 'profile') {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => DashboardScreen()), // or your profile screen
        );
      }
    }
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: GetMaterialApp(
        navigatorKey: MyApp.navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Happer',
        locale: Locale(widget.initialLocaleCode),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode) {
              return supportedLocale;
            }
          }
          return const Locale('fr', '');
        },
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Lato',
        ),
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        getPages: AppPages.routes,
        home: widget.isLoggedIn ? const DashboardScreen() : RegisterScreen(),
      ),
    );
  }
}
