
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../data/recurring_transaction_model.dart';
import '../data/recurring_transaction_repository.dart';
import '../../transactions/data/transaction_model.dart';
import '../../transactions/data/transaction_repository.dart';

class RecurringService {
  final RecurringTransactionRepository _recRepo;
  final TransactionRepository _txRepo;

  RecurringService({
    RecurringTransactionRepository? recRepo,
    TransactionRepository? txRepo,
  })  : _recRepo = recRepo ?? RecurringTransactionRepository(),
        _txRepo = txRepo ?? TransactionRepository();

  Future<void> runAutoApplyForToday() async {
    
    final dueList = await _recRepo.getDueToday();
    if (dueList.isEmpty) return;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    for (final r in dueList) {
      final tx = TransactionModel(
        id: const Uuid().v4(),
        userId: userId,
        date: DateTime.now(),
        amount: r.amount,
        storeName: r.title, 
        category: r.category ?? '미분류',
        method: r.method ?? '기타',
        receiptUrl: null,
        memo: r.memo ?? '',
        transactionType: r.transactionType, 
        accountId: 'Recurring',
        isPaid: true,
        isTaxDeductible: r.transactionType == 'expense'
            ? (r.isTaxDeductible ?? true)
            : false,
      );

      await _txRepo.addTransaction(tx);
      await _recRepo.markAsAppliedToday(r.id);
    }
  }
}
