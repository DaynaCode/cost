import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/core_providers.dart';
import '../data/accounts_repository.dart';

final accountsRepositoryProvider = Provider<AccountsRepository>((ref) {
  return AccountsRepository(ref.watch(appDatabaseProvider));
});

final accountsListProvider = StreamProvider<List<AccountData>>((ref) {
  return ref.watch(accountsRepositoryProvider).watchAll();
});

final totalBalanceProvider = Provider<double>((ref) {
  final accounts = ref.watch(accountsListProvider).valueOrNull ?? [];
  return accounts.fold<double>(0, (sum, account) => sum + account.balance);
});
