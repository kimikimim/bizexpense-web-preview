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
  String get loginWithKakao => 'Continue with Kakao';

  @override
  String get loginWithGoogle => 'Continue with Google';

  @override
  String get loginWithApple => 'Continue with Apple';

  @override
  String get loginOrDivider => 'or';

  @override
  String get loginOAuthError => 'Sign-in failed. Please try again.';

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

  @override
  String get menuAll => 'All';

  @override
  String get menuBusinessManagement => 'Business Management';

  @override
  String get menuStatisticsAnalysis => 'Statistics & Analytics';

  @override
  String get menuStatisticsAnalysisSub =>
      'Revenue & expense trends, category analysis';

  @override
  String get menuProfileSettings => 'Profile Settings';

  @override
  String get menuProfileSettingsSub => 'Name, age, nickname management';

  @override
  String get menuTaxReport => 'Tax Report';

  @override
  String get menuTaxReportSub => 'Quarterly VAT & income tax report';

  @override
  String get menuTaxSchedule => 'Tax Schedule';

  @override
  String get menuTaxScheduleSub =>
      'VAT / income tax filing deadline management';

  @override
  String get menuRecurring => 'Recurring Transactions';

  @override
  String get menuRecurringSub =>
      'Auto-register rent, subscriptions, payroll, etc.';

  @override
  String get menuInvoice => 'Issue Invoice';

  @override
  String get menuInvoiceSub => 'Create invoices to send to clients';

  @override
  String get menuDataManagement => 'Data Management';

  @override
  String get menuExportExcel => 'Export to Excel';

  @override
  String get menuExportExcelSub =>
      'Generate Excel file with all revenue & expenses';

  @override
  String get menuTaxExcel => 'Tax Settlement Excel';

  @override
  String get menuTaxExcelSub => 'Save in NTS e-filing format';

  @override
  String get menuPreferences => 'Preferences';

  @override
  String get menuDarkMode => 'Dark Mode';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuSettingsSub => 'Font size, business info, data backup';

  @override
  String get menuLogout => 'Sign Out';

  @override
  String get menuLogoutSub => 'Sign out from this device only';

  @override
  String get menuFrequentlyUsed => 'Quick Access';

  @override
  String get menuStatisticsShort => 'Stats';

  @override
  String get menuTaxReportShort => 'Tax\nReport';

  @override
  String get menuTaxScheduleShort => 'Tax\nSchedule';

  @override
  String get menuSettingsShort => 'Settings';

  @override
  String get menuManagingBusiness => 'Managing business';

  @override
  String get logoutDialogTitle => 'Sign Out';

  @override
  String get logoutDialogContent => 'Are you sure you want to sign out?';

  @override
  String get logoutConfirm => 'Sign Out';

  @override
  String get noDataToExport => 'No data to export.';

  @override
  String get exportExcelSuccess =>
      'Tax settlement Excel file has been created.';

  @override
  String get exportExcelBasicSuccess => 'Excel file has been created.';

  @override
  String get exportExcelError => 'An error occurred during export.';

  @override
  String get settingsDisplaySettings => 'Display Settings';

  @override
  String get settingsFontSizeLabel => 'Font Size';

  @override
  String get settingsFontSizeVerySmall => 'Very Small';

  @override
  String get settingsFontSizeSmall => 'Small';

  @override
  String get settingsFontSizeNormal => 'Normal';

  @override
  String get settingsFontSizeLarge => 'Large';

  @override
  String get settingsFontSizeVeryLarge => 'Very Large';

  @override
  String get settingsBusinessManagement => 'Business Management';

  @override
  String get settingsMyBusinessInfo => 'My Business Info';

  @override
  String get settingsMyBusinessInfoSub =>
      'Business name, registration number, address, etc.';

  @override
  String get settingsTaxScheduleSetup => 'Tax Schedule Setup';

  @override
  String get settingsTaxScheduleSetupSub => 'Change business type, tax type';

  @override
  String get settingsDataBackup => 'Data Backup';

  @override
  String get settingsDataBackupSub => 'Auto backup to cloud';

  @override
  String get settingsBackupFileDownload => 'Download Backup File';

  @override
  String get settingsBackupFileDownloadSub => 'Save backup file locally';

  @override
  String get settingsDataRestore => 'Data Restore';

  @override
  String get settingsDataRestoreSub => 'Restore data from backup file';

  @override
  String get settingsTaxSettlementExcel => 'Tax Settlement Excel';

  @override
  String get settingsTaxSettlementExcelSub =>
      'Generate NTS e-filing format file';

  @override
  String get settingsSupport => 'Customer Support';

  @override
  String get settingsKakaoInquiry => 'KakaoTalk 1:1 Inquiry';

  @override
  String get settingsKakaoInquirySub => 'Get the fastest response';

  @override
  String get settingsEmailInquiry => 'Email Inquiry';

  @override
  String get settingsTermsAndPolicy => 'Terms & Policies';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsOpenSourceLicense => 'Open Source Licenses';

  @override
  String get settingsAppVersion => 'App Version';

  @override
  String get settingsCountryPickerTitleAlt => 'Country / Region';

  @override
  String get settingsLinkError => 'Cannot open link.';

  @override
  String get settingsMailError => 'Cannot find default mail app.';

  @override
  String get settingsBackupSuccess => 'Backup complete!';

  @override
  String get settingsBackupFailed => 'Backup failed.';

  @override
  String get settingsBackupShared => 'Backup file shared.';

  @override
  String get settingsBackupShareFailed => 'Failed to create backup file.';

  @override
  String get settingsRestoreDialogTitle => 'Restore Data';

  @override
  String get settingsRestoreDialogContent =>
      'Existing data will be deleted and replaced with backup data. Continue?';

  @override
  String get settingsRestoreConfirm => 'Restore';

  @override
  String get settingsRestoreSuccess => 'Restore complete!';

  @override
  String get settingsRestoreFailed => 'Restore failed.';

  @override
  String settingsFileReadFailed(String error) {
    return 'File read failed: $error';
  }

  @override
  String get settingsFileNotReadable => 'Cannot read file.';

  @override
  String get settingsFilePathNotFound => 'File path not found.';

  @override
  String get userTypeSelectPrompt => 'Please choose your purpose.';

  @override
  String get userTypePersonal => 'Personal';

  @override
  String get userTypePersonalSub => 'Living expenses, allowance management';

  @override
  String get userTypeBusiness => 'Business';

  @override
  String get userTypeBusinessSub => 'Expense management, tax management';

  @override
  String get userTypeIndividual => 'Sole Proprietor';

  @override
  String get userTypeCorporate => 'Corporation';

  @override
  String get userTypeSaveError => 'An error occurred while saving settings.';

  @override
  String get addTransactionNew => 'New Entry';

  @override
  String get addTransactionEdit => 'Edit Entry';

  @override
  String get addTransactionType => 'Transaction Type';

  @override
  String get addTransactionInfo => 'Transaction Info';

  @override
  String get addTransactionExpense => 'Expense';

  @override
  String get addTransactionIncome => 'Income';

  @override
  String get addTransactionStoreName => 'Business Name';

  @override
  String get addTransactionStoreNameRequired => 'Required field';

  @override
  String get addTransactionAmountLabel => 'Amount';

  @override
  String get addTransactionAmountUnit => 'KRW';

  @override
  String get addTransactionAmountRequired => 'Required field';

  @override
  String get addTransactionPaymentMethod => 'Payment Method';

  @override
  String get addTransactionDepositMethod => 'Deposit Method';

  @override
  String get addTransactionInstallment => 'Installment Months';

  @override
  String get addTransactionInstallmentOnce => 'Full Payment';

  @override
  String get addTransactionInstallmentCustom => 'Enter Directly';

  @override
  String addTransactionInstallmentMonths(String n) {
    return '$n months';
  }

  @override
  String get addTransactionCashReceiptBusiness => 'Business Expense Proof';

  @override
  String get addTransactionCashReceiptPersonal => 'Income Deduction';

  @override
  String get addTransactionApprovalNumber => 'Approval Number (Optional)';

  @override
  String get addTransactionCategoryLabel => 'Category';

  @override
  String get addTransactionCategoryDirectInput => 'Enter directly';

  @override
  String get addTransactionTaxSettings => 'Tax Settings';

  @override
  String get addTransactionVatDeductible => 'VAT Deductible';

  @override
  String get addTransactionBusinessExpense =>
      'This expense is business-related';

  @override
  String get addTransactionBusinessExpenseOnSub =>
      'Included in VAT refund calculation as business expense';

  @override
  String get addTransactionBusinessExpenseOffSub =>
      'Marked as personal/non-deductible (excluded from VAT refund)';

  @override
  String get addTransactionMemoLabel => 'Memo';

  @override
  String get addTransactionMemoHint => 'Enter details';

  @override
  String get addTransactionMemoHintEntertainment => 'Enter attendees, purpose';

  @override
  String get addTransactionSaving => 'Saving...';

  @override
  String get addTransactionSave => 'Save';

  @override
  String get addTransactionSaved => 'Saved!';

  @override
  String get addTransactionDeleted => 'Deleted.';

  @override
  String get addTransactionLoginRequired =>
      'Login required. Please sign in again.';

  @override
  String get addTransactionImageUploadFailed => 'Image upload failed';

  @override
  String get addTransactionReceiptPrompt => 'Please attach a receipt photo';

  @override
  String get addTransactionReceiptRequired => 'Receipt Required';

  @override
  String get addTransactionReceiptRequiredContent =>
      'Based on payment method and amount,\nthis transaction requires a receipt to be kept by tax law.\n\nSave without receipt?';

  @override
  String get addTransactionReceiptAttach => 'Attach Receipt';

  @override
  String get addTransactionSaveAnyway => 'Save Anyway';

  @override
  String get addTransactionCorporateReceiptWarning => 'Missing Proof Notice';

  @override
  String get addTransactionCorporateReceiptContent =>
      'Corporate expenses generally require receipts.\nSave without a photo?';

  @override
  String get addTransactionDeleteConfirmTitle => 'Delete this entry?';

  @override
  String get addTransactionDeleteConfirmContent =>
      'This entry will be permanently deleted.';

  @override
  String get addTransactionReceiptTake => 'Take Photo';

  @override
  String get addTransactionReceiptFromGallery => 'Choose from Gallery';

  @override
  String get addTransactionUncategorized => 'Uncategorized';

  @override
  String get allTransactionsTitle => 'All Transactions';

  @override
  String get allTransactionsSearchHint =>
      'Search by name, memo, category, amount';

  @override
  String get allTransactionsFilter => 'Filter';

  @override
  String get allTransactionsFilterTitle => 'Filter';

  @override
  String get allTransactionsFilterReset => 'Reset';

  @override
  String get allTransactionsFilterApply => 'Apply Filter';

  @override
  String get allTransactionsNoResults => 'No entries found.';

  @override
  String get allTransactionsPeriod => 'Period';

  @override
  String get allTransactionsPeriodAll => 'All';

  @override
  String get allTransactionsPeriodThisMonth => 'This Month';

  @override
  String get allTransactionsPeriodLastMonth => 'Last Month';

  @override
  String get allTransactionsPeriodThreeMonths => '3 Months';

  @override
  String get allTransactionsPeriodCustom => 'Custom';

  @override
  String get allTransactionsTypeAll => 'All';

  @override
  String get allTransactionsTypeIncome => 'Income';

  @override
  String get allTransactionsTypeExpense => 'Expense';

  @override
  String get allTransactionsFilterPaymentMethod => 'Payment Method';

  @override
  String get allTransactionsFilterCategory => 'Category';

  @override
  String get allTransactionsFilterTaxOptions => 'Tax Options';

  @override
  String get allTransactionsFilterNoReceipt => 'No receipt only';

  @override
  String get allTransactionsFilterTaxDeductible => 'VAT deductible only';

  @override
  String get allTransactionsFilterSort => 'Sort';

  @override
  String get allTransactionsSortLatest => 'Latest';

  @override
  String get allTransactionsSortOldest => 'Oldest';

  @override
  String get allTransactionsSortAmountDesc => 'Highest Amount';

  @override
  String get allTransactionsSortAmountAsc => 'Lowest Amount';

  @override
  String get allTransactionsUncategorized => 'Uncategorized';

  @override
  String get statisticsTitle => 'Statistics / Tax Report';

  @override
  String get statisticsTaxReportTab => 'Tax Report';

  @override
  String get statisticsExpenseTab => 'Expense Statistics';

  @override
  String get statisticsThisMonthTaxScore => 'This Month\'s Tax Score';

  @override
  String get statisticsDeductibleRatio => 'Deductible Expense Ratio';

  @override
  String get statisticsReceiptCoverage => 'Receipt Coverage';

  @override
  String get statisticsBigNoReceipt => '100K+ Missing Receipts';

  @override
  String get statisticsDeductibleSection =>
      'Deductible / Non-Deductible Expenses';

  @override
  String get statisticsDeductible => 'Deductible';

  @override
  String get statisticsNonDeductible => 'Non-Deductible / Personal';

  @override
  String statisticsDeductiblePercent(String percent) {
    return 'About $percent% of this month\'s expenses are tax-deductible.';
  }

  @override
  String get statisticsTopRiskCategories => 'Top 3 High-Risk Categories';

  @override
  String get statisticsReceiptSection => 'Receipt Coverage';

  @override
  String get statisticsNoExpenseThisMonth => 'No expenses recorded this month.';

  @override
  String statisticsTotalExpense(String amount) {
    return 'Total Expense $amount';
  }

  @override
  String get statisticsTaxSafe => 'Safe';

  @override
  String get statisticsTaxNormal => 'Normal';

  @override
  String get statisticsTaxWarning => 'Warning';

  @override
  String get statisticsTaxSafeComment => 'Overall tax risk is low.';

  @override
  String get statisticsTaxNormalComment =>
      'Manage a few risk points for better results.';

  @override
  String get statisticsTaxWarningComment =>
      'Check non-deductible expenses and missing receipts.';

  @override
  String get taxReportTitle => 'Tax Report';

  @override
  String get taxReportVatRefundEstimate => 'Estimated VAT Refund This Quarter';

  @override
  String get taxReportVatPaymentEstimate =>
      'Estimated VAT Payment This Quarter';

  @override
  String get taxReportEstimateNote =>
      'Estimated based on revenue and expenses entered in the app';

  @override
  String get taxReportMonthlyExpenseBreakdown =>
      'This Month\'s Expense Breakdown';

  @override
  String get taxReportDeductibleExpense => 'Deductible Expenses';

  @override
  String get taxReportNonDeductibleExpense =>
      'Non-Deductible / Personal Expenses';

  @override
  String get taxReportReceiptStatus => 'Receipt Status';

  @override
  String get taxReportAllReceiptsRegistered =>
      'All required receipts are registered';

  @override
  String taxReportMissingReceipts(String count) {
    return 'Among expenses requiring receipts,\n$count have not been registered yet';
  }

  @override
  String taxReportMissingAmount(String amount) {
    return 'Missing amount: $amount';
  }

  @override
  String taxReportNonDeductibleRatio(String ratio) {
    return 'Non-Deductible Ratio: $ratio%';
  }

  @override
  String get taxReportNoDataYet => 'Almost no expense data this month yet.';

  @override
  String get taxReportNonDeductibleLow =>
      'Non-deductible ratio is low — relatively stable.';

  @override
  String get taxReportNonDeductibleMedium =>
      'Non-deductible ratio is a bit high. Consider separating personal expenses.';

  @override
  String get taxReportNonDeductibleHigh =>
      'Non-deductible ratio is quite high. You may need a tax consultant.';

  @override
  String get recurringAddTitle => 'Add Recurring';

  @override
  String get recurringEditTitle => 'Edit Recurring';

  @override
  String get recurringBasicInfo => 'Basic Info';

  @override
  String get recurringNameLabel => 'Name (e.g. Rent, Payroll)';

  @override
  String get recurringRequired => 'Required field';

  @override
  String get recurringStoreLabel => 'Client / Business Name (Optional)';

  @override
  String get recurringCycle => 'Repeat Cycle';

  @override
  String get recurringCycleMonthly => 'Monthly';

  @override
  String get recurringCycleWeekly => 'Weekly';

  @override
  String recurringDayOfMonth(String n) {
    return 'Day $n';
  }

  @override
  String get recurringMemoOptional => 'Memo (Optional)';

  @override
  String get recurringMemoHint => 'e.g. Store 1 rent, employee payroll';

  @override
  String get recurringUpdate => 'Update';

  @override
  String get recurringRegister => 'Register';

  @override
  String get recurringLoginRequired => 'Login required.';

  @override
  String get recurringAmountInvalid => 'Please enter a valid amount.';

  @override
  String get recurringAdded => 'Recurring transaction added.';

  @override
  String get recurringUpdated => 'Recurring transaction updated.';

  @override
  String get recurringSaveError => 'An error occurred while saving.';

  @override
  String get recurringListTitle => 'Recurring Transactions';

  @override
  String get recurringListEmpty => 'No recurring transactions yet.';

  @override
  String get recurringListEmptySub =>
      'Auto-register rent, payroll, subscriptions, etc.';

  @override
  String get recurringDeleteTitle => 'Delete recurring transaction?';

  @override
  String get recurringDeleteContent =>
      'This recurring transaction will be deleted.';

  @override
  String recurringMonthlyDay(String n) {
    return 'Every month on day $n';
  }

  @override
  String recurringWeeklyDay(String weekday) {
    return 'Every $weekday';
  }

  @override
  String get recurringMonthlyDaySelect => 'Which day of the month?';

  @override
  String get recurringWeekdaySelect => 'Select weekday';

  @override
  String get recurringCategoryOptional => 'Category (Optional)';

  @override
  String get recurringMethodOptional => 'Payment / Deposit Method (Optional)';

  @override
  String get recurringVatDeductibleToggle => 'Treat as VAT-deductible expense';

  @override
  String get recurringActiveToggle => 'Enable auto-generation';

  @override
  String get recurringActiveToggleSub =>
      'When off, entries will no longer be created automatically.';

  @override
  String get recurringSkipTitle => 'Skip this month only?';

  @override
  String get recurringSkipContent =>
      'This recurring transaction will not auto-generate an entry this month.';

  @override
  String get recurringSkip => 'Skip';

  @override
  String get recurringSkipDone => 'Set to skip this month.';

  @override
  String get recurringSkipButton => 'Skip this month only';

  @override
  String get recurringDeleteFailed => 'Failed to delete.';

  @override
  String get recurringAutoOff => 'Auto-generation off';

  @override
  String get homeDefaultName => 'Boss';

  @override
  String homeGreeting(String name) {
    return '$name';
  }

  @override
  String statisticsScorePoints(String score) {
    return '$score pts';
  }

  @override
  String get taxEventDefaultTitle => 'Tax Schedule';

  @override
  String get settingsInquirySubject => '[BizExpense] Inquiry';

  @override
  String get settingsInquiryBody =>
      '1. Inquiry type:\n2. Details:\n\n(Please write your message here)';

  @override
  String get profileEditSaved => 'Profile saved.';

  @override
  String profileEditSaveError(String error) {
    return 'An error occurred while saving: $error';
  }

  @override
  String get profileNameHint => 'Your real name';

  @override
  String get profileAgeHint => 'e.g. 35';

  @override
  String get profileNickname => 'Nickname';

  @override
  String get profileNicknameSection => 'Nickname';

  @override
  String get profileSaveButton => 'Save';

  @override
  String get signupTypeSoleProp => 'Sole Proprietorship';

  @override
  String get signupTypeSolePropSub =>
      'Individual owner · VAT tracking & expense management';

  @override
  String get signupTypeLlc => 'LLC / WLL';

  @override
  String get signupTypeLlcSub =>
      'Limited Liability Company · corporate accounting';

  @override
  String get signupTypeFreeZone => 'Free Zone Company';

  @override
  String get signupTypeFreeZoneSub =>
      'DMCC · DIFC · ADGM · NEOM and other free zones';

  @override
  String signupStepCounter(String current, String total) {
    return '$current / $total';
  }
}
