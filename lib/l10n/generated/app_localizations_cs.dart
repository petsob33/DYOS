// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get commonCancel => 'Zrušit';

  @override
  String get commonDelete => 'Smazat';

  @override
  String get commonEdit => 'Upravit';

  @override
  String get commonConfirm => 'Potvrdit';

  @override
  String get commonSave => 'Uložit';

  @override
  String get dataScreenTitle => 'Data a analýzy';

  @override
  String dataScreenError(String error) {
    return 'Chyba: $error';
  }

  @override
  String get dataScreenHeading => 'Přehled vztahu';

  @override
  String get dataScreenSubheading => 'Sleduj vzorce a trendy ve vašem vztahu';

  @override
  String get dataScreenTotalCountTitle => 'Celkem';

  @override
  String get dataScreenAllTime => 'Za celou dobu';

  @override
  String get dataScreenAvgPerWeekTitle => 'Prům./týden';

  @override
  String get dataScreenAverage => 'Průměr';

  @override
  String get dataScreenFavoriteDayTitle => 'Oblíbený den';

  @override
  String get dataScreenMostActive => 'Nejaktivnější';

  @override
  String get dataScreenBestOfHeading => 'To nejlepší';

  @override
  String get dataScreenLongestSexTitle => 'Nejdelší sex';

  @override
  String get dataScreenThisMonthSubtitle => 'Tento měsíc';

  @override
  String get dataScreenHeartsStreakTitle => 'Série srdíček';

  @override
  String dataScreenStreakDaySubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dní v řadě',
      many: 'dne v řadě',
      few: 'dny v řadě',
      one: 'den v řadě',
    );
    return '$_temp0';
  }

  @override
  String get dataScreenCurrentMonthHeading => 'Tento měsíc';

  @override
  String get dataScreenTotalTitle => 'Celkem';

  @override
  String get dataScreenAvgDurationTitle => 'Prům. délka';

  @override
  String get dataScreenAvgOrgasmsTitle => 'Prům. orgasmy';

  @override
  String get dataScreenFrequencyChartHeading => 'Graf četnosti';

  @override
  String get dataScreenInitiatorChartHeading => 'Graf iniciace';

  @override
  String get dataScreenYouLabel => 'Ty';

  @override
  String get dataScreenPartnerLabel => 'Partner';

  @override
  String get dataScreenOrgasmComparisonHeading => 'Porovnání orgasmů';

  @override
  String get dataScreenNoDataYet => 'Zatím žádná data';

  @override
  String get dataScreenTagsRadarHeading => 'Radar štítků';

  @override
  String get dataScreenNoTagsYet => 'Zatím žádné štítky';

  @override
  String get dataScreenHistoryHeading => 'Historie';

  @override
  String get loginScreenResetPasswordTitle => 'Obnovení hesla';

  @override
  String get loginScreenResetPasswordBody =>
      'Zadej svůj e-mail a pošleme ti odkaz pro obnovení hesla.';

  @override
  String get loginScreenEmailLabel => 'E-mail';

  @override
  String get loginScreenEmailHint => 'tvuj@email.cz';

  @override
  String get loginScreenSendButton => 'Odeslat';

  @override
  String get loginScreenResetEmailSent =>
      'E-mail pro obnovení hesla byl odeslán! Zkontroluj schránku.';

  @override
  String loginScreenGenericError(String error) {
    return 'Chyba: $error';
  }

  @override
  String get loginScreenAccountNotFoundTitle => 'Účet nenalezen';

  @override
  String get loginScreenAccountNotFoundBody =>
      'Pro tento e-mail jsme nenašli žádný účet. Chceš si založit nový?';

  @override
  String get loginScreenRegisterAction => 'Zaregistrovat se';

  @override
  String get loginScreenWelcomeBack => 'Vítej zpět';

  @override
  String get loginScreenSignInToContinue => 'Přihlas se a pokračuj';

  @override
  String get loginScreenEmailRequired => 'Zadej svůj e-mail';

  @override
  String get loginScreenEmailInvalid => 'Zadej platný e-mail';

  @override
  String get loginScreenPasswordLabel => 'Heslo';

  @override
  String get loginScreenPasswordRequired => 'Zadej své heslo';

  @override
  String get loginScreenPasswordTooShort => 'Heslo musí mít alespoň 6 znaků';

  @override
  String get loginScreenForgotPassword => 'Zapomenuté heslo?';

  @override
  String get loginScreenSignInButton => 'Přihlásit se';

  @override
  String get loginScreenOrDivider => 'NEBO';

  @override
  String get loginScreenContinueWithGoogle => 'Pokračovat přes Google';

  @override
  String get loginScreenNoAccountPrompt => 'Nemáš účet? ';

  @override
  String get loginScreenSignUpButton => 'Zaregistruj se';

  @override
  String get registerScreenCreateAccount => 'Vytvořit účet';

  @override
  String get registerScreenSignUpToGetStarted => 'Zaregistruj se a začni';

  @override
  String get registerScreenFullNameLabel => 'Celé jméno';

  @override
  String get registerScreenNameRequired => 'Zadej své jméno';

  @override
  String get registerScreenNameTooShort => 'Jméno musí mít alespoň 2 znaky';

  @override
  String get registerScreenPasswordRequired => 'Zadej heslo';

  @override
  String get registerScreenConfirmPasswordLabel => 'Potvrzení hesla';

  @override
  String get registerScreenConfirmPasswordRequired => 'Potvrď své heslo';

  @override
  String get registerScreenPasswordsDoNotMatch => 'Hesla se neshodují';

  @override
  String get registerScreenSignUpButton => 'Zaregistrovat se';

  @override
  String get registerScreenAlreadyHaveAccountPrompt => 'Už máš účet? ';

  @override
  String get registerScreenSignInButton => 'Přihlásit se';

  @override
  String get pairingScreenAppBarTitle => 'Spojit se s partnerem';

  @override
  String get pairingScreenSignOut => 'Odhlásit se';

  @override
  String get pairingScreenSignOutConfirm => 'Opravdu se chceš odhlásit?';

  @override
  String get pairingScreenHeading => 'Zadej e-mail svého partnera';

  @override
  String get pairingScreenSubheading => 'Oba už musíte mít založený účet';

  @override
  String get pairingScreenEmailHint => 'partner@email.com';

  @override
  String get pairingScreenEmailRequired => 'Zadej e-mailovou adresu';

  @override
  String get pairingScreenEmailInvalid => 'Zadej platnou e-mailovou adresu';

  @override
  String get pairingScreenCannotPairSelf => 'Nemůžeš se spojit sám se sebou';

  @override
  String pairingScreenPairedWith(String name) {
    return 'Spojeno s $name!';
  }

  @override
  String get pairingScreenGenericError =>
      'Teď se nedaří spojit. Zkontroluj své připojení.';

  @override
  String get pairingScreenPairButton => 'Spojit';

  @override
  String get profileScreenTitle => 'Profil';

  @override
  String get profileScreenUserNotFound => 'Uživatel nenalezen';

  @override
  String get profileScreenNoName => 'Bez jména';

  @override
  String get profileScreenPartnerHeading => 'Partner';

  @override
  String get profileScreenNoPartnerPaired => 'Zatím žádný spojený partner';

  @override
  String profileScreenErrorLoadingPartner(String error) {
    return 'Chyba při načítání partnera: $error';
  }

  @override
  String get profileScreenActionsHeading => 'Akce';

  @override
  String get profileScreenUpgradeAction => 'DYOS+ / Upgrade';

  @override
  String get profileScreenSecretGiftAction => 'Tajný dárek / Soukromé';

  @override
  String get profileScreenSettingsAction => 'Nastavení';

  @override
  String profileScreenErrorLoadingProfile(String error) {
    return 'Chyba při načítání profilu: $error';
  }

  @override
  String get editProfilePictureScreenTitle => 'Upravit profilovou fotku';

  @override
  String editProfilePictureScreenPickError(String error) {
    return 'Chyba při výběru obrázku: $error';
  }

  @override
  String get editProfilePictureScreenSelectImageFirst =>
      'Nejdřív vyber obrázek';

  @override
  String get editProfilePictureScreenUserNotFound => 'Uživatel nenalezen';

  @override
  String get editProfilePictureScreenUpdateSuccess =>
      'Profilová fotka byla úspěšně aktualizována!';

  @override
  String editProfilePictureScreenGenericError(String error) {
    return 'Chyba: $error';
  }

  @override
  String get editProfilePictureScreenChooseImage => 'Vybrat obrázek';

  @override
  String get editProfilePictureScreenSaveButton => 'Uložit profilovou fotku';

  @override
  String get firebaseTestScreenTitle => 'Test připojení Firebase';

  @override
  String get firebaseTestScreenRerunTooltip => 'Spustit testy znovu';

  @override
  String get firebaseTestScreenRunning => 'Testy probíhají...';

  @override
  String get firebaseTestScreenAllPassed => 'Všechny testy prošly! ✅';

  @override
  String get firebaseTestScreenSomeFailed => 'Některé testy selhaly ⚠️';

  @override
  String firebaseTestScreenPassedCount(int passed, int total) {
    return 'Prošlo: $passed / $total';
  }

  @override
  String get firebaseTestScreenNoResults => 'Zatím žádné výsledky testů';

  @override
  String get firebaseTestScreenWhatToCheckHeading => 'Co zkontrolovat:';

  @override
  String get firebaseTestScreenInstructionAllGreen =>
      '✅ Všechno zelené = Firebase je správně připojen!';

  @override
  String get firebaseTestScreenInstructionCoreFailed =>
      '❌ Firebase Core selhal = Zkontroluj konfigurační soubory';

  @override
  String get firebaseTestScreenInstructionFirestoreFailed =>
      '❌ Firestore selhal = Povol Firestore v konzoli Firebase';

  @override
  String get firebaseTestScreenInstructionWriteReadFailed =>
      '❌ Zápis/čtení selhalo = Zkontroluj bezpečnostní pravidla Firestore';

  @override
  String get blueprintDetailScreenXpGranted =>
      'Aktualizováno: získal jsi +100 XP! 🚀';

  @override
  String get blueprintDetailScreenAlreadyEarned =>
      'Sekce uložena. (XP za dnešek už máš.)';

  @override
  String get blueprintDetailScreenSectionComplete => 'Sekce dokončena!';

  @override
  String get blueprintDetailScreenLoadError =>
      'Tuhle sekci Blueprintu se nepodařilo načíst.';

  @override
  String get blueprintDetailScreenNotFound => 'Sekce Blueprintu nenalezena.';

  @override
  String get blueprintDetailScreenCompleteButton => 'Dokončit sekci';

  @override
  String get blueprintsListScreenTitle => 'Denní otázky';

  @override
  String get blueprintsListScreenLoadError =>
      'Blueprinty se nepodařilo načíst.';

  @override
  String get blueprintsListScreenIntro =>
      'Ulož si své preference jako pár. Dokončením sekce získáš +100 XP.';

  @override
  String blueprintsListScreenQuestionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count otázek',
      many: '$count otázky',
      few: '$count otázky',
      one: '1 otázka',
    );
    return '$_temp0';
  }

  @override
  String blueprintQuestionCardPartnerValue(String value) {
    return 'Partner: $value';
  }

  @override
  String get blueprintQuestionCardYes => 'Ano';

  @override
  String get blueprintQuestionCardNo => 'Ne';

  @override
  String get cycleSettingsSheetPairFirst => 'Nejdřív se spoj se svým partnerem';

  @override
  String get cycleSettingsSheetSaved => 'Nastavení bylo úspěšně uloženo!';

  @override
  String cycleSettingsSheetError(String error) {
    return 'Chyba: $error';
  }

  @override
  String get cycleSettingsSheetTitle => 'Nastavení cyklu';

  @override
  String get cycleSettingsSheetDayInCycleLabel => 'Den cyklu';

  @override
  String cycleSettingsSheetDayInCycleValue(int day) {
    return 'Den $day';
  }

  @override
  String get cycleSettingsSheetLastPeriodDateLabel =>
      'Datum poslední menstruace';

  @override
  String get cycleSettingsSheetNotSet => 'Nenastaveno';

  @override
  String get cycleSettingsSheetTapToChange => 'Klepnutím změníš';

  @override
  String get cycleSettingsSheetAvgCycleLengthLabel => 'Průměrná délka cyklu';

  @override
  String cycleSettingsSheetDaysValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dní',
      many: '$count dne',
      few: '$count dny',
      one: '1 den',
    );
    return '$_temp0';
  }

  @override
  String get cycleSettingsSheetPeriodLengthLabel => 'Délka menstruace';

  @override
  String get cycleSettingsSheetHideMenstruationLabel => 'Skrýt menstruaci';

  @override
  String get cycleSettingsSheetHideMenstruationDescription =>
      'Skryje sledování a zobrazování menstruace v kalendáři';

  @override
  String get cycleSettingsSheetLoadError => 'Nastavení se nepodařilo načíst';

  @override
  String get cycleTrackingScreenTitle => 'Kalendář';

  @override
  String get cycleTrackingScreenSettingsTooltip => 'Nastavení cyklu';

  @override
  String get cycleTrackingScreenToday => 'Dnes';

  @override
  String get cycleTrackingScreenYesterday => 'Včera';

  @override
  String get cycleTrackingScreenTomorrow => 'Zítra';

  @override
  String get cycleTrackingScreenMemoriesHeading => 'Vzpomínky';

  @override
  String get cycleTrackingScreenIntimacyHeading => 'Intimita';

  @override
  String cycleTrackingScreenRating(int rating) {
    return 'Hodnocení: $rating/5';
  }

  @override
  String get cycleTrackingScreenEventsHeading => 'Události';

  @override
  String get cycleTrackingScreenAddMemoryButton => 'Přidat vzpomínku';

  @override
  String get cycleTrackingScreenAddIntimacyButton => 'Přidat intimitu';

  @override
  String get cycleTrackingScreenAddEventButton => 'Přidat událost';

  @override
  String get cycleTrackingScreenAddPeriodLogButton =>
      'Přidat záznam menstruace';

  @override
  String get cycleTrackingScreenLegendHeading => 'Legenda';

  @override
  String get cycleTrackingScreenMenstruationLabel => 'Menstruace';

  @override
  String get cycleTrackingScreenFollicularLabel => 'Folikulární fáze';

  @override
  String get cycleTrackingScreenOvulationFertileLabel => 'Ovulace/Plodné dny';

  @override
  String get cycleTrackingScreenLutealPmsLabel => 'Luteální fáze/PMS';

  @override
  String get cycleTrackingScreenPairFirst =>
      'Nejdřív se spoj se svým partnerem';

  @override
  String get cycleTrackingScreenLogUpdated =>
      'Záznam cyklu byl úspěšně aktualizován!';

  @override
  String get cycleTrackingScreenLogAdded => 'Záznam cyklu byl úspěšně přidán!';

  @override
  String cycleTrackingScreenError(String error) {
    return 'Chyba: $error';
  }

  @override
  String get cycleTrackingScreenEditLogTitle => 'Upravit záznam cyklu';

  @override
  String get cycleTrackingScreenAddLogTitle => 'Přidat záznam cyklu';

  @override
  String get cycleTrackingScreenFlowIntensityLabel => 'Intenzita krvácení';

  @override
  String get cycleTrackingScreenMoodLabel => 'Nálada';

  @override
  String get cycleTrackingScreenUpdateLogButton => 'Aktualizovat záznam';

  @override
  String get cycleTrackingScreenAddLogButton => 'Přidat záznam';

  @override
  String get addEventSheetTitleRequired => 'Zadej prosím název';

  @override
  String get addEventSheetPairFirst => 'Nejdřív se spoj se svým partnerem';

  @override
  String get addEventSheetAddedWithXp => 'Událost přidána! +15 XP';

  @override
  String get addEventSheetAddedXpAlreadyEarned =>
      'Událost přidána! XP za tuto aktivitu získáš jen jednou denně.';

  @override
  String get addEventSheetUpdated => 'Událost byla úspěšně aktualizována!';

  @override
  String get addEventSheetAdded => 'Událost byla úspěšně přidána!';

  @override
  String addEventSheetError(String error) {
    return 'Chyba: $error';
  }

  @override
  String get addEventSheetEditTitle => 'Upravit událost';

  @override
  String get addEventSheetAddTitle => 'Přidat událost';

  @override
  String get addEventSheetTitleLabel => 'Název';

  @override
  String get addEventSheetTitleHint => 'Zadej název události';

  @override
  String get addEventSheetUpdateButton => 'Aktualizovat událost';

  @override
  String get addEventSheetAddButton => 'Přidat událost';

  @override
  String get addEventSheetDateTimeLabel => 'Datum a čas';

  @override
  String get addEventSheetToday => 'Dnes';

  @override
  String get addEventSheetYesterday => 'Včera';

  @override
  String get addEventSheetTomorrow => 'Zítra';

  @override
  String get eventsScreenBackTooltip => 'Zpět';

  @override
  String get eventsScreenTitle => 'Události';

  @override
  String get eventsScreenAddEventTooltip => 'Přidat událost';

  @override
  String eventsScreenDebugEventsLoaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Debug: načteno $count událostí',
      many: 'Debug: načteno $count události',
      few: 'Debug: načteny $count události',
      one: 'Debug: načtena 1 událost',
    );
    return '$_temp0';
  }

  @override
  String get eventsScreenNoEventsOnDay => 'V tento den nejsou žádné události';

  @override
  String get eventsScreenNoEventsYet => 'Zatím žádné události';

  @override
  String get eventsScreenAddEventButton => 'Přidat událost';

  @override
  String eventsScreenLoadError(String error) {
    return 'Načítání událostí selhalo: $error';
  }

  @override
  String get eventsScreenDeleteDialogTitle => 'Smazat událost';

  @override
  String eventsScreenDeleteConfirmMessage(String title) {
    return 'Opravdu chceš smazat „$title“?';
  }

  @override
  String get eventsScreenPairFirst => 'Nejdřív se spoj se svým partnerem';

  @override
  String get eventsScreenDeleted => 'Událost byla úspěšně smazána';

  @override
  String eventsScreenError(String error) {
    return 'Chyba: $error';
  }

  @override
  String get eventsScreenDeleteEventTooltip => 'Smazat událost';

  @override
  String get intimacyHistoryScreenTitle => 'Historie intimity';

  @override
  String get addIntimacySheetPairFirst => 'Nejdřív se spoj s partnerem';

  @override
  String get addIntimacySheetSelectInitiator => 'Vyber, kdo dal podnět';

  @override
  String get addIntimacySheetAddedWithXp => 'Záznam přidán! +20 XP';

  @override
  String get addIntimacySheetAddedXpAlreadyGranted =>
      'Záznam přidán! XP za tuto aktivitu se uděluje jednou denně.';

  @override
  String get addIntimacySheetUpdatedSuccess => 'Záznam byl úspěšně upraven!';

  @override
  String get addIntimacySheetAddedSuccess => 'Záznam byl úspěšně přidán!';

  @override
  String addIntimacySheetError(String error) {
    return 'Chyba: $error';
  }

  @override
  String get addIntimacySheetEditTitle => 'Upravit záznam';

  @override
  String get addIntimacySheetAddTitle => 'Přidat záznam';

  @override
  String get addIntimacySheetMeFallback => 'Já';

  @override
  String get addIntimacySheetUpdateButton => 'Uložit změny';

  @override
  String get addIntimacySheetAddButton => 'Přidat záznam';

  @override
  String get addIntimacySheetNoteFieldLabel => 'Poznámka (nepovinné)';

  @override
  String get addIntimacySheetNoteHint => 'Napiš si poznámku...';

  @override
  String get addIntimacySheetDateTimeLabel => 'Datum a čas';

  @override
  String get addIntimacySheetToday => 'Dnes';

  @override
  String get addIntimacySheetYesterday => 'Včera';

  @override
  String get addIntimacySheetRatingLabel => 'Hodnocení';

  @override
  String get addIntimacySheetInitiatorLabel => 'Kdo dal podnět';

  @override
  String get addIntimacySheetTagsLabel => 'Štítky';

  @override
  String get addIntimacySheetProtectionUsedLabel => 'Použita ochrana';

  @override
  String get addIntimacySheetProtectionSubtitle => 'Použili jste ochranu?';

  @override
  String get addIntimacySheetOrgasmsLabel => 'Orgasmy';

  @override
  String get addIntimacySheetDurationLabel => 'Délka';

  @override
  String get addIntimacySheetDurationFieldLabel => 'Délka (minuty)';

  @override
  String get addIntimacySheetDurationHint => 'např. 30';

  @override
  String get addIntimacySheetLocationLabel => 'Místo';

  @override
  String get addIntimacySheetLocationFieldLabel => 'Místo (nepovinné)';

  @override
  String get addIntimacySheetLocationHint => 'např. Doma, hotel, pláž...';

  @override
  String get intimacyHistoryListViewAllButton => 'Zobrazit vše';

  @override
  String get intimacyHistoryListLoadOlderButton => 'Načíst starší záznamy';

  @override
  String get intimacyHistoryListErrorTitle => 'Chyba při načítání záznamů';

  @override
  String get intimacyHistoryListEmptyTitle => 'Zatím žádné vzpomínky';

  @override
  String get intimacyHistoryListEmptySubtitle => 'Co to změnit? 😉';

  @override
  String intimacyHistoryListDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get intimacyLogDetailSheetTitle => 'Detail záznamu';

  @override
  String get intimacyLogDetailSheetDateTimeLabel => 'Datum a čas';

  @override
  String intimacyLogDetailSheetDateTimeValue(String date, String time) {
    return '$date v $time';
  }

  @override
  String get intimacyLogDetailSheetRatingLabel => 'Hodnocení';

  @override
  String get intimacyLogDetailSheetInitiatorLabel => 'Kdo dal podnět';

  @override
  String get intimacyLogDetailSheetMeFallback => 'Já';

  @override
  String get intimacyLogDetailSheetTagsLabel => 'Štítky';

  @override
  String get intimacyLogDetailSheetProtectionLabel => 'Ochrana';

  @override
  String get intimacyLogDetailSheetProtectionUsed => 'Použita';

  @override
  String get intimacyLogDetailSheetProtectionNotUsed => 'Nepoužita';

  @override
  String get intimacyLogDetailSheetOrgasmsLabel => 'Orgasmy';

  @override
  String get intimacyLogDetailSheetDurationLabel => 'Délka';

  @override
  String intimacyLogDetailSheetDurationValue(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minut',
      many: '$minutes minuty',
      few: '$minutes minuty',
      one: '$minutes minuta',
    );
    return '$_temp0';
  }

  @override
  String get intimacyLogDetailSheetLocationLabel => 'Místo';

  @override
  String get intimacyLogDetailSheetNoteLabel => 'Poznámka';

  @override
  String get intimacyLogDetailSheetDeleteConfirmTitle => 'Smazat záznam?';

  @override
  String get intimacyLogDetailSheetDeleteConfirmBody =>
      'Tuto akci nelze vrátit zpět.';

  @override
  String get intimacyLogDetailSheetDeletedSnackbar => 'Záznam smazán';

  @override
  String intimacyLogDetailSheetDeleteFailedSnackbar(String error) {
    return 'Smazání záznamu se nezdařilo: $error';
  }

  @override
  String get appRouterMemoryNotFound => 'Vzpomínka nenalezena';

  @override
  String get appRouterNavHome => 'Domů';

  @override
  String get appRouterNavMemory => 'Vzpomínky';

  @override
  String get appRouterNavData => 'Data';

  @override
  String get appRouterNavCalendar => 'Kalendář';

  @override
  String get appRouterQuickActionsHeading => 'Rychlé akce';

  @override
  String get appRouterQuickActionAddNote => 'Přidat poznámku';

  @override
  String get appRouterQuickActionAddMemory => 'Přidat vzpomínku';

  @override
  String get appRouterQuickActionLogIntimacy => 'Zapsat intimitu';

  @override
  String get appRouterQuickActionAddEvent => 'Přidat událost';

  @override
  String get chatScreenShortcutThinkingOfYou => 'Myslím na tebe 💭';

  @override
  String get chatScreenShortcutMissYou => 'Chybíš mi ❤️';

  @override
  String get chatScreenShortcutLoveYou => 'Miluju tě 😘';

  @override
  String get chatScreenShortcutSeeYouSoon => 'Brzy na viděnou 👋';

  @override
  String get chatScreenShortcutGoodMorning => 'Dobré ráno ☀️';

  @override
  String get chatScreenShortcutGoodNight => 'Dobrou noc 🌙';

  @override
  String get chatScreenShortcutHowAreYou => 'Jak se máš? 😊';

  @override
  String chatScreenSendMessageError(String error) {
    return 'Zprávu se nepodařilo odeslat: $error';
  }

  @override
  String chatScreenSendTouchError(String error) {
    return 'Dotek se nepodařilo odeslat: $error';
  }

  @override
  String get chatScreenPartnerFallback => 'Partner';

  @override
  String get chatScreenPairPrompt =>
      'Spároval ses s partnerem? Pak si můžete začít psát.';

  @override
  String get chatScreenEmptyState =>
      'Zatím žádné zprávy ani doteky.\nPozdrav se 👋';

  @override
  String get chatScreenLoadHistoryError =>
      'Historii chatu se nepodařilo načíst.';

  @override
  String get chatScreenTouchLabel => 'Dotek';

  @override
  String get chatScreenSendTouchTooltip => 'Poslat dotek';

  @override
  String get chatScreenMessageHint => 'Napiš zprávu...';

  @override
  String get chatScreenSendTooltip => 'Odeslat';

  @override
  String get homeScreenUserNotFound => 'Uživatel nenalezen';

  @override
  String get homeScreenNotPaired => 'Nejsi spárovaný. Nejdřív se spáruj.';

  @override
  String get homeScreenTestNotificationsTitle => 'Testovat oznámení';

  @override
  String get homeScreenHapticSentMessage =>
      'Haptický signál odeslán! Podrobnosti najdeš v konzoli/logu.';

  @override
  String homeScreenGenericError(String error) {
    return 'Chyba: $error';
  }

  @override
  String get homeScreenTestHapticSignalButton => 'Otestovat haptický signál';

  @override
  String get homeScreenQuickMessageSentMessage =>
      'Rychlá zpráva odeslána! Podrobnosti najdeš v konzoli/logu.';

  @override
  String get homeScreenTestQuickMessageButton => 'Otestovat rychlou zprávu';

  @override
  String get homeScreenSettingsTooltip => 'Nastavení';

  @override
  String get homeScreenTitle => 'Domů';

  @override
  String get homeScreenSubtitle => 'Widgety pro tvůj život';

  @override
  String appBarLevelStripXpLabel(int xp) {
    return '$xp SP';
  }

  @override
  String get countdownCardTitle => 'Odpočet';

  @override
  String get countdownCardNoEvents => 'Žádné nadcházející události';

  @override
  String countdownCardDaysUntil(int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dní',
      many: 'dne',
      few: 'dny',
      one: 'den',
    );
    return '$_temp0 do $title';
  }

  @override
  String get countdownCardError => 'Chyba při načítání událostí';

  @override
  String get daysTogetherCardTitle => 'Dny spolu';

  @override
  String get daysTogetherCardSetDate => 'Nastav si datum výročí';

  @override
  String get intimacySparkCardNoActivity => 'Zatím žádná aktivita';

  @override
  String intimacySparkCardDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'před $count dny',
      many: 'před $count dny',
      few: 'před $count dny',
      one: 'před $count dnem',
      zero: 'Dnes',
    );
    return '$_temp0';
  }

  @override
  String get intimacySparkCardError => 'Chyba při načítání dat';

  @override
  String get quickMessageNotificationOverlayLabel => 'Rychlá zpráva';

  @override
  String get quickNoteCardPromptWriteSomethingNice =>
      'Napiš mi něco hezkého...';

  @override
  String get quickNoteCardPromptDontForget => 'Nezapomeň...';

  @override
  String get quickNoteCardPromptDoorCode => 'Kód od dveří je...';

  @override
  String get quickNoteCardPromptSecretPhrase => 'Dnešní tajná fráze?';

  @override
  String get quickNoteCardHeaderLabel => 'LEPICÍ LÍSTEK';

  @override
  String get statusHeaderPairPrompt =>
      'Spároval ses s partnerem? Pak uvidíš jeho stav';

  @override
  String get statusHeaderYouFallback => 'Ty';

  @override
  String get statusHeaderPartnerFallback => 'Partner';

  @override
  String get statusHeaderReadyStatus => 'Připraven/a';

  @override
  String get statusHeaderLoadingStatus => 'Načítání...';

  @override
  String get statusHeaderErrorStatus => 'Chyba';

  @override
  String get statusHeaderUpdateStatusTitle => 'Upravit stav';

  @override
  String get statusHeaderChooseEmojiLabel => 'Vyber emoji';

  @override
  String get statusHeaderStatusLabel => 'Stav';

  @override
  String get statusHeaderStatusUpdatedMessage => 'Stav aktualizován';

  @override
  String statusHeaderUpdateErrorMessage(String error) {
    return 'Chyba při aktualizaci stavu: $error';
  }

  @override
  String get tapticTouchCardUnlockPrompt =>
      'Odemkni s DYOS+ nebo přes Roadmapu';

  @override
  String get tapticTouchCardSentLabel => 'Odesláno';

  @override
  String get tapticTouchCardSentToPartnerMessage => 'Odesláno partnerovi';

  @override
  String tapticTouchCardSendErrorMessage(String error) {
    return 'Chyba při odesílání: $error';
  }

  @override
  String addMemoryScreenErrorPickingImages(String error) {
    return 'Chyba při výběru fotek: $error';
  }

  @override
  String addMemoryScreenErrorPickingImage(String error) {
    return 'Chyba při výběru fotky: $error';
  }

  @override
  String get addMemoryScreenMemoryUpdated => 'Vzpomínka upravena';

  @override
  String get addMemoryScreenFreeLimitMessage =>
      'Máš plný limit 30 vzpomínek zdarma. Odemkni si neomezené vzpomínky v DYOS+.';

  @override
  String get addMemoryScreenAddImageOrCaption =>
      'Přidej aspoň jednu fotku nebo popisek';

  @override
  String get addMemoryScreenMemorySavedXp => 'Vzpomínka uložena! +25 XP';

  @override
  String get addMemoryScreenMemorySavedXpOncePerDay =>
      'Vzpomínka uložena! XP za tuto aktivitu se uděluje jednou denně.';

  @override
  String addMemoryScreenMemoryUpdatedWithCaption(String caption) {
    return 'Vzpomínka \"$caption\" upravena.';
  }

  @override
  String get addMemoryScreenUntitledCaption => 'Bez názvu';

  @override
  String get addMemoryScreenEditMemoryTitle => 'Upravit vzpomínku';

  @override
  String get addMemoryScreenAddMemoryTitle => 'Přidat vzpomínku';

  @override
  String get addMemoryScreenCaptionLabel => 'Popisek';

  @override
  String get addMemoryScreenCaptionHint => 'O čem je tahle vzpomínka?';

  @override
  String get addMemoryScreenPhotosVideosLabel => 'Fotky a videa';

  @override
  String get addMemoryScreenAddPhotos => 'Přidat fotky';

  @override
  String get addMemoryScreenAddMorePhotos => 'Přidat další fotky';

  @override
  String get addMemoryScreenDateLabel => 'Datum';

  @override
  String get addMemoryScreenCategoryLabel => 'Kategorie';

  @override
  String get addMemoryScreenPlaceLabel => 'Místo';

  @override
  String get addMemoryScreenAddPlace => 'Přidat místo';

  @override
  String get addMemoryScreenLocationSet => 'Místo nastaveno';

  @override
  String get addMemoryScreenChangePlaceTooltip => 'Změnit místo';

  @override
  String get addMemoryScreenRemovePlaceTooltip => 'Odebrat místo';

  @override
  String get addMemoryScreenUpdateMemoryButton => 'Uložit změny';

  @override
  String get addMemoryScreenSaveMemoryButton => 'Uložit vzpomínku';

  @override
  String get memoriesMapScreenBackTooltip => 'Zpět';

  @override
  String get memoriesMapScreenTitle => 'Mapa vzpomínek';

  @override
  String get memoriesMapScreenNoMemoriesYet => 'Zatím žádné vzpomínky s místem';

  @override
  String memoriesMapScreenError(String error) {
    return 'Chyba: $error';
  }

  @override
  String get memoriesMapScreenSearchHint => 'Hledej místo nebo adresu...';

  @override
  String get memoriesMapScreenMyLocationTooltip => 'Moje poloha';

  @override
  String get memoriesMapScreenMapKeyMissingMessage =>
      'Náhled mapy vyžaduje klíč Google Maps API (viz docs/ANDROID_GOOGLE_API_KEY.md). Vzpomínky s místem jsou uvedeny níže.';

  @override
  String get memoriesMapScreenPlaceFallback => 'Místo';

  @override
  String get memoriesMapScreenMemoryFallback => 'Vzpomínka';

  @override
  String get memoriesMapScreenUntitledCaption => 'Bez názvu';

  @override
  String get memoryDetailScreenDeleteMemoryTitle => 'Smazat vzpomínku?';

  @override
  String get memoryDetailScreenDeleteMemoryContent =>
      'Vzpomínka bude odstraněna. Tuto akci nelze vrátit zpět.';

  @override
  String get memoryDetailScreenMemoryDeleted => 'Vzpomínka smazána';

  @override
  String memoryDetailScreenFailedToDelete(String error) {
    return 'Smazání se nezdařilo: $error';
  }

  @override
  String get memoryDetailScreenBackTooltip => 'Zpět';

  @override
  String get memoryDetailScreenCloseTooltip => 'Zavřít';

  @override
  String memoryDetailScreenPageCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String get memoryDetailScreenDeletingLabel => 'Mažu…';

  @override
  String get memoryDetailScreenFailedToLoadImage =>
      'Fotku se nepodařilo načíst';

  @override
  String memoryDetailScreenDateAtTime(String date, String time) {
    return '$date v $time';
  }

  @override
  String get timelineScreenTitle => 'Časová osa';

  @override
  String get timelineScreenMemoriesMapTooltip => 'Mapa vzpomínek';

  @override
  String get timelineScreenFreeLimitMessage =>
      'Máš plný limit 30 vzpomínek zdarma. Odemkni si neomezené vzpomínky v DYOS+.';

  @override
  String get timelineScreenLoadOlderMemories => 'Načíst starší vzpomínky';

  @override
  String get timelineScreenAllCategoriesLabel => 'Vše';

  @override
  String get timelineScreenMemoriesLimitFreeLabel => 'Limit vzpomínek (Free)';

  @override
  String timelineScreenMemoriesLimitSubtitle(int count, int limit) {
    return '$count / $limit vzpomínek ve verzi zdarma';
  }

  @override
  String get timelineScreenErrorLoadingMemories =>
      'Chyba při načítání vzpomínek';

  @override
  String get timelineScreenNoMemoriesYet => 'Zatím žádné vzpomínky';

  @override
  String get timelineScreenStartCreatingMemories =>
      'Začni vytvářet vzpomínky se svou polovičkou!';

  @override
  String get timelineScreenFailedToLoad => 'Nepodařilo se načíst';

  @override
  String get memoryDetailDialogDeleteMemoryTitle => 'Smazat vzpomínku?';

  @override
  String get memoryDetailDialogDeleteMemoryContent =>
      'Vzpomínka bude odstraněna. Tuto akci nelze vrátit zpět.';

  @override
  String get memoryDetailDialogMemoryDeleted => 'Vzpomínka smazána';

  @override
  String memoryDetailDialogFailedToDelete(String error) {
    return 'Smazání se nezdařilo: $error';
  }

  @override
  String get memoryDetailDialogNoPhotos => 'Žádné fotky';

  @override
  String get memoryDetailDialogMemoryFallback => 'Vzpomínka';

  @override
  String memoryDetailDialogDateAtTime(String date, String time) {
    return '$date v $time';
  }

  @override
  String get pickPlaceScreenApiKeyMissingMessage =>
      'Přidej GOOGLE_MAPS_API_KEY do android/local.properties (Android) nebo GOOGLE_PLACES_API_KEY do ios Secrets.xcconfig a projekt znovu sestav. Vyhledávání podle adresy funguje i tak.';

  @override
  String pickPlaceScreenPlacesError(String message) {
    return 'Místa: $message';
  }

  @override
  String get pickPlaceScreenSearchSuggestionsUnavailable =>
      'Návrhy hledání nejsou dostupné. Použij ikonu lupy pro vyhledání míst.';

  @override
  String get pickPlaceScreenCouldNotLoadPlaceDetails =>
      'Nepodařilo se načíst podrobnosti o místě';

  @override
  String get pickPlaceScreenNoResultsFound =>
      'Pro tuto adresu nebyly nalezeny žádné výsledky';

  @override
  String pickPlaceScreenSearchFailed(String error) {
    return 'Hledání se nezdařilo: $error';
  }

  @override
  String get pickPlaceScreenLocationServicesDisabled =>
      'Služby polohy jsou vypnuté';

  @override
  String get pickPlaceScreenLocationPermissionDenied =>
      'Přístup k poloze byl zamítnut';

  @override
  String get pickPlaceScreenRestartAppLocation =>
      'Pro použití Moje poloha restartuj aplikaci.';

  @override
  String pickPlaceScreenCouldNotGetLocation(String error) {
    return 'Nepodařilo se zjistit polohu: $error';
  }

  @override
  String get pickPlaceScreenBackTooltip => 'Zpět';

  @override
  String get pickPlaceScreenTitle => 'Vyber místo';

  @override
  String get pickPlaceScreenMapKeyMissingFallback =>
      'Náhled mapy vyžaduje klíč Google Maps API v nativním buildu (viz docs/ANDROID_GOOGLE_API_KEY.md). Hledání podle adresy funguje níže.';

  @override
  String get pickPlaceScreenSearchHint => 'Hledej místo nebo adresu...';

  @override
  String get pickPlaceScreenMyLocationTooltip => 'Moje poloha';

  @override
  String get pickPlaceScreenTapToSetLocation =>
      'Klepnutím na mapu nastavíš místo vzpomínky';

  @override
  String get pickPlaceScreenPlaceNameLabel => 'Název místa (volitelné)';

  @override
  String get pickPlaceScreenPlaceNameHint => 'např. Restaurace, Park';

  @override
  String get levelScreenTitle => 'Tvoje úroveň';

  @override
  String get levelScreenBootSequence => 'Spouštění systému';

  @override
  String levelScreenCollectSpToNextTier(int spToNext, String nextTier) {
    return 'Nasbírej $spToNext SP a dostaneš se na $nextTier';
  }

  @override
  String levelScreenSpValue(int sp) {
    return '$sp SP';
  }

  @override
  String get levelScreenProgressionRewardsHeading => 'Postup a odměny';

  @override
  String get levelScreenCompleteTasksHeading => 'Splň úkoly a získej odměny';

  @override
  String get levelScreenQuestBlueprintTitle => 'Dokonči sekci Blueprintu';

  @override
  String get levelScreenQuestMemoryTitle => 'Přidej vzpomínku';

  @override
  String get levelScreenQuestEventTitle => 'Přidej událost';

  @override
  String get levelScreenQuestIntimacyTitle => 'Zaznamenej intimitu';

  @override
  String get levelScreenCompletedToday => 'Dnes splněno';

  @override
  String levelScreenQuestRewardBadge(int sp) {
    return '+$sp SP';
  }

  @override
  String get systemStatusDemoScreenTitle => 'Stav systému (náhled)';

  @override
  String get levelUpUnlockSheetFeatureMemories => 'Vzpomínky';

  @override
  String get levelUpUnlockSheetFeatureBlueprints => 'Denní otázky';

  @override
  String get levelUpUnlockSheetFeatureQuickMessages => 'Rychlé zprávy';

  @override
  String get levelUpUnlockSheetFeatureMapView => 'Mapa vzpomínek';

  @override
  String get levelUpUnlockSheetTitle => 'Zvyš úroveň a odemkni';

  @override
  String levelUpUnlockSheetRequirementBody(
    int requiredSp,
    String featureName,
    int currentSp,
  ) {
    return 'Pro odemčení $featureName potřebuješ $requiredSp SP. Máš $currentSp SP.';
  }

  @override
  String get levelUpUnlockSheetViewRoadmap => 'Zobrazit plán postupu';

  @override
  String get levelUpUnlockSheetGetPremium => 'Získej DYOS+';

  @override
  String systemStatusCardCurrentVersion(String version) {
    return 'Aktuální verze: $version';
  }

  @override
  String systemStatusCardProgressToNext(
    int currentXp,
    int tierMax,
    String nextLabel,
  ) {
    return '$currentXp / $tierMax SP do $nextLabel';
  }

  @override
  String systemStatusCardMaxLevel(int currentXp) {
    return '$currentXp SP · Max. úroveň';
  }

  @override
  String get listsScreenTitle => 'Seznamy';

  @override
  String get listsScreenAddNoteTooltip => 'Přidat poznámku';

  @override
  String get listsScreenBucketListHeading => 'Seznam přání';

  @override
  String get listsScreenBucketListSubheading =>
      'Věci, které chcete zažít společně';

  @override
  String get listsScreenEmptyTitle => 'Zatím žádné položky v seznamu přání';

  @override
  String get listsScreenEmptySubtitle => 'Klepni na + a přidej první položku';

  @override
  String get listsScreenErrorTitle => 'Chyba při načítání seznamu přání';

  @override
  String get listsScreenToday => 'Dnes';

  @override
  String get listsScreenYesterday => 'Včera';

  @override
  String listsScreenDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'před $count dny',
      many: 'před $count dny',
      few: 'před $count dny',
      one: 'před $count dnem',
    );
    return '$_temp0';
  }

  @override
  String get settingsScreenTitle => 'Nastavení';

  @override
  String get settingsScreenDeleteAccountTitle => 'Smazat účet';

  @override
  String get settingsScreenDeleteAccountWarning =>
      'Tuto akci nelze vrátit zpět. Trvale se smaže:';

  @override
  String get settingsScreenDeleteAccountBulletList =>
      '• Tvůj účet a profil\n• Všechny vzpomínky a fotky\n• Všechny záznamy a data o intimitě\n• Tvé propojení (partner bude odpojen)\n• Všechny poznámky a seznamy';

  @override
  String get settingsScreenDeleteAccountConfirmQuestion =>
      'Jsi si opravdu jistý/á?';

  @override
  String get settingsScreenDeleteForever => 'Smazat navždy';

  @override
  String get settingsScreenDeletingAccount => 'Mažu účet...';

  @override
  String settingsScreenDeleteAccountError(String error) {
    return 'Chyba při mazání účtu: $error';
  }

  @override
  String get settingsScreenMustBePairedForAnniversary =>
      'Pro nastavení výročí musíš být spárovaný/á s partnerem';

  @override
  String get settingsScreenSelectAnniversaryDateHelp => 'Vyber datum výročí';

  @override
  String get settingsScreenSetAnniversaryConfirm => 'Nastavit';

  @override
  String get settingsScreenAnniversaryUpdated =>
      'Datum výročí bylo aktualizováno';

  @override
  String settingsScreenAnniversaryUpdateError(String error) {
    return 'Chyba při aktualizaci data výročí: $error';
  }

  @override
  String get settingsScreenAnniversaryDateLabel => 'Datum výročí';

  @override
  String get settingsScreenSetAnniversaryDatePrompt => 'Nastav si datum výročí';

  @override
  String settingsScreenDaysTogether(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dní spolu',
      many: '$count dne spolu',
      few: '$count dny spolu',
      one: '$count den spolu',
    );
    return '$_temp0';
  }

  @override
  String get settingsScreenLoading => 'Načítání...';

  @override
  String get settingsScreenAppearanceLabel => 'Vzhled';

  @override
  String get settingsScreenThemeLight => 'Světlý';

  @override
  String get settingsScreenThemeDark => 'Tmavý';

  @override
  String get settingsScreenThemeSystem => 'Systémový';

  @override
  String get settingsScreenPairingLabel => 'Propojení';

  @override
  String get settingsScreenPairingSubtitle => 'Spravuj své propojení';

  @override
  String get settingsScreenDeleteAccountSubtitle => 'Trvale smaž svůj účet';

  @override
  String get settingsScreenLogOut => 'Odhlásit se';

  @override
  String get settingsScreenLogoutConfirmQuestion =>
      'Opravdu se chceš odhlásit?';

  @override
  String get settingsScreenLogoutSubtitle => 'Odhlaš se a ukonči relaci';

  @override
  String settingsScreenLogoutError(String error) {
    return 'Chyba při odhlašování: $error';
  }

  @override
  String get addNoteScreenContentEmptyError => 'Obsah nesmí být prázdný';

  @override
  String get addNoteScreenNotAuthenticatedError =>
      'Uživatel není přihlášen. Přihlas se prosím znovu.';

  @override
  String get addNoteScreenNotPairedError =>
      'Nejsi spárovaný/á s partnerem. Nejdřív se prosím spáruj.';

  @override
  String get addNoteScreenSaveSuccess => 'Poznámka byla úspěšně uložena!';

  @override
  String addNoteScreenSaveError(String error) {
    return 'Chyba při ukládání poznámky: $error';
  }

  @override
  String get addNoteScreenTitle => 'Přidat poznámku';

  @override
  String get addNoteScreenTitleLabel => 'Nadpis (volitelný)';

  @override
  String get addNoteScreenTitleHint => 'Přidej nadpis...';

  @override
  String get addNoteScreenContentLabel => 'Obsah';

  @override
  String get addNoteScreenContentHint => 'Napiš sem svou poznámku...';

  @override
  String get addNoteScreenContentRequired => 'Obsah je povinný';

  @override
  String get addNoteScreenTypeLabel => 'Typ';

  @override
  String get addNoteScreenTypeShared => 'Sdílené';

  @override
  String get addNoteScreenTypePrivate => 'Soukromé';

  @override
  String get addNoteScreenTypeBucketList => 'Seznam přání';

  @override
  String get addNoteScreenTypeSecretGift => 'Tajný dárek';

  @override
  String get addNoteScreenSaveNoteButton => 'Uložit poznámku';

  @override
  String get secretNotesScreenTitle => 'Tajné poznámky';

  @override
  String get secretNotesScreenTabSecretGift => 'Tajný dárek';

  @override
  String get secretNotesScreenTabPrivate => 'Soukromé';

  @override
  String get secretNotesScreenEmptySecretGiftTitle =>
      'Zatím žádné nápady na tajný dárek';

  @override
  String get secretNotesScreenEmptySecretGiftSubtitle =>
      'Klepni na + a přidej první nápad na dárek';

  @override
  String get secretNotesScreenEmptyPrivateTitle =>
      'Zatím žádné soukromé poznámky';

  @override
  String get secretNotesScreenEmptyPrivateSubtitle =>
      'Klepni na + a přidej první soukromou poznámku';

  @override
  String get secretNotesScreenErrorTitle => 'Chyba při načítání poznámek';

  @override
  String get secretNotesScreenToday => 'Dnes';

  @override
  String get secretNotesScreenYesterday => 'Včera';

  @override
  String secretNotesScreenDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'před $count dny',
      many: 'před $count dny',
      few: 'před $count dny',
      one: 'před $count dnem',
    );
    return '$_temp0';
  }

  @override
  String get premiumLandingScreenTitle => 'DYOS+';

  @override
  String get premiumLandingScreenYouHavePremium => 'Máš DYOS+';

  @override
  String get premiumLandingScreenOneSubscriptionBoth =>
      'Jedno předplatné pro vás oba.';

  @override
  String get premiumLandingScreenChooseYourPlan => 'Vyber si plán';

  @override
  String premiumLandingScreenLoadPlansError(String error) {
    return 'Plány se nepodařilo načíst: $error. Potáhni dolů pro nový pokus.';
  }

  @override
  String get premiumLandingScreenCancelAnytimeNote =>
      'Kdykoliv zrušitelné. Jedno předplatné pro vás oba.';

  @override
  String get premiumLandingScreenHeroSubtitle => 'Víc pro vás dva';

  @override
  String get premiumLandingScreenHeroDescription =>
      'Neomezené vzpomínky, přehledy a žádné limity. Jeden plán pro vás oba.';

  @override
  String get premiumLandingScreenInstantBenefits => 'Okamžité výhody';

  @override
  String get premiumLandingScreenNoPlansAvailable =>
      'Momentálně nejsou dostupné žádné plány. Potáhni dolů pro nový pokus.';

  @override
  String get premiumLandingScreenNoPlansConfigured =>
      'Žádné plány nejsou nastaveny. Potáhni dolů pro nový pokus.';

  @override
  String get premiumLandingScreenYearly => 'Roční';

  @override
  String get premiumLandingScreenMonthly => 'Měsíční';

  @override
  String get premiumLandingScreenYearlyBilling => 'Roční fakturace';

  @override
  String get premiumLandingScreenMonthlyBilling => 'Měsíční fakturace';

  @override
  String get premiumLandingScreenGetPremiumNow => 'Získej DYOS+ hned';

  @override
  String get premiumLandingScreenRestore => 'Obnovit';

  @override
  String get premiumLandingScreenPrivacy => 'Soukromí';

  @override
  String get premiumLandingScreenTerms => 'Podmínky';

  @override
  String get paywallModalTitle => 'DYOS+';

  @override
  String get paywallModalLoadError =>
      'Plány se nepodařilo načíst. Zkus to prosím znovu.';

  @override
  String get paywallModalNoPlansAvailable => 'Žádné plány nejsou dostupné.';

  @override
  String get paywallModalYearly => 'Roční';

  @override
  String get paywallModalMonthly => 'Měsíční';

  @override
  String get paywallModalMonthlyBilling => 'Měsíční fakturace';

  @override
  String get paywallModalRestorePurchases => 'Obnovit nákupy';
}
