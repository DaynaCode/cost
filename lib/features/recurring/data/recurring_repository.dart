import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../shared/models/transaction_type.dart';
import '../../transactions/data/transactions_repository.dart';

class RecurringRepository {
  RecurringRepository(this._db, this._transactionsRepository);

  final AppDatabase _db;
  final TransactionsRepository _transactionsRepository;
  static const _uuid = Uuid();

  Stream<List<RecurringTransactionData>> watchAll() {
    return (_db.select(_db.recurringTransactions)
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.nextOccurrence)]))
        .watch();
  }

  Future<List<RecurringTransactionData>> getDue() {
    return (_db.select(_db.recurringTransactions)
          ..where((tbl) =>
              tbl.isActive.equals(true) &
              tbl.nextOccurrence.isSmallerOrEqualValue(DateTime.now())))
        .get();
  }

  Future<String> create({
    required String title,
    required double amount,
    required String type,
    required String categoryId,
    required String accountId,
    required String frequency,
    required DateTime startDate,
    String description = '',
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.recurringTransactions).insert(
          RecurringTransactionsCompanion.insert(
            id: id,
            title: title,
            amount: amount,
            type: type,
            categoryId: categoryId,
            accountId: accountId,
            frequency: frequency,
            startDate: startDate,
            nextOccurrence: startDate,
            description: Value(description),
          ),
        );
    return id;
  }

  Future<void> update(RecurringTransactionData recurring) {
    return _db.update(_db.recurringTransactions).replace(recurring);
  }

  Future<void> delete(String id) {
    return (_db.delete(_db.recurringTransactions)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  Future<void> setActive(String id, bool isActive) {
    return (_db.update(_db.recurringTransactions)
          ..where((tbl) => tbl.id.equals(id)))
        .write(RecurringTransactionsCompanion(isActive: Value(isActive)));
  }

  Future<void> processDueRecurring() async {
    final due = await getDue();
    for (final recurring in due) {
      final type = TransactionTypeX.fromStorage(recurring.type);
      if (type == TransactionType.income) {
        await _transactionsRepository.addIncome(
          title: recurring.title,
          amount: recurring.amount,
          categoryId: recurring.categoryId,
          accountId: recurring.accountId,
          date: recurring.nextOccurrence,
          description: recurring.description,
          recurringId: recurring.id,
        );
      } else {
        await _transactionsRepository.addExpense(
          title: recurring.title,
          amount: recurring.amount,
          categoryId: recurring.categoryId,
          accountId: recurring.accountId,
          date: recurring.nextOccurrence,
          description: recurring.description,
          recurringId: recurring.id,
        );
      }
      final frequency = RecurringFrequencyX.fromStorage(recurring.frequency);
      final next = frequency.nextOccurrenceFrom(recurring.nextOccurrence);
      await update(recurring.copyWith(nextOccurrence: next));
    }
  }
}
