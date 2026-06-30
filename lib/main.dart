import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:happer_app/app/routes/app_pages.dart';
import 'package:happer_app/features/auth/bindings/auth_binding.dart';
import 'package:happer_app/core/controllers/locale_controller.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:happer_app/app_manager.dart';
import 'package:happer_app/shared/controllers/cart_controller.dart';
import 'package:happer_app/features/creator/screens/selfie_details_screen.dart';
import 'package:happer_app/features/splash/screens/splash_screen.dart';
import 'package:happer_app/firebase_options.dart';
import 'package:happer_app/features/profile/screens/image_grid_screen.dart';
// import 'package:happer_app/core/services/websocket_notification_service.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/core/network/profile_api.dart';
import 'package:http/http.dart' as http;
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/core/utils/storage_service.dart';
import 'package:app_links/app_links.dart'; 
 
// White status bar background with black icons/text, applied app-wide.
const SystemUiOverlayStyle kAppStatusBarStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.white,
  statusBarIconBrightness: Brightness.dark, // Android: dark (black) icons
  statusBarBrightness: Brightness.light, // iOS: dark (black) status bar text
);

// Make this function accessible from other files
Future<void> initializeStripe() async {
  await _initializeStripe();
}

StreamSubscription? _sub;

final _appLinks = AppLinks();

// Holds the cold-launch URI until the navigator is ready
Uri? _pendingInitialUri;

Future<void> _handleInitialUri() async {
  try {
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _pendingInitialUri = initialUri;
    }
  } on FormatException {
    debugPrint('Malformed initial URI received');
  }
}

void _handleIncomingLinks() {
  _sub = _appLinks.uriLinkStream.listen(
    (Uri uri) {
      _processUri(uri);
    },
    onError: (err) {
      debugPrint('Error in incoming link listener: $err');
    },
  );
}

void _processUri(Uri uri) async {
  debugPrint('Deep link received: $uri');

  final segments = uri.pathSegments;

  // ── Format: https://newapi.happer.fr/store/{username}
  //           https://newapi.happer.fr/store/{username}/{selfieId}
  // Also handles legacy creators.happer.fr links that were shared before the domain switch.
  const deepLinkHosts = {'newapi.happer.fr', 'creators.happer.fr'};
  if (deepLinkHosts.contains(uri.host) &&
      segments.isNotEmpty &&
      segments.first == 'store') {
    final username = segments.length >= 2 ? segments[1] : '';
    if (username.isEmpty) return;

    // Outfit: /store/{username}/{selfieId}
    if (segments.length >= 3) {
      // Support both new clean format (/store/user/ID) and legacy (/store/user/outfitid=ID)
      final segment = segments[2];
      final selfieId = segment.startsWith('outfitid=')
          ? segment.substring('outfitid='.length)
          : segment;
      if (selfieId.isNotEmpty) {
        debugPrint('Deep link → outfit selfieId=$selfieId username=$username');
        Future.delayed(const Duration(milliseconds: 300), () {
          MyApp.navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => SelfieDetailsScreen(selfieId: selfieId),
            ),
          );
        });
        return;
      }
    }

    // Profile: /store/{username} — fetch userId from username, then open profile
    debugPrint('Deep link → profile username=$username');
    _navigateToProfile(username);
    return;
  }

  debugPrint('Unhandled deep link: ${uri.path}');
}

Future<void> _navigateToProfile(String username) async {
  try {
    final token = StorageService.getToken();
    final headers = <String, String>{};
    if (token != null) headers['Authorization'] = 'Bearer $token';

    final response = await http.get(
      Uri.parse(
          'https://newapi.happer.fr/api/v1/user/profile/by-username/$username'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final userId = (body['data']?['_id'] ?? '').toString();
      if (userId.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 300), () {
          MyApp.navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => ImageGridScreen(userId: userId),
            ),
          );
        });
      }
    }
  } catch (e) {
    debugPrint('Failed to navigate to profile for username=$username: $e');
  }
}

void main() async {
  try {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // White status bar background with black icons/text on all screens.
    SystemChrome.setSystemUIOverlayStyle(kAppStatusBarStyle);

    // Initialize Firebase only if it hasn't been initialized already
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    print('[main] Init error: $e');
  }

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

  // Initialize storage service (must be before any ApiClient usage)
  await StorageService.init();

  // Check if user is already logged in
  final token = StorageService.getToken();
  final isGuestLogin = StorageService.isGuestLogin();
  AppManager.isLoginAsGuest = isGuestLogin;
  final isLoggedIn = token != null;
  final savedLocale = StorageService.getString('app_locale') ?? 'fr';

  // If user is already logged in, initialize Stripe properly with stored key
  if (isLoggedIn) {
    await _initializeStripe();
  }

  await _handleInitialUri();
  _handleIncomingLinks();

  Get.put(CartController(), permanent: true);
  AuthBinding().dependencies();

  FlutterNativeSplash.remove();
  runApp(
    MyApp(isLoggedIn: isLoggedIn, token: token, initialLocaleCode: savedLocale),
  );
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

  const MyApp({
    super.key,
    this.isLoggedIn = false,
    this.token,
    this.initialLocaleCode = 'fr',
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Get.put(LocaleController(initialCode: widget.initialLocaleCode));
    if (_pendingInitialUri != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _processUri(_pendingInitialUri!);
        _pendingInitialUri = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: kAppStatusBarStyle,
        ),
      ),
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      getPages: AppPages.routes,
      home: SplashScreen(isLoggedIn: widget.isLoggedIn),
    );
  }
}
