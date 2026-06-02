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
  String get navCommunity => 'المجتمع';

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
}
