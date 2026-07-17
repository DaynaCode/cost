import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/persian_date_formatter.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../accounts/application/accounts_providers.dart';
import '../../../budgets/application/budgets_providers.dart';
import '../../../transactions/application/transactions_providers.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/monthly_bar_chart.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/summary_card.dart';
import '../../../transactions/presentation/widgets/transaction_tile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صبح بخیر';
    if (hour < 17) return 'ظهر بخیر';
    if (hour < 20) return 'عصر بخیر';
    return 'شب بخیر';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalBalance = ref.watch(totalBalanceProvider);
    final monthlyTotals = ref.watch(monthlyTotalsProvider);
    final recentTransactions =
        ref.watch(recentTransactionsProvider).valueOrNull ?? [];
    final categoriesById = ref.watch(categoriesByIdProvider);
    final currentMonthTransactions =
        ref.watch(currentMonthTransactionsProvider).valueOrNull ?? [];
    final budgetProgressList = ref.watch(budgetProgressListProvider);

    final remainingBudget = budgetProgressList.fold<double>(
        0, (sum, progress) => sum + progress.remaining.clamp(0, double.infinity));

    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت هزینه ها'),
        actions: [
          IconButton(
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      PersianDateFormatter.formatFull(now),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                SummaryCard(
                  title: 'کل درآمد',
                  amount: monthlyTotals.income,
                  icon: Icons.arrow_downward,
                  color: const Color(0xFF2E7D32),
                ),
                SummaryCard(
                  title: 'کل هزینه',
                  amount: monthlyTotals.expense,
                  icon: Icons.arrow_upward,
                  color: const Color(0xFFE53935),
                ),
                SummaryCard(
                  title: 'مانده حساب',
                  amount: totalBalance,
                  icon: Icons.account_balance_wallet,
                  color: const Color(0xFF1E88E5),
                ),
                SummaryCard(
                  title: 'بودجه باقی مانده',
                  amount: remainingBudget,
                  icon: Icons.savings,
                  color: const Color(0xFF8E24AA),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('عملیات سریع',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  QuickActionButton(
                    icon: Icons.add_circle,
                    label: 'افزودن درآمد',
                    color: const Color(0xFF2E7D32),
                    onTap: () => context.push('/add-income'),
                  ),
                  QuickActionButton(
                    icon: Icons.remove_circle,
                    label: 'افزودن هزینه',
                    color: const Color(0xFFE53935),
                    onTap: () => context.push('/add-expense'),
                  ),
                  QuickActionButton(
                    icon: Icons.swap_horiz,
                    label: 'انتقال وجه',
                    color: const Color(0xFF1E88E5),
                    onTap: () => context.push('/transfer'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'تحلیل هزینه ها - ${PersianDateFormatter.currentMonthName(now)}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: ExpensePieChart(
                transactions: currentMonthTransactions,
                categoriesById: categoriesById,
              ),
            ),
            const SizedBox(height: 24),
            Text('روند ۶ ماه اخیر',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            AppCard(
              child: MonthlyBarChart(
                transactions: ref.watch(allTransactionsProvider).valueOrNull ?? [],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('تراکنش های اخیر',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                TextButton(
                  onPressed: () => context.go('/transactions'),
                  child: const Text('مشاهده همه'),
                ),
              ],
            ),
            if (recentTransactions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'هنوز تراکنشی ثبت نشده است',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  children: recentTransactions.map((tx) {
                    return TransactionTile(
                      transaction: tx,
                      category: categoriesById[tx.categoryId],
                      onTap: () => context.push('/transaction/${tx.id}'),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
