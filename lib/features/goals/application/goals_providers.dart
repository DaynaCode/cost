import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/core_providers.dart';
import '../data/goals_repository.dart';

final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  return GoalsRepository(ref.watch(appDatabaseProvider));
});

final goalsListProvider = StreamProvider<List<GoalData>>((ref) {
  return ref.watch(goalsRepositoryProvider).watchAll();
});
