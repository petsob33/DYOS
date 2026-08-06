// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSave => 'Save';

  @override
  String get dataScreenTitle => 'Data & Analytics';

  @override
  String dataScreenError(String error) {
    return 'Error: $error';
  }

  @override
  String get dataScreenHeading => 'Relationship Insights';

  @override
  String get dataScreenSubheading =>
      'Track patterns and trends in your relationship';

  @override
  String get dataScreenTotalCountTitle => 'Total Count';

  @override
  String get dataScreenAllTime => 'All time';

  @override
  String get dataScreenAvgPerWeekTitle => 'Avg/Week';

  @override
  String get dataScreenAverage => 'Average';

  @override
  String get dataScreenFavoriteDayTitle => 'Favorite Day';

  @override
  String get dataScreenMostActive => 'Most active';

  @override
  String get dataScreenBestOfHeading => 'Best Of';

  @override
  String get dataScreenLongestSexTitle => 'Longest Sex';

  @override
  String get dataScreenThisMonthSubtitle => 'This month';

  @override
  String get dataScreenHeartsStreakTitle => 'Hearts Streak';

  @override
  String dataScreenStreakDaySubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days in a row',
      one: 'day in a row',
    );
    return '$_temp0';
  }

  @override
  String get dataScreenCurrentMonthHeading => 'This Month';

  @override
  String get dataScreenTotalTitle => 'Total';

  @override
  String get dataScreenAvgDurationTitle => 'Avg Duration';

  @override
  String get dataScreenAvgOrgasmsTitle => 'Avg Orgasms';

  @override
  String get dataScreenFrequencyChartHeading => 'Frequency Chart';

  @override
  String get dataScreenInitiatorChartHeading => 'Initiator Chart';

  @override
  String get dataScreenYouLabel => 'You';

  @override
  String get dataScreenPartnerLabel => 'Partner';

  @override
  String get dataScreenOrgasmComparisonHeading => 'Orgasm Comparison';

  @override
  String get dataScreenNoDataYet => 'No data yet';

  @override
  String get dataScreenTagsRadarHeading => 'Tags Radar';

  @override
  String get dataScreenNoTagsYet => 'No tags yet';

  @override
  String get dataScreenHistoryHeading => 'History';

  @override
  String get loginScreenResetPasswordTitle => 'Reset Password';

  @override
  String get loginScreenResetPasswordBody =>
      'Enter your email address and we\'ll send you a link to reset your password.';

  @override
  String get loginScreenEmailLabel => 'Email';

  @override
  String get loginScreenEmailHint => 'your@email.com';

  @override
  String get loginScreenSendButton => 'Send';

  @override
  String get loginScreenResetEmailSent =>
      'Password reset email sent! Check your inbox.';

  @override
  String loginScreenGenericError(String error) {
    return 'Error: $error';
  }

  @override
  String get loginScreenAccountNotFoundTitle => 'Account not found';

  @override
  String get loginScreenAccountNotFoundBody =>
      'No account was found for this email. Would you like to create a new account?';

  @override
  String get loginScreenRegisterAction => 'Register';

  @override
  String get loginScreenWelcomeBack => 'Welcome back';

  @override
  String get loginScreenSignInToContinue => 'Sign in to continue';

  @override
  String get loginScreenEmailRequired => 'Please enter your email';

  @override
  String get loginScreenEmailInvalid => 'Please enter a valid email';

  @override
  String get loginScreenPasswordLabel => 'Password';

  @override
  String get loginScreenPasswordRequired => 'Please enter your password';

  @override
  String get loginScreenPasswordTooShort =>
      'Password must be at least 6 characters';

  @override
  String get loginScreenForgotPassword => 'Forgot password?';

  @override
  String get loginScreenSignInButton => 'Sign in';

  @override
  String get loginScreenOrDivider => 'OR';

  @override
  String get loginScreenContinueWithGoogle => 'Continue with Google';

  @override
  String get loginScreenNoAccountPrompt => 'Don\'t have an account? ';

  @override
  String get loginScreenSignUpButton => 'Sign up';

  @override
  String get registerScreenCreateAccount => 'Create account';

  @override
  String get registerScreenSignUpToGetStarted => 'Sign up to get started';

  @override
  String get registerScreenFullNameLabel => 'Full name';

  @override
  String get registerScreenNameRequired => 'Please enter your name';

  @override
  String get registerScreenNameTooShort => 'Name must be at least 2 characters';

  @override
  String get registerScreenPasswordRequired => 'Please enter a password';

  @override
  String get registerScreenConfirmPasswordLabel => 'Confirm password';

  @override
  String get registerScreenConfirmPasswordRequired =>
      'Please confirm your password';

  @override
  String get registerScreenPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get registerScreenSignUpButton => 'Sign up';

  @override
  String get registerScreenAlreadyHaveAccountPrompt =>
      'Already have an account? ';

  @override
  String get registerScreenSignInButton => 'Sign in';

  @override
  String get pairingScreenAppBarTitle => 'Connect with Partner';

  @override
  String get pairingScreenSignOut => 'Sign Out';

  @override
  String get pairingScreenSignOutConfirm =>
      'Are you sure you want to sign out?';

  @override
  String get pairingScreenHeading => 'Enter your partner\'s email';

  @override
  String get pairingScreenSubheading =>
      'Both of you must already have an account';

  @override
  String get pairingScreenEmailHint => 'partner@email.com';

  @override
  String get pairingScreenEmailRequired => 'Please enter an email address';

  @override
  String get pairingScreenEmailInvalid => 'Enter a valid email address';

  @override
  String get pairingScreenCannotPairSelf => 'You cannot pair with yourself';

  @override
  String pairingScreenPairedWith(String name) {
    return 'Paired with $name!';
  }

  @override
  String get pairingScreenGenericError =>
      'Unable to pair right now. Check your connection.';

  @override
  String get pairingScreenPairButton => 'Pair';

  @override
  String get profileScreenTitle => 'Profile';

  @override
  String get profileScreenUserNotFound => 'User not found';

  @override
  String get profileScreenNoName => 'No name';

  @override
  String get profileScreenPartnerHeading => 'Partner';

  @override
  String get profileScreenNoPartnerPaired => 'No partner paired';

  @override
  String profileScreenErrorLoadingPartner(String error) {
    return 'Error loading partner: $error';
  }

  @override
  String get profileScreenActionsHeading => 'Actions';

  @override
  String get profileScreenUpgradeAction => 'DYOS+ / Upgrade';

  @override
  String get profileScreenSecretGiftAction => 'Secret gift / Private';

  @override
  String get profileScreenSettingsAction => 'Settings';

  @override
  String profileScreenErrorLoadingProfile(String error) {
    return 'Error loading profile: $error';
  }

  @override
  String get editProfilePictureScreenTitle => 'Edit Profile Picture';

  @override
  String editProfilePictureScreenPickError(String error) {
    return 'Error picking image: $error';
  }

  @override
  String get editProfilePictureScreenSelectImageFirst =>
      'Please select an image first';

  @override
  String get editProfilePictureScreenUserNotFound => 'User not found';

  @override
  String get editProfilePictureScreenUpdateSuccess =>
      'Profile picture updated successfully!';

  @override
  String editProfilePictureScreenGenericError(String error) {
    return 'Error: $error';
  }

  @override
  String get editProfilePictureScreenChooseImage => 'Choose Image';

  @override
  String get editProfilePictureScreenSaveButton => 'Save Profile Picture';

  @override
  String get firebaseTestScreenTitle => 'Firebase Connection Test';

  @override
  String get firebaseTestScreenRerunTooltip => 'Run tests again';

  @override
  String get firebaseTestScreenRunning => 'Running tests...';

  @override
  String get firebaseTestScreenAllPassed => 'All tests passed! ✅';

  @override
  String get firebaseTestScreenSomeFailed => 'Some tests failed ⚠️';

  @override
  String firebaseTestScreenPassedCount(int passed, int total) {
    return 'Passed: $passed / $total';
  }

  @override
  String get firebaseTestScreenNoResults => 'No test results yet';

  @override
  String get firebaseTestScreenWhatToCheckHeading => 'What to check:';

  @override
  String get firebaseTestScreenInstructionAllGreen =>
      '✅ All green = Firebase is properly connected!';

  @override
  String get firebaseTestScreenInstructionCoreFailed =>
      '❌ Firebase Core failed = Check configuration files';

  @override
  String get firebaseTestScreenInstructionFirestoreFailed =>
      '❌ Firestore failed = Enable Firestore in Firebase Console';

  @override
  String get firebaseTestScreenInstructionWriteReadFailed =>
      '❌ Write/Read failed = Check Firestore security rules';

  @override
  String get blueprintDetailScreenXpGranted =>
      'System Updated: +100 XP acquired! 🚀';

  @override
  String get blueprintDetailScreenAlreadyEarned =>
      'Section saved. (XP already earned today.)';

  @override
  String get blueprintDetailScreenSectionComplete => 'Section complete!';

  @override
  String get blueprintDetailScreenLoadError =>
      'Could not load this Blueprint section.';

  @override
  String get blueprintDetailScreenNotFound => 'Blueprint section not found.';

  @override
  String get blueprintDetailScreenCompleteButton => 'Complete Section';

  @override
  String get blueprintsListScreenTitle => 'Daily Questions';

  @override
  String get blueprintsListScreenLoadError => 'Could not load Blueprints.';

  @override
  String get blueprintsListScreenIntro =>
      'Save your preferences as a couple. Complete a section to earn +100 XP.';

  @override
  String blueprintsListScreenQuestionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '1 question',
    );
    return '$_temp0';
  }

  @override
  String blueprintQuestionCardPartnerValue(String value) {
    return 'Partner: $value';
  }

  @override
  String get blueprintQuestionCardYes => 'Yes';

  @override
  String get blueprintQuestionCardNo => 'No';

  @override
  String get cycleSettingsSheetPairFirst => 'Please pair with a partner first';

  @override
  String get cycleSettingsSheetSaved => 'Settings saved successfully!';

  @override
  String cycleSettingsSheetError(String error) {
    return 'Error: $error';
  }

  @override
  String get cycleSettingsSheetTitle => 'Cycle Settings';

  @override
  String get cycleSettingsSheetDayInCycleLabel => 'Day in Cycle';

  @override
  String cycleSettingsSheetDayInCycleValue(int day) {
    return 'Day $day';
  }

  @override
  String get cycleSettingsSheetLastPeriodDateLabel => 'Last Period Date';

  @override
  String get cycleSettingsSheetNotSet => 'Not set';

  @override
  String get cycleSettingsSheetTapToChange => 'Tap to change';

  @override
  String get cycleSettingsSheetAvgCycleLengthLabel => 'Average Cycle Length';

  @override
  String cycleSettingsSheetDaysValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get cycleSettingsSheetPeriodLengthLabel => 'Period Length';

  @override
  String get cycleSettingsSheetHideMenstruationLabel => 'Hide Menstruation';

  @override
  String get cycleSettingsSheetHideMenstruationDescription =>
      'Hide menstruation tracking and display in calendar';

  @override
  String get cycleSettingsSheetLoadError => 'Error loading settings';

  @override
  String get cycleTrackingScreenTitle => 'Calendar';

  @override
  String get cycleTrackingScreenSettingsTooltip => 'Cycle Settings';

  @override
  String get cycleTrackingScreenToday => 'Today';

  @override
  String get cycleTrackingScreenYesterday => 'Yesterday';

  @override
  String get cycleTrackingScreenTomorrow => 'Tomorrow';

  @override
  String get cycleTrackingScreenMemoriesHeading => 'Memories';

  @override
  String get cycleTrackingScreenIntimacyHeading => 'Intimacy';

  @override
  String cycleTrackingScreenRating(int rating) {
    return 'Rating: $rating/5';
  }

  @override
  String get cycleTrackingScreenEventsHeading => 'Events';

  @override
  String get cycleTrackingScreenAddMemoryButton => 'Add Memory';

  @override
  String get cycleTrackingScreenAddIntimacyButton => 'Add Intimacy';

  @override
  String get cycleTrackingScreenAddEventButton => 'Add Event';

  @override
  String get cycleTrackingScreenAddPeriodLogButton => 'Add Period Log';

  @override
  String get cycleTrackingScreenLegendHeading => 'Legend';

  @override
  String get cycleTrackingScreenMenstruationLabel => 'Menstruation';

  @override
  String get cycleTrackingScreenFollicularLabel => 'Follicular';

  @override
  String get cycleTrackingScreenOvulationFertileLabel => 'Ovulation/Fertile';

  @override
  String get cycleTrackingScreenLutealPmsLabel => 'Luteal/PMS';

  @override
  String get cycleTrackingScreenPairFirst => 'Please pair with a partner first';

  @override
  String get cycleTrackingScreenLogUpdated => 'Cycle log updated successfully!';

  @override
  String get cycleTrackingScreenLogAdded => 'Cycle log added successfully!';

  @override
  String cycleTrackingScreenError(String error) {
    return 'Error: $error';
  }

  @override
  String get cycleTrackingScreenEditLogTitle => 'Edit Cycle Log';

  @override
  String get cycleTrackingScreenAddLogTitle => 'Add Cycle Log';

  @override
  String get cycleTrackingScreenFlowIntensityLabel => 'Flow Intensity';

  @override
  String get cycleTrackingScreenMoodLabel => 'Mood';

  @override
  String get cycleTrackingScreenUpdateLogButton => 'Update Log';

  @override
  String get cycleTrackingScreenAddLogButton => 'Add Log';

  @override
  String get addEventSheetTitleRequired => 'Please enter a title';

  @override
  String get addEventSheetPairFirst => 'Please pair with a partner first';

  @override
  String get addEventSheetAddedWithXp => 'Event added! +15 XP';

  @override
  String get addEventSheetAddedXpAlreadyEarned =>
      'Event added! XP for this activity is granted once per day.';

  @override
  String get addEventSheetUpdated => 'Event updated successfully!';

  @override
  String get addEventSheetAdded => 'Event added successfully!';

  @override
  String addEventSheetError(String error) {
    return 'Error: $error';
  }

  @override
  String get addEventSheetEditTitle => 'Edit Event';

  @override
  String get addEventSheetAddTitle => 'Add Event';

  @override
  String get addEventSheetTitleLabel => 'Title';

  @override
  String get addEventSheetTitleHint => 'Enter event title';

  @override
  String get addEventSheetUpdateButton => 'Update Event';

  @override
  String get addEventSheetAddButton => 'Add Event';

  @override
  String get addEventSheetDateTimeLabel => 'Date & Time';

  @override
  String get addEventSheetToday => 'Today';

  @override
  String get addEventSheetYesterday => 'Yesterday';

  @override
  String get addEventSheetTomorrow => 'Tomorrow';

  @override
  String get eventsScreenBackTooltip => 'Back';

  @override
  String get eventsScreenTitle => 'Events';

  @override
  String get eventsScreenAddEventTooltip => 'Add event';

  @override
  String eventsScreenDebugEventsLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Debug: $count events loaded',
      one: 'Debug: 1 event loaded',
    );
    return '$_temp0';
  }

  @override
  String get eventsScreenNoEventsOnDay => 'No events on this day';

  @override
  String get eventsScreenNoEventsYet => 'No events yet';

  @override
  String get eventsScreenAddEventButton => 'Add event';

  @override
  String eventsScreenLoadError(String error) {
    return 'Error loading events: $error';
  }

  @override
  String get eventsScreenDeleteDialogTitle => 'Delete Event';

  @override
  String eventsScreenDeleteConfirmMessage(String title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get eventsScreenPairFirst => 'Please pair with a partner first';

  @override
  String get eventsScreenDeleted => 'Event deleted successfully';

  @override
  String eventsScreenError(String error) {
    return 'Error: $error';
  }

  @override
  String get eventsScreenDeleteEventTooltip => 'Delete event';

  @override
  String get intimacyHistoryScreenTitle => 'Intimacy History';

  @override
  String get addIntimacySheetPairFirst => 'Please pair with a partner first';

  @override
  String get addIntimacySheetSelectInitiator => 'Please select an initiator';

  @override
  String get addIntimacySheetAddedWithXp => 'Intimacy log added! +20 XP';

  @override
  String get addIntimacySheetAddedXpAlreadyGranted =>
      'Intimacy log added! XP for this activity is granted once per day.';

  @override
  String get addIntimacySheetUpdatedSuccess =>
      'Intimacy log updated successfully!';

  @override
  String get addIntimacySheetAddedSuccess => 'Intimacy log added successfully!';

  @override
  String addIntimacySheetError(String error) {
    return 'Error: $error';
  }

  @override
  String get addIntimacySheetEditTitle => 'Edit Intimacy Log';

  @override
  String get addIntimacySheetAddTitle => 'Add Intimacy Log';

  @override
  String get addIntimacySheetMeFallback => 'Me';

  @override
  String get addIntimacySheetUpdateButton => 'Update Log';

  @override
  String get addIntimacySheetAddButton => 'Add Log';

  @override
  String get addIntimacySheetNoteFieldLabel => 'Note (optional)';

  @override
  String get addIntimacySheetNoteHint => 'Add any notes...';

  @override
  String get addIntimacySheetDateTimeLabel => 'Date & Time';

  @override
  String get addIntimacySheetToday => 'Today';

  @override
  String get addIntimacySheetYesterday => 'Yesterday';

  @override
  String get addIntimacySheetRatingLabel => 'Rating';

  @override
  String get addIntimacySheetInitiatorLabel => 'Initiator';

  @override
  String get addIntimacySheetTagsLabel => 'Tags';

  @override
  String get addIntimacySheetProtectionUsedLabel => 'Protection Used';

  @override
  String get addIntimacySheetProtectionSubtitle =>
      'Was protection used during intimacy?';

  @override
  String get addIntimacySheetOrgasmsLabel => 'Orgasms';

  @override
  String get addIntimacySheetDurationLabel => 'Duration';

  @override
  String get addIntimacySheetDurationFieldLabel => 'Duration (minutes)';

  @override
  String get addIntimacySheetDurationHint => 'e.g., 30';

  @override
  String get addIntimacySheetLocationLabel => 'Location';

  @override
  String get addIntimacySheetLocationFieldLabel => 'Location (optional)';

  @override
  String get addIntimacySheetLocationHint => 'e.g., Home, Hotel, Beach...';

  @override
  String get intimacyHistoryListViewAllButton => 'View All';

  @override
  String get intimacyHistoryListLoadOlderButton => 'Load older logs';

  @override
  String get intimacyHistoryListErrorTitle => 'Error loading logs';

  @override
  String get intimacyHistoryListEmptyTitle => 'No memories yet';

  @override
  String get intimacyHistoryListEmptySubtitle => 'Time to change that? 😉';

  @override
  String intimacyHistoryListDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get intimacyLogDetailSheetTitle => 'Intimacy Log Details';

  @override
  String get intimacyLogDetailSheetDateTimeLabel => 'Date & Time';

  @override
  String intimacyLogDetailSheetDateTimeValue(String date, String time) {
    return '$date at $time';
  }

  @override
  String get intimacyLogDetailSheetRatingLabel => 'Rating';

  @override
  String get intimacyLogDetailSheetInitiatorLabel => 'Initiator';

  @override
  String get intimacyLogDetailSheetMeFallback => 'Me';

  @override
  String get intimacyLogDetailSheetTagsLabel => 'Tags';

  @override
  String get intimacyLogDetailSheetProtectionLabel => 'Protection';

  @override
  String get intimacyLogDetailSheetProtectionUsed => 'Used';

  @override
  String get intimacyLogDetailSheetProtectionNotUsed => 'Not used';

  @override
  String get intimacyLogDetailSheetOrgasmsLabel => 'Orgasms';

  @override
  String get intimacyLogDetailSheetDurationLabel => 'Duration';

  @override
  String intimacyLogDetailSheetDurationValue(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '$minutes minute',
    );
    return '$_temp0';
  }

  @override
  String get intimacyLogDetailSheetLocationLabel => 'Location';

  @override
  String get intimacyLogDetailSheetNoteLabel => 'Note';

  @override
  String get intimacyLogDetailSheetDeleteConfirmTitle => 'Delete intimacy log?';

  @override
  String get intimacyLogDetailSheetDeleteConfirmBody =>
      'This action cannot be undone.';

  @override
  String get intimacyLogDetailSheetDeletedSnackbar => 'Intimacy log deleted';

  @override
  String intimacyLogDetailSheetDeleteFailedSnackbar(String error) {
    return 'Failed to delete log: $error';
  }

  @override
  String get appRouterMemoryNotFound => 'Memory not found';

  @override
  String get appRouterNavHome => 'Home';

  @override
  String get appRouterNavMemory => 'Memory';

  @override
  String get appRouterNavData => 'Data';

  @override
  String get appRouterNavCalendar => 'Calendar';

  @override
  String get appRouterQuickActionsHeading => 'Quick actions';

  @override
  String get appRouterQuickActionAddNote => 'Add note';

  @override
  String get appRouterQuickActionAddMemory => 'Add memory';

  @override
  String get appRouterQuickActionLogIntimacy => 'Log intimacy';

  @override
  String get appRouterQuickActionAddEvent => 'Add event';

  @override
  String get chatScreenShortcutThinkingOfYou => 'Thinking of you 💭';

  @override
  String get chatScreenShortcutMissYou => 'Miss you ❤️';

  @override
  String get chatScreenShortcutLoveYou => 'Love you 😘';

  @override
  String get chatScreenShortcutSeeYouSoon => 'See you soon 👋';

  @override
  String get chatScreenShortcutGoodMorning => 'Good morning ☀️';

  @override
  String get chatScreenShortcutGoodNight => 'Good night 🌙';

  @override
  String get chatScreenShortcutHowAreYou => 'How are you? 😊';

  @override
  String chatScreenSendMessageError(String error) {
    return 'Could not send message: $error';
  }

  @override
  String chatScreenSendTouchError(String error) {
    return 'Could not send touch: $error';
  }

  @override
  String get chatScreenPartnerFallback => 'Partner';

  @override
  String get chatScreenPairPrompt =>
      'Pair with your partner to start chatting.';

  @override
  String get chatScreenEmptyState => 'No messages or touches yet.\nSay hi 👋';

  @override
  String get chatScreenLoadHistoryError => 'Could not load chat history.';

  @override
  String get chatScreenTouchLabel => 'Touch';

  @override
  String get chatScreenSendTouchTooltip => 'Send a touch';

  @override
  String get chatScreenMessageHint => 'Type a message...';

  @override
  String get chatScreenSendTooltip => 'Send';

  @override
  String get homeScreenUserNotFound => 'User not found';

  @override
  String get homeScreenNotPaired => 'Not paired. Please pair first.';

  @override
  String get homeScreenTestNotificationsTitle => 'Test Notifications';

  @override
  String get homeScreenHapticSentMessage =>
      'Haptic signal sent! Check console/logs for details.';

  @override
  String homeScreenGenericError(String error) {
    return 'Error: $error';
  }

  @override
  String get homeScreenTestHapticSignalButton => 'Test Haptic Signal';

  @override
  String get homeScreenQuickMessageSentMessage =>
      'Quick message sent! Check console/logs for details.';

  @override
  String get homeScreenTestQuickMessageButton => 'Test Quick Message';

  @override
  String get homeScreenSettingsTooltip => 'Settings';

  @override
  String get homeScreenTitle => 'Home';

  @override
  String get homeScreenSubtitle => 'Widgets for your life';

  @override
  String appBarLevelStripXpLabel(int xp) {
    return '$xp SP';
  }

  @override
  String get countdownCardTitle => 'Countdown';

  @override
  String get countdownCardNoEvents => 'No upcoming events';

  @override
  String countdownCardDaysUntil(int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '$_temp0 until $title';
  }

  @override
  String get countdownCardError => 'Error loading events';

  @override
  String get daysTogetherCardTitle => 'Days Together';

  @override
  String get daysTogetherCardSetDate => 'Set your anniversary date';

  @override
  String get intimacySparkCardNoActivity => 'No activity yet';

  @override
  String intimacySparkCardDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '$count day ago',
      zero: 'Today',
    );
    return '$_temp0';
  }

  @override
  String get intimacySparkCardError => 'Error loading data';

  @override
  String get quickMessageNotificationOverlayLabel => 'Quick Message';

  @override
  String get quickNoteCardPromptWriteSomethingNice =>
      'Write me something nice...';

  @override
  String get quickNoteCardPromptDontForget => 'Don\'t forget...';

  @override
  String get quickNoteCardPromptDoorCode => 'The door code is...';

  @override
  String get quickNoteCardPromptSecretPhrase => 'Today\'s secret phrase?';

  @override
  String get quickNoteCardHeaderLabel => 'STICKY NOTE';

  @override
  String get statusHeaderPairPrompt => 'Pair with your partner to view status';

  @override
  String get statusHeaderYouFallback => 'You';

  @override
  String get statusHeaderPartnerFallback => 'Partner';

  @override
  String get statusHeaderReadyStatus => 'Ready';

  @override
  String get statusHeaderLoadingStatus => 'Loading...';

  @override
  String get statusHeaderErrorStatus => 'Error';

  @override
  String get statusHeaderUpdateStatusTitle => 'Update Status';

  @override
  String get statusHeaderChooseEmojiLabel => 'Choose emoji';

  @override
  String get statusHeaderStatusLabel => 'Status';

  @override
  String get statusHeaderStatusUpdatedMessage => 'Status updated';

  @override
  String statusHeaderUpdateErrorMessage(String error) {
    return 'Error updating status: $error';
  }

  @override
  String get tapticTouchCardUnlockPrompt =>
      'Unlock with DYOS+ or via the Roadmap';

  @override
  String get tapticTouchCardSentLabel => 'Sent';

  @override
  String get tapticTouchCardSentToPartnerMessage => 'Sent to partner';

  @override
  String tapticTouchCardSendErrorMessage(String error) {
    return 'Error sending: $error';
  }

  @override
  String addMemoryScreenErrorPickingImages(String error) {
    return 'Error picking images: $error';
  }

  @override
  String addMemoryScreenErrorPickingImage(String error) {
    return 'Error picking image: $error';
  }

  @override
  String get addMemoryScreenMemoryUpdated => 'Memory updated';

  @override
  String get addMemoryScreenFreeLimitMessage =>
      'You have reached the free limit of 30 memories. Unlock unlimited Memories in DYOS+.';

  @override
  String get addMemoryScreenAddImageOrCaption =>
      'Please add at least one image or a caption';

  @override
  String get addMemoryScreenMemorySavedXp => 'Memory saved! +25 XP';

  @override
  String get addMemoryScreenMemorySavedXpOncePerDay =>
      'Memory saved! XP for this activity is granted once per day.';

  @override
  String addMemoryScreenMemoryUpdatedWithCaption(String caption) {
    return 'Memory \"$caption\" updated.';
  }

  @override
  String get addMemoryScreenUntitledCaption => 'Untitled';

  @override
  String get addMemoryScreenEditMemoryTitle => 'Edit Memory';

  @override
  String get addMemoryScreenAddMemoryTitle => 'Add Memory';

  @override
  String get addMemoryScreenCaptionLabel => 'Caption';

  @override
  String get addMemoryScreenCaptionHint => 'What\'s this memory about?';

  @override
  String get addMemoryScreenPhotosVideosLabel => 'Photos & Videos';

  @override
  String get addMemoryScreenAddPhotos => 'Add Photos';

  @override
  String get addMemoryScreenAddMorePhotos => 'Add More Photos';

  @override
  String get addMemoryScreenDateLabel => 'Date';

  @override
  String get addMemoryScreenCategoryLabel => 'Category';

  @override
  String get addMemoryScreenPlaceLabel => 'Place';

  @override
  String get addMemoryScreenAddPlace => 'Add place';

  @override
  String get addMemoryScreenLocationSet => 'Location set';

  @override
  String get addMemoryScreenChangePlaceTooltip => 'Change place';

  @override
  String get addMemoryScreenRemovePlaceTooltip => 'Remove place';

  @override
  String get addMemoryScreenUpdateMemoryButton => 'Update Memory';

  @override
  String get addMemoryScreenSaveMemoryButton => 'Save Memory';

  @override
  String get memoriesMapScreenBackTooltip => 'Back';

  @override
  String get memoriesMapScreenTitle => 'Memories map';

  @override
  String get memoriesMapScreenNoMemoriesYet => 'No memories with a place yet';

  @override
  String memoriesMapScreenError(String error) {
    return 'Error: $error';
  }

  @override
  String get memoriesMapScreenSearchHint => 'Search place or address...';

  @override
  String get memoriesMapScreenMyLocationTooltip => 'My location';

  @override
  String get memoriesMapScreenMapKeyMissingMessage =>
      'Map preview needs a Google Maps API key (see docs/ANDROID_GOOGLE_API_KEY.md). Memories with a place are listed below.';

  @override
  String get memoriesMapScreenPlaceFallback => 'Place';

  @override
  String get memoriesMapScreenMemoryFallback => 'Memory';

  @override
  String get memoriesMapScreenUntitledCaption => 'Untitled';

  @override
  String get memoryDetailScreenDeleteMemoryTitle => 'Delete memory?';

  @override
  String get memoryDetailScreenDeleteMemoryContent =>
      'This memory will be removed. This cannot be undone.';

  @override
  String get memoryDetailScreenMemoryDeleted => 'Memory deleted';

  @override
  String memoryDetailScreenFailedToDelete(String error) {
    return 'Failed to delete: $error';
  }

  @override
  String get memoryDetailScreenBackTooltip => 'Back';

  @override
  String get memoryDetailScreenCloseTooltip => 'Close';

  @override
  String memoryDetailScreenPageCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String get memoryDetailScreenDeletingLabel => 'Deleting…';

  @override
  String get memoryDetailScreenFailedToLoadImage => 'Failed to load image';

  @override
  String memoryDetailScreenDateAtTime(String date, String time) {
    return '$date at $time';
  }

  @override
  String get timelineScreenTitle => 'Timeline';

  @override
  String get timelineScreenMemoriesMapTooltip => 'Memories map';

  @override
  String get timelineScreenFreeLimitMessage =>
      'You have reached the free limit of 30 memories. Unlock unlimited Memories in DYOS+.';

  @override
  String get timelineScreenLoadOlderMemories => 'Load older memories';

  @override
  String get timelineScreenAllCategoriesLabel => 'All';

  @override
  String get timelineScreenMemoriesLimitFreeLabel => 'Memories limit (Free)';

  @override
  String timelineScreenMemoriesLimitSubtitle(int count, int limit) {
    return '$count / $limit memories on the free plan';
  }

  @override
  String get timelineScreenErrorLoadingMemories => 'Error loading memories';

  @override
  String get timelineScreenNoMemoriesYet => 'No memories yet';

  @override
  String get timelineScreenStartCreatingMemories =>
      'Start creating memories with your partner!';

  @override
  String get timelineScreenFailedToLoad => 'Failed to load';

  @override
  String get memoryDetailDialogDeleteMemoryTitle => 'Delete memory?';

  @override
  String get memoryDetailDialogDeleteMemoryContent =>
      'This memory will be removed. This cannot be undone.';

  @override
  String get memoryDetailDialogMemoryDeleted => 'Memory deleted';

  @override
  String memoryDetailDialogFailedToDelete(String error) {
    return 'Failed to delete: $error';
  }

  @override
  String get memoryDetailDialogNoPhotos => 'No Photos';

  @override
  String get memoryDetailDialogMemoryFallback => 'Memory';

  @override
  String memoryDetailDialogDateAtTime(String date, String time) {
    return '$date at $time';
  }

  @override
  String get pickPlaceScreenApiKeyMissingMessage =>
      'Add GOOGLE_MAPS_API_KEY to android/local.properties (Android) or GOOGLE_PLACES_API_KEY in ios Secrets.xcconfig, then rebuild. You can still search by address.';

  @override
  String pickPlaceScreenPlacesError(String message) {
    return 'Places: $message';
  }

  @override
  String get pickPlaceScreenSearchSuggestionsUnavailable =>
      'Search suggestions unavailable. Use the search icon to find places.';

  @override
  String get pickPlaceScreenCouldNotLoadPlaceDetails =>
      'Could not load place details';

  @override
  String get pickPlaceScreenNoResultsFound =>
      'No results found for this address';

  @override
  String pickPlaceScreenSearchFailed(String error) {
    return 'Search failed: $error';
  }

  @override
  String get pickPlaceScreenLocationServicesDisabled =>
      'Location services are disabled';

  @override
  String get pickPlaceScreenLocationPermissionDenied =>
      'Location permission denied';

  @override
  String get pickPlaceScreenRestartAppLocation =>
      'Restart the app to use My location.';

  @override
  String pickPlaceScreenCouldNotGetLocation(String error) {
    return 'Could not get location: $error';
  }

  @override
  String get pickPlaceScreenBackTooltip => 'Back';

  @override
  String get pickPlaceScreenTitle => 'Pick a place';

  @override
  String get pickPlaceScreenMapKeyMissingFallback =>
      'Map preview needs a Google Maps API key in the native build (see docs/ANDROID_GOOGLE_API_KEY.md). Search by address works below.';

  @override
  String get pickPlaceScreenSearchHint => 'Search place or address...';

  @override
  String get pickPlaceScreenMyLocationTooltip => 'My location';

  @override
  String get pickPlaceScreenTapToSetLocation =>
      'Tap on the map to set the memory location';

  @override
  String get pickPlaceScreenPlaceNameLabel => 'Place name (optional)';

  @override
  String get pickPlaceScreenPlaceNameHint => 'e.g. Restaurant, Park';

  @override
  String get levelScreenTitle => 'Your Level';

  @override
  String get levelScreenBootSequence => 'Boot Sequence';

  @override
  String levelScreenCollectSpToNextTier(int spToNext, String nextTier) {
    return 'Collect $spToNext SP to get to $nextTier';
  }

  @override
  String levelScreenSpValue(int sp) {
    return '$sp SP';
  }

  @override
  String get levelScreenProgressionRewardsHeading => 'Progression & Rewards';

  @override
  String get levelScreenCompleteTasksHeading => 'Complete tasks & win rewards';

  @override
  String get levelScreenQuestBlueprintTitle => 'Complete a Blueprint section';

  @override
  String get levelScreenQuestMemoryTitle => 'Add a memory';

  @override
  String get levelScreenQuestEventTitle => 'Add an event';

  @override
  String get levelScreenQuestIntimacyTitle => 'Log intimacy';

  @override
  String get levelScreenCompletedToday => 'Completed today';

  @override
  String levelScreenQuestRewardBadge(int sp) {
    return '+$sp SP';
  }

  @override
  String get systemStatusDemoScreenTitle => 'System Status (Preview)';

  @override
  String get levelUpUnlockSheetFeatureMemories => 'Memories';

  @override
  String get levelUpUnlockSheetFeatureBlueprints => 'Daily Questions';

  @override
  String get levelUpUnlockSheetFeatureQuickMessages => 'Quick Messages';

  @override
  String get levelUpUnlockSheetFeatureMapView => 'Memory Map';

  @override
  String get levelUpUnlockSheetTitle => 'Level up to unlock';

  @override
  String levelUpUnlockSheetRequirementBody(
    int requiredSp,
    String featureName,
    int currentSp,
  ) {
    return 'You need $requiredSp SP to unlock $featureName. You have $currentSp SP.';
  }

  @override
  String get levelUpUnlockSheetViewRoadmap => 'View roadmap';

  @override
  String get levelUpUnlockSheetGetPremium => 'Get DYOS+';

  @override
  String systemStatusCardCurrentVersion(String version) {
    return 'Current Version: $version';
  }

  @override
  String systemStatusCardProgressToNext(
    int currentXp,
    int tierMax,
    String nextLabel,
  ) {
    return '$currentXp / $tierMax SP to $nextLabel';
  }

  @override
  String systemStatusCardMaxLevel(int currentXp) {
    return '$currentXp SP · Max level';
  }

  @override
  String get listsScreenTitle => 'Lists';

  @override
  String get listsScreenAddNoteTooltip => 'Add note';

  @override
  String get listsScreenBucketListHeading => 'Bucket List';

  @override
  String get listsScreenBucketListSubheading =>
      'Things you want to do together';

  @override
  String get listsScreenEmptyTitle => 'No bucket list items yet';

  @override
  String get listsScreenEmptySubtitle =>
      'Tap the + button to add your first item';

  @override
  String get listsScreenErrorTitle => 'Error loading bucket list';

  @override
  String get listsScreenToday => 'Today';

  @override
  String get listsScreenYesterday => 'Yesterday';

  @override
  String listsScreenDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '$count day ago',
    );
    return '$_temp0';
  }

  @override
  String get settingsScreenTitle => 'Settings';

  @override
  String get settingsScreenDeleteAccountTitle => 'Delete Account';

  @override
  String get settingsScreenDeleteAccountWarning =>
      'This action cannot be undone. This will permanently delete:';

  @override
  String get settingsScreenDeleteAccountBulletList =>
      '• Your account and profile\n• All your memories and photos\n• All intimacy logs and data\n• Your pairing (partner will be unpaired)\n• All notes and lists';

  @override
  String get settingsScreenDeleteAccountConfirmQuestion =>
      'Are you absolutely sure?';

  @override
  String get settingsScreenDeleteForever => 'Delete Forever';

  @override
  String get settingsScreenDeletingAccount => 'Deleting account...';

  @override
  String settingsScreenDeleteAccountError(String error) {
    return 'Error deleting account: $error';
  }

  @override
  String get settingsScreenMustBePairedForAnniversary =>
      'You must be paired to set anniversary date';

  @override
  String get settingsScreenSelectAnniversaryDateHelp =>
      'Select anniversary date';

  @override
  String get settingsScreenSetAnniversaryConfirm => 'Set';

  @override
  String get settingsScreenAnniversaryUpdated => 'Anniversary date updated';

  @override
  String settingsScreenAnniversaryUpdateError(String error) {
    return 'Error updating anniversary date: $error';
  }

  @override
  String get settingsScreenAnniversaryDateLabel => 'Anniversary Date';

  @override
  String get settingsScreenSetAnniversaryDatePrompt =>
      'Set your anniversary date';

  @override
  String settingsScreenDaysTogether(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days together',
      one: '$count day together',
    );
    return '$_temp0';
  }

  @override
  String get settingsScreenLoading => 'Loading...';

  @override
  String get settingsScreenAppearanceLabel => 'Appearance';

  @override
  String get settingsScreenThemeLight => 'Light';

  @override
  String get settingsScreenThemeDark => 'Dark';

  @override
  String get settingsScreenThemeSystem => 'System';

  @override
  String get settingsScreenPairingLabel => 'Pairing';

  @override
  String get settingsScreenPairingSubtitle => 'Manage your pairing';

  @override
  String get settingsScreenDeleteAccountSubtitle =>
      'Permanently delete your account';

  @override
  String get settingsScreenLogOut => 'Log out';

  @override
  String get settingsScreenLogoutConfirmQuestion =>
      'Are you sure you want to log out?';

  @override
  String get settingsScreenLogoutSubtitle => 'Sign out and clear session';

  @override
  String settingsScreenLogoutError(String error) {
    return 'Error logging out: $error';
  }

  @override
  String get addNoteScreenContentEmptyError => 'Content cannot be empty';

  @override
  String get addNoteScreenNotAuthenticatedError =>
      'User not authenticated. Please log in again.';

  @override
  String get addNoteScreenNotPairedError =>
      'You are not paired with a partner. Please pair first.';

  @override
  String get addNoteScreenSaveSuccess => 'Note saved successfully!';

  @override
  String addNoteScreenSaveError(String error) {
    return 'Error saving note: $error';
  }

  @override
  String get addNoteScreenTitle => 'Add Note';

  @override
  String get addNoteScreenTitleLabel => 'Title (optional)';

  @override
  String get addNoteScreenTitleHint => 'Add a title...';

  @override
  String get addNoteScreenContentLabel => 'Content';

  @override
  String get addNoteScreenContentHint => 'Write your note here...';

  @override
  String get addNoteScreenContentRequired => 'Content is required';

  @override
  String get addNoteScreenTypeLabel => 'Type';

  @override
  String get addNoteScreenTypeShared => 'Shared';

  @override
  String get addNoteScreenTypePrivate => 'Private';

  @override
  String get addNoteScreenTypeBucketList => 'Bucket List';

  @override
  String get addNoteScreenTypeSecretGift => 'Secret Gift';

  @override
  String get addNoteScreenSaveNoteButton => 'Save Note';

  @override
  String get secretNotesScreenTitle => 'Secret Notes';

  @override
  String get secretNotesScreenTabSecretGift => 'Secret Gift';

  @override
  String get secretNotesScreenTabPrivate => 'Private';

  @override
  String get secretNotesScreenEmptySecretGiftTitle =>
      'No secret gift ideas yet';

  @override
  String get secretNotesScreenEmptySecretGiftSubtitle =>
      'Tap the + button to add your first secret gift idea';

  @override
  String get secretNotesScreenEmptyPrivateTitle => 'No private notes yet';

  @override
  String get secretNotesScreenEmptyPrivateSubtitle =>
      'Tap the + button to add your first private note';

  @override
  String get secretNotesScreenErrorTitle => 'Error loading notes';

  @override
  String get secretNotesScreenToday => 'Today';

  @override
  String get secretNotesScreenYesterday => 'Yesterday';

  @override
  String secretNotesScreenDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '$count day ago',
    );
    return '$_temp0';
  }

  @override
  String get premiumLandingScreenTitle => 'DYOS+';

  @override
  String get premiumLandingScreenYouHavePremium => 'You have DYOS+';

  @override
  String get premiumLandingScreenOneSubscriptionBoth =>
      'One subscription for both of you.';

  @override
  String get premiumLandingScreenChooseYourPlan => 'Choose your plan';

  @override
  String premiumLandingScreenLoadPlansError(String error) {
    return 'Could not load plans: $error. Pull down to retry.';
  }

  @override
  String get premiumLandingScreenCancelAnytimeNote =>
      'Cancel anytime. One subscription for both of you.';

  @override
  String get premiumLandingScreenHeroSubtitle => 'More for the two of you';

  @override
  String get premiumLandingScreenHeroDescription =>
      'Unlimited memories, insights, and no limits. One plan, both of you.';

  @override
  String get premiumLandingScreenInstantBenefits => 'Instant benefits';

  @override
  String get premiumLandingScreenNoPlansAvailable =>
      'No plans available right now. Pull down to retry.';

  @override
  String get premiumLandingScreenNoPlansConfigured =>
      'No plans configured. Pull down to retry.';

  @override
  String get premiumLandingScreenYearly => 'Yearly';

  @override
  String get premiumLandingScreenMonthly => 'Monthly';

  @override
  String get premiumLandingScreenYearlyBilling => 'Yearly billing';

  @override
  String get premiumLandingScreenMonthlyBilling => 'Monthly billing';

  @override
  String get premiumLandingScreenGetPremiumNow => 'Get DYOS+ now';

  @override
  String get premiumLandingScreenRestore => 'Restore';

  @override
  String get premiumLandingScreenPrivacy => 'Privacy';

  @override
  String get premiumLandingScreenTerms => 'Terms';

  @override
  String get paywallModalTitle => 'DYOS+';

  @override
  String get paywallModalLoadError => 'Could not load plans. Please try again.';

  @override
  String get paywallModalNoPlansAvailable => 'No plans available.';

  @override
  String get paywallModalYearly => 'Yearly';

  @override
  String get paywallModalMonthly => 'Monthly';

  @override
  String get paywallModalMonthlyBilling => 'Monthly billing';

  @override
  String get paywallModalRestorePurchases => 'Restore purchases';
}
