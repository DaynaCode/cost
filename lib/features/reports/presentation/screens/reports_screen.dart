import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/persian_number_formatter.dart';
import '../../../../shared/utils/icon_catalog.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../dashboard/presentation/widgets/expense_pie_chart.dart';
import '../../../transactions/application/transactions_providers.dart';
import '../../application/reports_providers.dart';
import '../../domain/report_period.dart';
import '../widgets/cash_flow_chart.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reportPeriodProvider);
    final summary = ref.watch(incomeExpenseSummaryProvider);
    final categoryEntries = ref.watch(categoryReportProvider);
    final cashFlowPoints = ref.watch(cashFlowTrendProvider);
    final reportTransactions = ref.watch(reportTransactionsProvider);
    final categoriesById = ref.watch(categoriesByIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('گزارش ها')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ReportPeriod.values.map((option) {
                final isSelected = option == period;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(option.label),
                    selected: isSelected,
                    onSelected: (_) =>
                        ref.read(reportPeriodProvider.notifier).state = option,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('درآمد', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text(
                        PersianNumberFormatter.formatAmount(summary.income),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF2E7D32),
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('هزینه', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text(
                        PersianNumberFormatter.formatAmount(summary.expense),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFFE53935),
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('پس انداز خالص', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  PersianNumberFormatter.formatCurrency(summary.net),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: summary.net >= 0
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFE53935)),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: summary.savingsRate.clamp(0.0, 1.0),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                Text(
                  'نرخ پس انداز: ${PersianNumberFormatter.toPersianDigits((summary.savingsRate * 100).toStringAsFixed(0))}٪',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('تحلیل دسته بندی',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          AppCard(
            child: ExpensePieChart(
              transactions: reportTransactions,
              categoriesById: categoriesById,
            ),
          ),
          const SizedBox(height: 12),
          if (categoryEntries.isEmpty)
            const EmptyState(
              icon: Icons.pie_chart_outline,
              title: 'داده ای برای این بازه یافت نشد',
            )
          else
            AppCard(
              child: Column(
                children: categoryEntries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Color(entry.category.colorValue)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            iconFromCodePoint(entry.category.iconCode),
                            size: 18,
                            color: Color(entry.category.colorValue),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(entry.category.name)),
                        Text(
                          PersianNumberFormatter.formatAmount(entry.total),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 20),
          Text('روند جریان نقدی (۶ ماه اخیر)',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          AppCard(child: CashFlowChart(points: cashFlowPoints)),
        ],
      ),
    );
  }
}
