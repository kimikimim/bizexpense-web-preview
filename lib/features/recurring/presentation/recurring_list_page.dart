import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:expense_pro/l10n/app_localizations.dart';

import '../../../core/providers/country_config_provider.dart';
import '../data/recurring_transaction_model.dart';
import '../data/recurring_transaction_repository.dart';
import 'edit_recurring_page.dart';

class RecurringListPage extends ConsumerStatefulWidget {
  const RecurringListPage({super.key});

  @override
  ConsumerState<RecurringListPage> createState() => _RecurringListPageState();
}

class _RecurringListPageState extends ConsumerState<RecurringListPage> {
  final _repo = RecurringTransactionRepository();

  bool _isLoading = true;
  List<RecurringTransactionModel> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final list = await _repo.getMyRecurring();
    if (!mounted) return;
    setState(() {
      _items = list;
      _isLoading = false;
    });
  }

  String _buildCycleText(RecurringTransactionModel r, AppLocalizations l10n) {
    if (r.cycle == 'monthly') {
      return l10n.recurringMonthlyDay('${r.day}');
    } else {
      final localeName = Localizations.localeOf(context).toString();
      final day = (r.day >= 1 && r.day <= 7) ? r.day : 1;
      // 2024-01-01 is a Monday → 1..7 maps Mon..Sun
      final weekday =
          DateFormat.EEEE(localeName).format(DateTime(2024, 1, day));
      return l10n.recurringWeeklyDay(weekday);
    }
  }

  Color _typeColor(String type) {
    
    if (type == 'income') return Colors.green;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = ref.watch(countryConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recurringListTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Text(
                    '${l10n.recurringListEmpty}\n\n${l10n.recurringListEmptySub}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 12, 16, 80),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final r = _items[index];
                      final c = _typeColor(r.transactionType);
                      final bool isActive = r.isActive; 

                      return Opacity(
                        opacity: isActive ? 1.0 : 0.55, 
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: c.withOpacity(0.12),
                              child: Icon(
                                
                                r.transactionType == 'income'
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: c,
                              ),
                            ),
                            title: Text(
                              r.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  '${_buildCycleText(r, l10n)} · ${config.formatMoney(r.amount)}',
                                ),
                                if (r.category != null)
                                  Text(
                                    r.category!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                if (!isActive)  
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: (isDark
                                                ? Colors.grey[800]
                                                : Colors.grey[100])
                                            ?.withOpacity(0.9),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.5),
                                        ),
                                      ),
                                      child: Text(
                                        l10n.recurringAutoOff,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              size: 20,
                            ),
                            onTap: () async {
                              final updated =
                                  await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditRecurringPage(initial: r),
                                ),
                              );
                              if (updated == true) _load();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const EditRecurringPage(),
            ),
          );
          if (created == true) _load();
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.recurringAddTitle),
      ),
    );
  }
}
