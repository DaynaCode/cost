import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

class GoalsRepository {
  GoalsRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<GoalData>> watchAll() {
    return (_db.select(_db.goals)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .watch();
  }

  Future<String> create({
    required String title,
    required double targetAmount,
    required int colorValue,
    required int iconCode,
    DateTime? deadline,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.goals).insert(
          GoalsCompanion.insert(
            id: id,
            title: title,
            targetAmount: targetAmount,
            colorValue: colorValue,
            iconCode: iconCode,
            deadline: Value(deadline),
          ),
        );
    return id;
  }

  Future<void> update(GoalData goal) {
    return _db.update(_db.goals).replace(goal);
  }

  Future<void> delete(String id) {
    return (_db.delete(_db.goals)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> addContribution(String id, double amount) async {
    final goal = await (_db.select(_db.goals)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    if (goal == null) return;
    final newAmount = goal.currentAmount + amount;
    await (_db.update(_db.goals)..where((tbl) => tbl.id.equals(id))).write(
      GoalsCompanion(
        currentAmount: Value(newAmount),
        isCompleted: Value(newAmount >= goal.targetAmount),
      ),
    );
  }
}
