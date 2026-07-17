import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/persian_number_formatter.dart';
import '../../../../shared/utils/icon_catalog.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../application/accounts_providers.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsListProvider).valueOrNull ?? [];
    final totalBalance = ref.watch(totalBalanceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('حساب ها')),
      body: accounts.isEmpty
          ? const EmptyState(
              icon: Icons.account_balance_wallet,
              title: 'هنوز حسابی ثبت نشده است',
              subtitle: 'برای شروع یک حساب جدید اضافه کنید',
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AppCard(
                  color: Theme.of(context).colorScheme.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('مجموع دارایی',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85))),
                      const SizedBox(height: 8),
                      Text(
                        PersianNumberFormatter.formatCurrency(totalBalance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...accounts.map((account) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      onTap: () =>
                          context.push('/accounts/edit', extra: account),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Color(account.colorValue)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(iconFromCodePoint(account.iconCode),
                                color: Color(account.colorValue)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              account.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            PersianNumberFormatter.formatAmount(
                                account.balance),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/accounts/edit'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
