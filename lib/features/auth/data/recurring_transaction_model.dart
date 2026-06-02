import 'package:uuid/uuid.dart';

class RecurringTransactionModel {
  final String id;
  final String userId;
  final String title;              
  final int amount;
  final String transactionType;    
  final String cycle;              
  final int day;                   
  final String? category;
  final String? method;
  final String? memo;
  final bool? isTaxDeductible;
  final bool isActive;
  final DateTime? lastAppliedDate;
  final DateTime? createdAt;

  RecurringTransactionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.transactionType,
    required this.cycle,
    required this.day,
    this.category,
    this.method,
    this.memo,
    this.isTaxDeductible,
    this.lastAppliedDate,
    this.createdAt,
    this.isActive = true,
  });

  factory RecurringTransactionModel.fromMap(Map<String, dynamic> map) {
    return RecurringTransactionModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      
      title: (map['title'] ?? map['store_name'] ?? '') as String,
      amount: map['amount'] as int,
      
      transactionType:
          (map['transaction_type'] ?? map['type'] ?? 'expense') as String,
      cycle: (map['cycle'] ?? 'monthly') as String,
      day: (map['day'] ?? 1) as int,
      category: map['category'] as String?,
      method: map['method'] as String?,
      memo: map['memo'] as String?,
      isTaxDeductible: map['is_tax_deductible'] as bool?,
      isActive: (map['is_active'] as bool?) ?? true,
      lastAppliedDate: map['last_applied_date'] != null
          ? DateTime.parse(map['last_applied_date'] as String)
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final now = DateTime.now();
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'store_name': title,
      'amount': amount,
      
      'transaction_type': transactionType,
      
      'type': transactionType,
      'cycle': cycle,
      'day': day,
      'category': category,
      'method': method,
      'memo': memo,
      'is_tax_deductible': isTaxDeductible,
      'is_active': isActive,
      'last_applied_date': lastAppliedDate?.toIso8601String(),
      'created_at': (createdAt ?? now).toIso8601String(),
    };
  }

  factory RecurringTransactionModel.newForInsert({
    required String userId,
    required String title,
    required int amount,
    required String transactionType,
    required String cycle,
    required int day,
    String? category,
    String? method,
    String? memo,
    bool? isTaxDeductible,
  }) {
    final now = DateTime.now();
    return RecurringTransactionModel(
      id: const Uuid().v4(),
      userId: userId,
      title: title,
      amount: amount,
      transactionType: transactionType,
      cycle: cycle,
      day: day,
      category: category,
      method: method,
      memo: memo,
      isTaxDeductible: isTaxDeductible,
      lastAppliedDate: null,
      createdAt: now,
    );
  }
}
