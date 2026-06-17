import 'package:get/get.dart';
import 'package:happer_app/app/routes/app_routes.dart';
import 'package:happer_app/features/auth/bindings/auth_binding.dart';
import 'package:happer_app/features/selfies/bindings/selfie_binding.dart';
import 'package:happer_app/features/auth/screens/forgot_password_otp_screen.dart';
import 'package:happer_app/features/auth/screens/forgot_password_screen.dart';
import 'package:happer_app/features/auth/screens/login_screen.dart';
import 'package:happer_app/features/auth/screens/otp_verification_screen.dart';
import 'package:happer_app/features/auth/screens/register_screen.dart';
import 'package:happer_app/features/auth/screens/reset_password_screen.dart';
import 'package:happer_app/features/auth/screens/signup_screen.dart';
import 'package:happer_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:happer_app/features/dashboard/screens/cart_screen.dart';
import 'package:happer_app/features/dashboard/screens/notifications_screen.dart';
import 'package:happer_app/features/dashboard/screens/game_contest_screen.dart';
import 'package:happer_app/features/dashboard/screens/nogame_screen.dart';
import 'package:happer_app/features/creator/bindings/creator_binding.dart';
import 'package:happer_app/features/profile/bindings/address_binding.dart';
import 'package:happer_app/features/creator/screens/creator_tab_screen.dart';
import 'package:happer_app/features/discover/screens/discover_tab_screen.dart';
import 'package:happer_app/features/profile/screens/profile_screen.dart';
import 'package:happer_app/features/profile/screens/my_account_screen.dart';
import 'package:happer_app/features/profile/screens/my_address_screen.dart';
import 'package:happer_app/features/profile/screens/change_password_screen.dart';
import 'package:happer_app/features/profile/screens/my_purchases_screen.dart';
import 'package:happer_app/features/profile/screens/my_images_screen.dart';
import 'package:happer_app/features/profile/screens/liked_images_screen.dart';
import 'package:happer_app/features/profile/screens/profile_styles_screen.dart';
import 'package:happer_app/features/profile/screens/wishlist_screen.dart';
import 'package:happer_app/features/profile/screens/won_products_screen.dart';
import 'package:happer_app/features/profile/screens/code_credit_screen.dart';
import 'package:happer_app/features/profile/screens/return_refund_screen_new.dart';
import 'package:happer_app/features/profile/screens/notification_settings_screen.dart';

// Screens below require constructor args — will be migrated to Get.arguments
// when each module is refactored with new APIs:
// - AddressScreen (cartId)
// - NotificationDetailScreen (id, title, description, time)
// - GameProductDetailsScreen (product, timerEndDate)
// - BrandDetailsScreen (brandId, brandName, brandDescription, brandLogo)
// - ProductDetailsScreen (itemId, userId)
// - ProductListScreen (category)
// - SelfieDetailsScreen (selfieId)
// - DiscoverDetailScreen (selfieModel, isFromMyImages)
// - ResetPasswordScreen (email)
// - InvoiceViewerScreen (invoiceUrl)
// - ImageGridScreen (userId)

class AppPages {
  static const initial = AppRoutes.register;

  static final routes = [
    // Auth
    GetPage(name: AppRoutes.register, page: () => RegisterScreen(), binding: AuthBinding()),
    GetPage(name: AppRoutes.login, page: () => LoginScreen(), binding: AuthBinding()),
    GetPage(name: AppRoutes.signup, page: () => SignupScreen(), binding: AuthBinding()),
    GetPage(name: AppRoutes.signupOtp, page: () => OtpVerificationScreen(), binding: AuthBinding()),
    GetPage(name: AppRoutes.forgotPassword, page: () => ForgotPasswordScreen(), binding: AuthBinding()),
    GetPage(name: AppRoutes.forgotPasswordOtp, page: () => ForgotPasswordOtpScreen(), binding: AuthBinding()),
    GetPage(name: AppRoutes.resetPassword, page: () => ResetPasswordScreen(), binding: AuthBinding()),

    // Dashboard
    GetPage(name: AppRoutes.dashboard, page: () => const DashboardScreen(), binding: SelfieBinding()),
    GetPage(name: AppRoutes.cart, page: () => CartScreen()),
    GetPage(name: AppRoutes.notifications, page: () => NotificationsScreen()),
    GetPage(name: AppRoutes.gameContest, page: () => GameContestScreen()),
    GetPage(name: AppRoutes.noGame, page: () => DummyGameContestScreen()),

    // Creator
    GetPage(name: AppRoutes.creatorTab, page: () => CreatorTabScreen(), binding: CreatorBinding()),

    // Discover
    GetPage(name: AppRoutes.discoverTab, page: () => DiscoverTabScreen()),

    // Profile
    GetPage(name: AppRoutes.profile, page: () => ProfileScreen()),
    GetPage(name: AppRoutes.myAccount, page: () => MyAccountScreen()),
    GetPage(name: AppRoutes.myAddress, page: () => const MyAddressScreen(), binding: AddressBinding()),
    GetPage(name: AppRoutes.changePassword, page: () => const ChangePasswordScreen()),
    GetPage(name: AppRoutes.myPurchases, page: () => MyPurchasesScreen()),
    GetPage(name: AppRoutes.myImages, page: () => MyImagesScreen(), binding: SelfieBinding()),
    GetPage(name: AppRoutes.likedImages, page: () => LikedImagesScreen()),
    GetPage(name: AppRoutes.profileStyles, page: () => const StylesScreen()),
    GetPage(name: AppRoutes.wishlist, page: () => WishlistScreen()),
    GetPage(name: AppRoutes.wonProducts, page: () => WonProductsScreen()),
    GetPage(name: AppRoutes.codeCredit, page: () => CodeCreditScreen()),
    GetPage(name: AppRoutes.returnRefund, page: () => const ReturnRefundScreen()),
    GetPage(name: AppRoutes.notificationSettings, page: () => NotificationSettingsScreen()),
  ];
}
