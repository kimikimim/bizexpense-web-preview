import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../transactions/data/transaction_model.dart';

class UnpaidReceivablesPage extends StatefulWidget {
  final List<TransactionModel> transactions;

  const UnpaidReceivablesPage({
    super.key,
    required this.transactions,
  });

  @override
  State<UnpaidReceivablesPage> createState() => _UnpaidReceivablesPageState();
}

class _UnpaidReceivablesPageState extends State<UnpaidReceivablesPage> {
  late List<TransactionModel> _transactions;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _transactions = List.from(widget.transactions);
  }

  Future<void> _markAsPaid(TransactionModel tx) async {
    try {
      await _supabase
          .from('transactions')
          .update({'is_paid': true})
          .eq('id', tx.id);

      setState(() {
        _transactions.removeWhere((t) => t.id == tx.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${tx.storeName} 정산 완료로 표시했습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('정산 처리 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _showActionSheet(TransactionModel tx) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle_outline, color: Colors.green),
              title: const Text('정산 완료로 표시'),
              onTap: () {
                Navigator.pop(context);
                _markAsPaid(tx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('상세 / 수정'),
              onTap: () {
                Navigator.pop(context, tx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close, color: Colors.red),
              title: const Text('취소'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
    final total = _transactions.fold<int>(0, (sum, tx) => sum + tx.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('미수금 관리'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.black.withOpacity(0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '미수금 합계',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  currency.format(total),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_transactions.length}건의 미수금이 있습니다.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          Expanded(
            child: _transactions.isEmpty
                ? const Center(
                    child: Text(
                      '미수금이 없습니다.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    itemCount: _transactions.length,
                    separatorBuilder: (_, __) => const Divider(height: 0),
                    itemBuilder: (context, index) {
                      final tx = _transactions[index];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.orange.withOpacity(0.12),
                          child: const Icon(
                            Icons.pending_actions,
                            color: Colors.orange,
                            size: 20,
                          ),
                        ),
                        title: Text(tx.storeName),
                        subtitle: Text(
                          DateFormat('yyyy-MM-dd').format(tx.date),
                        ),
                        trailing: Text(
                          currency.format(tx.amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () => _showActionSheet(tx),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
