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
  String get loginWithKakao => 'المتابعة عبر كاكاو';

  @override
  String get loginWithGoogle => 'المتابعة عبر Google';

  @override
  String get loginWithApple => 'المتابعة عبر Apple';

  @override
  String get loginOrDivider => 'أو';

  @override
  String get loginOAuthError => 'فشل تسجيل الدخول. حاول مرة أخرى.';

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

  @override
  String get recurringAddTitle => 'إضافة معاملة متكررة';

  @override
  String get recurringEditTitle => 'تعديل المعاملة المتكررة';

  @override
  String get recurringBasicInfo => 'المعلومات الأساسية';

  @override
  String get recurringNameLabel => 'الاسم (مثل: الإيجار، الرواتب)';

  @override
  String get recurringRequired => 'حقل مطلوب';

  @override
  String get recurringStoreLabel => 'العميل / اسم النشاط (اختياري)';

  @override
  String get recurringCycle => 'دورة التكرار';

  @override
  String get recurringCycleMonthly => 'شهرياً';

  @override
  String get recurringCycleWeekly => 'أسبوعياً';

  @override
  String recurringDayOfMonth(String n) {
    return 'اليوم $n';
  }

  @override
  String get recurringMemoOptional => 'ملاحظة (اختياري)';

  @override
  String get recurringMemoHint => 'مثل: إيجار الفرع الأول، راتب الموظف';

  @override
  String get recurringUpdate => 'تحديث';

  @override
  String get recurringRegister => 'تسجيل';

  @override
  String get recurringLoginRequired => 'تسجيل الدخول مطلوب.';

  @override
  String get recurringAmountInvalid => 'يرجى إدخال مبلغ صحيح.';

  @override
  String get recurringAdded => 'تمت إضافة المعاملة المتكررة.';

  @override
  String get recurringUpdated => 'تم تحديث المعاملة المتكررة.';

  @override
  String get recurringSaveError => 'حدث خطأ أثناء الحفظ.';

  @override
  String get recurringListTitle => 'المعاملات المتكررة';

  @override
  String get recurringListEmpty => 'لا توجد معاملات متكررة بعد.';

  @override
  String get recurringListEmptySub =>
      'سجّل الإيجار والرواتب والاشتراكات تلقائياً.';

  @override
  String get recurringDeleteTitle => 'حذف المعاملة المتكررة؟';

  @override
  String get recurringDeleteContent => 'سيتم حذف هذه المعاملة المتكررة.';

  @override
  String recurringMonthlyDay(String n) {
    return 'كل شهر في اليوم $n';
  }

  @override
  String recurringWeeklyDay(String weekday) {
    return 'كل $weekday';
  }

  @override
  String get recurringMonthlyDaySelect => 'أي يوم من الشهر؟';

  @override
  String get recurringWeekdaySelect => 'اختر اليوم';

  @override
  String get recurringCategoryOptional => 'الفئة (اختياري)';

  @override
  String get recurringMethodOptional => 'طريقة الدفع / الإيداع (اختياري)';

  @override
  String get recurringVatDeductibleToggle =>
      'اعتبارها مصروفاً قابلاً لخصم الضريبة';

  @override
  String get recurringActiveToggle => 'تفعيل الإنشاء التلقائي';

  @override
  String get recurringActiveToggleSub =>
      'عند الإيقاف، لن يتم إنشاء القيود تلقائياً بعد الآن.';

  @override
  String get recurringSkipTitle => 'تخطّي هذا الشهر فقط؟';

  @override
  String get recurringSkipContent =>
      'لن يتم إنشاء قيد تلقائي لهذه المعاملة المتكررة هذا الشهر.';

  @override
  String get recurringSkip => 'تخطّي';

  @override
  String get recurringSkipDone => 'تم ضبطه لتخطّي هذا الشهر.';

  @override
  String get recurringSkipButton => 'تخطّي هذا الشهر فقط';

  @override
  String get recurringDeleteFailed => 'فشل الحذف.';

  @override
  String get recurringAutoOff => 'الإنشاء التلقائي متوقف';

  @override
  String get homeDefaultName => 'المدير';

  @override
  String homeGreeting(String name) {
    return '$name';
  }

  @override
  String statisticsScorePoints(String score) {
    return '$score نقطة';
  }

  @override
  String get taxEventDefaultTitle => 'جدول الضرائب';

  @override
  String get settingsInquirySubject => '[BizExpense] استفسار';

  @override
  String get settingsInquiryBody =>
      '1. نوع الاستفسار:\n2. التفاصيل:\n\n(يرجى كتابة رسالتك هنا)';

  @override
  String get profileEditSaved => 'تم حفظ الملف الشخصي.';

  @override
  String profileEditSaveError(String error) {
    return 'حدث خطأ أثناء الحفظ: $error';
  }

  @override
  String get profileNameHint => 'اسمك الحقيقي';

  @override
  String get profileAgeHint => 'مثال: 35';

  @override
  String get profileNickname => 'الاسم المستعار';

  @override
  String get profileNicknameSection => 'الاسم المستعار';

  @override
  String get profileSaveButton => 'حفظ';

  @override
  String get signupTypeSoleProp => 'مؤسسة فردية';

  @override
  String get signupTypeSolePropSub =>
      'مالك فردي · تتبع ضريبة القيمة المضافة وإدارة المصروفات';

  @override
  String get signupTypeLlc => 'شركة ذ.م.م';

  @override
  String get signupTypeLlcSub => 'شركة ذات مسؤولية محدودة · محاسبة الشركات';

  @override
  String get signupTypeFreeZone => 'شركة منطقة حرة';

  @override
  String get signupTypeFreeZoneSub =>
      'DMCC · DIFC · ADGM · NEOM ومناطق حرة أخرى';

  @override
  String signupStepCounter(String current, String total) {
    return '$current / $total';
  }

  @override
  String get txDeposit => 'إيداع';

  @override
  String get txWithdrawal => 'سحب';

  @override
  String get cameraTitle => 'مسح الإيصال';

  @override
  String get cameraPrompt => 'التقط صورة لإيصالك';

  @override
  String get cameraCapture => 'الكاميرا';

  @override
  String get cameraAlbum => 'المعرض';

  @override
  String get cameraAnalyzing => 'جارٍ التحليل بالذكاء الاصطناعي...';

  @override
  String get cameraAnalyze => 'تحليل هذا الإيصال';

  @override
  String get cameraAnalyzeFailed =>
      'فشل التحليل. حاول مرة أخرى أو أدخل يدوياً.';

  @override
  String get myBizTitle => 'معلومات نشاطي';

  @override
  String myBizSaveFailed(String error) {
    return 'فشل الحفظ: $error';
  }

  @override
  String get myBizProfileSection => 'الملف الشخصي';

  @override
  String get myBizNicknameHint => 'مثال: أبو محمد';

  @override
  String get myBizInvoiceInfo => '🧾 معلومات الفاتورة / عرض السعر';

  @override
  String get myBizCompany => 'اسم الشركة';

  @override
  String get myBizCompanyHint => 'مثال: BizExpense';

  @override
  String get myBizCeo => 'المالك / الممثل';

  @override
  String get myBizCeoHint => 'مثال: أحمد محمد';

  @override
  String get myBizTaxNumber => 'الرقم الضريبي (TRN)';

  @override
  String get myBizTaxNumberHint => 'مثال: 100123456700003';

  @override
  String get myBizAddress => 'عنوان النشاط';

  @override
  String get myBizAddressHint => 'مثال: دبي، الإمارات';

  @override
  String get myBizActivity => 'النشاط التجاري';

  @override
  String get myBizActivityHint => 'مثال: خدمات / برمجيات';

  @override
  String get myBizWithdraw => 'حذف الحساب';

  @override
  String get myBizWithdrawConfirm =>
      'هل أنت متأكد أنك تريد حذف حسابك؟\nسيتم حذف جميع البيانات نهائياً ولا يمكن استرجاعها.';

  @override
  String get myBizWithdrawButton => 'حذف الحساب';

  @override
  String get myBizWithdrawDone => 'تم حذف حسابك.';

  @override
  String get myBizError => 'حدث خطأ.';

  @override
  String get invoiceMinItem => 'يجب إضافة بند واحد على الأقل.';

  @override
  String get invoiceClientRequired => 'يرجى إدخال اسم العميل.';

  @override
  String get invoiceItemNamesRequired => 'يرجى تعبئة جميع أسماء البنود.';

  @override
  String get invoicePdfFailed => 'فشل إنشاء ملف PDF.';

  @override
  String get invoiceTitle => 'أرسل عرض سعر في ثوانٍ';

  @override
  String get invoiceRecipient => 'المستلم (العميل)';

  @override
  String get invoiceClientHint => 'مثال: شركة ABC للتجارة';

  @override
  String get invoiceClientLabel => 'اسم العميل';

  @override
  String get invoiceItems => 'البنود';

  @override
  String get invoiceAddItem => 'إضافة بند';

  @override
  String invoiceItemName(String n) {
    return 'البند $n';
  }

  @override
  String get invoiceItemNameHint => 'مثال: أعمال تصميم';

  @override
  String get invoiceUnitPrice => 'سعر الوحدة';

  @override
  String get invoiceQty => 'الكمية';

  @override
  String get invoiceShareHint =>
      'استخدم نافذة المشاركة لإرسال أو طباعة عرض السعر.';

  @override
  String get invoiceGenerating => 'جارٍ الإنشاء...';

  @override
  String get invoiceShare => 'مشاركة PDF';

  @override
  String get taxCalEmptyTitle => 'لا توجد مواعيد قادمة.';

  @override
  String get taxCalEmptySub =>
      'أعدّ ملفك الضريبي وسنذكّرك بمواعيد تقديم ضريبة القيمة المضافة تلقائياً.';

  @override
  String get taxCalSetupButton => 'إعداد الجدول الضريبي';

  @override
  String get taxCalLoadError => 'تعذّر تحميل الجدول الضريبي';

  @override
  String get taxBadgeVat => 'ض.ق.م';

  @override
  String get taxBadgeIncome => 'ضريبة الدخل';

  @override
  String get taxBadgeCorporate => 'ضريبة الشركات';

  @override
  String get taxBadgeLocal => 'ضريبة محلية';

  @override
  String get taxBadgeCar => 'ضريبة المركبات';

  @override
  String get taxBadgeProperty => 'ضريبة العقار';

  @override
  String get taxBadgeWht => 'استقطاع';

  @override
  String get taxBadgeInsure => 'تأمين';

  @override
  String taxEventVat(String period) {
    return 'إقرار ضريبة القيمة المضافة — $period';
  }

  @override
  String taxEventVatPayment(String period) {
    return 'سداد ضريبة القيمة المضافة — $period';
  }

  @override
  String taxEventCorporate(String year) {
    return 'إقرار ضريبة الشركات $year';
  }

  @override
  String get meTaxSetupTitle => 'الإعداد الضريبي';

  @override
  String get meTaxSetupIntro =>
      'حدّد تفاصيل تقديم ضريبة القيمة المضافة وسننشئ مواعيدك.';

  @override
  String get meTaxVatRegistered => 'مسجّل في ضريبة القيمة المضافة';

  @override
  String get meTaxVatRegisteredSub => 'هل نشاطك مسجّل في ضريبة القيمة المضافة؟';

  @override
  String get meTaxFilingFrequency => 'دورة الإقرار';

  @override
  String get meTaxQuarterly => 'ربع سنوي';

  @override
  String get meTaxMonthly => 'شهري';

  @override
  String get meTaxCorporate => 'خاضع لضريبة الشركات';

  @override
  String get meTaxCorporateSub =>
      'الشركات (ذ.م.م / منطقة حرة) تقدّم إقرار ضريبة الشركات مرة سنوياً.';

  @override
  String get meTaxSaved => 'تم إنشاء الجدول الضريبي.';

  @override
  String meTaxQuarterLabel(String q, String year) {
    return 'الربع $q $year';
  }

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguagePickerTitle => 'اختر اللغة';

  @override
  String get settingsRegionFixedNote => 'تم تحديدها عند إنشاء حسابك';

  @override
  String get menuMyInvoices => 'فواتيري';

  @override
  String get menuMyInvoicesSub => 'عرض الفواتير الصادرة';

  @override
  String get invoiceListTitle => 'فواتيري';

  @override
  String get invoiceListEmpty => 'لا توجد فواتير صادرة بعد.';

  @override
  String get invoiceListEmptySub => 'ستظهر الفواتير التي تصدرها هنا.';

  @override
  String get invoiceStatusIssued => 'صادرة';

  @override
  String get invoiceStatusDraft => 'مسودة';

  @override
  String get invoiceStatusCancelled => 'ملغاة';

  @override
  String invoiceVatOf(String vat) {
    return 'شاملة الضريبة $vat';
  }

  @override
  String get signupConfirmEmail =>
      'تم إنشاء الحساب. يرجى تأكيد بريدك الإلكتروني ثم تسجيل الدخول.';
}
