import 'package:supabase_flutter/supabase_flutter.dart';
import 'recurring_transaction_model.dart';
import 'package:expense_pro/core/utils/app_logger.dart';

class RecurringTransactionRepository {
  final _client = Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  Future<List<RecurringTransactionModel>> getMyRecurring({bool onlyActive = true}) async {
    final uid = _userId;
    if (uid == null) return [];

    var query = _client
        .from('recurring_transactions')
        .select()
        .eq('user_id', uid);

    if (onlyActive) {
      query = query.eq('is_active', true);
    }

    final res = await query.order('created_at', ascending: true);

    return (res as List)
        .map((row) => RecurringTransactionModel.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<bool> addRecurring(RecurringTransactionModel model) async {
    try {
      await _client.from('recurring_transactions').insert(model.toMap());
      return true;
    } catch (e) {
      appLogger.e('addRecurring error: $e', error: e);
      return false;
    }
  }

  Future<bool> updateRecurring(RecurringTransactionModel model) async {
    try {
      await _client
          .from('recurring_transactions')
          .update(model.toMap())
          .eq('id', model.id);
      return true;
    } catch (e) {
      appLogger.e('updateRecurring error: $e', error: e);
      return false;
    }
  }

  Future<bool> deleteRecurring(String id) async {
    try {
      await _client
          .from('recurring_transactions')
          .delete()
          .eq('id', id);
      return true;
    } catch (e) {
      appLogger.e('deleteRecurring error: $e', error: e);
      return false;
    }
  }

  Future<List<RecurringTransactionModel>> getDueToday() async {
    final uid = _userId;
    if (uid == null) return [];

    final today = DateTime.now();
    final weekday = today.weekday;
    final dayOfMonth = today.day;

    final res = await _client
        .from('recurring_transactions')
        .select()
        .eq('user_id', uid)
        .eq('is_active', true) 
        .or('cycle.eq.monthly,cycle.eq.weekly');

    final list = (res as List)
        .map((row) => RecurringTransactionModel.fromMap(
              row as Map<String, dynamic>,
            ))
        .toList();

    return list.where((r) {
      
      if (r.lastAppliedDate != null) {
        final last = DateTime(
          r.lastAppliedDate!.year,
          r.lastAppliedDate!.month,
          r.lastAppliedDate!.day,
        );
        final now = DateTime(today.year, today.month, today.day);
        if (last.isAtSameMomentAs(now)) return false;
      }

      if (r.cycle == 'monthly') return r.day == dayOfMonth;
      if (r.cycle == 'weekly') return r.day == weekday;
      return false;
    }).toList();
  }

  Future<void> markAsAppliedToday(String id) async {
    await _client
        .from('recurring_transactions')
        .update({
          'last_applied_date': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }
}
