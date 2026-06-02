import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/recurring_transaction_model.dart';
import '../data/recurring_transaction_repository.dart';
import 'add_recurring_transaction_page.dart';

class RecurringTransactionsPage extends StatefulWidget {
  const RecurringTransactionsPage({super.key});

  @override
  State<RecurringTransactionsPage> createState() => _RecurringTransactionsPageState();
}

class _RecurringTransactionsPageState extends State<RecurringTransactionsPage> {
  final RecurringTransactionRepository _repository = RecurringTransactionRepository();
  final _currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

  bool _isLoading = true;
  List<RecurringTransactionModel> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final data = await _repository.getMyRecurring();
    if (!mounted) return;
    setState(() {
      _items = data;
      _isLoading = false;
    });
  }

  Future<void> _openAddPage({RecurringTransactionModel? initial}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddRecurringTransactionPage(
          initialData: initial,
        ),
      ),
    );

    if (result == true) {
      _load();
    }
  }

  Future<void> _deleteItem(RecurringTransactionModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제하시겠습니까?'),
        content: Text('「${item.title}」 정기 거래를 삭제합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final ok = await _repository.deleteRecurring(item.id);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제되었습니다.')),
      );
      _load();
    }
  }

  String _buildCycleLabel(RecurringTransactionModel r) {
    if (r.cycle == 'monthly') {
      return '매월 ${r.day}일';
    } else if (r.cycle == 'weekly') {
      const weekdayNames = ['월', '화', '수', '목', '금', '토', '일'];
      final index = (r.day - 1).clamp(0, 6);
      return '매주 ${weekdayNames[index]}요일';
    }
    return '';
  }

  Color _typeColor(String type) {
    return type == 'income' ? Colors.green : Colors.red;
  }

  IconData _typeIcon(String type) {
    return type == 'income' ? Icons.arrow_downward : Icons.arrow_upward;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: const Text('정기 거래 관리'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _items.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 80),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.repeat, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text(
                                '등록된 정기 지출/수입이 없습니다.',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '월세, 인건비, 광고비 등을 등록해두면\n매달 자동으로 내역이 생성돼요.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[500], fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final r = _items[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _typeColor(r.transactionType).withOpacity(0.1),
                            child: Icon(
                              _typeIcon(r.transactionType),
                              color: _typeColor(r.transactionType),
                            ),
                          ),
                          title: Text(
                            r.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 2),
                              Text(
                                '${_buildCycleLabel(r)} • ${_currencyFormat.format(r.amount)}',
                                style: TextStyle(
                                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                                  fontSize: 13,
                                ),
                              ),
                              if (r.title.isNotEmpty)
                                Text(
                                  r.title,
                                  style: TextStyle(
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _openAddPage(initial: r),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                onPressed: () => _deleteItem(r),
                              ),
                            ],
                          ),
                          onTap: () => _openAddPage(initial: r),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddPage(),
        label: const Text('정기 거래 추가'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
