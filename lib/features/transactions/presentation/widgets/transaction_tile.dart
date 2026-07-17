import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/persian_date_formatter.dart';
import '../../../../core/utils/persian_number_formatter.dart';
import '../../../../shared/models/transaction_type.dart';
import '../../../../shared/utils/icon_catalog.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.category,
    this.onTap,
  });

  final TransactionData transaction;
  final CategoryData? category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = TransactionTypeX.fromStorage(transaction.type);
    final isIncome = type == TransactionType.income;
    final isTransfer = type == TransactionType.transfer;
    final color = isTransfer
        ? const Color(0xFF1E88E5)
        : (isIncome ? const Color(0xFF2E7D32) : const Color(0xFFE53935));
    final icon = category != null
        ? iconFromCodePoint(category!.iconCode)
        : Icons.swap_horiz;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        transaction.title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${category?.name ?? 'انتقال'} • ${PersianDateFormatter.formatDateShort(transaction.date)}',
        style: theme.textTheme.bodySmall
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
      trailing: Text(
        '${isIncome ? '+' : (isTransfer ? '' : '-')}${PersianNumberFormatter.formatAmount(transaction.amount)}',
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
