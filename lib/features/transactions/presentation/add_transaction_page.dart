import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/widgets/primary_button.dart';

import '../data/transaction_model.dart';
import '../data/transaction_repository.dart';

class AddTransactionPage extends StatefulWidget {
  final TransactionModel? initialData;
  final bool isExistingRecord;
  final String? initialTransactionType; 

  const AddTransactionPage({
    super.key,
    this.initialData,
    this.isExistingRecord = false,
    this.initialTransactionType,
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = TransactionRepository();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _storeController;
  late TextEditingController _amountController;
  late TextEditingController _categoryController;
  late TextEditingController _memoController;
  late TextEditingController _approvalNumController;
  late TextEditingController _customMethodController;
  late TextEditingController _customInstallmentController;

  String _storeName = '';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String _userType = 'personal';

  bool _isTaxDeductible = true;
  bool _isVatExempt = false; 

  String _transactionType = 'expense'; 

  String _selectedMethod = '개인카드';
  String _selectedInstallment = '1';
  String _cashReceiptType = '지출증빙용';

  List<String> _storeSuggestions = [];
  XFile? _pickedImage;

  final List<String> _paymentMethods = [
    '개인카드',
    '법인카드',
    '현금영수증',
    '계좌이체',
    '간이영수증',
    '지역화폐',
    '제로페이',
    '상품권',
    '포인트/마일리지',
    '기타',
  ];

  final List<Map<String, dynamic>> _expenseCategoryIcons = [
    {'icon': Icons.restaurant, 'label': '식비'},
    {'icon': Icons.local_cafe, 'label': '카페/간식'},
    {'icon': Icons.directions_car, 'label': '교통비'},
    {'icon': Icons.shopping_bag, 'label': '쇼핑'},
    {'icon': Icons.shopping_cart, 'label': '소모품'},
    {'icon': Icons.handshake, 'label': '접대비'},
    {'icon': Icons.phone_android, 'label': '통신비'},
    {'icon': Icons.local_hospital, 'label': '의료비'},
    {'icon': Icons.school, 'label': '교육비'},
    {'icon': Icons.more_horiz, 'label': '기타'},
  ];

  final List<Map<String, dynamic>> _incomeCategoryIcons = [
    {'icon': Icons.work, 'label': '사업수입'},
    {'icon': Icons.payments, 'label': '급여'},
    {'icon': Icons.sell, 'label': '판매수익'},
    {'icon': Icons.account_balance, 'label': '임대수익'},
    {'icon': Icons.trending_up, 'label': '투자수익'},
    {'icon': Icons.card_giftcard, 'label': '기타수입'},
    {'icon': Icons.more_horiz, 'label': '기타'},
  ];

  final List<String> _incomeMethods = [
    '계좌입금',
    '현금',
    '카드수납',
    '전자결제',
    '기타',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserType();
    _loadStoreNames();

    final data = widget.initialData;

    _storeName = data?.storeName ?? '';
    _storeController = TextEditingController(text: _storeName);
    _amountController = TextEditingController(
      text: data != null ? data.amount.toString() : '',
    );
    _categoryController =
        TextEditingController(text: data?.category ?? '');
    _memoController = TextEditingController(text: data?.memo ?? '');
    _approvalNumController =
        TextEditingController(text: data?.approvalNumber ?? '');
    _customMethodController = TextEditingController();
    _customInstallmentController = TextEditingController();

    _transactionType =
        widget.initialTransactionType ?? data?.transactionType ?? 'expense';

    if (data != null) {
      _selectedDate = data.date;
      _isTaxDeductible = data.isTaxDeductible;
      _isVatExempt = data.isVatExempt ?? false;

      String method = data.method;

      if (method.contains('(') && method.contains('개월)')) {
        final parts = method.split('(');
        method = parts[0];
        if (parts.length > 1) {
          final instStr =
              parts[1].replaceAll('개월)', '');
          final instVal = int.tryParse(instStr) ?? 1;
          if (instVal >= 1 && instVal <= 36) {
            _selectedInstallment = instVal.toString();
          } else {
            _selectedInstallment = 'custom';
            _customInstallmentController.text =
                instVal.toString();
          }
        }
      }

      final methodList = _transactionType == 'income'
          ? _incomeMethods
          : _paymentMethods;
      if (methodList.contains(method)) {
        _selectedMethod = method;
      } else {
        _selectedMethod = '기타';
        _customMethodController.text = method;
      }

      if (data.cashReceiptType != null) {
        _cashReceiptType = data.cashReceiptType!;
      }
    } else {
      
      if (_transactionType == 'income') {
        _selectedMethod = '계좌입금';
      } else {
        _selectedMethod = '개인카드';
      }
      _isVatExempt = false;
    }
  }

  Future<void> _loadUserType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userType = prefs.getString('user_type') ?? 'personal';
    });
  }

  Future<void> _loadStoreNames() async {
    final names = await _repository.getAllStoreNames();
    setState(() {
      _storeSuggestions = names;
    });
  }

  @override
  void dispose() {
    _storeController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _memoController.dispose();
    _approvalNumController.dispose();
    _customMethodController.dispose();
    _customInstallmentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 50,
      );
      if (image != null) {
        setState(() => _pickedImage = image);
      }
    } catch (e) {
      debugPrint('이미지 선택 오류: $e');
    }
  }

  void _clearImage() {
    setState(() => _pickedImage = null);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _delete() async {
    if (!widget.isExistingRecord || widget.initialData == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제하시겠습니까?'),
        content: const Text('이 내역은 영구적으로 삭제됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '삭제',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final success =
        await _repository.deleteTransaction(widget.initialData!.id);
    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제되었습니다.')),
      );
      Navigator.pop(context, true);
    }
  }

  bool _needsReceiptForCurrentForm() {
    if (_transactionType != 'expense') return false;

    final rawAmount =
        _amountController.text.replaceAll(',', '');
    final amount = int.tryParse(rawAmount) ?? 0;

    String method = _selectedMethod;
    if (method.contains('(')) {
      method = method.split('(').first;
    }

    const mustReceiptMethods = [
      '개인카드',
      '법인카드',
      '현금영수증',
      '계좌이체',
      '간이영수증',
      '제로페이',
      '지역화폐',
      '상품권',
    ];

    if (!mustReceiptMethods.contains(method)) {
      return false;
    }

    if (method == '현금영수증' || method == '간이영수증') {
      return true;
    }

    if (amount >= 100000) {
      return true;
    }

    return false;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_storeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('상호명을 입력해주세요.')),
      );
      return;
    }

    final hasExistingReceipt =
        widget.initialData?.receiptUrl != null &&
            widget.initialData!.receiptUrl!.isNotEmpty;
    final hasNewImage = _pickedImage != null;

    if (!hasExistingReceipt &&
        !hasNewImage &&
        _needsReceiptForCurrentForm()) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('⚠️ 영수증 필수 거래입니다'),
          content: const Text(
            '결제수단과 금액 기준으로 볼 때,\n'
            '이 거래는 세법상 영수증을 반드시 보관해야 하는 거래로 보여요.\n\n'
            '그래도 영수증 없이 그냥 저장할까요?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text('영수증 첨부하기'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              child: const Text(
                '그냥 저장',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }
    
    else if (!hasExistingReceipt &&
        !hasNewImage &&
        _userType.contains('corporate')) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('⚠️ 증빙 누락 안내'),
          content: const Text(
            '법인 비용은 웬만하면 영수증이 있어야 해요.\n'
            '사진 없이 그냥 저장하시겠습니까?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text('영수증 첨부하기'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              child: const Text(
                '그냥 저장',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => _isLoading = true);

    String? finalReceiptUrl = widget.initialData?.receiptUrl;
    if (_pickedImage != null) {
      final uploadedUrl =
          await _repository.uploadReceiptImage(_pickedImage!);
      if (uploadedUrl != null) {
        finalReceiptUrl = uploadedUrl;
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이미지 업로드 실패')),
          );
        }
        return;
      }
    }

    String methodToSave = _selectedMethod;
    if (_selectedMethod == '기타') {
      methodToSave =
          _customMethodController.text.trim();
      if (methodToSave.isEmpty) methodToSave = '기타';
    } else if (_selectedMethod.contains('카드')) {
      int installment = 1;
      if (_selectedInstallment == 'custom') {
        installment = int.tryParse(
              _customInstallmentController.text,
            ) ??
            1;
      } else {
        installment = int.parse(_selectedInstallment);
      }
      if (installment > 1) {
        methodToSave =
            '$_selectedMethod(${installment}개월)';
      }
    }

    final amount = int.tryParse(
          _amountController.text.replaceAll(',', ''),
        ) ??
        0;

        final txId =
        (widget.isExistingRecord && widget.initialData != null)
            ? widget.initialData!.id
            : const Uuid().v4();

    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;

    if (currentUser == null) {
      
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다. 다시 로그인해주세요.')),
        );
        Navigator.pop(context, false);
      }
      return;
    }

    final tx = TransactionModel(
      id: txId,
      userId: currentUser.id, 
      date: _selectedDate,
      amount: amount,
      storeName: _storeController.text,
      category: _categoryController.text.isEmpty
          ? '미분류'
          : _categoryController.text,
      method: methodToSave,
      receiptUrl: finalReceiptUrl,
      memo: _memoController.text,
      isTaxDeductible: _transactionType == 'expense'
          ? _isTaxDeductible
          : false,
      approvalNumber: _approvalNumController.text,
      cashReceiptType: _selectedMethod == '현금영수증'
          ? _cashReceiptType
          : null,
      accountId: 'ManualInput',
      transactionType: _transactionType,
      isVatExempt: _isVatExempt,
    );

    final success = widget.isExistingRecord
        ? await _repository.updateTransaction(tx)
        : await _repository.addTransaction(tx);

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장되었습니다!')),
      );
      Navigator.pop(context, true);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 4, bottom: 8, top: 24),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).hintColor,
        ),
      ),
    );
  }

  Widget _buildInputCard({required Widget child}) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: child,
    );
  }

  Widget _buildReceiptSection() {
    ImageProvider? imageProvider;
    bool hasImage = false;

    if (_pickedImage != null) {
      hasImage = true;
      if (kIsWeb) {
        imageProvider = NetworkImage(_pickedImage!.path);
      } else {
        imageProvider = FileImage(File(_pickedImage!.path));
      }
    } else if (widget.initialData?.receiptUrl != null) {
      hasImage = true;
      imageProvider =
          NetworkImage(widget.initialData!.receiptUrl!);
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness ==
                        Brightness.dark
                    ? Colors.black26
                    : Colors.grey[200],
                image: hasImage
                    ? DecorationImage(
                        image: imageProvider!,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: !hasImage
                  ? Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '영수증 사진을 등록해주세요',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      children: [
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: _clearImage,
                            child: Container(
                              padding:
                                  const EdgeInsets.all(6),
                              decoration:
                                  const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () =>
                      _pickImage(ImageSource.camera),
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                    size: 20,
                  ),
                  label: const Text('촬영하기'),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: Theme.of(context).dividerColor,
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () =>
                      _pickImage(ImageSource.gallery),
                  icon: const Icon(
                    Icons.photo_library_outlined,
                    size: 20,
                  ),
                  label: const Text('앨범에서 선택'),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBusiness = _userType.contains('business');
    final isEntertainment =
        _categoryController.text.contains('접대');

    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? Colors.white : Colors.black87;
    final hintColor =
        isDark ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.initialData == null ? '새 내역 입력' : '내역 수정',
        ),
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          if (widget.isExistingRecord)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              onPressed: _isLoading ? null : _delete,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                40,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    
                    _buildInputCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          DateFormat(
                            'yyyy년 MM월 dd일 (E)',
                            'ko_KR',
                          ).format(_selectedDate),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        trailing: Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                          color: hintColor,
                        ),
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildReceiptSection(),

                    _buildSectionTitle('거래 유형'),
                    Container(
                      margin:
                          const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius:
                            BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context)
                              .dividerColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _transactionType =
                                      'expense';
                                  _categoryController
                                      .clear();
                                  _selectedMethod =
                                      '개인카드';
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  vertical: 16,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: _transactionType ==
                                          'expense'
                                      ? Colors.red
                                          .withOpacity(0.1)
                                      : Colors
                                          .transparent,
                                  borderRadius:
                                      BorderRadius
                                          .circular(12),
                                  border: Border.all(
                                    color: _transactionType ==
                                            'expense'
                                        ? Colors.red
                                        : Colors
                                            .transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.arrow_upward,
                                      color: _transactionType ==
                                              'expense'
                                          ? Colors.red
                                          : Colors.grey,
                                      size: 28,
                                    ),
                                    const SizedBox(
                                        height: 4),
                                    Text(
                                      '지출',
                                      style: TextStyle(
                                        color: _transactionType ==
                                                'expense'
                                            ? Colors.red
                                            : Colors.grey,
                                        fontWeight:
                                            _transactionType ==
                                                    'expense'
                                                ? FontWeight
                                                    .bold
                                                : FontWeight
                                                    .normal,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _transactionType =
                                      'income';
                                  _categoryController
                                      .clear();
                                  _selectedMethod =
                                      '계좌입금';
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  vertical: 16,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: _transactionType ==
                                          'income'
                                      ? Colors.green
                                          .withOpacity(0.1)
                                      : Colors
                                          .transparent,
                                  borderRadius:
                                      BorderRadius
                                          .circular(12),
                                  border: Border.all(
                                    color: _transactionType ==
                                            'income'
                                        ? Colors.green
                                        : Colors
                                            .transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.arrow_downward,
                                      color: _transactionType ==
                                              'income'
                                          ? Colors.green
                                          : Colors.grey,
                                      size: 28,
                                    ),
                                    const SizedBox(
                                        height: 4),
                                    Text(
                                      '수입',
                                      style: TextStyle(
                                        color: _transactionType ==
                                                'income'
                                            ? Colors.green
                                            : Colors.grey,
                                        fontWeight:
                                            _transactionType ==
                                                    'income'
                                                ? FontWeight
                                                    .bold
                                                : FontWeight
                                                    .normal,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildSectionTitle('거래 정보'),
                    _buildInputCard(
                      child: Autocomplete<String>(
                        initialValue:
                            TextEditingValue(
                                text: _storeName),
                        optionsBuilder: (val) {
                          if (val.text.isEmpty) {
                            return const Iterable<
                                String>.empty();
                          }
                          return _storeSuggestions.where(
                            (opt) => opt.contains(val.text),
                          );
                        },
                        onSelected: (val) {
                          _storeController.text = val;
                          _storeName = val;
                        },
                        fieldViewBuilder: (ctx, controller,
                            focusNode, onSubmitted) {
                          _storeController = controller;
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            style: TextStyle(
                                color: textColor),
                            decoration:
                                InputDecoration(
                              labelText: '상호명',
                              border:
                                  InputBorder.none,
                              icon: Icon(
                                Icons.store_outlined,
                                size: 20,
                                color: hintColor,
                              ),
                              labelStyle: TextStyle(
                                  color: hintColor),
                            ),
                            validator: (val) =>
                                val == null ||
                                        val.isEmpty
                                    ? '필수 입력입니다'
                                    : null,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInputCard(
                      child: TextFormField(
                        controller: _amountController,
                        style:
                            TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: '금액',
                          suffixText: '원',
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.attach_money,
                            size: 20,
                            color: hintColor,
                          ),
                          labelStyle:
                              TextStyle(color: hintColor),
                          suffixStyle:
                              TextStyle(color: textColor),
                        ),
                        keyboardType:
                            TextInputType.number,
                        validator: (val) => val == null ||
                                val.isEmpty
                            ? '필수 입력입니다'
                            : null,
                      ),
                    ),

                    _buildSectionTitle(
                      _transactionType == 'income'
                          ? '입금 방법'
                          : '결제 수단',
                    ),
                    _buildInputCard(
                      child: DropdownButtonFormField<
                          String>(
                        value: _selectedMethod,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.payment,
                            size: 20,
                            color: hintColor,
                          ),
                        ),
                        items: (_transactionType ==
                                    'income'
                                ? _incomeMethods
                                : _paymentMethods)
                            .map(
                              (m) =>
                                  DropdownMenuItem(
                                value: m,
                                child: Text(
                                  m,
                                  style: TextStyle(
                                      color:
                                          textColor),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() {
                            _selectedMethod = val;
                          });
                        },
                        dropdownColor:
                            Theme.of(context)
                                .cardColor,
                      ),
                    ),

                    if (_transactionType ==
                            'expense' &&
                        _selectedMethod
                            .contains('카드')) ...[
                      const SizedBox(height: 12),
                      _buildInputCard(
                        child: Row(
                          children: [
                            Icon(
                              Icons.date_range,
                              size: 20,
                              color: hintColor,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child:
                                  DropdownButtonFormField<
                                      String>(
                                value:
                                    _selectedInstallment,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                ),
                                decoration:
                                    InputDecoration(
                                  labelText: '할부 개월',
                                  border:
                                      InputBorder
                                          .none,
                                  labelStyle: TextStyle(
                                      color:
                                          hintColor),
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: '1',
                                    child: Text(
                                      '일시불',
                                      style: TextStyle(
                                          color:
                                              textColor),
                                    ),
                                  ),
                                  ...List.generate(
                                          35,
                                          (i) =>
                                              (i + 2)
                                                  .toString())
                                      .map(
                                        (m) =>
                                            DropdownMenuItem(
                                          value: m,
                                          child: Text(
                                            '$m개월',
                                            style: TextStyle(
                                                color:
                                                    textColor),
                                          ),
                                        ),
                                      ),
                                  DropdownMenuItem(
                                    value: 'custom',
                                    child: Text(
                                      '직접 입력',
                                      style: TextStyle(
                                          color:
                                              textColor),
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val == null)
                                    return;
                                  setState(() {
                                    _selectedInstallment =
                                        val;
                                  });
                                },
                                dropdownColor:
                                    Theme.of(context)
                                        .cardColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (_transactionType ==
                            'expense' &&
                        _selectedMethod ==
                            '현금영수증') ...[
                      const SizedBox(height: 12),
                      Container(
                        padding:
                            const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .cardColor,
                          borderRadius:
                              BorderRadius.circular(
                                  12),
                          border: Border.all(
                            color: Theme.of(context)
                                .dividerColor,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Radio<String>(
                                  value: '지출증빙용',
                                  groupValue:
                                      _cashReceiptType,
                                  onChanged: (val) {
                                    if (val == null)
                                      return;
                                    setState(() {
                                      _cashReceiptType =
                                          val;
                                    });
                                  },
                                  activeColor:
                                      Colors.blueGrey,
                                ),
                                Text(
                                  '지출증빙 (사업자)',
                                  style: TextStyle(
                                      color:
                                          textColor),
                                ),
                                const SizedBox(
                                    width: 16),
                                Radio<String>(
                                  value: '소득공제용',
                                  groupValue:
                                      _cashReceiptType,
                                  onChanged: (val) {
                                    if (val == null)
                                      return;
                                    setState(() {
                                      _cashReceiptType =
                                          val;
                                    });
                                  },
                                  activeColor:
                                      Colors.blueGrey,
                                ),
                                Text(
                                  '소득공제 (개인)',
                                  style: TextStyle(
                                      color:
                                          textColor),
                                ),
                              ],
                            ),
                            const Divider(height: 1),
                            TextFormField(
                              controller:
                                  _approvalNumController,
                              style: TextStyle(
                                  color: textColor),
                              decoration:
                                  InputDecoration(
                                labelText:
                                    '승인번호 (선택)',
                                border:
                                    InputBorder.none,
                                icon: Icon(
                                  Icons.qr_code,
                                  size: 20,
                                  color: hintColor,
                                ),
                                labelStyle: TextStyle(
                                    color:
                                        hintColor),
                              ),
                              keyboardType:
                                  TextInputType
                                      .number,
                            ),
                          ],
                        ),
                      ),
                    ],

                    _buildSectionTitle('카테고리'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (_transactionType ==
                                  'income'
                              ? _incomeCategoryIcons
                              : _expenseCategoryIcons)
                          .map((cat) {
                        final isSelected =
                            _categoryController
                                    .text ==
                                cat['label'];
                        return ChoiceChip(
                          label: Text(cat['label']),
                          avatar: Icon(
                            cat['icon'],
                            size: 16,
                            color: isSelected
                                ? Colors.white
                                : hintColor,
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _categoryController
                                      .text =
                                  cat['label'];
                            });
                          },
                          selectedColor:
                              _transactionType ==
                                      'income'
                                  ? Colors
                                      .green[700]
                                  : Colors
                                      .blueGrey[700],
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : textColor,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          backgroundColor:
                              Theme.of(context)
                                  .cardColor,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    20),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors
                                      .transparent
                                  : Theme.of(context)
                                      .dividerColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    _buildInputCard(
                      child: TextFormField(
                        controller: _categoryController,
                        style:
                            TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: '직접 입력',
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.category_outlined,
                            size: 20,
                            color: hintColor,
                          ),
                          hintStyle:
                              TextStyle(color: hintColor),
                        ),
                        onChanged: (val) =>
                            setState(() {}),
                      ),
                    ),

                    if (isBusiness &&
                        _transactionType ==
                            'expense') ...[
                      _buildSectionTitle('세무 설정'),
                      SwitchListTile(
                        title: Text(
                          '부가세 공제 가능',
                          style: TextStyle(
                              color: textColor),
                        ),
                        value: _isTaxDeductible,
                        activeColor: Colors.green,
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 4,
                        ),
                        onChanged: (val) {
                          setState(() {
                            _isTaxDeductible = val;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: const Text(
                          '이 지출은 사업 관련 비용이에요',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          _isVatExempt
                              ? '개인/공제 제외 지출로 표시됩니다 (부가세 환급 계산에서 제외)'
                              : '사업 관련 지출로 보고 부가세 환급 계산에 포함합니다',
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        value: !_isVatExempt,
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 4,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _isVatExempt = !value;
                          });
                        },
                      ),
                    ],

                    const SizedBox(height: 12),

                    _buildInputCard(
                      child: TextFormField(
                        controller: _memoController,
                        style:
                            TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: '메모',
                          hintText: (isBusiness &&
                                  isEntertainment)
                              ? '참석자, 목적 입력'
                              : '내용 입력',
                          hintStyle: TextStyle(
                            color: (isBusiness &&
                                    isEntertainment)
                                ? Colors.redAccent
                                : hintColor,
                          ),
                          labelStyle:
                              TextStyle(color: hintColor),
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.note_alt_outlined,
                            size: 20,
                            color: hintColor,
                          ),
                        ),
                        maxLines: 3,
                      ),
                    ),

                    const SizedBox(height: 40),

                    PrimaryButton(
                      label: _isLoading ? '저장 중...' : '저장하기',
                      isLoading: _isLoading,
                      onPressed: _save,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
