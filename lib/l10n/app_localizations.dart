import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'BizExpense'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your smart tax partner'**
  String get appTagline;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get navStatistics;

  /// No description provided for @navTax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get navTax;

  /// No description provided for @navCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get navCommunity;

  /// No description provided for @navMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get navMenu;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get login;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to continue.'**
  String get loginSubtitle;

  /// No description provided for @loginLoading.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get loginLoading;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get loginError;

  /// No description provided for @loginEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email and password.'**
  String get loginEmailRequired;

  /// No description provided for @loginGenericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get loginGenericError;

  /// No description provided for @signupStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signupStep1Title;

  /// No description provided for @signupStep1Sub.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and password.'**
  String get signupStep1Sub;

  /// No description provided for @signupStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Set Up Profile'**
  String get signupStep2Title;

  /// No description provided for @signupStep2Sub.
  ///
  /// In en, this message translates to:
  /// **'Set your basic info and username.'**
  String get signupStep2Sub;

  /// No description provided for @signupStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Business Type'**
  String get signupStep3Title;

  /// No description provided for @signupStep3Sub.
  ///
  /// In en, this message translates to:
  /// **'How will you use the app?'**
  String get signupStep3Sub;

  /// No description provided for @signupBannerStep1.
  ///
  /// In en, this message translates to:
  /// **'Start Securely'**
  String get signupBannerStep1;

  /// No description provided for @signupBannerStep2.
  ///
  /// In en, this message translates to:
  /// **'Introduce Yourself'**
  String get signupBannerStep2;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password (8+ chars, letters, numbers, special chars)'**
  String get passwordHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age (Optional)'**
  String get age;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio (Optional)'**
  String get bio;

  /// No description provided for @bioHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Café owner for 3 years.'**
  String get bioHint;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get basicInfo;

  /// No description provided for @communityInfo.
  ///
  /// In en, this message translates to:
  /// **'Community Info'**
  String get communityInfo;

  /// No description provided for @communityInfoNote.
  ///
  /// In en, this message translates to:
  /// **'Only your username is shown on posts and comments.'**
  String get communityInfoNote;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @businessIndividual.
  ///
  /// In en, this message translates to:
  /// **'Sole Proprietor'**
  String get businessIndividual;

  /// No description provided for @businessIndividualSub.
  ///
  /// In en, this message translates to:
  /// **'Expense tracking, VAT & income tax'**
  String get businessIndividualSub;

  /// No description provided for @businessCorporate.
  ///
  /// In en, this message translates to:
  /// **'Corporation'**
  String get businessCorporate;

  /// No description provided for @businessCorporateSub.
  ///
  /// In en, this message translates to:
  /// **'Corporate expense & accounting'**
  String get businessCorporateSub;

  /// No description provided for @personal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// No description provided for @personalSub.
  ///
  /// In en, this message translates to:
  /// **'Personal budget management'**
  String get personalSub;

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get mostPopular;

  /// No description provided for @signupChooseType.
  ///
  /// In en, this message translates to:
  /// **'Choose your business type\nand we\'ll optimise the app for you.'**
  String get signupChooseType;

  /// No description provided for @validEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get validEmailRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get passwordTooShort;

  /// No description provided for @passwordNeedsLetter.
  ///
  /// In en, this message translates to:
  /// **'Password must include a letter.'**
  String get passwordNeedsLetter;

  /// No description provided for @passwordNeedsNumber.
  ///
  /// In en, this message translates to:
  /// **'Password must include a number.'**
  String get passwordNeedsNumber;

  /// No description provided for @passwordNeedsSpecial.
  ///
  /// In en, this message translates to:
  /// **'Password must include a special character.'**
  String get passwordNeedsSpecial;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordMismatch;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name.'**
  String get nameRequired;

  /// No description provided for @usernameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 2 characters.'**
  String get usernameTooShort;

  /// No description provided for @signupFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign up failed. Please try again.'**
  String get signupFailed;

  /// No description provided for @emailAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered.'**
  String get emailAlreadyRegistered;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format.'**
  String get invalidEmail;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be 8+ chars with letters, numbers & special characters.'**
  String get weakPassword;

  /// No description provided for @heroNetProfit.
  ///
  /// In en, this message translates to:
  /// **'{month} Forecast Net Profit'**
  String heroNetProfit(String month);

  /// No description provided for @heroProfit.
  ///
  /// In en, this message translates to:
  /// **'▲ Profit Expected'**
  String get heroProfit;

  /// No description provided for @heroLoss.
  ///
  /// In en, this message translates to:
  /// **'▼ Loss Expected'**
  String get heroLoss;

  /// No description provided for @heroExpectedIncome.
  ///
  /// In en, this message translates to:
  /// **'Expected Income'**
  String get heroExpectedIncome;

  /// No description provided for @heroExpectedExpense.
  ///
  /// In en, this message translates to:
  /// **'Expected Expense'**
  String get heroExpectedExpense;

  /// No description provided for @heroGreeting.
  ///
  /// In en, this message translates to:
  /// **'{name}'**
  String heroGreeting(String name);

  /// No description provided for @actionAddIncome.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get actionAddIncome;

  /// No description provided for @actionAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get actionAddExpense;

  /// No description provided for @actionScanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan Receipt'**
  String get actionScanReceipt;

  /// No description provided for @actionTaxReport.
  ///
  /// In en, this message translates to:
  /// **'Tax Report'**
  String get actionTaxReport;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @countrySelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Your Country'**
  String get countrySelectTitle;

  /// No description provided for @countrySelectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tax settings are configured automatically.'**
  String get countrySelectSubtitle;

  /// No description provided for @countryDetected.
  ///
  /// In en, this message translates to:
  /// **'Detected'**
  String get countryDetected;

  /// No description provided for @countrySelectContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get countrySelectContinue;

  /// No description provided for @countryVat.
  ///
  /// In en, this message translates to:
  /// **'VAT'**
  String get countryVat;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsCountryRegion.
  ///
  /// In en, this message translates to:
  /// **'Country / Region'**
  String get settingsCountryRegion;

  /// No description provided for @settingsCountryPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Country / Region'**
  String get settingsCountryPickerTitle;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsFontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get settingsFontSize;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsExport.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get settingsExport;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settingsLogout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get settingsSmall;

  /// No description provided for @settingsMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get settingsMedium;

  /// No description provided for @settingsLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get settingsLarge;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, memo, amount...'**
  String get searchHint;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get noResults;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @memo.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get memo;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
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
