import 'package:flutter/material.dart';

/// Country-aware payment methods & categories.
///
/// Korea (KR) keeps the original Korean tax concepts (현금영수증, 지역화폐, 제로페이...).
/// Other countries (Middle East) get a generic localized set without
/// Korea-specific tax artifacts.
class TxOptions {
  final bool isKorea;
  const TxOptions(this.isKorea);

  factory TxOptions.forCountry(String countryCode) =>
      TxOptions(countryCode == 'KR');

  // ---- Payment methods (expense) ----
  List<String> get expensePaymentMethods => isKorea
      ? const [
          '개인카드',
          '법인카드',
          '현금영수증',
          '계좌이체',
          '간이영수증',
          '지역화폐',
          '제로페이',
          '상품권',
          '포인트/마일리지',
          '기타',
        ]
      : const [
          'Credit Card',
          'Debit Card',
          'Cash',
          'Bank Transfer',
          'Cheque',
          'Online Payment',
          'Other',
        ];

  // ---- Deposit methods (income) ----
  List<String> get incomeMethods => isKorea
      ? const [
          '계좌입금',
          '현금',
          '카드수납',
          '전자결제',
          '기타',
        ]
      : const [
          'Bank Deposit',
          'Cash',
          'Card',
          'Online Payment',
          'Other',
        ];

  String get defaultExpenseMethod => isKorea ? '개인카드' : 'Credit Card';
  String get defaultIncomeMethod => isKorea ? '계좌입금' : 'Bank Deposit';
  String get otherMethod => isKorea ? '기타' : 'Other';

  // ---- Expense categories ----
  List<Map<String, dynamic>> get expenseCategories => isKorea
      ? const [
          {'icon': Icons.restaurant, 'label': '식비'},
          {'icon': Icons.local_cafe, 'label': '카페/간식'},
          {'icon': Icons.directions_car, 'label': '교통비'},
          {'icon': Icons.shopping_bag, 'label': '쇼핑'},
          {'icon': Icons.shopping_cart, 'label': '소모품'},
          {'icon': Icons.handshake, 'label': '접대비'},
          {'icon': Icons.phone_android, 'label': '통신비'},
          {'icon': Icons.local_hospital, 'label': '의료비'},
          {'icon': Icons.school, 'label': '교육비'},
          {'icon': Icons.more_horiz, 'label': '기타'},
        ]
      : const [
          {'icon': Icons.restaurant, 'label': 'Food'},
          {'icon': Icons.local_cafe, 'label': 'Cafe / Snacks'},
          {'icon': Icons.directions_car, 'label': 'Transport'},
          {'icon': Icons.shopping_bag, 'label': 'Shopping'},
          {'icon': Icons.shopping_cart, 'label': 'Supplies'},
          {'icon': Icons.handshake, 'label': 'Entertainment'},
          {'icon': Icons.phone_android, 'label': 'Telecom'},
          {'icon': Icons.local_hospital, 'label': 'Medical'},
          {'icon': Icons.school, 'label': 'Education'},
          {'icon': Icons.more_horiz, 'label': 'Other'},
        ];

  // ---- Income categories ----
  List<Map<String, dynamic>> get incomeCategories => isKorea
      ? const [
          {'icon': Icons.work, 'label': '사업수입'},
          {'icon': Icons.payments, 'label': '급여'},
          {'icon': Icons.sell, 'label': '판매수익'},
          {'icon': Icons.account_balance, 'label': '임대수익'},
          {'icon': Icons.trending_up, 'label': '투자수익'},
          {'icon': Icons.card_giftcard, 'label': '기타수입'},
          {'icon': Icons.more_horiz, 'label': '기타'},
        ]
      : const [
          {'icon': Icons.work, 'label': 'Business Income'},
          {'icon': Icons.payments, 'label': 'Salary'},
          {'icon': Icons.sell, 'label': 'Sales Revenue'},
          {'icon': Icons.account_balance, 'label': 'Rental Income'},
          {'icon': Icons.trending_up, 'label': 'Investment'},
          {'icon': Icons.card_giftcard, 'label': 'Other Income'},
          {'icon': Icons.more_horiz, 'label': 'Other'},
        ];

  /// True if this method represents a card payment (installment-capable).
  bool isCardMethod(String method) =>
      isKorea ? method.contains('카드') : method.contains('Card');

  /// Korea-only cash-receipt method.
  bool isCashReceipt(String method) => isKorea && method == '현금영수증';
}
