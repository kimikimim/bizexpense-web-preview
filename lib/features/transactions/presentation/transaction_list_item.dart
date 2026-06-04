import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:expense_pro/l10n/app_localizations.dart';

import '../data/transaction_model.dart';
import '../../../core/providers/country_config_provider.dart';

class TransactionListItem extends ConsumerWidget {
  final TransactionModel tx;
  final bool isDark;
  final IconData leadingIcon;
  final VoidCallback onTap;

  TransactionListItem({
    super.key,
    required this.tx,
    required this.isDark,
    required this.leadingIcon,
    required this.onTap,
  });

  final _timeFormat = DateFormat('MM-dd HH:mm');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final config = ref.watch(countryConfigProvider);
    final isIncome = tx.transactionType == 'income';
    final amountText =
        (isIncome ? '+' : '-') + config.formatMoney(tx.amount);

    final amountColor = isIncome ? Colors.red : Colors.blue;

    return Container(
      
      color: isDark ? Colors.black : Colors.white,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 22,
          backgroundColor:
              isDark ? Colors.grey[800] : Colors.grey[200],
          child: Icon(
            leadingIcon,
            size: 20,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        title: Text(
          tx.storeName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          "${tx.category ?? l10n.addTransactionUncategorized} • ${_timeFormat.format(tx.date)}",
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amountText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: amountColor, 
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isIncome ? l10n.txDeposit : l10n.txWithdrawal,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white54 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
