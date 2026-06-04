import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:expense_pro/l10n/app_localizations.dart';

import '../../transactions/data/transaction_model.dart';
import '../../transactions/data/transaction_repository.dart';
import '../../../core/providers/country_config_provider.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage>
    with SingleTickerProviderStateMixin {
  final TransactionRepository _repo = TransactionRepository();
  late NumberFormat _currency;

  bool _isLoading = true;
  late TabController _tabController;
  List<TransactionModel> _allTransactions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final config = ref.read(countryConfigProvider);
    _currency = NumberFormat.currency(
      locale: config.currencyLocale,
      symbol: config.currencySymbol,
    );
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final tx = await _repo.getTransactions();
    if (!mounted) return;
    setState(() {
      _allTransactions = tx;
      _isLoading = false;
    });
  }

  List<TransactionModel> get _currentMonthTx {
    final now = DateTime.now();
    return _allTransactions
        .where((t) =>
            t.date.year == now.year && t.date.month == now.month)
        .toList();
  }

  int _sumAmount(Iterable<TransactionModel> txs) =>
      txs.fold(0, (s, t) => s + t.amount);

  bool _isDeductible(TransactionModel tx) {
    if (tx.transactionType != 'expense') return false;

    final config = ref.read(countryConfigProvider);
    final category = tx.category ?? '';
    for (final k in config.nonDeductibleCategories) {
      if (category.contains(k)) return false;
    }

    if (tx.isVatExempt == true) return false;

    return true;
  }

  bool _hasReceipt(TransactionModel tx) {
    return tx.receiptUrl != null && tx.receiptUrl!.isNotEmpty;
  }

  TaxMetrics _buildTaxMetrics() {
    final month = _currentMonthTx;
    final income =
        month.where((t) => t.transactionType == 'income').toList();
    final expense =
        month.where((t) => t.transactionType == 'expense').toList();

    final totalIncome = _sumAmount(income);
    final totalExpense = _sumAmount(expense);

    final deductible = expense.where(_isDeductible).toList();
    final nonDeductible =
        expense.where((t) => !_isDeductible(t)).toList();

    final deductibleSum = _sumAmount(deductible);
    final nonDeductibleSum = _sumAmount(nonDeductible);
    final deductibleRatio =
        totalExpense == 0 ? 0.0 : deductibleSum / totalExpense;

    final expenseWithReceipt =
        expense.where(_hasReceipt).toList();
    final receiptCoverage =
        expense.isEmpty ? 0.0 : expenseWithReceipt.length / expense.length;

    final bigNoReceipt = expense
        .where((t) => t.amount >= 100000 && !_hasReceipt(t))
        .toList();
    final bigNoReceiptSum = _sumAmount(bigNoReceipt);

    final uncategorized = AppLocalizations.of(context)!.addTransactionUncategorized;
    final Map<String, int> nonDeductibleByCat = {};
    for (final t in nonDeductible) {
      final key = t.category ?? uncategorized;
      nonDeductibleByCat[key] =
          (nonDeductibleByCat[key] ?? 0) + t.amount;
    }

    final topRisk = nonDeductibleByCat.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3 = topRisk.take(3).toList();

    double score = 80;

    score += (deductibleRatio - 0.7) * 40; 
    
    score += (receiptCoverage - 0.8) * 40; 
    
    score -= (bigNoReceiptSum / 1000000) * 5; 

    if (score > 100) score = 100;
    if (score < 0) score = 0;

    late String grade;
    late String comment;
    if (score >= 85) {
      grade = 'safe';
      comment = '';
    } else if (score >= 60) {
      grade = 'normal';
      comment = '';
    } else {
      grade = 'warning';
      comment = '';
    }

    return TaxMetrics(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      deductibleExpense: deductibleSum,
      nonDeductibleExpense: nonDeductibleSum,
      deductibleRatio: deductibleRatio,
      receiptCoverage: receiptCoverage,
      bigNoReceiptCount: bigNoReceipt.length,
      bigNoReceiptAmount: bigNoReceiptSum,
      nonDeductibleByCategory: nonDeductibleByCat,
      taxScore: score,
      taxGrade: grade,
      taxComment: comment,
      topRiskCategories: top3,
    );
  }

  List<CategorySlice> _buildCategorySlices() {
    final expense = _currentMonthTx
        .where((t) => t.transactionType == 'expense')
        .toList();
    final total = _sumAmount(expense);
    if (total == 0) return [];

    final uncategorized = AppLocalizations.of(context)!.addTransactionUncategorized;
    final Map<String, int> byCat = {};
    for (final t in expense) {
      final key = t.category ?? uncategorized;
      byCat[key] = (byCat[key] ?? 0) + t.amount;
    }

    final entries = byCat.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries
        .map(
          (e) => CategorySlice(
            name: e.key,
            amount: e.value,
            percent: e.value / total,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.statisticsTitle),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: l10n.statisticsTaxReportTab),
              Tab(text: l10n.statisticsExpenseTab),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTaxTab(context, l10n),
                    _buildCategoryTab(context, isDark: isDark, l10n: l10n),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTaxTab(BuildContext context, AppLocalizations l10n) {
    final metrics = _buildTaxMetrics();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _TaxScoreCard(metrics: metrics, currency: _currency, l10n: l10n),
        const SizedBox(height: 16),
        _DeductionSection(metrics: metrics, currency: _currency, l10n: l10n),
        const SizedBox(height: 16),
        _ReceiptSection(metrics: metrics, currency: _currency, l10n: l10n),
      ],
    );
  }

  Widget _buildCategoryTab(BuildContext context,
      {required bool isDark, required AppLocalizations l10n}) {
    final slices = _buildCategorySlices();
    final totalExpense = _sumAmount(
      _currentMonthTx
          .where((t) => t.transactionType == 'expense'),
    );

    if (slices.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          Center(child: Text(l10n.statisticsNoExpenseThisMonth)),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: SizedBox(
            width: 220,
            height: 220,
            child: _DonutChart(slices: slices, isDark: isDark),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            l10n.statisticsTotalExpense(_currency.format(totalExpense)),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ...slices
            .map((s) => _CategoryRow(slice: s, currency: _currency))
            .toList(),
      ],
    );
  }
}

