import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_pro/core/utils/app_logger.dart';
import '../../features/transactions/data/transaction_model.dart';
import '../../features/transactions/data/transaction_repository.dart';

class BackupService {
  final TransactionRepository _repository = TransactionRepository();
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<bool> autoBackup() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final transactions = await _repository.getTransactions();
      final backupData = {
        'user_id': userId,
        'backup_data': jsonEncode(transactions.map((t) => t.toJson()).toList()),
        'backup_date': DateTime.now().toIso8601String(),
        'transaction_count': transactions.length,
      };

      await _supabase.from('backups').insert(backupData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_backup_date', DateTime.now().toIso8601String());

      return true;
    } catch (e) {
      appLogger.e("자동 백업 실패: $e", error: e);
      return false;
    }
  }

  Future<String?> createBackupFile() async {
    try {
      final transactions = await _repository.getTransactions();
      final backupData = {
        'version': '1.0',
        'backup_date': DateTime.now().toIso8601String(),
        'transaction_count': transactions.length,
        'transactions': transactions.map((t) => t.toJson()).toList(),
      };

      final jsonString = jsonEncode(backupData);
      return jsonString;
    } catch (e) {
      appLogger.e("백업 파일 생성 실패: $e", error: e);
      return null;
    }
  }

  Future<bool> restoreFromBackup(String backupJson) async {
    try {
      final backupData = jsonDecode(backupJson);
      final transactionsData = backupData['transactions'] as List;

      final transactions = transactionsData.map((json) {
        
        return TransactionModel(
          id: json['id'] ?? '',
          userId: json['user_id'] ?? '',
          date: DateTime.parse(json['transaction_date'] ?? DateTime.now().toIso8601String()),
          amount: json['amount'] ?? 0,
          storeName: json['store_name'] ?? '',
          category: json['category'],
          method: json['method'] ?? '카드',
          receiptUrl: json['receipt_image_url'],
          isTaxDeductible: json['is_tax_deductible'] ?? true,
          memo: json['memo'],
          approvalNumber: json['approval_number'],
          cashReceiptType: json['cash_receipt_type'],
          transactionType: json['transaction_type'] ?? 'expense',
          accountId: json['account_id'] ?? 'unknown',
          isPaid: json['is_paid'] ?? true,
        );
      }).toList();

      for (var tx in transactions) {
        await _repository.addTransaction(tx);
      }

      return true;
    } catch (e) {
      appLogger.e("복원 실패: $e", error: e);
      return false;
    }
  }

  Future<DateTime?> getLastBackupDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateString = prefs.getString('last_backup_date');
      if (dateString == null) return null;
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getBackupHistory() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('backups')
          .select()
          .eq('user_id', userId)
          .order('backup_date', ascending: false)
          .limit(10);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      appLogger.e("백업 이력 조회 실패: $e", error: e);
      return [];
    }
  }
}
