abstract class AppRoutes {
  // Auth
  static const login = '/login';
  static const signup = '/signup';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const forgotPasswordOtp = '/forgot-password-otp';
  static const resetPassword = '/reset-password';
  static const signupOtp = '/signup-otp';

  // Dashboard
  static const dashboard = '/dashboard';
  static const cart = '/cart';
  static const address = '/address';
  static const notifications = '/notifications';
  static const notificationDetails = '/notification-details';
  static const shopTheStyle = '/shop-the-style';
  static const imageDisplay = '/image-display';
  static const gameContest = '/game-contest';
  static const gameProductDetails = '/game-product-details';
  static const noGame = '/no-game';

  // Creator
  static const creatorTab = '/creator-tab';
  static const brandDetails = '/brand-details';
  static const productDetails = '/product-details';
  static const selfieDetails = '/selfie-details';
  static const productList = '/product-list';

  // Discover
  static const discoverTab = '/discover-tab';
  static const discoverDetail = '/discover-detail';

  // Profile
  static const profile = '/profile';
  static const myAccount = '/my-account';
  static const myAddress = '/my-address';
  static const changePassword = '/change-password';
  static const myPurchases = '/my-purchases';
  static const myImages = '/my-images';
  static const likedImages = '/liked-images';
  static const profileStyles = '/profile-styles';
  static const wishlist = '/wishlist';
  static const wonProducts = '/won-products';
  static const codeCredit = '/code-credit';
  static const returnRefund = '/return-refund';
  static const notificationSettings = '/notification-settings';
  static const invoiceViewer = '/invoice-viewer';
  static const imageGrid = '/image-grid';
}
