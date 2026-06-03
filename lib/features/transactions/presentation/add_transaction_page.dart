import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_pro/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/providers/country_config_provider.dart';
import '../../../core/config/transaction_options.dart';

import '../data/transaction_model.dart';
import '../data/transaction_repository.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
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
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
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

  late TxOptions _opts;
  bool _isKorea = true;
  late String _selectedMethod;
  String _selectedInstallment = '1';
  String _cashReceiptType = '지출증빙용';

  List<String> _storeSuggestions = [];
  XFile? _pickedImage;

  List<String> get _paymentMethods => _opts.expensePaymentMethods;
  List<String> get _incomeMethods => _opts.incomeMethods;
  List<Map<String, dynamic>> get _expenseCategoryIcons => _opts.expenseCategories;
  List<Map<String, dynamic>> get _incomeCategoryIcons => _opts.incomeCategories;

  @override
  void initState() {
    super.initState();
    final countryCode = ref.read(countryConfigProvider).countryCode;
    _isKorea = countryCode == 'KR';
    _opts = TxOptions.forCountry(countryCode);
    _selectedMethod = _opts.defaultExpenseMethod;

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
        _selectedMethod = _opts.otherMethod;
        _customMethodController.text = method;
      }

      if (data.cashReceiptType != null) {
        _cashReceiptType = data.cashReceiptType!;
      }
    } else {
      _selectedMethod = _transactionType == 'income'
          ? _opts.defaultIncomeMethod
          : _opts.defaultExpenseMethod;
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
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _delete() async {
    if (!widget.isExistingRecord || widget.initialData == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final dl = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(dl.addTransactionDeleteConfirmTitle),
          content: Text(dl.addTransactionDeleteConfirmContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(dl.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                dl.delete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final success =
        await _repository.deleteTransaction(widget.initialData!.id);
    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.addTransactionDeleted)),
      );
      Navigator.pop(context, true);
    }
  }

  bool _needsReceiptForCurrentForm() {
    if (!_isKorea) return false; // Korea-specific receipt rules
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
        SnackBar(content: Text(AppLocalizations.of(context)!.addTransactionStoreName)),
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
        builder: (context) {
          final dl = AppLocalizations.of(context)!;
          return AlertDialog(
            title: Text('⚠️ ${dl.addTransactionReceiptRequired}'),
            content: Text(dl.addTransactionReceiptRequiredContent),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(dl.addTransactionReceiptAttach),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  dl.addTransactionSaveAnyway,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );
      if (confirm != true) return;
    } else if (!hasExistingReceipt &&
        !hasNewImage &&
        _userType.contains('corporate')) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) {
          final dl = AppLocalizations.of(context)!;
          return AlertDialog(
            title: Text('⚠️ ${dl.addTransactionCorporateReceiptWarning}'),
            content: Text(dl.addTransactionCorporateReceiptContent),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(dl.addTransactionReceiptAttach),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  dl.addTransactionSaveAnyway,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
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
            SnackBar(content: Text(AppLocalizations.of(context)!.addTransactionImageUploadFailed)),
          );
        }
        return;
      }
    }

    String methodToSave = _selectedMethod;
    if (_selectedMethod == _opts.otherMethod) {
      methodToSave =
          _customMethodController.text.trim();
      if (methodToSave.isEmpty) methodToSave = _opts.otherMethod;
    } else if (_isKorea && _opts.isCardMethod(_selectedMethod)) {
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
          SnackBar(content: Text(AppLocalizations.of(context)!.addTransactionLoginRequired)),
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
          ? AppLocalizations.of(context)!.addTransactionUncategorized
          : _categoryController.text,
      method: methodToSave,
      receiptUrl: finalReceiptUrl,
      memo: _memoController.text,
      isTaxDeductible: _transactionType == 'expense'
          ? _isTaxDeductible
          : false,
      approvalNumber: _approvalNumController.text,
      cashReceiptType: _opts.isCashReceipt(_selectedMethod)
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
        SnackBar(content: Text(AppLocalizations.of(context)!.addTransactionSaved)),
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
                          AppLocalizations.of(context)!.addTransactionReceiptPrompt,
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
                  label: Text(AppLocalizations.of(context)!.addTransactionReceiptTake),
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
                  label: Text(AppLocalizations.of(context)!.addTransactionReceiptFromGallery),
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
    final isEntertainment = _isKorea &&
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
          widget.initialData == null
              ? AppLocalizations.of(context)!.addTransactionNew
              : AppLocalizations.of(context)!.addTransactionEdit,
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
                          _isKorea
                              ? DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR')
                                  .format(_selectedDate)
                              : DateFormat.yMMMMEEEEd(
                                      Localizations.localeOf(context)
                                          .toString())
                                  .format(_selectedDate),
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

                    _buildSectionTitle(AppLocalizations.of(context)!.addTransactionType),
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
                                      _opts.defaultExpenseMethod;
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
                                      AppLocalizations.of(context)!.addTransactionExpense,
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
                                      _opts.defaultIncomeMethod;
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
                                      AppLocalizations.of(context)!.addTransactionIncome,
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

                    _buildSectionTitle(AppLocalizations.of(context)!.addTransactionInfo),
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
                              labelText: AppLocalizations.of(context)!.addTransactionStoreName,
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
                                    ? AppLocalizations.of(context)!.addTransactionStoreNameRequired
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
                          labelText: AppLocalizations.of(context)!.addTransactionAmountLabel,
                          suffixText: AppLocalizations.of(context)!.addTransactionAmountUnit,
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
                            ? AppLocalizations.of(context)!.addTransactionAmountRequired
                            : null,
                      ),
                    ),

                    _buildSectionTitle(
                      _transactionType == 'income'
                          ? AppLocalizations.of(context)!.addTransactionDepositMethod
                          : AppLocalizations.of(context)!.addTransactionPaymentMethod,
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

                    if (_isKorea &&
                        _transactionType == 'expense' &&
                        _opts.isCardMethod(_selectedMethod)) ...[
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
                                  labelText: AppLocalizations.of(context)!.addTransactionInstallment,
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
                                      AppLocalizations.of(context)!.addTransactionInstallmentOnce,
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
                                            AppLocalizations.of(context)!.addTransactionInstallmentMonths(m),
                                            style: TextStyle(
                                                color:
                                                    textColor),
                                          ),
                                        ),
                                      ),
                                  DropdownMenuItem(
                                    value: 'custom',
                                    child: Text(
                                      AppLocalizations.of(context)!.addTransactionInstallmentCustom,
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

                    if (_transactionType == 'expense' &&
                        _opts.isCashReceipt(_selectedMethod)) ...[
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
                                  AppLocalizations.of(context)!.addTransactionCashReceiptBusiness,
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
                                  AppLocalizations.of(context)!.addTransactionCashReceiptPersonal,
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
                                    AppLocalizations.of(context)!.addTransactionApprovalNumber,
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

                    _buildSectionTitle(AppLocalizations.of(context)!.addTransactionCategoryLabel),
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
                          hintText: AppLocalizations.of(context)!.addTransactionCategoryDirectInput,
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
                      _buildSectionTitle(AppLocalizations.of(context)!.addTransactionTaxSettings),
                      SwitchListTile(
                        title: Text(
                          AppLocalizations.of(context)!.addTransactionVatDeductible,
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
                        title: Text(
                          AppLocalizations.of(context)!.addTransactionBusinessExpense,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          _isVatExempt
                              ? AppLocalizations.of(context)!.addTransactionBusinessExpenseOffSub
                              : AppLocalizations.of(context)!.addTransactionBusinessExpenseOnSub,
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
                          labelText: AppLocalizations.of(context)!.addTransactionMemoLabel,
                          hintText: (isBusiness &&
                                  isEntertainment)
                              ? AppLocalizations.of(context)!.addTransactionMemoHintEntertainment
                              : AppLocalizations.of(context)!.addTransactionMemoHint,
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
                      label: _isLoading
                          ? AppLocalizations.of(context)!.addTransactionSaving
                          : AppLocalizations.of(context)!.addTransactionSave,
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
