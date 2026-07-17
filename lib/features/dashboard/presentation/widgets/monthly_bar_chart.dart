import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/persian_date_formatter.dart';

class MonthlyBarChart extends StatelessWidget {
  const MonthlyBarChart({super.key, required this.transactions});

  final List<TransactionData> transactions;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = List.generate(6, (index) {
      final jalali = PersianDateFormatter.toJalali(now);
      var year = jalali.year;
      var month = jalali.month - (5 - index);
      while (month <= 0) {
        month += 12;
        year -= 1;
      }
      return _MonthBucket(year: year, month: month);
    });

    for (final tx in transactions) {
      final jalali = PersianDateFormatter.toJalali(tx.date);
      final bucket = months.firstWhere(
        (m) => m.year == jalali.year && m.month == jalali.month,
        orElse: () => _MonthBucket(year: -1, month: -1),
      );
      if (bucket.year == -1) continue;
      if (tx.type == 'income') {
        bucket.income += tx.amount;
      } else if (tx.type == 'expense') {
        bucket.expense += tx.amount;
      }
    }

    final maxValue = months.fold<double>(
        1, (max, m) => [max, m.income, m.expense].reduce((a, b) => a > b ? a : b));

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxValue * 1.2,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= months.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      PersianDateFormatter.monthName(months[index].month)
                          .substring(0, 3),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: months.asMap().entries.map((entry) {
            final index = entry.key;
            final bucket = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: bucket.income,
                  color: const Color(0xFF2E7D32),
                  width: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                BarChartRodData(
                  toY: bucket.expense,
                  color: const Color(0xFFE53935),
                  width: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _MonthBucket {
  _MonthBucket({required this.year, required this.month});

  final int year;
  final int month;
  double income = 0;
  double expense = 0;
}
