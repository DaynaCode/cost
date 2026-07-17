import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../shared/utils/icon_catalog.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../application/categories_providers.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseCategories =
        ref.watch(expenseCategoriesProvider).valueOrNull ?? [];
    final incomeCategories =
        ref.watch(incomeCategoriesProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('دسته بندی ها'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'هزینه'),
            Tab(text: 'درآمد'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CategoryGrid(categories: expenseCategories),
          _CategoryGrid(categories: incomeCategories),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/categories/edit'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.categories});

  final List<CategoryData> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(child: Text('دسته بندی ای وجود ندارد'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return AppCard(
          onTap: () => context.push('/categories/edit', extra: category),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Color(category.colorValue).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconFromCodePoint(category.iconCode),
                    color: Color(category.colorValue)),
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }
}
