import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/persian_date_formatter.dart';
import '../../transactions/application/transactions_providers.dart';
import '../data/budgets_repository.dart';

final budgetsRepositoryProvider = Provider<BudgetsRepository>((ref) {
  return BudgetsRepository(ref.watch(appDatabaseProvider));
});

final budgetsListProvider = StreamProvider<List<BudgetData>>((ref) {
  return ref.watch(budgetsRepositoryProvider).watchAll();
});

class BudgetProgress {
  const BudgetProgress({
    required this.budget,
    required this.spent,
  });

  final BudgetData budget;
  final double spent;

  double get percentage => budget.amount <= 0
      ? 0
      : (spent / budget.amount).clamp(0.0, 999.0);

  double get remaining => budget.amount - spent;

  bool get isExceeded => spent > budget.amount;
}

final budgetProgressListProvider = Provider<List<BudgetProgress>>((ref) {
  final budgets = ref.watch(budgetsListProvider).valueOrNull ?? [];
  final transactions =
      ref.watch(currentMonthTransactionsProvider).valueOrNull ?? [];

  return budgets.map((budget) {
    final now = DateTime.now();
    final periodStart = PersianDateFormatter.startOfJalaliMonth(now);
    final periodEnd = PersianDateFormatter.endOfJalaliMonth(now);

    final spent = transactions
        .where((tx) =>
            tx.categoryId == budget.categoryId &&
            tx.type == 'expense' &&
            !tx.date.isBefore(periodStart) &&
            !tx.date.isAfter(periodEnd))
        .fold<double>(0, (sum, tx) => sum + tx.amount);

    return BudgetProgress(budget: budget, spent: spent);
  }).toList();
});
