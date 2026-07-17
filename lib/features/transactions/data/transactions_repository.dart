import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../shared/models/transaction_type.dart';
import '../../accounts/data/accounts_repository.dart';
import '../domain/transaction_model.dart';

class TransactionsRepository {
  TransactionsRepository(this._db, this._accountsRepository);

  final AppDatabase _db;
  final AccountsRepository _accountsRepository;
  static const _uuid = Uuid();

  Stream<List<TransactionData>> watchAll() {
    return (_db.select(_db.transactions)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]))
        .watch();
  }

  Stream<List<TransactionData>> watchRecent({int limit = 5}) {
    return (_db.select(_db.transactions)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)])
          ..limit(limit))
        .watch();
  }

  Stream<List<TransactionData>> watchInRange(DateTime start, DateTime end) {
    return (_db.select(_db.transactions)
          ..where((tbl) => tbl.date.isBetweenValues(start, end))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]))
        .watch();
  }

  Future<List<TransactionData>> getInRange(DateTime start, DateTime end) {
    return (_db.select(_db.transactions)
          ..where((tbl) => tbl.date.isBetweenValues(start, end)))
        .get();
  }

  Future<TransactionData?> getById(String id) {
    return (_db.select(_db.transactions)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<String> addIncome({
    required String title,
    required double amount,
    required String categoryId,
    required String accountId,
    required DateTime date,
    String description = '',
    String? recurringId,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.transactions).insert(
          TransactionsCompanion.insert(
            id: id,
            title: title,
            amount: amount,
            type: TransactionType.income.storageValue,
            categoryId: categoryId,
            accountId: accountId,
            date: date,
            description: Value(description),
            recurringId: Value(recurringId),
          ),
        );
    await _accountsRepository.adjustBalance(accountId, amount);
    return id;
  }

  Future<String> addExpense({
    required String title,
    required double amount,
    required String categoryId,
    required String accountId,
    required DateTime date,
    String description = '',
    String? paymentMethod,
    String? recurringId,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.transactions).insert(
          TransactionsCompanion.insert(
            id: id,
            title: title,
            amount: amount,
            type: TransactionType.expense.storageValue,
            categoryId: categoryId,
            accountId: accountId,
            date: date,
            description: Value(description),
            paymentMethod: Value(paymentMethod),
            recurringId: Value(recurringId),
          ),
        );
    await _accountsRepository.adjustBalance(accountId, -amount);
    return id;
  }

  Future<String> addTransfer({
    required double amount,
    required String fromAccountId,
    required String toAccountId,
    required String transferCategoryId,
    required DateTime date,
    String description = '',
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.transactions).insert(
          TransactionsCompanion.insert(
            id: id,
            title: 'انتقال وجه',
            amount: amount,
            type: TransactionType.transfer.storageValue,
            categoryId: transferCategoryId,
            accountId: fromAccountId,
            toAccountId: Value(toAccountId),
            date: date,
            description: Value(description),
          ),
        );
    await _accountsRepository.adjustBalance(fromAccountId, -amount);
    await _accountsRepository.adjustBalance(toAccountId, amount);
    return id;
  }

  Future<void> updateTransaction({
    required TransactionData original,
    required String title,
    required double amount,
    required String categoryId,
    required String accountId,
    required DateTime date,
    String description = '',
    String? paymentMethod,
  }) async {
    await _reverseBalanceEffect(original);
    await _db.update(_db.transactions).replace(
          original.copyWith(
            title: title,
            amount: amount,
            categoryId: categoryId,
            accountId: accountId,
            date: date,
            description: description,
            paymentMethod: Value(paymentMethod),
          ),
        );
    final type = TransactionTypeX.fromStorage(original.type);
    final delta = type == TransactionType.income ? amount : -amount;
    await _accountsRepository.adjustBalance(accountId, delta);
  }

  Future<void> deleteTransaction(TransactionData transaction) async {
    await _reverseBalanceEffect(transaction);
    await (_db.delete(_db.transactions)
          ..where((tbl) => tbl.id.equals(transaction.id)))
        .go();
  }

  Future<void> _reverseBalanceEffect(TransactionData transaction) async {
    final type = TransactionTypeX.fromStorage(transaction.type);
    switch (type) {
      case TransactionType.income:
        await _accountsRepository.adjustBalance(
            transaction.accountId, -transaction.amount);
        break;
      case TransactionType.expense:
        await _accountsRepository.adjustBalance(
            transaction.accountId, transaction.amount);
        break;
      case TransactionType.transfer:
        await _accountsRepository.adjustBalance(
            transaction.accountId, transaction.amount);
        if (transaction.toAccountId != null) {
          await _accountsRepository.adjustBalance(
              transaction.toAccountId!, -transaction.amount);
        }
        break;
    }
  }

  List<TransactionData> applyFilter(
    List<TransactionData> transactions,
    TransactionFilter filter,
    Map<String, CategoryData> categoriesById,
  ) {
    var result = transactions.where((tx) {
      if (filter.typeFilter != null && tx.type != filter.typeFilter) {
        return false;
      }
      if (filter.categoryIds.isNotEmpty &&
          !filter.categoryIds.contains(tx.categoryId)) {
        return false;
      }
      if (filter.accountIds.isNotEmpty &&
          !filter.accountIds.contains(tx.accountId)) {
        return false;
      }
      if (filter.minAmount != null && tx.amount < filter.minAmount!) {
        return false;
      }
      if (filter.maxAmount != null && tx.amount > filter.maxAmount!) {
        return false;
      }
      if (filter.searchQuery.isNotEmpty) {
        final query = filter.searchQuery.toLowerCase();
        final category = categoriesById[tx.categoryId];
        final matchesTitle = tx.title.toLowerCase().contains(query);
        final matchesDescription =
            tx.description.toLowerCase().contains(query);
        final matchesAmount = tx.amount.toString().contains(query);
        final matchesCategory =
            category?.name.toLowerCase().contains(query) ?? false;
        if (!matchesTitle &&
            !matchesDescription &&
            !matchesAmount &&
            !matchesCategory) {
          return false;
        }
      }
      return true;
    }).toList();

    return result;
  }

  List<TransactionData> applySort(
      List<TransactionData> transactions, SortOption sortOption) {
    final result = [...transactions];
    switch (sortOption) {
      case SortOption.newest:
        result.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortOption.oldest:
        result.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortOption.highestAmount:
        result.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case SortOption.lowestAmount:
        result.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }
    return result;
  }
}
