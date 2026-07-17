import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/persian_date_formatter.dart';
import '../../../shared/models/transaction_type.dart';
import '../../accounts/application/accounts_providers.dart';
import '../../categories/application/categories_providers.dart';
import '../data/transactions_repository.dart';
import '../domain/transaction_model.dart';

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return TransactionsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(accountsRepositoryProvider),
  );
});

final allTransactionsProvider = StreamProvider<List<TransactionData>>((ref) {
  return ref.watch(transactionsRepositoryProvider).watchAll();
});

final recentTransactionsProvider =
    StreamProvider<List<TransactionData>>((ref) {
  return ref.watch(transactionsRepositoryProvider).watchRecent(limit: 6);
});

final currentMonthTransactionsProvider =
    StreamProvider<List<TransactionData>>((ref) {
  final now = DateTime.now();
  final start = PersianDateFormatter.startOfJalaliMonth(now);
  final end = PersianDateFormatter.endOfJalaliMonth(now);
  return ref.watch(transactionsRepositoryProvider).watchInRange(start, end);
});

final monthlyTotalsProvider = Provider<MonthlyTotals>((ref) {
  final transactions =
      ref.watch(currentMonthTransactionsProvider).valueOrNull ?? [];
  double income = 0;
  double expense = 0;
  for (final tx in transactions) {
    final type = TransactionTypeX.fromStorage(tx.type);
    if (type == TransactionType.income) {
      income += tx.amount;
    } else if (type == TransactionType.expense) {
      expense += tx.amount;
    }
  }
  return MonthlyTotals(income: income, expense: expense);
});

class MonthlyTotals {
  const MonthlyTotals({required this.income, required this.expense});

  final double income;
  final double expense;

  double get net => income - expense;
}

final categoriesByIdProvider = Provider<Map<String, CategoryData>>((ref) {
  final categories = ref.watch(allCategoriesProvider).valueOrNull ?? [];
  return {for (final category in categories) category.id: category};
});

final accountsByIdProvider = Provider<Map<String, AccountData>>((ref) {
  final accounts = ref.watch(accountsListProvider).valueOrNull ?? [];
  return {for (final account in accounts) account.id: account};
});

final transactionFilterProvider =
    StateProvider<TransactionFilter>((ref) => const TransactionFilter());

final sortOptionProvider =
    StateProvider<SortOption>((ref) => SortOption.newest);

final filteredTransactionsProvider = Provider<List<TransactionData>>((ref) {
  final transactions = ref.watch(allTransactionsProvider).valueOrNull ?? [];
  final filter = ref.watch(transactionFilterProvider);
  final sortOption = ref.watch(sortOptionProvider);
  final categoriesById = ref.watch(categoriesByIdProvider);
  final repository = ref.watch(transactionsRepositoryProvider);

  var result = repository.applyFilter(transactions, filter, categoriesById);
  result = _applyDateFilter(result, filter);
  return repository.applySort(result, sortOption);
});

List<TransactionData> _applyDateFilter(
    List<TransactionData> transactions, TransactionFilter filter) {
  final now = DateTime.now();
  DateTime? start;
  DateTime? end;
  switch (filter.dateFilter) {
    case TransactionDateFilter.all:
      return transactions;
    case TransactionDateFilter.today:
      start = DateTime(now.year, now.month, now.day);
      end = start.add(const Duration(days: 1));
      break;
    case TransactionDateFilter.thisWeek:
      start = PersianDateFormatter.startOfWeek(now);
      end = start.add(const Duration(days: 7));
      break;
    case TransactionDateFilter.thisMonth:
      start = PersianDateFormatter.startOfJalaliMonth(now);
      end = PersianDateFormatter.endOfJalaliMonth(now);
      break;
    case TransactionDateFilter.thisYear:
      start = PersianDateFormatter.startOfJalaliYear(now);
      end = now.add(const Duration(days: 1));
      break;
    case TransactionDateFilter.custom:
      start = filter.customStart;
      end = filter.customEnd;
      break;
  }
  if (start == null || end == null) return transactions;
  return transactions
      .where((tx) => tx.date.isAfter(start!) && tx.date.isBefore(end!))
      .toList();
}
