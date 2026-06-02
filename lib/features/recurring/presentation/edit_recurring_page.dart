import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/primary_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/recurring_transaction_model.dart';
import '../data/recurring_transaction_repository.dart';

class EditRecurringPage extends StatefulWidget {
  final RecurringTransactionModel? initial;

  const EditRecurringPage({super.key, this.initial});

  @override
  State<EditRecurringPage> createState() => _EditRecurringPageState();
}

class _EditRecurringPageState extends State<EditRecurringPage> {
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

  final _expenseCategories = [
    '식비',
    '카페/간식',
    '교통비',
    '쇼핑',
    '소모품',
    '접대비',
    '통신비',
    '임대료',
    '광고비',
    '기타',
  ];

  final _incomeCategories = [
    '사업수입',
    '정기매출',
    '임대수익',
    '서비스수익',
    '기타',
  ];

  final _methods = [
    '계좌이체',
    '카드결제',
    '현금',
    '자동이체',
    '기타',
  ];

  @override
  void initState() {
    super.initState();

    final data = widget.initial;
    _titleController = TextEditingController(text: data?.title ?? '');
    _amountController =
        TextEditingController(text: data?.amount.toString() ?? '');
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

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 정보가 없습니다.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final amount =
        int.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;

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
        const SnackBar(content: Text('저장에 실패했습니다.')),
      );
    }
  }

  Future<void> _skipThisMonth() async {
    if (widget.initial == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('이번 달만 건너뛸까요?'),
        content: const Text('이번 달에는 이 정기 거래로 인한 자동 생성이 일어나지 않습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              '건너뛰기',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _repo.markAsAppliedToday(widget.initial!.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('이번 달은 건너뛰기로 설정되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(isEdit ? '정기 거래 수정' : '정기 거래 추가'),
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
                          title: const Text('삭제하시겠습니까?'),
                          content: const Text('이 정기 거래는 더 이상 자동 생성되지 않습니다.'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(ctx, false),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(ctx, true),
                              child: const Text(
                                '삭제',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        final ok = await _repo
                            .deleteRecurring(widget.initial!.id);
                        if (!mounted) return;
                        if (ok) {
                          Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('삭제에 실패했습니다.')),
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
                      '거래 유형',
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
                            label: const Text('지출'),
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
                            label: const Text('수입'),
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
                      decoration: const InputDecoration(
                        labelText: '이름 (예: 월세, 직원 월급)',
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? '필수 입력입니다' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: '금액',
                        suffixText: '원',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? '필수 입력입니다' : null,
                    ),
                    const SizedBox(height: 24),

                    Text(
                      '반복 주기',
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
                            label: const Text('매월'),
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
                            label: const Text('매주'),
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
                        decoration: const InputDecoration(
                          labelText: '매월 몇 일?',
                        ),
                        items: List.generate(
                          31,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text('매월 ${i + 1}일'),
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
                        decoration:
                            const InputDecoration(labelText: '요일 선택'),
                        items: const [
                          DropdownMenuItem(
                            value: 1,
                            child: Text('매주 월요일'),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text('매주 화요일'),
                          ),
                          DropdownMenuItem(
                            value: 3,
                            child: Text('매주 수요일'),
                          ),
                          DropdownMenuItem(
                            value: 4,
                            child: Text('매주 목요일'),
                          ),
                          DropdownMenuItem(
                            value: 5,
                            child: Text('매주 금요일'),
                          ),
                          DropdownMenuItem(
                            value: 6,
                            child: Text('매주 토요일'),
                          ),
                          DropdownMenuItem(
                            value: 7,
                            child: Text('매주 일요일'),
                          ),
                        ],
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
                      decoration:
                          const InputDecoration(labelText: '카테고리 (선택)'),
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
                      decoration: const InputDecoration(
                          labelText: '결제/입금 수단 (선택)'),
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

                    if (_transactionType == 'expense')
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('부가세 공제 대상 지출로 보기'),
                        value: _isTaxDeductible,
                        onChanged: (v) =>
                            setState(() => _isTaxDeductible = v),
                      ),

                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _memoController,
                      decoration: const InputDecoration(
                        labelText: '메모 (선택)',
                        hintText: '예: 1호점 월세, 배달앱 광고비 등',
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: 24),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('이 정기 거래 자동 생성 사용'),
                      subtitle: const Text('꺼두면 앞으로 자동으로 내역이 생성되지 않습니다.'),
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
                          label: const Text('이번 달만 건너뛰기'),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: isEdit ? '수정하기' : '등록하기',
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
