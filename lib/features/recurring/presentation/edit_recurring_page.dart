import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:expense_pro/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/widgets/primary_button.dart';
import '../../../core/providers/country_config_provider.dart';
import '../../../core/config/transaction_options.dart';
import '../data/recurring_transaction_model.dart';
import '../data/recurring_transaction_repository.dart';

class EditRecurringPage extends ConsumerStatefulWidget {
  final RecurringTransactionModel? initial;

  const EditRecurringPage({super.key, this.initial});

  @override
  ConsumerState<EditRecurringPage> createState() => _EditRecurringPageState();
}

class _EditRecurringPageState extends ConsumerState<EditRecurringPage> {
  final _formKey = GlobalKey<FormState>();
  final _repo = RecurringTransactionRepository();

  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _memoController;

  String _transactionType = 'expense';
  String _cycle = 'monthly';
  int _day = 1;
  String? _category;
  String? _method;
  bool _isTaxDeductible = true;

  bool _isSaving = false;
  bool _isActive = true;

  late TxOptions _opts;
  bool _isKorea = true;
  List<String> get _expenseCategories => _opts.recurringExpenseCategories;
  List<String> get _incomeCategories => _opts.recurringIncomeCategories;
  List<String> get _methods => _opts.recurringMethods;

  @override
  void initState() {
    super.initState();
    final config = ref.read(countryConfigProvider);
    final countryCode = config.countryCode;
    _isKorea = countryCode == 'KR';
    _opts = TxOptions.forCountry(countryCode);

    final data = widget.initial;
    _titleController = TextEditingController(text: data?.title ?? '');
    _amountController = TextEditingController(
        text: data != null ? _trimAmount(config.toMajorUnits(data.amount)) : '');
    _memoController = TextEditingController(text: data?.memo ?? '');

    if (data != null) {
      _transactionType = data.transactionType;
      _cycle = data.cycle;
      _day = data.day;
      _category = data.category;
      _method = data.method;
      _isTaxDeductible = data.isTaxDeductible ?? true;
      _isActive = data.isActive;
    }
  }

