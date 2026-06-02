class TransactionModel {
  final String id;
  final String userId; 
  final DateTime date;
  final int amount;
  final String transactionType; 
  final String storeName;
  final String? category;
  final String method;
  final String accountId; 
  final bool isPaid;
  final String? receiptUrl;
  final bool isTaxDeductible;
  final String? memo;
  final String? approvalNumber; 
  final String? cashReceiptType; 
  final bool? isVatExempt;
  
  TransactionModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.amount,
    required this.storeName,
    this.transactionType = 'expense', 
    required this.accountId,
    this.isPaid = true, 
    this.category,
    this.method = '카드',
    this.receiptUrl,
    this.isTaxDeductible = true,
    this.memo,
    this.approvalNumber,
    this.cashReceiptType,
    this.isVatExempt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? 'unknown',
      date: DateTime.tryParse(json['transaction_date'] ?? '') ?? DateTime.now(),
      amount: json['amount'] ?? 0,
      
      transactionType: json['transaction_type'] ?? 'expense', 
      accountId: json['account_id'] ?? 'unknown',
      isPaid: json['is_paid'] ?? true,
      
      storeName: json['store_name'] ?? '상호명 없음',
      category: json['category'],
      method: json['method'] ?? '카드',
      receiptUrl: json['receipt_image_url'],
      isTaxDeductible: json['is_tax_deductible'] ?? true,
      memo: json['memo'],
      approvalNumber: json['approval_number'],
      cashReceiptType: json['cash_receipt_type'],
      isVatExempt: json['is_vat_exempt'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      
      'user_id': userId, 
      
      'transaction_date': date.toIso8601String(),
      'amount': amount,
      
      'transaction_type': transactionType,
      'account_id': accountId,
      'is_paid': isPaid,
      'store_name': storeName,
      'category': category,
      'method': method,
      'receipt_image_url': receiptUrl,
      'is_tax_deductible': isTaxDeductible,
      'memo': memo,
      'approval_number': approvalNumber,
      'cash_receipt_type': cashReceiptType,
      'is_vat_exempt': isVatExempt ?? false,
    };
  }
}
