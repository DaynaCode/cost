import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/persian_number_formatter.dart';

class ExpensePieChart extends StatelessWidget {
  const ExpensePieChart({
    super.key,
    required this.transactions,
    required this.categoriesById,
  });

  final List<TransactionData> transactions;
  final Map<String, CategoryData> categoriesById;

  @override
  Widget build(BuildContext context) {
    final expenseByCategory = <String, double>{};
    for (final tx in transactions) {
      if (tx.type != 'expense') continue;
      expenseByCategory.update(tx.categoryId, (value) => value + tx.amount,
          ifAbsent: () => tx.amount);
    }

    if (expenseByCategory.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'هنوز هزینه ای برای این ماه ثبت نشده است',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final total = expenseByCategory.values.fold<double>(0, (a, b) => a + b);
    final entries = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 36,
              sections: entries.map((entry) {
                final category = categoriesById[entry.key];
                final color = category != null
                    ? Color(category.colorValue)
                    : Colors.grey;
                final percentage = (entry.value / total * 100);
                return PieChartSectionData(
                  color: color,
                  value: entry.value,
                  title: '${percentage.round()}%',
                  radius: 32,
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: entries.take(5).map((entry) {
              final category = categoriesById[entry.key];
              final color =
                  category != null ? Color(category.colorValue) : Colors.grey;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category?.name ?? 'سایر',
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      PersianNumberFormatter.formatAmount(entry.value),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
