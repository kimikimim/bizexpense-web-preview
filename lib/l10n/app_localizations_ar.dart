// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'BizExpense';

  @override
  String get appTagline => 'شريكك الضريبي الذكي';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navStatistics => 'الإحصائيات';

  @override
  String get navTax => 'الضرائب';

  @override
  String get navMenu => 'القائمة';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get loginSubtitle => 'يرجى تسجيل الدخول للمتابعة.';

  @override
  String get loginLoading => 'جارٍ تسجيل الدخول...';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get noAccount => 'ليس لديك حساب؟';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get loginError => 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get loginEmailRequired => 'يرجى إدخال البريد الإلكتروني وكلمة المرور.';

  @override
  String get loginGenericError => 'حدث خطأ. يرجى المحاولة مرة أخرى.';

  @override
  String get signupStep1Title => 'إنشاء حساب';

  @override
  String get signupStep1Sub => 'أدخل بريدك الإلكتروني وكلمة المرور.';

  @override
  String get signupStep2Title => 'إعداد الملف الشخصي';

  @override
  String get signupStep2Sub => 'أدخل معلوماتك الأساسية واسم المستخدم.';

  @override
  String get signupStep3Title => 'نوع العمل';

  @override
  String get signupStep3Sub => 'كيف ستستخدم التطبيق؟';

  @override
  String get signupBannerStep1 => 'ابدأ بأمان';

  @override
  String get signupBannerStep2 => 'عرّف بنفسك';

  @override
  String get emailAddress => 'عنوان البريد الإلكتروني';

  @override
  String get passwordHint => 'كلمة المرور (8+ أحرف، حروف، أرقام، رموز)';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get age => 'العمر (اختياري)';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get bio => 'نبذة (اختياري)';

  @override
  String get bioHint => 'مثال: صاحب مقهى منذ 3 سنوات.';

  @override
  String get basicInfo => 'المعلومات الأساسية';

  @override
  String get communityInfo => 'معلومات المجتمع';

  @override
  String get communityInfoNote =>
      'يظهر اسم المستخدم فقط في المنشورات والتعليقات.';

  @override
  String get next => 'التالي';

  @override
  String get complete => 'إتمام';

  @override
  String get businessIndividual => 'مالك فردي';

  @override
  String get businessIndividualSub =>
      'تتبع المصروفات وضريبة القيمة المضافة وضريبة الدخل';

  @override
  String get businessCorporate => 'شركة';

  @override
  String get businessCorporateSub => 'مصروفات الشركة والمحاسبة';

  @override
  String get personal => 'شخصي';

  @override
  String get personalSub => 'إدارة الميزانية الشخصية';

  @override
  String get mostPopular => 'الأكثر شيوعاً';

  @override
  String get signupChooseType => 'اختر نوع عملك\nوسنُهيئ التطبيق لك.';

  @override
  String get validEmailRequired => 'يرجى إدخال عنوان بريد إلكتروني صحيح.';

  @override
  String get passwordTooShort =>
      'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل.';

  @override
  String get passwordNeedsLetter => 'يجب أن تحتوي كلمة المرور على حرف.';

  @override
  String get passwordNeedsNumber => 'يجب أن تحتوي كلمة المرور على رقم.';

  @override
  String get passwordNeedsSpecial => 'يجب أن تحتوي كلمة المرور على رمز خاص.';

  @override
  String get passwordMismatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get nameRequired => 'يرجى إدخال اسمك.';

  @override
  String get usernameTooShort =>
      'يجب أن يتكون اسم المستخدم من حرفين على الأقل.';

  @override
  String get signupFailed => 'فشل إنشاء الحساب. يرجى المحاولة مرة أخرى.';

  @override
  String get emailAlreadyRegistered => 'هذا البريد الإلكتروني مسجل بالفعل.';

  @override
  String get invalidEmail => 'صيغة البريد الإلكتروني غير صحيحة.';

  @override
  String get weakPassword =>
      'يجب أن تحتوي كلمة المرور على 8+ أحرف وأرقام ورموز.';

  @override
  String heroNetProfit(String month) {
    return 'توقع صافي الربح - $month';
  }

  @override
  String get heroProfit => '▲ ربح متوقع';

  @override
  String get heroLoss => '▼ خسارة متوقعة';

  @override
  String get heroExpectedIncome => 'الدخل المتوقع';

  @override
  String get heroExpectedExpense => 'المصروف المتوقع';

  @override
  String heroGreeting(String name) {
    return '$name';
  }

  @override
  String get actionAddIncome => 'إضافة دخل';

  @override
  String get actionAddExpense => 'إضافة مصروف';

  @override
  String get actionScanReceipt => 'مسح الإيصال';

  @override
  String get actionTaxReport => 'تقرير ضريبي';

  @override
  String get recentTransactions => 'المعاملات الأخيرة';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get countrySelectTitle => 'اختر دولتك';

  @override
  String get countrySelectSubtitle => 'سيتم ضبط الإعدادات الضريبية تلقائياً.';

  @override
  String get countryDetected => 'تم الكشف';

  @override
  String get countrySelectContinue => 'متابعة';

  @override
  String get countryVat => 'ضريبة القيمة المضافة';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsCountryRegion => 'الدولة / المنطقة';

  @override
  String get settingsCountryPickerTitle => 'اختر الدولة / المنطقة';

  @override
  String get settingsDarkMode => 'الوضع الداكن';

  @override
  String get settingsFontSize => 'حجم الخط';

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get settingsExport => 'تصدير البيانات';

  @override
  String get settingsLogout => 'تسجيل الخروج';

  @override
  String get settingsVersion => 'الإصدار';

  @override
  String get settingsSmall => 'صغير';

  @override
  String get settingsMedium => 'متوسط';

  @override
  String get settingsLarge => 'كبير';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get confirm => 'تأكيد';

  @override
  String get error => 'خطأ';

  @override
  String get success => 'نجاح';

  @override
  String get searchHint => 'ابحث بالاسم أو الملاحظة أو المبلغ...';

  @override
  String get noResults => 'لا توجد نتائج.';

  @override
  String get income => 'دخل';

  @override
  String get expense => 'مصروف';

  @override
  String get balance => 'الرصيد';

  @override
  String get category => 'الفئة';

  @override
  String get memo => 'ملاحظة';

  @override
  String get date => 'التاريخ';

  @override
  String get amount => 'المبلغ';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get menuAll => 'الكل';

  @override
  String get menuBusinessManagement => 'إدارة الأعمال';

  @override
  String get menuStatisticsAnalysis => 'الإحصائيات والتحليل';

  @override
  String get menuStatisticsAnalysisSub =>
      'اتجاهات الإيرادات والمصروفات، تحليل حسب الفئة';

  @override
  String get menuProfileSettings => 'إعدادات الملف الشخصي';

  @override
  String get menuProfileSettingsSub => 'إدارة الاسم والعمر واسم المستخدم';

  @override
  String get menuTaxReport => 'تقرير ضريبي';

  @override
  String get menuTaxReportSub =>
      'تقارير ضريبة القيمة المضافة وضريبة الدخل الفصلية';

  @override
  String get menuTaxSchedule => 'جدول الضرائب';

  @override
  String get menuTaxScheduleSub => 'إدارة مواعيد تقديم الضرائب';

  @override
  String get menuRecurring => 'إدارة المعاملات المتكررة';

  @override
  String get menuRecurringSub =>
      'ضبط التسجيل التلقائي للإيجار والاشتراكات والرواتب';

  @override
  String get menuInvoice => 'إصدار فاتورة';

  @override
  String get menuInvoiceSub => 'إنشاء فواتير لإرسالها للعملاء';

  @override
  String get menuDataManagement => 'إدارة البيانات';

  @override
  String get menuExportExcel => 'تصدير إلى Excel';

  @override
  String get menuExportExcelSub => 'إنشاء ملف Excel بجميع الإيرادات والمصروفات';

  @override
  String get menuTaxExcel => 'Excel للتسوية الضريبية';

  @override
  String get menuTaxExcelSub => 'حفظ بتنسيق التقديم الإلكتروني';

  @override
  String get menuPreferences => 'التفضيلات';

  @override
  String get menuDarkMode => 'الوضع الداكن';

  @override
  String get menuSettings => 'الإعدادات';

  @override
  String get menuSettingsSub => 'حجم الخط ومعلومات العمل والنسخ الاحتياطي';

  @override
  String get menuLogout => 'تسجيل الخروج';

  @override
  String get menuLogoutSub => 'تسجيل الخروج من هذا الجهاز فقط';

  @override
  String get menuFrequentlyUsed => 'الوصول السريع';

  @override
  String get menuStatisticsShort => 'إحصاء';

  @override
  String get menuTaxReportShort => 'تقرير\nضريبي';

  @override
  String get menuTaxScheduleShort => 'جدول\nضريبي';

  @override
  String get menuSettingsShort => 'إعدادات';

  @override
  String get menuManagingBusiness => 'إدارة الأعمال';

  @override
  String get logoutDialogTitle => 'تسجيل الخروج';

  @override
  String get logoutDialogContent => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get logoutConfirm => 'تسجيل الخروج';

  @override
  String get noDataToExport => 'لا توجد بيانات للتصدير.';

  @override
  String get exportExcelSuccess => 'تم إنشاء ملف Excel للتسوية الضريبية.';

  @override
  String get exportExcelBasicSuccess => 'تم إنشاء ملف Excel.';

  @override
  String get exportExcelError => 'حدث خطأ أثناء التصدير.';

  @override
  String get settingsDisplaySettings => 'إعدادات العرض';

  @override
  String get settingsFontSizeLabel => 'حجم الخط';

  @override
  String get settingsFontSizeVerySmall => 'صغير جداً';

  @override
  String get settingsFontSizeSmall => 'صغير';

  @override
  String get settingsFontSizeNormal => 'عادي';

  @override
  String get settingsFontSizeLarge => 'كبير';

  @override
  String get settingsFontSizeVeryLarge => 'كبير جداً';

  @override
  String get settingsBusinessManagement => 'إدارة الأعمال';

  @override
  String get settingsMyBusinessInfo => 'معلومات عملي';

  @override
  String get settingsMyBusinessInfoSub =>
      'الاسم التجاري، رقم التسجيل، العنوان، إلخ.';

  @override
  String get settingsTaxScheduleSetup => 'إعداد جدول الضرائب';

  @override
  String get settingsTaxScheduleSetupSub => 'تغيير نوع العمل ونوع الضريبة';

  @override
  String get settingsDataBackup => 'نسخ احتياطي للبيانات';

  @override
  String get settingsDataBackupSub => 'نسخ احتياطي تلقائي إلى السحابة';

  @override
  String get settingsBackupFileDownload => 'تنزيل ملف النسخ الاحتياطي';

  @override
  String get settingsBackupFileDownloadSub => 'حفظ ملف النسخ الاحتياطي محلياً';

  @override
  String get settingsDataRestore => 'استعادة البيانات';

  @override
  String get settingsDataRestoreSub =>
      'استعادة البيانات من ملف النسخ الاحتياطي';

  @override
  String get settingsTaxSettlementExcel => 'Excel للتسوية الضريبية';

  @override
  String get settingsTaxSettlementExcelSub =>
      'إنشاء ملف بتنسيق التقديم الإلكتروني';

  @override
  String get settingsSupport => 'خدمة العملاء';

  @override
  String get settingsKakaoInquiry => 'استفسار KakaoTalk 1:1';

  @override
  String get settingsKakaoInquirySub => 'احصل على أسرع رد';

  @override
  String get settingsEmailInquiry => 'استفسار عبر البريد الإلكتروني';

  @override
  String get settingsTermsAndPolicy => 'الشروط والسياسات';

  @override
  String get settingsTermsOfService => 'شروط الخدمة';

  @override
  String get settingsPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get settingsOpenSourceLicense => 'تراخيص المصدر المفتوح';

  @override
  String get settingsAppVersion => 'إصدار التطبيق';

  @override
  String get settingsCountryPickerTitleAlt => 'الدولة / المنطقة';

  @override
  String get settingsLinkError => 'تعذر فتح الرابط.';

  @override
  String get settingsMailError => 'تعذر العثور على تطبيق البريد الافتراضي.';

  @override
  String get settingsBackupSuccess => 'اكتمل النسخ الاحتياطي!';

  @override
  String get settingsBackupFailed => 'فشل النسخ الاحتياطي.';

  @override
  String get settingsBackupShared => 'تمت مشاركة ملف النسخ الاحتياطي.';

  @override
  String get settingsBackupShareFailed => 'فشل إنشاء ملف النسخ الاحتياطي.';

  @override
  String get settingsRestoreDialogTitle => 'استعادة البيانات';

  @override
  String get settingsRestoreDialogContent =>
      'سيتم حذف البيانات الحالية واستبدالها ببيانات النسخ الاحتياطي. هل تريد المتابعة؟';

  @override
  String get settingsRestoreConfirm => 'استعادة';

  @override
  String get settingsRestoreSuccess => 'اكتملت الاستعادة!';

  @override
  String get settingsRestoreFailed => 'فشلت الاستعادة.';

  @override
  String settingsFileReadFailed(String error) {
    return 'فشل قراءة الملف: $error';
  }

  @override
  String get settingsFileNotReadable => 'تعذر قراءة الملف.';

  @override
  String get settingsFilePathNotFound => 'مسار الملف غير موجود.';

  @override
  String get userTypeSelectPrompt => 'يرجى اختيار غرض الاستخدام.';

  @override
  String get userTypePersonal => 'شخصي';

  @override
  String get userTypePersonalSub => 'نفقات المعيشة، إدارة المصروف';

  @override
  String get userTypeBusiness => 'أعمال';

  @override
  String get userTypeBusinessSub => 'إدارة النفقات، إدارة الضرائب';

  @override
  String get userTypeIndividual => 'مالك فردي';

  @override
  String get userTypeCorporate => 'شركة';

  @override
  String get userTypeSaveError => 'حدث خطأ أثناء حفظ الإعدادات.';

  @override
  String get addTransactionNew => 'إدخال جديد';

  @override
  String get addTransactionEdit => 'تعديل الإدخال';

  @override
  String get addTransactionType => 'نوع المعاملة';

  @override
  String get addTransactionInfo => 'معلومات المعاملة';

  @override
  String get addTransactionExpense => 'مصروف';

  @override
  String get addTransactionIncome => 'دخل';

  @override
  String get addTransactionStoreName => 'اسم المنشأة';

  @override
  String get addTransactionStoreNameRequired => 'حقل مطلوب';

  @override
  String get addTransactionAmountLabel => 'المبلغ';

  @override
  String get addTransactionAmountUnit => 'ر.س';

  @override
  String get addTransactionAmountRequired => 'حقل مطلوب';

  @override
  String get addTransactionPaymentMethod => 'طريقة الدفع';

  @override
  String get addTransactionDepositMethod => 'طريقة الإيداع';

  @override
  String get addTransactionInstallment => 'أشهر التقسيط';

  @override
  String get addTransactionInstallmentOnce => 'دفعة كاملة';

  @override
  String get addTransactionInstallmentCustom => 'أدخل مباشرة';

  @override
  String addTransactionInstallmentMonths(String n) {
    return '$n أشهر';
  }

  @override
  String get addTransactionCashReceiptBusiness => 'إثبات مصروف أعمال';

  @override
  String get addTransactionCashReceiptPersonal => 'خصم الدخل';

  @override
  String get addTransactionApprovalNumber => 'رقم الموافقة (اختياري)';

  @override
  String get addTransactionCategoryLabel => 'الفئة';

  @override
  String get addTransactionCategoryDirectInput => 'أدخل مباشرة';

  @override
  String get addTransactionTaxSettings => 'الإعدادات الضريبية';

  @override
  String get addTransactionVatDeductible => 'قابل لخصم ضريبة القيمة المضافة';

  @override
  String get addTransactionBusinessExpense => 'هذا المصروف متعلق بالأعمال';

  @override
  String get addTransactionBusinessExpenseOnSub =>
      'مدرج في حساب استرداد ضريبة القيمة المضافة كمصروف أعمال';

  @override
  String get addTransactionBusinessExpenseOffSub =>
      'محدد كمصروف شخصي/غير قابل للخصم';

  @override
  String get addTransactionMemoLabel => 'ملاحظة';

  @override
  String get addTransactionMemoHint => 'أدخل التفاصيل';

  @override
  String get addTransactionMemoHintEntertainment => 'أدخل الحاضرين والغرض';

  @override
  String get addTransactionSaving => 'جارٍ الحفظ...';

  @override
  String get addTransactionSave => 'حفظ';

  @override
  String get addTransactionSaved => 'تم الحفظ!';

  @override
  String get addTransactionDeleted => 'تم الحذف.';

  @override
  String get addTransactionLoginRequired =>
      'تسجيل الدخول مطلوب. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get addTransactionImageUploadFailed => 'فشل رفع الصورة';

  @override
  String get addTransactionReceiptPrompt => 'يرجى إرفاق صورة الإيصال';

  @override
  String get addTransactionReceiptRequired => 'الإيصال مطلوب';

  @override
  String get addTransactionReceiptRequiredContent =>
      'بناءً على طريقة الدفع والمبلغ،\nتتطلب هذه المعاملة الاحتفاظ بإيصال وفقاً للقانون الضريبي.\n\nهل تريد الحفظ بدون إيصال؟';

  @override
  String get addTransactionReceiptAttach => 'إرفاق إيصال';

  @override
  String get addTransactionSaveAnyway => 'حفظ على أي حال';

  @override
  String get addTransactionCorporateReceiptWarning => 'إشعار بفقدان الإثبات';

  @override
  String get addTransactionCorporateReceiptContent =>
      'نفقات الشركة تتطلب عادةً إيصالات.\nهل تريد الحفظ بدون صورة؟';

  @override
  String get addTransactionDeleteConfirmTitle => 'حذف هذا الإدخال؟';

  @override
  String get addTransactionDeleteConfirmContent =>
      'سيتم حذف هذا الإدخال نهائياً.';

  @override
  String get addTransactionReceiptTake => 'التقاط صورة';

  @override
  String get addTransactionReceiptFromGallery => 'اختر من المعرض';

  @override
  String get addTransactionUncategorized => 'غير مصنف';

  @override
  String get allTransactionsTitle => 'جميع المعاملات';

  @override
  String get allTransactionsSearchHint =>
      'ابحث بالاسم أو الملاحظة أو الفئة أو المبلغ';

  @override
  String get allTransactionsFilter => 'تصفية';

  @override
  String get allTransactionsFilterTitle => 'تصفية';

  @override
  String get allTransactionsFilterReset => 'إعادة تعيين';

  @override
  String get allTransactionsFilterApply => 'تطبيق التصفية';

  @override
  String get allTransactionsNoResults => 'لا توجد إدخالات.';

  @override
  String get allTransactionsPeriod => 'الفترة';

  @override
  String get allTransactionsPeriodAll => 'الكل';

  @override
  String get allTransactionsPeriodThisMonth => 'هذا الشهر';

  @override
  String get allTransactionsPeriodLastMonth => 'الشهر الماضي';

  @override
  String get allTransactionsPeriodThreeMonths => '3 أشهر';

  @override
  String get allTransactionsPeriodCustom => 'تخصيص';

  @override
  String get allTransactionsTypeAll => 'الكل';

  @override
  String get allTransactionsTypeIncome => 'دخل';

  @override
  String get allTransactionsTypeExpense => 'مصروف';

  @override
  String get allTransactionsFilterPaymentMethod => 'طريقة الدفع';

  @override
  String get allTransactionsFilterCategory => 'الفئة';

  @override
  String get allTransactionsFilterTaxOptions => 'خيارات الضريبة';

  @override
  String get allTransactionsFilterNoReceipt => 'بدون إيصال فقط';

  @override
  String get allTransactionsFilterTaxDeductible =>
      'قابل لخصم ضريبة القيمة المضافة فقط';

  @override
  String get allTransactionsFilterSort => 'ترتيب';

  @override
  String get allTransactionsSortLatest => 'الأحدث';

  @override
  String get allTransactionsSortOldest => 'الأقدم';

  @override
  String get allTransactionsSortAmountDesc => 'أعلى مبلغ';

  @override
  String get allTransactionsSortAmountAsc => 'أدنى مبلغ';

  @override
  String get allTransactionsUncategorized => 'غير مصنف';

  @override
  String get statisticsTitle => 'الإحصائيات / التقرير الضريبي';

  @override
  String get statisticsTaxReportTab => 'التقرير الضريبي';

  @override
  String get statisticsExpenseTab => 'إحصائيات المصروفات';

  @override
  String get statisticsThisMonthTaxScore => 'نقاط الضريبة لهذا الشهر';

  @override
  String get statisticsDeductibleRatio => 'نسبة المصروفات القابلة للخصم';

  @override
  String get statisticsReceiptCoverage => 'تغطية الإيصالات';

  @override
  String get statisticsBigNoReceipt => '100K+ إيصالات مفقودة';

  @override
  String get statisticsDeductibleSection =>
      'المصروفات القابلة للخصم / غير القابلة';

  @override
  String get statisticsDeductible => 'قابل للخصم';

  @override
  String get statisticsNonDeductible => 'غير قابل للخصم / شخصي';

  @override
  String statisticsDeductiblePercent(String percent) {
    return 'حوالي $percent% من مصروفات هذا الشهر قابلة للخصم الضريبي.';
  }

  @override
  String get statisticsTopRiskCategories => 'أعلى 3 فئات عالية المخاطر';

  @override
  String get statisticsReceiptSection => 'تغطية الإيصالات';

  @override
  String get statisticsNoExpenseThisMonth => 'لا توجد مصروفات مسجلة هذا الشهر.';

  @override
  String statisticsTotalExpense(String amount) {
    return 'إجمالي المصروفات $amount';
  }

  @override
  String get statisticsTaxSafe => 'آمن';

  @override
  String get statisticsTaxNormal => 'عادي';

  @override
  String get statisticsTaxWarning => 'تحذير';

  @override
  String get statisticsTaxSafeComment => 'المخاطر الضريبية الإجمالية منخفضة.';

  @override
  String get statisticsTaxNormalComment =>
      'إدارة بعض نقاط المخاطرة لتحسين النتائج.';

  @override
  String get statisticsTaxWarningComment =>
      'تحقق من المصروفات غير القابلة للخصم والإيصالات المفقودة.';

  @override
  String get taxReportTitle => 'تقرير ضريبي';

  @override
  String get taxReportVatRefundEstimate =>
      'تقدير استرداد ضريبة القيمة المضافة هذا الربع';

  @override
  String get taxReportVatPaymentEstimate =>
      'تقدير دفع ضريبة القيمة المضافة هذا الربع';

  @override
  String get taxReportEstimateNote =>
      'تقدير بناءً على الإيرادات والمصروفات المدخلة في التطبيق';

  @override
  String get taxReportMonthlyExpenseBreakdown => 'تفاصيل مصروفات هذا الشهر';

  @override
  String get taxReportDeductibleExpense => 'المصروفات القابلة للخصم';

  @override
  String get taxReportNonDeductibleExpense =>
      'المصروفات الشخصية / غير القابلة للخصم';

  @override
  String get taxReportReceiptStatus => 'حالة الإيصالات';

  @override
  String get taxReportAllReceiptsRegistered => 'جميع الإيصالات المطلوبة مسجلة';

  @override
  String taxReportMissingReceipts(String count) {
    return 'من بين المصروفات التي تتطلب إيصالات،\nلم يتم تسجيل $count بعد';
  }

  @override
  String taxReportMissingAmount(String amount) {
    return 'المبلغ المفقود: $amount';
  }

  @override
  String taxReportNonDeductibleRatio(String ratio) {
    return 'نسبة غير القابل للخصم: $ratio%';
  }

  @override
  String get taxReportNoDataYet =>
      'لا توجد بيانات مصروفات كافية هذا الشهر بعد.';

  @override
  String get taxReportNonDeductibleLow =>
      'نسبة غير القابل للخصم منخفضة — مستقرة نسبياً.';

  @override
  String get taxReportNonDeductibleMedium =>
      'نسبة غير القابل للخصم مرتفعة قليلاً. فكر في فصل النفقات الشخصية.';

  @override
  String get taxReportNonDeductibleHigh =>
      'نسبة غير القابل للخصم مرتفعة جداً. قد تحتاج إلى استشارة ضريبية.';
}
