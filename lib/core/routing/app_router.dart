import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../database/app_database.dart';
import '../../features/accounts/presentation/screens/accounts_screen.dart';
import '../../features/accounts/presentation/screens/edit_account_screen.dart';
import '../../features/budgets/presentation/screens/budgets_screen.dart';
import '../../features/budgets/presentation/screens/edit_budget_screen.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/categories/presentation/screens/edit_category_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/goals/presentation/screens/edit_goal_screen.dart';
import '../../features/goals/presentation/screens/goals_screen.dart';
import '../../features/recurring/presentation/screens/edit_recurring_screen.dart';
import '../../features/recurring/presentation/screens/recurring_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/settings/presentation/screens/about_screen.dart';
import '../../features/settings/presentation/screens/backup_restore_screen.dart';
import '../../features/settings/presentation/screens/pin_lock_screen.dart';
import '../../features/settings/presentation/screens/security_settings_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/transactions/presentation/screens/edit_expense_screen.dart';
import '../../features/transactions/presentation/screens/edit_income_screen.dart';
import '../../features/transactions/presentation/screens/transaction_detail_screen.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';
import '../../features/transactions/presentation/screens/transfer_screen.dart';
import '../widgets/main_shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/transactions',
            builder: (context, state) => const TransactionsScreen(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/add-income',
        builder: (context, state) => const EditIncomeScreen(),
      ),
      GoRoute(
        path: '/edit-income/:id',
        builder: (context, state) => EditIncomeScreen(
          transactionId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/add-expense',
        builder: (context, state) => const EditExpenseScreen(),
      ),
      GoRoute(
        path: '/edit-expense/:id',
        builder: (context, state) => EditExpenseScreen(
          transactionId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/transfer',
        builder: (context, state) => const TransferScreen(),
      ),
      GoRoute(
        path: '/transaction/:id',
        builder: (context, state) => TransactionDetailScreen(
          transactionId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/accounts',
        builder: (context, state) => const AccountsScreen(),
      ),
      GoRoute(
        path: '/accounts/edit',
        builder: (context, state) => EditAccountScreen(
          account: state.extra as AccountData?,
        ),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/categories/edit',
        builder: (context, state) => EditCategoryScreen(
          category: state.extra as CategoryData?,
        ),
      ),
      GoRoute(
        path: '/budgets',
        builder: (context, state) => const BudgetsScreen(),
      ),
      GoRoute(
        path: '/budgets/edit',
        builder: (context, state) => EditBudgetScreen(
          budget: state.extra as BudgetData?,
        ),
      ),
      GoRoute(
        path: '/recurring',
        builder: (context, state) => const RecurringScreen(),
      ),
      GoRoute(
        path: '/recurring/edit',
        builder: (context, state) => EditRecurringScreen(
          recurring: state.extra as RecurringTransactionData?,
        ),
      ),
      GoRoute(
        path: '/goals',
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        path: '/goals/edit',
        builder: (context, state) => EditGoalScreen(
          goal: state.extra as GoalData?,
        ),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/backup-restore',
        builder: (context, state) => const BackupRestoreScreen(),
      ),
      GoRoute(
        path: '/security-settings',
        builder: (context, state) => const SecuritySettingsScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/pin-lock',
        builder: (context, state) => PinLockScreen(
          mode: state.extra as PinLockMode? ?? PinLockMode.unlock,
        ),
      ),
    ],
  );
});
