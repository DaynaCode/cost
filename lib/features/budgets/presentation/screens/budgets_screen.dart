import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/persian_number_formatter.dart';
import '../../../../shared/utils/icon_catalog.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../transactions/application/transactions_providers.dart';
import '../../application/budgets_providers.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressList = ref.watch(budgetProgressListProvider);
    final categoriesById = ref.watch(categoriesByIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('بودجه بندی')),
      body: progressList.isEmpty
          ? const EmptyState(
              icon: Icons.pie_chart_outline,
              title: 'هنوز بودجه ای تعریف نشده است',
              subtitle: 'برای هر دسته بندی یک بودجه ماهانه تعریف کنید',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: progressList.length,
              itemBuilder: (context, index) {
                final progress = progressList[index];
                final category = categoriesById[progress.budget.categoryId];
                final percentage = progress.percentage;
                final color = percentage >= 1
                    ? const Color(0xFFE53935)
                    : percentage >= 0.75
                        ? const Color(0xFFFB8C00)
                        : const Color(0xFF2E7D32);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    onTap: () =>
                        context.push('/budgets/edit', extra: progress.budget),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (category != null)
                              Icon(iconFromCodePoint(category.iconCode),
                                  color: Color(category.colorValue), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                category?.name ?? '-',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              '${PersianNumberFormatter.formatAmount(progress.spent)} / ${PersianNumberFormatter.formatAmount(progress.budget.amount)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: percentage.clamp(0.0, 1.0),
                            minHeight: 8,
                            color: color,
                            backgroundColor: color.withValues(alpha: 0.12),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          progress.isExceeded
                              ? 'از بودجه عبور کرده اید'
                              : '${PersianNumberFormatter.toPersianDigits((percentage * 100).toStringAsFixed(0))}٪ استفاده شده',
                          style: TextStyle(color: color, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/budgets/edit'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
