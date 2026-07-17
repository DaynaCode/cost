import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/persian_date_formatter.dart';
import '../../../../core/utils/persian_number_formatter.dart';
import '../../../../shared/models/transaction_type.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../transactions/application/transactions_providers.dart';
import '../../application/recurring_providers.dart';

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringList = ref.watch(recurringListProvider).valueOrNull ?? [];
    final categoriesById = ref.watch(categoriesByIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تراکنش های تکرارشونده')),
      body: recurringList.isEmpty
          ? const EmptyState(
              icon: Icons.repeat,
              title: 'هنوز تراکنش تکرارشونده ای ثبت نشده است',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recurringList.length,
              itemBuilder: (context, index) {
                final recurring = recurringList[index];
                final category = categoriesById[recurring.categoryId];
                final type = TransactionTypeX.fromStorage(recurring.type);
                final color = type == TransactionType.income
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFE53935);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    onTap: () =>
                        context.push('/recurring/edit', extra: recurring),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(recurring.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                                '${category?.name ?? ''} • ${RecurringFrequencyX.fromStorage(recurring.frequency).label}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'رخداد بعدی: ${PersianDateFormatter.formatDate(recurring.nextOccurrence)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              PersianNumberFormatter.formatAmount(
                                  recurring.amount),
                              style: TextStyle(
                                  color: color, fontWeight: FontWeight.w700),
                            ),
                            Switch(
                              value: recurring.isActive,
                              onChanged: (value) => ref
                                  .read(recurringRepositoryProvider)
                                  .setActive(recurring.id, value),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/recurring/edit'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
