
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  int _getMonthlyExpense() {
    final now = DateTime.now();
    return _transactions
        .where((tx) =>
            tx.transactionType == 'expense' &&
            tx.date.year == now.year &&
            tx.date.month == now.month)
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  List<TransactionModel> _getRecentTransactions() {
    final sorted = List<TransactionModel>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(3).toList();
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
) {
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
) {
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
) {
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
) {
    return GestureDetector(onTap: onTap, child: Column(children: [Container(width: 56, height: 56, decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A2A) : color.withAlpha(20), borderRadius: BorderRadius.circular(18)), child: Icon(icon, color: color, size: 24)), const SizedBox(height: 8), Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.grey[300] : const Color(0xFF4E5968)))]));
  }
) {
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
) {
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
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.zero,
      child: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF191F28), letterSpacing: -0.3)),
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
                        _buildRecentActivity(),
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
);
}
