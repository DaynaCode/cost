import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

class CategoriesRepository {
  CategoriesRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<CategoryData>> watchByType(String type) {
    return (_db.select(_db.categories)
          ..where((tbl) => tbl.type.equals(type))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .watch();
  }

  Stream<List<CategoryData>> watchAll() {
    return (_db.select(_db.categories)
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .watch();
  }

  Future<List<CategoryData>> getAll() {
    return _db.select(_db.categories).get();
  }

  Future<CategoryData?> getById(String id) {
    return (_db.select(_db.categories)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<String> create({
    required String name,
    required String type,
    required int colorValue,
    required int iconCode,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.categories).insert(
          CategoriesCompanion.insert(
            id: id,
            name: name,
            type: type,
            colorValue: colorValue,
            iconCode: iconCode,
          ),
        );
    return id;
  }

  Future<void> update(CategoryData category) {
    return _db.update(_db.categories).replace(category);
  }

  Future<bool> isUsed(String id) async {
    final transactions = await (_db.select(_db.transactions)
          ..where((tbl) => tbl.categoryId.equals(id)))
        .get();
    return transactions.isNotEmpty;
  }

  Future<void> delete(String id) {
    return (_db.delete(_db.categories)..where((tbl) => tbl.id.equals(id))).go();
  }
}
