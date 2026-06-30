class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String signup = '/user/auth/signup';
  static const String checkUsernameAvailability = '/user/auth/check-username-availability';
  static const String signupVerifyOtp = '/user/auth/signup/verify-otp';
  static const String signupResendOtp = '/user/auth/signup/resend-otp';
  static const String login = '/user/auth/login';
  static const String googleLogin = '/user/auth/google-login';
  static const String appleLogin = '/user/auth/apple-login';
  static const String guestLogin = '/user/auth/guest-login';
  static const String completeEsign = '/user/profile/complete-esign';
  static const String fetchProfile = '/user/auth/me';
  static const String updateProfile = '/user/auth/me';
  static const String editProfile = '/user/profile/edit-profile';
  static const String logout = '/user/auth/logout';
  static const String registerDevice = '/user/auth/register-device';
  static const String forgotPassword = '/user/auth/forgot-password';
  static const String forgotPasswordVerifyOtp = '/user/auth/forgot-password/verify-otp';
  static const String resetPassword = '/user/auth/reset-password';

  // Common
  static const String fileUpload = '/common/file-upload';

  // Profile image
  static const String updateProfileImage = '/user/profile/update-profile-image';

  // Address
  static const String getAllAddresses = '/user/address/get-all-addresses';
  static const String addAddress = '/user/address/add-address';
  static String getAddress(String id) => '/user/address/get-address/$id';
  static String editAddress(String id) => '/user/address/edit-address/$id';
  static String deleteAddress(String id) => '/user/address/delete-address/$id';

  // Profile
  static String userProfileStats(String userId) => '/user/profile/user-profile-stats/$userId';
  static String userSelfies(String userId) => '/user/profile/user-selfies/$userId';

  // Follow
  static const String follow = '/user/followers/follow';
  static const String unfollow = '/user/followers/unfollow';

  // Products
  static const String getProductsList = '/user/products/get-products-list';
  static String getProductDetail(String id) => '/user/products/get-product/$id';
  static const String getLinkedProducts = '/user/products/get-linked-products';
  static const String getLikedProducts = '/user/products/get-liked-products';
  // Like/unlike are keyed by the product VARIANT id (not the product id).
  static String likeProduct(String variantId) => '/user/products/$variantId/like';
  static String unlikeProduct(String variantId) => '/user/products/$variantId/unlike';

  // Cart
  static const String addToCart = '/user/carts/add-to-cart';
  static const String getMyCart = '/user/carts/get-my-cart';
  static String removeCartItem(String itemId) => '/user/carts/remove-cart-item/$itemId';
  static const String initiatePayment = '/user/carts/initiate-payment';
  static const String getPurchasedProducts = '/user/carts/get-purchased-products';

  // Selfies
  static const String getLikedSelfies = '/user/selfies/get-liked-selfies';
  static const String getCreatorSelfies = '/user/selfies/get-creator-selfies';
  static const String getSuggestions = '/user/selfies/get-suggestions';
  static const String getNormalUserSelfies = '/user/selfies/get-normal-user-selfies';
  static const String submitSelfie = '/user/selfies/submit-selfie';
  static const String getOwnSelfies = '/user/selfies/get-own-selfies';
  static const String getSelfies = '/user/selfies';
  static String getSelfieDetail(String id) => '/user/selfies/get-selfie/$id';
  static String deleteSelfie(String id) => '/user/selfies/$id';
  static String likeSelfie(String id) => '/user/selfies/$id/like';
  static String unlikeSelfie(String id) => '/user/selfies/$id/unlike';

  // Promo / Credit codes
  static const String getMyPromoCode = '/user/promo-codes/me';
  static const String verifyPromoCode = '/user/promo-codes/me';

  // Won products
  static const String getWonProducts = '/user/products/won';

  // Wishlist
  static const String getWishlist = '/user/wishlist/me';
  static const String addToWishlist = '/user/wishlist/add';
  static String removeFromWishlist(String productId) => '/user/wishlist/remove/$productId';

  // Change password
  static const String changePassword = '/user/auth/change-password';
}
