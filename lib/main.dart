import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'core/providers/core_providers.dart';
import 'core/services/notification_service.dart';
import 'core/services/settings_service.dart';
import 'features/recurring/data/recurring_repository.dart';
import 'features/accounts/data/accounts_repository.dart';
import 'features/transactions/data/transactions_repository.dart';
import 'features/settings/presentation/screens/pin_lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();
  final notificationService = NotificationService();
  await notificationService.initialize();

  final database = AppDatabase();
  final accountsRepository = AccountsRepository(database);
  final transactionsRepository =
      TransactionsRepository(database, accountsRepository);
  await RecurringRepository(database, transactionsRepository)
      .processDueRecurring();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        appDatabaseProvider.overrideWithValue(database),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const CostManagerRoot(),
    ),
  );
}

class CostManagerRoot extends ConsumerWidget {
  const CostManagerRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsServiceProvider);
    if (!settings.isPinEnabled) {
      return const CostManagerApp();
    }
    return _LockedApp(settings: settings);
  }
}

class _LockedApp extends StatefulWidget {
  const _LockedApp({required this.settings});

  final SettingsService settings;

  @override
  State<_LockedApp> createState() => _LockedAppState();
}

class _LockedAppState extends State<_LockedApp> {
  bool _unlocked = false;

  @override
  Widget build(BuildContext context) {
    if (_unlocked) return const CostManagerApp();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa', 'IR'),
      home: _UnlockGate(onUnlocked: () => setState(() => _unlocked = true)),
    );
  }
}

class _UnlockGate extends StatefulWidget {
  const _UnlockGate({required this.onUnlocked});

  final VoidCallback onUnlocked;

  @override
  State<_UnlockGate> createState() => _UnlockGateState();
}

class _UnlockGateState extends State<_UnlockGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _presentLock());
  }

  Future<void> _presentLock() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const PinLockScreen(mode: PinLockMode.unlock),
      ),
    );
    if (result == true) widget.onUnlocked();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}
