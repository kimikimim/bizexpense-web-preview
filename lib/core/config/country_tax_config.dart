import 'package:intl/intl.dart';

class TaxFilingPeriod {
  final String label;
  final int startMonth;
  final int endMonth;

  const TaxFilingPeriod({
    required this.label,
    required this.startMonth,
    required this.endMonth,
  });
}

class CountryTaxConfig {
  final String countryCode;
  final String countryName;
  final String nativeName;
  final String flagEmoji;
  final String currencySymbol;
  final String currencyLocale;
  final double vatRate;
  final String vatTerminology;
  final String yearPeriodFormat;
  final List<TaxFilingPeriod> filingPeriods;
  final List<String> nonDeductibleCategories;
  final String languageCode;

  const CountryTaxConfig({
    required this.countryCode,
    required this.countryName,
    required this.nativeName,
    required this.flagEmoji,
    required this.currencySymbol,
    required this.currencyLocale,
    required this.vatRate,
    required this.vatTerminology,
    required this.yearPeriodFormat,
    required this.filingPeriods,
    required this.nonDeductibleCategories,
    this.languageCode = 'en',
  });

  TaxFilingPeriod currentPeriod() {
    final month = DateTime.now().month;
    for (final p in filingPeriods) {
      if (month >= p.startMonth && month <= p.endMonth) return p;
    }
    return filingPeriods.last;
  }

  String formatPeriodYear(int year, TaxFilingPeriod period) {
    return yearPeriodFormat
        .replaceAll('{year}', '$year')
        .replaceAll('{period}', period.label);
  }

  /// Format a money amount using this country's currency & locale.
  String formatMoney(num amount) {
    return NumberFormat.currency(
      locale: currencyLocale,
      symbol: currencySymbol,
    ).format(amount);
  }

  /// ISO 4217 currency code (matches the ME DB currency_code CHECK).
  String get currencyCode {
    switch (countryCode) {
      case 'KR':
        return 'KRW';
      case 'AE':
        return 'AED';
      case 'SA':
        return 'SAR';
      case 'ID':
        return 'IDR';
      case 'VN':
        return 'VND';
      default:
        return 'USD';
    }
  }

  /// Currency code to persist, or null for KR whose tables have no
  /// currency_code column (sending it there would break the insert).
  String? get persistCurrencyCode => countryCode == 'KR' ? null : currencyCode;
}

const Map<String, CountryTaxConfig> kCountryConfigs = {
  'KR': CountryTaxConfig(
    countryCode: 'KR',
    countryName: 'South Korea',
    nativeName: '한국',
    flagEmoji: '🇰🇷',
    currencySymbol: '₩',
    currencyLocale: 'ko_KR',
    vatRate: 0.10,
    vatTerminology: '부가세',
    yearPeriodFormat: '{year}년 {period}',
    languageCode: 'ko',
    filingPeriods: [
      TaxFilingPeriod(label: '1기', startMonth: 1, endMonth: 6),
      TaxFilingPeriod(label: '2기', startMonth: 7, endMonth: 12),
    ],
    nonDeductibleCategories: ['접대', '개인', '의류'],
  ),
  'AE': CountryTaxConfig(
    countryCode: 'AE',
    countryName: 'UAE',
    nativeName: 'الإمارات',
    flagEmoji: '🇦🇪',
    currencySymbol: 'AED',
    currencyLocale: 'en_AE',
    vatRate: 0.05,
    vatTerminology: 'VAT',
    yearPeriodFormat: '{year} {period}',
    languageCode: 'ar',
    filingPeriods: [
      TaxFilingPeriod(label: 'Q1', startMonth: 1, endMonth: 3),
      TaxFilingPeriod(label: 'Q2', startMonth: 4, endMonth: 6),
      TaxFilingPeriod(label: 'Q3', startMonth: 7, endMonth: 9),
      TaxFilingPeriod(label: 'Q4', startMonth: 10, endMonth: 12),
    ],
    nonDeductibleCategories: ['Personal', 'Entertainment', 'Clothing'],
  ),
  'ID': CountryTaxConfig(
    countryCode: 'ID',
    countryName: 'Indonesia',
    nativeName: 'Indonesia',
    flagEmoji: '🇮🇩',
    currencySymbol: 'Rp',
    currencyLocale: 'id_ID',
    vatRate: 0.11,
    vatTerminology: 'PPN',
    yearPeriodFormat: '{period} {year}',
    filingPeriods: [
      TaxFilingPeriod(label: 'Jan', startMonth: 1, endMonth: 1),
      TaxFilingPeriod(label: 'Feb', startMonth: 2, endMonth: 2),
      TaxFilingPeriod(label: 'Mar', startMonth: 3, endMonth: 3),
      TaxFilingPeriod(label: 'Apr', startMonth: 4, endMonth: 4),
      TaxFilingPeriod(label: 'May', startMonth: 5, endMonth: 5),
      TaxFilingPeriod(label: 'Jun', startMonth: 6, endMonth: 6),
      TaxFilingPeriod(label: 'Jul', startMonth: 7, endMonth: 7),
      TaxFilingPeriod(label: 'Aug', startMonth: 8, endMonth: 8),
      TaxFilingPeriod(label: 'Sep', startMonth: 9, endMonth: 9),
      TaxFilingPeriod(label: 'Oct', startMonth: 10, endMonth: 10),
      TaxFilingPeriod(label: 'Nov', startMonth: 11, endMonth: 11),
      TaxFilingPeriod(label: 'Dec', startMonth: 12, endMonth: 12),
    ],
    nonDeductibleCategories: ['Pribadi', 'Hiburan', 'Pakaian'],
  ),
  'VN': CountryTaxConfig(
    countryCode: 'VN',
    countryName: 'Vietnam',
    nativeName: 'Việt Nam',
    flagEmoji: '🇻🇳',
    currencySymbol: '₫',
    currencyLocale: 'vi_VN',
    vatRate: 0.10,
    vatTerminology: 'VAT',
    yearPeriodFormat: '{year} {period}',
    filingPeriods: [
      TaxFilingPeriod(label: 'Q1', startMonth: 1, endMonth: 3),
      TaxFilingPeriod(label: 'Q2', startMonth: 4, endMonth: 6),
      TaxFilingPeriod(label: 'Q3', startMonth: 7, endMonth: 9),
      TaxFilingPeriod(label: 'Q4', startMonth: 10, endMonth: 12),
    ],
    nonDeductibleCategories: ['Cá nhân', 'Giải trí', 'Quần áo'],
  ),
  'SA': CountryTaxConfig(
    countryCode: 'SA',
    countryName: 'Saudi Arabia',
    nativeName: 'السعودية',
    flagEmoji: '🇸🇦',
    currencySymbol: 'SAR',
    currencyLocale: 'ar_SA',
    vatRate: 0.15,
    vatTerminology: 'VAT',
    yearPeriodFormat: '{year} {period}',
    languageCode: 'ar',
    filingPeriods: [
      TaxFilingPeriod(label: 'Q1', startMonth: 1, endMonth: 3),
      TaxFilingPeriod(label: 'Q2', startMonth: 4, endMonth: 6),
      TaxFilingPeriod(label: 'Q3', startMonth: 7, endMonth: 9),
      TaxFilingPeriod(label: 'Q4', startMonth: 10, endMonth: 12),
    ],
    nonDeductibleCategories: ['Personal', 'Entertainment', 'Clothing'],
  ),
};
