
import 'package:expense_pro/features/recurring/data/recurring_transaction_repository.dart';
import 'package:expense_pro/features/recurring/data/recurring_transaction_model.dart';

class MonthlyForecast {
  final int expectedExpense; 
  final int expectedIncome;  

  MonthlyForecast({
    required this.expectedExpense,
    required this.expectedIncome,
  });

  int get expectedNet => expectedIncome - expectedExpense;
}

class MonthlyForecastService {
  final RecurringTransactionRepository _recRepo;

  MonthlyForecastService({RecurringTransactionRepository? recRepo})
      : _recRepo = recRepo ?? RecurringTransactionRepository();

  Future<MonthlyForecast> getThisMonthForecast() async {
    final list = await _recRepo.getMyRecurring();
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    int totalExpense = 0;
    int totalIncome = 0;

    int countWeekdayInMonth(int weekday) {
      
      if (weekday < 1 || weekday > 7) {
        
        return 0;
      }
      var d = DateTime(year, month, 1);
      int count = 0;
      while (d.month == month) {
        if (d.weekday == weekday) count++;
        d = d.add(const Duration(days: 1));
      }
      return count;
    }

    for (final r in list) {
      int occurrences = 0;

      if (r.cycle == 'monthly') {
        
        occurrences = 1;
      } else if (r.cycle == 'weekly') {
        
        occurrences = countWeekdayInMonth(r.day);
      } else {
        
        occurrences = 0;
      }

      final totalForThisMonth = r.amount * occurrences;

      if (r.transactionType == 'expense') {
        totalExpense += totalForThisMonth;
      } else {
        
        totalIncome += totalForThisMonth;
      }
    }

    return MonthlyForecast(
      expectedExpense: totalExpense,
      expectedIncome: totalIncome,
    );
  }
}
