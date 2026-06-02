import 'package:flutter/material.dart';
import '../../../core/widgets/primary_button.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../data/recurring_transaction_model.dart';
import '../data/recurring_transaction_repository.dart';

class AddRecurringTransactionPage extends StatefulWidget {
  final RecurringTransactionModel? initialData;

  const AddRecurringTransactionPage({
    super.key,
    this.initialData,
  });

  @override
  State<AddRecurringTransactionPage> createState() => _AddRecurringTransactionPageState();
}

class _AddRecurringTransactionPageState extends State<AddRecurringTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final RecurringTransactionRepository _repository = RecurringTransactionRepository();

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

  final List<String> _methods = [
    '계좌이체',
    '현금',
    '카드',
    '자동이체',
    '기타',
  ];

  final List<String> _expenseCategories = [
    '임대료',
    '인건비',
    '광고비',
    '식자재',
    '관리비',
    '통신비',
    '기타',
  ];

  final List<String> _incomeCategories = [
    '사업수입',
    '급여',
    '정기매출',
    '임대수익',
    '기타',
  ];

  @override
  void initState() {
    super.initState();
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

  List<DropdownMenuItem<int>> _buildDayItems() {
    if (_cycle == 'monthly') {
      return List.generate(
        31,
        (i) => DropdownMenuItem(
          value: i + 1,
          child: Text('${i + 1}일'),
        ),
      );
    } else {
      const names = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
      return List.generate(
        7,
        (i) => DropdownMenuItem(
          value: i + 1,
          child: Text(names[i]),
        ),
      );
    }
  }

  String _cycleLabel() {
    if (_cycle == 'monthly') return '매월';
    return '매주';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final amount = int.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('금액을 올바르게 입력해주세요.')),
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
          content: Text(widget.initialData == null ? '정기 거래가 추가되었습니다.' : '정기 거래가 수정되었습니다.'),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialData != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.grey[400] : Colors.grey[600];

    final categories = _type == 'income' ? _incomeCategories : _expenseCategories;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? '정기 거래 수정' : '정기 거래 추가'),
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
                      '거래 유형',
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
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _type == 'expense' ? Colors.red : Colors.grey.shade400,
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
                                    color: _type == 'expense' ? Colors.red : Colors.grey,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '지출',
                                    style: TextStyle(
                                      color: _type == 'expense' ? Colors.red : Colors.grey,
                                      fontWeight: _type == 'expense' ? FontWeight.bold : FontWeight.normal,
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
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _type == 'income' ? Colors.green : Colors.grey.shade400,
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
                                    color: _type == 'income' ? Colors.green : Colors.grey,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '수입',
                                    style: TextStyle(
                                      color: _type == 'income' ? Colors.green : Colors.grey,
                                      fontWeight: _type == 'income' ? FontWeight.bold : FontWeight.normal,
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
                      '기본 정보',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: TextFormField(
                        controller: _titleController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: '이름 (예: 월세, 직원 월급)',
                          border: InputBorder.none,
                          labelStyle: TextStyle(color: hintColor),
                          icon: Icon(Icons.label_outline, color: hintColor),
                        ),
                        validator: (val) =>
                            val == null || val.trim().isEmpty ? '필수 입력입니다' : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: TextFormField(
                        controller: _storeController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: '거래처 / 상호명 (선택)',
                          border: InputBorder.none,
                          labelStyle: TextStyle(color: hintColor),
                          icon: Icon(Icons.store_outlined, color: hintColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: '금액',
                          suffixText: '원',
                          border: InputBorder.none,
                          labelStyle: TextStyle(color: hintColor),
                          suffixStyle: TextStyle(color: textColor),
                          icon: Icon(Icons.attach_money, color: hintColor),
                        ),
                        validator: (val) =>
                            val == null || val.trim().isEmpty ? '필수 입력입니다' : null,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      '반복 주기',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Row(
                        children: [
                          DropdownButton<String>(
                            value: _cycle,
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(
                                value: 'monthly',
                                child: Text('매월'),
                              ),
                              DropdownMenuItem(
                                value: 'weekly',
                                child: Text('매주'),
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
                              items: _buildDayItems(),
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
                      '분류',
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: TextFormField(
                        controller: _categoryController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: '직접 입력',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: hintColor),
                          icon: Icon(Icons.category_outlined, color: hintColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
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
                      '메모 (선택)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: TextFormField(
                        controller: _memoController,
                        maxLines: 3,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: '예: 1호점 월세, 김대리 급여 등',
                          hintStyle: TextStyle(color: hintColor),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: _isSaving
                          ? '저장 중...'
                          : (isEdit ? '수정하기' : '등록하기'),
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
