import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/persian_date_formatter.dart';
import '../../transactions/application/transactions_providers.dart';
import '../domain/report_period.dart';

final reportPeriodProvider = StateProvider<ReportPeriod>(
    (ref) => ReportPeriod.monthly);

class ReportRange {
  const ReportRange(this.start, this.end);
  final DateTime start;
  final DateTime end;
}

ReportRange rangeForPeriod(ReportPeriod period, DateTime reference) {
  switch (period) {
    case ReportPeriod.daily:
      final start = DateTime(reference.year, reference.month, reference.day);
      return ReportRange(start, start.add(const Duration(days: 1)));
    case ReportPeriod.weekly:
      final start = PersianDateFormatter.startOfWeek(reference);
      return ReportRange(start, start.add(const Duration(days: 7)));
    case ReportPeriod.monthly:
      return ReportRange(
        PersianDateFormatter.startOfJalaliMonth(reference),
        PersianDateFormatter.endOfJalaliMonth(reference),
      );
    case ReportPeriod.yearly:
      final start = PersianDateFormatter.startOfJalaliYear(reference);
      final jalali = PersianDateFormatter.toJalali(reference);
      final end = DateTime(jalali.year + 1, start.month, start.day)
          .subtract(const Duration(seconds: 1));
      return ReportRange(start, end);
  }
}

final reportTransactionsProvider = Provider<List<TransactionData>>((ref) {
  final period = ref.watch(reportPeriodProvider);
  final range = rangeForPeriod(period, DateTime.now());
  final all = ref.watch(allTransactionsProvider).valueOrNull ?? [];
  return all
      .where((tx) => !tx.date.isBefore(range.start) && tx.date.isBefore(range.end))
      .toList();
});

class CategoryReportEntry {
  const CategoryReportEntry(
      {required this.category, required this.total});
  final CategoryData category;
  final double total;
}

final categoryReportProvider = Provider<List<CategoryReportEntry>>((ref) {
  final transactions = ref.watch(reportTransactionsProvider);
  final categoriesById = ref.watch(categoriesByIdProvider);

  final totals = <String, double>{};
  for (final tx in transactions) {
    if (tx.type != 'expense') continue;
    totals.update(tx.categoryId, (value) => value + tx.amount,
        ifAbsent: () => tx.amount);
  }

  final entries = totals.entries
      .where((entry) => categoriesById.containsKey(entry.key))
      .map((entry) =>
          CategoryReportEntry(category: categoriesById[entry.key]!, total: entry.value))
      .toList()
    ..sort((a, b) => b.total.compareTo(a.total));

  return entries;
});

class IncomeExpenseSummary {
  const IncomeExpenseSummary({required this.income, required this.expense});
  final double income;
  final double expense;
  double get net => income - expense;
  double get savingsRate => income <= 0 ? 0 : (net / income).clamp(-5.0, 1.0);
}

final incomeExpenseSummaryProvider = Provider<IncomeExpenseSummary>((ref) {
  final transactions = ref.watch(reportTransactionsProvider);
  double income = 0;
  double expense = 0;
  for (final tx in transactions) {
    if (tx.type == 'income') {
      income += tx.amount;
    } else if (tx.type == 'expense') {
      expense += tx.amount;
    }
  }
  return IncomeExpenseSummary(income: income, expense: expense);
});

class CashFlowPoint {
  const CashFlowPoint({required this.label, required this.net});
  final String label;
  final double net;
}

final cashFlowTrendProvider = Provider<List<CashFlowPoint>>((ref) {
  final all = ref.watch(allTransactionsProvider).valueOrNull ?? [];
  final now = DateTime.now();
  final points = <CashFlowPoint>[];

  for (var i = 5; i >= 0; i--) {
    final jalali = PersianDateFormatter.toJalali(now);
    var year = jalali.year;
    var month = jalali.month - i;
    while (month <= 0) {
      month += 12;
      year -= 1;
    }
    final monthTransactions = all.where((tx) {
      final txJalali = PersianDateFormatter.toJalali(tx.date);
      return txJalali.year == year && txJalali.month == month;
    });
    double net = 0;
    for (final tx in monthTransactions) {
      if (tx.type == 'income') {
        net += tx.amount;
      } else if (tx.type == 'expense') {
        net -= tx.amount;
      }
    }
    points.add(CashFlowPoint(
      label: PersianDateFormatter.monthName(month).substring(0, 3),
      net: net,
    ));
  }
  return points;
});
