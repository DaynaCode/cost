import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/persian_date_formatter.dart';
import '../../../../core/utils/persian_number_formatter.dart';
import '../../../../shared/models/transaction_type.dart';
import '../../../../shared/utils/icon_catalog.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../application/transactions_providers.dart';

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(allTransactionsProvider).valueOrNull ?? [];
    final categoriesById = ref.watch(categoriesByIdProvider);
    final accountsById = ref.watch(accountsByIdProvider);

    TransactionData? transaction;
    for (final tx in transactions) {
      if (tx.id == transactionId) {
        transaction = tx;
        break;
      }
    }

    if (transaction == null) {
      return const Scaffold(body: Center(child: Text('تراکنش یافت نشد')));
    }
    final tx = transaction;

    final category = categoriesById[tx.categoryId];
    final account = accountsById[tx.accountId];
    final toAccount =
        tx.toAccountId != null ? accountsById[tx.toAccountId] : null;
    final type = TransactionTypeX.fromStorage(tx.type);
    final color = type == TransactionType.income
        ? const Color(0xFF2E7D32)
        : type == TransactionType.expense
            ? const Color(0xFFE53935)
            : const Color(0xFF1E88E5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('جزئیات تراکنش'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              final path = type == TransactionType.income
                  ? '/edit-income/${tx.id}'
                  : '/edit-expense/${tx.id}';
              context.push(path);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('حذف تراکنش'),
                  content: const Text('آیا از حذف این تراکنش اطمینان دارید؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('انصراف'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('حذف'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref
                    .read(transactionsRepositoryProvider)
                    .deleteTransaction(tx);
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category != null
                    ? iconFromCodePoint(category.iconCode)
                    : Icons.swap_horiz,
                color: color,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              PersianNumberFormatter.formatCurrency(tx.amount),
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700, color: color),
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              children: [
                _DetailRow(label: 'عنوان', value: tx.title),
                const Divider(height: 24),
                _DetailRow(label: 'نوع', value: type.label),
                const Divider(height: 24),
                _DetailRow(label: 'دسته بندی', value: category?.name ?? '-'),
                const Divider(height: 24),
                _DetailRow(label: 'حساب', value: account?.name ?? '-'),
                if (toAccount != null) ...[
                  const Divider(height: 24),
                  _DetailRow(label: 'به حساب', value: toAccount.name),
                ],
                if (tx.paymentMethod != null) ...[
                  const Divider(height: 24),
                  _DetailRow(
                    label: 'روش پرداخت',
                    value: PaymentMethodX.fromStorage(tx.paymentMethod)
                        .label,
                  ),
                ],
                const Divider(height: 24),
                _DetailRow(
                  label: 'تاریخ',
                  value: PersianDateFormatter.formatDate(tx.date),
                ),
                if (tx.description.isNotEmpty) ...[
                  const Divider(height: 24),
                  _DetailRow(
                      label: 'توضیحات', value: tx.description),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
