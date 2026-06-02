import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_pro/l10n/app_localizations.dart';

import '../../transactions/data/transaction_model.dart';
import '../../transactions/data/transaction_repository.dart';

class TaxSummaryPage extends StatefulWidget {
  const TaxSummaryPage({super.key});

  @override
  State<TaxSummaryPage> createState() => _TaxSummaryPageState();
}

class _TaxSummaryPageState extends State<TaxSummaryPage> {
  final _repo = TransactionRepository();
  final _currency = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

  bool _isLoading = true;
  List<TransactionModel> _transactions = [];

  int _quarterVatNet = 0;            
  int _deductibleAmount = 0;        
  int _nonDeductibleAmount = 0;     
  int _missingReceiptCount = 0;     
  int _missingReceiptAmount = 0;    

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _repo.getTransactions();
    _calculateStats(data);

    if (!mounted) return;
    setState(() {
      _transactions = data;
      _isLoading = false;
    });
  }

  static const _nonDeductibleCategories = [
    '접대',
    '개인',
    '의류',
  ];

  bool _isDeductible(TransactionModel tx) {
    if (tx.transactionType != 'expense') return false;

    final category = (tx.category ?? '').trim();
    for (final blocked in _nonDeductibleCategories) {
      if (category.contains(blocked)) return false;
    }
    return true;
  }

  bool _needsReceipt(TransactionModel tx) {
    if (tx.transactionType != 'expense') return false;

    final methodRaw = tx.method ?? '';
    final baseMethod =
        methodRaw.contains('(') ? methodRaw.split('(').first : methodRaw;

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

    return tx.amount >= 100000;
  }

  void _calculateStats(List<TransactionModel> txs) {
    if (txs.isEmpty) {
      _quarterVatNet = 0;
      _deductibleAmount = 0;
      _nonDeductibleAmount = 0;
      _missingReceiptCount = 0;
      _missingReceiptAmount = 0;
      return;
    }

    final now = DateTime.now();

    final quarterIndex = ((now.month - 1) / 3).floor(); 
    final startMonth = quarterIndex * 3 + 1;            
    final quarterStart = DateTime(now.year, startMonth, 1);
    final quarterEnd = DateTime(now.year, startMonth + 3, 1); 

    int salesTotal = 0;
    int purchaseTotal = 0;

    for (final tx in txs) {
      final d = tx.date;
      if (d.isBefore(quarterStart) || !d.isBefore(quarterEnd)) continue;

      if (tx.transactionType == 'income') {
        salesTotal += tx.amount;
      } else if (tx.transactionType == 'expense') {
        if (_isDeductible(tx)) {
          purchaseTotal += tx.amount;
        }
      }
    }

    final salesVat = (salesTotal * 0.1).round();
    final purchaseVat = (purchaseTotal * 0.1).round();
    _quarterVatNet = purchaseVat - salesVat;

    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1);

    int deductible = 0;
    int nonDeductible = 0;

    for (final tx in txs) {
      if (tx.transactionType != 'expense') continue;

      final d = tx.date;
      if (d.isBefore(monthStart) || !d.isBefore(monthEnd)) continue;

      if (_isDeductible(tx)) {
        deductible += tx.amount;
      } else {
        nonDeductible += tx.amount;
      }
    }

    _deductibleAmount = deductible;
    _nonDeductibleAmount = nonDeductible;

    int missingCount = 0;
    int missingAmount = 0;

    for (final tx in txs) {
      if (!_needsReceipt(tx)) continue;

      final d = tx.date;
      if (d.isBefore(monthStart) || !d.isBefore(monthEnd)) continue;

      final hasReceipt =
          tx.receiptUrl != null && tx.receiptUrl!.isNotEmpty;

      if (!hasReceipt) {
        missingCount += 1;
        missingAmount += tx.amount;
      }
    }

    _missingReceiptCount = missingCount;
    _missingReceiptAmount = missingAmount;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final vatTitle = _quarterVatNet >= 0
        ? l10n.taxReportVatRefundEstimate
        : l10n.taxReportVatPaymentEstimate;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.taxReportTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.teal[900]
                          : const Color(0xFFE6F5F3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vatTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currency.format(_quarterVatNet.abs()),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.taxReportEstimateNote,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? Colors.grey[300]
                                : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    l10n.taxReportMonthlyExpenseBreakdown,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[900]
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildRow(
                          label: l10n.taxReportDeductibleExpense,
                          amount: _deductibleAmount,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 8),
                        _buildRow(
                          label: l10n.taxReportNonDeductibleExpense,
                          amount: _nonDeductibleAmount,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 8),
                        Divider(
                          color: isDark
                              ? Colors.grey[700]
                              : Colors.grey[300],
                        ),
                        const SizedBox(height: 8),
                        _buildRatioRow(l10n),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    l10n.taxReportReceiptStatus,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[900]
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                _missingReceiptCount == 0
                                    ? l10n.taxReportAllReceiptsRegistered
                                    : l10n.taxReportMissingReceipts(_missingReceiptCount.toString()),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (_missingReceiptCount > 0)
                                Text(
                                  l10n.taxReportMissingAmount(_currency.format(_missingReceiptAmount)),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.redAccent,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRow({
    required String label,
    required int amount,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          _currency.format(amount),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRatioRow(AppLocalizations l10n) {
    final total = _deductibleAmount + _nonDeductibleAmount;
    if (total == 0) {
      return Text(
        l10n.taxReportNoDataYet,
        style: const TextStyle(fontSize: 12),
      );
    }

    final nonDeductibleRatio =
        (_nonDeductibleAmount / total * 100).round();

    String comment;
    if (nonDeductibleRatio <= 20) {
      comment = l10n.taxReportNonDeductibleLow;
    } else if (nonDeductibleRatio <= 40) {
      comment = l10n.taxReportNonDeductibleMedium;
    } else {
      comment = l10n.taxReportNonDeductibleHigh;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.taxReportNonDeductibleRatio(nonDeductibleRatio.toString()),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          comment,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
