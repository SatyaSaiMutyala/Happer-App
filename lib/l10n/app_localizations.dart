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
  /// **'1 SPONSORSHIP = 50 CREDITS'**
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
  /// **'My Looks'**
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
  /// **'SHARE'**
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
