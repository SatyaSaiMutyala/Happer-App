import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Happer'**
  String get appTitle;

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Happer'**
  String get app_name;

  /// No description provided for @shareSlogan.
  ///
  /// In en, this message translates to:
  /// **'Share your style and win fashion items'**
  String get shareSlogan;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'No data found.'**
  String get noDataFound;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String hoursAgo(int hours);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// No description provided for @weekAgo.
  ///
  /// In en, this message translates to:
  /// **'{weeks} week ago'**
  String weekAgo(int weeks);

  /// No description provided for @weeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks ago'**
  String weeksAgo(int weeks);

  /// No description provided for @monthAgo.
  ///
  /// In en, this message translates to:
  /// **'{months} month ago'**
  String monthAgo(int months);

  /// No description provided for @monthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{months} months ago'**
  String monthsAgo(int months);

  /// No description provided for @yearAgo.
  ///
  /// In en, this message translates to:
  /// **'{years} year ago'**
  String yearAgo(int years);

  /// No description provided for @yearsAgo.
  ///
  /// In en, this message translates to:
  /// **'{years} years ago'**
  String yearsAgo(int years);

  /// No description provided for @shopTheStyle.
  ///
  /// In en, this message translates to:
  /// **'SHOP THE STYLE'**
  String get shopTheStyle;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again later.'**
  String get errorOccurred;

  /// No description provided for @failedToUpdateLike.
  ///
  /// In en, this message translates to:
  /// **'Failed to update like status'**
  String get failedToUpdateLike;

  /// No description provided for @noCreatorFound.
  ///
  /// In en, this message translates to:
  /// **'No creator found for \"{query}\"'**
  String noCreatorFound(String query);

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search results for: \"{query}\"'**
  String searchResults(String query);

  /// No description provided for @connexion.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get connexion;

  /// No description provided for @inscription.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get inscription;

  /// No description provided for @continuerAvecFacebook.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get continuerAvecFacebook;

  /// No description provided for @seConnecter.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get seConnecter;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @nomUtilisateur.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get nomUtilisateur;

  /// No description provided for @emailAdress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAdress;

  /// No description provided for @motDePasse.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get motDePasse;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgetPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password ?'**
  String get forgetPassword;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @sInscrire.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get sInscrire;

  /// No description provided for @adresseMail.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get adresseMail;

  /// No description provided for @nomUtilisateurSignUp.
  ///
  /// In en, this message translates to:
  /// **'UserName'**
  String get nomUtilisateurSignUp;

  /// No description provided for @usernmae.
  ///
  /// In en, this message translates to:
  /// **'User name'**
  String get usernmae;

  /// No description provided for @sexe.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get sexe;

  /// No description provided for @homme.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get homme;

  /// No description provided for @femme.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get femme;

  /// No description provided for @confirmerMotDePasse.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmerMotDePasse;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @codeParainage.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get codeParainage;

  /// No description provided for @compris.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get compris;

  /// No description provided for @sauter.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get sauter;

  /// No description provided for @relaunch.
  ///
  /// In en, this message translates to:
  /// **'RELAUNCH'**
  String get relaunch;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'READ MORE'**
  String get readMore;

  /// No description provided for @followTutorial.
  ///
  /// In en, this message translates to:
  /// **'Follow the tutorial?'**
  String get followTutorial;

  /// No description provided for @inspirationDuJour.
  ///
  /// In en, this message translates to:
  /// **'Daily inspiration'**
  String get inspirationDuJour;

  /// No description provided for @inspiration.
  ///
  /// In en, this message translates to:
  /// **'Inspiration of the day'**
  String get inspiration;

  /// No description provided for @historique.
  ///
  /// In en, this message translates to:
  /// **'Historic'**
  String get historique;

  /// No description provided for @cerclesPrives.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get cerclesPrives;

  /// No description provided for @monDressing.
  ///
  /// In en, this message translates to:
  /// **'My dressing'**
  String get monDressing;

  /// No description provided for @monCompte.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get monCompte;

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get myAccount;

  /// No description provided for @product_title.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get product_title;

  /// No description provided for @productsComing.
  ///
  /// In en, this message translates to:
  /// **'Products are coming. Please wait.'**
  String get productsComing;

  /// No description provided for @myFashionItem.
  ///
  /// In en, this message translates to:
  /// **'My fashion items'**
  String get myFashionItem;

  /// No description provided for @wonItems.
  ///
  /// In en, this message translates to:
  /// **'Won items'**
  String get wonItems;

  /// No description provided for @wishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlist;

  /// No description provided for @detailsProduit.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get detailsProduit;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @prix.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get prix;

  /// No description provided for @prixReel.
  ///
  /// In en, this message translates to:
  /// **'Real price'**
  String get prixReel;

  /// No description provided for @realPrice.
  ///
  /// In en, this message translates to:
  /// **'Real price'**
  String get realPrice;

  /// No description provided for @discountPrice.
  ///
  /// In en, this message translates to:
  /// **'Discount price'**
  String get discountPrice;

  /// No description provided for @iWantIt.
  ///
  /// In en, this message translates to:
  /// **'I WANT IT'**
  String get iWantIt;

  /// No description provided for @productInformation.
  ///
  /// In en, this message translates to:
  /// **'Product Information'**
  String get productInformation;

  /// No description provided for @latestBidder.
  ///
  /// In en, this message translates to:
  /// **'Latest Bidder'**
  String get latestBidder;

  /// No description provided for @dernieresHappeuses.
  ///
  /// In en, this message translates to:
  /// **'Last Happeuses'**
  String get dernieresHappeuses;

  /// No description provided for @first.
  ///
  /// In en, this message translates to:
  /// **'1st'**
  String get first;

  /// No description provided for @second.
  ///
  /// In en, this message translates to:
  /// **'2nd'**
  String get second;

  /// No description provided for @third.
  ///
  /// In en, this message translates to:
  /// **'3rd'**
  String get third;

  /// No description provided for @fourth.
  ///
  /// In en, this message translates to:
  /// **'4th'**
  String get fourth;

  /// No description provided for @fifth.
  ///
  /// In en, this message translates to:
  /// **'5th'**
  String get fifth;

  /// No description provided for @credit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get credit;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// No description provided for @coins.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get coins;

  /// No description provided for @youHave.
  ///
  /// In en, this message translates to:
  /// **'You have'**
  String get youHave;

  /// No description provided for @coin.
  ///
  /// In en, this message translates to:
  /// **'coin'**
  String get coin;

  /// No description provided for @freeCoins.
  ///
  /// In en, this message translates to:
  /// **'Free Coins'**
  String get freeCoins;

  /// No description provided for @oneCredit.
  ///
  /// In en, this message translates to:
  /// **'+1 coin'**
  String get oneCredit;

  /// No description provided for @thirtyCoin.
  ///
  /// In en, this message translates to:
  /// **'+50 coins'**
  String get thirtyCoin;

  /// No description provided for @twoHundredCredit.
  ///
  /// In en, this message translates to:
  /// **'+200 coins'**
  String get twoHundredCredit;

  /// No description provided for @perAd.
  ///
  /// In en, this message translates to:
  /// **'/ad'**
  String get perAd;

  /// No description provided for @perDay.
  ///
  /// In en, this message translates to:
  /// **'/day'**
  String get perDay;

  /// No description provided for @perGuest.
  ///
  /// In en, this message translates to:
  /// **'per guest'**
  String get perGuest;

  /// No description provided for @perWeek.
  ///
  /// In en, this message translates to:
  /// **'/week'**
  String get perWeek;

  /// No description provided for @getCreditPerDay.
  ///
  /// In en, this message translates to:
  /// **'Your coins every day by removing ads'**
  String get getCreditPerDay;

  /// No description provided for @gagnerUnCredit.
  ///
  /// In en, this message translates to:
  /// **'Watch a video and win a credit.'**
  String get gagnerUnCredit;

  /// No description provided for @ad.
  ///
  /// In en, this message translates to:
  /// **'Ads'**
  String get ad;

  /// No description provided for @withoutAds.
  ///
  /// In en, this message translates to:
  /// **'without ads'**
  String get withoutAds;

  /// No description provided for @maxPubPerDay.
  ///
  /// In en, this message translates to:
  /// **'200 ads maximum /day'**
  String get maxPubPerDay;

  /// No description provided for @supprimerPub.
  ///
  /// In en, this message translates to:
  /// **'Would like to remove the advertising for 9.99€'**
  String get supprimerPub;

  /// No description provided for @getHapperPremium.
  ///
  /// In en, this message translates to:
  /// **'GET HAPPER PREMIUM'**
  String get getHapperPremium;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @becomePremium.
  ///
  /// In en, this message translates to:
  /// **'Become Premium'**
  String get becomePremium;

  /// No description provided for @becomePremiumButton.
  ///
  /// In en, this message translates to:
  /// **'BECOME PREMIUM'**
  String get becomePremiumButton;

  /// No description provided for @plus.
  ///
  /// In en, this message translates to:
  /// **'PLUS'**
  String get plus;

  /// No description provided for @gold.
  ///
  /// In en, this message translates to:
  /// **'GOLD'**
  String get gold;

  /// No description provided for @diamond.
  ///
  /// In en, this message translates to:
  /// **'DIAMOND'**
  String get diamond;

  /// No description provided for @get.
  ///
  /// In en, this message translates to:
  /// **'Get'**
  String get get;

  /// No description provided for @coinsEveryDay.
  ///
  /// In en, this message translates to:
  /// **'Coins Every Day'**
  String get coinsEveryDay;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @ofAds.
  ///
  /// In en, this message translates to:
  /// **'of Ads'**
  String get ofAds;

  /// No description provided for @dealerAtDisposal.
  ///
  /// In en, this message translates to:
  /// **'Dealer at your disposal'**
  String get dealerAtDisposal;

  /// No description provided for @notificationEndOfReserve.
  ///
  /// In en, this message translates to:
  /// **'Notification end of reserve'**
  String get notificationEndOfReserve;

  /// No description provided for @threeFreeDays.
  ///
  /// In en, this message translates to:
  /// **'3 Free Days.\\nThen'**
  String get threeFreeDays;

  /// No description provided for @freeTrail.
  ///
  /// In en, this message translates to:
  /// **'Free\\nTrial'**
  String get freeTrail;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get year;

  /// No description provided for @saveEco.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveEco;

  /// No description provided for @onThePrice.
  ///
  /// In en, this message translates to:
  /// **'on the price'**
  String get onThePrice;

  /// No description provided for @startWithoutPay.
  ///
  /// In en, this message translates to:
  /// **'Start without paying'**
  String get startWithoutPay;

  /// No description provided for @forPremiumMembers.
  ///
  /// In en, this message translates to:
  /// **'For Premium members only'**
  String get forPremiumMembers;

  /// No description provided for @suscribeToAccessDealer.
  ///
  /// In en, this message translates to:
  /// **'Please purchase a subscription to use your Croupier'**
  String get suscribeToAccessDealer;

  /// No description provided for @oneCreditLeft.
  ///
  /// In en, this message translates to:
  /// **'You have 1 credit left'**
  String get oneCreditLeft;

  /// No description provided for @getHapperPlus.
  ///
  /// In en, this message translates to:
  /// **'Enjoy HAPPER PLUS your credit without ads !'**
  String get getHapperPlus;

  /// No description provided for @seeOffers.
  ///
  /// In en, this message translates to:
  /// **'See offers'**
  String get seeOffers;

  /// No description provided for @threeCreditLeft.
  ///
  /// In en, this message translates to:
  /// **'You have 3 credits left'**
  String get threeCreditLeft;

  /// No description provided for @showAds.
  ///
  /// In en, this message translates to:
  /// **'Show ads for more credits'**
  String get showAds;

  /// No description provided for @goToAds.
  ///
  /// In en, this message translates to:
  /// **'See'**
  String get goToAds;

  /// No description provided for @takeAPicture.
  ///
  /// In en, this message translates to:
  /// **'Take a picture'**
  String get takeAPicture;

  /// No description provided for @selectFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Select from Library'**
  String get selectFromLibrary;

  /// No description provided for @prendreUnePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get prendreUnePhoto;

  /// No description provided for @chargerUnePhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload a photo'**
  String get chargerUnePhoto;

  /// No description provided for @cameraNonTrouve.
  ///
  /// In en, this message translates to:
  /// **'Camera not found'**
  String get cameraNonTrouve;

  /// No description provided for @impossibleRecupererCamera.
  ///
  /// In en, this message translates to:
  /// **'Unable to retrieve the camera.'**
  String get impossibleRecupererCamera;

  /// No description provided for @shareThisPicture.
  ///
  /// In en, this message translates to:
  /// **'Share this picture'**
  String get shareThisPicture;

  /// No description provided for @cropPicture.
  ///
  /// In en, this message translates to:
  /// **'Crop picture'**
  String get cropPicture;

  /// No description provided for @categorizeThisPicture.
  ///
  /// In en, this message translates to:
  /// **'Categorize this picture'**
  String get categorizeThisPicture;

  /// No description provided for @toolTipResizeImage.
  ///
  /// In en, this message translates to:
  /// **'To remain anonymous, please do not frame your face'**
  String get toolTipResizeImage;

  /// No description provided for @toolTipCategorizeImage.
  ///
  /// In en, this message translates to:
  /// **'Select your style category'**
  String get toolTipCategorizeImage;

  /// No description provided for @cameraFragmentTitle.
  ///
  /// In en, this message translates to:
  /// **'SHARE YOUR STYLE'**
  String get cameraFragmentTitle;

  /// No description provided for @selfieUpload.
  ///
  /// In en, this message translates to:
  /// **'Selfie Upload'**
  String get selfieUpload;

  /// No description provided for @contribuer.
  ///
  /// In en, this message translates to:
  /// **'Contribute'**
  String get contribuer;

  /// No description provided for @partager.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get partager;

  /// No description provided for @vosPlusBeauxStyles.
  ///
  /// In en, this message translates to:
  /// **'your best Styles'**
  String get vosPlusBeauxStyles;

  /// No description provided for @partageDuSelfie.
  ///
  /// In en, this message translates to:
  /// **'Sharing the selfie'**
  String get partageDuSelfie;

  /// No description provided for @votreSelfieAttente.
  ///
  /// In en, this message translates to:
  /// **'Your selfie is now waiting for a rating'**
  String get votreSelfieAttente;

  /// No description provided for @selfieNotValidated.
  ///
  /// In en, this message translates to:
  /// **'Your selfie was not validated'**
  String get selfieNotValidated;

  /// No description provided for @pictureShared.
  ///
  /// In en, this message translates to:
  /// **'Picture Shared'**
  String get pictureShared;

  /// No description provided for @shareStyleText.
  ///
  /// In en, this message translates to:
  /// **'I\'ve found this clothing style you\'ll love on the Happer fashion app. Join me now!'**
  String get shareStyleText;

  /// No description provided for @shareStyleWithFriends.
  ///
  /// In en, this message translates to:
  /// **'Share this style with people you know'**
  String get shareStyleWithFriends;

  /// No description provided for @myStyles.
  ///
  /// In en, this message translates to:
  /// **'My Pictures'**
  String get myStyles;

  /// No description provided for @sharedStyles.
  ///
  /// In en, this message translates to:
  /// **'Shared Styles'**
  String get sharedStyles;

  /// No description provided for @favoriteStyle.
  ///
  /// In en, this message translates to:
  /// **'Favorite Styles'**
  String get favoriteStyle;

  /// No description provided for @like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// No description provided for @textToolTipCAMERA.
  ///
  /// In en, this message translates to:
  /// **'Share your style for more credits'**
  String get textToolTipCAMERA;

  /// No description provided for @prenom.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get prenom;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'FIrst Name'**
  String get firstName;

  /// No description provided for @nom.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nom;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @adresse.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get adresse;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @codePostal.
  ///
  /// In en, this message translates to:
  /// **'Zip code'**
  String get codePostal;

  /// No description provided for @postalCode.
  ///
  /// In en, this message translates to:
  /// **'Post Code'**
  String get postalCode;

  /// No description provided for @ville.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get ville;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @adresseEmail.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get adresseEmail;

  /// No description provided for @dateDeNaissance.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateDeNaissance;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date Of Birth'**
  String get dateOfBirth;

  /// No description provided for @modifier.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get modifier;

  /// No description provided for @deconnexion.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get deconnexion;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @deleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteMyAccount;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @invitFriend.
  ///
  /// In en, this message translates to:
  /// **'INVITE YOUR FRIENDS'**
  String get invitFriend;

  /// No description provided for @sponsorship.
  ///
  /// In en, this message translates to:
  /// **'Invite friends'**
  String get sponsorship;

  /// No description provided for @sponsorShipText.
  ///
  /// In en, this message translates to:
  /// **'Sponsorship'**
  String get sponsorShipText;

  /// No description provided for @sponsorshipTitle.
  ///
  /// In en, this message translates to:
  /// **'1 SPONSORSHIP = 20 CREDITS'**
  String get sponsorshipTitle;

  /// No description provided for @earnCreditSponsorShip.
  ///
  /// In en, this message translates to:
  /// **'Earn 30 credits for each friend you refer'**
  String get earnCreditSponsorShip;

  /// No description provided for @yourCode.
  ///
  /// In en, this message translates to:
  /// **'Your code'**
  String get yourCode;

  /// No description provided for @textShare.
  ///
  /// In en, this message translates to:
  /// **'Share your code with a friend. When she uses it during her registration, you will both get 30 credits'**
  String get textShare;

  /// No description provided for @messageSponshipAddFriend.
  ///
  /// In en, this message translates to:
  /// **'Join me on the Happer fashion app that offers free items every day! Referral code: '**
  String get messageSponshipAddFriend;

  /// No description provided for @invite3Friends.
  ///
  /// In en, this message translates to:
  /// **'Invite 3 friends to unlock more credits'**
  String get invite3Friends;

  /// No description provided for @invitFriends.
  ///
  /// In en, this message translates to:
  /// **'Invit friends'**
  String get invitFriends;

  /// No description provided for @invitMyFriends.
  ///
  /// In en, this message translates to:
  /// **'INVIT MY FRIENDS'**
  String get invitMyFriends;

  /// No description provided for @getCredits.
  ///
  /// In en, this message translates to:
  /// **'GET YOUR CREDITS'**
  String get getCredits;

  /// No description provided for @friendsToInvite.
  ///
  /// In en, this message translates to:
  /// **'friends to invite to unlock more credits'**
  String get friendsToInvite;

  /// No description provided for @friendToInvite.
  ///
  /// In en, this message translates to:
  /// **'friend to invite to unlock more credits'**
  String get friendToInvite;

  /// No description provided for @onlyOneFriendToSponsor.
  ///
  /// In en, this message translates to:
  /// **'Only 1 more friend to sponsor for more credits'**
  String get onlyOneFriendToSponsor;

  /// No description provided for @onlyTwoFriendsToSponsor.
  ///
  /// In en, this message translates to:
  /// **'Only 2 more friends to sponsor for more credits'**
  String get onlyTwoFriendsToSponsor;

  /// No description provided for @moreCreditMoreChanceToWin.
  ///
  /// In en, this message translates to:
  /// **'More credits = More chance to win'**
  String get moreCreditMoreChanceToWin;

  /// No description provided for @dealerIsWaiting.
  ///
  /// In en, this message translates to:
  /// **'Your Dealer is waiting for you !'**
  String get dealerIsWaiting;

  /// No description provided for @dontMissYourChance.
  ///
  /// In en, this message translates to:
  /// **'Don\'t miss your chance to win.'**
  String get dontMissYourChance;

  /// No description provided for @dealerAtYourPlace.
  ///
  /// In en, this message translates to:
  /// **'Dealer for Happ at your place !'**
  String get dealerAtYourPlace;

  /// No description provided for @infosTitleTooltipCroupier.
  ///
  /// In en, this message translates to:
  /// **'This feature allows you to Happer automatically.'**
  String get infosTitleTooltipCroupier;

  /// No description provided for @infosContentTooltipCroupier.
  ///
  /// In en, this message translates to:
  /// **'Available to PREMIUM members'**
  String get infosContentTooltipCroupier;

  /// No description provided for @dealerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Currently Unavailable'**
  String get dealerUnavailable;

  /// No description provided for @dealerCurrentlyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Dealer Unavailable'**
  String get dealerCurrentlyUnavailable;

  /// No description provided for @dealerAvailableSoon.
  ///
  /// In en, this message translates to:
  /// **'Your dealer will be available soon'**
  String get dealerAvailableSoon;

  /// No description provided for @credtiDealerIsHighThanYourCredit.
  ///
  /// In en, this message translates to:
  /// **'The number of credits for the dealer is higher than your credits!'**
  String get credtiDealerIsHighThanYourCredit;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @validate.
  ///
  /// In en, this message translates to:
  /// **'Validate'**
  String get validate;

  /// No description provided for @terminer.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get terminer;

  /// No description provided for @followUp.
  ///
  /// In en, this message translates to:
  /// **'Follow up'**
  String get followUp;

  /// No description provided for @moreOption.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOption;

  /// No description provided for @moreInformations.
  ///
  /// In en, this message translates to:
  /// **'MORE INFORMATION'**
  String get moreInformations;

  /// No description provided for @goToHapper.
  ///
  /// In en, this message translates to:
  /// **'Go to Happer'**
  String get goToHapper;

  /// No description provided for @d.
  ///
  /// In en, this message translates to:
  /// **'D'**
  String get d;

  /// No description provided for @titleInfoStartDate.
  ///
  /// In en, this message translates to:
  /// **'Reserve period not reached'**
  String get titleInfoStartDate;

  /// No description provided for @contentInfoStartDate.
  ///
  /// In en, this message translates to:
  /// **'Minimum date and time before you can win the item'**
  String get contentInfoStartDate;

  /// No description provided for @dateHeureMiseEnJeuArticle.
  ///
  /// In en, this message translates to:
  /// **'Date and time the item was put into play'**
  String get dateHeureMiseEnJeuArticle;

  /// No description provided for @expireOn.
  ///
  /// In en, this message translates to:
  /// **'Expires on'**
  String get expireOn;

  /// No description provided for @informationResetCreditAllDays.
  ///
  /// In en, this message translates to:
  /// **'Remember to use your credits before 00:00\\nEvery day, they are reset to 0.'**
  String get informationResetCreditAllDays;

  /// No description provided for @obtenezAuMoins.
  ///
  /// In en, this message translates to:
  /// **'Get at least'**
  String get obtenezAuMoins;

  /// No description provided for @oneEtoile.
  ///
  /// In en, this message translates to:
  /// **'1 star'**
  String get oneEtoile;

  /// No description provided for @twoEtoiles.
  ///
  /// In en, this message translates to:
  /// **'2 stars'**
  String get twoEtoiles;

  /// No description provided for @threeEtoiles.
  ///
  /// In en, this message translates to:
  /// **'3 stars'**
  String get threeEtoiles;

  /// No description provided for @fourEtoiles.
  ///
  /// In en, this message translates to:
  /// **'4 stars'**
  String get fourEtoiles;

  /// No description provided for @fiveEtoiles.
  ///
  /// In en, this message translates to:
  /// **'5 stars'**
  String get fiveEtoiles;

  /// No description provided for @pourDevenir.
  ///
  /// In en, this message translates to:
  /// **'To become a'**
  String get pourDevenir;

  /// No description provided for @membreDuCercleSilver.
  ///
  /// In en, this message translates to:
  /// **'Member Of The Silver Circle'**
  String get membreDuCercleSilver;

  /// No description provided for @membreDuCercleGold.
  ///
  /// In en, this message translates to:
  /// **'Member Of The Gold Circle'**
  String get membreDuCercleGold;

  /// No description provided for @membreDuCerclePlatines.
  ///
  /// In en, this message translates to:
  /// **'Member Of The Platines Circle'**
  String get membreDuCerclePlatines;

  /// No description provided for @membreDuCercleRuby.
  ///
  /// In en, this message translates to:
  /// **'Member Of The Ruby Circle'**
  String get membreDuCercleRuby;

  /// No description provided for @membreDuCercleSapphire.
  ///
  /// In en, this message translates to:
  /// **'Member Of The Sapphire Circle'**
  String get membreDuCercleSapphire;

  /// No description provided for @succes.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get succes;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations !'**
  String get congratulations;

  /// No description provided for @votreCompteModifieAvecSucces.
  ///
  /// In en, this message translates to:
  /// **'Your account has been successfully modified!'**
  String get votreCompteModifieAvecSucces;

  /// No description provided for @codeActivated.
  ///
  /// In en, this message translates to:
  /// **'Your code has been activated'**
  String get codeActivated;

  /// No description provided for @passwordEditedOk.
  ///
  /// In en, this message translates to:
  /// **'Your password has been successfully changed!'**
  String get passwordEditedOk;

  /// No description provided for @plusFiveCoins.
  ///
  /// In en, this message translates to:
  /// **'+5 Coins !'**
  String get plusFiveCoins;

  /// No description provided for @erreure.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get erreure;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @anErrorOccured.
  ///
  /// In en, this message translates to:
  /// **'An error has occured'**
  String get anErrorOccured;

  /// No description provided for @uneErreurEstSurvenue.
  ///
  /// In en, this message translates to:
  /// **'A mistake has occurred. Please try again later.'**
  String get uneErreurEstSurvenue;

  /// No description provided for @echecDeConnexion.
  ///
  /// In en, this message translates to:
  /// **'Connection failure'**
  String get echecDeConnexion;

  /// No description provided for @echecInscription.
  ///
  /// In en, this message translates to:
  /// **'Failure to register'**
  String get echecInscription;

  /// No description provided for @deleteAuthorization.
  ///
  /// In en, this message translates to:
  /// **'Please reset your Apple account access permissions to the application and try again'**
  String get deleteAuthorization;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address!'**
  String get invalidEmail;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'The password must contain at least 8 characters, one lower case, one upper case and one number'**
  String get invalidPassword;

  /// No description provided for @adresseMailDejaExistante.
  ///
  /// In en, this message translates to:
  /// **'Existing email address'**
  String get adresseMailDejaExistante;

  /// No description provided for @motDePasseDifferents.
  ///
  /// In en, this message translates to:
  /// **'Different passwords'**
  String get motDePasseDifferents;

  /// No description provided for @differentPassword.
  ///
  /// In en, this message translates to:
  /// **'Different Passwords'**
  String get differentPassword;

  /// No description provided for @passwordMustBeTheSame.
  ///
  /// In en, this message translates to:
  /// **'Passwords must match'**
  String get passwordMustBeTheSame;

  /// No description provided for @mailOuMotDePasseIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password'**
  String get mailOuMotDePasseIncorrect;

  /// No description provided for @ancienMotDePasseIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Your old password is invalid'**
  String get ancienMotDePasseIncorrect;

  /// No description provided for @facebookDeletePasswordImpossible.
  ///
  /// In en, this message translates to:
  /// **'Logging in with a Facebook or Apple account does not allow you to change your password'**
  String get facebookDeletePasswordImpossible;

  /// No description provided for @vousNavezPasAssezDeCredits.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have enough credits to Happer!'**
  String get vousNavezPasAssezDeCredits;

  /// No description provided for @onDiraitQueVousNavezPlusDeCredit.
  ///
  /// In en, this message translates to:
  /// **'Looks like you\'re out of credit!'**
  String get onDiraitQueVousNavezPlusDeCredit;

  /// No description provided for @impossibleHapper.
  ///
  /// In en, this message translates to:
  /// **'Impossible to Happer, you are not part of this circle !'**
  String get impossibleHapper;

  /// No description provided for @vousAvezDejaGagneUnProduit.
  ///
  /// In en, this message translates to:
  /// **'You have already won a product this month !'**
  String get vousAvezDejaGagneUnProduit;

  /// No description provided for @produitsEnPause.
  ///
  /// In en, this message translates to:
  /// **'The products are on pause, please try again later.'**
  String get produitsEnPause;

  /// No description provided for @produitRemporterParAutreUtilisateur.
  ///
  /// In en, this message translates to:
  /// **'The product was won by another user!'**
  String get produitRemporterParAutreUtilisateur;

  /// No description provided for @expiredCode.
  ///
  /// In en, this message translates to:
  /// **'Expired code'**
  String get expiredCode;

  /// No description provided for @codeUnknown.
  ///
  /// In en, this message translates to:
  /// **'Sorry, this code does not seem to be valid. Please make sure it was written correctly.'**
  String get codeUnknown;

  /// No description provided for @codeAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'Sorry, it seems that this code has already been used.'**
  String get codeAlreadyUsed;

  /// No description provided for @modificationImpossible.
  ///
  /// In en, this message translates to:
  /// **'Unable to modify'**
  String get modificationImpossible;

  /// No description provided for @impossibleModification.
  ///
  /// In en, this message translates to:
  /// **'Modification impossible'**
  String get impossibleModification;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @votreSignalementPrisEnCompte.
  ///
  /// In en, this message translates to:
  /// **'Your report has been taken into consideration.'**
  String get votreSignalementPrisEnCompte;

  /// No description provided for @aucunNouveauSelfieANoter.
  ///
  /// In en, this message translates to:
  /// **'No new Selfie to note'**
  String get aucunNouveauSelfieANoter;

  /// No description provided for @validateYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Credits are pending, validate your e-mail.'**
  String get validateYourEmail;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @voulezVousVraimentSignalerCeSelfie.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to report this selfie ? '**
  String get voulezVousVraimentSignalerCeSelfie;

  /// No description provided for @oui.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get oui;

  /// No description provided for @non.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get non;

  /// No description provided for @noThanks.
  ///
  /// In en, this message translates to:
  /// **'NO THANKS'**
  String get noThanks;

  /// No description provided for @textToolTipVIDEO.
  ///
  /// In en, this message translates to:
  /// **'The explanatory video is still available here'**
  String get textToolTipVIDEO;

  /// No description provided for @tooltipBackProducts.
  ///
  /// In en, this message translates to:
  /// **'Return to the articles'**
  String get tooltipBackProducts;

  /// No description provided for @tooltipIWantIt.
  ///
  /// In en, this message translates to:
  /// **'You can buy the article directly'**
  String get tooltipIWantIt;

  /// No description provided for @youHaveThreeCoins.
  ///
  /// In en, this message translates to:
  /// **'You have 2 coins'**
  String get youHaveThreeCoins;

  /// No description provided for @youCanShowAd.
  ///
  /// In en, this message translates to:
  /// **'You can view ads for more coins'**
  String get youCanShowAd;

  /// No description provided for @dailyLogin.
  ///
  /// In en, this message translates to:
  /// **'Welcome login'**
  String get dailyLogin;

  /// No description provided for @exceptOf.
  ///
  /// In en, this message translates to:
  /// **'except of '**
  String get exceptOf;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @enterCodeAndNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter the code received by email and your new password'**
  String get enterCodeAndNewPassword;

  /// No description provided for @lang.
  ///
  /// In en, this message translates to:
  /// **'en'**
  String get lang;

  /// No description provided for @superGreat.
  ///
  /// In en, this message translates to:
  /// **'Great !'**
  String get superGreat;

  /// No description provided for @restezAttentif.
  ///
  /// In en, this message translates to:
  /// **'Stay tuned !'**
  String get restezAttentif;

  /// No description provided for @marque.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get marque;

  /// No description provided for @demanderDesHappies.
  ///
  /// In en, this message translates to:
  /// **'Ask for Happies'**
  String get demanderDesHappies;

  /// No description provided for @bear.
  ///
  /// In en, this message translates to:
  /// **'ta mere'**
  String get bear;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @wishlistNotifications.
  ///
  /// In en, this message translates to:
  /// **'Wishlist Notifications'**
  String get wishlistNotifications;

  /// No description provided for @creditsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Credits Notifications'**
  String get creditsNotifications;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @wishlistNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications about your wishlist items'**
  String get wishlistNotificationsDesc;

  /// No description provided for @creditsNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications about your credits'**
  String get creditsNotificationsDesc;

  /// No description provided for @pushNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive general push notifications'**
  String get pushNotificationsDesc;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully'**
  String get settingsSaved;

  /// No description provided for @failedToSaveSettings.
  ///
  /// In en, this message translates to:
  /// **'Failed to save settings'**
  String get failedToSaveSettings;

  /// No description provided for @returnAndRefund.
  ///
  /// In en, this message translates to:
  /// **'Return and refund'**
  String get returnAndRefund;

  /// No description provided for @sponsorshipCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get sponsorshipCode;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'CART'**
  String get cartTitle;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'General terms of sale'**
  String get termsAndConditions;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordTitle;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'FORGOT PASSWORD'**
  String get forgotPasswordTitle;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'RESET PASSWORD'**
  String get resetPasswordTitle;

  /// No description provided for @gameContestTitle.
  ///
  /// In en, this message translates to:
  /// **'Game Contest'**
  String get gameContestTitle;

  /// No description provided for @mesCommandesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get mesCommandesTitle;

  /// No description provided for @mesLooksTitle.
  ///
  /// In en, this message translates to:
  /// **'My Boutique'**
  String get mesLooksTitle;

  /// No description provided for @mesFavorisTitle.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get mesFavorisTitle;

  /// No description provided for @sharePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'SHARE PHOTO'**
  String get sharePhotoTitle;

  /// No description provided for @deleteNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Notification'**
  String get deleteNotificationTitle;

  /// No description provided for @deleteNotificationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this notification?'**
  String get deleteNotificationConfirm;

  /// No description provided for @editProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Edit profile photo'**
  String get editProfilePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @myAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'My Address'**
  String get myAddressTitle;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @noNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up! Check back later for updates.'**
  String get noNotificationsSubtitle;

  /// No description provided for @noImagesFound.
  ///
  /// In en, this message translates to:
  /// **'No images yet'**
  String get noImagesFound;

  /// No description provided for @noImagesFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your looks will appear here once you add them.'**
  String get noImagesFoundSubtitle;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated successfully'**
  String get profilePhotoUpdated;

  /// No description provided for @profilePhotoUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile photo'**
  String get profilePhotoUpdateFailed;

  /// No description provided for @passwordUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdatedSuccess;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get enterCurrentPassword;

  /// No description provided for @codeCreditTitle.
  ///
  /// In en, this message translates to:
  /// **'CODE CREDIT'**
  String get codeCreditTitle;

  /// No description provided for @monCompteTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'MY ACCOUNT'**
  String get monCompteTitleLabel;

  /// No description provided for @monEspaceTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'MY SPACE'**
  String get monEspaceTitleLabel;

  /// No description provided for @loginToSeeContent.
  ///
  /// In en, this message translates to:
  /// **'Please log in to see more content'**
  String get loginToSeeContent;

  /// No description provided for @loginToTakeSelfie.
  ///
  /// In en, this message translates to:
  /// **'Please login to take a selfie'**
  String get loginToTakeSelfie;

  /// No description provided for @loginToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Please login to proceed to checkout'**
  String get loginToCheckout;

  /// No description provided for @itemRemovedFromCart.
  ///
  /// In en, this message translates to:
  /// **'Item removed from cart'**
  String get itemRemovedFromCart;

  /// No description provided for @selfieUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Selfie uploaded successfully!'**
  String get selfieUploadSuccess;

  /// No description provided for @selfieUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload selfie'**
  String get selfieUploadFailed;

  /// No description provided for @happerProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'HAPPER PRODUCTS'**
  String get happerProductsTitle;

  /// No description provided for @pleaseEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter a code'**
  String get pleaseEnterCode;

  /// No description provided for @codeVerifiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Code verified successfully'**
  String get codeVerifiedSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get loginFailed;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get registrationFailed;

  /// No description provided for @wishlistTitle.
  ///
  /// In en, this message translates to:
  /// **'WISHLIST'**
  String get wishlistTitle;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required'**
  String get cameraPermissionRequired;

  /// No description provided for @googleLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Google login failed. Please try again.'**
  String get googleLoginFailed;

  /// No description provided for @appleLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Apple login failed. Please try again.'**
  String get appleLoginFailed;

  /// No description provided for @noProductAvailable.
  ///
  /// In en, this message translates to:
  /// **'No product available'**
  String get noProductAvailable;

  /// No description provided for @addItemsToCart.
  ///
  /// In en, this message translates to:
  /// **'Please add items to your cart first'**
  String get addItemsToCart;

  /// No description provided for @wonProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'WON PRODUCTS'**
  String get wonProductsTitle;

  /// No description provided for @returnAndRefundTitle.
  ///
  /// In en, this message translates to:
  /// **'RETURN AND REFUND'**
  String get returnAndRefundTitle;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, we missed you.'**
  String get welcomeBack;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordLink;

  /// No description provided for @loginFailedCredentials.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get loginFailedCredentials;

  /// No description provided for @orSignInWith.
  ///
  /// In en, this message translates to:
  /// **'Or sign in with'**
  String get orSignInWith;

  /// No description provided for @noAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccountQuestion;

  /// No description provided for @signUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpLink;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorLabel;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in the fields below or sign up with your social media account.'**
  String get signupSubtitle;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstNameHint;

  /// No description provided for @lastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastNameHint;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordHint;

  /// No description provided for @sponsorCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Sponsorship Code (Optional)'**
  String get sponsorCodeHint;

  /// No description provided for @iAcceptAllThe.
  ///
  /// In en, this message translates to:
  /// **'I accept all the '**
  String get iAcceptAllThe;

  /// No description provided for @conditionsGenerales.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get conditionsGenerales;

  /// No description provided for @acceptTermsToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please accept the Terms and Conditions to continue.'**
  String get acceptTermsToContinue;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'SIGN UP'**
  String get signUpButton;

  /// No description provided for @orSignUpWith.
  ///
  /// In en, this message translates to:
  /// **'Or sign up with'**
  String get orSignUpWith;

  /// No description provided for @resetPasswordHeading.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordHeading;

  /// No description provided for @resetPasswordInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter the code received by email and your new password'**
  String get resetPasswordInstructions;

  /// No description provided for @enterCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get enterCodeHint;

  /// No description provided for @newPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordHint;

  /// No description provided for @confirmPasswordField.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordField;

  /// No description provided for @confirmButton.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM'**
  String get confirmButton;

  /// No description provided for @resetPasswordFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset password.'**
  String get resetPasswordFailed;

  /// No description provided for @registerTagline.
  ///
  /// In en, this message translates to:
  /// **'Join a community of fashion enthusiasts, discover incredible looks and share your style.'**
  String get registerTagline;

  /// No description provided for @getStartedButton.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStartedButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continueAsGuest;

  /// No description provided for @guestLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to continue as guest. Please try again.'**
  String get guestLoginFailed;

  /// No description provided for @productsAddedCount.
  ///
  /// In en, this message translates to:
  /// **'Products Added'**
  String get productsAddedCount;

  /// No description provided for @cartEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Add items to your cart to see them here'**
  String get cartEmptyDescription;

  /// No description provided for @confirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmLabel;

  /// No description provided for @confirmRemoveFromCart.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this item from your cart?'**
  String get confirmRemoveFromCart;

  /// No description provided for @happerSpecialPrice.
  ///
  /// In en, this message translates to:
  /// **'Happer Special Price'**
  String get happerSpecialPrice;

  /// No description provided for @subtotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtotal incl. VAT'**
  String get subtotalLabel;

  /// No description provided for @happerBenefits.
  ///
  /// In en, this message translates to:
  /// **'Happer Benefits'**
  String get happerBenefits;

  /// No description provided for @shippingLabel.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shippingLabel;

  /// No description provided for @freeLabel.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freeLabel;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total incl. VAT'**
  String get totalLabel;

  /// No description provided for @iAcceptThe.
  ///
  /// In en, this message translates to:
  /// **'I accept the '**
  String get iAcceptThe;

  /// No description provided for @cgvLabel.
  ///
  /// In en, this message translates to:
  /// **'General Terms of Sale'**
  String get cgvLabel;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE →'**
  String get continueButton;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get paymentFailed;

  /// No description provided for @noTokenError.
  ///
  /// In en, this message translates to:
  /// **'Error: No token found. Please log in again.'**
  String get noTokenError;

  /// No description provided for @itemRemoveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove item from cart'**
  String get itemRemoveFailed;

  /// No description provided for @itemRemoveError.
  ///
  /// In en, this message translates to:
  /// **'Error removing item from cart'**
  String get itemRemoveError;

  /// No description provided for @deleteNotificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete notification'**
  String get deleteNotificationFailed;

  /// No description provided for @authErrorLogin.
  ///
  /// In en, this message translates to:
  /// **'Authentication error. Please login again.'**
  String get authErrorLogin;

  /// No description provided for @shareButton.
  ///
  /// In en, this message translates to:
  /// **'PUBLISH'**
  String get shareButton;

  /// No description provided for @productsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Products are not available for your user type'**
  String get productsNotAvailable;

  /// No description provided for @selectExtraProducts.
  ///
  /// In en, this message translates to:
  /// **'Select Extra Products'**
  String get selectExtraProducts;

  /// No description provided for @tryAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgainButton;

  /// No description provided for @pleaseLoginFirst.
  ///
  /// In en, this message translates to:
  /// **'Please Login First'**
  String get pleaseLoginFirst;

  /// No description provided for @authErrorLoginAgain.
  ///
  /// In en, this message translates to:
  /// **'Authentication error. Please log in again.'**
  String get authErrorLoginAgain;

  /// No description provided for @deleteImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Image'**
  String get deleteImageTitle;

  /// No description provided for @deleteImageConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this image?'**
  String get deleteImageConfirm;

  /// No description provided for @imageDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Image deleted successfully'**
  String get imageDeletedSuccess;

  /// No description provided for @imageDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete image'**
  String get imageDeleteFailed;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addedToFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// No description provided for @failedUpdateFavorite.
  ///
  /// In en, this message translates to:
  /// **'Failed to update favorite status'**
  String get failedUpdateFavorite;

  /// No description provided for @noProductsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No products found in this category'**
  String get noProductsInCategory;

  /// No description provided for @itemAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'Item added to cart successfully'**
  String get itemAddedToCart;

  /// No description provided for @failedAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Failed to add item to cart'**
  String get failedAddToCart;

  /// No description provided for @failedFetchSearchResults.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch search results'**
  String get failedFetchSearchResults;

  /// No description provided for @addedToWishlist.
  ///
  /// In en, this message translates to:
  /// **'Added to wishlist'**
  String get addedToWishlist;

  /// No description provided for @removedFromWishlist.
  ///
  /// In en, this message translates to:
  /// **'Removed from wishlist'**
  String get removedFromWishlist;

  /// No description provided for @failedUpdateWishlist.
  ///
  /// In en, this message translates to:
  /// **'Failed to update wishlist'**
  String get failedUpdateWishlist;

  /// No description provided for @viewWishlist.
  ///
  /// In en, this message translates to:
  /// **'VIEW WISHLIST'**
  String get viewWishlist;

  /// No description provided for @errorTakingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Error taking photo'**
  String get errorTakingPhoto;

  /// No description provided for @errorSelectingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Error selecting photo'**
  String get errorSelectingPhoto;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @actualPrice.
  ///
  /// In en, this message translates to:
  /// **'Actual price'**
  String get actualPrice;

  /// No description provided for @promoPrice.
  ///
  /// In en, this message translates to:
  /// **'Promo Price'**
  String get promoPrice;

  /// No description provided for @deliveryDetailsButton.
  ///
  /// In en, this message translates to:
  /// **'DELIVERY DETAILS'**
  String get deliveryDetailsButton;

  /// No description provided for @noPurchasesFound.
  ///
  /// In en, this message translates to:
  /// **'No purchases found.'**
  String get noPurchasesFound;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link'**
  String get couldNotOpenLink;

  /// No description provided for @myOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'MY ORDERS'**
  String get myOrdersTitle;

  /// No description provided for @myAddressAppBar.
  ///
  /// In en, this message translates to:
  /// **'MY ADDRESS'**
  String get myAddressAppBar;

  /// No description provided for @errorLoadingCredits.
  ///
  /// In en, this message translates to:
  /// **'Error loading credits'**
  String get errorLoadingCredits;

  /// No description provided for @failedLoadNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Failed to load notification settings'**
  String get failedLoadNotificationSettings;

  /// No description provided for @failedUpdateSettings.
  ///
  /// In en, this message translates to:
  /// **'Failed to update'**
  String get failedUpdateSettings;

  /// No description provided for @userIdNotFound.
  ///
  /// In en, this message translates to:
  /// **'User ID not found'**
  String get userIdNotFound;

  /// No description provided for @pleaseEnterTheCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the code'**
  String get pleaseEnterTheCode;

  /// No description provided for @verificationCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCodeLabel;

  /// No description provided for @failedLoadWonProducts.
  ///
  /// In en, this message translates to:
  /// **'Failed to load won products'**
  String get failedLoadWonProducts;

  /// No description provided for @couldNotLoadInvoice.
  ///
  /// In en, this message translates to:
  /// **'Could not load invoice'**
  String get couldNotLoadInvoice;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @emailCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Email copied to clipboard'**
  String get emailCopiedToClipboard;

  /// No description provided for @couldNotOpenImageDetails.
  ///
  /// In en, this message translates to:
  /// **'Could not open image details'**
  String get couldNotOpenImageDetails;

  /// No description provided for @myAddressesTitle.
  ///
  /// In en, this message translates to:
  /// **'MY ADDRESSES'**
  String get myAddressesTitle;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add address'**
  String get addAddress;

  /// No description provided for @noAddressRegistered.
  ///
  /// In en, this message translates to:
  /// **'No address registered'**
  String get noAddressRegistered;

  /// No description provided for @deleteAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete address'**
  String get deleteAddressTitle;

  /// No description provided for @deleteAddressConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete this address?'**
  String get deleteAddressConfirm;

  /// No description provided for @addressDeleted.
  ///
  /// In en, this message translates to:
  /// **'Address deleted'**
  String get addressDeleted;

  /// No description provided for @newAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'NEW ADDRESS'**
  String get newAddressTitle;

  /// No description provided for @editAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'EDIT ADDRESS'**
  String get editAddressTitle;

  /// No description provided for @addressLabelField.
  ///
  /// In en, this message translates to:
  /// **'Label (e.g. Home, Office)'**
  String get addressLabelField;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get saveButton;

  /// No description provided for @updateButton.
  ///
  /// In en, this message translates to:
  /// **'UPDATE'**
  String get updateButton;

  /// No description provided for @addressUpdated.
  ///
  /// In en, this message translates to:
  /// **'Address updated'**
  String get addressUpdated;

  /// No description provided for @addressAdded.
  ///
  /// In en, this message translates to:
  /// **'Address added'**
  String get addressAdded;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @myProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfileTitle;

  /// No description provided for @personalInfoSection.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInfoSection;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameLabel;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @memberSinceLabel.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get memberSinceLabel;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @unfollow.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollow;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @posts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get posts;

  /// No description provided for @profileLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get profileLoadFailed;

  /// No description provided for @linkProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'Link Products'**
  String get linkProductsTitle;

  /// No description provided for @captionLabel.
  ///
  /// In en, this message translates to:
  /// **'Caption'**
  String get captionLabel;

  /// No description provided for @captionHint.
  ///
  /// In en, this message translates to:
  /// **'Add a caption...'**
  String get captionHint;

  /// No description provided for @maxImagesReached.
  ///
  /// In en, this message translates to:
  /// **'You can add up to {count} images'**
  String maxImagesReached(int count);

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add image'**
  String get addImage;

  /// No description provided for @likedProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'LIKED PRODUCTS'**
  String get likedProductsTitle;

  /// No description provided for @noLikedProducts.
  ///
  /// In en, this message translates to:
  /// **'No liked products yet'**
  String get noLikedProducts;

  /// No description provided for @noLikedProductsDesc.
  ///
  /// In en, this message translates to:
  /// **'Products you like will appear here'**
  String get noLikedProductsDesc;

  /// No description provided for @favTabPosts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get favTabPosts;

  /// No description provided for @favTabProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get favTabProducts;

  /// No description provided for @selectAtLeastOneProduct.
  ///
  /// In en, this message translates to:
  /// **'Please link at least one product to your selfie'**
  String get selectAtLeastOneProduct;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesYet;

  /// No description provided for @favoritesWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Looks you like will appear here'**
  String get favoritesWillAppearHere;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @pleaseWaitMoment.
  ///
  /// In en, this message translates to:
  /// **'Please wait a moment'**
  String get pleaseWaitMoment;

  /// No description provided for @loggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get loggingIn;

  /// No description provided for @signingUp.
  ///
  /// In en, this message translates to:
  /// **'Signing up...'**
  String get signingUp;

  /// No description provided for @verifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get verifying;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a selfie'**
  String get addPhoto;

  /// No description provided for @loginToAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Please login to add to cart'**
  String get loginToAddToCart;

  /// No description provided for @activateCreatorAccount.
  ///
  /// In en, this message translates to:
  /// **'Activate Creator'**
  String get activateCreatorAccount;

  /// No description provided for @dobLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dobLabel;

  /// No description provided for @creatorAccountActivated.
  ///
  /// In en, this message translates to:
  /// **'Creator account activated successfully!'**
  String get creatorAccountActivated;

  /// No description provided for @completeProfileBeforeAccept.
  ///
  /// In en, this message translates to:
  /// **'Please complete your profile before accepting: {fields}'**
  String completeProfileBeforeAccept(String fields);

  /// No description provided for @pleaseSelectShippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Please select a delivery address'**
  String get pleaseSelectShippingAddress;

  /// No description provided for @productSelectedBy.
  ///
  /// In en, this message translates to:
  /// **'This product was selected by'**
  String get productSelectedBy;

  /// No description provided for @theHappyPlaceOfFashion.
  ///
  /// In en, this message translates to:
  /// **'The happy place of fashion'**
  String get theHappyPlaceOfFashion;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @agreeWithAllTermsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'I agree with all Terms and Conditions'**
  String get agreeWithAllTermsAndConditions;

  /// No description provided for @enterRegisteredEmailForNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your registered email to get your new password'**
  String get enterRegisteredEmailForNewPassword;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @creator.
  ///
  /// In en, this message translates to:
  /// **'CREATOR'**
  String get creator;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'DISCOVER'**
  String get discover;

  /// No description provided for @dayAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} day ago'**
  String dayAgo(int days);

  /// No description provided for @selectSize.
  ///
  /// In en, this message translates to:
  /// **'SELECT SIZE'**
  String get selectSize;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'ADD TO CART'**
  String get addToCart;

  /// No description provided for @subTotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subTotal;

  /// No description provided for @shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @continuer.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continuer;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// No description provided for @shopThePics.
  ///
  /// In en, this message translates to:
  /// **'CREATOR\'S SHOP'**
  String get shopThePics;

  /// No description provided for @selectProduct.
  ///
  /// In en, this message translates to:
  /// **'Select a product'**
  String get selectProduct;

  /// No description provided for @useContactInMyProfile.
  ///
  /// In en, this message translates to:
  /// **'Use the contact details in my profile'**
  String get useContactInMyProfile;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'CHECKOUT'**
  String get checkout;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'PAY NOW'**
  String get payNow;

  /// No description provided for @saveCardForFuturePayments.
  ///
  /// In en, this message translates to:
  /// **'Save this card for future payments'**
  String get saveCardForFuturePayments;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get profile;

  /// No description provided for @myPictures.
  ///
  /// In en, this message translates to:
  /// **'My pictures'**
  String get myPictures;

  /// No description provided for @promo.
  ///
  /// In en, this message translates to:
  /// **'Promo'**
  String get promo;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get paid;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'SENT'**
  String get sent;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'DELIVERED'**
  String get delivered;

  /// No description provided for @referralCode.
  ///
  /// In en, this message translates to:
  /// **'Referral code'**
  String get referralCode;

  /// No description provided for @won.
  ///
  /// In en, this message translates to:
  /// **'WON'**
  String get won;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'VERIFY'**
  String get verify;

  /// No description provided for @procedure.
  ///
  /// In en, this message translates to:
  /// **'Procedure'**
  String get procedure;

  /// No description provided for @contactCustomerServiceNotice.
  ///
  /// In en, this message translates to:
  /// **'For any question or issue, contact customer service at contact@happer.fr. Average response time: 72h.'**
  String get contactCustomerServiceNotice;

  /// No description provided for @contactByEmail.
  ///
  /// In en, this message translates to:
  /// **'CONTACT BY EMAIL'**
  String get contactByEmail;

  /// No description provided for @sharedPictures.
  ///
  /// In en, this message translates to:
  /// **'Shared pictures'**
  String get sharedPictures;

  /// No description provided for @likedPictures.
  ///
  /// In en, this message translates to:
  /// **'Liked pictures'**
  String get likedPictures;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'DETAILS'**
  String get details;

  /// No description provided for @weContactYouWithin72Hours.
  ///
  /// In en, this message translates to:
  /// **'We will contact you by email within 72 hours!'**
  String get weContactYouWithin72Hours;

  /// No description provided for @theseArticlesSelectedBy.
  ///
  /// In en, this message translates to:
  /// **'These articles have been selected by'**
  String get theseArticlesSelectedBy;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// No description provided for @sixth.
  ///
  /// In en, this message translates to:
  /// **'6th'**
  String get sixth;

  /// No description provided for @seventh.
  ///
  /// In en, this message translates to:
  /// **'7th'**
  String get seventh;

  /// No description provided for @eighth.
  ///
  /// In en, this message translates to:
  /// **'8th'**
  String get eighth;

  /// No description provided for @ninth.
  ///
  /// In en, this message translates to:
  /// **'9th'**
  String get ninth;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @gcs.
  ///
  /// In en, this message translates to:
  /// **'GCS'**
  String get gcs;

  /// No description provided for @gcu.
  ///
  /// In en, this message translates to:
  /// **'GCU'**
  String get gcu;

  /// No description provided for @myPurchases.
  ///
  /// In en, this message translates to:
  /// **'MY PURCHASES'**
  String get myPurchases;

  /// No description provided for @codeVerified.
  ///
  /// In en, this message translates to:
  /// **'CODE VERIFIED'**
  String get codeVerified;

  /// No description provided for @minimumDateBeforePlay.
  ///
  /// In en, this message translates to:
  /// **'Minimum date and time before you can play on the product'**
  String get minimumDateBeforePlay;

  /// No description provided for @nightBiddingPaused.
  ///
  /// In en, this message translates to:
  /// **'Between midnight and 8 am you cannot bid on products. Resume in {hours} hours.'**
  String nightBiddingPaused(int hours);

  /// No description provided for @moreCoins.
  ///
  /// In en, this message translates to:
  /// **'Need more credits?'**
  String get moreCoins;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @publishMyLook.
  ///
  /// In en, this message translates to:
  /// **'PUBLISH MY LOOK'**
  String get publishMyLook;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProducts;

  /// No description provided for @myLooks.
  ///
  /// In en, this message translates to:
  /// **'My looks'**
  String get myLooks;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'CONFIRMED'**
  String get confirmed;

  /// No description provided for @shippingLink.
  ///
  /// In en, this message translates to:
  /// **'SHIPPING LINK'**
  String get shippingLink;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'ORDER DETAILS'**
  String get orderDetails;

  /// No description provided for @deliveredOn.
  ///
  /// In en, this message translates to:
  /// **'Delivered on'**
  String get deliveredOn;

  /// No description provided for @confirmedStatus.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmedStatus;

  /// No description provided for @shippedStatus.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get shippedStatus;

  /// No description provided for @deliveredStatus.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get deliveredStatus;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @trackingNumber.
  ///
  /// In en, this message translates to:
  /// **'Tracking number'**
  String get trackingNumber;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get deliveryAddress;

  /// No description provided for @orderInformation.
  ///
  /// In en, this message translates to:
  /// **'Order information'**
  String get orderInformation;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order number'**
  String get orderNumber;

  /// No description provided for @viewInvoicePdf.
  ///
  /// In en, this message translates to:
  /// **'View invoice (PDF)'**
  String get viewInvoicePdf;

  /// No description provided for @purchasedVia.
  ///
  /// In en, this message translates to:
  /// **'Purchased via'**
  String get purchasedVia;

  /// No description provided for @viewLook.
  ///
  /// In en, this message translates to:
  /// **'View look'**
  String get viewLook;

  /// No description provided for @returnOrReplaceItem.
  ///
  /// In en, this message translates to:
  /// **'Return or replace item'**
  String get returnOrReplaceItem;

  /// No description provided for @makeAReturnRequest.
  ///
  /// In en, this message translates to:
  /// **'Make a return request'**
  String get makeAReturnRequest;

  /// No description provided for @returnThisItem.
  ///
  /// In en, this message translates to:
  /// **'RETURN THIS ITEM'**
  String get returnThisItem;

  /// No description provided for @returnWindowNotice.
  ///
  /// In en, this message translates to:
  /// **'You have 14 days after receipt to make a return request'**
  String get returnWindowNotice;

  /// No description provided for @incorrectSize.
  ///
  /// In en, this message translates to:
  /// **'Incorrect size'**
  String get incorrectSize;

  /// No description provided for @damagedItem.
  ///
  /// In en, this message translates to:
  /// **'Damaged item'**
  String get damagedItem;

  /// No description provided for @itemNotAsDescribed.
  ///
  /// In en, this message translates to:
  /// **'Item not as described'**
  String get itemNotAsDescribed;

  /// No description provided for @itemDoesNotSuitMe.
  ///
  /// In en, this message translates to:
  /// **'The item does not suit me'**
  String get itemDoesNotSuitMe;

  /// No description provided for @otherReason.
  ///
  /// In en, this message translates to:
  /// **'Other reason'**
  String get otherReason;

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Add a comment'**
  String get addComment;

  /// No description provided for @addItemPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add photos of the item'**
  String get addItemPhotos;

  /// No description provided for @viewReturnConditions.
  ///
  /// In en, this message translates to:
  /// **'View return conditions'**
  String get viewReturnConditions;

  /// No description provided for @submitReturnRequest.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT RETURN REQUEST'**
  String get submitReturnRequest;

  /// No description provided for @returnRequest.
  ///
  /// In en, this message translates to:
  /// **'RETURN REQUEST'**
  String get returnRequest;

  /// No description provided for @returnRequestReceived.
  ///
  /// In en, this message translates to:
  /// **'We received your request on {date} at {time}. Follow its progress below.'**
  String returnRequestReceived(String date, String time);

  /// No description provided for @request.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get request;

  /// No description provided for @dispatch.
  ///
  /// In en, this message translates to:
  /// **'Dispatch'**
  String get dispatch;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @refund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get refund;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @returnReason.
  ///
  /// In en, this message translates to:
  /// **'Return reason'**
  String get returnReason;

  /// No description provided for @requestDate.
  ///
  /// In en, this message translates to:
  /// **'Request date'**
  String get requestDate;

  /// No description provided for @requestNumber.
  ///
  /// In en, this message translates to:
  /// **'Request number'**
  String get requestNumber;

  /// No description provided for @returnAddress.
  ///
  /// In en, this message translates to:
  /// **'Return address'**
  String get returnAddress;

  /// No description provided for @returnFees.
  ///
  /// In en, this message translates to:
  /// **'Return fees'**
  String get returnFees;

  /// No description provided for @customerPays.
  ///
  /// In en, this message translates to:
  /// **'Paid by the customer'**
  String get customerPays;

  /// No description provided for @returnDeadlineNotice.
  ///
  /// In en, this message translates to:
  /// **'You have until {date} to ship your return. After this deadline your request will be cancelled.'**
  String returnDeadlineNotice(String date);

  /// No description provided for @trackMyReturn.
  ///
  /// In en, this message translates to:
  /// **'Track my return'**
  String get trackMyReturn;

  /// No description provided for @trackReturnDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow the delivery after shipping.'**
  String get trackReturnDescription;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'CONTACT SUPPORT'**
  String get contactSupport;

  /// No description provided for @forAnyQuestionNeedOrIssue.
  ///
  /// In en, this message translates to:
  /// **'For any question, need or issue, please contact customer service at support@happer.fr.'**
  String get forAnyQuestionNeedOrIssue;

  /// No description provided for @averageResponseTime.
  ///
  /// In en, this message translates to:
  /// **'Average response time is 72h.'**
  String get averageResponseTime;

  /// No description provided for @viewFaq.
  ///
  /// In en, this message translates to:
  /// **'VIEW FAQ'**
  String get viewFaq;

  /// No description provided for @contactByWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'CONTACT BY WHATSAPP'**
  String get contactByWhatsapp;

  /// No description provided for @activateYourAccount.
  ///
  /// In en, this message translates to:
  /// **'ACTIVATE YOUR ACCOUNT'**
  String get activateYourAccount;

  /// No description provided for @happerCreator.
  ///
  /// In en, this message translates to:
  /// **'HAPPER CREATOR'**
  String get happerCreator;

  /// No description provided for @creatorActivationIntro.
  ///
  /// In en, this message translates to:
  /// **'You can now activate your Happer creator account.'**
  String get creatorActivationIntro;

  /// No description provided for @creatorActivationBenefits.
  ///
  /// In en, this message translates to:
  /// **'You will be able to receive products from our partner brands, share them on Happer and earn revenue on sales made through your content.'**
  String get creatorActivationBenefits;

  /// No description provided for @byAcceptingYouConfirm.
  ///
  /// In en, this message translates to:
  /// **'By accepting, you confirm:'**
  String get byAcceptingYouConfirm;

  /// No description provided for @publishReceivedProducts.
  ///
  /// In en, this message translates to:
  /// **'Publish the products received within the agreed deadlines'**
  String get publishReceivedProducts;

  /// No description provided for @respectCollaborationRules.
  ///
  /// In en, this message translates to:
  /// **'Respect the collaboration rules'**
  String get respectCollaborationRules;

  /// No description provided for @guaranteeAuthenticity.
  ///
  /// In en, this message translates to:
  /// **'Guarantee the authenticity of your content'**
  String get guaranteeAuthenticity;

  /// No description provided for @authorizeContentUse.
  ///
  /// In en, this message translates to:
  /// **'Authorize Happer to use the content in accordance with the contract'**
  String get authorizeContentUse;

  /// No description provided for @creatorContractNotice.
  ///
  /// In en, this message translates to:
  /// **'This collaboration is governed by the Happer Creator Contract.'**
  String get creatorContractNotice;

  /// No description provided for @creatorTermsCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I acknowledge that I have read the Happer Creator Contract, accept it without reservation and undertake to comply with it.'**
  String get creatorTermsCheckbox;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'LOG OUT'**
  String get logoutButton;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get enterNewPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your new password'**
  String get confirmNewPassword;

  /// No description provided for @myLooksTitle.
  ///
  /// In en, this message translates to:
  /// **'MY LOOKS'**
  String get myLooksTitle;

  /// No description provided for @authLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login required'**
  String get authLoginRequired;

  /// No description provided for @authLoginToContinue.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue.'**
  String get authLoginToContinue;

  /// No description provided for @authEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get authEnterEmail;

  /// No description provided for @authEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get authEnterPassword;

  /// No description provided for @authEnterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get authEnterFirstName;

  /// No description provided for @authEnterLastName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your last name'**
  String get authEnterLastName;

  /// No description provided for @authEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get authEnterUsername;

  /// No description provided for @authUsernameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get authUsernameTooShort;

  /// No description provided for @authUsernameInvalidChars.
  ///
  /// In en, this message translates to:
  /// **'Username can only contain lowercase letters, numbers, _ and .'**
  String get authUsernameInvalidChars;

  /// No description provided for @authEnterAPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get authEnterAPassword;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get authPasswordTooShort;

  /// No description provided for @authUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **'Username is already taken. Please choose another.'**
  String get authUsernameTaken;

  /// No description provided for @authVerifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get authVerifyEmailTitle;

  /// No description provided for @authEnterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get authEnterVerificationCode;

  /// No description provided for @authCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to\n{email}'**
  String authCodeSentTo(String email);

  /// No description provided for @authEnterSixDigitCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit code'**
  String get authEnterSixDigitCodeHint;

  /// No description provided for @authVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get authVerify;

  /// No description provided for @authEnterSixDigitCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit code.'**
  String get authEnterSixDigitCode;

  /// No description provided for @authDidntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code? '**
  String get authDidntReceiveCode;

  /// No description provided for @authResend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get authResend;

  /// No description provided for @authVerifyAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify & Continue'**
  String get authVerifyAndContinue;

  /// No description provided for @authForgotPasswordHeading.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get authForgotPasswordHeading;

  /// No description provided for @authFillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields.'**
  String get authFillRequiredFields;

  /// No description provided for @authVerificationCodeSent.
  ///
  /// In en, this message translates to:
  /// **'A verification code has been sent to your email.'**
  String get authVerificationCodeSent;

  /// No description provided for @authAccountVerified.
  ///
  /// In en, this message translates to:
  /// **'Account verified successfully!'**
  String get authAccountVerified;

  /// No description provided for @authAccountVerifiedPleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Account verified. Please log in.'**
  String get authAccountVerifiedPleaseLogin;

  /// No description provided for @authOtpVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Code verification failed. Please try again.'**
  String get authOtpVerificationFailed;

  /// No description provided for @authNewCodeSent.
  ///
  /// In en, this message translates to:
  /// **'A new code has been sent to your email.'**
  String get authNewCodeSent;

  /// No description provided for @authResendCodeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend the code. Please try again.'**
  String get authResendCodeFailed;

  /// No description provided for @authAppleSignInNoFirebaseToken.
  ///
  /// In en, this message translates to:
  /// **'Apple Sign In failed: could not get Firebase token. Please try again.'**
  String get authAppleSignInNoFirebaseToken;

  /// No description provided for @authAppleSignInNoAccessToken.
  ///
  /// In en, this message translates to:
  /// **'Apple Sign In failed: no access token from server. Please try again.'**
  String get authAppleSignInNoAccessToken;

  /// No description provided for @authAppleSignInSimulator.
  ///
  /// In en, this message translates to:
  /// **'Apple Sign In requires a real iPhone — not supported on iOS Simulator.'**
  String get authAppleSignInSimulator;

  /// No description provided for @authAuthenticationError.
  ///
  /// In en, this message translates to:
  /// **'Authentication error: {details}'**
  String authAuthenticationError(String details);

  /// No description provided for @authPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get authPleaseTryAgain;

  /// No description provided for @authGoogleSignInNoAccessToken.
  ///
  /// In en, this message translates to:
  /// **'Google Sign In failed: no access token from server.'**
  String get authGoogleSignInNoAccessToken;

  /// No description provided for @authEnterEmailAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email and password.'**
  String get authEnterEmailAndPassword;

  /// No description provided for @authSendResetCodeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset code. Please try again.'**
  String get authSendResetCodeFailed;

  /// No description provided for @authFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields.'**
  String get authFillAllFields;

  /// No description provided for @authPasswordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password has been reset successfully.'**
  String get authPasswordResetSuccess;

  /// No description provided for @authHapperCreatorContract.
  ///
  /// In en, this message translates to:
  /// **'Happer Creator Contract'**
  String get authHapperCreatorContract;

  /// No description provided for @authCreatorInfoRequired.
  ///
  /// In en, this message translates to:
  /// **'This information is required to set up your Creator contract.'**
  String get authCreatorInfoRequired;

  /// No description provided for @authAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get authAddressLabel;

  /// No description provided for @authNextUpper.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get authNextUpper;

  /// No description provided for @authContractNoticePrefix.
  ///
  /// In en, this message translates to:
  /// **'This collaboration is governed by the '**
  String get authContractNoticePrefix;

  /// No description provided for @authEditMyInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit my information'**
  String get authEditMyInfo;

  /// No description provided for @authUsernameExampleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. jean.dupont_12'**
  String get authUsernameExampleHint;

  /// No description provided for @authRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get authRequired;

  /// No description provided for @authUsernameRules.
  ///
  /// In en, this message translates to:
  /// **'3–20 characters: lowercase letters, numbers, _ or .'**
  String get authUsernameRules;

  /// No description provided for @authUsernameAlreadyTaken.
  ///
  /// In en, this message translates to:
  /// **'This username is already taken'**
  String get authUsernameAlreadyTaken;

  /// No description provided for @authStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String authStepOf(int step, int total);

  /// No description provided for @cartPaymentMethodCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get cartPaymentMethodCard;

  /// No description provided for @cartRemoveItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get cartRemoveItemTitle;

  /// No description provided for @cartRemoveButton.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get cartRemoveButton;

  /// No description provided for @cartPaymentDataMissing.
  ///
  /// In en, this message translates to:
  /// **'Error: missing payment data'**
  String get cartPaymentDataMissing;

  /// No description provided for @cartGooglePayUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Google Pay is not available on this device'**
  String get cartGooglePayUnavailable;

  /// No description provided for @cartPaymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment successful!'**
  String get cartPaymentSuccess;

  /// No description provided for @cartChoosePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose a payment method'**
  String get cartChoosePaymentMethod;

  /// No description provided for @cartMyCartTitle.
  ///
  /// In en, this message translates to:
  /// **'MY CART'**
  String get cartMyCartTitle;

  /// No description provided for @cartProductsAddedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} Product Added} other{{count} Products Added}}'**
  String cartProductsAddedCount(int count);

  /// No description provided for @cartDeliveryTo.
  ///
  /// In en, this message translates to:
  /// **'Deliver to'**
  String get cartDeliveryTo;

  /// No description provided for @cartSelectAddress.
  ///
  /// In en, this message translates to:
  /// **'Select an address'**
  String get cartSelectAddress;

  /// No description provided for @cartChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get cartChange;

  /// No description provided for @cartChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get cartChoose;

  /// No description provided for @cartPayWith.
  ///
  /// In en, this message translates to:
  /// **'PAY WITH'**
  String get cartPayWith;

  /// No description provided for @cartSecure.
  ///
  /// In en, this message translates to:
  /// **'Secure'**
  String get cartSecure;

  /// No description provided for @cartTotalInclVatUpper.
  ///
  /// In en, this message translates to:
  /// **'TOTAL INCL. VAT'**
  String get cartTotalInclVatUpper;

  /// No description provided for @cartOrderButton.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get cartOrderButton;

  /// No description provided for @cartPayByCard.
  ///
  /// In en, this message translates to:
  /// **'Pay by card'**
  String get cartPayByCard;

  /// No description provided for @cartPayAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String cartPayAmount(String amount);

  /// No description provided for @cartAddProductsToStart.
  ///
  /// In en, this message translates to:
  /// **'Add products to get started'**
  String get cartAddProductsToStart;

  /// No description provided for @cartDeliveredIn2To5Days.
  ///
  /// In en, this message translates to:
  /// **'Delivered in 2-5 days'**
  String get cartDeliveredIn2To5Days;

  /// No description provided for @cartPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get cartPaymentTitle;

  /// No description provided for @cartAddToOrderComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Adding to your order coming soon'**
  String get cartAddToOrderComingSoon;

  /// No description provided for @cartThankYouTitle.
  ///
  /// In en, this message translates to:
  /// **'THANK YOU'**
  String get cartThankYouTitle;

  /// No description provided for @cartThankYouForOrder.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your order!'**
  String get cartThankYouForOrder;

  /// No description provided for @cartPaymentConfirmedPreparing.
  ///
  /// In en, this message translates to:
  /// **'Your payment has been confirmed and your order\nis being prepared.'**
  String get cartPaymentConfirmedPreparing;

  /// No description provided for @cartOrderConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Order confirmed'**
  String get cartOrderConfirmed;

  /// No description provided for @cartOrderReference.
  ///
  /// In en, this message translates to:
  /// **'Order #{reference}'**
  String cartOrderReference(String reference);

  /// No description provided for @cartConfirmationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'A confirmation email has been sent to you.'**
  String get cartConfirmationEmailSent;

  /// No description provided for @cartFreeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Free delivery'**
  String get cartFreeDelivery;

  /// No description provided for @cartFreeDeliveryDescription.
  ///
  /// In en, this message translates to:
  /// **'Your order qualifies for free delivery.\nEstimated time: 3 to 5 business days.'**
  String get cartFreeDeliveryDescription;

  /// No description provided for @cartTrackMyOrder.
  ///
  /// In en, this message translates to:
  /// **'Track my order'**
  String get cartTrackMyOrder;

  /// No description provided for @cartTrackMyOrderDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow the shipping and delivery of your order in real time.'**
  String get cartTrackMyOrderDescription;

  /// No description provided for @cartViewMyOrder.
  ///
  /// In en, this message translates to:
  /// **'View my order'**
  String get cartViewMyOrder;

  /// No description provided for @cartBackToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get cartBackToHome;

  /// No description provided for @cartNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get cartNeedHelp;

  /// No description provided for @cartNeedHelpDescription.
  ///
  /// In en, this message translates to:
  /// **'Our team is here to help.\nContact us at any time.'**
  String get cartNeedHelpDescription;

  /// No description provided for @cartCompleteYourLook.
  ///
  /// In en, this message translates to:
  /// **'Complete your look'**
  String get cartCompleteYourLook;

  /// No description provided for @cartCompleteYourLookDescription.
  ///
  /// In en, this message translates to:
  /// **'Add 1 or 2 pieces to your order in one click.'**
  String get cartCompleteYourLookDescription;

  /// No description provided for @cartNoExtraPayment.
  ///
  /// In en, this message translates to:
  /// **'No extra payment. You only pay the difference.'**
  String get cartNoExtraPayment;

  /// No description provided for @cartConfirmAndAddToOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm and add to my order'**
  String get cartConfirmAndAddToOrder;

  /// No description provided for @cartNoThanksGoToOrder.
  ///
  /// In en, this message translates to:
  /// **'No thanks, go to my order'**
  String get cartNoThanksGoToOrder;

  /// No description provided for @cartAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get cartAdded;

  /// No description provided for @cartAddToMyOrder.
  ///
  /// In en, this message translates to:
  /// **'Add to my order'**
  String get cartAddToMyOrder;

  /// No description provided for @cartLoadDetailsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load cart details. Please try again.'**
  String get cartLoadDetailsFailed;

  /// No description provided for @cartUseProfileAddress.
  ///
  /// In en, this message translates to:
  /// **'Use my profile address'**
  String get cartUseProfileAddress;

  /// No description provided for @cartBillingAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'BILLING ADDRESS'**
  String get cartBillingAddressTitle;

  /// No description provided for @cartUseAddressFromMyProfile.
  ///
  /// In en, this message translates to:
  /// **'Use the address entered in My Profile'**
  String get cartUseAddressFromMyProfile;

  /// No description provided for @cartAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get cartAddressLabel;

  /// No description provided for @cartEnterLastName.
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get cartEnterLastName;

  /// No description provided for @cartEnterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get cartEnterFirstName;

  /// No description provided for @cartEnterStreetAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your street address'**
  String get cartEnterStreetAddress;

  /// No description provided for @cartEnterPostalCode.
  ///
  /// In en, this message translates to:
  /// **'Enter postal code'**
  String get cartEnterPostalCode;

  /// No description provided for @cartEnterCityName.
  ///
  /// In en, this message translates to:
  /// **'Enter city name'**
  String get cartEnterCityName;

  /// No description provided for @cartEnterEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get cartEnterEmailAddress;

  /// No description provided for @cartEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get cartEnterPhoneNumber;

  /// No description provided for @cartMinTwoCharacters.
  ///
  /// In en, this message translates to:
  /// **'Minimum 2 characters'**
  String get cartMinTwoCharacters;

  /// No description provided for @cartEnterValidAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid address'**
  String get cartEnterValidAddress;

  /// No description provided for @cartEnterValidPostalCode.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid postal code'**
  String get cartEnterValidPostalCode;

  /// No description provided for @cartEnterValidCityName.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid city name'**
  String get cartEnterValidCityName;

  /// No description provided for @cartEnterValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get cartEnterValidPhoneNumber;

  /// No description provided for @cartAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get cartAdd;

  /// No description provided for @cartDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get cartDefault;

  /// No description provided for @cartAddAddressToContinue.
  ///
  /// In en, this message translates to:
  /// **'Add an address to continue your order'**
  String get cartAddAddressToContinue;

  /// No description provided for @cartLoginToAccessCart.
  ///
  /// In en, this message translates to:
  /// **'Log in to access your cart.'**
  String get cartLoginToAccessCart;

  /// No description provided for @cartViewCart.
  ///
  /// In en, this message translates to:
  /// **'View cart'**
  String get cartViewCart;

  /// No description provided for @cartItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} item} other{{count} items}}'**
  String cartItemsCount(int count);

  /// No description provided for @cartInCartCount.
  ///
  /// In en, this message translates to:
  /// **'In cart ({count})'**
  String cartInCartCount(int count);

  /// No description provided for @cartColorUpper.
  ///
  /// In en, this message translates to:
  /// **'COLOR'**
  String get cartColorUpper;

  /// No description provided for @cartSizeUpper.
  ///
  /// In en, this message translates to:
  /// **'SIZE'**
  String get cartSizeUpper;

  /// No description provided for @cartQuantityUpper.
  ///
  /// In en, this message translates to:
  /// **'QUANTITY'**
  String get cartQuantityUpper;

  /// No description provided for @cartOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get cartOutOfStock;

  /// No description provided for @cartOutOfStockUpper.
  ///
  /// In en, this message translates to:
  /// **'OUT OF STOCK'**
  String get cartOutOfStockUpper;

  /// No description provided for @cartSelectASize.
  ///
  /// In en, this message translates to:
  /// **'Select a size'**
  String get cartSelectASize;

  /// No description provided for @cartSelectYourOptions.
  ///
  /// In en, this message translates to:
  /// **'Select your options'**
  String get cartSelectYourOptions;

  /// No description provided for @cartInStockCount.
  ///
  /// In en, this message translates to:
  /// **'{count} in stock'**
  String cartInStockCount(int count);

  /// No description provided for @cartStateActiveBidding.
  ///
  /// In en, this message translates to:
  /// **'Active bidding'**
  String get cartStateActiveBidding;

  /// No description provided for @cartStateStartingSoon.
  ///
  /// In en, this message translates to:
  /// **'Starting soon'**
  String get cartStateStartingSoon;

  /// No description provided for @cartStateBiddingEnded.
  ///
  /// In en, this message translates to:
  /// **'Bidding ended'**
  String get cartStateBiddingEnded;

  /// No description provided for @cartStateContestExpired.
  ///
  /// In en, this message translates to:
  /// **'Contest expired'**
  String get cartStateContestExpired;

  /// No description provided for @cartStatePlaceBidNow.
  ///
  /// In en, this message translates to:
  /// **'Place your bid now!'**
  String get cartStatePlaceBidNow;

  /// No description provided for @cartNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get cartNoDescription;

  /// No description provided for @cartUnknownBrand.
  ///
  /// In en, this message translates to:
  /// **'Unknown brand'**
  String get cartUnknownBrand;

  /// No description provided for @cartNoUser.
  ///
  /// In en, this message translates to:
  /// **'No user'**
  String get cartNoUser;

  /// No description provided for @creatorTheCollection.
  ///
  /// In en, this message translates to:
  /// **'THE COLLECTION'**
  String get creatorTheCollection;

  /// No description provided for @creatorNoMoreProducts.
  ///
  /// In en, this message translates to:
  /// **'No more products'**
  String get creatorNoMoreProducts;

  /// No description provided for @creatorCheckBackLaterNewArrivals.
  ///
  /// In en, this message translates to:
  /// **'Check back later for new arrivals'**
  String get creatorCheckBackLaterNewArrivals;

  /// No description provided for @creatorBrandInspirations.
  ///
  /// In en, this message translates to:
  /// **'INSPIRATIONS {brand}'**
  String creatorBrandInspirations(String brand);

  /// No description provided for @creatorNoInspiration.
  ///
  /// In en, this message translates to:
  /// **'No inspiration yet'**
  String get creatorNoInspiration;

  /// No description provided for @creatorAllCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up.'**
  String get creatorAllCaughtUp;

  /// No description provided for @creatorNewLooksComingSoon.
  ///
  /// In en, this message translates to:
  /// **'New looks are coming soon.'**
  String get creatorNewLooksComingSoon;

  /// No description provided for @creatorProductAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'Product added to cart'**
  String get creatorProductAddedToCart;

  /// No description provided for @creatorProductDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'PRODUCT DETAILS'**
  String get creatorProductDetailsTitle;

  /// No description provided for @creatorOutOfStockUpper.
  ///
  /// In en, this message translates to:
  /// **'OUT OF STOCK'**
  String get creatorOutOfStockUpper;

  /// No description provided for @creatorSelectColor.
  ///
  /// In en, this message translates to:
  /// **'SELECT COLOR'**
  String get creatorSelectColor;

  /// No description provided for @creatorSelectSize.
  ///
  /// In en, this message translates to:
  /// **'SELECT SIZE'**
  String get creatorSelectSize;

  /// No description provided for @creatorOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get creatorOutOfStock;

  /// No description provided for @creatorSoldBy.
  ///
  /// In en, this message translates to:
  /// **'Sold by {brand}'**
  String creatorSoldBy(String brand);

  /// No description provided for @creatorNoDescriptionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No description available'**
  String get creatorNoDescriptionAvailable;

  /// No description provided for @creatorSeeMore.
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get creatorSeeMore;

  /// No description provided for @creatorLoginToAddLookToCart.
  ///
  /// In en, this message translates to:
  /// **'Log in to add this look to your cart.'**
  String get creatorLoginToAddLookToCart;

  /// No description provided for @creatorNoItemAvailable.
  ///
  /// In en, this message translates to:
  /// **'No item available'**
  String get creatorNoItemAvailable;

  /// No description provided for @creatorItemsAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item added to cart} other{{count} items added to cart}}'**
  String creatorItemsAddedToCart(int count);

  /// No description provided for @creatorFailedAddItemsToCart.
  ///
  /// In en, this message translates to:
  /// **'Unable to add the items to the cart'**
  String get creatorFailedAddItemsToCart;

  /// No description provided for @creatorSelectionOf.
  ///
  /// In en, this message translates to:
  /// **'The selection of '**
  String get creatorSelectionOf;

  /// No description provided for @creatorAroundTheLook.
  ///
  /// In en, this message translates to:
  /// **'Around the look'**
  String get creatorAroundTheLook;

  /// No description provided for @creatorCollectionPrefix.
  ///
  /// In en, this message translates to:
  /// **'Collection '**
  String get creatorCollectionPrefix;

  /// No description provided for @creatorExploreCollection.
  ///
  /// In en, this message translates to:
  /// **'Explore the collection'**
  String get creatorExploreCollection;

  /// No description provided for @creatorShopTheLook.
  ///
  /// In en, this message translates to:
  /// **'SHOP THE LOOK'**
  String get creatorShopTheLook;

  /// No description provided for @creatorShareUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sharing is unavailable at the moment'**
  String get creatorShareUnavailable;

  /// No description provided for @creatorLookComposedWith.
  ///
  /// In en, this message translates to:
  /// **'Look created with '**
  String get creatorLookComposedWith;

  /// No description provided for @creatorHapperExclusivePrice.
  ///
  /// In en, this message translates to:
  /// **'Happer Exclusive Price'**
  String get creatorHapperExclusivePrice;

  /// No description provided for @creatorFreeDeliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Free Delivery'**
  String get creatorFreeDeliveryTitle;

  /// No description provided for @creatorAddLookToCartWithPrice.
  ///
  /// In en, this message translates to:
  /// **'ADD THE LOOK TO CART - {price}€'**
  String creatorAddLookToCartWithPrice(int price);

  /// No description provided for @creatorAddLookToCart.
  ///
  /// In en, this message translates to:
  /// **'ADD THE LOOK TO CART'**
  String get creatorAddLookToCart;

  /// No description provided for @creatorLookSavings.
  ///
  /// In en, this message translates to:
  /// **' - Save {amount}€ - '**
  String creatorLookSavings(int amount);

  /// No description provided for @creatorFreeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Free delivery'**
  String get creatorFreeDelivery;

  /// No description provided for @creatorCompleteTheLook.
  ///
  /// In en, this message translates to:
  /// **'Complete the look'**
  String get creatorCompleteTheLook;

  /// No description provided for @creatorChooseSizeForEachPiece.
  ///
  /// In en, this message translates to:
  /// **'Choose your size for each piece'**
  String get creatorChooseSizeForEachPiece;

  /// No description provided for @creatorRequired.
  ///
  /// In en, this message translates to:
  /// **'· required'**
  String get creatorRequired;

  /// No description provided for @creatorQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get creatorQuantity;

  /// No description provided for @creatorTotalWithCount.
  ///
  /// In en, this message translates to:
  /// **'Total ({count})'**
  String creatorTotalWithCount(int count);

  /// No description provided for @creatorSavingsAmount.
  ///
  /// In en, this message translates to:
  /// **'You save {amount} €'**
  String creatorSavingsAmount(String amount);

  /// No description provided for @creatorAddToCartButton.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get creatorAddToCartButton;

  /// No description provided for @creatorChooseSizes.
  ///
  /// In en, this message translates to:
  /// **'Choose sizes'**
  String get creatorChooseSizes;

  /// No description provided for @creatorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log in again.'**
  String get creatorSessionExpired;

  /// No description provided for @creatorFailedLoadSelfies.
  ///
  /// In en, this message translates to:
  /// **'Failed to load selfies.'**
  String get creatorFailedLoadSelfies;

  /// No description provided for @creatorFailedLoadSelfiesRetry.
  ///
  /// In en, this message translates to:
  /// **'Failed to load selfies. Please try again.'**
  String get creatorFailedLoadSelfiesRetry;

  /// No description provided for @creatorFailedDeleteRetry.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete. Please try again.'**
  String get creatorFailedDeleteRetry;

  /// No description provided for @creatorRemovedFromLikes.
  ///
  /// In en, this message translates to:
  /// **'Removed from your likes'**
  String get creatorRemovedFromLikes;

  /// No description provided for @creatorAddedToLikes.
  ///
  /// In en, this message translates to:
  /// **'Added to your likes'**
  String get creatorAddedToLikes;

  /// No description provided for @creatorFailedUpdateLikeRetry.
  ///
  /// In en, this message translates to:
  /// **'Failed to update like. Please try again.'**
  String get creatorFailedUpdateLikeRetry;

  /// No description provided for @creatorSelfiePublishedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Selfie published successfully!'**
  String get creatorSelfiePublishedSuccess;

  /// No description provided for @creatorSelfieSentPendingValidation.
  ///
  /// In en, this message translates to:
  /// **'Selfie sent! It will be visible once approved.'**
  String get creatorSelfieSentPendingValidation;

  /// No description provided for @creatorFailedPostSelfieRetry.
  ///
  /// In en, this message translates to:
  /// **'Failed to post selfie. Please try again.'**
  String get creatorFailedPostSelfieRetry;

  /// No description provided for @creatorInspirationTitle.
  ///
  /// In en, this message translates to:
  /// **'INSPIRATION'**
  String get creatorInspirationTitle;

  /// No description provided for @creatorShareProfileMessage.
  ///
  /// In en, this message translates to:
  /// **'I discovered {creatorName}\'s fashion boutique on Happer and I love their style ✨\n\nSharing their profile with you!\n\n{link}'**
  String creatorShareProfileMessage(String creatorName, String link);

  /// No description provided for @creatorShareOutfitMessage.
  ///
  /// In en, this message translates to:
  /// **'I found {creatorName}\'s outfit on Happer, I think you might like it ✨\n\n{link}'**
  String creatorShareOutfitMessage(String creatorName, String link);

  /// No description provided for @creatorShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Sharing failed. Please try again.'**
  String get creatorShareFailed;

  /// No description provided for @creatorCouldNotOpenUrl.
  ///
  /// In en, this message translates to:
  /// **'Could not open {url}'**
  String creatorCouldNotOpenUrl(String url);

  /// No description provided for @creatorErrorOpeningLink.
  ///
  /// In en, this message translates to:
  /// **'Error opening link: {error}'**
  String creatorErrorOpeningLink(String error);

  /// No description provided for @creatorSearchCreatorBrandHint.
  ///
  /// In en, this message translates to:
  /// **'Search creator, brand...'**
  String get creatorSearchCreatorBrandHint;

  /// No description provided for @creatorCreatorLabel.
  ///
  /// In en, this message translates to:
  /// **'Creator'**
  String get creatorCreatorLabel;

  /// No description provided for @dashLoginToAccessCommunity.
  ///
  /// In en, this message translates to:
  /// **'Please log in to access the community'**
  String get dashLoginToAccessCommunity;

  /// No description provided for @dashLoginToAccessProfile.
  ///
  /// In en, this message translates to:
  /// **'Please log in to access your profile'**
  String get dashLoginToAccessProfile;

  /// No description provided for @dashLoginToAccessFavorites.
  ///
  /// In en, this message translates to:
  /// **'Please log in to access your favorites'**
  String get dashLoginToAccessFavorites;

  /// No description provided for @dashLoginToPublishPhoto.
  ///
  /// In en, this message translates to:
  /// **'Please log in to publish a photo'**
  String get dashLoginToPublishPhoto;

  /// No description provided for @dashLoginToSearch.
  ///
  /// In en, this message translates to:
  /// **'Please log in to search'**
  String get dashLoginToSearch;

  /// No description provided for @dashSearchingForCreator.
  ///
  /// In en, this message translates to:
  /// **'Searching for creator: {query}'**
  String dashSearchingForCreator(String query);

  /// No description provided for @dashCropProgress.
  ///
  /// In en, this message translates to:
  /// **'Crop ({current}/{total})'**
  String dashCropProgress(int current, int total);

  /// No description provided for @dashCropYourPhoto.
  ///
  /// In en, this message translates to:
  /// **'Crop your photo'**
  String get dashCropYourPhoto;

  /// No description provided for @dashImageEditingCanceled.
  ///
  /// In en, this message translates to:
  /// **'Image editing canceled'**
  String get dashImageEditingCanceled;

  /// No description provided for @dashDragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag a photo to change the order'**
  String get dashDragToReorder;

  /// No description provided for @dashMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'MESSAGE'**
  String get dashMessageTitle;

  /// No description provided for @dashImageFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Image failed to load'**
  String get dashImageFailedToLoad;

  /// No description provided for @dashComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get dashComingSoon;

  /// No description provided for @dashCountdownComplete.
  ///
  /// In en, this message translates to:
  /// **'Countdown complete!'**
  String get dashCountdownComplete;

  /// No description provided for @dashWebSocketConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'WebSocket connection failed'**
  String get dashWebSocketConnectionFailed;

  /// No description provided for @dashWebSocketConnectError.
  ///
  /// In en, this message translates to:
  /// **'Error connecting to WebSocket'**
  String get dashWebSocketConnectError;

  /// No description provided for @dashGetHapperPlusUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Get Happer Plus for unlimited access'**
  String get dashGetHapperPlusUnlimited;

  /// No description provided for @dashPremiumOffersSoon.
  ///
  /// In en, this message translates to:
  /// **'Premium offers coming soon!'**
  String get dashPremiumOffersSoon;

  /// No description provided for @dashCreditAdsSoon.
  ///
  /// In en, this message translates to:
  /// **'Credit ads coming soon!'**
  String get dashCreditAdsSoon;

  /// No description provided for @dashPrizeTitle.
  ///
  /// In en, this message translates to:
  /// **'PRIZE'**
  String get dashPrizeTitle;

  /// No description provided for @dashStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get dashStartDate;

  /// No description provided for @dashHappDate.
  ///
  /// In en, this message translates to:
  /// **'Happ date'**
  String get dashHappDate;

  /// No description provided for @dashNoImageAvailable.
  ///
  /// In en, this message translates to:
  /// **'No image available'**
  String get dashNoImageAvailable;

  /// No description provided for @dashContestDateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Contest {label}: {date}'**
  String dashContestDateTooltip(String label, String date);

  /// No description provided for @dashAddedToWishlistUpper.
  ///
  /// In en, this message translates to:
  /// **'ADDED TO WISHLIST'**
  String get dashAddedToWishlistUpper;

  /// No description provided for @dashYouAlreadyHaveTheHand.
  ///
  /// In en, this message translates to:
  /// **'You already hold the lead'**
  String get dashYouAlreadyHaveTheHand;

  /// No description provided for @dashFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Feature coming soon'**
  String get dashFeatureComingSoon;

  /// No description provided for @dashIHaveTheHand.
  ///
  /// In en, this message translates to:
  /// **'I\'m in the lead'**
  String get dashIHaveTheHand;

  /// No description provided for @dashContestExpired.
  ///
  /// In en, this message translates to:
  /// **'Contest expired'**
  String get dashContestExpired;

  /// No description provided for @dashNoParticipants.
  ///
  /// In en, this message translates to:
  /// **'No participants in this contest'**
  String get dashNoParticipants;

  /// No description provided for @dashExpiredUpper.
  ///
  /// In en, this message translates to:
  /// **'EXPIRED'**
  String get dashExpiredUpper;

  /// No description provided for @dashConnectingToServer.
  ///
  /// In en, this message translates to:
  /// **'Connecting to server...'**
  String get dashConnectingToServer;

  /// No description provided for @dashGettingLatestProducts.
  ///
  /// In en, this message translates to:
  /// **'Getting the latest products'**
  String get dashGettingLatestProducts;

  /// No description provided for @dashCheckBackLater.
  ///
  /// In en, this message translates to:
  /// **'Check back later for new items'**
  String get dashCheckBackLater;

  /// No description provided for @dashRefreshUpper.
  ///
  /// In en, this message translates to:
  /// **'REFRESH'**
  String get dashRefreshUpper;

  /// No description provided for @dashNoImage.
  ///
  /// In en, this message translates to:
  /// **'No image'**
  String get dashNoImage;

  /// No description provided for @dashServerProblemLocalData.
  ///
  /// In en, this message translates to:
  /// **'Problem connecting to the server. Using local data.'**
  String get dashServerProblemLocalData;

  /// No description provided for @dashServerUnreachableCachedData.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the server. Using cached data.'**
  String get dashServerUnreachableCachedData;

  /// No description provided for @dashStartingSoonUpper.
  ///
  /// In en, this message translates to:
  /// **'STARTING SOON'**
  String get dashStartingSoonUpper;

  /// No description provided for @dashSoonUpper.
  ///
  /// In en, this message translates to:
  /// **'SOON'**
  String get dashSoonUpper;

  /// No description provided for @dashImageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable'**
  String get dashImageUnavailable;

  /// No description provided for @dashContestStartingSoon.
  ///
  /// In en, this message translates to:
  /// **'Contest starting soon!'**
  String get dashContestStartingSoon;

  /// No description provided for @dashContestEnded.
  ///
  /// In en, this message translates to:
  /// **'Contest has ended'**
  String get dashContestEnded;

  /// No description provided for @dashContestNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Contest not available'**
  String get dashContestNotAvailable;

  /// No description provided for @dashOpeningProductPage.
  ///
  /// In en, this message translates to:
  /// **'Opening product page...'**
  String get dashOpeningProductPage;

  /// No description provided for @dashProductAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'Product added to cart!'**
  String get dashProductAddedToCart;

  /// No description provided for @dashPreparingShare.
  ///
  /// In en, this message translates to:
  /// **'Preparing to share...'**
  String get dashPreparingShare;

  /// No description provided for @dashShareProductText.
  ///
  /// In en, this message translates to:
  /// **'{title}\n{brand}\nPrice: {price} €\nPromo price: {promoPrice} €\n\nDiscover this product on Happer!\n'**
  String dashShareProductText(
      String title, String brand, String price, String promoPrice);

  /// No description provided for @dashShareProductSubject.
  ///
  /// In en, this message translates to:
  /// **'Check out this product on Happer!'**
  String get dashShareProductSubject;

  /// No description provided for @dashShareError.
  ///
  /// In en, this message translates to:
  /// **'Error while sharing'**
  String get dashShareError;

  /// No description provided for @dashLoadingLatestUsers.
  ///
  /// In en, this message translates to:
  /// **'Loading latest users...'**
  String get dashLoadingLatestUsers;

  /// No description provided for @dashTapToRefreshUsers.
  ///
  /// In en, this message translates to:
  /// **'Tap to refresh user list'**
  String get dashTapToRefreshUsers;

  /// No description provided for @dashNoUsersYet.
  ///
  /// In en, this message translates to:
  /// **'No users yet.'**
  String get dashNoUsersYet;

  /// No description provided for @dashRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get dashRefresh;

  /// No description provided for @dashLoadingProductInfo.
  ///
  /// In en, this message translates to:
  /// **'Loading product information...'**
  String get dashLoadingProductInfo;

  /// No description provided for @dashStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get dashStatus;

  /// No description provided for @dashTotalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total users'**
  String get dashTotalUsers;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get orderCancelled;

  /// No description provided for @orderCancelledOn.
  ///
  /// In en, this message translates to:
  /// **'Cancelled on {date}'**
  String orderCancelledOn(String date);

  /// No description provided for @orderShippedOn.
  ///
  /// In en, this message translates to:
  /// **'Shipped on {date}'**
  String orderShippedOn(String date);

  /// No description provided for @orderConfirmedOn.
  ///
  /// In en, this message translates to:
  /// **'Confirmed on {date}'**
  String orderConfirmedOn(String date);

  /// No description provided for @orderNotShippedYet.
  ///
  /// In en, this message translates to:
  /// **'Not shipped yet'**
  String get orderNotShippedYet;

  /// No description provided for @orderCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get orderCancelOrder;

  /// No description provided for @orderCancelThisItem.
  ///
  /// In en, this message translates to:
  /// **'Cancel this item'**
  String get orderCancelThisItem;

  /// No description provided for @orderCancelConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel the order?'**
  String get orderCancelConfirmTitle;

  /// No description provided for @orderCancelConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This item will be cancelled. This action is permanent.'**
  String get orderCancelConfirmMessage;

  /// No description provided for @orderCancelConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, cancel'**
  String get orderCancelConfirmYes;

  /// No description provided for @orderTrackingLinkUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Tracking link not available yet'**
  String get orderTrackingLinkUnavailable;

  /// No description provided for @orderDeliveryTracking.
  ///
  /// In en, this message translates to:
  /// **'Delivery tracking'**
  String get orderDeliveryTracking;

  /// No description provided for @orderLookUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Look unavailable for this order'**
  String get orderLookUnavailable;

  /// No description provided for @orderLinkUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Link unavailable'**
  String get orderLinkUnavailable;

  /// No description provided for @orderInvoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get orderInvoice;

  /// No description provided for @orderInvoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'INVOICE'**
  String get orderInvoiceTitle;

  /// No description provided for @orderLoadingInvoice.
  ///
  /// In en, this message translates to:
  /// **'Loading invoice...'**
  String get orderLoadingInvoice;

  /// No description provided for @orderCouldNotLoadPage.
  ///
  /// In en, this message translates to:
  /// **'Could not load “{title}”.'**
  String orderCouldNotLoadPage(String title);

  /// No description provided for @orderCancelButton.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get orderCancelButton;

  /// No description provided for @orderReturnButton.
  ///
  /// In en, this message translates to:
  /// **'RETURN'**
  String get orderReturnButton;

  /// No description provided for @orderShippedBadge.
  ///
  /// In en, this message translates to:
  /// **'SHIPPED'**
  String get orderShippedBadge;

  /// No description provided for @orderReturnWindowPrefix.
  ///
  /// In en, this message translates to:
  /// **'You have '**
  String get orderReturnWindowPrefix;

  /// No description provided for @orderReturnWindowDays.
  ///
  /// In en, this message translates to:
  /// **'14 days'**
  String get orderReturnWindowDays;

  /// No description provided for @orderReturnWindowSuffix.
  ///
  /// In en, this message translates to:
  /// **' after receipt to make a return request'**
  String get orderReturnWindowSuffix;

  /// No description provided for @orderYourCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Your comment…'**
  String get orderYourCommentHint;

  /// No description provided for @orderReturnConditionsSoon.
  ///
  /// In en, this message translates to:
  /// **'Return conditions coming soon'**
  String get orderReturnConditionsSoon;

  /// No description provided for @orderTimeHourMinute.
  ///
  /// In en, this message translates to:
  /// **'{hour}:{minute}'**
  String orderTimeHourMinute(String hour, String minute);

  /// No description provided for @orderDateAtTime.
  ///
  /// In en, this message translates to:
  /// **'{date} at {time}'**
  String orderDateAtTime(String date, String time);

  /// No description provided for @orderReturnAddressValue.
  ///
  /// In en, this message translates to:
  /// **'Happer - {brand} Returns\n25 rue d\'Uzès, 75002 Paris, France'**
  String orderReturnAddressValue(String brand);

  /// No description provided for @orderSupportEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'Support request'**
  String get orderSupportEmailSubject;

  /// No description provided for @orderFaqUnavailable.
  ///
  /// In en, this message translates to:
  /// **'FAQ unavailable'**
  String get orderFaqUnavailable;

  /// No description provided for @orderFaqLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load the FAQ right now. Check your connection and try again.'**
  String get orderFaqLoadError;

  /// No description provided for @orderRetryButton.
  ///
  /// In en, this message translates to:
  /// **'TRY AGAIN'**
  String get orderRetryButton;

  /// No description provided for @orderSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size {size}'**
  String orderSizeLabel(String size);

  /// No description provided for @orderQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity {quantity}'**
  String orderQuantityLabel(int quantity);

  /// No description provided for @orderWinnerYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get orderWinnerYou;

  /// No description provided for @profileMySelections.
  ///
  /// In en, this message translates to:
  /// **'My Selections'**
  String get profileMySelections;

  /// No description provided for @profileGameContestComingSoon.
  ///
  /// In en, this message translates to:
  /// **'The game contest is coming soon'**
  String get profileGameContestComingSoon;

  /// No description provided for @profileInvalidCodeTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Invalid code. Please try again.'**
  String get profileInvalidCodeTryAgain;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccess;

  /// No description provided for @profilePleaseEnterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password'**
  String get profilePleaseEnterCurrentPassword;

  /// No description provided for @profilePleaseEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get profilePleaseEnterNewPassword;

  /// No description provided for @profilePasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {count} characters'**
  String profilePasswordMinLength(int count);

  /// No description provided for @profilePleaseConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your new password'**
  String get profilePleaseConfirmNewPassword;

  /// No description provided for @profileMyShares.
  ///
  /// In en, this message translates to:
  /// **'My Shares'**
  String get profileMyShares;

  /// No description provided for @profileWonProducts.
  ///
  /// In en, this message translates to:
  /// **'Won Products'**
  String get profileWonProducts;

  /// No description provided for @profileWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get profileWishlist;

  /// No description provided for @profileMyPurchases.
  ///
  /// In en, this message translates to:
  /// **'My Purchases'**
  String get profileMyPurchases;

  /// No description provided for @profileYourPromoCode.
  ///
  /// In en, this message translates to:
  /// **'YOUR PROMO CODE'**
  String get profileYourPromoCode;

  /// No description provided for @profileYourPromoCodes.
  ///
  /// In en, this message translates to:
  /// **'YOUR PROMO CODES'**
  String get profileYourPromoCodes;

  /// No description provided for @profileNoPromoCodes.
  ///
  /// In en, this message translates to:
  /// **'No promo codes available'**
  String get profileNoPromoCodes;

  /// No description provided for @profileCreditsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Credits'**
  String profileCreditsCount(int count);

  /// No description provided for @profileTapToApply.
  ///
  /// In en, this message translates to:
  /// **'Tap to apply'**
  String get profileTapToApply;

  /// No description provided for @profileDeleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent. All your data will be deleted and cannot be recovered.'**
  String get profileDeleteAccountWarning;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to log out?'**
  String get profileLogoutConfirm;

  /// No description provided for @profileCouldNotOpenInstagram.
  ///
  /// In en, this message translates to:
  /// **'Could not open Instagram'**
  String get profileCouldNotOpenInstagram;

  /// No description provided for @profileShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get profileShare;

  /// No description provided for @profileLookTab.
  ///
  /// In en, this message translates to:
  /// **'Look'**
  String get profileLookTab;

  /// No description provided for @profileAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get profileAdd;

  /// No description provided for @profileNoAddress.
  ///
  /// In en, this message translates to:
  /// **'No address'**
  String get profileNoAddress;

  /// No description provided for @profileDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get profileDefault;

  /// No description provided for @profileDefaultAddress.
  ///
  /// In en, this message translates to:
  /// **'Default address'**
  String get profileDefaultAddress;

  /// No description provided for @profileDefaultAddressDesc.
  ///
  /// In en, this message translates to:
  /// **'Used automatically at checkout'**
  String get profileDefaultAddressDesc;

  /// No description provided for @profileGenderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get profileGenderOther;

  /// No description provided for @profileGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get profileGender;

  /// No description provided for @profileBio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get profileBio;

  /// No description provided for @profileStreetAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get profileStreetAddress;

  /// No description provided for @profileErrorLoadingWishlist.
  ///
  /// In en, this message translates to:
  /// **'Error loading wishlist items'**
  String get profileErrorLoadingWishlist;

  /// No description provided for @profileWishlistEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your wishlist is empty'**
  String get profileWishlistEmpty;

  /// No description provided for @profileWishlistEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Items you add to your wishlist will appear here'**
  String get profileWishlistEmptyDesc;

  /// No description provided for @profileAlreadyInWishlist.
  ///
  /// In en, this message translates to:
  /// **'Item is already in your wishlist'**
  String get profileAlreadyInWishlist;

  /// No description provided for @profileNoWonProducts.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t won any products yet'**
  String get profileNoWonProducts;

  /// No description provided for @profileNoWonProductsDesc.
  ///
  /// In en, this message translates to:
  /// **'Participate in contests to win amazing products'**
  String get profileNoWonProductsDesc;

  /// No description provided for @profileCollected.
  ///
  /// In en, this message translates to:
  /// **'COLLECTED'**
  String get profileCollected;

  /// No description provided for @networkNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get networkNoInternet;

  /// No description provided for @networkTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again.'**
  String get networkTimeout;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
