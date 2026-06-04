// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'BizExpense';

  @override
  String get appTagline => '당신의 똑똑한 세금 파트너';

  @override
  String get navHome => '홈';

  @override
  String get navStatistics => '통계';

  @override
  String get navTax => '세금';

  @override
  String get navMenu => '메뉴';

  @override
  String get login => '로그인';

  @override
  String get loginSubtitle => '계속하려면 로그인해 주세요.';

  @override
  String get loginLoading => '로그인 중...';

  @override
  String get email => '이메일';

  @override
  String get password => '비밀번호';

  @override
  String get noAccount => '계정이 없으신가요?';

  @override
  String get signUp => '회원가입';

  @override
  String get loginError => '이메일 또는 비밀번호가 올바르지 않습니다.';

  @override
  String get loginEmailRequired => '이메일과 비밀번호를 입력해 주세요.';

  @override
  String get loginWithKakao => '카카오로 시작하기';

  @override
  String get loginWithGoogle => 'Google로 시작하기';

  @override
  String get loginWithApple => 'Apple로 시작하기';

  @override
  String get loginOrDivider => '또는';

  @override
  String get loginOAuthError => '로그인에 실패했습니다. 다시 시도해 주세요.';

  @override
  String get loginGenericError => '오류가 발생했습니다. 다시 시도해 주세요.';

  @override
  String get signupStep1Title => '계정 만들기';

  @override
  String get signupStep1Sub => '이메일과 비밀번호를 입력하세요.';

  @override
  String get signupStep2Title => '프로필 설정';

  @override
  String get signupStep2Sub => '기본 정보와 사용자 이름을 설정하세요.';

  @override
  String get signupStep3Title => '사업자 유형';

  @override
  String get signupStep3Sub => '앱을 어떻게 사용하시나요?';

  @override
  String get signupBannerStep1 => '안전하게 시작';

  @override
  String get signupBannerStep2 => '나를 소개하기';

  @override
  String get emailAddress => '이메일 주소';

  @override
  String get passwordHint => '비밀번호 (8자 이상, 영문·숫자·특수문자)';

  @override
  String get confirmPassword => '비밀번호 확인';

  @override
  String get fullName => '이름';

  @override
  String get age => '나이 (선택)';

  @override
  String get username => '사용자 이름';

  @override
  String get bio => '소개 (선택)';

  @override
  String get bioHint => '예: 3년 차 카페 사장입니다.';

  @override
  String get basicInfo => '기본 정보';

  @override
  String get communityInfo => '커뮤니티 정보';

  @override
  String get communityInfoNote => '게시글과 댓글에는 사용자 이름만 표시됩니다.';

  @override
  String get next => '다음';

  @override
  String get complete => '완료';

  @override
  String get businessIndividual => '개인사업자';

  @override
  String get businessIndividualSub => '지출 관리, 부가세·종합소득세';

  @override
  String get businessCorporate => '법인사업자';

  @override
  String get businessCorporateSub => '법인 지출·회계 관리';

  @override
  String get personal => '개인용';

  @override
  String get personalSub => '개인 가계부 관리';

  @override
  String get mostPopular => '가장 많이 선택';

  @override
  String get signupChooseType => '사업자 유형을 선택하시면\n앱을 최적화해 드립니다.';

  @override
  String get validEmailRequired => '올바른 이메일 주소를 입력해 주세요.';

  @override
  String get passwordTooShort => '비밀번호는 8자 이상이어야 합니다.';

  @override
  String get passwordNeedsLetter => '비밀번호에 영문을 포함해야 합니다.';

  @override
  String get passwordNeedsNumber => '비밀번호에 숫자를 포함해야 합니다.';

  @override
  String get passwordNeedsSpecial => '비밀번호에 특수문자를 포함해야 합니다.';

  @override
  String get passwordMismatch => '비밀번호가 일치하지 않습니다.';

  @override
  String get nameRequired => '이름을 입력해 주세요.';

  @override
  String get usernameTooShort => '사용자 이름은 2자 이상이어야 합니다.';

  @override
  String get signupFailed => '회원가입에 실패했습니다. 다시 시도해 주세요.';

  @override
  String get emailAlreadyRegistered => '이미 가입된 이메일입니다.';

  @override
  String get invalidEmail => '이메일 형식이 올바르지 않습니다.';

  @override
  String get weakPassword => '비밀번호는 영문·숫자·특수문자 포함 8자 이상이어야 합니다.';

  @override
  String heroNetProfit(String month) {
    return '$month 예상 순이익';
  }

  @override
  String get heroProfit => '▲ 흑자 예상';

  @override
  String get heroLoss => '▼ 적자 예상';

  @override
  String get heroExpectedIncome => '예상 수입';

  @override
  String get heroExpectedExpense => '예상 지출';

  @override
  String heroGreeting(String name) {
    return '$name';
  }

  @override
  String get actionAddIncome => '수입 입력';

  @override
  String get actionAddExpense => '지출 입력';

  @override
  String get actionScanReceipt => '영수증 스캔';

  @override
  String get actionTaxReport => '세금 리포트';

  @override
  String get recentTransactions => '최근 거래 내역';

  @override
  String get viewAll => '전체 보기';

  @override
  String get countrySelectTitle => '국가를 선택하세요';

  @override
  String get countrySelectSubtitle => '세금 설정이 자동으로 구성됩니다.';

  @override
  String get countryDetected => '감지됨';

  @override
  String get countrySelectContinue => '계속';

  @override
  String get countryVat => '부가세';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsCountryRegion => '국가 / 지역';

  @override
  String get settingsCountryPickerTitle => '국가 / 지역 선택';

  @override
  String get settingsDarkMode => '다크 모드';

  @override
  String get settingsFontSize => '글자 크기';

  @override
  String get settingsNotifications => '알림';

  @override
  String get settingsExport => '데이터 내보내기';

  @override
  String get settingsLogout => '로그아웃';

  @override
  String get settingsVersion => '버전';

  @override
  String get settingsSmall => '작게';

  @override
  String get settingsMedium => '보통';

  @override
  String get settingsLarge => '크게';

  @override
  String get loading => '불러오는 중...';

  @override
  String get retry => '다시 시도';

  @override
  String get cancel => '취소';

  @override
  String get save => '저장';

  @override
  String get delete => '삭제';

  @override
  String get confirm => '확인';

  @override
  String get error => '오류';

  @override
  String get success => '완료';

  @override
  String get searchHint => '상호, 메모, 금액으로 검색...';

  @override
  String get noResults => '검색 결과가 없습니다.';

  @override
  String get income => '수입';

  @override
  String get expense => '지출';

  @override
  String get balance => '잔액';

  @override
  String get category => '분류';

  @override
  String get memo => '메모';

  @override
  String get date => '날짜';

  @override
  String get amount => '금액';

  @override
  String get paymentMethod => '결제 수단';

  @override
  String get menuAll => '전체';

  @override
  String get menuBusinessManagement => '사업 관리';

  @override
  String get menuStatisticsAnalysis => '통계 & 분석';

  @override
  String get menuStatisticsAnalysisSub => '수입·지출 추이, 카테고리 분석';

  @override
  String get menuProfileSettings => '프로필 설정';

  @override
  String get menuProfileSettingsSub => '이름, 나이, 닉네임 관리';

  @override
  String get menuTaxReport => '세금 리포트';

  @override
  String get menuTaxReportSub => '분기별 부가세·종합소득세 리포트';

  @override
  String get menuTaxSchedule => '세금 일정';

  @override
  String get menuTaxScheduleSub => '부가세 / 종합소득세 신고 기한 관리';

  @override
  String get menuRecurring => '반복 거래';

  @override
  String get menuRecurringSub => '임대료, 구독료, 급여 등 자동 등록';

  @override
  String get menuInvoice => '거래명세서 발행';

  @override
  String get menuInvoiceSub => '거래처에 보낼 명세서 작성';

  @override
  String get menuDataManagement => '데이터 관리';

  @override
  String get menuExportExcel => '엑셀로 내보내기';

  @override
  String get menuExportExcelSub => '모든 수입·지출 엑셀 파일 생성';

  @override
  String get menuTaxExcel => '세금 정산 엑셀';

  @override
  String get menuTaxExcelSub => '홈택스 전자신고 형식으로 저장';

  @override
  String get menuPreferences => '환경 설정';

  @override
  String get menuDarkMode => '다크 모드';

  @override
  String get menuSettings => '설정';

  @override
  String get menuSettingsSub => '글자 크기, 사업자 정보, 데이터 백업';

  @override
  String get menuLogout => '로그아웃';

  @override
  String get menuLogoutSub => '이 기기에서만 로그아웃';

  @override
  String get menuFrequentlyUsed => '자주 쓰는 기능';

  @override
  String get menuStatisticsShort => '통계';

  @override
  String get menuTaxReportShort => '세금\n리포트';

  @override
  String get menuTaxScheduleShort => '세금\n일정';

  @override
  String get menuSettingsShort => '설정';

  @override
  String get menuManagingBusiness => '사업 관리 중';

  @override
  String get logoutDialogTitle => '로그아웃';

  @override
  String get logoutDialogContent => '정말 로그아웃하시겠어요?';

  @override
  String get logoutConfirm => '로그아웃';

  @override
  String get noDataToExport => '내보낼 데이터가 없습니다.';

  @override
  String get exportExcelSuccess => '세금 정산 엑셀 파일이 생성되었습니다.';

  @override
  String get exportExcelBasicSuccess => '엑셀 파일이 생성되었습니다.';

  @override
  String get exportExcelError => '내보내기 중 오류가 발생했습니다.';

  @override
  String get settingsDisplaySettings => '화면 설정';

  @override
  String get settingsFontSizeLabel => '글자 크기';

  @override
  String get settingsFontSizeVerySmall => '아주 작게';

  @override
  String get settingsFontSizeSmall => '작게';

  @override
  String get settingsFontSizeNormal => '보통';

  @override
  String get settingsFontSizeLarge => '크게';

  @override
  String get settingsFontSizeVeryLarge => '아주 크게';

  @override
  String get settingsBusinessManagement => '사업 관리';

  @override
  String get settingsMyBusinessInfo => '내 사업자 정보';

  @override
  String get settingsMyBusinessInfoSub => '상호, 사업자등록번호, 주소 등';

  @override
  String get settingsTaxScheduleSetup => '세금 일정 설정';

  @override
  String get settingsTaxScheduleSetupSub => '사업자 유형, 과세 유형 변경';

  @override
  String get settingsDataBackup => '데이터 백업';

  @override
  String get settingsDataBackupSub => '클라우드 자동 백업';

  @override
  String get settingsBackupFileDownload => '백업 파일 다운로드';

  @override
  String get settingsBackupFileDownloadSub => '백업 파일을 기기에 저장';

  @override
  String get settingsDataRestore => '데이터 복원';

  @override
  String get settingsDataRestoreSub => '백업 파일에서 데이터 복원';

  @override
  String get settingsTaxSettlementExcel => '세금 정산 엑셀';

  @override
  String get settingsTaxSettlementExcelSub => '홈택스 전자신고 형식 파일 생성';

  @override
  String get settingsSupport => '고객 지원';

  @override
  String get settingsKakaoInquiry => '카카오톡 1:1 문의';

  @override
  String get settingsKakaoInquirySub => '가장 빠르게 답변받기';

  @override
  String get settingsEmailInquiry => '이메일 문의';

  @override
  String get settingsTermsAndPolicy => '약관 & 정책';

  @override
  String get settingsTermsOfService => '이용약관';

  @override
  String get settingsPrivacyPolicy => '개인정보 처리방침';

  @override
  String get settingsOpenSourceLicense => '오픈소스 라이선스';

  @override
  String get settingsAppVersion => '앱 버전';

  @override
  String get settingsCountryPickerTitleAlt => '국가 / 지역';

  @override
  String get settingsLinkError => '링크를 열 수 없습니다.';

  @override
  String get settingsMailError => '기본 메일 앱을 찾을 수 없습니다.';

  @override
  String get settingsBackupSuccess => '백업 완료!';

  @override
  String get settingsBackupFailed => '백업에 실패했습니다.';

  @override
  String get settingsBackupShared => '백업 파일을 공유했습니다.';

  @override
  String get settingsBackupShareFailed => '백업 파일 생성에 실패했습니다.';

  @override
  String get settingsRestoreDialogTitle => '데이터 복원';

  @override
  String get settingsRestoreDialogContent =>
      '기존 데이터가 삭제되고 백업 데이터로 대체됩니다. 계속하시겠어요?';

  @override
  String get settingsRestoreConfirm => '복원';

  @override
  String get settingsRestoreSuccess => '복원 완료!';

  @override
  String get settingsRestoreFailed => '복원에 실패했습니다.';

  @override
  String settingsFileReadFailed(String error) {
    return '파일 읽기 실패: $error';
  }

  @override
  String get settingsFileNotReadable => '파일을 읽을 수 없습니다.';

  @override
  String get settingsFilePathNotFound => '파일 경로를 찾을 수 없습니다.';

  @override
  String get userTypeSelectPrompt => '사용 목적을 선택해 주세요.';

  @override
  String get userTypePersonal => '개인용';

  @override
  String get userTypePersonalSub => '생활비, 용돈 관리';

  @override
  String get userTypeBusiness => '사업용';

  @override
  String get userTypeBusinessSub => '지출 관리, 세금 관리';

  @override
  String get userTypeIndividual => '개인사업자';

  @override
  String get userTypeCorporate => '법인사업자';

  @override
  String get userTypeSaveError => '설정 저장 중 오류가 발생했습니다.';

  @override
  String get addTransactionNew => '새 거래 입력';

  @override
  String get addTransactionEdit => '거래 수정';

  @override
  String get addTransactionType => '거래 유형';

  @override
  String get addTransactionInfo => '거래 정보';

  @override
  String get addTransactionExpense => '지출';

  @override
  String get addTransactionIncome => '수입';

  @override
  String get addTransactionStoreName => '상호명';

  @override
  String get addTransactionStoreNameRequired => '필수 입력 항목입니다';

  @override
  String get addTransactionAmountLabel => '금액';

  @override
  String get addTransactionAmountUnit => '원';

  @override
  String get addTransactionAmountRequired => '필수 입력 항목입니다';

  @override
  String get addTransactionPaymentMethod => '결제 수단';

  @override
  String get addTransactionDepositMethod => '입금 수단';

  @override
  String get addTransactionInstallment => '할부 개월';

  @override
  String get addTransactionInstallmentOnce => '일시불';

  @override
  String get addTransactionInstallmentCustom => '직접 입력';

  @override
  String addTransactionInstallmentMonths(String n) {
    return '$n개월';
  }

  @override
  String get addTransactionCashReceiptBusiness => '지출증빙용';

  @override
  String get addTransactionCashReceiptPersonal => '소득공제용';

  @override
  String get addTransactionApprovalNumber => '승인번호 (선택)';

  @override
  String get addTransactionCategoryLabel => '분류';

  @override
  String get addTransactionCategoryDirectInput => '직접 입력';

  @override
  String get addTransactionTaxSettings => '세금 설정';

  @override
  String get addTransactionVatDeductible => '부가세 공제 대상';

  @override
  String get addTransactionBusinessExpense => '이 지출은 사업 관련입니다';

  @override
  String get addTransactionBusinessExpenseOnSub => '사업 경비로 부가세 환급 계산에 포함';

  @override
  String get addTransactionBusinessExpenseOffSub => '개인용/불공제로 표시 (부가세 환급 제외)';

  @override
  String get addTransactionMemoLabel => '메모';

  @override
  String get addTransactionMemoHint => '세부 내용을 입력하세요';

  @override
  String get addTransactionMemoHintEntertainment => '참석자, 목적을 입력하세요';

  @override
  String get addTransactionSaving => '저장 중...';

  @override
  String get addTransactionSave => '저장';

  @override
  String get addTransactionSaved => '저장되었습니다!';

  @override
  String get addTransactionDeleted => '삭제되었습니다.';

  @override
  String get addTransactionLoginRequired => '로그인이 필요합니다. 다시 로그인해 주세요.';

  @override
  String get addTransactionImageUploadFailed => '이미지 업로드에 실패했습니다';

  @override
  String get addTransactionReceiptPrompt => '영수증 사진을 첨부해 주세요';

  @override
  String get addTransactionReceiptRequired => '영수증 필요';

  @override
  String get addTransactionReceiptRequiredContent =>
      '결제 수단과 금액 기준으로\n세법상 영수증 보관이 필요한 거래입니다.\n\n영수증 없이 저장하시겠어요?';

  @override
  String get addTransactionReceiptAttach => '영수증 첨부';

  @override
  String get addTransactionSaveAnyway => '그래도 저장';

  @override
  String get addTransactionCorporateReceiptWarning => '증빙 누락 안내';

  @override
  String get addTransactionCorporateReceiptContent =>
      '법인 지출은 일반적으로 영수증이 필요합니다.\n사진 없이 저장하시겠어요?';

  @override
  String get addTransactionDeleteConfirmTitle => '이 거래를 삭제할까요?';

  @override
  String get addTransactionDeleteConfirmContent => '이 거래 내역이 영구적으로 삭제됩니다.';

  @override
  String get addTransactionReceiptTake => '사진 촬영';

  @override
  String get addTransactionReceiptFromGallery => '갤러리에서 선택';

  @override
  String get addTransactionUncategorized => '미분류';

  @override
  String get allTransactionsTitle => '전체 거래 내역';

  @override
  String get allTransactionsSearchHint => '상호, 메모, 분류, 금액으로 검색';

  @override
  String get allTransactionsFilter => '필터';

  @override
  String get allTransactionsFilterTitle => '필터';

  @override
  String get allTransactionsFilterReset => '초기화';

  @override
  String get allTransactionsFilterApply => '필터 적용';

  @override
  String get allTransactionsNoResults => '거래 내역이 없습니다.';

  @override
  String get allTransactionsPeriod => '기간';

  @override
  String get allTransactionsPeriodAll => '전체';

  @override
  String get allTransactionsPeriodThisMonth => '이번 달';

  @override
  String get allTransactionsPeriodLastMonth => '지난 달';

  @override
  String get allTransactionsPeriodThreeMonths => '3개월';

  @override
  String get allTransactionsPeriodCustom => '직접 설정';

  @override
  String get allTransactionsTypeAll => '전체';

  @override
  String get allTransactionsTypeIncome => '수입';

  @override
  String get allTransactionsTypeExpense => '지출';

  @override
  String get allTransactionsFilterPaymentMethod => '결제 수단';

  @override
  String get allTransactionsFilterCategory => '분류';

  @override
  String get allTransactionsFilterTaxOptions => '세금 옵션';

  @override
  String get allTransactionsFilterNoReceipt => '영수증 없음만';

  @override
  String get allTransactionsFilterTaxDeductible => '부가세 공제 대상만';

  @override
  String get allTransactionsFilterSort => '정렬';

  @override
  String get allTransactionsSortLatest => '최신순';

  @override
  String get allTransactionsSortOldest => '오래된순';

  @override
  String get allTransactionsSortAmountDesc => '금액 높은순';

  @override
  String get allTransactionsSortAmountAsc => '금액 낮은순';

  @override
  String get allTransactionsUncategorized => '미분류';

  @override
  String get statisticsTitle => '통계 / 세금 리포트';

  @override
  String get statisticsTaxReportTab => '세금 리포트';

  @override
  String get statisticsExpenseTab => '지출 통계';

  @override
  String get statisticsThisMonthTaxScore => '이번 달 세금 점수';

  @override
  String get statisticsDeductibleRatio => '공제 가능 지출 비율';

  @override
  String get statisticsReceiptCoverage => '영수증 확보율';

  @override
  String get statisticsBigNoReceipt => '10만원 이상 영수증 누락';

  @override
  String get statisticsDeductibleSection => '공제 / 불공제 지출';

  @override
  String get statisticsDeductible => '공제 가능';

  @override
  String get statisticsNonDeductible => '불공제 / 개인';

  @override
  String statisticsDeductiblePercent(String percent) {
    return '이번 달 지출의 약 $percent%가 세금 공제 대상입니다.';
  }

  @override
  String get statisticsTopRiskCategories => '위험도 높은 상위 3개 분류';

  @override
  String get statisticsReceiptSection => '영수증 확보율';

  @override
  String get statisticsNoExpenseThisMonth => '이번 달 기록된 지출이 없습니다.';

  @override
  String statisticsTotalExpense(String amount) {
    return '총 지출 $amount';
  }

  @override
  String get statisticsTaxSafe => '안전';

  @override
  String get statisticsTaxNormal => '보통';

  @override
  String get statisticsTaxWarning => '주의';

  @override
  String get statisticsTaxSafeComment => '전반적인 세금 리스크가 낮습니다.';

  @override
  String get statisticsTaxNormalComment => '몇 가지 위험 요소를 관리하면 더 좋아집니다.';

  @override
  String get statisticsTaxWarningComment => '불공제 지출과 영수증 누락을 확인하세요.';

  @override
  String get taxReportTitle => '세금 리포트';

  @override
  String get taxReportVatRefundEstimate => '이번 분기 예상 부가세 환급액';

  @override
  String get taxReportVatPaymentEstimate => '이번 분기 예상 부가세 납부액';

  @override
  String get taxReportEstimateNote => '앱에 입력된 수입·지출 기준 예상치입니다';

  @override
  String get taxReportMonthlyExpenseBreakdown => '이번 달 지출 내역';

  @override
  String get taxReportDeductibleExpense => '공제 가능 지출';

  @override
  String get taxReportNonDeductibleExpense => '불공제 / 개인 지출';

  @override
  String get taxReportReceiptStatus => '영수증 현황';

  @override
  String get taxReportAllReceiptsRegistered => '필요한 영수증이 모두 등록되었습니다';

  @override
  String taxReportMissingReceipts(String count) {
    return '영수증이 필요한 지출 중\n$count건이 아직 등록되지 않았습니다';
  }

  @override
  String taxReportMissingAmount(String amount) {
    return '누락 금액: $amount';
  }

  @override
  String taxReportNonDeductibleRatio(String ratio) {
    return '불공제 비율: $ratio%';
  }

  @override
  String get taxReportNoDataYet => '이번 달 지출 데이터가 아직 거의 없습니다.';

  @override
  String get taxReportNonDeductibleLow => '불공제 비율이 낮아 비교적 안정적입니다.';

  @override
  String get taxReportNonDeductibleMedium =>
      '불공제 비율이 다소 높습니다. 개인 지출 분리를 고려하세요.';

  @override
  String get taxReportNonDeductibleHigh =>
      '불공제 비율이 상당히 높습니다. 세무 상담이 필요할 수 있습니다.';

  @override
  String get recurringAddTitle => '정기 거래 추가';

  @override
  String get recurringEditTitle => '정기 거래 수정';

  @override
  String get recurringBasicInfo => '기본 정보';

  @override
  String get recurringNameLabel => '이름 (예: 월세, 직원 월급)';

  @override
  String get recurringRequired => '필수 입력입니다';

  @override
  String get recurringStoreLabel => '거래처 / 상호명 (선택)';

  @override
  String get recurringCycle => '반복 주기';

  @override
  String get recurringCycleMonthly => '매월';

  @override
  String get recurringCycleWeekly => '매주';

  @override
  String recurringDayOfMonth(String n) {
    return '$n일';
  }

  @override
  String get recurringMemoOptional => '메모 (선택)';

  @override
  String get recurringMemoHint => '예: 1호점 월세, 김대리 급여 등';

  @override
  String get recurringUpdate => '수정하기';

  @override
  String get recurringRegister => '등록하기';

  @override
  String get recurringLoginRequired => '로그인이 필요합니다.';

  @override
  String get recurringAmountInvalid => '금액을 올바르게 입력해주세요.';

  @override
  String get recurringAdded => '정기 거래가 추가되었습니다.';

  @override
  String get recurringUpdated => '정기 거래가 수정되었습니다.';

  @override
  String get recurringSaveError => '저장 중 오류가 발생했습니다.';

  @override
  String get recurringListTitle => '정기 거래';

  @override
  String get recurringListEmpty => '등록된 정기 거래가 없습니다.';

  @override
  String get recurringListEmptySub => '임대료, 급여, 구독료 등을 자동 등록하세요.';

  @override
  String get recurringDeleteTitle => '정기 거래를 삭제할까요?';

  @override
  String get recurringDeleteContent => '이 정기 거래가 삭제됩니다.';

  @override
  String recurringMonthlyDay(String n) {
    return '매월 $n일';
  }

  @override
  String recurringWeeklyDay(String weekday) {
    return '매주 $weekday';
  }

  @override
  String get recurringMonthlyDaySelect => '매월 몇 일?';

  @override
  String get recurringWeekdaySelect => '요일 선택';

  @override
  String get recurringCategoryOptional => '카테고리 (선택)';

  @override
  String get recurringMethodOptional => '결제/입금 수단 (선택)';

  @override
  String get recurringVatDeductibleToggle => '부가세 공제 대상 지출로 보기';

  @override
  String get recurringActiveToggle => '이 정기 거래 자동 생성 사용';

  @override
  String get recurringActiveToggleSub => '꺼두면 앞으로 자동으로 내역이 생성되지 않습니다.';

  @override
  String get recurringSkipTitle => '이번 달만 건너뛸까요?';

  @override
  String get recurringSkipContent => '이번 달에는 이 정기 거래로 인한 자동 생성이 일어나지 않습니다.';

  @override
  String get recurringSkip => '건너뛰기';

  @override
  String get recurringSkipDone => '이번 달은 건너뛰기로 설정되었습니다.';

  @override
  String get recurringSkipButton => '이번 달만 건너뛰기';

  @override
  String get recurringDeleteFailed => '삭제에 실패했습니다.';

  @override
  String get recurringAutoOff => '자동 생성 꺼짐';

  @override
  String get homeDefaultName => '사장님';

  @override
  String homeGreeting(String name) {
    return '$name 님';
  }

  @override
  String statisticsScorePoints(String score) {
    return '$score점';
  }

  @override
  String get taxEventDefaultTitle => '세무 일정';

  @override
  String get settingsInquirySubject => '[BizExpense] 문의합니다';

  @override
  String get settingsInquiryBody => '1. 문의 유형:\n2. 내용:\n\n(여기에 내용을 적어주세요)';

  @override
  String get profileEditSaved => '프로필이 저장되었습니다.';

  @override
  String profileEditSaveError(String error) {
    return '저장 중 오류가 발생했습니다: $error';
  }

  @override
  String get profileNameHint => '실제 이름';

  @override
  String get profileAgeHint => '예) 35';

  @override
  String get profileNickname => '닉네임';

  @override
  String get profileNicknameSection => '닉네임';

  @override
  String get profileSaveButton => '저장하기';

  @override
  String get signupTypeSoleProp => '1인 사업자';

  @override
  String get signupTypeSolePropSub => '1인 소유주 · 부가세 추적 및 지출 관리';

  @override
  String get signupTypeLlc => '유한책임회사(LLC)';

  @override
  String get signupTypeLlcSub => '유한책임회사 · 법인 회계';

  @override
  String get signupTypeFreeZone => '프리존 법인';

  @override
  String get signupTypeFreeZoneSub => 'DMCC · DIFC · ADGM · NEOM 등 프리존';

  @override
  String signupStepCounter(String current, String total) {
    return '$current / $total';
  }

  @override
  String get txDeposit => '입금';

  @override
  String get txWithdrawal => '출금';
}
