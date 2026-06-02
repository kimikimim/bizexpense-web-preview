import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/primary_button.dart';
import 'package:expense_pro/l10n/app_localizations.dart';

import '../../transactions/data/transaction_model.dart';
import '../../transactions/data/transaction_repository.dart';
import '../../../core/constants/category_icons.dart';
import 'add_transaction_page.dart';
import 'transaction_list_item.dart';

enum SortOption {
  latest,      
  oldest,      
  amountDesc,  
  amountAsc,   
}

enum TransactionTypeFilter { all, income, expense }

enum PeriodPreset { all, thisMonth, lastMonth, threeMonths, custom }

class TransactionFilter {
  final PeriodPreset periodPreset;
  final DateTimeRange? customRange;
  final TransactionTypeFilter typeFilter;
  final Set<String> methods;
  final Set<String> categories;
  final bool onlyNoReceipt;
  final bool onlyTaxDeductible;
  final SortOption sortOption;

  const TransactionFilter({
    required this.periodPreset,
    required this.customRange,
    required this.typeFilter,
    required this.methods,
    required this.categories,
    required this.onlyNoReceipt,
    required this.onlyTaxDeductible,
    required this.sortOption,
  });

  factory TransactionFilter.initial() => TransactionFilter(
        periodPreset: PeriodPreset.all,
        customRange: null,
        typeFilter: TransactionTypeFilter.all,
        methods: <String>{},
        categories: <String>{},
        onlyNoReceipt: false,
        onlyTaxDeductible: false,
        sortOption: SortOption.latest,
      );

  TransactionFilter copyWith({
    PeriodPreset? periodPreset,
    DateTimeRange? customRange,
    TransactionTypeFilter? typeFilter,
    Set<String>? methods,
    Set<String>? categories,
    bool? onlyNoReceipt,
    bool? onlyTaxDeductible,
    SortOption? sortOption,
  }) {
    return TransactionFilter(
      periodPreset: periodPreset ?? this.periodPreset,
      customRange: customRange ?? this.customRange,
      typeFilter: typeFilter ?? this.typeFilter,
      methods: methods ?? this.methods,
      categories: categories ?? this.categories,
      onlyNoReceipt: onlyNoReceipt ?? this.onlyNoReceipt,
      onlyTaxDeductible: onlyTaxDeductible ?? this.onlyTaxDeductible,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  bool get isDefault => this == TransactionFilter.initial();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TransactionFilter) return false;
    return periodPreset == other.periodPreset &&
        customRange == other.customRange &&
        typeFilter == other.typeFilter &&
        _setEquals(methods, other.methods) &&
        _setEquals(categories, other.categories) &&
        onlyNoReceipt == other.onlyNoReceipt &&
        onlyTaxDeductible == other.onlyTaxDeductible &&
        sortOption == other.sortOption;
  }

  @override
  int get hashCode =>
      periodPreset.hashCode ^
      (customRange?.hashCode ?? 0) ^
      typeFilter.hashCode ^
      methods.hashCode ^
      categories.hashCode ^
      onlyNoReceipt.hashCode ^
      onlyTaxDeductible.hashCode ^
      sortOption.hashCode;

  static bool _setEquals(Set a, Set b) =>
      a.length == b.length && a.difference(b).isEmpty;
}

class AllTransactionsPage extends StatefulWidget {
  final List<TransactionModel> transactions;

  const AllTransactionsPage({
    super.key,
    required this.transactions,
  });

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  final DateFormat _dateHeaderFormat = DateFormat('yyyy.MM.dd (E)', 'ko_KR');

  late List<TransactionModel> _filtered;
  late List<TransactionModel> _localTransactions;
  TransactionFilter _filter = TransactionFilter.initial();
  final TextEditingController _searchController = TextEditingController();
  final _repository = TransactionRepository();

  List<TransactionModel> get _source => _localTransactions;

