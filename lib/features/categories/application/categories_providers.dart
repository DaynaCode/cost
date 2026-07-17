import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/core_providers.dart';
import '../data/categories_repository.dart';

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  return CategoriesRepository(ref.watch(appDatabaseProvider));
});

final allCategoriesProvider = StreamProvider<List<CategoryData>>((ref) {
  return ref.watch(categoriesRepositoryProvider).watchAll();
});

final expenseCategoriesProvider = StreamProvider<List<CategoryData>>((ref) {
  return ref.watch(categoriesRepositoryProvider).watchByType('expense');
});

final incomeCategoriesProvider = StreamProvider<List<CategoryData>>((ref) {
  return ref.watch(categoriesRepositoryProvider).watchByType('income');
});
