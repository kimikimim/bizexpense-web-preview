import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'transaction_model.dart';
import 'package:expense_pro/core/utils/app_logger.dart';

class TransactionRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Map<String, dynamic> _toDbJson(
    TransactionModel tx, {
    required String userId,
    String? currencyCode,
  }) {
    return {
      'user_id': userId,
      'store_name': tx.storeName,
      'amount': tx.amount,
      'transaction_date': tx.date.toIso8601String(),
      'transaction_type': tx.transactionType,
      'category': tx.category,
      'method': tx.method,
      'receipt_image_url': tx.receiptUrl,
      'memo': tx.memo,
      'is_tax_deductible': tx.isTaxDeductible,
      'approval_number': tx.approvalNumber,
      'cash_receipt_type': tx.cashReceiptType,
      // Only sent for non-KR; KR tables have no currency_code column.
      if (currencyCode != null) 'currency_code': currencyCode,
    };
  }

  Future<List<TransactionModel>> getTransactions() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return [];
      }

      final data = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', user.id) 
          .order('transaction_date', ascending: false);

      return (data as List)
          .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      appLogger.e("데이터 에러: $e", error: e);
      return [];
    }
  }

  Future<bool> addTransaction(TransactionModel tx, {String? currencyCode}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final payload = _toDbJson(tx, userId: userId, currencyCode: currencyCode);
      await _supabase.from('transactions').insert(payload);
      return true;
    } catch (e) {
      appLogger.e("저장 에러: $e", error: e);
      return false;
    }
  }

  Future<bool> updateTransaction(TransactionModel tx, {String? currencyCode}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final payload = _toDbJson(tx, userId: userId, currencyCode: currencyCode);
      await _supabase
          .from('transactions')
          .update(payload)
          .eq('id', tx.id)
          .eq('user_id', userId); 

      return true;
    } catch (e) {
      appLogger.e("수정 에러: $e", error: e);
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase
          .from('transactions')
          .delete()
          .eq('id', id)
          .eq('user_id', userId); 
      return true;
    } catch (e) {
      appLogger.e("삭제 에러: $e", error: e);
      return false;
    }
  }

  Future<String?> uploadReceiptImage(XFile imageFile) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_receipt.jpg';
      final bytes = await imageFile.readAsBytes();
      await _supabase.storage.from('receipts').uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
      return _supabase.storage.from('receipts').getPublicUrl(fileName);
    } catch (e) {
      appLogger.e("이미지 업로드 에러: $e", error: e);
      return null;
    }
  }

  Future<List<String>> getAllStoreNames() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final data = await _supabase
          .from('transactions')
          .select('store_name')
          .eq('user_id', userId);

      final set = <String>{};
      for (final item in data as List) {
        final name = item['store_name'] as String?;
        if (name != null && name.isNotEmpty) {
          set.add(name);
        }
      }
      return set.toList();
    } catch (e) {
      appLogger.e("상호명 로드 실패: $e", error: e);
      return [];
    }
  }
}
