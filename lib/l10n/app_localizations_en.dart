// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'BizExpense';

  @override
  String get appTagline => 'Your smart tax partner';

  @override
  String get navHome => 'Home';

  @override
  String get navStatistics => 'Statistics';

  @override
  String get navTax => 'Tax';

  @override
  String get navCommunity => 'Community';

  @override
  String get navMenu => 'Menu';

  @override
  String get login => 'Sign In';

  @override
  String get loginSubtitle => 'Please sign in to continue.';

  @override
  String get loginLoading => 'Signing in...';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get loginError => 'Incorrect email or password.';

  @override
  String get loginEmailRequired => 'Please enter your email and password.';

  @override
  String get loginGenericError => 'An error occurred. Please try again.';

  @override
  String get signupStep1Title => 'Create Account';

  @override
  String get signupStep1Sub => 'Enter your email and password.';

  @override
  String get signupStep2Title => 'Set Up Profile';

  @override
  String get signupStep2Sub => 'Set your basic info and username.';

  @override
  String get signupStep3Title => 'Business Type';

  @override
  String get signupStep3Sub => 'How will you use the app?';

  @override
  String get signupBannerStep1 => 'Start Securely';

  @override
  String get signupBannerStep2 => 'Introduce Yourself';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get passwordHint =>
      'Password (8+ chars, letters, numbers, special chars)';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get age => 'Age (Optional)';

  @override
  String get username => 'Username';

  @override
  String get bio => 'Bio (Optional)';

  @override
  String get bioHint => 'e.g. Café owner for 3 years.';

  @override
  String get basicInfo => 'Basic Info';

  @override
  String get communityInfo => 'Community Info';

  @override
  String get communityInfoNote =>
      'Only your username is shown on posts and comments.';

  @override
  String get next => 'Next';

  @override
  String get complete => 'Complete';

  @override
  String get businessIndividual => 'Sole Proprietor';

  @override
  String get businessIndividualSub => 'Expense tracking, VAT & income tax';

  @override
  String get businessCorporate => 'Corporation';

  @override
  String get businessCorporateSub => 'Corporate expense & accounting';

  @override
  String get personal => 'Personal';

  @override
  String get personalSub => 'Personal budget management';

  @override
  String get mostPopular => 'Most Popular';

  @override
  String get signupChooseType =>
      'Choose your business type\nand we\'ll optimise the app for you.';

  @override
  String get validEmailRequired => 'Please enter a valid email address.';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters.';

  @override
  String get passwordNeedsLetter => 'Password must include a letter.';

  @override
  String get passwordNeedsNumber => 'Password must include a number.';

  @override
  String get passwordNeedsSpecial =>
      'Password must include a special character.';

  @override
  String get passwordMismatch => 'Passwords do not match.';

  @override
  String get nameRequired => 'Please enter your name.';

  @override
  String get usernameTooShort => 'Username must be at least 2 characters.';

  @override
  String get signupFailed => 'Sign up failed. Please try again.';

  @override
  String get emailAlreadyRegistered => 'This email is already registered.';

  @override
  String get invalidEmail => 'Invalid email format.';

  @override
  String get weakPassword =>
      'Password must be 8+ chars with letters, numbers & special characters.';

  @override
  String heroNetProfit(String month) {
    return '$month Forecast Net Profit';
  }

  @override
  String get heroProfit => '▲ Profit Expected';

  @override
  String get heroLoss => '▼ Loss Expected';

  @override
  String get heroExpectedIncome => 'Expected Income';

  @override
  String get heroExpectedExpense => 'Expected Expense';

  @override
  String heroGreeting(String name) {
    return '$name';
  }

  @override
  String get actionAddIncome => 'Add Income';

  @override
  String get actionAddExpense => 'Add Expense';

  @override
  String get actionScanReceipt => 'Scan Receipt';

  @override
  String get actionTaxReport => 'Tax Report';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get viewAll => 'View All';

  @override
  String get countrySelectTitle => 'Select Your Country';

  @override
  String get countrySelectSubtitle =>
      'Tax settings are configured automatically.';

  @override
  String get countryDetected => 'Detected';

  @override
  String get countrySelectContinue => 'Continue';

  @override
  String get countryVat => 'VAT';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsCountryRegion => 'Country / Region';

  @override
  String get settingsCountryPickerTitle => 'Select Country / Region';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsFontSize => 'Font Size';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsExport => 'Export Data';

  @override
  String get settingsLogout => 'Sign Out';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsSmall => 'Small';

  @override
  String get settingsMedium => 'Medium';

  @override
  String get settingsLarge => 'Large';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get searchHint => 'Search by name, memo, amount...';

  @override
  String get noResults => 'No results found.';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get balance => 'Balance';

  @override
  String get category => 'Category';

  @override
  String get memo => 'Memo';

  @override
  String get date => 'Date';

  @override
  String get amount => 'Amount';

  @override
  String get paymentMethod => 'Payment Method';
}
