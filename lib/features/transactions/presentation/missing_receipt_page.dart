import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/transaction_model.dart';
import '../presentation/transaction_list_item.dart';
import '../../../core/constants/category_icons.dart';

class MissingReceiptPage extends StatelessWidget {
  final List<TransactionModel> transactions;

  const MissingReceiptPage({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sorted = List<TransactionModel>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text("영수증 누락 내역"),
      ),
      body: sorted.isEmpty
          ? Center(
              child: Text(
                "영수증이 누락된 항목이 없습니다.",
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                _buildHeader(context, sorted.length),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: sorted.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final tx = sorted[index];

                      final String categoryKey =
                          (tx.category == null || tx.category!.trim().isEmpty)
                              ? '기타'
                              : tx.category!;
                      final icon =
                          categoryIcons[categoryKey] ?? Icons.receipt_long;

                      return TransactionListItem(
                        tx: tx,
                        isDark: isDark,
                        leadingIcon: icon,
                        onTap: () {
                          
                          Navigator.pop(context, tx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.blueGrey[900] : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.receipt_long,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "영수증 누락 ${count}건",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "각 항목을 눌러 영수증 사진을 등록하거나 내용을 수정해주세요.",
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
