import 'upcoming_tax_banner.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/data/transaction_model.dart';
import '../../transactions/data/transaction_repository.dart';

import '../../../core/utils/text_parser.dart';
import '../../../core/utils/excel_service.dart';
import '../../tax/services/tax_service.dart';
import '../../receivables/presentation/unpaid_receivables_page.dart';


import '../../receipts/presentation/camera_page.dart';
import '../../transactions/presentation/add_transaction_page.dart';
import '../../auth/presentation/login_page.dart';
import '../../tax/presentation/tax_tips_page.dart';
import '../../transactions/presentation/all_transactions_page.dart';
import '../../transactions/presentation/transaction_list_item.dart';
import '../../../core/constants/category_icons.dart';
import '../../transactions/presentation/missing_receipt_page.dart';
import '../../recurring/data/recurring_transaction_model.dart';
import '../../recurring/data/recurring_transaction_repository.dart';
import '../../recurring/services/recurring_service.dart';
import 'package:expense_pro/core/utils/app_logger.dart';
import '../../cards/presentation/card_list_page.dart';
import '../../cards/data/card_repository.dart';
import '../../tax/presentation/tax_summary_page.dart';
import '../../../core/providers/country_config_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _transactionType = 'expense'; 
  String _cycle = 'monthly';          

  final TransactionRepository _repository = TransactionRepository();
  final TaxService _taxService = TaxService();

  final RecurringTransactionRepository _recurringRepo =
      RecurringTransactionRepository();
  final RecurringService _recurringService = RecurringService();

  List<RecurringTransactionModel> _recurrings = [];

  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  late NumberFormat currencyFormat;

  @override
  void initState() {
    super.initState();
    final config = ref.read(countryConfigProvider);
    currencyFormat = NumberFormat.currency(
      locale: config.currencyLocale,
      symbol: config.currencySymbol,
    );
    _loadData();
  }

  static const double _sectionGap = 16.0;              
  static const double _sectionHorizontalPadding = 16.0; 
  static const double _sectionInnerGap = 8.0; 

  TextStyle get _sectionTitleStyle => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      );

  bool _isVatDeductibleForVat(TransactionModel tx) {
    
    if (tx.transactionType != 'expense') return false;

    if (!_isDeductible(tx)) return false;

    if (tx.receiptUrl == null || tx.receiptUrl!.isEmpty) return false;

    return true;
  }

  Map<String, dynamic>? _upcomingTaxEvent;
  Map<String, dynamic>? _taxProfile;
  Map<String, dynamic> _calculateVatForCurrentPeriod() {
    final config = ref.read(countryConfigProvider);
    final now = DateTime.now();
    final int year = now.year;
    final taxPeriod = config.currentPeriod();

    final DateTime from = DateTime(year, taxPeriod.startMonth, 1);
    final DateTime to = DateTime(year, taxPeriod.endMonth + 1, 1)
        .subtract(const Duration(days: 1));

    final String periodWithYear = config.formatPeriodYear(year, taxPeriod);

    int salesTotal = 0;
    int purchaseTotal = 0;

    for (final tx in _transactions) {
      final d = tx.date;

      if (d.isBefore(from) || d.isAfter(to)) continue;

      if (tx.transactionType == 'income') {
        salesTotal += tx.amount;
      } else if (tx.transactionType == 'expense') {
        if (!_isVatDeductibleForVat(tx)) continue;
        purchaseTotal += tx.amount;
      }
    }

    final int salesVat = (salesTotal * config.vatRate).round();
    final int purchaseVat = (purchaseTotal * config.vatRate).round();
    final int netVat = purchaseVat - salesVat;

    return {
      'period': taxPeriod.label,
      'periodWithYear': periodWithYear,
      'salesTotal': salesTotal,
      'purchaseTotal': purchaseTotal,
      'salesVat': salesVat,
      'purchaseVat': purchaseVat,
      'netVat': netVat,
    };
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openVatDetailBottomSheet() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formatter = NumberFormat('#,###');
    final config = ref.read(countryConfigProvider);

    final vatData = _calculateVatForCurrentPeriod();
    final String periodWithYear = vatData['periodWithYear'] as String;
    final int salesTotal = vatData['salesTotal'] as int;
    final int purchaseTotal = vatData['purchaseTotal'] as int;
    final int salesVat = vatData['salesVat'] as int;
    final int purchaseVat = vatData['purchaseVat'] as int;
    final int net = vatData['netVat'] as int;
    final bool isRefund = net >= 0;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  "$periodWithYear ${config.vatTerminology} 예상 상세",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("매출 합계"),
                    Text("₩${formatter.format(salesTotal)}"),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("매입 합계(공제 대상)"),
                    Text("₩${formatter.format(purchaseTotal)}"),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("매출 ${config.vatTerminology} (${(config.vatRate * 100).toStringAsFixed(0)}%)"),
                    Text("${config.currencySymbol}${formatter.format(salesVat)}"),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("매입 ${config.vatTerminology} (${(config.vatRate * 100).toStringAsFixed(0)}%)"),
                    Text("${config.currencySymbol}${formatter.format(purchaseVat)}"),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isRefund ? "환급 예상액" : "납부 예상액",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isRefund ? Colors.teal : Colors.deepOrange,
                      ),
                    ),
                    Text(
                      "₩${formatter.format(net.abs())}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isRefund ? Colors.teal : Colors.deepOrange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                Text(
                  "※ 현재 기(${periodWithYear.split(' ').last})에 입력된 매출·지출 기준으로 단순 계산된 값입니다.",
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    await RecurringService().runAutoApplyForToday();

    final data = await _repository.getTransactions();

    final recurrings = await _recurringRepo.getMyRecurring(onlyActive: true);

    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    Map<String, dynamic>? taxEvent;
    try {
      final List<dynamic> response = await Supabase.instance.client
          .from('tax_events')
          .select()
          .gte('due_date', todayStr)
          .eq('is_paid', false)
          .order('due_date', ascending: true)
          .limit(1);

      if (response.isNotEmpty) {
        taxEvent = response.first as Map<String, dynamic>;
      }
    } catch (e) {
      appLogger.e("세금 일정 로드 실패: $e", error: e);
    }

    Map<String, dynamic>? profile;
    try {
      profile = await _taxService.loadProfile();
    } catch (e) {
      appLogger.e("세무 프로필 로드 실패: $e", error: e);
    }

    if (!mounted) return;
    setState(() {
      _transactions = data;
      _recurrings = recurrings;
      _upcomingTaxEvent = taxEvent;
      _taxProfile = profile;
      _isLoading = false;
    });

    CardRepository().syncTransactions();
  }
  
  int _getMonthlyIncome() {
    final now = DateTime.now();
    return _transactions
        .where((tx) =>
            tx.transactionType == 'income' &&
            tx.date.year == now.year &&
            tx.date.month == now.month)
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  List<String> get _nonDeductibleCategories =>
      ref.read(countryConfigProvider).nonDeductibleCategories;

  bool _isDeductible(TransactionModel tx) {
    final category = tx.category ?? '';
    for (final blocked in _nonDeductibleCategories) {
      if (category.contains(blocked)) return false;
    }
    return true;
  }

  int _calculateVatRefundEstimate() {
    final vatRate = ref.read(countryConfigProvider).vatRate;
    double refundableVat = 0;

    for (final tx in _transactions) {
      if (tx.transactionType != 'expense') continue;
      if (!_isDeductible(tx)) continue;
      if (tx.receiptUrl == null || tx.receiptUrl!.isEmpty) continue;

      refundableVat += tx.amount * vatRate;
    }

    return refundableVat.round();
  }

  int _getQuarterVatNet() {
    final config = ref.read(countryConfigProvider);
    final now = DateTime.now();
    final period = config.currentPeriod();
    final start = DateTime(now.year, period.startMonth, 1);
    final end = DateTime(now.year, period.endMonth + 1, 1);

    int salesVat = 0;
    int purchaseVat = 0;

    for (final tx in _transactions) {
      final d = tx.date;

      if (d.isBefore(start) || !d.isBefore(end)) continue;

      if (tx.transactionType == 'income') {
        salesVat += (tx.amount * config.vatRate).round();
      } else if (tx.transactionType == 'expense') {
        if (!_isVatDeductibleForVat(tx)) continue;
        purchaseVat += (tx.amount * config.vatRate).round();
      }
    }

    return purchaseVat - salesVat;
  }

  int _getMonthlyExpense() {
    final now = DateTime.now();
    return _transactions
        .where((tx) =>
            tx.transactionType == 'expense' &&
            tx.date.year == now.year &&
            tx.date.month == now.month)
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  int _getUnpaidReceivables() {
    return _transactions
        .where((tx) => tx.transactionType == 'income' && !tx.isPaid)
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  int _getUnpaidPayables() {
    return _transactions
        .where((tx) => tx.transactionType == 'expense' && !tx.isPaid)
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  int _getEstimatedTax() {
    final monthlyExpense = _getMonthlyExpense();
    
    return (monthlyExpense * 0.15).round();
  }

  double _getMonthOverMonthGrowth() {
    final now = DateTime.now();
    final thisMonth = _getMonthlyIncome();

    final lastMonthDate = DateTime(now.year, now.month - 1);
    final lastMonth = _transactions
        .where((tx) =>
            tx.transactionType == 'income' &&
            tx.date.year == lastMonthDate.year &&
            tx.date.month == lastMonthDate.month)
        .fold(0, (sum, tx) => sum + tx.amount);

    if (lastMonth == 0) return 0;
    return ((thisMonth - lastMonth) / lastMonth * 100);
  }

  List<TransactionModel> _getUnpaidReceivablesList() {
    return _transactions
        .where((tx) => tx.transactionType == 'income' && !tx.isPaid)
        .toList();
  }

  List<TransactionModel> _getRecentTransactions() {
    final sorted = List<TransactionModel>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(3).toList();
  }

  int _getVatDaysRemaining() {
    if (_upcomingTaxEvent == null) return -1;
    try {
      final dueDateStr = _upcomingTaxEvent!['due_date'];
      if (dueDateStr == null) return -1;
      final eventDate = DateTime.parse(dueDateStr);
      final today = DateTime.now();
      final diff = DateTime(eventDate.year, eventDate.month, eventDate.day)
          .difference(DateTime(today.year, today.month, today.day))
          .inDays;
      return diff;
    } catch (e) {
      return -1;
    }
  }

  Future<void> _openMissingReceiptList() async {
    final missing = _getMissingReceiptList();
    if (missing.isEmpty) {
      _showSnackBar("영수증 누락된 항목이 없습니다.");
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  "영수증 누락된 지출",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "영수증 사진을 등록하면 세무 리스크를 줄일 수 있어요.",
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: missing.length,
                    itemBuilder: (context, index) {
                      final tx = missing[index];

                      final categoryKey = (tx.category == null ||
                              tx.category!.trim().isEmpty)
                          ? '기타'
                          : tx.category!;
                      final icon =
                          categoryIcons[categoryKey] ?? Icons.receipt_long;

                      return TransactionListItem(
                        tx: tx,
                        isDark: isDark,
                        leadingIcon: icon,
                        onTap: () async {
                          
                          Navigator.pop(context); 
                          await _navigateToAddPage(
                            initialData: tx,
                            isExistingRecord: true,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _navigateToAddPage(
      {TransactionModel? initialData,
      bool isExistingRecord = false,
      String? transactionType}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionPage(
          initialData: initialData,
          isExistingRecord: isExistingRecord,
          initialTransactionType: transactionType,
        ),
      ),
    );
    if (result == true) _loadData();
  }

  Future<void> _pasteAndParse() async {
    final ClipboardData? data =
        await Clipboard.getData(Clipboard.kTextPlain);
    if (data == null || data.text == null) {
      _showSnackBar("복사된 내용이 없습니다.");
      return;
    }
    final parsedTx = TextParser.parse(data.text!);
    if (parsedTx != null) {
      _navigateToAddPage(initialData: parsedTx, isExistingRecord: false);
    } else {
      _showSnackBar("인식 실패: 결제 문자가 아니거나 형식이 다릅니다.");
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("로그아웃"),
        content: const Text("정말 로그아웃 하시겠습니까?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("취소")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("로그아웃",
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1)));
  }

  void _showVatExplainBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formatter = NumberFormat('#,###');

    final int vatRefund = _calculateVatRefundEstimate();

    final deductibleList = _transactions.where((tx) {
      if (tx.transactionType != 'expense') return false;
      if (!_isDeductible(tx)) return false; 
      if (tx.receiptUrl == null || tx.receiptUrl!.isEmpty) return false; 
      return true;
    }).toList();

    final nonDeductibleList = _transactions.where((tx) {
      if (tx.transactionType != 'expense') return false;
      
      if (!_isDeductible(tx)) return true;
      if (tx.receiptUrl == null || tx.receiptUrl!.isEmpty) return true;
      return false;
    }).toList();

    final deductibleTotal = deductibleList.fold<int>(
      0,
      (sum, tx) => sum + tx.amount,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.receipt_long, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "부가세 환급 예상은 이렇게 계산했어요",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  vatRefund >= 0 ? "환급 가능성 (추정)" : "납부 가능성 (추정)",
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "₩${formatter.format(vatRefund.abs())}",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: vatRefund >= 0 ? Colors.teal : Colors.deepOrange,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  "어떻게 계산했나요?",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                _buildVatExplainRow(
                  isDark: isDark,
                  title: "1. 공제 가능 지출만 모았어요",
                  description:
                      "식대·접대·복리후생·개인 지출·의류 등 일부 카테고리는 자동으로 공제 대상에서 제외했어요.",
                ),
                const SizedBox(height: 6),
                _buildVatExplainRow(
                  isDark: isDark,
                  title: "2. 영수증이 있는 지출만 포함했어요",
                  description:
                      "영수증이 등록된 지출만 매입세액으로 보고, 그 합계의 10%를 환급 가능한 부가세로 추정했어요.",
                ),
                const SizedBox(height: 6),
                _buildVatExplainRow(
                  isDark: isDark,
                  title: "3. 매출 부가세와 비교했어요",
                  description:
                      "앱에 입력된 매출 금액의 10%를 매출세액으로 보고, 매입세액과 차이를 계산했어요.",
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "이번 계산에 포함된 지출",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "· 공제 가능 지출 합계: ₩${formatter.format(deductibleTotal)} (${deductibleList.length}건)",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "· 이번 계산에서 제외된 지출: ${nonDeductibleList.length}건",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "⚠️ 실제 부가세 신고 시에는 업종, 면세/과세 구분, 의제매입세액 등 추가 규정 때문에 금액이 달라질 수 있어요. "
                  "정확한 환급·납부 금액은 반드시 세무사와 다시 확인해주세요.",
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
  
  bool _needsReceipt(TransactionModel tx) {
    
    if (tx.transactionType != 'expense') return false;

    final methodRaw = tx.method ?? '';
    final baseMethod = methodRaw.contains('(')
        ? methodRaw.split('(').first
        : methodRaw;
    final amount = tx.amount;

    const mustReceiptMethods = [
      '개인카드',
      '법인카드',
      '현금영수증',
      '계좌이체',
      '간이영수증',
      '제로페이',
      '지역화폐',
      '상품권',
    ];

    if (!mustReceiptMethods.contains(baseMethod)) {
      return false;
    }

    if (baseMethod == '현금영수증' || baseMethod == '간이영수증') {
      return true;
    }

    if (amount >= 100000) {
      return true;
    }

    return false;
  }

  List<TransactionModel> _getMissingReceiptList() {
    final now = DateTime.now();

    return _transactions.where((tx) {
      
      if (!_needsReceipt(tx)) return false;

      final sameMonth =
          tx.date.year == now.year && tx.date.month == now.month;
      if (!sameMonth) return false;

      final hasReceipt =
          tx.receiptUrl != null && tx.receiptUrl!.isNotEmpty;

      return !hasReceipt;
    }).toList();
  }

  int _getReceiptMissingCount() {
    return _getMissingReceiptList().length;
  }
    
  int _getThisMonthIncome() => _getMonthlyIncome();
  int _getThisMonthExpense() => _getMonthlyExpense();

  int _getRemainingRecurringAmount(String type) {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    int total = 0;

    for (final r in _recurrings.where((e) => e.transactionType == type)) {
      if (r.cycle == 'monthly') {
        final day = r.day;
        if (day < now.day) continue; 

        final scheduled = DateTime(now.year, now.month, day);

        if (r.lastAppliedDate != null) {
          final d = DateTime(r.lastAppliedDate!.year,
              r.lastAppliedDate!.month, r.lastAppliedDate!.day);
          if (d.isAtSameMomentAs(scheduled)) continue;
        }

        total += r.amount;
      } else if (r.cycle == 'weekly') {
        
        var date = DateTime(now.year, now.month, now.day);
        final end = DateTime(now.year, now.month, lastDayOfMonth);

        while (!date.isAfter(end)) {
          if (date.weekday == r.day) {
            
            if (r.lastAppliedDate != null &&
                r.lastAppliedDate!.year == date.year &&
                r.lastAppliedDate!.month == date.month &&
                r.lastAppliedDate!.day == date.day) {
              
            } else {
              total += r.amount;
            }
          }
          date = date.add(const Duration(days: 1));
        }
      }
    }

    return total;
  }

  Map<String, int> _getMonthlyForecast() {
    final actualIncome = _getThisMonthIncome();
    final actualExpense = _getThisMonthExpense();

    final remainingFixedIncome = _getRemainingRecurringAmount('income');
    final remainingFixedExpense = _getRemainingRecurringAmount('expense');

    final forecastIncome = actualIncome + remainingFixedIncome;
    final forecastExpense = actualExpense + remainingFixedExpense;
    final forecastNet = forecastIncome - forecastExpense;

    return {
      'actualIncome': actualIncome,
      'actualExpense': actualExpense,
      'remainingFixedIncome': remainingFixedIncome,
      'remainingFixedExpense': remainingFixedExpense,
      'forecastIncome': forecastIncome,
      'forecastExpense': forecastExpense,
      'forecastNet': forecastNet,
    };
  }

  Widget _buildVatExplainRow({
    required bool isDark,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.check_circle, size: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKPISection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthlyIncome = _getMonthlyIncome();
    final monthlyExpense = _getMonthlyExpense();
    final unpaidReceivables = _getUnpaidReceivables();
    final vatData = _calculateVatForCurrentPeriod();
    final String vatPeriod = vatData['period'] as String;
    final int vatNet = vatData['netVat'] as int;
    final unpaidList = _getUnpaidReceivablesList();

    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, '이번 달 현황'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(isDark ? 30 : 8), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Column(children: [
              _kpiRow(context, '이번 달 매출', monthlyIncome, const Color(0xFF2DB400), isDark),
              _kpiDivider(isDark),
              _kpiRow(context, '이번 달 지출', monthlyExpense, const Color(0xFFFF4D4F), isDark),
              _kpiDivider(isDark),
              _kpiRow(context, '미수금${unpaidList.isNotEmpty ? " (${unpaidList.length}건)" : ""}', unpaidReceivables, const Color(0xFFFF9500), isDark,
                onTap: unpaidReceivables > 0 ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => UnpaidReceivablesPage(transactions: unpaidList))) : null),
              _kpiDivider(isDark),
              _kpiRow(context, '$vatPeriod ${ref.read(countryConfigProvider).vatTerminology} ${vatNet >= 0 ? "환급" : "납부"} 예상', vatNet.abs(), vatNet >= 0 ? const Color(0xFF3182F6) : const Color(0xFFFF4D4F), isDark, onTap: _openVatDetailBottomSheet),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _kpiRow(BuildContext context, String label, int amount, Color color, bool isDark, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(children: [
          Container(width: 3, height: 36, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.grey[300] : const Color(0xFF4E5968)))),
          Text(currencyFormat.format(amount), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF191F28))),
          if (onTap != null) ...[const SizedBox(width: 2), Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey[400])],
        ]),
      ),
    );
  }

  Widget _kpiDivider(bool isDark) {
    return Divider(height: 1, indent: 20, endIndent: 20, color: isDark ? Colors.white10 : Colors.grey.shade100);
  }

  Widget _buildKpiSmallCard(_KpiItem item, bool isDark) {
    return _kpiRow(context, item.title, item.value, item.color, isDark, onTap: item.onTap);
  }

  Widget _buildKPICard({required String title, required int amount, required IconData icon, required Color color, required bool isDark, String? subtitle, VoidCallback? onTap}) {
    return const SizedBox.shrink();
  }

  Widget _buildPrimaryActions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actions = [
      {'icon': Icons.add_rounded, 'label': '매출 등록', 'color': const Color(0xFF2DB400), 'bg': const Color(0xFFEBF8E1)},
      {'icon': Icons.remove_rounded, 'label': '지출 등록', 'color': const Color(0xFFFF4D4F), 'bg': const Color(0xFFFFECEC)},
      {'icon': Icons.document_scanner_rounded, 'label': '영수증 촬영', 'color': const Color(0xFF3182F6), 'bg': const Color(0xFFE8F1FF)},
      {'icon': Icons.analytics_rounded, 'label': '세무 리포트', 'color': const Color(0xFF8A2BE2), 'bg': const Color(0xFFF3EAFF)},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(actions.length, (i) {
          final a = actions[i];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                final label = a['label'] as String;
                if (label == '매출 등록') _navigateToAddPage(transactionType: 'income');
                else if (label == '지출 등록') _navigateToAddPage(transactionType: 'expense');
                else if (label == '영수증 촬영') Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraPage())).then((result) {
                  if (result is TransactionModel) _navigateToAddPage(initialData: result, isExistingRecord: false);
                  else _loadData();
                });
                else if (label == '세무 리포트') Navigator.push(context, MaterialPageRoute(builder: (_) => const TaxSummaryPage()));
              },
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A2A2A) : a['bg'] as Color,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(a['icon'] as IconData, color: isDark ? Colors.white : a['color'] as Color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    a['label'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.grey[300] : const Color(0xFF4E5968)),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap, required bool isDark}) {
    return GestureDetector(onTap: onTap, child: Column(children: [Container(width: 56, height: 56, decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A2A) : color.withAlpha(20), borderRadius: BorderRadius.circular(18)), child: Icon(icon, color: color, size: 24)), const SizedBox(height: 8), Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.grey[300] : const Color(0xFF4E5968)))]));
  }

  Widget _buildPriorityAlerts() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unpaidReceivables = _getUnpaidReceivablesList();
    final missingList = _getMissingReceiptList();
    final List<Widget> alerts = [];

    if (missingList.isNotEmpty) {
      alerts.add(_buildAlertCard(
        icon: Icons.receipt_long_rounded,
        title: '영수증 누락 ${missingList.length}건',
        subtitle: '세무 리스크를 줄이려면 빠르게 등록해주세요',
        color: const Color(0xFF3182F6),
        onTap: () async {
          final selected = await Navigator.push<TransactionModel?>(context, MaterialPageRoute(builder: (_) => MissingReceiptPage(transactions: missingList)));
          if (selected != null) _navigateToAddPage(initialData: selected, isExistingRecord: true);
        },
        isDark: isDark,
      ));
    }
    if (unpaidReceivables.isNotEmpty) {
      final total = unpaidReceivables.fold<int>(0, (s, tx) => s + tx.amount);
      alerts.add(_buildAlertCard(
        icon: Icons.pending_actions_rounded,
        title: '미수금 ${unpaidReceivables.length}건',
        subtitle: '합계 ${currencyFormat.format(total)}',
        color: const Color(0xFFFF9500),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UnpaidReceivablesPage(transactions: unpaidReceivables))),
        isDark: isDark,
      ));
    }
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, '지금 확인하세요'),
          const SizedBox(height: 12),
          ...alerts.map((w) => Padding(padding: const EdgeInsets.only(bottom: 8), child: w)),
        ],
      ),
    );
  }

  Widget _buildAlertCard({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap, required bool isDark}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        decoration: BoxDecoration(
          color: color.withAlpha(isDark ? 25 : 15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF191F28))),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : const Color(0xFF8B95A1))),
          ])),
          Icon(Icons.chevron_right_rounded, size: 20, color: color),
        ]),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recent = _getRecentTransactions();
    if (recent.isEmpty) return const SizedBox.shrink();
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _buildSectionTitle(context, '최근 거래'),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AllTransactionsPage(transactions: _transactions))),
            child: const Text('전체 보기', style: TextStyle(color: Color(0xFF3182F6), fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(isDark ? 30 : 8), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: List.generate(recent.length, (i) {
              final tx = recent[i];
              final isIncome = tx.transactionType == 'income';
              final categoryKey = (tx.category == null || tx.category!.trim().isEmpty) ? '기타' : tx.category!;
              final icon = categoryIcons[categoryKey] ?? Icons.receipt_long;
              return Column(children: [
                InkWell(
                  onTap: () => _navigateToAddPage(initialData: tx, isExistingRecord: true),
                  borderRadius: BorderRadius.vertical(
                    top: i == 0 ? const Radius.circular(20) : Radius.zero,
                    bottom: i == recent.length - 1 ? const Radius.circular(20) : Radius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: (isIncome ? const Color(0xFF2DB400) : const Color(0xFFFF4D4F)).withAlpha(isDark ? 40 : 15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, size: 20, color: isIncome ? const Color(0xFF2DB400) : const Color(0xFFFF4D4F)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(tx.storeName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF191F28))),
                        const SizedBox(height: 2),
                        Text(tx.category ?? '기타', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : const Color(0xFF8B95A1))),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(
                          '${isIncome ? "+" : "-"}${currencyFormat.format(tx.amount)}',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isIncome ? const Color(0xFF2DB400) : const Color(0xFFFF4D4F)),
                        ),
                        const SizedBox(height: 2),
                        Text(DateFormat('M/d').format(tx.date), style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[500] : const Color(0xFF8B95A1))),
                      ]),
                    ]),
                  ),
                ),
                if (i < recent.length - 1) Divider(height: 1, indent: 20, endIndent: 20, color: isDark ? Colors.white10 : Colors.grey.shade100),
              ]);
            }),
          ),
        ),
      ]),
    );
  }

  Widget _buildHelpSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildSectionTitle(context, '더 알아보기'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(isDark ? 30 : 8), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: Column(children: [
            _helpRow(icon: Icons.lightbulb_outline_rounded, iconColor: const Color(0xFFFF9500), label: '사장님 절세 족보', isDark: isDark,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TaxTipsPage()))),
            Divider(height: 1, indent: 20, endIndent: 20, color: isDark ? Colors.white10 : Colors.grey.shade100),
            _helpRow(icon: Icons.share_rounded, iconColor: const Color(0xFF2DB400), label: '회계사에게 자료 공유', isDark: isDark,
              onTap: () async {
                if (_transactions.isEmpty) { _showSnackBar("내보낼 데이터가 없습니다."); return; }
                await ExcelService().exportForAccounting(_transactions);
                _showSnackBar("회계사용 엑셀 파일이 생성되었습니다.");
              }),
            Divider(height: 1, indent: 20, endIndent: 20, color: isDark ? Colors.white10 : Colors.grey.shade100),
            _helpRow(icon: Icons.credit_card_rounded, iconColor: const Color(0xFF3182F6), label: '카드 관리', isDark: isDark,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CardListPage()))),
          ]),
        ),
      ]),
    );
  }

  Widget _helpRow({required IconData icon, required Color iconColor, required String label, required bool isDark, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: iconColor.withAlpha(isDark ? 40 : 20), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 18)),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : const Color(0xFF191F28)))),
          Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey[400]),
        ]),
      ),
    );
  }

  Widget _buildHeroCard() {
    final f = _getMonthlyForecast();
    final user = Supabase.instance.client.auth.currentUser;
    final name = (user?.userMetadata?['name'] as String?) ?? '사장님';
    final net = f['forecastNet'] ?? 0;
    final income = f['forecastIncome'] ?? 0;
    final expense = f['forecastExpense'] ?? 0;
    final isProfit = net >= 0;
    final now = DateTime.now();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0E1726), Color(0xFF1A3550), Color(0xFF1B4F72)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${now.month}월 예상 순이익',
                style: TextStyle(fontSize: 13, color: Colors.white.withAlpha(160), fontWeight: FontWeight.w500),
              ),
              Text(
                '$name 님',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            currencyFormat.format(net.abs()),
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isProfit ? Colors.green.withAlpha(50) : Colors.redAccent.withAlpha(50),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isProfit ? '▲ 흑자 예상' : '▼ 적자 예상',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isProfit ? const Color(0xFF2DB400) : Colors.redAccent[100],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.white.withAlpha(30)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF2DB400), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('예상 매출', style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(150))),
                    ]),
                    const SizedBox(height: 4),
                    Text(currencyFormat.format(income),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
              Container(width: 1, height: 36, color: Colors.white.withAlpha(30)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFFF4D4F), shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text('예상 지출', style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(150))),
                      ]),
                      const SizedBox(height: 4),
                      Text(currencyFormat.format(expense),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _transactionType = 'expense'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: _transactionType == 'expense'
                      ? Colors.red.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _transactionType == 'expense'
                        ? Colors.red
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      color: _transactionType == 'expense'
                          ? Colors.red
                          : Colors.grey,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "지출",
                      style: TextStyle(
                        fontWeight: _transactionType == 'expense'
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 17,
                        color: _transactionType == 'expense'
                            ? Colors.red
                            : Colors.grey,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _transactionType = 'income'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: _transactionType == 'income'
                      ? Colors.green.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _transactionType == 'income'
                        ? Colors.green
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.arrow_downward,
                      color: _transactionType == 'income'
                          ? Colors.green
                          : Colors.grey,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "수입",
                      style: TextStyle(
                        fontWeight: _transactionType == 'income'
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 17,
                        color: _transactionType == 'income'
                            ? Colors.green
                            : Colors.grey,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.zero,
      child: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF191F28), letterSpacing: -0.3)),
    );
  }

  Widget _buildCycleToggle() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _cycle = 'monthly'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _cycle == 'monthly'
                    ? Colors.deepPurple.withOpacity(0.15)
                    : Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  "매월",
                  style: TextStyle(
                    fontWeight: _cycle == 'monthly'
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 15,
                    color: _cycle == 'monthly'
                        ? Colors.deepPurple
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _cycle = 'weekly'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _cycle == 'weekly'
                    ? Colors.deepPurple.withOpacity(0.15)
                    : Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  "매주",
                  style: TextStyle(
                    fontWeight: _cycle == 'weekly'
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 15,
                    color: _cycle == 'weekly'
                        ? Colors.deepPurple
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildSearchResults() {
    final keyword = _searchController.text.trim().toLowerCase();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final results = _transactions.where((tx) {
      return tx.storeName.toLowerCase().contains(keyword) ||
          (tx.memo ?? '').toLowerCase().contains(keyword) ||
          (tx.category ?? '').toLowerCase().contains(keyword) ||
          tx.method.toLowerCase().contains(keyword) ||
          tx.amount.toString().contains(keyword);
    }).toList();

    if (results.isEmpty) {
      return const Center(
        child: Text('검색 결과가 없습니다.', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final tx = results[index];
        final categoryKey = (tx.category == null || tx.category!.trim().isEmpty)
            ? '기타'
            : tx.category!;
        final icon = categoryIcons[categoryKey] ?? Icons.receipt_long;
        return TransactionListItem(
          tx: tx,
          isDark: isDark,
          leadingIcon: icon,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddTransactionPage(
                  initialData: tx,
                  isExistingRecord: true,
                ),
              ),
            );
            if (result == true) {
              await _loadData();
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F6F8),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F6F8),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: '상호, 메모, 금액 검색...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                  border: InputBorder.none,
                ),
              )
            : const Text(
                'BizExpense',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded, size: 24),
            onPressed: () => setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) _searchController.clear();
            }),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : (_isSearching && _searchController.text.trim().isNotEmpty)
              ? _buildSearchResults()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: const Color(0xFF3182F6),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        _buildHeroCard(),
                        const SizedBox(height: 20),
                        _buildPrimaryActions(),
                        const SizedBox(height: 24),
                        _buildPriorityAlerts(),
                        const UpcomingTaxBanner(),
                        const SizedBox(height: 24),
                        _buildKPISection(),
                        const SizedBox(height: 24),
                        _buildRecentActivity(),
                        const SizedBox(height: 24),
                        _buildHelpSection(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: _isSearching
          ? null
          : FloatingActionButton(
              heroTag: 'add_expense',
              onPressed: () => _navigateToAddPage(),
              backgroundColor: const Color(0xFF3182F6),
              elevation: 4,
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
    );
  }
}

class _KpiItem {
final String title;
final int value;
final IconData icon;
final Color color;
final String? subtitle;
final VoidCallback? onTap;

  _KpiItem({
  required this.title,
  required this.value,
  required this.icon,
  required this.color,
  this.subtitle,
  this.onTap,
  });
}
