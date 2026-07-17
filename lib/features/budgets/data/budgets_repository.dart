import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

class BudgetsRepository {
  BudgetsRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<BudgetData>> watchAll() {
    return _db.select(_db.budgets).watch();
  }

  Future<String> create({
    required String categoryId,
    required double amount,
    required String period,
    required DateTime startDate,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.budgets).insert(
          BudgetsCompanion.insert(
            id: id,
            categoryId: categoryId,
            amount: amount,
            period: period,
            startDate: startDate,
          ),
        );
    return id;
  }

  Future<void> update(BudgetData budget) {
    return _db.update(_db.budgets).replace(budget);
  }

  Future<void> delete(String id) {
    return (_db.delete(_db.budgets)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> updateNotifiedThreshold(String id, int threshold) {
    return (_db.update(_db.budgets)..where((tbl) => tbl.id.equals(id)))
        .write(BudgetsCompanion(notifiedThreshold: Value(threshold)));
  }
}
