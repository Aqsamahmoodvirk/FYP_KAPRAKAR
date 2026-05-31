import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur')
  ];

  /// No description provided for @num45.
  ///
  /// In en, this message translates to:
  /// **'4.5'**
  String get num45;

  /// No description provided for @activeOrder.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE ORDER'**
  String get activeOrder;

  /// No description provided for @aiStyleSuggestions.
  ///
  /// In en, this message translates to:
  /// **'AI Style Suggestions'**
  String get aiStyleSuggestions;

  /// No description provided for @aboutYou.
  ///
  /// In en, this message translates to:
  /// **'About You'**
  String get aboutYou;

  /// No description provided for @acceptingNewOrders.
  ///
  /// In en, this message translates to:
  /// **'Accepting New Orders'**
  String get acceptingNewOrders;

  /// No description provided for @accessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get accessories;

  /// No description provided for @accessoriesEstimation.
  ///
  /// In en, this message translates to:
  /// **'Accessories Estimation'**
  String get accessoriesEstimation;

  /// No description provided for @activeOrders.
  ///
  /// In en, this message translates to:
  /// **'Active Orders'**
  String get activeOrders;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @alignTheDressWithinTheOutlines.
  ///
  /// In en, this message translates to:
  /// **'Align the dress within the outlines for optimal 3D Avatar Rendering.'**
  String get alignTheDressWithinTheOutlines;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAnAccount;

  /// No description provided for @areYouSureYouWantToLogOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get areYouSureYouWantToLogOut;

  /// No description provided for @armhole.
  ///
  /// In en, this message translates to:
  /// **'Armhole'**
  String get armhole;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get availableBalance;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @black.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get black;

  /// No description provided for @blue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get blue;

  /// No description provided for @bookAService.
  ///
  /// In en, this message translates to:
  /// **'Book a Service'**
  String get bookAService;

  /// No description provided for @brieflyDescribeYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Briefly describe your experience...'**
  String get brieflyDescribeYourExperience;

  /// No description provided for @buttonsLacesMotifsEtc.
  ///
  /// In en, this message translates to:
  /// **'Buttons, laces, motifs, etc.'**
  String get buttonsLacesMotifsEtc;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @captureImage.
  ///
  /// In en, this message translates to:
  /// **'Capture Image'**
  String get captureImage;

  /// No description provided for @casual.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get casual;

  /// No description provided for @changeCity.
  ///
  /// In en, this message translates to:
  /// **'Change City'**
  String get changeCity;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Photo'**
  String get changeProfilePhoto;

  /// No description provided for @chestBust.
  ///
  /// In en, this message translates to:
  /// **'Chest / Bust'**
  String get chestBust;

  /// No description provided for @chiffon.
  ///
  /// In en, this message translates to:
  /// **'Chiffon'**
  String get chiffon;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @chooseYourPreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get chooseYourPreferredLanguage;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @completeTheseStepsToCustomizeY.
  ///
  /// In en, this message translates to:
  /// **'Complete these steps to customize your new outfit.'**
  String get completeTheseStepsToCustomizeY;

  /// No description provided for @confirmPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Place Order'**
  String get confirmPlaceOrder;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @continueAs.
  ///
  /// In en, this message translates to:
  /// **'Continue as'**
  String get continueAs;

  /// No description provided for @cotton.
  ///
  /// In en, this message translates to:
  /// **'Cotton'**
  String get cotton;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @customerChats.
  ///
  /// In en, this message translates to:
  /// **'Customer Chats'**
  String get customerChats;

  /// No description provided for @cutting.
  ///
  /// In en, this message translates to:
  /// **'Cutting'**
  String get cutting;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @describeYourDesiredOutfit.
  ///
  /// In en, this message translates to:
  /// **'Describe Your Desired Outfit'**
  String get describeYourDesiredOutfit;

  /// No description provided for @designYourOutfit.
  ///
  /// In en, this message translates to:
  /// **'Design Your Outfit'**
  String get designYourOutfit;

  /// No description provided for @don.
  ///
  /// In en, this message translates to:
  /// **'Don'**
  String get don;

  /// No description provided for @dressIsCurrentlyBeingStitched.
  ///
  /// In en, this message translates to:
  /// **'Dress is currently being stitched.'**
  String get dressIsCurrentlyBeingStitched;

  /// No description provided for @dressIsReadyRequiresFinalPhoto.
  ///
  /// In en, this message translates to:
  /// **'Dress is ready. Requires final photo before delivery.'**
  String get dressIsReadyRequiresFinalPhoto;

  /// No description provided for @eid.
  ///
  /// In en, this message translates to:
  /// **'Eid'**
  String get eid;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailPhone.
  ///
  /// In en, this message translates to:
  /// **'Email / Phone'**
  String get emailPhone;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @enterYourDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter your details'**
  String get enterYourDetails;

  /// No description provided for @enterYourEmailOrPhoneNumberToR.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or phone number to receive an OTP.'**
  String get enterYourEmailOrPhoneNumberToR;

  /// No description provided for @errorLoadingChat.
  ///
  /// In en, this message translates to:
  /// **'Error loading chat'**
  String get errorLoadingChat;

  /// No description provided for @expertInShalwarKameez.
  ///
  /// In en, this message translates to:
  /// **'Expert in Shalwar Kameez'**
  String get expertInShalwarKameez;

  /// No description provided for @expertisePricing.
  ///
  /// In en, this message translates to:
  /// **'Expertise & Pricing'**
  String get expertisePricing;

  /// No description provided for @exploreAccessoryVendors.
  ///
  /// In en, this message translates to:
  /// **'Explore Accessory Vendors'**
  String get exploreAccessoryVendors;

  /// No description provided for @fabricDesignNotes.
  ///
  /// In en, this message translates to:
  /// **'Fabric & Design Notes'**
  String get fabricDesignNotes;

  /// No description provided for @fabricHasBeenMeasuredAndCut.
  ///
  /// In en, this message translates to:
  /// **'Fabric has been measured and cut.'**
  String get fabricHasBeenMeasuredAndCut;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @finalProductCapture.
  ///
  /// In en, this message translates to:
  /// **'Final Product Capture'**
  String get finalProductCapture;

  /// No description provided for @findATailor.
  ///
  /// In en, this message translates to:
  /// **'Find a Tailor'**
  String get findATailor;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @forgotPassword1.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword1;

  /// No description provided for @formal.
  ///
  /// In en, this message translates to:
  /// **'Formal'**
  String get formal;

  /// No description provided for @frequentlyAskedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get frequentlyAskedQuestions;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @getAiSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Get AI Suggestions'**
  String get getAiSuggestions;

  /// No description provided for @getAiPoweredPakistaniFashionSu.
  ///
  /// In en, this message translates to:
  /// **'Get AI-powered Pakistani fashion suggestions based on occasion, season, fabric, and color.'**
  String get getAiPoweredPakistaniFashionSu;

  /// No description provided for @green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get green;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @hip.
  ///
  /// In en, this message translates to:
  /// **'Hip'**
  String get hip;

  /// No description provided for @howToMeasure.
  ///
  /// In en, this message translates to:
  /// **'How to Measure'**
  String get howToMeasure;

  /// No description provided for @howWasYourStitchingExperience.
  ///
  /// In en, this message translates to:
  /// **'How was your stitching experience?'**
  String get howWasYourStitchingExperience;

  /// No description provided for @inboxRequests.
  ///
  /// In en, this message translates to:
  /// **'Inbox Requests'**
  String get inboxRequests;

  /// No description provided for @joinKaprakar.
  ///
  /// In en, this message translates to:
  /// **'Join KapraKar'**
  String get joinKaprakar;

  /// No description provided for @kaprakarHub.
  ///
  /// In en, this message translates to:
  /// **'Customer Dashboard'**
  String get kaprakarHub;

  /// No description provided for @lastOrder.
  ///
  /// In en, this message translates to:
  /// **'LAST ORDER'**
  String get lastOrder;

  /// No description provided for @lawn.
  ///
  /// In en, this message translates to:
  /// **'Lawn'**
  String get lawn;

  /// No description provided for @locationCity.
  ///
  /// In en, this message translates to:
  /// **'Location / City'**
  String get locationCity;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @manageProfile.
  ///
  /// In en, this message translates to:
  /// **'Manage Profile'**
  String get manageProfile;

  /// No description provided for @maroon.
  ///
  /// In en, this message translates to:
  /// **'Maroon'**
  String get maroon;

  /// No description provided for @measurementGuide.
  ///
  /// In en, this message translates to:
  /// **'Measurement Guide'**
  String get measurementGuide;

  /// No description provided for @measurements.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get measurements;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @myWallet.
  ///
  /// In en, this message translates to:
  /// **'My Wallet'**
  String get myWallet;

  /// No description provided for @nameAndPhoneAreRequired.
  ///
  /// In en, this message translates to:
  /// **'Name and Phone are required'**
  String get nameAndPhoneAreRequired;

  /// No description provided for @neck.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get neck;

  /// No description provided for @needAccessoriesForThisDress.
  ///
  /// In en, this message translates to:
  /// **'Need accessories for this dress?'**
  String get needAccessoriesForThisDress;

  /// No description provided for @needMeasurementGuidance.
  ///
  /// In en, this message translates to:
  /// **'Need measurement guidance?'**
  String get needMeasurementGuidance;

  /// No description provided for @newCreation.
  ///
  /// In en, this message translates to:
  /// **'New Creation'**
  String get newCreation;

  /// No description provided for @newOrder.
  ///
  /// In en, this message translates to:
  /// **'New Order'**
  String get newOrder;

  /// No description provided for @noActiveOrderFound.
  ///
  /// In en, this message translates to:
  /// **'No active order found.'**
  String get noActiveOrderFound;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No history yet.'**
  String get noHistoryYet;

  /// No description provided for @noMatchingStylesFound.
  ///
  /// In en, this message translates to:
  /// **'No matching styles found.'**
  String get noMatchingStylesFound;

  /// No description provided for @noNewNotifications.
  ///
  /// In en, this message translates to:
  /// **'No new notifications'**
  String get noNewNotifications;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// No description provided for @noOrdersYet1.
  ///
  /// In en, this message translates to:
  /// **'No orders yet.'**
  String get noOrdersYet1;

  /// No description provided for @notificationsHub.
  ///
  /// In en, this message translates to:
  /// **'Notifications Hub'**
  String get notificationsHub;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get orderHistory;

  /// No description provided for @orderPlacedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order Placed Successfully!'**
  String get orderPlacedSuccessfully;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @organza.
  ///
  /// In en, this message translates to:
  /// **'Organza'**
  String get organza;

  /// No description provided for @pkr1500.
  ///
  /// In en, this message translates to:
  /// **'PKR 1,500'**
  String get pkr1500;

  /// No description provided for @pkr15001.
  ///
  /// In en, this message translates to:
  /// **'PKR 1,500+'**
  String get pkr15001;

  /// No description provided for @party.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get party;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @paymentDetails.
  ///
  /// In en, this message translates to:
  /// **'Payment Details'**
  String get paymentDetails;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @photoUploadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Photo uploaded successfully!'**
  String get photoUploadedSuccessfully;

  /// No description provided for @pink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get pink;

  /// No description provided for @pinterestInspiration.
  ///
  /// In en, this message translates to:
  /// **'Pinterest Inspiration:'**
  String get pinterestInspiration;

  /// No description provided for @pleaseProvideAccurateMeasureme.
  ///
  /// In en, this message translates to:
  /// **'Please provide accurate measurements in inches for the best fit.'**
  String get pleaseProvideAccurateMeasureme;

  /// No description provided for @portfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get portfolio;

  /// No description provided for @previewDress.
  ///
  /// In en, this message translates to:
  /// **'Preview Dress'**
  String get previewDress;

  /// No description provided for @previewStitchedDress.
  ///
  /// In en, this message translates to:
  /// **'Preview Stitched Dress'**
  String get previewStitchedDress;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profileSettings;

  /// No description provided for @profileSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile saved successfully!'**
  String get profileSavedSuccessfully;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @queueSummary.
  ///
  /// In en, this message translates to:
  /// **'Queue Summary'**
  String get queueSummary;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @rateYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Rate your experience'**
  String get rateYourExperience;

  /// No description provided for @readyForTrial.
  ///
  /// In en, this message translates to:
  /// **'Ready for Trial'**
  String get readyForTrial;

  /// No description provided for @recentHistory.
  ///
  /// In en, this message translates to:
  /// **'Recent History'**
  String get recentHistory;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @requestHistory.
  ///
  /// In en, this message translates to:
  /// **'Request History'**
  String get requestHistory;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @reviewAccept.
  ///
  /// In en, this message translates to:
  /// **'Review & Accept'**
  String get reviewAccept;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveContinue.
  ///
  /// In en, this message translates to:
  /// **'Save & Continue'**
  String get saveContinue;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// No description provided for @selectFabric.
  ///
  /// In en, this message translates to:
  /// **'Select Fabric'**
  String get selectFabric;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @selectOccasion.
  ///
  /// In en, this message translates to:
  /// **'Select Occasion'**
  String get selectOccasion;

  /// No description provided for @selectSeason.
  ///
  /// In en, this message translates to:
  /// **'Select Season'**
  String get selectSeason;

  /// No description provided for @selectWhatYouSewAndSetYourStar.
  ///
  /// In en, this message translates to:
  /// **'Select what you sew and set your starting prices.'**
  String get selectWhatYouSewAndSetYourStar;

  /// No description provided for @selectedTailor.
  ///
  /// In en, this message translates to:
  /// **'Selected Tailor'**
  String get selectedTailor;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @shareYourDetailedExperienceOpt.
  ///
  /// In en, this message translates to:
  /// **'Share your detailed experience (optional)...'**
  String get shareYourDetailedExperienceOpt;

  /// No description provided for @shirtKameezLength.
  ///
  /// In en, this message translates to:
  /// **'Shirt/Kameez Length'**
  String get shirtKameezLength;

  /// No description provided for @shopName.
  ///
  /// In en, this message translates to:
  /// **'Shop Name'**
  String get shopName;

  /// No description provided for @shopSetup.
  ///
  /// In en, this message translates to:
  /// **'Shop Setup'**
  String get shopSetup;

  /// No description provided for @shoulder.
  ///
  /// In en, this message translates to:
  /// **'Shoulder'**
  String get shoulder;

  /// No description provided for @showcaseYourWork.
  ///
  /// In en, this message translates to:
  /// **'Showcase your work'**
  String get showcaseYourWork;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signInToContinueYourTailoringJ.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your tailoring journey.'**
  String get signInToContinueYourTailoringJ;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @sleeveLength.
  ///
  /// In en, this message translates to:
  /// **'Sleeve Length'**
  String get sleeveLength;

  /// No description provided for @startNewOrder.
  ///
  /// In en, this message translates to:
  /// **'Start New Order'**
  String get startNewOrder;

  /// No description provided for @startANewStitchingJourneyWeGui.
  ///
  /// In en, this message translates to:
  /// **'Start a new stitching journey. We guide you through measurements, style selection, and matching with top tailors.'**
  String get startANewStitchingJourneyWeGui;

  /// No description provided for @startYourCustomFashionJourney.
  ///
  /// In en, this message translates to:
  /// **'Start your custom fashion journey.'**
  String get startYourCustomFashionJourney;

  /// No description provided for @startingPricePkr.
  ///
  /// In en, this message translates to:
  /// **'Starting Price (PKR)'**
  String get startingPricePkr;

  /// No description provided for @stitching.
  ///
  /// In en, this message translates to:
  /// **'Stitching'**
  String get stitching;

  /// No description provided for @stitchingCharges.
  ///
  /// In en, this message translates to:
  /// **'Stitching Charges'**
  String get stitchingCharges;

  /// No description provided for @stitchingProcess.
  ///
  /// In en, this message translates to:
  /// **'Stitching Process'**
  String get stitchingProcess;

  /// No description provided for @submitFeedback.
  ///
  /// In en, this message translates to:
  /// **'Submit Feedback'**
  String get submitFeedback;

  /// No description provided for @summer.
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get summer;

  /// No description provided for @tbd.
  ///
  /// In en, this message translates to:
  /// **'TBD'**
  String get tbd;

  /// No description provided for @tailor.
  ///
  /// In en, this message translates to:
  /// **'Tailor'**
  String get tailor;

  /// No description provided for @tailorDashboard.
  ///
  /// In en, this message translates to:
  /// **'Tailor Dashboard'**
  String get tailorDashboard;

  /// No description provided for @takeAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takeAPhoto;

  /// No description provided for @tellUsAboutYourShop.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your shop'**
  String get tellUsAboutYourShop;

  /// No description provided for @thankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank You!'**
  String get thankYou;

  /// No description provided for @thisInformationWillBeVisibleTo.
  ///
  /// In en, this message translates to:
  /// **'This information will be visible to customers.'**
  String get thisInformationWillBeVisibleTo;

  /// No description provided for @totalEarningsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Total Earnings (This Month)'**
  String get totalEarningsThisMonth;

  /// No description provided for @totalEstimated.
  ///
  /// In en, this message translates to:
  /// **'Total Estimated'**
  String get totalEstimated;

  /// No description provided for @trackMyOrders.
  ///
  /// In en, this message translates to:
  /// **'Track My Orders'**
  String get trackMyOrders;

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track Order'**
  String get trackOrder;

  /// No description provided for @trouserShalwarLength.
  ///
  /// In en, this message translates to:
  /// **'Trouser/Shalwar Length'**
  String get trouserShalwarLength;

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessage;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @updateStatus.
  ///
  /// In en, this message translates to:
  /// **'Update Status'**
  String get updateStatus;

  /// No description provided for @uploadPhotosOfYourBestStitched.
  ///
  /// In en, this message translates to:
  /// **'Upload photos of your best stitched dresses.'**
  String get uploadPhotosOfYourBestStitched;

  /// No description provided for @useAMeasuringTapeAndKeepItSnug.
  ///
  /// In en, this message translates to:
  /// **'Use a measuring tape and keep it snug but not tight.'**
  String get useAMeasuringTapeAndKeepItSnug;

  /// No description provided for @velvet.
  ///
  /// In en, this message translates to:
  /// **'Velvet'**
  String get velvet;

  /// No description provided for @viewCatalog.
  ///
  /// In en, this message translates to:
  /// **'View Catalog'**
  String get viewCatalog;

  /// No description provided for @waist.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get waist;

  /// No description provided for @wedding.
  ///
  /// In en, this message translates to:
  /// **'Wedding'**
  String get wedding;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @white.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get white;

  /// No description provided for @winter.
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get winter;

  /// No description provided for @withdrawToBank.
  ///
  /// In en, this message translates to:
  /// **'Withdraw to Bank'**
  String get withdrawToBank;

  /// No description provided for @youWillSeeYourPastAlertsHere.
  ///
  /// In en, this message translates to:
  /// **'You will see your past alerts here.'**
  String get youWillSeeYourPastAlertsHere;

  /// No description provided for @yourFeedbackHelpsUsImproveOurS.
  ///
  /// In en, this message translates to:
  /// **'Your feedback helps us improve our services.'**
  String get yourFeedbackHelpsUsImproveOurS;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @aboutKapraKar.
  ///
  /// In en, this message translates to:
  /// **'About KapraKar'**
  String get aboutKapraKar;

  /// No description provided for @termsOfServiceContent.
  ///
  /// In en, this message translates to:
  /// **'Welcome to our platform. These Terms of Service govern your use of our application for connecting customers and service providers.\n\n1. Acceptance of Terms: By accessing and using our application, you accept and agree to be bound by the terms and provision of this agreement.\n\n2. User Conduct: All users are expected to act respectfully, maintain professional communication, and uphold the integrity of the platform.\n\n3. Account Security: You are responsible for maintaining the confidentiality of your account details and password.\n\n4. Service Transactions: Any agreements, payments, and deliverables discussed are strictly between the involved parties; the platform provides connection but is not liable for outcomes.\n\n5. Modifications: We reserve the right to modify these terms at any time. Continued use of the app signifies acceptance of any changes.'**
  String get termsOfServiceContent;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'Your privacy is our priority. This Privacy Policy explains how we collect, use, and protect your information.\n\n1. Information Collection: We collect essential data such as name, contact details, and usage metrics to provide and improve our services.\n\n2. Data Usage: Your information is primarily used to facilitate connections between users, manage accounts, and offer customer support.\n\n3. Data Protection: We employ robust security measures to protect your personal information against unauthorized access or disclosure.\n\n4. Third-Party Sharing: We do not sell or rent your personal data to third parties. Data may only be shared with verified partners when necessary for core functionality.\n\n5. Your Rights: You have the right to access, update, or request the deletion of your personal data at any time by contacting support.'**
  String get privacyPolicyContent;

  /// No description provided for @upperBody.
  ///
  /// In en, this message translates to:
  /// **'Upper Body'**
  String get upperBody;

  /// No description provided for @lowerBody.
  ///
  /// In en, this message translates to:
  /// **'Lower Body'**
  String get lowerBody;

  /// No description provided for @sleevesAndLengths.
  ///
  /// In en, this message translates to:
  /// **'Sleeves & Lengths'**
  String get sleevesAndLengths;

  /// No description provided for @eg14.
  ///
  /// In en, this message translates to:
  /// **'e.g. 14'**
  String get eg14;

  /// No description provided for @eg36.
  ///
  /// In en, this message translates to:
  /// **'e.g. 36'**
  String get eg36;

  /// No description provided for @eg30.
  ///
  /// In en, this message translates to:
  /// **'e.g. 30'**
  String get eg30;

  /// No description provided for @eg38.
  ///
  /// In en, this message translates to:
  /// **'e.g. 38'**
  String get eg38;

  /// No description provided for @eg15.
  ///
  /// In en, this message translates to:
  /// **'e.g. 15'**
  String get eg15;

  /// No description provided for @eg22.
  ///
  /// In en, this message translates to:
  /// **'e.g. 22'**
  String get eg22;

  /// No description provided for @eg16.
  ///
  /// In en, this message translates to:
  /// **'e.g. 16'**
  String get eg16;

  /// No description provided for @measurementGuideInstruction.
  ///
  /// In en, this message translates to:
  /// **'Use a measuring tape and keep it snug but not tight. It\'s best to wear thin clothes while measuring.'**
  String get measurementGuideInstruction;

  /// No description provided for @shoulderGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Shoulder'**
  String get shoulderGuideTitle;

  /// No description provided for @shoulderGuideDesc.
  ///
  /// In en, this message translates to:
  /// **'Measure from one shoulder tip to the other across the back.'**
  String get shoulderGuideDesc;

  /// No description provided for @chestGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Chest / Bust'**
  String get chestGuideTitle;

  /// No description provided for @chestGuideDesc.
  ///
  /// In en, this message translates to:
  /// **'Measure around the fullest part of the chest/bust.'**
  String get chestGuideDesc;

  /// No description provided for @waistGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get waistGuideTitle;

  /// No description provided for @waistGuideDesc.
  ///
  /// In en, this message translates to:
  /// **'Measure around the natural waistline.'**
  String get waistGuideDesc;

  /// No description provided for @hipGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Hip'**
  String get hipGuideTitle;

  /// No description provided for @hipGuideDesc.
  ///
  /// In en, this message translates to:
  /// **'Measure around the fullest part of your hips.'**
  String get hipGuideDesc;

  /// No description provided for @neckGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get neckGuideTitle;

  /// No description provided for @neckGuideDesc.
  ///
  /// In en, this message translates to:
  /// **'Measure around the base of your neck, keeping the tape comfortably loose.'**
  String get neckGuideDesc;

  /// No description provided for @sleeveGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleeve Length'**
  String get sleeveGuideTitle;

  /// No description provided for @sleeveGuideDesc.
  ///
  /// In en, this message translates to:
  /// **'Measure from the shoulder seam down to your desired sleeve end.'**
  String get sleeveGuideDesc;

  /// No description provided for @armholeGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Armhole'**
  String get armholeGuideTitle;

  /// No description provided for @armholeGuideDesc.
  ///
  /// In en, this message translates to:
  /// **'Measure from the top of the shoulder down around the armpit.'**
  String get armholeGuideDesc;

  /// No description provided for @kameezGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Shirt/Kameez Length'**
  String get kameezGuideTitle;

  /// No description provided for @kameezGuideDesc.
  ///
  /// In en, this message translates to:
  /// **'Measure from the top of the shoulder down to your desired hemline.'**
  String get kameezGuideDesc;

  /// No description provided for @trouserGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Trouser/Shalwar Length'**
  String get trouserGuideTitle;

  /// No description provided for @trouserGuideDesc.
  ///
  /// In en, this message translates to:
  /// **'Measure from your natural waistline down to the desired ankle length.'**
  String get trouserGuideDesc;

  /// No description provided for @faqHowToOrder.
  ///
  /// In en, this message translates to:
  /// **'How to order?'**
  String get faqHowToOrder;

  /// No description provided for @faqHowToOrderAnswer.
  ///
  /// In en, this message translates to:
  /// **'To place an order, go to the Home screen, select your desired service, and follow the steps to book a tailor.'**
  String get faqHowToOrderAnswer;

  /// No description provided for @faqMeasurementGuide.
  ///
  /// In en, this message translates to:
  /// **'Measurement guide?'**
  String get faqMeasurementGuide;

  /// No description provided for @faqMeasurementGuideAnswer.
  ///
  /// In en, this message translates to:
  /// **'We provide a detailed measurement guide and the option to input your custom measurements in your profile or during the booking process.'**
  String get faqMeasurementGuideAnswer;

  /// No description provided for @faqPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment methods?'**
  String get faqPaymentMethods;

  /// No description provided for @faqPaymentMethodsAnswer.
  ///
  /// In en, this message translates to:
  /// **'We accept major credit/debit cards, mobile wallets, and cash on delivery.'**
  String get faqPaymentMethodsAnswer;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupport;

  /// No description provided for @whatsappUs.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Us'**
  String get whatsappUs;

  /// No description provided for @callUs.
  ///
  /// In en, this message translates to:
  /// **'Call Us'**
  String get callUs;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @dontHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAnAccount;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @enterYourPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone'**
  String get enterYourPhone;

  /// No description provided for @createAPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get createAPassword;

  /// No description provided for @step.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get step;

  /// No description provided for @completedReady.
  ///
  /// In en, this message translates to:
  /// **'Completed - Ready'**
  String get completedReady;

  /// No description provided for @requiredToProceed.
  ///
  /// In en, this message translates to:
  /// **'Required to proceed'**
  String get requiredToProceed;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @optionalGetFabricStyleIdeas.
  ///
  /// In en, this message translates to:
  /// **'Optional: Get fabric & style ideas'**
  String get optionalGetFabricStyleIdeas;

  /// No description provided for @findTailor.
  ///
  /// In en, this message translates to:
  /// **'Find Tailor'**
  String get findTailor;

  /// No description provided for @tailorSelected.
  ///
  /// In en, this message translates to:
  /// **'Tailor Selected'**
  String get tailorSelected;

  /// No description provided for @chooseATailorForYourOrder.
  ///
  /// In en, this message translates to:
  /// **'Choose a tailor for your order'**
  String get chooseATailorForYourOrder;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order Placed'**
  String get orderPlaced;

  /// No description provided for @finalizeMeasurementsPayment.
  ///
  /// In en, this message translates to:
  /// **'Finalize measurements & payment'**
  String get finalizeMeasurementsPayment;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @choosePhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose a Photo'**
  String get choosePhotoLabel;

  /// No description provided for @takePhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhotoLabel;

  /// No description provided for @chooseFromGalleryLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGalleryLabel;

  /// No description provided for @permissionDeniedLabel.
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Please allow access in settings.'**
  String get permissionDeniedLabel;

  /// No description provided for @changePhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhotoLabel;

  /// No description provided for @uploadFailedLabel.
  ///
  /// In en, this message translates to:
  /// **'Upload failed. Please try again.'**
  String get uploadFailedLabel;

  /// No description provided for @uploadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploadingLabel;

  /// No description provided for @avatarPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'3D Avatar Preview'**
  String get avatarPreviewTitle;

  /// No description provided for @viewOriginalPhoto.
  ///
  /// In en, this message translates to:
  /// **'View Original Photo'**
  String get viewOriginalPhoto;

  /// No description provided for @satisfiedButton.
  ///
  /// In en, this message translates to:
  /// **'I am Satisfied'**
  String get satisfiedButton;

  /// No description provided for @requestChangesButton.
  ///
  /// In en, this message translates to:
  /// **'Request Changes'**
  String get requestChangesButton;

  /// No description provided for @orderReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Review'**
  String get orderReviewTitle;

  /// No description provided for @tailorNotUploadedYet.
  ///
  /// In en, this message translates to:
  /// **'Tailor has not uploaded the photo yet.'**
  String get tailorNotUploadedYet;

  /// No description provided for @viewOn3DAvatar.
  ///
  /// In en, this message translates to:
  /// **'View on 3D Avatar'**
  String get viewOn3DAvatar;

  /// No description provided for @revisionSent.
  ///
  /// In en, this message translates to:
  /// **'Revision request sent successfully.'**
  String get revisionSent;

  /// No description provided for @changeRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Changes'**
  String get changeRequestTitle;

  /// No description provided for @changeCategory.
  ///
  /// In en, this message translates to:
  /// **'Change Category'**
  String get changeCategory;

  /// No description provided for @describeChanges.
  ///
  /// In en, this message translates to:
  /// **'Describe the changes needed'**
  String get describeChanges;

  /// No description provided for @submitRevision.
  ///
  /// In en, this message translates to:
  /// **'Submit Revision Request'**
  String get submitRevision;

  /// No description provided for @uploadRevisedPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Revised Photo'**
  String get uploadRevisedPhoto;

  /// No description provided for @revisionInboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Revision Inbox'**
  String get revisionInboxTitle;

  /// No description provided for @orderCompleteCustomer.
  ///
  /// In en, this message translates to:
  /// **'Order Completed'**
  String get orderCompleteCustomer;

  /// No description provided for @rateExperience.
  ///
  /// In en, this message translates to:
  /// **'Rate your experience with the tailor'**
  String get rateExperience;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @orderCompleteTailor.
  ///
  /// In en, this message translates to:
  /// **'Order Completed Successfully'**
  String get orderCompleteTailor;

  /// No description provided for @viewWallet.
  ///
  /// In en, this message translates to:
  /// **'View Wallet'**
  String get viewWallet;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @noStylesFound.
  ///
  /// In en, this message translates to:
  /// **'No matching styles found for your fabric'**
  String get noStylesFound;

  /// No description provided for @tryDifferentOptions.
  ///
  /// In en, this message translates to:
  /// **'Try Different Options'**
  String get tryDifferentOptions;

  /// No description provided for @aiResultTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Suggestion Result'**
  String get aiResultTitle;

  /// No description provided for @viewInspiration.
  ///
  /// In en, this message translates to:
  /// **'View Inspiration'**
  String get viewInspiration;

  /// No description provided for @selectStyle.
  ///
  /// In en, this message translates to:
  /// **'Select This Style'**
  String get selectStyle;

  /// No description provided for @generatingPreview.
  ///
  /// In en, this message translates to:
  /// **'Generating preview...'**
  String get generatingPreview;

  /// No description provided for @selectBodyType.
  ///
  /// In en, this message translates to:
  /// **'Select Body Type'**
  String get selectBodyType;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ur': return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
