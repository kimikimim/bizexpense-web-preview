import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

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
    Locale('ko'),
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

  /// No description provided for @loginWithKakao.
  ///
  /// In en, this message translates to:
  /// **'Continue with Kakao'**
  String get loginWithKakao;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginWithGoogle;

  /// No description provided for @loginWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get loginWithApple;

  /// No description provided for @loginOrDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get loginOrDivider;

  /// No description provided for @loginOAuthError.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Please try again.'**
  String get loginOAuthError;

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

  /// No description provided for @menuAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get menuAll;

  /// No description provided for @menuBusinessManagement.
  ///
  /// In en, this message translates to:
  /// **'Business Management'**
  String get menuBusinessManagement;

  /// No description provided for @menuStatisticsAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Statistics & Analytics'**
  String get menuStatisticsAnalysis;

  /// No description provided for @menuStatisticsAnalysisSub.
  ///
  /// In en, this message translates to:
  /// **'Revenue & expense trends, category analysis'**
  String get menuStatisticsAnalysisSub;

  /// No description provided for @menuProfileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get menuProfileSettings;

  /// No description provided for @menuProfileSettingsSub.
  ///
  /// In en, this message translates to:
  /// **'Name, age, nickname management'**
  String get menuProfileSettingsSub;

  /// No description provided for @menuTaxReport.
  ///
  /// In en, this message translates to:
  /// **'Tax Report'**
  String get menuTaxReport;

  /// No description provided for @menuTaxReportSub.
  ///
  /// In en, this message translates to:
  /// **'Quarterly VAT & income tax report'**
  String get menuTaxReportSub;

  /// No description provided for @menuTaxSchedule.
  ///
  /// In en, this message translates to:
  /// **'Tax Schedule'**
  String get menuTaxSchedule;

  /// No description provided for @menuTaxScheduleSub.
  ///
  /// In en, this message translates to:
  /// **'VAT / income tax filing deadline management'**
  String get menuTaxScheduleSub;

  /// No description provided for @menuRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring Transactions'**
  String get menuRecurring;

  /// No description provided for @menuRecurringSub.
  ///
  /// In en, this message translates to:
  /// **'Auto-register rent, subscriptions, payroll, etc.'**
  String get menuRecurringSub;

  /// No description provided for @menuInvoice.
  ///
  /// In en, this message translates to:
  /// **'Issue Invoice'**
  String get menuInvoice;

  /// No description provided for @menuInvoiceSub.
  ///
  /// In en, this message translates to:
  /// **'Create invoices to send to clients'**
  String get menuInvoiceSub;

  /// No description provided for @menuDataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get menuDataManagement;

  /// No description provided for @menuExportExcel.
  ///
  /// In en, this message translates to:
  /// **'Export to Excel'**
  String get menuExportExcel;

  /// No description provided for @menuExportExcelSub.
  ///
  /// In en, this message translates to:
  /// **'Generate Excel file with all revenue & expenses'**
  String get menuExportExcelSub;

  /// No description provided for @menuTaxExcel.
  ///
  /// In en, this message translates to:
  /// **'Tax Settlement Excel'**
  String get menuTaxExcel;

  /// No description provided for @menuTaxExcelSub.
  ///
  /// In en, this message translates to:
  /// **'Save in NTS e-filing format'**
  String get menuTaxExcelSub;

  /// No description provided for @menuPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get menuPreferences;

  /// No description provided for @menuDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get menuDarkMode;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuSettingsSub.
  ///
  /// In en, this message translates to:
  /// **'Font size, business info, data backup'**
  String get menuSettingsSub;

  /// No description provided for @menuLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get menuLogout;

  /// No description provided for @menuLogoutSub.
  ///
  /// In en, this message translates to:
  /// **'Sign out from this device only'**
  String get menuLogoutSub;

  /// No description provided for @menuFrequentlyUsed.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get menuFrequentlyUsed;

  /// No description provided for @menuStatisticsShort.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get menuStatisticsShort;

  /// No description provided for @menuTaxReportShort.
  ///
  /// In en, this message translates to:
  /// **'Tax\nReport'**
  String get menuTaxReportShort;

  /// No description provided for @menuTaxScheduleShort.
  ///
  /// In en, this message translates to:
  /// **'Tax\nSchedule'**
  String get menuTaxScheduleShort;

  /// No description provided for @menuSettingsShort.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettingsShort;

  /// No description provided for @menuManagingBusiness.
  ///
  /// In en, this message translates to:
  /// **'Managing business'**
  String get menuManagingBusiness;

  /// No description provided for @logoutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get logoutDialogTitle;

  /// No description provided for @logoutDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get logoutDialogContent;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get logoutConfirm;

  /// No description provided for @noDataToExport.
  ///
  /// In en, this message translates to:
  /// **'No data to export.'**
  String get noDataToExport;

  /// No description provided for @exportExcelSuccess.
  ///
  /// In en, this message translates to:
  /// **'Tax settlement Excel file has been created.'**
  String get exportExcelSuccess;

  /// No description provided for @exportExcelBasicSuccess.
  ///
  /// In en, this message translates to:
  /// **'Excel file has been created.'**
  String get exportExcelBasicSuccess;

  /// No description provided for @exportExcelError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during export.'**
  String get exportExcelError;

  /// No description provided for @settingsDisplaySettings.
  ///
  /// In en, this message translates to:
  /// **'Display Settings'**
  String get settingsDisplaySettings;

  /// No description provided for @settingsFontSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get settingsFontSizeLabel;

  /// No description provided for @settingsFontSizeVerySmall.
  ///
  /// In en, this message translates to:
  /// **'Very Small'**
  String get settingsFontSizeVerySmall;

  /// No description provided for @settingsFontSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get settingsFontSizeSmall;

  /// No description provided for @settingsFontSizeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get settingsFontSizeNormal;

  /// No description provided for @settingsFontSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get settingsFontSizeLarge;

  /// No description provided for @settingsFontSizeVeryLarge.
  ///
  /// In en, this message translates to:
  /// **'Very Large'**
  String get settingsFontSizeVeryLarge;

  /// No description provided for @settingsBusinessManagement.
  ///
  /// In en, this message translates to:
  /// **'Business Management'**
  String get settingsBusinessManagement;

  /// No description provided for @settingsMyBusinessInfo.
  ///
  /// In en, this message translates to:
  /// **'My Business Info'**
  String get settingsMyBusinessInfo;

  /// No description provided for @settingsMyBusinessInfoSub.
  ///
  /// In en, this message translates to:
  /// **'Business name, registration number, address, etc.'**
  String get settingsMyBusinessInfoSub;

  /// No description provided for @settingsTaxScheduleSetup.
  ///
  /// In en, this message translates to:
  /// **'Tax Schedule Setup'**
  String get settingsTaxScheduleSetup;

  /// No description provided for @settingsTaxScheduleSetupSub.
  ///
  /// In en, this message translates to:
  /// **'Change business type, tax type'**
  String get settingsTaxScheduleSetupSub;

  /// No description provided for @settingsDataBackup.
  ///
  /// In en, this message translates to:
  /// **'Data Backup'**
  String get settingsDataBackup;

  /// No description provided for @settingsDataBackupSub.
  ///
  /// In en, this message translates to:
  /// **'Auto backup to cloud'**
  String get settingsDataBackupSub;

  /// No description provided for @settingsBackupFileDownload.
  ///
  /// In en, this message translates to:
  /// **'Download Backup File'**
  String get settingsBackupFileDownload;

  /// No description provided for @settingsBackupFileDownloadSub.
  ///
  /// In en, this message translates to:
  /// **'Save backup file locally'**
  String get settingsBackupFileDownloadSub;

  /// No description provided for @settingsDataRestore.
  ///
  /// In en, this message translates to:
  /// **'Data Restore'**
  String get settingsDataRestore;

  /// No description provided for @settingsDataRestoreSub.
  ///
  /// In en, this message translates to:
  /// **'Restore data from backup file'**
  String get settingsDataRestoreSub;

  /// No description provided for @settingsTaxSettlementExcel.
  ///
  /// In en, this message translates to:
  /// **'Tax Settlement Excel'**
  String get settingsTaxSettlementExcel;

  /// No description provided for @settingsTaxSettlementExcelSub.
  ///
  /// In en, this message translates to:
  /// **'Generate NTS e-filing format file'**
  String get settingsTaxSettlementExcelSub;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Customer Support'**
  String get settingsSupport;

  /// No description provided for @settingsKakaoInquiry.
  ///
  /// In en, this message translates to:
  /// **'KakaoTalk 1:1 Inquiry'**
  String get settingsKakaoInquiry;

  /// No description provided for @settingsKakaoInquirySub.
  ///
  /// In en, this message translates to:
  /// **'Get the fastest response'**
  String get settingsKakaoInquirySub;

  /// No description provided for @settingsEmailInquiry.
  ///
  /// In en, this message translates to:
  /// **'Email Inquiry'**
  String get settingsEmailInquiry;

  /// No description provided for @settingsTermsAndPolicy.
  ///
  /// In en, this message translates to:
  /// **'Terms & Policies'**
  String get settingsTermsAndPolicy;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTermsOfService;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsOpenSourceLicense.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get settingsOpenSourceLicense;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get settingsAppVersion;

  /// No description provided for @settingsCountryPickerTitleAlt.
  ///
  /// In en, this message translates to:
  /// **'Country / Region'**
  String get settingsCountryPickerTitleAlt;

  /// No description provided for @settingsLinkError.
  ///
  /// In en, this message translates to:
  /// **'Cannot open link.'**
  String get settingsLinkError;

  /// No description provided for @settingsMailError.
  ///
  /// In en, this message translates to:
  /// **'Cannot find default mail app.'**
  String get settingsMailError;

  /// No description provided for @settingsBackupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup complete!'**
  String get settingsBackupSuccess;

  /// No description provided for @settingsBackupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed.'**
  String get settingsBackupFailed;

  /// No description provided for @settingsBackupShared.
  ///
  /// In en, this message translates to:
  /// **'Backup file shared.'**
  String get settingsBackupShared;

  /// No description provided for @settingsBackupShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create backup file.'**
  String get settingsBackupShareFailed;

  /// No description provided for @settingsRestoreDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get settingsRestoreDialogTitle;

  /// No description provided for @settingsRestoreDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Existing data will be deleted and replaced with backup data. Continue?'**
  String get settingsRestoreDialogContent;

  /// No description provided for @settingsRestoreConfirm.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get settingsRestoreConfirm;

  /// No description provided for @settingsRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restore complete!'**
  String get settingsRestoreSuccess;

  /// No description provided for @settingsRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed.'**
  String get settingsRestoreFailed;

  /// No description provided for @settingsFileReadFailed.
  ///
  /// In en, this message translates to:
  /// **'File read failed: {error}'**
  String settingsFileReadFailed(String error);

  /// No description provided for @settingsFileNotReadable.
  ///
  /// In en, this message translates to:
  /// **'Cannot read file.'**
  String get settingsFileNotReadable;

  /// No description provided for @settingsFilePathNotFound.
  ///
  /// In en, this message translates to:
  /// **'File path not found.'**
  String get settingsFilePathNotFound;

  /// No description provided for @userTypeSelectPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please choose your purpose.'**
  String get userTypeSelectPrompt;

  /// No description provided for @userTypePersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get userTypePersonal;

  /// No description provided for @userTypePersonalSub.
  ///
  /// In en, this message translates to:
  /// **'Living expenses, allowance management'**
  String get userTypePersonalSub;

  /// No description provided for @userTypeBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get userTypeBusiness;

  /// No description provided for @userTypeBusinessSub.
  ///
  /// In en, this message translates to:
  /// **'Expense management, tax management'**
  String get userTypeBusinessSub;

  /// No description provided for @userTypeIndividual.
  ///
  /// In en, this message translates to:
  /// **'Sole Proprietor'**
  String get userTypeIndividual;

  /// No description provided for @userTypeCorporate.
  ///
  /// In en, this message translates to:
  /// **'Corporation'**
  String get userTypeCorporate;

  /// No description provided for @userTypeSaveError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while saving settings.'**
  String get userTypeSaveError;

  /// No description provided for @addTransactionNew.
  ///
  /// In en, this message translates to:
  /// **'New Entry'**
  String get addTransactionNew;

  /// No description provided for @addTransactionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Entry'**
  String get addTransactionEdit;

  /// No description provided for @addTransactionType.
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get addTransactionType;

  /// No description provided for @addTransactionInfo.
  ///
  /// In en, this message translates to:
  /// **'Transaction Info'**
  String get addTransactionInfo;

  /// No description provided for @addTransactionExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get addTransactionExpense;

  /// No description provided for @addTransactionIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get addTransactionIncome;

  /// No description provided for @addTransactionStoreName.
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get addTransactionStoreName;

  /// No description provided for @addTransactionStoreNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get addTransactionStoreNameRequired;

  /// No description provided for @addTransactionAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get addTransactionAmountLabel;

  /// No description provided for @addTransactionAmountUnit.
  ///
  /// In en, this message translates to:
  /// **'KRW'**
  String get addTransactionAmountUnit;

  /// No description provided for @addTransactionAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get addTransactionAmountRequired;

  /// No description provided for @addTransactionPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get addTransactionPaymentMethod;

  /// No description provided for @addTransactionDepositMethod.
  ///
  /// In en, this message translates to:
  /// **'Deposit Method'**
  String get addTransactionDepositMethod;

  /// No description provided for @addTransactionInstallment.
  ///
  /// In en, this message translates to:
  /// **'Installment Months'**
  String get addTransactionInstallment;

  /// No description provided for @addTransactionInstallmentOnce.
  ///
  /// In en, this message translates to:
  /// **'Full Payment'**
  String get addTransactionInstallmentOnce;

  /// No description provided for @addTransactionInstallmentCustom.
  ///
  /// In en, this message translates to:
  /// **'Enter Directly'**
  String get addTransactionInstallmentCustom;

  /// No description provided for @addTransactionInstallmentMonths.
  ///
  /// In en, this message translates to:
  /// **'{n} months'**
  String addTransactionInstallmentMonths(String n);

  /// No description provided for @addTransactionCashReceiptBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business Expense Proof'**
  String get addTransactionCashReceiptBusiness;

  /// No description provided for @addTransactionCashReceiptPersonal.
  ///
  /// In en, this message translates to:
  /// **'Income Deduction'**
  String get addTransactionCashReceiptPersonal;

  /// No description provided for @addTransactionApprovalNumber.
  ///
  /// In en, this message translates to:
  /// **'Approval Number (Optional)'**
  String get addTransactionApprovalNumber;

  /// No description provided for @addTransactionCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get addTransactionCategoryLabel;

  /// No description provided for @addTransactionCategoryDirectInput.
  ///
  /// In en, this message translates to:
  /// **'Enter directly'**
  String get addTransactionCategoryDirectInput;

  /// No description provided for @addTransactionTaxSettings.
  ///
  /// In en, this message translates to:
  /// **'Tax Settings'**
  String get addTransactionTaxSettings;

  /// No description provided for @addTransactionVatDeductible.
  ///
  /// In en, this message translates to:
  /// **'VAT Deductible'**
  String get addTransactionVatDeductible;

  /// No description provided for @addTransactionBusinessExpense.
  ///
  /// In en, this message translates to:
  /// **'This expense is business-related'**
  String get addTransactionBusinessExpense;

  /// No description provided for @addTransactionBusinessExpenseOnSub.
  ///
  /// In en, this message translates to:
  /// **'Included in VAT refund calculation as business expense'**
  String get addTransactionBusinessExpenseOnSub;

  /// No description provided for @addTransactionBusinessExpenseOffSub.
  ///
  /// In en, this message translates to:
  /// **'Marked as personal/non-deductible (excluded from VAT refund)'**
  String get addTransactionBusinessExpenseOffSub;

  /// No description provided for @addTransactionMemoLabel.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get addTransactionMemoLabel;

  /// No description provided for @addTransactionMemoHint.
  ///
  /// In en, this message translates to:
  /// **'Enter details'**
  String get addTransactionMemoHint;

  /// No description provided for @addTransactionMemoHintEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Enter attendees, purpose'**
  String get addTransactionMemoHintEntertainment;

  /// No description provided for @addTransactionSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get addTransactionSaving;

  /// No description provided for @addTransactionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get addTransactionSave;

  /// No description provided for @addTransactionSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved!'**
  String get addTransactionSaved;

  /// No description provided for @addTransactionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted.'**
  String get addTransactionDeleted;

  /// No description provided for @addTransactionLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login required. Please sign in again.'**
  String get addTransactionLoginRequired;

  /// No description provided for @addTransactionImageUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Image upload failed'**
  String get addTransactionImageUploadFailed;

  /// No description provided for @addTransactionReceiptPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please attach a receipt photo'**
  String get addTransactionReceiptPrompt;

  /// No description provided for @addTransactionReceiptRequired.
  ///
  /// In en, this message translates to:
  /// **'Receipt Required'**
  String get addTransactionReceiptRequired;

  /// No description provided for @addTransactionReceiptRequiredContent.
  ///
  /// In en, this message translates to:
  /// **'Based on payment method and amount,\nthis transaction requires a receipt to be kept by tax law.\n\nSave without receipt?'**
  String get addTransactionReceiptRequiredContent;

  /// No description provided for @addTransactionReceiptAttach.
  ///
  /// In en, this message translates to:
  /// **'Attach Receipt'**
  String get addTransactionReceiptAttach;

  /// No description provided for @addTransactionSaveAnyway.
  ///
  /// In en, this message translates to:
  /// **'Save Anyway'**
  String get addTransactionSaveAnyway;

  /// No description provided for @addTransactionCorporateReceiptWarning.
  ///
  /// In en, this message translates to:
  /// **'Missing Proof Notice'**
  String get addTransactionCorporateReceiptWarning;

  /// No description provided for @addTransactionCorporateReceiptContent.
  ///
  /// In en, this message translates to:
  /// **'Corporate expenses generally require receipts.\nSave without a photo?'**
  String get addTransactionCorporateReceiptContent;

  /// No description provided for @addTransactionDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get addTransactionDeleteConfirmTitle;

  /// No description provided for @addTransactionDeleteConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'This entry will be permanently deleted.'**
  String get addTransactionDeleteConfirmContent;

  /// No description provided for @addTransactionReceiptTake.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get addTransactionReceiptTake;

  /// No description provided for @addTransactionReceiptFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get addTransactionReceiptFromGallery;

  /// No description provided for @addTransactionUncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get addTransactionUncategorized;

  /// No description provided for @allTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'All Transactions'**
  String get allTransactionsTitle;

  /// No description provided for @allTransactionsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, memo, category, amount'**
  String get allTransactionsSearchHint;

  /// No description provided for @allTransactionsFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get allTransactionsFilter;

  /// No description provided for @allTransactionsFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get allTransactionsFilterTitle;

  /// No description provided for @allTransactionsFilterReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get allTransactionsFilterReset;

  /// No description provided for @allTransactionsFilterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply Filter'**
  String get allTransactionsFilterApply;

  /// No description provided for @allTransactionsNoResults.
  ///
  /// In en, this message translates to:
  /// **'No entries found.'**
  String get allTransactionsNoResults;

  /// No description provided for @allTransactionsPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get allTransactionsPeriod;

  /// No description provided for @allTransactionsPeriodAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allTransactionsPeriodAll;

  /// No description provided for @allTransactionsPeriodThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get allTransactionsPeriodThisMonth;

  /// No description provided for @allTransactionsPeriodLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get allTransactionsPeriodLastMonth;

  /// No description provided for @allTransactionsPeriodThreeMonths.
  ///
  /// In en, this message translates to:
  /// **'3 Months'**
  String get allTransactionsPeriodThreeMonths;

  /// No description provided for @allTransactionsPeriodCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get allTransactionsPeriodCustom;

  /// No description provided for @allTransactionsTypeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allTransactionsTypeAll;

  /// No description provided for @allTransactionsTypeIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get allTransactionsTypeIncome;

  /// No description provided for @allTransactionsTypeExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get allTransactionsTypeExpense;

  /// No description provided for @allTransactionsFilterPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get allTransactionsFilterPaymentMethod;

  /// No description provided for @allTransactionsFilterCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get allTransactionsFilterCategory;

  /// No description provided for @allTransactionsFilterTaxOptions.
  ///
  /// In en, this message translates to:
  /// **'Tax Options'**
  String get allTransactionsFilterTaxOptions;

  /// No description provided for @allTransactionsFilterNoReceipt.
  ///
  /// In en, this message translates to:
  /// **'No receipt only'**
  String get allTransactionsFilterNoReceipt;

  /// No description provided for @allTransactionsFilterTaxDeductible.
  ///
  /// In en, this message translates to:
  /// **'VAT deductible only'**
  String get allTransactionsFilterTaxDeductible;

  /// No description provided for @allTransactionsFilterSort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get allTransactionsFilterSort;

  /// No description provided for @allTransactionsSortLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get allTransactionsSortLatest;

  /// No description provided for @allTransactionsSortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get allTransactionsSortOldest;

  /// No description provided for @allTransactionsSortAmountDesc.
  ///
  /// In en, this message translates to:
  /// **'Highest Amount'**
  String get allTransactionsSortAmountDesc;

  /// No description provided for @allTransactionsSortAmountAsc.
  ///
  /// In en, this message translates to:
  /// **'Lowest Amount'**
  String get allTransactionsSortAmountAsc;

  /// No description provided for @allTransactionsUncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get allTransactionsUncategorized;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics / Tax Report'**
  String get statisticsTitle;

  /// No description provided for @statisticsTaxReportTab.
  ///
  /// In en, this message translates to:
  /// **'Tax Report'**
  String get statisticsTaxReportTab;

  /// No description provided for @statisticsExpenseTab.
  ///
  /// In en, this message translates to:
  /// **'Expense Statistics'**
  String get statisticsExpenseTab;

  /// No description provided for @statisticsThisMonthTaxScore.
  ///
  /// In en, this message translates to:
  /// **'This Month\'s Tax Score'**
  String get statisticsThisMonthTaxScore;

  /// No description provided for @statisticsDeductibleRatio.
  ///
  /// In en, this message translates to:
  /// **'Deductible Expense Ratio'**
  String get statisticsDeductibleRatio;

  /// No description provided for @statisticsReceiptCoverage.
  ///
  /// In en, this message translates to:
  /// **'Receipt Coverage'**
  String get statisticsReceiptCoverage;

  /// No description provided for @statisticsBigNoReceipt.
  ///
  /// In en, this message translates to:
  /// **'100K+ Missing Receipts'**
  String get statisticsBigNoReceipt;

  /// No description provided for @statisticsDeductibleSection.
  ///
  /// In en, this message translates to:
  /// **'Deductible / Non-Deductible Expenses'**
  String get statisticsDeductibleSection;

  /// No description provided for @statisticsDeductible.
  ///
  /// In en, this message translates to:
  /// **'Deductible'**
  String get statisticsDeductible;

  /// No description provided for @statisticsNonDeductible.
  ///
  /// In en, this message translates to:
  /// **'Non-Deductible / Personal'**
  String get statisticsNonDeductible;

  /// No description provided for @statisticsDeductiblePercent.
  ///
  /// In en, this message translates to:
  /// **'About {percent}% of this month\'s expenses are tax-deductible.'**
  String statisticsDeductiblePercent(String percent);

  /// No description provided for @statisticsTopRiskCategories.
  ///
  /// In en, this message translates to:
  /// **'Top 3 High-Risk Categories'**
  String get statisticsTopRiskCategories;

  /// No description provided for @statisticsReceiptSection.
  ///
  /// In en, this message translates to:
  /// **'Receipt Coverage'**
  String get statisticsReceiptSection;

  /// No description provided for @statisticsNoExpenseThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded this month.'**
  String get statisticsNoExpenseThisMonth;

  /// No description provided for @statisticsTotalExpense.
  ///
  /// In en, this message translates to:
  /// **'Total Expense {amount}'**
  String statisticsTotalExpense(String amount);

  /// No description provided for @statisticsTaxSafe.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get statisticsTaxSafe;

  /// No description provided for @statisticsTaxNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get statisticsTaxNormal;

  /// No description provided for @statisticsTaxWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get statisticsTaxWarning;

  /// No description provided for @statisticsTaxSafeComment.
  ///
  /// In en, this message translates to:
  /// **'Overall tax risk is low.'**
  String get statisticsTaxSafeComment;

  /// No description provided for @statisticsTaxNormalComment.
  ///
  /// In en, this message translates to:
  /// **'Manage a few risk points for better results.'**
  String get statisticsTaxNormalComment;

  /// No description provided for @statisticsTaxWarningComment.
  ///
  /// In en, this message translates to:
  /// **'Check non-deductible expenses and missing receipts.'**
  String get statisticsTaxWarningComment;

  /// No description provided for @taxReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Tax Report'**
  String get taxReportTitle;

  /// No description provided for @taxReportVatRefundEstimate.
  ///
  /// In en, this message translates to:
  /// **'Estimated VAT Refund This Quarter'**
  String get taxReportVatRefundEstimate;

  /// No description provided for @taxReportVatPaymentEstimate.
  ///
  /// In en, this message translates to:
  /// **'Estimated VAT Payment This Quarter'**
  String get taxReportVatPaymentEstimate;

  /// No description provided for @taxReportEstimateNote.
  ///
  /// In en, this message translates to:
  /// **'Estimated based on revenue and expenses entered in the app'**
  String get taxReportEstimateNote;

  /// No description provided for @taxReportMonthlyExpenseBreakdown.
  ///
  /// In en, this message translates to:
  /// **'This Month\'s Expense Breakdown'**
  String get taxReportMonthlyExpenseBreakdown;

  /// No description provided for @taxReportDeductibleExpense.
  ///
  /// In en, this message translates to:
  /// **'Deductible Expenses'**
  String get taxReportDeductibleExpense;

  /// No description provided for @taxReportNonDeductibleExpense.
  ///
  /// In en, this message translates to:
  /// **'Non-Deductible / Personal Expenses'**
  String get taxReportNonDeductibleExpense;

  /// No description provided for @taxReportReceiptStatus.
  ///
  /// In en, this message translates to:
  /// **'Receipt Status'**
  String get taxReportReceiptStatus;

  /// No description provided for @taxReportAllReceiptsRegistered.
  ///
  /// In en, this message translates to:
  /// **'All required receipts are registered'**
  String get taxReportAllReceiptsRegistered;

  /// No description provided for @taxReportMissingReceipts.
  ///
  /// In en, this message translates to:
  /// **'Among expenses requiring receipts,\n{count} have not been registered yet'**
  String taxReportMissingReceipts(String count);

  /// No description provided for @taxReportMissingAmount.
  ///
  /// In en, this message translates to:
  /// **'Missing amount: {amount}'**
  String taxReportMissingAmount(String amount);

  /// No description provided for @taxReportNonDeductibleRatio.
  ///
  /// In en, this message translates to:
  /// **'Non-Deductible Ratio: {ratio}%'**
  String taxReportNonDeductibleRatio(String ratio);

  /// No description provided for @taxReportNoDataYet.
  ///
  /// In en, this message translates to:
  /// **'Almost no expense data this month yet.'**
  String get taxReportNoDataYet;

  /// No description provided for @taxReportNonDeductibleLow.
  ///
  /// In en, this message translates to:
  /// **'Non-deductible ratio is low — relatively stable.'**
  String get taxReportNonDeductibleLow;

  /// No description provided for @taxReportNonDeductibleMedium.
  ///
  /// In en, this message translates to:
  /// **'Non-deductible ratio is a bit high. Consider separating personal expenses.'**
  String get taxReportNonDeductibleMedium;

  /// No description provided for @taxReportNonDeductibleHigh.
  ///
  /// In en, this message translates to:
  /// **'Non-deductible ratio is quite high. You may need a tax consultant.'**
  String get taxReportNonDeductibleHigh;

  /// No description provided for @recurringAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Recurring'**
  String get recurringAddTitle;

  /// No description provided for @recurringEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Recurring'**
  String get recurringEditTitle;

  /// No description provided for @recurringBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get recurringBasicInfo;

  /// No description provided for @recurringNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (e.g. Rent, Payroll)'**
  String get recurringNameLabel;

  /// No description provided for @recurringRequired.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get recurringRequired;

  /// No description provided for @recurringStoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Client / Business Name (Optional)'**
  String get recurringStoreLabel;

  /// No description provided for @recurringCycle.
  ///
  /// In en, this message translates to:
  /// **'Repeat Cycle'**
  String get recurringCycle;

  /// No description provided for @recurringCycleMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get recurringCycleMonthly;

  /// No description provided for @recurringCycleWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get recurringCycleWeekly;

  /// No description provided for @recurringDayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Day {n}'**
  String recurringDayOfMonth(String n);

  /// No description provided for @recurringMemoOptional.
  ///
  /// In en, this message translates to:
  /// **'Memo (Optional)'**
  String get recurringMemoOptional;

  /// No description provided for @recurringMemoHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Store 1 rent, employee payroll'**
  String get recurringMemoHint;

  /// No description provided for @recurringUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get recurringUpdate;

  /// No description provided for @recurringRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get recurringRegister;

  /// No description provided for @recurringLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login required.'**
  String get recurringLoginRequired;

  /// No description provided for @recurringAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount.'**
  String get recurringAmountInvalid;

  /// No description provided for @recurringAdded.
  ///
  /// In en, this message translates to:
  /// **'Recurring transaction added.'**
  String get recurringAdded;

  /// No description provided for @recurringUpdated.
  ///
  /// In en, this message translates to:
  /// **'Recurring transaction updated.'**
  String get recurringUpdated;

  /// No description provided for @recurringSaveError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while saving.'**
  String get recurringSaveError;

  /// No description provided for @recurringListTitle.
  ///
  /// In en, this message translates to:
  /// **'Recurring Transactions'**
  String get recurringListTitle;

  /// No description provided for @recurringListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recurring transactions yet.'**
  String get recurringListEmpty;

  /// No description provided for @recurringListEmptySub.
  ///
  /// In en, this message translates to:
  /// **'Auto-register rent, payroll, subscriptions, etc.'**
  String get recurringListEmptySub;

  /// No description provided for @recurringDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete recurring transaction?'**
  String get recurringDeleteTitle;

  /// No description provided for @recurringDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'This recurring transaction will be deleted.'**
  String get recurringDeleteContent;

  /// No description provided for @recurringMonthlyDay.
  ///
  /// In en, this message translates to:
  /// **'Every month on day {n}'**
  String recurringMonthlyDay(String n);

  /// No description provided for @recurringWeeklyDay.
  ///
  /// In en, this message translates to:
  /// **'Every {weekday}'**
  String recurringWeeklyDay(String weekday);

  /// No description provided for @recurringMonthlyDaySelect.
  ///
  /// In en, this message translates to:
  /// **'Which day of the month?'**
  String get recurringMonthlyDaySelect;

  /// No description provided for @recurringWeekdaySelect.
  ///
  /// In en, this message translates to:
  /// **'Select weekday'**
  String get recurringWeekdaySelect;

  /// No description provided for @recurringCategoryOptional.
  ///
  /// In en, this message translates to:
  /// **'Category (Optional)'**
  String get recurringCategoryOptional;

  /// No description provided for @recurringMethodOptional.
  ///
  /// In en, this message translates to:
  /// **'Payment / Deposit Method (Optional)'**
  String get recurringMethodOptional;

  /// No description provided for @recurringVatDeductibleToggle.
  ///
  /// In en, this message translates to:
  /// **'Treat as VAT-deductible expense'**
  String get recurringVatDeductibleToggle;

  /// No description provided for @recurringActiveToggle.
  ///
  /// In en, this message translates to:
  /// **'Enable auto-generation'**
  String get recurringActiveToggle;

  /// No description provided for @recurringActiveToggleSub.
  ///
  /// In en, this message translates to:
  /// **'When off, entries will no longer be created automatically.'**
  String get recurringActiveToggleSub;

  /// No description provided for @recurringSkipTitle.
  ///
  /// In en, this message translates to:
  /// **'Skip this month only?'**
  String get recurringSkipTitle;

  /// No description provided for @recurringSkipContent.
  ///
  /// In en, this message translates to:
  /// **'This recurring transaction will not auto-generate an entry this month.'**
  String get recurringSkipContent;

  /// No description provided for @recurringSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get recurringSkip;

  /// No description provided for @recurringSkipDone.
  ///
  /// In en, this message translates to:
  /// **'Set to skip this month.'**
  String get recurringSkipDone;

  /// No description provided for @recurringSkipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip this month only'**
  String get recurringSkipButton;

  /// No description provided for @recurringDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete.'**
  String get recurringDeleteFailed;

  /// No description provided for @recurringAutoOff.
  ///
  /// In en, this message translates to:
  /// **'Auto-generation off'**
  String get recurringAutoOff;

  /// No description provided for @homeDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Boss'**
  String get homeDefaultName;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'{name}'**
  String homeGreeting(String name);

  /// No description provided for @statisticsScorePoints.
  ///
  /// In en, this message translates to:
  /// **'{score} pts'**
  String statisticsScorePoints(String score);

  /// No description provided for @taxEventDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Tax Schedule'**
  String get taxEventDefaultTitle;

  /// No description provided for @settingsInquirySubject.
  ///
  /// In en, this message translates to:
  /// **'[BizExpense] Inquiry'**
  String get settingsInquirySubject;

  /// No description provided for @settingsInquiryBody.
  ///
  /// In en, this message translates to:
  /// **'1. Inquiry type:\n2. Details:\n\n(Please write your message here)'**
  String get settingsInquiryBody;

  /// No description provided for @profileEditSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved.'**
  String get profileEditSaved;

  /// No description provided for @profileEditSaveError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while saving: {error}'**
  String profileEditSaveError(String error);

  /// No description provided for @profileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your real name'**
  String get profileNameHint;

  /// No description provided for @profileAgeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 35'**
  String get profileAgeHint;

  /// No description provided for @profileNickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get profileNickname;

  /// No description provided for @profileNicknameSection.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get profileNicknameSection;

  /// No description provided for @profileSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSaveButton;

  /// No description provided for @signupTypeSoleProp.
  ///
  /// In en, this message translates to:
  /// **'Sole Proprietorship'**
  String get signupTypeSoleProp;

  /// No description provided for @signupTypeSolePropSub.
  ///
  /// In en, this message translates to:
  /// **'Individual owner · VAT tracking & expense management'**
  String get signupTypeSolePropSub;

  /// No description provided for @signupTypeLlc.
  ///
  /// In en, this message translates to:
  /// **'LLC / WLL'**
  String get signupTypeLlc;

  /// No description provided for @signupTypeLlcSub.
  ///
  /// In en, this message translates to:
  /// **'Limited Liability Company · corporate accounting'**
  String get signupTypeLlcSub;

  /// No description provided for @signupTypeFreeZone.
  ///
  /// In en, this message translates to:
  /// **'Free Zone Company'**
  String get signupTypeFreeZone;

  /// No description provided for @signupTypeFreeZoneSub.
  ///
  /// In en, this message translates to:
  /// **'DMCC · DIFC · ADGM · NEOM and other free zones'**
  String get signupTypeFreeZoneSub;

  /// No description provided for @signupStepCounter.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String signupStepCounter(String current, String total);

  /// No description provided for @txDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get txDeposit;

  /// No description provided for @txWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal'**
  String get txWithdrawal;

  /// No description provided for @cameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Receipt'**
  String get cameraTitle;

  /// No description provided for @cameraPrompt.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of your receipt'**
  String get cameraPrompt;

  /// No description provided for @cameraCapture.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraCapture;

  /// No description provided for @cameraAlbum.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get cameraAlbum;

  /// No description provided for @cameraAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing with AI...'**
  String get cameraAnalyzing;

  /// No description provided for @cameraAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze this receipt'**
  String get cameraAnalyze;

  /// No description provided for @cameraAnalyzeFailed.
  ///
  /// In en, this message translates to:
  /// **'Analysis failed. Try again or enter manually.'**
  String get cameraAnalyzeFailed;

  /// No description provided for @myBizTitle.
  ///
  /// In en, this message translates to:
  /// **'My Business Info'**
  String get myBizTitle;

  /// No description provided for @myBizSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String myBizSaveFailed(String error);

  /// No description provided for @myBizProfileSection.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get myBizProfileSection;

  /// No description provided for @myBizNicknameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Boss Kim'**
  String get myBizNicknameHint;

  /// No description provided for @myBizInvoiceInfo.
  ///
  /// In en, this message translates to:
  /// **'🧾 Invoice / Quote Info'**
  String get myBizInvoiceInfo;

  /// No description provided for @myBizCompany.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get myBizCompany;

  /// No description provided for @myBizCompanyHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. BizExpense'**
  String get myBizCompanyHint;

  /// No description provided for @myBizCeo.
  ///
  /// In en, this message translates to:
  /// **'Owner / Representative'**
  String get myBizCeo;

  /// No description provided for @myBizCeoHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. John Smith'**
  String get myBizCeoHint;

  /// No description provided for @myBizTaxNumber.
  ///
  /// In en, this message translates to:
  /// **'Tax Registration No. (TRN)'**
  String get myBizTaxNumber;

  /// No description provided for @myBizTaxNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 100123456700003'**
  String get myBizTaxNumberHint;

  /// No description provided for @myBizAddress.
  ///
  /// In en, this message translates to:
  /// **'Business Address'**
  String get myBizAddress;

  /// No description provided for @myBizAddressHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dubai, UAE'**
  String get myBizAddressHint;

  /// No description provided for @myBizActivity.
  ///
  /// In en, this message translates to:
  /// **'Business Activity'**
  String get myBizActivity;

  /// No description provided for @myBizActivityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Services / Software'**
  String get myBizActivityHint;

  /// No description provided for @myBizWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get myBizWithdraw;

  /// No description provided for @myBizWithdrawConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?\nAll data will be permanently deleted and cannot be recovered.'**
  String get myBizWithdrawConfirm;

  /// No description provided for @myBizWithdrawButton.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get myBizWithdrawButton;

  /// No description provided for @myBizWithdrawDone.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get myBizWithdrawDone;

  /// No description provided for @myBizError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get myBizError;

  /// No description provided for @invoiceMinItem.
  ///
  /// In en, this message translates to:
  /// **'At least one item is required.'**
  String get invoiceMinItem;

  /// No description provided for @invoiceClientRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the client name.'**
  String get invoiceClientRequired;

  /// No description provided for @invoiceItemNamesRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all item names.'**
  String get invoiceItemNamesRequired;

  /// No description provided for @invoicePdfFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate PDF.'**
  String get invoicePdfFailed;

  /// No description provided for @invoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Send a Quote in Seconds'**
  String get invoiceTitle;

  /// No description provided for @invoiceRecipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient (Client)'**
  String get invoiceRecipient;

  /// No description provided for @invoiceClientHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. ABC Trading LLC'**
  String get invoiceClientHint;

  /// No description provided for @invoiceClientLabel.
  ///
  /// In en, this message translates to:
  /// **'Client Name'**
  String get invoiceClientLabel;

  /// No description provided for @invoiceItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get invoiceItems;

  /// No description provided for @invoiceAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get invoiceAddItem;

  /// No description provided for @invoiceItemName.
  ///
  /// In en, this message translates to:
  /// **'Item {n}'**
  String invoiceItemName(String n);

  /// No description provided for @invoiceItemNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Design work'**
  String get invoiceItemNameHint;

  /// No description provided for @invoiceUnitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get invoiceUnitPrice;

  /// No description provided for @invoiceQty.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get invoiceQty;

  /// No description provided for @invoiceShareHint.
  ///
  /// In en, this message translates to:
  /// **'Use the share sheet to send or print the quote.'**
  String get invoiceShareHint;

  /// No description provided for @invoiceGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get invoiceGenerating;

  /// No description provided for @invoiceShare.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get invoiceShare;

  /// No description provided for @taxCalEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No upcoming deadlines.'**
  String get taxCalEmptyTitle;

  /// No description provided for @taxCalEmptySub.
  ///
  /// In en, this message translates to:
  /// **'Set up your tax profile and we\'ll remind you of VAT filing deadlines automatically.'**
  String get taxCalEmptySub;

  /// No description provided for @taxCalSetupButton.
  ///
  /// In en, this message translates to:
  /// **'Set up tax schedule'**
  String get taxCalSetupButton;

  /// No description provided for @taxCalLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load tax schedule'**
  String get taxCalLoadError;

  /// No description provided for @taxBadgeVat.
  ///
  /// In en, this message translates to:
  /// **'VAT'**
  String get taxBadgeVat;

  /// No description provided for @taxBadgeIncome.
  ///
  /// In en, this message translates to:
  /// **'Income Tax'**
  String get taxBadgeIncome;

  /// No description provided for @taxBadgeCorporate.
  ///
  /// In en, this message translates to:
  /// **'Corporate Tax'**
  String get taxBadgeCorporate;

  /// No description provided for @taxBadgeLocal.
  ///
  /// In en, this message translates to:
  /// **'Local Tax'**
  String get taxBadgeLocal;

  /// No description provided for @taxBadgeCar.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Tax'**
  String get taxBadgeCar;

  /// No description provided for @taxBadgeProperty.
  ///
  /// In en, this message translates to:
  /// **'Property Tax'**
  String get taxBadgeProperty;

  /// No description provided for @taxBadgeWht.
  ///
  /// In en, this message translates to:
  /// **'Withholding'**
  String get taxBadgeWht;

  /// No description provided for @taxBadgeInsure.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get taxBadgeInsure;

  /// No description provided for @taxEventVat.
  ///
  /// In en, this message translates to:
  /// **'VAT Return — {period}'**
  String taxEventVat(String period);

  /// No description provided for @taxEventVatPayment.
  ///
  /// In en, this message translates to:
  /// **'VAT Payment — {period}'**
  String taxEventVatPayment(String period);

  /// No description provided for @taxEventCorporate.
  ///
  /// In en, this message translates to:
  /// **'Corporate Tax Return {year}'**
  String taxEventCorporate(String year);

  /// No description provided for @meTaxSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Tax Setup'**
  String get meTaxSetupTitle;

  /// No description provided for @meTaxSetupIntro.
  ///
  /// In en, this message translates to:
  /// **'Set your VAT filing details and we\'ll generate your deadlines.'**
  String get meTaxSetupIntro;

  /// No description provided for @meTaxVatRegistered.
  ///
  /// In en, this message translates to:
  /// **'VAT registered'**
  String get meTaxVatRegistered;

  /// No description provided for @meTaxVatRegisteredSub.
  ///
  /// In en, this message translates to:
  /// **'Is your business registered for VAT?'**
  String get meTaxVatRegisteredSub;

  /// No description provided for @meTaxFilingFrequency.
  ///
  /// In en, this message translates to:
  /// **'Filing frequency'**
  String get meTaxFilingFrequency;

  /// No description provided for @meTaxQuarterly.
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get meTaxQuarterly;

  /// No description provided for @meTaxMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get meTaxMonthly;

  /// No description provided for @meTaxCorporate.
  ///
  /// In en, this message translates to:
  /// **'Subject to Corporate Tax'**
  String get meTaxCorporate;

  /// No description provided for @meTaxCorporateSub.
  ///
  /// In en, this message translates to:
  /// **'Companies (LLC / Free Zone) file corporate tax once a year.'**
  String get meTaxCorporateSub;

  /// No description provided for @meTaxSaved.
  ///
  /// In en, this message translates to:
  /// **'Tax schedule created.'**
  String get meTaxSaved;

  /// No description provided for @meTaxQuarterLabel.
  ///
  /// In en, this message translates to:
  /// **'Q{q} {year}'**
  String meTaxQuarterLabel(String q, String year);

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguagePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get settingsLanguagePickerTitle;

  /// No description provided for @settingsRegionFixedNote.
  ///
  /// In en, this message translates to:
  /// **'Set when you created your account'**
  String get settingsRegionFixedNote;

  /// No description provided for @menuMyInvoices.
  ///
  /// In en, this message translates to:
  /// **'My Invoices'**
  String get menuMyInvoices;

  /// No description provided for @menuMyInvoicesSub.
  ///
  /// In en, this message translates to:
  /// **'View issued invoices'**
  String get menuMyInvoicesSub;

  /// No description provided for @invoiceListTitle.
  ///
  /// In en, this message translates to:
  /// **'My Invoices'**
  String get invoiceListTitle;

  /// No description provided for @invoiceListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No invoices issued yet.'**
  String get invoiceListEmpty;

  /// No description provided for @invoiceListEmptySub.
  ///
  /// In en, this message translates to:
  /// **'Invoices you issue will appear here.'**
  String get invoiceListEmptySub;

  /// No description provided for @invoiceStatusIssued.
  ///
  /// In en, this message translates to:
  /// **'Issued'**
  String get invoiceStatusIssued;

  /// No description provided for @invoiceStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get invoiceStatusDraft;

  /// No description provided for @invoiceStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get invoiceStatusCancelled;

  /// No description provided for @invoiceVatOf.
  ///
  /// In en, this message translates to:
  /// **'incl. VAT {vat}'**
  String invoiceVatOf(String vat);

  /// No description provided for @signupConfirmEmail.
  ///
  /// In en, this message translates to:
  /// **'Account created. Please confirm your email, then sign in.'**
  String get signupConfirmEmail;
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
      <String>['ar', 'en', 'ko'].contains(locale.languageCode);

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
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
