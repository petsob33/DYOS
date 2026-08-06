import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('cs'),
    Locale('en'),
  ];

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @dataScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Data & Analytics'**
  String get dataScreenTitle;

  /// No description provided for @dataScreenError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String dataScreenError(String error);

  /// No description provided for @dataScreenHeading.
  ///
  /// In en, this message translates to:
  /// **'Relationship Insights'**
  String get dataScreenHeading;

  /// No description provided for @dataScreenSubheading.
  ///
  /// In en, this message translates to:
  /// **'Track patterns and trends in your relationship'**
  String get dataScreenSubheading;

  /// No description provided for @dataScreenTotalCountTitle.
  ///
  /// In en, this message translates to:
  /// **'Total Count'**
  String get dataScreenTotalCountTitle;

  /// No description provided for @dataScreenAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get dataScreenAllTime;

  /// No description provided for @dataScreenAvgPerWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'Avg/Week'**
  String get dataScreenAvgPerWeekTitle;

  /// No description provided for @dataScreenAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get dataScreenAverage;

  /// No description provided for @dataScreenFavoriteDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorite Day'**
  String get dataScreenFavoriteDayTitle;

  /// No description provided for @dataScreenMostActive.
  ///
  /// In en, this message translates to:
  /// **'Most active'**
  String get dataScreenMostActive;

  /// No description provided for @dataScreenBestOfHeading.
  ///
  /// In en, this message translates to:
  /// **'Best Of'**
  String get dataScreenBestOfHeading;

  /// No description provided for @dataScreenLongestSexTitle.
  ///
  /// In en, this message translates to:
  /// **'Longest Sex'**
  String get dataScreenLongestSexTitle;

  /// No description provided for @dataScreenThisMonthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get dataScreenThisMonthSubtitle;

  /// No description provided for @dataScreenHeartsStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Hearts Streak'**
  String get dataScreenHeartsStreakTitle;

  /// No description provided for @dataScreenStreakDaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{day in a row} other{days in a row}}'**
  String dataScreenStreakDaySubtitle(int count);

  /// No description provided for @dataScreenCurrentMonthHeading.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get dataScreenCurrentMonthHeading;

  /// No description provided for @dataScreenTotalTitle.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get dataScreenTotalTitle;

  /// No description provided for @dataScreenAvgDurationTitle.
  ///
  /// In en, this message translates to:
  /// **'Avg Duration'**
  String get dataScreenAvgDurationTitle;

  /// No description provided for @dataScreenAvgOrgasmsTitle.
  ///
  /// In en, this message translates to:
  /// **'Avg Orgasms'**
  String get dataScreenAvgOrgasmsTitle;

  /// No description provided for @dataScreenFrequencyChartHeading.
  ///
  /// In en, this message translates to:
  /// **'Frequency Chart'**
  String get dataScreenFrequencyChartHeading;

  /// No description provided for @dataScreenInitiatorChartHeading.
  ///
  /// In en, this message translates to:
  /// **'Initiator Chart'**
  String get dataScreenInitiatorChartHeading;

  /// No description provided for @dataScreenYouLabel.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get dataScreenYouLabel;

  /// No description provided for @dataScreenPartnerLabel.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get dataScreenPartnerLabel;

  /// No description provided for @dataScreenOrgasmComparisonHeading.
  ///
  /// In en, this message translates to:
  /// **'Orgasm Comparison'**
  String get dataScreenOrgasmComparisonHeading;

  /// No description provided for @dataScreenNoDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get dataScreenNoDataYet;

  /// No description provided for @dataScreenTagsRadarHeading.
  ///
  /// In en, this message translates to:
  /// **'Tags Radar'**
  String get dataScreenTagsRadarHeading;

  /// No description provided for @dataScreenNoTagsYet.
  ///
  /// In en, this message translates to:
  /// **'No tags yet'**
  String get dataScreenNoTagsYet;

  /// No description provided for @dataScreenHistoryHeading.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get dataScreenHistoryHeading;

  /// No description provided for @loginScreenResetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get loginScreenResetPasswordTitle;

  /// No description provided for @loginScreenResetPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password.'**
  String get loginScreenResetPasswordBody;

  /// No description provided for @loginScreenEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginScreenEmailLabel;

  /// No description provided for @loginScreenEmailHint.
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get loginScreenEmailHint;

  /// No description provided for @loginScreenSendButton.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get loginScreenSendButton;

  /// No description provided for @loginScreenResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent! Check your inbox.'**
  String get loginScreenResetEmailSent;

  /// No description provided for @loginScreenGenericError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String loginScreenGenericError(String error);

  /// No description provided for @loginScreenAccountNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Account not found'**
  String get loginScreenAccountNotFoundTitle;

  /// No description provided for @loginScreenAccountNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'No account was found for this email. Would you like to create a new account?'**
  String get loginScreenAccountNotFoundBody;

  /// No description provided for @loginScreenRegisterAction.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get loginScreenRegisterAction;

  /// No description provided for @loginScreenWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginScreenWelcomeBack;

  /// No description provided for @loginScreenSignInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginScreenSignInToContinue;

  /// No description provided for @loginScreenEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get loginScreenEmailRequired;

  /// No description provided for @loginScreenEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get loginScreenEmailInvalid;

  /// No description provided for @loginScreenPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginScreenPasswordLabel;

  /// No description provided for @loginScreenPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get loginScreenPasswordRequired;

  /// No description provided for @loginScreenPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get loginScreenPasswordTooShort;

  /// No description provided for @loginScreenForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginScreenForgotPassword;

  /// No description provided for @loginScreenSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginScreenSignInButton;

  /// No description provided for @loginScreenOrDivider.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get loginScreenOrDivider;

  /// No description provided for @loginScreenContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginScreenContinueWithGoogle;

  /// No description provided for @loginScreenNoAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get loginScreenNoAccountPrompt;

  /// No description provided for @loginScreenSignUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get loginScreenSignUpButton;

  /// No description provided for @registerScreenCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerScreenCreateAccount;

  /// No description provided for @registerScreenSignUpToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Sign up to get started'**
  String get registerScreenSignUpToGetStarted;

  /// No description provided for @registerScreenFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get registerScreenFullNameLabel;

  /// No description provided for @registerScreenNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get registerScreenNameRequired;

  /// No description provided for @registerScreenNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get registerScreenNameTooShort;

  /// No description provided for @registerScreenPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get registerScreenPasswordRequired;

  /// No description provided for @registerScreenConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get registerScreenConfirmPasswordLabel;

  /// No description provided for @registerScreenConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get registerScreenConfirmPasswordRequired;

  /// No description provided for @registerScreenPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get registerScreenPasswordsDoNotMatch;

  /// No description provided for @registerScreenSignUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get registerScreenSignUpButton;

  /// No description provided for @registerScreenAlreadyHaveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get registerScreenAlreadyHaveAccountPrompt;

  /// No description provided for @registerScreenSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get registerScreenSignInButton;

  /// No description provided for @pairingScreenAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect with Partner'**
  String get pairingScreenAppBarTitle;

  /// No description provided for @pairingScreenSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get pairingScreenSignOut;

  /// No description provided for @pairingScreenSignOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get pairingScreenSignOutConfirm;

  /// No description provided for @pairingScreenHeading.
  ///
  /// In en, this message translates to:
  /// **'Enter your partner\'s email'**
  String get pairingScreenHeading;

  /// No description provided for @pairingScreenSubheading.
  ///
  /// In en, this message translates to:
  /// **'Both of you must already have an account'**
  String get pairingScreenSubheading;

  /// No description provided for @pairingScreenEmailHint.
  ///
  /// In en, this message translates to:
  /// **'partner@email.com'**
  String get pairingScreenEmailHint;

  /// No description provided for @pairingScreenEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email address'**
  String get pairingScreenEmailRequired;

  /// No description provided for @pairingScreenEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get pairingScreenEmailInvalid;

  /// No description provided for @pairingScreenCannotPairSelf.
  ///
  /// In en, this message translates to:
  /// **'You cannot pair with yourself'**
  String get pairingScreenCannotPairSelf;

  /// No description provided for @pairingScreenPairedWith.
  ///
  /// In en, this message translates to:
  /// **'Paired with {name}!'**
  String pairingScreenPairedWith(String name);

  /// No description provided for @pairingScreenGenericError.
  ///
  /// In en, this message translates to:
  /// **'Unable to pair right now. Check your connection.'**
  String get pairingScreenGenericError;

  /// No description provided for @pairingScreenPairButton.
  ///
  /// In en, this message translates to:
  /// **'Pair'**
  String get pairingScreenPairButton;

  /// No description provided for @profileScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileScreenTitle;

  /// No description provided for @profileScreenUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get profileScreenUserNotFound;

  /// No description provided for @profileScreenNoName.
  ///
  /// In en, this message translates to:
  /// **'No name'**
  String get profileScreenNoName;

  /// No description provided for @profileScreenPartnerHeading.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get profileScreenPartnerHeading;

  /// No description provided for @profileScreenNoPartnerPaired.
  ///
  /// In en, this message translates to:
  /// **'No partner paired'**
  String get profileScreenNoPartnerPaired;

  /// No description provided for @profileScreenErrorLoadingPartner.
  ///
  /// In en, this message translates to:
  /// **'Error loading partner: {error}'**
  String profileScreenErrorLoadingPartner(String error);

  /// No description provided for @profileScreenActionsHeading.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get profileScreenActionsHeading;

  /// No description provided for @profileScreenUpgradeAction.
  ///
  /// In en, this message translates to:
  /// **'DYOS+ / Upgrade'**
  String get profileScreenUpgradeAction;

  /// No description provided for @profileScreenSecretGiftAction.
  ///
  /// In en, this message translates to:
  /// **'Secret gift / Private'**
  String get profileScreenSecretGiftAction;

  /// No description provided for @profileScreenSettingsAction.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileScreenSettingsAction;

  /// No description provided for @profileScreenErrorLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error loading profile: {error}'**
  String profileScreenErrorLoadingProfile(String error);

  /// No description provided for @editProfilePictureScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile Picture'**
  String get editProfilePictureScreenTitle;

  /// No description provided for @editProfilePictureScreenPickError.
  ///
  /// In en, this message translates to:
  /// **'Error picking image: {error}'**
  String editProfilePictureScreenPickError(String error);

  /// No description provided for @editProfilePictureScreenSelectImageFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select an image first'**
  String get editProfilePictureScreenSelectImageFirst;

  /// No description provided for @editProfilePictureScreenUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get editProfilePictureScreenUserNotFound;

  /// No description provided for @editProfilePictureScreenUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated successfully!'**
  String get editProfilePictureScreenUpdateSuccess;

  /// No description provided for @editProfilePictureScreenGenericError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String editProfilePictureScreenGenericError(String error);

  /// No description provided for @editProfilePictureScreenChooseImage.
  ///
  /// In en, this message translates to:
  /// **'Choose Image'**
  String get editProfilePictureScreenChooseImage;

  /// No description provided for @editProfilePictureScreenSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Profile Picture'**
  String get editProfilePictureScreenSaveButton;

  /// No description provided for @firebaseTestScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Firebase Connection Test'**
  String get firebaseTestScreenTitle;

  /// No description provided for @firebaseTestScreenRerunTooltip.
  ///
  /// In en, this message translates to:
  /// **'Run tests again'**
  String get firebaseTestScreenRerunTooltip;

  /// No description provided for @firebaseTestScreenRunning.
  ///
  /// In en, this message translates to:
  /// **'Running tests...'**
  String get firebaseTestScreenRunning;

  /// No description provided for @firebaseTestScreenAllPassed.
  ///
  /// In en, this message translates to:
  /// **'All tests passed! ✅'**
  String get firebaseTestScreenAllPassed;

  /// No description provided for @firebaseTestScreenSomeFailed.
  ///
  /// In en, this message translates to:
  /// **'Some tests failed ⚠️'**
  String get firebaseTestScreenSomeFailed;

  /// No description provided for @firebaseTestScreenPassedCount.
  ///
  /// In en, this message translates to:
  /// **'Passed: {passed} / {total}'**
  String firebaseTestScreenPassedCount(int passed, int total);

  /// No description provided for @firebaseTestScreenNoResults.
  ///
  /// In en, this message translates to:
  /// **'No test results yet'**
  String get firebaseTestScreenNoResults;

  /// No description provided for @firebaseTestScreenWhatToCheckHeading.
  ///
  /// In en, this message translates to:
  /// **'What to check:'**
  String get firebaseTestScreenWhatToCheckHeading;

  /// No description provided for @firebaseTestScreenInstructionAllGreen.
  ///
  /// In en, this message translates to:
  /// **'✅ All green = Firebase is properly connected!'**
  String get firebaseTestScreenInstructionAllGreen;

  /// No description provided for @firebaseTestScreenInstructionCoreFailed.
  ///
  /// In en, this message translates to:
  /// **'❌ Firebase Core failed = Check configuration files'**
  String get firebaseTestScreenInstructionCoreFailed;

  /// No description provided for @firebaseTestScreenInstructionFirestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'❌ Firestore failed = Enable Firestore in Firebase Console'**
  String get firebaseTestScreenInstructionFirestoreFailed;

  /// No description provided for @firebaseTestScreenInstructionWriteReadFailed.
  ///
  /// In en, this message translates to:
  /// **'❌ Write/Read failed = Check Firestore security rules'**
  String get firebaseTestScreenInstructionWriteReadFailed;

  /// No description provided for @blueprintDetailScreenXpGranted.
  ///
  /// In en, this message translates to:
  /// **'System Updated: +100 XP acquired! 🚀'**
  String get blueprintDetailScreenXpGranted;

  /// No description provided for @blueprintDetailScreenAlreadyEarned.
  ///
  /// In en, this message translates to:
  /// **'Section saved. (XP already earned today.)'**
  String get blueprintDetailScreenAlreadyEarned;

  /// No description provided for @blueprintDetailScreenSectionComplete.
  ///
  /// In en, this message translates to:
  /// **'Section complete!'**
  String get blueprintDetailScreenSectionComplete;

  /// No description provided for @blueprintDetailScreenLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this Blueprint section.'**
  String get blueprintDetailScreenLoadError;

  /// No description provided for @blueprintDetailScreenNotFound.
  ///
  /// In en, this message translates to:
  /// **'Blueprint section not found.'**
  String get blueprintDetailScreenNotFound;

  /// No description provided for @blueprintDetailScreenCompleteButton.
  ///
  /// In en, this message translates to:
  /// **'Complete Section'**
  String get blueprintDetailScreenCompleteButton;

  /// No description provided for @blueprintsListScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Questions'**
  String get blueprintsListScreenTitle;

  /// No description provided for @blueprintsListScreenLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load Blueprints.'**
  String get blueprintsListScreenLoadError;

  /// No description provided for @blueprintsListScreenIntro.
  ///
  /// In en, this message translates to:
  /// **'Save your preferences as a couple. Complete a section to earn +100 XP.'**
  String get blueprintsListScreenIntro;

  /// No description provided for @blueprintsListScreenQuestionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 question} other{{count} questions}}'**
  String blueprintsListScreenQuestionsCount(int count);

  /// No description provided for @blueprintQuestionCardPartnerValue.
  ///
  /// In en, this message translates to:
  /// **'Partner: {value}'**
  String blueprintQuestionCardPartnerValue(String value);

  /// No description provided for @blueprintQuestionCardYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get blueprintQuestionCardYes;

  /// No description provided for @blueprintQuestionCardNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get blueprintQuestionCardNo;

  /// No description provided for @cycleSettingsSheetPairFirst.
  ///
  /// In en, this message translates to:
  /// **'Please pair with a partner first'**
  String get cycleSettingsSheetPairFirst;

  /// No description provided for @cycleSettingsSheetSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully!'**
  String get cycleSettingsSheetSaved;

  /// No description provided for @cycleSettingsSheetError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String cycleSettingsSheetError(String error);

  /// No description provided for @cycleSettingsSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Cycle Settings'**
  String get cycleSettingsSheetTitle;

  /// No description provided for @cycleSettingsSheetDayInCycleLabel.
  ///
  /// In en, this message translates to:
  /// **'Day in Cycle'**
  String get cycleSettingsSheetDayInCycleLabel;

  /// No description provided for @cycleSettingsSheetDayInCycleValue.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String cycleSettingsSheetDayInCycleValue(int day);

  /// No description provided for @cycleSettingsSheetLastPeriodDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Period Date'**
  String get cycleSettingsSheetLastPeriodDateLabel;

  /// No description provided for @cycleSettingsSheetNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get cycleSettingsSheetNotSet;

  /// No description provided for @cycleSettingsSheetTapToChange.
  ///
  /// In en, this message translates to:
  /// **'Tap to change'**
  String get cycleSettingsSheetTapToChange;

  /// No description provided for @cycleSettingsSheetAvgCycleLengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Average Cycle Length'**
  String get cycleSettingsSheetAvgCycleLengthLabel;

  /// No description provided for @cycleSettingsSheetDaysValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 day} other{{count} days}}'**
  String cycleSettingsSheetDaysValue(int count);

  /// No description provided for @cycleSettingsSheetPeriodLengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Period Length'**
  String get cycleSettingsSheetPeriodLengthLabel;

  /// No description provided for @cycleSettingsSheetHideMenstruationLabel.
  ///
  /// In en, this message translates to:
  /// **'Hide Menstruation'**
  String get cycleSettingsSheetHideMenstruationLabel;

  /// No description provided for @cycleSettingsSheetHideMenstruationDescription.
  ///
  /// In en, this message translates to:
  /// **'Hide menstruation tracking and display in calendar'**
  String get cycleSettingsSheetHideMenstruationDescription;

  /// No description provided for @cycleSettingsSheetLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading settings'**
  String get cycleSettingsSheetLoadError;

  /// No description provided for @cycleTrackingScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get cycleTrackingScreenTitle;

  /// No description provided for @cycleTrackingScreenSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cycle Settings'**
  String get cycleTrackingScreenSettingsTooltip;

  /// No description provided for @cycleTrackingScreenToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get cycleTrackingScreenToday;

  /// No description provided for @cycleTrackingScreenYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get cycleTrackingScreenYesterday;

  /// No description provided for @cycleTrackingScreenTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get cycleTrackingScreenTomorrow;

  /// No description provided for @cycleTrackingScreenMemoriesHeading.
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get cycleTrackingScreenMemoriesHeading;

  /// No description provided for @cycleTrackingScreenIntimacyHeading.
  ///
  /// In en, this message translates to:
  /// **'Intimacy'**
  String get cycleTrackingScreenIntimacyHeading;

  /// No description provided for @cycleTrackingScreenRating.
  ///
  /// In en, this message translates to:
  /// **'Rating: {rating}/5'**
  String cycleTrackingScreenRating(int rating);

  /// No description provided for @cycleTrackingScreenEventsHeading.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get cycleTrackingScreenEventsHeading;

  /// No description provided for @cycleTrackingScreenAddMemoryButton.
  ///
  /// In en, this message translates to:
  /// **'Add Memory'**
  String get cycleTrackingScreenAddMemoryButton;

  /// No description provided for @cycleTrackingScreenAddIntimacyButton.
  ///
  /// In en, this message translates to:
  /// **'Add Intimacy'**
  String get cycleTrackingScreenAddIntimacyButton;

  /// No description provided for @cycleTrackingScreenAddEventButton.
  ///
  /// In en, this message translates to:
  /// **'Add Event'**
  String get cycleTrackingScreenAddEventButton;

  /// No description provided for @cycleTrackingScreenAddPeriodLogButton.
  ///
  /// In en, this message translates to:
  /// **'Add Period Log'**
  String get cycleTrackingScreenAddPeriodLogButton;

  /// No description provided for @cycleTrackingScreenLegendHeading.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get cycleTrackingScreenLegendHeading;

  /// No description provided for @cycleTrackingScreenMenstruationLabel.
  ///
  /// In en, this message translates to:
  /// **'Menstruation'**
  String get cycleTrackingScreenMenstruationLabel;

  /// No description provided for @cycleTrackingScreenFollicularLabel.
  ///
  /// In en, this message translates to:
  /// **'Follicular'**
  String get cycleTrackingScreenFollicularLabel;

  /// No description provided for @cycleTrackingScreenOvulationFertileLabel.
  ///
  /// In en, this message translates to:
  /// **'Ovulation/Fertile'**
  String get cycleTrackingScreenOvulationFertileLabel;

  /// No description provided for @cycleTrackingScreenLutealPmsLabel.
  ///
  /// In en, this message translates to:
  /// **'Luteal/PMS'**
  String get cycleTrackingScreenLutealPmsLabel;

  /// No description provided for @cycleTrackingScreenPairFirst.
  ///
  /// In en, this message translates to:
  /// **'Please pair with a partner first'**
  String get cycleTrackingScreenPairFirst;

  /// No description provided for @cycleTrackingScreenLogUpdated.
  ///
  /// In en, this message translates to:
  /// **'Cycle log updated successfully!'**
  String get cycleTrackingScreenLogUpdated;

  /// No description provided for @cycleTrackingScreenLogAdded.
  ///
  /// In en, this message translates to:
  /// **'Cycle log added successfully!'**
  String get cycleTrackingScreenLogAdded;

  /// No description provided for @cycleTrackingScreenError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String cycleTrackingScreenError(String error);

  /// No description provided for @cycleTrackingScreenEditLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Cycle Log'**
  String get cycleTrackingScreenEditLogTitle;

  /// No description provided for @cycleTrackingScreenAddLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Cycle Log'**
  String get cycleTrackingScreenAddLogTitle;

  /// No description provided for @cycleTrackingScreenFlowIntensityLabel.
  ///
  /// In en, this message translates to:
  /// **'Flow Intensity'**
  String get cycleTrackingScreenFlowIntensityLabel;

  /// No description provided for @cycleTrackingScreenMoodLabel.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get cycleTrackingScreenMoodLabel;

  /// No description provided for @cycleTrackingScreenUpdateLogButton.
  ///
  /// In en, this message translates to:
  /// **'Update Log'**
  String get cycleTrackingScreenUpdateLogButton;

  /// No description provided for @cycleTrackingScreenAddLogButton.
  ///
  /// In en, this message translates to:
  /// **'Add Log'**
  String get cycleTrackingScreenAddLogButton;

  /// No description provided for @addEventSheetTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get addEventSheetTitleRequired;

  /// No description provided for @addEventSheetPairFirst.
  ///
  /// In en, this message translates to:
  /// **'Please pair with a partner first'**
  String get addEventSheetPairFirst;

  /// No description provided for @addEventSheetAddedWithXp.
  ///
  /// In en, this message translates to:
  /// **'Event added! +15 XP'**
  String get addEventSheetAddedWithXp;

  /// No description provided for @addEventSheetAddedXpAlreadyEarned.
  ///
  /// In en, this message translates to:
  /// **'Event added! XP for this activity is granted once per day.'**
  String get addEventSheetAddedXpAlreadyEarned;

  /// No description provided for @addEventSheetUpdated.
  ///
  /// In en, this message translates to:
  /// **'Event updated successfully!'**
  String get addEventSheetUpdated;

  /// No description provided for @addEventSheetAdded.
  ///
  /// In en, this message translates to:
  /// **'Event added successfully!'**
  String get addEventSheetAdded;

  /// No description provided for @addEventSheetError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String addEventSheetError(String error);

  /// No description provided for @addEventSheetEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Event'**
  String get addEventSheetEditTitle;

  /// No description provided for @addEventSheetAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Event'**
  String get addEventSheetAddTitle;

  /// No description provided for @addEventSheetTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get addEventSheetTitleLabel;

  /// No description provided for @addEventSheetTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter event title'**
  String get addEventSheetTitleHint;

  /// No description provided for @addEventSheetUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update Event'**
  String get addEventSheetUpdateButton;

  /// No description provided for @addEventSheetAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Event'**
  String get addEventSheetAddButton;

  /// No description provided for @addEventSheetDateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get addEventSheetDateTimeLabel;

  /// No description provided for @addEventSheetToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get addEventSheetToday;

  /// No description provided for @addEventSheetYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get addEventSheetYesterday;

  /// No description provided for @addEventSheetTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get addEventSheetTomorrow;

  /// No description provided for @eventsScreenBackTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get eventsScreenBackTooltip;

  /// No description provided for @eventsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get eventsScreenTitle;

  /// No description provided for @eventsScreenAddEventTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get eventsScreenAddEventTooltip;

  /// No description provided for @eventsScreenDebugEventsLoaded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Debug: 1 event loaded} other{Debug: {count} events loaded}}'**
  String eventsScreenDebugEventsLoaded(int count);

  /// No description provided for @eventsScreenNoEventsOnDay.
  ///
  /// In en, this message translates to:
  /// **'No events on this day'**
  String get eventsScreenNoEventsOnDay;

  /// No description provided for @eventsScreenNoEventsYet.
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get eventsScreenNoEventsYet;

  /// No description provided for @eventsScreenAddEventButton.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get eventsScreenAddEventButton;

  /// No description provided for @eventsScreenLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading events: {error}'**
  String eventsScreenLoadError(String error);

  /// No description provided for @eventsScreenDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Event'**
  String get eventsScreenDeleteDialogTitle;

  /// No description provided for @eventsScreenDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String eventsScreenDeleteConfirmMessage(String title);

  /// No description provided for @eventsScreenPairFirst.
  ///
  /// In en, this message translates to:
  /// **'Please pair with a partner first'**
  String get eventsScreenPairFirst;

  /// No description provided for @eventsScreenDeleted.
  ///
  /// In en, this message translates to:
  /// **'Event deleted successfully'**
  String get eventsScreenDeleted;

  /// No description provided for @eventsScreenError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String eventsScreenError(String error);

  /// No description provided for @eventsScreenDeleteEventTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete event'**
  String get eventsScreenDeleteEventTooltip;

  /// No description provided for @intimacyHistoryScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Intimacy History'**
  String get intimacyHistoryScreenTitle;

  /// No description provided for @addIntimacySheetPairFirst.
  ///
  /// In en, this message translates to:
  /// **'Please pair with a partner first'**
  String get addIntimacySheetPairFirst;

  /// No description provided for @addIntimacySheetSelectInitiator.
  ///
  /// In en, this message translates to:
  /// **'Please select an initiator'**
  String get addIntimacySheetSelectInitiator;

  /// No description provided for @addIntimacySheetAddedWithXp.
  ///
  /// In en, this message translates to:
  /// **'Intimacy log added! +20 XP'**
  String get addIntimacySheetAddedWithXp;

  /// No description provided for @addIntimacySheetAddedXpAlreadyGranted.
  ///
  /// In en, this message translates to:
  /// **'Intimacy log added! XP for this activity is granted once per day.'**
  String get addIntimacySheetAddedXpAlreadyGranted;

  /// No description provided for @addIntimacySheetUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Intimacy log updated successfully!'**
  String get addIntimacySheetUpdatedSuccess;

  /// No description provided for @addIntimacySheetAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Intimacy log added successfully!'**
  String get addIntimacySheetAddedSuccess;

  /// No description provided for @addIntimacySheetError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String addIntimacySheetError(String error);

  /// No description provided for @addIntimacySheetEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Intimacy Log'**
  String get addIntimacySheetEditTitle;

  /// No description provided for @addIntimacySheetAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Intimacy Log'**
  String get addIntimacySheetAddTitle;

  /// No description provided for @addIntimacySheetMeFallback.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get addIntimacySheetMeFallback;

  /// No description provided for @addIntimacySheetUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update Log'**
  String get addIntimacySheetUpdateButton;

  /// No description provided for @addIntimacySheetAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Log'**
  String get addIntimacySheetAddButton;

  /// No description provided for @addIntimacySheetNoteFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get addIntimacySheetNoteFieldLabel;

  /// No description provided for @addIntimacySheetNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add any notes...'**
  String get addIntimacySheetNoteHint;

  /// No description provided for @addIntimacySheetDateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get addIntimacySheetDateTimeLabel;

  /// No description provided for @addIntimacySheetToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get addIntimacySheetToday;

  /// No description provided for @addIntimacySheetYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get addIntimacySheetYesterday;

  /// No description provided for @addIntimacySheetRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get addIntimacySheetRatingLabel;

  /// No description provided for @addIntimacySheetInitiatorLabel.
  ///
  /// In en, this message translates to:
  /// **'Initiator'**
  String get addIntimacySheetInitiatorLabel;

  /// No description provided for @addIntimacySheetTagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get addIntimacySheetTagsLabel;

  /// No description provided for @addIntimacySheetProtectionUsedLabel.
  ///
  /// In en, this message translates to:
  /// **'Protection Used'**
  String get addIntimacySheetProtectionUsedLabel;

  /// No description provided for @addIntimacySheetProtectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Was protection used during intimacy?'**
  String get addIntimacySheetProtectionSubtitle;

  /// No description provided for @addIntimacySheetOrgasmsLabel.
  ///
  /// In en, this message translates to:
  /// **'Orgasms'**
  String get addIntimacySheetOrgasmsLabel;

  /// No description provided for @addIntimacySheetDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get addIntimacySheetDurationLabel;

  /// No description provided for @addIntimacySheetDurationFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration (minutes)'**
  String get addIntimacySheetDurationFieldLabel;

  /// No description provided for @addIntimacySheetDurationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 30'**
  String get addIntimacySheetDurationHint;

  /// No description provided for @addIntimacySheetLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get addIntimacySheetLocationLabel;

  /// No description provided for @addIntimacySheetLocationFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Location (optional)'**
  String get addIntimacySheetLocationFieldLabel;

  /// No description provided for @addIntimacySheetLocationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Home, Hotel, Beach...'**
  String get addIntimacySheetLocationHint;

  /// No description provided for @intimacyHistoryListViewAllButton.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get intimacyHistoryListViewAllButton;

  /// No description provided for @intimacyHistoryListLoadOlderButton.
  ///
  /// In en, this message translates to:
  /// **'Load older logs'**
  String get intimacyHistoryListLoadOlderButton;

  /// No description provided for @intimacyHistoryListErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error loading logs'**
  String get intimacyHistoryListErrorTitle;

  /// No description provided for @intimacyHistoryListEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No memories yet'**
  String get intimacyHistoryListEmptyTitle;

  /// No description provided for @intimacyHistoryListEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Time to change that? 😉'**
  String get intimacyHistoryListEmptySubtitle;

  /// No description provided for @intimacyHistoryListDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String intimacyHistoryListDurationMinutes(int minutes);

  /// No description provided for @intimacyLogDetailSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Intimacy Log Details'**
  String get intimacyLogDetailSheetTitle;

  /// No description provided for @intimacyLogDetailSheetDateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get intimacyLogDetailSheetDateTimeLabel;

  /// No description provided for @intimacyLogDetailSheetDateTimeValue.
  ///
  /// In en, this message translates to:
  /// **'{date} at {time}'**
  String intimacyLogDetailSheetDateTimeValue(String date, String time);

  /// No description provided for @intimacyLogDetailSheetRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get intimacyLogDetailSheetRatingLabel;

  /// No description provided for @intimacyLogDetailSheetInitiatorLabel.
  ///
  /// In en, this message translates to:
  /// **'Initiator'**
  String get intimacyLogDetailSheetInitiatorLabel;

  /// No description provided for @intimacyLogDetailSheetMeFallback.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get intimacyLogDetailSheetMeFallback;

  /// No description provided for @intimacyLogDetailSheetTagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get intimacyLogDetailSheetTagsLabel;

  /// No description provided for @intimacyLogDetailSheetProtectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Protection'**
  String get intimacyLogDetailSheetProtectionLabel;

  /// No description provided for @intimacyLogDetailSheetProtectionUsed.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get intimacyLogDetailSheetProtectionUsed;

  /// No description provided for @intimacyLogDetailSheetProtectionNotUsed.
  ///
  /// In en, this message translates to:
  /// **'Not used'**
  String get intimacyLogDetailSheetProtectionNotUsed;

  /// No description provided for @intimacyLogDetailSheetOrgasmsLabel.
  ///
  /// In en, this message translates to:
  /// **'Orgasms'**
  String get intimacyLogDetailSheetOrgasmsLabel;

  /// No description provided for @intimacyLogDetailSheetDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get intimacyLogDetailSheetDurationLabel;

  /// No description provided for @intimacyLogDetailSheetDurationValue.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, one{{minutes} minute} other{{minutes} minutes}}'**
  String intimacyLogDetailSheetDurationValue(int minutes);

  /// No description provided for @intimacyLogDetailSheetLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get intimacyLogDetailSheetLocationLabel;

  /// No description provided for @intimacyLogDetailSheetNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get intimacyLogDetailSheetNoteLabel;

  /// No description provided for @intimacyLogDetailSheetDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete intimacy log?'**
  String get intimacyLogDetailSheetDeleteConfirmTitle;

  /// No description provided for @intimacyLogDetailSheetDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get intimacyLogDetailSheetDeleteConfirmBody;

  /// No description provided for @intimacyLogDetailSheetDeletedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Intimacy log deleted'**
  String get intimacyLogDetailSheetDeletedSnackbar;

  /// No description provided for @intimacyLogDetailSheetDeleteFailedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete log: {error}'**
  String intimacyLogDetailSheetDeleteFailedSnackbar(String error);

  /// No description provided for @appRouterMemoryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Memory not found'**
  String get appRouterMemoryNotFound;

  /// No description provided for @appRouterNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get appRouterNavHome;

  /// No description provided for @appRouterNavMemory.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get appRouterNavMemory;

  /// No description provided for @appRouterNavData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get appRouterNavData;

  /// No description provided for @appRouterNavCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get appRouterNavCalendar;

  /// No description provided for @appRouterQuickActionsHeading.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get appRouterQuickActionsHeading;

  /// No description provided for @appRouterQuickActionAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get appRouterQuickActionAddNote;

  /// No description provided for @appRouterQuickActionAddMemory.
  ///
  /// In en, this message translates to:
  /// **'Add memory'**
  String get appRouterQuickActionAddMemory;

  /// No description provided for @appRouterQuickActionLogIntimacy.
  ///
  /// In en, this message translates to:
  /// **'Log intimacy'**
  String get appRouterQuickActionLogIntimacy;

  /// No description provided for @appRouterQuickActionAddEvent.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get appRouterQuickActionAddEvent;

  /// No description provided for @chatScreenShortcutThinkingOfYou.
  ///
  /// In en, this message translates to:
  /// **'Thinking of you 💭'**
  String get chatScreenShortcutThinkingOfYou;

  /// No description provided for @chatScreenShortcutMissYou.
  ///
  /// In en, this message translates to:
  /// **'Miss you ❤️'**
  String get chatScreenShortcutMissYou;

  /// No description provided for @chatScreenShortcutLoveYou.
  ///
  /// In en, this message translates to:
  /// **'Love you 😘'**
  String get chatScreenShortcutLoveYou;

  /// No description provided for @chatScreenShortcutSeeYouSoon.
  ///
  /// In en, this message translates to:
  /// **'See you soon 👋'**
  String get chatScreenShortcutSeeYouSoon;

  /// No description provided for @chatScreenShortcutGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning ☀️'**
  String get chatScreenShortcutGoodMorning;

  /// No description provided for @chatScreenShortcutGoodNight.
  ///
  /// In en, this message translates to:
  /// **'Good night 🌙'**
  String get chatScreenShortcutGoodNight;

  /// No description provided for @chatScreenShortcutHowAreYou.
  ///
  /// In en, this message translates to:
  /// **'How are you? 😊'**
  String get chatScreenShortcutHowAreYou;

  /// No description provided for @chatScreenSendMessageError.
  ///
  /// In en, this message translates to:
  /// **'Could not send message: {error}'**
  String chatScreenSendMessageError(String error);

  /// No description provided for @chatScreenSendTouchError.
  ///
  /// In en, this message translates to:
  /// **'Could not send touch: {error}'**
  String chatScreenSendTouchError(String error);

  /// No description provided for @chatScreenPartnerFallback.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get chatScreenPartnerFallback;

  /// No description provided for @chatScreenPairPrompt.
  ///
  /// In en, this message translates to:
  /// **'Pair with your partner to start chatting.'**
  String get chatScreenPairPrompt;

  /// No description provided for @chatScreenEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No messages or touches yet.\nSay hi 👋'**
  String get chatScreenEmptyState;

  /// No description provided for @chatScreenLoadHistoryError.
  ///
  /// In en, this message translates to:
  /// **'Could not load chat history.'**
  String get chatScreenLoadHistoryError;

  /// No description provided for @chatScreenTouchLabel.
  ///
  /// In en, this message translates to:
  /// **'Touch'**
  String get chatScreenTouchLabel;

  /// No description provided for @chatScreenSendTouchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Send a touch'**
  String get chatScreenSendTouchTooltip;

  /// No description provided for @chatScreenMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get chatScreenMessageHint;

  /// No description provided for @chatScreenSendTooltip.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatScreenSendTooltip;

  /// No description provided for @homeScreenUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get homeScreenUserNotFound;

  /// No description provided for @homeScreenNotPaired.
  ///
  /// In en, this message translates to:
  /// **'Not paired. Please pair first.'**
  String get homeScreenNotPaired;

  /// No description provided for @homeScreenTestNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Test Notifications'**
  String get homeScreenTestNotificationsTitle;

  /// No description provided for @homeScreenHapticSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Haptic signal sent! Check console/logs for details.'**
  String get homeScreenHapticSentMessage;

  /// No description provided for @homeScreenGenericError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String homeScreenGenericError(String error);

  /// No description provided for @homeScreenTestHapticSignalButton.
  ///
  /// In en, this message translates to:
  /// **'Test Haptic Signal'**
  String get homeScreenTestHapticSignalButton;

  /// No description provided for @homeScreenQuickMessageSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Quick message sent! Check console/logs for details.'**
  String get homeScreenQuickMessageSentMessage;

  /// No description provided for @homeScreenTestQuickMessageButton.
  ///
  /// In en, this message translates to:
  /// **'Test Quick Message'**
  String get homeScreenTestQuickMessageButton;

  /// No description provided for @homeScreenSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeScreenSettingsTooltip;

  /// No description provided for @homeScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeScreenTitle;

  /// No description provided for @homeScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Widgets for your life'**
  String get homeScreenSubtitle;

  /// No description provided for @appBarLevelStripXpLabel.
  ///
  /// In en, this message translates to:
  /// **'{xp} SP'**
  String appBarLevelStripXpLabel(int xp);

  /// No description provided for @countdownCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Countdown'**
  String get countdownCardTitle;

  /// No description provided for @countdownCardNoEvents.
  ///
  /// In en, this message translates to:
  /// **'No upcoming events'**
  String get countdownCardNoEvents;

  /// No description provided for @countdownCardDaysUntil.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{day} other{days}} until {title}'**
  String countdownCardDaysUntil(int count, String title);

  /// No description provided for @countdownCardError.
  ///
  /// In en, this message translates to:
  /// **'Error loading events'**
  String get countdownCardError;

  /// No description provided for @daysTogetherCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Days Together'**
  String get daysTogetherCardTitle;

  /// No description provided for @daysTogetherCardSetDate.
  ///
  /// In en, this message translates to:
  /// **'Set your anniversary date'**
  String get daysTogetherCardSetDate;

  /// No description provided for @intimacySparkCardNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get intimacySparkCardNoActivity;

  /// No description provided for @intimacySparkCardDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Today} one{{count} day ago} other{{count} days ago}}'**
  String intimacySparkCardDaysAgo(int count);

  /// No description provided for @intimacySparkCardError.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get intimacySparkCardError;

  /// No description provided for @quickMessageNotificationOverlayLabel.
  ///
  /// In en, this message translates to:
  /// **'Quick Message'**
  String get quickMessageNotificationOverlayLabel;

  /// No description provided for @quickNoteCardPromptWriteSomethingNice.
  ///
  /// In en, this message translates to:
  /// **'Write me something nice...'**
  String get quickNoteCardPromptWriteSomethingNice;

  /// No description provided for @quickNoteCardPromptDontForget.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget...'**
  String get quickNoteCardPromptDontForget;

  /// No description provided for @quickNoteCardPromptDoorCode.
  ///
  /// In en, this message translates to:
  /// **'The door code is...'**
  String get quickNoteCardPromptDoorCode;

  /// No description provided for @quickNoteCardPromptSecretPhrase.
  ///
  /// In en, this message translates to:
  /// **'Today\'s secret phrase?'**
  String get quickNoteCardPromptSecretPhrase;

  /// No description provided for @quickNoteCardHeaderLabel.
  ///
  /// In en, this message translates to:
  /// **'STICKY NOTE'**
  String get quickNoteCardHeaderLabel;

  /// No description provided for @statusHeaderPairPrompt.
  ///
  /// In en, this message translates to:
  /// **'Pair with your partner to view status'**
  String get statusHeaderPairPrompt;

  /// No description provided for @statusHeaderYouFallback.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get statusHeaderYouFallback;

  /// No description provided for @statusHeaderPartnerFallback.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get statusHeaderPartnerFallback;

  /// No description provided for @statusHeaderReadyStatus.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get statusHeaderReadyStatus;

  /// No description provided for @statusHeaderLoadingStatus.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get statusHeaderLoadingStatus;

  /// No description provided for @statusHeaderErrorStatus.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get statusHeaderErrorStatus;

  /// No description provided for @statusHeaderUpdateStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Status'**
  String get statusHeaderUpdateStatusTitle;

  /// No description provided for @statusHeaderChooseEmojiLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose emoji'**
  String get statusHeaderChooseEmojiLabel;

  /// No description provided for @statusHeaderStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusHeaderStatusLabel;

  /// No description provided for @statusHeaderStatusUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Status updated'**
  String get statusHeaderStatusUpdatedMessage;

  /// No description provided for @statusHeaderUpdateErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error updating status: {error}'**
  String statusHeaderUpdateErrorMessage(String error);

  /// No description provided for @tapticTouchCardUnlockPrompt.
  ///
  /// In en, this message translates to:
  /// **'Unlock with DYOS+ or via the Roadmap'**
  String get tapticTouchCardUnlockPrompt;

  /// No description provided for @tapticTouchCardSentLabel.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get tapticTouchCardSentLabel;

  /// No description provided for @tapticTouchCardSentToPartnerMessage.
  ///
  /// In en, this message translates to:
  /// **'Sent to partner'**
  String get tapticTouchCardSentToPartnerMessage;

  /// No description provided for @tapticTouchCardSendErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error sending: {error}'**
  String tapticTouchCardSendErrorMessage(String error);

  /// No description provided for @addMemoryScreenErrorPickingImages.
  ///
  /// In en, this message translates to:
  /// **'Error picking images: {error}'**
  String addMemoryScreenErrorPickingImages(String error);

  /// No description provided for @addMemoryScreenErrorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image: {error}'**
  String addMemoryScreenErrorPickingImage(String error);

  /// No description provided for @addMemoryScreenMemoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Memory updated'**
  String get addMemoryScreenMemoryUpdated;

  /// No description provided for @addMemoryScreenFreeLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You have reached the free limit of 30 memories. Unlock unlimited Memories in DYOS+.'**
  String get addMemoryScreenFreeLimitMessage;

  /// No description provided for @addMemoryScreenAddImageOrCaption.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one image or a caption'**
  String get addMemoryScreenAddImageOrCaption;

  /// No description provided for @addMemoryScreenMemorySavedXp.
  ///
  /// In en, this message translates to:
  /// **'Memory saved! +25 XP'**
  String get addMemoryScreenMemorySavedXp;

  /// No description provided for @addMemoryScreenMemorySavedXpOncePerDay.
  ///
  /// In en, this message translates to:
  /// **'Memory saved! XP for this activity is granted once per day.'**
  String get addMemoryScreenMemorySavedXpOncePerDay;

  /// No description provided for @addMemoryScreenMemoryUpdatedWithCaption.
  ///
  /// In en, this message translates to:
  /// **'Memory \"{caption}\" updated.'**
  String addMemoryScreenMemoryUpdatedWithCaption(String caption);

  /// No description provided for @addMemoryScreenUntitledCaption.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get addMemoryScreenUntitledCaption;

  /// No description provided for @addMemoryScreenEditMemoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Memory'**
  String get addMemoryScreenEditMemoryTitle;

  /// No description provided for @addMemoryScreenAddMemoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Memory'**
  String get addMemoryScreenAddMemoryTitle;

  /// No description provided for @addMemoryScreenCaptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Caption'**
  String get addMemoryScreenCaptionLabel;

  /// No description provided for @addMemoryScreenCaptionHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s this memory about?'**
  String get addMemoryScreenCaptionHint;

  /// No description provided for @addMemoryScreenPhotosVideosLabel.
  ///
  /// In en, this message translates to:
  /// **'Photos & Videos'**
  String get addMemoryScreenPhotosVideosLabel;

  /// No description provided for @addMemoryScreenAddPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get addMemoryScreenAddPhotos;

  /// No description provided for @addMemoryScreenAddMorePhotos.
  ///
  /// In en, this message translates to:
  /// **'Add More Photos'**
  String get addMemoryScreenAddMorePhotos;

  /// No description provided for @addMemoryScreenDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get addMemoryScreenDateLabel;

  /// No description provided for @addMemoryScreenCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get addMemoryScreenCategoryLabel;

  /// No description provided for @addMemoryScreenPlaceLabel.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get addMemoryScreenPlaceLabel;

  /// No description provided for @addMemoryScreenAddPlace.
  ///
  /// In en, this message translates to:
  /// **'Add place'**
  String get addMemoryScreenAddPlace;

  /// No description provided for @addMemoryScreenLocationSet.
  ///
  /// In en, this message translates to:
  /// **'Location set'**
  String get addMemoryScreenLocationSet;

  /// No description provided for @addMemoryScreenChangePlaceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Change place'**
  String get addMemoryScreenChangePlaceTooltip;

  /// No description provided for @addMemoryScreenRemovePlaceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove place'**
  String get addMemoryScreenRemovePlaceTooltip;

  /// No description provided for @addMemoryScreenUpdateMemoryButton.
  ///
  /// In en, this message translates to:
  /// **'Update Memory'**
  String get addMemoryScreenUpdateMemoryButton;

  /// No description provided for @addMemoryScreenSaveMemoryButton.
  ///
  /// In en, this message translates to:
  /// **'Save Memory'**
  String get addMemoryScreenSaveMemoryButton;

  /// No description provided for @memoriesMapScreenBackTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get memoriesMapScreenBackTooltip;

  /// No description provided for @memoriesMapScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Memories map'**
  String get memoriesMapScreenTitle;

  /// No description provided for @memoriesMapScreenNoMemoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No memories with a place yet'**
  String get memoriesMapScreenNoMemoriesYet;

  /// No description provided for @memoriesMapScreenError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String memoriesMapScreenError(String error);

  /// No description provided for @memoriesMapScreenSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search place or address...'**
  String get memoriesMapScreenSearchHint;

  /// No description provided for @memoriesMapScreenMyLocationTooltip.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get memoriesMapScreenMyLocationTooltip;

  /// No description provided for @memoriesMapScreenMapKeyMissingMessage.
  ///
  /// In en, this message translates to:
  /// **'Map preview needs a Google Maps API key (see docs/ANDROID_GOOGLE_API_KEY.md). Memories with a place are listed below.'**
  String get memoriesMapScreenMapKeyMissingMessage;

  /// No description provided for @memoriesMapScreenPlaceFallback.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get memoriesMapScreenPlaceFallback;

  /// No description provided for @memoriesMapScreenMemoryFallback.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get memoriesMapScreenMemoryFallback;

  /// No description provided for @memoriesMapScreenUntitledCaption.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get memoriesMapScreenUntitledCaption;

  /// No description provided for @memoryDetailScreenDeleteMemoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete memory?'**
  String get memoryDetailScreenDeleteMemoryTitle;

  /// No description provided for @memoryDetailScreenDeleteMemoryContent.
  ///
  /// In en, this message translates to:
  /// **'This memory will be removed. This cannot be undone.'**
  String get memoryDetailScreenDeleteMemoryContent;

  /// No description provided for @memoryDetailScreenMemoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Memory deleted'**
  String get memoryDetailScreenMemoryDeleted;

  /// No description provided for @memoryDetailScreenFailedToDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete: {error}'**
  String memoryDetailScreenFailedToDelete(String error);

  /// No description provided for @memoryDetailScreenBackTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get memoryDetailScreenBackTooltip;

  /// No description provided for @memoryDetailScreenCloseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get memoryDetailScreenCloseTooltip;

  /// No description provided for @memoryDetailScreenPageCounter.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String memoryDetailScreenPageCounter(int current, int total);

  /// No description provided for @memoryDetailScreenDeletingLabel.
  ///
  /// In en, this message translates to:
  /// **'Deleting…'**
  String get memoryDetailScreenDeletingLabel;

  /// No description provided for @memoryDetailScreenFailedToLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get memoryDetailScreenFailedToLoadImage;

  /// No description provided for @memoryDetailScreenDateAtTime.
  ///
  /// In en, this message translates to:
  /// **'{date} at {time}'**
  String memoryDetailScreenDateAtTime(String date, String time);

  /// No description provided for @timelineScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timelineScreenTitle;

  /// No description provided for @timelineScreenMemoriesMapTooltip.
  ///
  /// In en, this message translates to:
  /// **'Memories map'**
  String get timelineScreenMemoriesMapTooltip;

  /// No description provided for @timelineScreenFreeLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You have reached the free limit of 30 memories. Unlock unlimited Memories in DYOS+.'**
  String get timelineScreenFreeLimitMessage;

  /// No description provided for @timelineScreenLoadOlderMemories.
  ///
  /// In en, this message translates to:
  /// **'Load older memories'**
  String get timelineScreenLoadOlderMemories;

  /// No description provided for @timelineScreenAllCategoriesLabel.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get timelineScreenAllCategoriesLabel;

  /// No description provided for @timelineScreenMemoriesLimitFreeLabel.
  ///
  /// In en, this message translates to:
  /// **'Memories limit (Free)'**
  String get timelineScreenMemoriesLimitFreeLabel;

  /// No description provided for @timelineScreenMemoriesLimitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} / {limit} memories on the free plan'**
  String timelineScreenMemoriesLimitSubtitle(int count, int limit);

  /// No description provided for @timelineScreenErrorLoadingMemories.
  ///
  /// In en, this message translates to:
  /// **'Error loading memories'**
  String get timelineScreenErrorLoadingMemories;

  /// No description provided for @timelineScreenNoMemoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No memories yet'**
  String get timelineScreenNoMemoriesYet;

  /// No description provided for @timelineScreenStartCreatingMemories.
  ///
  /// In en, this message translates to:
  /// **'Start creating memories with your partner!'**
  String get timelineScreenStartCreatingMemories;

  /// No description provided for @timelineScreenFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get timelineScreenFailedToLoad;

  /// No description provided for @memoryDetailDialogDeleteMemoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete memory?'**
  String get memoryDetailDialogDeleteMemoryTitle;

  /// No description provided for @memoryDetailDialogDeleteMemoryContent.
  ///
  /// In en, this message translates to:
  /// **'This memory will be removed. This cannot be undone.'**
  String get memoryDetailDialogDeleteMemoryContent;

  /// No description provided for @memoryDetailDialogMemoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Memory deleted'**
  String get memoryDetailDialogMemoryDeleted;

  /// No description provided for @memoryDetailDialogFailedToDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete: {error}'**
  String memoryDetailDialogFailedToDelete(String error);

  /// No description provided for @memoryDetailDialogNoPhotos.
  ///
  /// In en, this message translates to:
  /// **'No Photos'**
  String get memoryDetailDialogNoPhotos;

  /// No description provided for @memoryDetailDialogMemoryFallback.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get memoryDetailDialogMemoryFallback;

  /// No description provided for @memoryDetailDialogDateAtTime.
  ///
  /// In en, this message translates to:
  /// **'{date} at {time}'**
  String memoryDetailDialogDateAtTime(String date, String time);

  /// No description provided for @pickPlaceScreenApiKeyMissingMessage.
  ///
  /// In en, this message translates to:
  /// **'Add GOOGLE_MAPS_API_KEY to android/local.properties (Android) or GOOGLE_PLACES_API_KEY in ios Secrets.xcconfig, then rebuild. You can still search by address.'**
  String get pickPlaceScreenApiKeyMissingMessage;

  /// No description provided for @pickPlaceScreenPlacesError.
  ///
  /// In en, this message translates to:
  /// **'Places: {message}'**
  String pickPlaceScreenPlacesError(String message);

  /// No description provided for @pickPlaceScreenSearchSuggestionsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Search suggestions unavailable. Use the search icon to find places.'**
  String get pickPlaceScreenSearchSuggestionsUnavailable;

  /// No description provided for @pickPlaceScreenCouldNotLoadPlaceDetails.
  ///
  /// In en, this message translates to:
  /// **'Could not load place details'**
  String get pickPlaceScreenCouldNotLoadPlaceDetails;

  /// No description provided for @pickPlaceScreenNoResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found for this address'**
  String get pickPlaceScreenNoResultsFound;

  /// No description provided for @pickPlaceScreenSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed: {error}'**
  String pickPlaceScreenSearchFailed(String error);

  /// No description provided for @pickPlaceScreenLocationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled'**
  String get pickPlaceScreenLocationServicesDisabled;

  /// No description provided for @pickPlaceScreenLocationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get pickPlaceScreenLocationPermissionDenied;

  /// No description provided for @pickPlaceScreenRestartAppLocation.
  ///
  /// In en, this message translates to:
  /// **'Restart the app to use My location.'**
  String get pickPlaceScreenRestartAppLocation;

  /// No description provided for @pickPlaceScreenCouldNotGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not get location: {error}'**
  String pickPlaceScreenCouldNotGetLocation(String error);

  /// No description provided for @pickPlaceScreenBackTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get pickPlaceScreenBackTooltip;

  /// No description provided for @pickPlaceScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a place'**
  String get pickPlaceScreenTitle;

  /// No description provided for @pickPlaceScreenMapKeyMissingFallback.
  ///
  /// In en, this message translates to:
  /// **'Map preview needs a Google Maps API key in the native build (see docs/ANDROID_GOOGLE_API_KEY.md). Search by address works below.'**
  String get pickPlaceScreenMapKeyMissingFallback;

  /// No description provided for @pickPlaceScreenSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search place or address...'**
  String get pickPlaceScreenSearchHint;

  /// No description provided for @pickPlaceScreenMyLocationTooltip.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get pickPlaceScreenMyLocationTooltip;

  /// No description provided for @pickPlaceScreenTapToSetLocation.
  ///
  /// In en, this message translates to:
  /// **'Tap on the map to set the memory location'**
  String get pickPlaceScreenTapToSetLocation;

  /// No description provided for @pickPlaceScreenPlaceNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Place name (optional)'**
  String get pickPlaceScreenPlaceNameLabel;

  /// No description provided for @pickPlaceScreenPlaceNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Restaurant, Park'**
  String get pickPlaceScreenPlaceNameHint;

  /// No description provided for @levelScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Level'**
  String get levelScreenTitle;

  /// No description provided for @levelScreenBootSequence.
  ///
  /// In en, this message translates to:
  /// **'Boot Sequence'**
  String get levelScreenBootSequence;

  /// No description provided for @levelScreenCollectSpToNextTier.
  ///
  /// In en, this message translates to:
  /// **'Collect {spToNext} SP to get to {nextTier}'**
  String levelScreenCollectSpToNextTier(int spToNext, String nextTier);

  /// No description provided for @levelScreenSpValue.
  ///
  /// In en, this message translates to:
  /// **'{sp} SP'**
  String levelScreenSpValue(int sp);

  /// No description provided for @levelScreenProgressionRewardsHeading.
  ///
  /// In en, this message translates to:
  /// **'Progression & Rewards'**
  String get levelScreenProgressionRewardsHeading;

  /// No description provided for @levelScreenCompleteTasksHeading.
  ///
  /// In en, this message translates to:
  /// **'Complete tasks & win rewards'**
  String get levelScreenCompleteTasksHeading;

  /// No description provided for @levelScreenQuestBlueprintTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete a Blueprint section'**
  String get levelScreenQuestBlueprintTitle;

  /// No description provided for @levelScreenQuestMemoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a memory'**
  String get levelScreenQuestMemoryTitle;

  /// No description provided for @levelScreenQuestEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Add an event'**
  String get levelScreenQuestEventTitle;

  /// No description provided for @levelScreenQuestIntimacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Log intimacy'**
  String get levelScreenQuestIntimacyTitle;

  /// No description provided for @levelScreenCompletedToday.
  ///
  /// In en, this message translates to:
  /// **'Completed today'**
  String get levelScreenCompletedToday;

  /// No description provided for @levelScreenQuestRewardBadge.
  ///
  /// In en, this message translates to:
  /// **'+{sp} SP'**
  String levelScreenQuestRewardBadge(int sp);

  /// No description provided for @systemStatusDemoScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'System Status (Preview)'**
  String get systemStatusDemoScreenTitle;

  /// No description provided for @levelUpUnlockSheetFeatureMemories.
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get levelUpUnlockSheetFeatureMemories;

  /// No description provided for @levelUpUnlockSheetFeatureBlueprints.
  ///
  /// In en, this message translates to:
  /// **'Daily Questions'**
  String get levelUpUnlockSheetFeatureBlueprints;

  /// No description provided for @levelUpUnlockSheetFeatureQuickMessages.
  ///
  /// In en, this message translates to:
  /// **'Quick Messages'**
  String get levelUpUnlockSheetFeatureQuickMessages;

  /// No description provided for @levelUpUnlockSheetFeatureMapView.
  ///
  /// In en, this message translates to:
  /// **'Memory Map'**
  String get levelUpUnlockSheetFeatureMapView;

  /// No description provided for @levelUpUnlockSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Level up to unlock'**
  String get levelUpUnlockSheetTitle;

  /// No description provided for @levelUpUnlockSheetRequirementBody.
  ///
  /// In en, this message translates to:
  /// **'You need {requiredSp} SP to unlock {featureName}. You have {currentSp} SP.'**
  String levelUpUnlockSheetRequirementBody(
    int requiredSp,
    String featureName,
    int currentSp,
  );

  /// No description provided for @levelUpUnlockSheetViewRoadmap.
  ///
  /// In en, this message translates to:
  /// **'View roadmap'**
  String get levelUpUnlockSheetViewRoadmap;

  /// No description provided for @levelUpUnlockSheetGetPremium.
  ///
  /// In en, this message translates to:
  /// **'Get DYOS+'**
  String get levelUpUnlockSheetGetPremium;

  /// No description provided for @systemStatusCardCurrentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current Version: {version}'**
  String systemStatusCardCurrentVersion(String version);

  /// No description provided for @systemStatusCardProgressToNext.
  ///
  /// In en, this message translates to:
  /// **'{currentXp} / {tierMax} SP to {nextLabel}'**
  String systemStatusCardProgressToNext(
    int currentXp,
    int tierMax,
    String nextLabel,
  );

  /// No description provided for @systemStatusCardMaxLevel.
  ///
  /// In en, this message translates to:
  /// **'{currentXp} SP · Max level'**
  String systemStatusCardMaxLevel(int currentXp);

  /// No description provided for @listsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get listsScreenTitle;

  /// No description provided for @listsScreenAddNoteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get listsScreenAddNoteTooltip;

  /// No description provided for @listsScreenBucketListHeading.
  ///
  /// In en, this message translates to:
  /// **'Bucket List'**
  String get listsScreenBucketListHeading;

  /// No description provided for @listsScreenBucketListSubheading.
  ///
  /// In en, this message translates to:
  /// **'Things you want to do together'**
  String get listsScreenBucketListSubheading;

  /// No description provided for @listsScreenEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No bucket list items yet'**
  String get listsScreenEmptyTitle;

  /// No description provided for @listsScreenEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first item'**
  String get listsScreenEmptySubtitle;

  /// No description provided for @listsScreenErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error loading bucket list'**
  String get listsScreenErrorTitle;

  /// No description provided for @listsScreenToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get listsScreenToday;

  /// No description provided for @listsScreenYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get listsScreenYesterday;

  /// No description provided for @listsScreenDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day ago} other{{count} days ago}}'**
  String listsScreenDaysAgo(int count);

  /// No description provided for @settingsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreenTitle;

  /// No description provided for @settingsScreenDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsScreenDeleteAccountTitle;

  /// No description provided for @settingsScreenDeleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. This will permanently delete:'**
  String get settingsScreenDeleteAccountWarning;

  /// No description provided for @settingsScreenDeleteAccountBulletList.
  ///
  /// In en, this message translates to:
  /// **'• Your account and profile\n• All your memories and photos\n• All intimacy logs and data\n• Your pairing (partner will be unpaired)\n• All notes and lists'**
  String get settingsScreenDeleteAccountBulletList;

  /// No description provided for @settingsScreenDeleteAccountConfirmQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you absolutely sure?'**
  String get settingsScreenDeleteAccountConfirmQuestion;

  /// No description provided for @settingsScreenDeleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete Forever'**
  String get settingsScreenDeleteForever;

  /// No description provided for @settingsScreenDeletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Deleting account...'**
  String get settingsScreenDeletingAccount;

  /// No description provided for @settingsScreenDeleteAccountError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting account: {error}'**
  String settingsScreenDeleteAccountError(String error);

  /// No description provided for @settingsScreenMustBePairedForAnniversary.
  ///
  /// In en, this message translates to:
  /// **'You must be paired to set anniversary date'**
  String get settingsScreenMustBePairedForAnniversary;

  /// No description provided for @settingsScreenSelectAnniversaryDateHelp.
  ///
  /// In en, this message translates to:
  /// **'Select anniversary date'**
  String get settingsScreenSelectAnniversaryDateHelp;

  /// No description provided for @settingsScreenSetAnniversaryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get settingsScreenSetAnniversaryConfirm;

  /// No description provided for @settingsScreenAnniversaryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Anniversary date updated'**
  String get settingsScreenAnniversaryUpdated;

  /// No description provided for @settingsScreenAnniversaryUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating anniversary date: {error}'**
  String settingsScreenAnniversaryUpdateError(String error);

  /// No description provided for @settingsScreenAnniversaryDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Anniversary Date'**
  String get settingsScreenAnniversaryDateLabel;

  /// No description provided for @settingsScreenSetAnniversaryDatePrompt.
  ///
  /// In en, this message translates to:
  /// **'Set your anniversary date'**
  String get settingsScreenSetAnniversaryDatePrompt;

  /// No description provided for @settingsScreenDaysTogether.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day together} other{{count} days together}}'**
  String settingsScreenDaysTogether(int count);

  /// No description provided for @settingsScreenLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get settingsScreenLoading;

  /// No description provided for @settingsScreenAppearanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsScreenAppearanceLabel;

  /// No description provided for @settingsScreenThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsScreenThemeLight;

  /// No description provided for @settingsScreenThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsScreenThemeDark;

  /// No description provided for @settingsScreenThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsScreenThemeSystem;

  /// No description provided for @settingsScreenPairingLabel.
  ///
  /// In en, this message translates to:
  /// **'Pairing'**
  String get settingsScreenPairingLabel;

  /// No description provided for @settingsScreenPairingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your pairing'**
  String get settingsScreenPairingSubtitle;

  /// No description provided for @settingsScreenDeleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account'**
  String get settingsScreenDeleteAccountSubtitle;

  /// No description provided for @settingsScreenLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsScreenLogOut;

  /// No description provided for @settingsScreenLogoutConfirmQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get settingsScreenLogoutConfirmQuestion;

  /// No description provided for @settingsScreenLogoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out and clear session'**
  String get settingsScreenLogoutSubtitle;

  /// No description provided for @settingsScreenLogoutError.
  ///
  /// In en, this message translates to:
  /// **'Error logging out: {error}'**
  String settingsScreenLogoutError(String error);

  /// No description provided for @addNoteScreenContentEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Content cannot be empty'**
  String get addNoteScreenContentEmptyError;

  /// No description provided for @addNoteScreenNotAuthenticatedError.
  ///
  /// In en, this message translates to:
  /// **'User not authenticated. Please log in again.'**
  String get addNoteScreenNotAuthenticatedError;

  /// No description provided for @addNoteScreenNotPairedError.
  ///
  /// In en, this message translates to:
  /// **'You are not paired with a partner. Please pair first.'**
  String get addNoteScreenNotPairedError;

  /// No description provided for @addNoteScreenSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Note saved successfully!'**
  String get addNoteScreenSaveSuccess;

  /// No description provided for @addNoteScreenSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving note: {error}'**
  String addNoteScreenSaveError(String error);

  /// No description provided for @addNoteScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNoteScreenTitle;

  /// No description provided for @addNoteScreenTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title (optional)'**
  String get addNoteScreenTitleLabel;

  /// No description provided for @addNoteScreenTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Add a title...'**
  String get addNoteScreenTitleHint;

  /// No description provided for @addNoteScreenContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get addNoteScreenContentLabel;

  /// No description provided for @addNoteScreenContentHint.
  ///
  /// In en, this message translates to:
  /// **'Write your note here...'**
  String get addNoteScreenContentHint;

  /// No description provided for @addNoteScreenContentRequired.
  ///
  /// In en, this message translates to:
  /// **'Content is required'**
  String get addNoteScreenContentRequired;

  /// No description provided for @addNoteScreenTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get addNoteScreenTypeLabel;

  /// No description provided for @addNoteScreenTypeShared.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get addNoteScreenTypeShared;

  /// No description provided for @addNoteScreenTypePrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get addNoteScreenTypePrivate;

  /// No description provided for @addNoteScreenTypeBucketList.
  ///
  /// In en, this message translates to:
  /// **'Bucket List'**
  String get addNoteScreenTypeBucketList;

  /// No description provided for @addNoteScreenTypeSecretGift.
  ///
  /// In en, this message translates to:
  /// **'Secret Gift'**
  String get addNoteScreenTypeSecretGift;

  /// No description provided for @addNoteScreenSaveNoteButton.
  ///
  /// In en, this message translates to:
  /// **'Save Note'**
  String get addNoteScreenSaveNoteButton;

  /// No description provided for @secretNotesScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Secret Notes'**
  String get secretNotesScreenTitle;

  /// No description provided for @secretNotesScreenTabSecretGift.
  ///
  /// In en, this message translates to:
  /// **'Secret Gift'**
  String get secretNotesScreenTabSecretGift;

  /// No description provided for @secretNotesScreenTabPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get secretNotesScreenTabPrivate;

  /// No description provided for @secretNotesScreenEmptySecretGiftTitle.
  ///
  /// In en, this message translates to:
  /// **'No secret gift ideas yet'**
  String get secretNotesScreenEmptySecretGiftTitle;

  /// No description provided for @secretNotesScreenEmptySecretGiftSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first secret gift idea'**
  String get secretNotesScreenEmptySecretGiftSubtitle;

  /// No description provided for @secretNotesScreenEmptyPrivateTitle.
  ///
  /// In en, this message translates to:
  /// **'No private notes yet'**
  String get secretNotesScreenEmptyPrivateTitle;

  /// No description provided for @secretNotesScreenEmptyPrivateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first private note'**
  String get secretNotesScreenEmptyPrivateSubtitle;

  /// No description provided for @secretNotesScreenErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error loading notes'**
  String get secretNotesScreenErrorTitle;

  /// No description provided for @secretNotesScreenToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get secretNotesScreenToday;

  /// No description provided for @secretNotesScreenYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get secretNotesScreenYesterday;

  /// No description provided for @secretNotesScreenDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day ago} other{{count} days ago}}'**
  String secretNotesScreenDaysAgo(int count);

  /// No description provided for @premiumLandingScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'DYOS+'**
  String get premiumLandingScreenTitle;

  /// No description provided for @premiumLandingScreenYouHavePremium.
  ///
  /// In en, this message translates to:
  /// **'You have DYOS+'**
  String get premiumLandingScreenYouHavePremium;

  /// No description provided for @premiumLandingScreenOneSubscriptionBoth.
  ///
  /// In en, this message translates to:
  /// **'One subscription for both of you.'**
  String get premiumLandingScreenOneSubscriptionBoth;

  /// No description provided for @premiumLandingScreenChooseYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose your plan'**
  String get premiumLandingScreenChooseYourPlan;

  /// No description provided for @premiumLandingScreenLoadPlansError.
  ///
  /// In en, this message translates to:
  /// **'Could not load plans: {error}. Pull down to retry.'**
  String premiumLandingScreenLoadPlansError(String error);

  /// No description provided for @premiumLandingScreenCancelAnytimeNote.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime. One subscription for both of you.'**
  String get premiumLandingScreenCancelAnytimeNote;

  /// No description provided for @premiumLandingScreenHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'More for the two of you'**
  String get premiumLandingScreenHeroSubtitle;

  /// No description provided for @premiumLandingScreenHeroDescription.
  ///
  /// In en, this message translates to:
  /// **'Unlimited memories, insights, and no limits. One plan, both of you.'**
  String get premiumLandingScreenHeroDescription;

  /// No description provided for @premiumLandingScreenInstantBenefits.
  ///
  /// In en, this message translates to:
  /// **'Instant benefits'**
  String get premiumLandingScreenInstantBenefits;

  /// No description provided for @premiumLandingScreenNoPlansAvailable.
  ///
  /// In en, this message translates to:
  /// **'No plans available right now. Pull down to retry.'**
  String get premiumLandingScreenNoPlansAvailable;

  /// No description provided for @premiumLandingScreenNoPlansConfigured.
  ///
  /// In en, this message translates to:
  /// **'No plans configured. Pull down to retry.'**
  String get premiumLandingScreenNoPlansConfigured;

  /// No description provided for @premiumLandingScreenYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get premiumLandingScreenYearly;

  /// No description provided for @premiumLandingScreenMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get premiumLandingScreenMonthly;

  /// No description provided for @premiumLandingScreenYearlyBilling.
  ///
  /// In en, this message translates to:
  /// **'Yearly billing'**
  String get premiumLandingScreenYearlyBilling;

  /// No description provided for @premiumLandingScreenMonthlyBilling.
  ///
  /// In en, this message translates to:
  /// **'Monthly billing'**
  String get premiumLandingScreenMonthlyBilling;

  /// No description provided for @premiumLandingScreenGetPremiumNow.
  ///
  /// In en, this message translates to:
  /// **'Get DYOS+ now'**
  String get premiumLandingScreenGetPremiumNow;

  /// No description provided for @premiumLandingScreenRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get premiumLandingScreenRestore;

  /// No description provided for @premiumLandingScreenPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get premiumLandingScreenPrivacy;

  /// No description provided for @premiumLandingScreenTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get premiumLandingScreenTerms;

  /// No description provided for @paywallModalTitle.
  ///
  /// In en, this message translates to:
  /// **'DYOS+'**
  String get paywallModalTitle;

  /// No description provided for @paywallModalLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load plans. Please try again.'**
  String get paywallModalLoadError;

  /// No description provided for @paywallModalNoPlansAvailable.
  ///
  /// In en, this message translates to:
  /// **'No plans available.'**
  String get paywallModalNoPlansAvailable;

  /// No description provided for @paywallModalYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get paywallModalYearly;

  /// No description provided for @paywallModalMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get paywallModalMonthly;

  /// No description provided for @paywallModalMonthlyBilling.
  ///
  /// In en, this message translates to:
  /// **'Monthly billing'**
  String get paywallModalMonthlyBilling;

  /// No description provided for @paywallModalRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get paywallModalRestorePurchases;
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
      <String>['cs', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