class TaxMetrics {
  final int totalIncome;
  final int totalExpense;
  final int deductibleExpense;
  final int nonDeductibleExpense;
  final double deductibleRatio;
  final double receiptCoverage;
  final int bigNoReceiptCount;
  final int bigNoReceiptAmount;
  final Map<String, int> nonDeductibleByCategory;
  final double taxScore;
  final String taxGrade;
  final String taxComment;
  final List<MapEntry<String, int>> topRiskCategories;

  TaxMetrics({
    required this.totalIncome,
    required this.totalExpense,
    required this.deductibleExpense,
    required this.nonDeductibleExpense,
    required this.deductibleRatio,
    required this.receiptCoverage,
    required this.bigNoReceiptCount,
    required this.bigNoReceiptAmount,
    required this.nonDeductibleByCategory,
    required this.taxScore,
    required this.taxGrade,
    required this.taxComment,
    required this.topRiskCategories,
  });
}

class CategorySlice {
  final String name;
  final int amount;
  final double percent;

  CategorySlice({
    required this.name,
    required this.amount,
    required this.percent,
  });
}

class _TaxScoreCard extends StatelessWidget {
  final TaxMetrics metrics;
  final NumberFormat currency;
  final AppLocalizations l10n;

  const _TaxScoreCard({
    required this.metrics,
    required this.currency,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final score = metrics.taxScore;

    Color color;
    if (score >= 85) {
      color = Colors.green;
    } else if (score >= 60) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.statisticsThisMonthTaxScore,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  l10n.statisticsScorePoints(score.toStringAsFixed(0)),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: score / 100,
              minHeight: 8,
              backgroundColor:
                  isDark ? Colors.grey[800] : Colors.grey[300],
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.shield, size: 18, color: color),
                const SizedBox(width: 6),
                Text(
                  '${_resolveGrade(metrics.taxGrade, l10n)} · ${_resolveComment(metrics.taxGrade, l10n)}',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _smallBadge(
                  l10n.statisticsDeductibleRatio,
                  '${(metrics.deductibleRatio * 100).toStringAsFixed(1)}%',
                ),
                _smallBadge(
                  l10n.statisticsReceiptCoverage,
                  '${(metrics.receiptCoverage * 100).toStringAsFixed(1)}%',
                ),
                if (metrics.bigNoReceiptCount > 0)
                  _smallBadge(
                    l10n.statisticsBigNoReceipt,
                    '${metrics.bigNoReceiptCount} / ${currency.format(metrics.bigNoReceiptAmount)}',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _resolveGrade(String grade, AppLocalizations l10n) {
    switch (grade) {
      case 'safe': return l10n.statisticsTaxSafe;
      case 'normal': return l10n.statisticsTaxNormal;
      default: return l10n.statisticsTaxWarning;
    }
  }

  String _resolveComment(String grade, AppLocalizations l10n) {
    switch (grade) {
      case 'safe': return l10n.statisticsTaxSafeComment;
      case 'normal': return l10n.statisticsTaxNormalComment;
      default: return l10n.statisticsTaxWarningComment;
    }
  }

  Widget _smallBadge(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _DeductionSection extends StatelessWidget {
  final TaxMetrics metrics;
  final NumberFormat currency;
  final AppLocalizations l10n;

  const _DeductionSection({
    required this.metrics,
    required this.currency,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final deductible = metrics.deductibleExpense;
    final nonDeductible = metrics.nonDeductibleExpense;
    final total = deductible + nonDeductible;
    final percent =
        total == 0 ? 0.0 : deductible / total;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.statisticsDeductibleSection,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.statisticsDeductible,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currency.format(deductible),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.statisticsNonDeductible,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currency.format(nonDeductible),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              backgroundColor: Colors.red.withOpacity(0.15),
              color: Colors.green,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.statisticsDeductiblePercent((percent * 100).toStringAsFixed(1)),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            if (metrics.topRiskCategories.isNotEmpty) ...[
              Text(
                l10n.statisticsTopRiskCategories,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...metrics.topRiskCategories.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          e.key,
                          style:
                              const TextStyle(fontSize: 12),
                        ),
                      ),
                      Text(
                        currency.format(e.value),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReceiptSection extends StatelessWidget {
  final TaxMetrics metrics;
  final NumberFormat currency;
  final AppLocalizations l10n;

  const _ReceiptSection({
    required this.metrics,
    required this.currency,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final coverage = metrics.receiptCoverage;
    final coveragePct =
        (coverage * 100).toStringAsFixed(1);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              l10n.statisticsReceiptSection,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: coverage,
                        strokeWidth: 6,
                        backgroundColor:
                            Colors.grey[300],
                        color: Colors.blue,
                      ),
                      Text(
                        '$coveragePct%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$coveragePct% ${l10n.statisticsReceiptCoverage}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      if (metrics.bigNoReceiptCount > 0)
                        Text(
                          l10n.taxReportMissingReceipts(metrics.bigNoReceiptCount.toString()),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.red,
                              ),
                        )
                      else
                        Text(
                          l10n.taxReportAllReceiptsRegistered,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.green,
                              ),
                        )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutChart extends StatelessWidget {
  final List<CategorySlice> slices;
  final bool isDark;

  const _DonutChart({
    required this.slices,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter:
          _DonutPainter(slices: slices, isDark: isDark),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<CategorySlice> slices;
  final bool isDark;

  _DonutPainter({
    required this.slices,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2;
    final innerRadius = radius * 0.6;

    var startAngle =
        -90.0 * 3.1415926535 / 180.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius - innerRadius;

    final colors = <Color>[
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
    ];

    for (var i = 0; i < slices.length; i++) {
      final s = slices[i];
      final sweep =
          2 * 3.1415926535 * s.percent;

      paint.color =
          colors[i % colors.length];

      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: (radius + innerRadius) / 2,
        ),
        startAngle,
        sweep,
        false,
        paint,
      );

      startAngle += sweep;
    }

    final innerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isDark ? Colors.black : Colors.white;

    canvas.drawCircle(center, innerRadius, innerPaint);
  }

  @override
  bool shouldRepaint(
      covariant _DonutPainter oldDelegate) {
    return oldDelegate.slices != slices ||
        oldDelegate.isDark != isDark;
  }
}

class _CategoryRow extends StatelessWidget {
  final CategorySlice slice;
  final NumberFormat currency;

  const _CategoryRow({
    required this.slice,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final pct =
        (slice.percent * 100).toStringAsFixed(1);

    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              slice.name,
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
          ),
          Text(
            '$pct%',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            currency.format(slice.amount),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
