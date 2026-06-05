import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_pro/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/widgets/primary_button.dart';
import '../../../core/providers/country_config_provider.dart';
import '../../../core/config/transaction_options.dart';
import '../data/recurring_transaction_model.dart';
import '../data/recurring_transaction_repository.dart';

class AddRecurringTransactionPage extends ConsumerStatefulWidget {
  final RecurringTransactionModel? initialData;

  const AddRecurringTransactionPage({
    super.key,
    this.initialData,
  });

  @override
  ConsumerState<AddRecurringTransactionPage> createState() =>
      _AddRecurringTransactionPageState();
}

class _AddRecurringTransactionPageState
    extends ConsumerState<AddRecurringTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final RecurringTransactionRepository _repository =
      RecurringTransactionRepository();

  late TextEditingController _titleController;
  late TextEditingController _storeController;
  late TextEditingController _amountController;
  late TextEditingController _memoController;
  late TextEditingController _categoryController;

  String _type = 'expense';
  String _cycle = 'monthly';
  int _day = 1;
  String? _method;

  bool _isSaving = false;

  late TxOptions _opts;
  List<String> get _methods => _opts.recurringMethods;
  List<String> get _expenseCategories => _opts.recurringExpenseCategories;
  List<String> get _incomeCategories => _opts.recurringIncomeCategories;

  @override
  void initState() {
    super.initState();
    _opts = TxOptions.forCountry(ref.read(countryConfigProvider).countryCode);

    final data = widget.initialData;

    _titleController = TextEditingController(text: data?.title ?? '');
    _storeController = TextEditingController(text: '');
    _amountController = TextEditingController(
      text: data != null ? data.amount.toString() : '',
    );
    _memoController = TextEditingController(text: data?.memo ?? '');
    _categoryController = TextEditingController(text: data?.category ?? '');

    _type = data?.transactionType ?? 'expense';
    _cycle = data?.cycle ?? 'monthly';
    _day = data?.day ?? 1;
    _method = data?.method ?? _methods.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _storeController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  List<DropdownMenuItem<int>> _buildDayItems(AppLocalizations l10n) {
    if (_cycle == 'monthly') {
      return List.generate(
        31,
        (i) => DropdownMenuItem(
          value: i + 1,
          child: Text(l10n.recurringDayOfMonth('${i + 1}')),
        ),
      );
    } else {
      final localeName = Localizations.localeOf(context).toString();
      // 2024-01-01 is a Monday → i=1..7 maps Mon..Sun
      return List.generate(
        7,
        (i) => DropdownMenuItem(
          value: i + 1,
          child: Text(
            DateFormat.EEEE(localeName).format(DateTime(2024, 1, i + 1)),
          ),
        ),
      );
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recurringLoginRequired)),
      );
      return;
    }

    final amount = int.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recurringAmountInvalid)),
      );
      return;
    }

    setState(() => _isSaving = true);

    final now = DateTime.now();

    final model = RecurringTransactionModel(
      id: widget.initialData?.id ?? const Uuid().v4(),
      userId: user.id,
      title: _titleController.text.trim(),
      amount: amount,
      transactionType: _type,
      category: _categoryController.text.trim().isEmpty
          ? null
          : _categoryController.text.trim(),
      method: _method,
      memo: _memoController.text.trim().isEmpty
          ? null
          : _memoController.text.trim(),
      cycle: _cycle,
      day: _day,
      lastAppliedDate: widget.initialData?.lastAppliedDate,
      createdAt: widget.initialData?.createdAt ?? now,
    );

    bool ok;
    if (widget.initialData == null) {
      ok = await _repository.addRecurring(model);
    } else {
      ok = await _repository.updateRecurring(model);
    }

    setState(() => _isSaving = false);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.initialData == null
              ? l10n.recurringAdded
              : l10n.recurringUpdated),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recurringSaveError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEdit = widget.initialData != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.grey[400] : Colors.grey[600];

    final categories =
        _type == 'income' ? _incomeCategories : _expenseCategories;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? l10n.recurringEditTitle : l10n.recurringAddTitle),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.addTransactionType,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() {
                              _type = 'expense';
                              _categoryController.clear();
                            }),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _type == 'expense'
                                      ? Colors.red
                                      : Colors.grey.shade400,
                                  width: _type == 'expense' ? 2 : 1,
                                ),
                                color: _type == 'expense'
                                    ? Colors.red.withOpacity(0.06)
                                    : Colors.transparent,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.arrow_upward,
                                    color: _type == 'expense'
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.addTransactionExpense,
                                    style: TextStyle(
                                      color: _type == 'expense'
                                          ? Colors.red
                                          : Colors.grey,
                                      fontWeight: _type == 'expense'
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() {
                              _type = 'income';
                              _categoryController.clear();
                            }),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _type == 'income'
                                      ? Colors.green
                                      : Colors.grey.shade400,
                                  width: _type == 'income' ? 2 : 1,
                                ),
                                color: _type == 'income'
                                    ? Colors.green.withOpacity(0.06)
                                    : Colors.transparent,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.arrow_downward,
                                    color: _type == 'income'
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.addTransactionIncome,
                                    style: TextStyle(
                                      color: _type == 'income'
                                          ? Colors.green
                                          : Colors.grey,
                                      fontWeight: _type == 'income'
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Text(
                      l10n.recurringBasicInfo,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _fieldBox(
                      child: TextFormField(
                        controller: _titleController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: l10n.recurringNameLabel,
                          border: InputBorder.none,
                          labelStyle: TextStyle(color: hintColor),
                          icon: Icon(Icons.label_outline, color: hintColor),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? l10n.recurringRequired
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _fieldBox(
                      child: TextFormField(
                        controller: _storeController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: l10n.recurringStoreLabel,
                          border: InputBorder.none,
                          labelStyle: TextStyle(color: hintColor),
                          icon: Icon(Icons.store_outlined, color: hintColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _fieldBox(
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: l10n.addTransactionAmountLabel,
                          suffixText: ref.watch(countryConfigProvider).currencySymbol,
                          border: InputBorder.none,
                          labelStyle: TextStyle(color: hintColor),
                          suffixStyle: TextStyle(color: textColor),
                          icon: Icon(Icons.attach_money, color: hintColor),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? l10n.recurringRequired
                            : null,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      l10n.recurringCycle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _fieldBox(
                      child: Row(
                        children: [
                          DropdownButton<String>(
                            value: _cycle,
                            underline: const SizedBox(),
                            items: [
                              DropdownMenuItem(
                                value: 'monthly',
                                child: Text(l10n.recurringCycleMonthly),
                              ),
                              DropdownMenuItem(
                                value: 'weekly',
                                child: Text(l10n.recurringCycleWeekly),
                              ),
                            ],
                            onChanged: (val) {
                              if (val == null) return;
                              setState(() {
                                _cycle = val;
                                _day = 1;
                              });
                            },
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _day,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              items: _buildDayItems(l10n),
                              onChanged: (val) {
                                if (val == null) return;
                                setState(() => _day = val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      l10n.addTransactionCategoryLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((cat) {
                        final selected = _categoryController.text == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              _categoryController.text = cat;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    _fieldBox(
                      child: TextFormField(
                        controller: _categoryController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: l10n.addTransactionCategoryDirectInput,
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: hintColor),
                          icon: Icon(Icons.category_outlined, color: hintColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _fieldBox(
                      child: DropdownButtonFormField<String>(
                        value: _method ?? _methods.first,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(Icons.payment),
                        ),
                        items: _methods
                            .map((m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(m),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _method = val),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      l10n.recurringMemoOptional,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: TextFormField(
                        controller: _memoController,
                        maxLines: 3,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: l10n.recurringMemoHint,
                          hintStyle: TextStyle(color: hintColor),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: _isSaving
                          ? l10n.addTransactionSaving
                          : (isEdit
                              ? l10n.recurringUpdate
                              : l10n.recurringRegister),
                      isLoading: _isSaving,
                      onPressed: _save,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _fieldBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: child,
    );
  }
}
