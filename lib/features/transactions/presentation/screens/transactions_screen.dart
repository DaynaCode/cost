import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/models/transaction_type.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../accounts/application/accounts_providers.dart';
import '../../../categories/application/categories_providers.dart';
import '../../application/transactions_providers.dart';
import '../../domain/transaction_model.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/transaction_tile.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(filteredTransactionsProvider);
    final categoriesById = ref.watch(categoriesByIdProvider);
    final filter = ref.watch(transactionFilterProvider);
    final sortOption = ref.watch(sortOptionProvider);
    final categories = ref.watch(allCategoriesProvider).valueOrNull ?? [];
    final accounts = ref.watch(accountsListProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('تراکنش ها'),
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (option) =>
                ref.read(sortOptionProvider.notifier).state = option,
            itemBuilder: (context) => SortOption.values
                .map((option) => PopupMenuItem(
                      value: option,
                      child: Text(option.label),
                    ))
                .toList(),
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: filter.hasActiveFilters,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () async {
              final result = await showModalBottomSheet<TransactionFilter>(
                context: context,
                isScrollControlled: true,
                builder: (context) => FilterBottomSheet(
                  initialFilter: filter,
                  categories: categories,
                  accounts: accounts,
                ),
              );
              if (result != null) {
                ref.read(transactionFilterProvider.notifier).state = result;
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => ref
                  .read(transactionFilterProvider.notifier)
                  .update((state) => state.copyWith(searchQuery: value)),
              decoration: const InputDecoration(
                hintText: 'جستجو بر اساس عنوان، مبلغ یا توضیحات',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          if (sortOption != SortOption.newest || filter.hasActiveFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'مرتب سازی: ${sortOption.label}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          Expanded(
            child: transactions.isEmpty
                ? const EmptyState(
                    icon: Icons.receipt_long,
                    title: 'تراکنشی یافت نشد',
                    subtitle: 'با تغییر فیلترها یا افزودن تراکنش جدید شروع کنید',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return TransactionTile(
                        transaction: tx,
                        category: categoriesById[tx.categoryId],
                        onTap: () => context.push('/transaction/${tx.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_circle, color: Color(0xFF2E7D32)),
              title: const Text('افزودن درآمد'),
              onTap: () {
                Navigator.pop(context);
                context.push('/add-income');
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle, color: Color(0xFFE53935)),
              title: const Text('افزودن هزینه'),
              onTap: () {
                Navigator.pop(context);
                context.push('/add-expense');
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz, color: Color(0xFF1E88E5)),
              title: const Text('انتقال وجه'),
              onTap: () {
                Navigator.pop(context);
                context.push('/transfer');
              },
            ),
          ],
        ),
      ),
    );
  }
}

