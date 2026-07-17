import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../transactions/application/transactions_providers.dart';
import '../../../transactions/domain/transaction_model.dart';
import '../../../transactions/presentation/widgets/transaction_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allTransactions = ref.watch(allTransactionsProvider).valueOrNull ?? [];
    final categoriesById = ref.watch(categoriesByIdProvider);
    final repository = ref.watch(transactionsRepositoryProvider);

    final results = _query.isEmpty
        ? <TransactionData>[]
        : repository.applyFilter(
            allTransactions,
            TransactionFilter(searchQuery: _query),
            categoriesById,
          );

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: (value) => setState(() => _query = value),
          decoration: const InputDecoration(
            hintText: 'جستجو بر اساس عنوان، مبلغ، دسته بندی یا توضیحات',
            border: InputBorder.none,
          ),
        ),
      ),
      body: _query.isEmpty
          ? const EmptyState(
              icon: Icons.search,
              title: 'برای جستجو تایپ کنید',
            )
          : results.isEmpty
              ? const EmptyState(
                  icon: Icons.search_off,
                  title: 'نتیجه ای یافت نشد',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final tx = results[index];
                    return TransactionTile(
                      transaction: tx,
                      category: categoriesById[tx.categoryId],
                      onTap: () => context.push('/transaction/${tx.id}'),
                    );
                  },
                ),
    );
  }
}
