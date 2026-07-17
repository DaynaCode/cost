import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/core_providers.dart';
import '../../transactions/application/transactions_providers.dart';
import '../data/recurring_repository.dart';

final recurringRepositoryProvider = Provider<RecurringRepository>((ref) {
  return RecurringRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(transactionsRepositoryProvider),
  );
});

final recurringListProvider = StreamProvider<List<RecurringTransactionData>>((ref) {
  return ref.watch(recurringRepositoryProvider).watchAll();
});