  @override
  void initState() {
    super.initState();
    _localTransactions = List.from(widget.transactions);
    _applyFilter();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    List<TransactionModel> list = List.from(_source);

    final keyword = _searchController.text.trim();
    if (keyword.isNotEmpty) {
      final lower = keyword.toLowerCase();
      list = list.where((tx) {
        final store = tx.storeName.toLowerCase();
        final memo = (tx.memo ?? '').toLowerCase();
        final category = (tx.category ?? '').toLowerCase();
        final method = (tx.method).toLowerCase();
        final amount = tx.amount.toString();
        return store.contains(lower) ||
            memo.contains(lower) ||
            category.contains(lower) ||
            method.contains(lower) ||
            amount.contains(lower);
      }).toList();
    }

    DateTime? from;
    DateTime? to;
    final now = DateTime.now();

    switch (_filter.periodPreset) {
      case PeriodPreset.all:
        break;
      case PeriodPreset.thisMonth:
        from = DateTime(now.year, now.month, 1);
        to = DateTime(now.year, now.month + 1, 1)
            .subtract(const Duration(seconds: 1));
        break;
      case PeriodPreset.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        from = lastMonth;
        to = DateTime(lastMonth.year, lastMonth.month + 1, 1)
            .subtract(const Duration(seconds: 1));
        break;
      case PeriodPreset.threeMonths:
        from = DateTime(now.year, now.month - 2, 1);
        to = DateTime(now.year, now.month + 1, 1)
            .subtract(const Duration(seconds: 1));
        break;
      case PeriodPreset.custom:
        if (_filter.customRange != null) {
          from = _filter.customRange!.start;
          to = _filter.customRange!.end;
        }
        break;
    }

    if (from != null && to != null) {
      list = list.where((tx) {
        final d = tx.date;
        return !d.isBefore(from!) && !d.isAfter(to!);
      }).toList();
    }

    switch (_filter.typeFilter) {
      case TransactionTypeFilter.all:
        break;
      case TransactionTypeFilter.income:
        list = list
            .where((tx) => tx.transactionType == 'income')
            .toList();
        break;
      case TransactionTypeFilter.expense:
        list = list
            .where((tx) => tx.transactionType == 'expense')
            .toList();
        break;
    }

    if (_filter.methods.isNotEmpty) {
      list = list
          .where((tx) => _filter.methods.contains(tx.method))
          .toList();
    }

    if (_filter.categories.isNotEmpty) {
      list = list
          .where((tx) =>
              tx.category != null &&
              _filter.categories.contains(tx.category))
          .toList();
    }

    if (_filter.onlyNoReceipt) {
      list = list.where((tx) => tx.receiptUrl == null).toList();
    }
    if (_filter.onlyTaxDeductible) {
      list =
          list.where((tx) => tx.isTaxDeductible == true).toList();
    }

    list.sort((a, b) {
      switch (_filter.sortOption) {
        case SortOption.latest:
          return b.date.compareTo(a.date); 
        case SortOption.oldest:
          return a.date.compareTo(b.date);
        case SortOption.amountDesc:
          return b.amount.compareTo(a.amount);
        case SortOption.amountAsc:
          return a.amount.compareTo(b.amount);
      }
    });

    setState(() {
      _filtered = list;
    });
  }

  Map<String, List<TransactionModel>> _groupByDate(
      List<TransactionModel> list) {
    final Map<String, List<TransactionModel>> map = {};
    for (var tx in list) {
      final key = DateFormat('yyyy-MM-dd').format(tx.date);
      map.putIfAbsent(key, () => []).add(tx);
    }
    final sortedKeys = map.keys.toList();
    if (_filter.sortOption == SortOption.oldest) {
      sortedKeys.sort((a, b) => a.compareTo(b)); 
    } else {
      sortedKeys.sort((a, b) => b.compareTo(a)); 
    }
    final result = <String, List<TransactionModel>>{};
    for (final k in sortedKeys) {
      result[k] = map[k]!;
    }
    return result;
  }

