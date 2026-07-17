import '../../../core/database/app_database.dart';

class TransactionWithDetails {
  const TransactionWithDetails({
    required this.transaction,
    required this.category,
    required this.account,
    this.toAccount,
  });

  final TransactionData transaction;
  final CategoryData category;
  final AccountData account;
  final AccountData? toAccount;
}

enum TransactionDateFilter { all, today, thisWeek, thisMonth, thisYear, custom }

class TransactionFilter {
  const TransactionFilter({
    this.searchQuery = '',
    this.categoryIds = const {},
    this.accountIds = const {},
    this.dateFilter = TransactionDateFilter.all,
    this.customStart,
    this.customEnd,
    this.minAmount,
    this.maxAmount,
    this.typeFilter,
  });

  final String searchQuery;
  final Set<String> categoryIds;
  final Set<String> accountIds;
  final TransactionDateFilter dateFilter;
  final DateTime? customStart;
  final DateTime? customEnd;
  final double? minAmount;
  final double? maxAmount;
  final String? typeFilter;

  bool get hasActiveFilters =>
      categoryIds.isNotEmpty ||
      accountIds.isNotEmpty ||
      dateFilter != TransactionDateFilter.all ||
      minAmount != null ||
      maxAmount != null ||
      typeFilter != null;

  TransactionFilter copyWith({
    String? searchQuery,
    Set<String>? categoryIds,
    Set<String>? accountIds,
    TransactionDateFilter? dateFilter,
    DateTime? customStart,
    DateTime? customEnd,
    double? minAmount,
    double? maxAmount,
    String? typeFilter,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
    bool clearTypeFilter = false,
  }) {
    return TransactionFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      categoryIds: categoryIds ?? this.categoryIds,
      accountIds: accountIds ?? this.accountIds,
      dateFilter: dateFilter ?? this.dateFilter,
      customStart: customStart ?? this.customStart,
      customEnd: customEnd ?? this.customEnd,
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
      typeFilter: clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
    );
  }
}