  String _trimAmount(num v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  String _weekdayName(int day) {
    // 2024-01-01 is a Monday → day 1..7 maps Mon..Sun
    final localeName = Localizations.localeOf(context).toString();
    return DateFormat.EEEE(localeName).format(DateTime(2024, 1, day));
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recurringLoginRequired)),
      );
      return;
    }

    setState(() => _isSaving = true);

    final amount = ref.read(countryConfigProvider).toMinorUnits(
        num.tryParse(_amountController.text.replaceAll(',', '')) ?? 0);

    final model = RecurringTransactionModel(
      id: widget.initial?.id ?? const Uuid().v4(),
      userId: userId,
      title: _titleController.text.trim(),
      amount: amount,
      transactionType: _transactionType,
      cycle: _cycle,
      day: _day,
      category: _category,
      method: _method,
      memo: _memoController.text.trim().isEmpty ? null : _memoController.text,
      isTaxDeductible:
          _transactionType == 'expense' ? _isTaxDeductible : null,
      lastAppliedDate: widget.initial?.lastAppliedDate,
      createdAt: widget.initial?.createdAt ?? DateTime.now(),
      isActive: _isActive,
    );

    bool ok;
    if (widget.initial == null) {
      ok = await _repo.addRecurring(model);
    } else {
      ok = await _repo.updateRecurring(model);
    }

    setState(() => _isSaving = false);

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recurringSaveError)),
      );
    }
  }

  Future<void> _skipThisMonth() async {
    if (widget.initial == null) return;
    final l10n = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.recurringSkipTitle),
        content: Text(l10n.recurringSkipContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.recurringSkip,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _repo.markAsAppliedToday(widget.initial!.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.recurringSkipDone)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.grey[400] : Colors.grey[600];

    final isEdit = widget.initial != null;

    final categoryList =
        _transactionType == 'income' ? _incomeCategories : _expenseCategories;
    final String? safeCategory =
        categoryList.contains(_category) ? _category : null;
    final String? safeMethod =
        _methods.contains(_method) ? _method : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? l10n.recurringEditTitle : l10n.recurringAddTitle),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _isSaving
                  ? null
                  : () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.recurringDeleteTitle),
                          content: Text(l10n.recurringDeleteContent),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(l10n.cancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(
                                l10n.delete,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        final ok =
                            await _repo.deleteRecurring(widget.initial!.id);
                        if (!mounted) return;
                        if (ok) {
                          Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.recurringDeleteFailed)),
                          );
                        }
                      }
                    },
            ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.addTransactionType,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: hintColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Text(l10n.addTransactionExpense),
                            selected: _transactionType == 'expense',
                            onSelected: (_) {
                              setState(() {
                                _transactionType = 'expense';
                                if (!_expenseCategories.contains(_category)) {
                                  _category = null;
                                }
                              });
                            },
                            selectedColor: Colors.red[400],
                            labelStyle: TextStyle(
                              color: _transactionType == 'expense'
                                  ? Colors.white
                                  : textColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: Text(l10n.addTransactionIncome),
                            selected: _transactionType == 'income',
                            onSelected: (_) {
                              setState(() {
                                _transactionType = 'income';
                                if (!_incomeCategories.contains(_category)) {
                                  _category = null;
                                }
                              });
                            },
                            selectedColor: Colors.green[400],
                            labelStyle: TextStyle(
                              color: _transactionType == 'income'
                                  ? Colors.white
                                  : textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: l10n.recurringNameLabel,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? l10n.recurringRequired
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: l10n.addTransactionAmountLabel,
                        suffixText: ref.watch(countryConfigProvider).currencySymbol,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? l10n.recurringRequired
                          : null,
                    ),
                    const SizedBox(height: 24),

                    Text(
                      l10n.recurringCycle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: hintColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Text(l10n.recurringCycleMonthly),
                            selected: _cycle == 'monthly',
                            onSelected: (_) {
                              setState(() {
                                _cycle = 'monthly';
                                if (_day < 1 || _day > 31) _day = 1;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: Text(l10n.recurringCycleWeekly),
                            selected: _cycle == 'weekly',
                            onSelected: (_) {
                              setState(() {
                                _cycle = 'weekly';
                                if (_day < 1 || _day > 7) _day = 1;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_cycle == 'monthly')
                      DropdownButtonFormField<int>(
                        value: _day,
                        decoration: InputDecoration(
                          labelText: l10n.recurringMonthlyDaySelect,
                        ),
                        items: List.generate(
                          31,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text(l10n.recurringMonthlyDay('${i + 1}')),
                          ),
                        ),
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() {
                            _day = v;
                          });
                        },
                      )
                    else
                      DropdownButtonFormField<int>(
                        value: _day,
                        decoration: InputDecoration(
                            labelText: l10n.recurringWeekdaySelect),
                        items: List.generate(
                          7,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child:
                                Text(l10n.recurringWeeklyDay(_weekdayName(i + 1))),
                          ),
                        ),
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() {
                            _day = v;
                          });
                        },
                      ),
                    const SizedBox(height: 24),

                    DropdownButtonFormField<String>(
                      value: safeCategory,
                      decoration: InputDecoration(
                          labelText: l10n.recurringCategoryOptional),
                      items: categoryList
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _category = v),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: safeMethod,
                      decoration: InputDecoration(
                          labelText: l10n.recurringMethodOptional),
                      items: _methods
                          .map(
                            (m) => DropdownMenuItem(
                              value: m,
                              child: Text(m),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _method = v),
                    ),
                    const SizedBox(height: 24),

                    if (_isKorea && _transactionType == 'expense')
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.recurringVatDeductibleToggle),
                        value: _isTaxDeductible,
                        onChanged: (v) =>
                            setState(() => _isTaxDeductible = v),
                      ),

                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _memoController,
                      decoration: InputDecoration(
                        labelText: l10n.recurringMemoOptional,
                        hintText: l10n.recurringMemoHint,
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: 24),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.recurringActiveToggle),
                      subtitle: Text(l10n.recurringActiveToggleSub),
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),

                    if (isEdit) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _isSaving ? null : _skipThisMonth,
                          icon: const Icon(Icons.skip_next),
                          label: Text(l10n.recurringSkipButton),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: isEdit
                          ? l10n.recurringUpdate
                          : l10n.recurringRegister,
                      isLoading: _isSaving,
                      onPressed: _save,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