  Future<void> _openFilterSheet() async {
    
    final Set<String> allMethods =
        _source.map((e) => e.method).toSet();
    final l10n = AppLocalizations.of(context)!;
    final Set<String> allCategories =
        _source.map((e) => e.category ?? l10n.allTransactionsUncategorized).toSet();

    final result = await showModalBottomSheet<TransactionFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        TransactionFilter localFilter = _filter;

        return DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

            Widget buildSectionTitle(String title) {
              return Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white70
                        : Colors.black87,
                  ),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius:
                    const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8, bottom: 4),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius:
                            BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          l10n.allTransactionsFilterTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              localFilter =
                                  TransactionFilter.initial();
                            });
                            Navigator.pop(
                              context,
                              TransactionFilter.initial(),
                            );
                          },
                          child: Text(l10n.allTransactionsFilterReset),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding:
                          const EdgeInsets.only(bottom: 80),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          
                          buildSectionTitle(l10n.allTransactionsPeriod),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 16),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildChoiceChip(
                                  context: context,
                                  label: l10n.allTransactionsPeriodAll,
                                  selected: localFilter
                                          .periodPreset ==
                                      PeriodPreset.all,
                                  onSelected: (_) {
                                    setState(() {
                                      localFilter = localFilter
                                          .copyWith(
                                              periodPreset:
                                                  PeriodPreset
                                                      .all,
                                              customRange:
                                                  null);
                                    });
                                    Navigator.pop(
                                        context,
                                        localFilter);
                                  },
                                ),
                                _buildChoiceChip(
                                  context: context,
                                  label: l10n.allTransactionsPeriodThisMonth,
                                  selected: localFilter
                                          .periodPreset ==
                                      PeriodPreset.thisMonth,
                                  onSelected: (_) {
                                    setState(() {
                                      localFilter =
                                          localFilter.copyWith(
                                        periodPreset:
                                            PeriodPreset
                                                .thisMonth,
                                        customRange: null,
                                      );
                                    });
                                  },
                                ),
                                _buildChoiceChip(
                                  context: context,
                                  label: l10n.allTransactionsPeriodLastMonth,
                                  selected: localFilter
                                          .periodPreset ==
                                      PeriodPreset.lastMonth,
                                  onSelected: (_) {
                                    setState(() {
                                      localFilter =
                                          localFilter.copyWith(
                                        periodPreset:
                                            PeriodPreset
                                                .lastMonth,
                                        customRange: null,
                                      );
                                    });
                                  },
                                ),
                                _buildChoiceChip(
                                  context: context,
                                  label: l10n.allTransactionsPeriodThreeMonths,
                                  selected: localFilter
                                          .periodPreset ==
                                      PeriodPreset.threeMonths,
                                  onSelected: (_) {
                                    setState(() {
                                      localFilter =
                                          localFilter.copyWith(
                                        periodPreset:
                                            PeriodPreset
                                                .threeMonths,
                                        customRange: null,
                                      );
                                    });
                                  },
                                ),
                                _buildChoiceChip(
                                  context: context,
                                  label: l10n.allTransactionsPeriodCustom,
                                  selected: localFilter
                                          .periodPreset ==
                                      PeriodPreset.custom,
                                  onSelected: (_) async {
                                    final now =
                                        DateTime.now();
                                    final picked =
                                        await showDateRangePicker(
                                      context: context,
                                      firstDate: DateTime(
                                          now.year - 3),
                                      lastDate: DateTime(
                                          now.year + 1),
                                      initialDateRange:
                                          localFilter
                                                  .customRange ??
                                              DateTimeRange(
                                                start: DateTime(
                                                    now.year,
                                                    now.month,
                                                    1),
                                                end: now,
                                              ),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        localFilter =
                                            localFilter
                                                .copyWith(
                                          periodPreset:
                                              PeriodPreset
                                                  .custom,
                                          customRange:
                                              picked,
                                        );
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),

                          buildSectionTitle(l10n.addTransactionType),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 16),
                            child: Wrap(
                              spacing: 8,
                              children: [
                                _buildChoiceChip(
                                  context: context,
                                  label: l10n.allTransactionsTypeAll,
                                  selected: localFilter
                                          .typeFilter ==
                                      TransactionTypeFilter.all,
                                  onSelected: (_) {
                                    setState(() {
                                      localFilter =
                                          localFilter.copyWith(
                                        typeFilter:
                                            TransactionTypeFilter
                                                .all,
                                      );
                                    });
                                  },
                                ),
                                _buildChoiceChip(
                                  context: context,
                                  label: l10n.allTransactionsTypeIncome,
                                  selected: localFilter
                                          .typeFilter ==
                                      TransactionTypeFilter
                                          .income,
                                  onSelected: (_) {
                                    setState(() {
                                      localFilter =
                                          localFilter.copyWith(
                                        typeFilter:
                                            TransactionTypeFilter
                                                .income,
                                      );
                                    });
                                  },
                                ),
                                _buildChoiceChip(
                                  context: context,
                                  label: l10n.allTransactionsTypeExpense,
                                  selected: localFilter
                                          .typeFilter ==
                                      TransactionTypeFilter
                                          .expense,
                                  onSelected: (_) {
                                    setState(() {
                                      localFilter =
                                          localFilter.copyWith(
                                        typeFilter:
                                            TransactionTypeFilter
                                                .expense,
                                      );
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                          buildSectionTitle(l10n.allTransactionsFilterPaymentMethod),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 16),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: allMethods
                                  .map((m) => FilterChip(
                                        label: Text(m),
                                        selected: localFilter
                                            .methods
                                            .contains(m),
                                        onSelected:
                                            (selected) {
                                          final newSet = Set<
                                              String>.from(
                                              localFilter
                                                  .methods);
                                          if (selected) {
                                            newSet.add(m);
                                          } else {
                                            newSet
                                                .remove(m);
                                          }
                                          setState(() {
                                            localFilter =
                                                localFilter
                                                    .copyWith(
                                              methods:
                                                  newSet,
                                            );
                                          });
                                        },
                                      ))
                                  .toList(),
                            ),
                          ),

                          buildSectionTitle(l10n.allTransactionsFilterCategory),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 16),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: allCategories
                                  .map((c) => FilterChip(
                                        label: Text(c),
                                        selected: localFilter
                                            .categories
                                            .contains(c),
                                        onSelected:
                                            (selected) {
                                          final newSet = Set<
                                              String>.from(
                                              localFilter
                                                  .categories);
                                          if (selected) {
                                            newSet.add(c);
                                          } else {
                                            newSet
                                                .remove(c);
                                          }
                                          setState(() {
                                            localFilter =
                                                localFilter
                                                    .copyWith(
                                              categories:
                                                  newSet,
                                            );
                                          });
                                        },
                                      ))
                                  .toList(),
                            ),
                          ),

                          buildSectionTitle(l10n.allTransactionsFilterTaxOptions),
                          SwitchListTile(
                            title: Text(l10n.allTransactionsFilterNoReceipt),
                            value:
                                localFilter.onlyNoReceipt,
                            onChanged: (v) {
                              setState(() {
                                localFilter =
                                    localFilter.copyWith(
                                        onlyNoReceipt: v);
                              });
                            },
                          ),
                          SwitchListTile(
                            title:
                                Text(l10n.allTransactionsFilterTaxDeductible),
                            value: localFilter
                                .onlyTaxDeductible,
                            onChanged: (v) {
                              setState(() {
                                localFilter =
                                    localFilter.copyWith(
                                        onlyTaxDeductible:
                                            v);
                              });
                            },
                          ),

                          buildSectionTitle(l10n.allTransactionsFilterSort),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 16),
                            child: DropdownButtonFormField<
                                SortOption>(
                              value:
                                  localFilter.sortOption,
                              decoration:
                                  const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: SortOption.latest,
                                  child: Text(l10n.allTransactionsSortLatest),
                                ),
                                DropdownMenuItem(
                                  value: SortOption.oldest,
                                  child: Text(l10n.allTransactionsSortOldest),
                                ),
                                DropdownMenuItem(
                                  value:
                                      SortOption.amountDesc,
                                  child:
                                      Text(l10n.allTransactionsSortAmountDesc),
                                ),
                                DropdownMenuItem(
                                  value:
                                      SortOption.amountAsc,
                                  child:
                                      Text(l10n.allTransactionsSortAmountAsc),
                                ),
                              ],
                              onChanged: (val) {
                                if (val == null) return;
                                setState(() {
                                  localFilter =
                                      localFilter.copyWith(
                                          sortOption: val);
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(
                              16, 8, 16, 16),
                      child: PrimaryButton(
                        label: l10n.allTransactionsFilterApply,
                        onPressed: () {
                          Navigator.pop(context, localFilter);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _filter = result;
      });
      _applyFilter();
    }
  }

  Widget _buildChoiceChip({
    required BuildContext context,
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor:
          Colors.blueGrey[700]?.withOpacity(0.9),
      labelStyle: TextStyle(
        color: selected
            ? Colors.white
            : (isDark ? Colors.white70 : Colors.black87),
      ),
      backgroundColor:
          isDark ? Colors.grey[800] : Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10nBuild = AppLocalizations.of(context)!;
    final grouped = _groupByDate(_filtered);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10nBuild.allTransactionsTitle),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.fromLTRB(16, 8, 16, 12),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => _applyFilter(),
                    decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: const Icon(Icons.search),
                      hintText: l10nBuild.allTransactionsSearchHint,
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _applyFilter();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark
                          ? Colors.grey[850]
                          : Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: Colors.blueGrey,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                InkWell(
                  onTap: _openFilterSheet,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007BFF),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_list,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          l10nBuild.allTransactionsFilter,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!_filter.isDefault)
                          Container(
                            margin:
                                const EdgeInsets.only(left: 4),
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withOpacity(0.2),
                              borderRadius:
                                  BorderRadius.circular(999),
                            ),
                            child: const Text(
                              "●",
                              style: TextStyle(
                                  color: Colors.yellowAccent,
                                  fontSize: 10),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: grouped.isEmpty
                ? Center(
                    child: Text(l10nBuild.allTransactionsNoResults),
                  )
                : ListView.builder(
                    itemCount: grouped.length,
                    itemBuilder: (context, index) {
                      final dateKey =
                          grouped.keys.elementAt(index);
                      final items = grouped[dateKey]!;
                      final date = DateTime.parse(dateKey);

                      return Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          
                          Container(
                            width: double.infinity,
                            color: isDark
                                ? Colors.grey[900]
                                : Colors.grey[100],
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8),
                            child: Text(
                              _dateHeaderFormat.format(date),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          ...items.map((tx) {
  
                            final String categoryKey =
                                (tx.category == null || tx.category!.trim().isEmpty)
                                    ? l10nBuild.allTransactionsUncategorized
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
                                  final updated = await _repository.getTransactions();
                                  setState(() {
                                    _localTransactions = updated;
                                  });
                                  _applyFilter();
                                }
                              },
                            );
                          }).toList(),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
