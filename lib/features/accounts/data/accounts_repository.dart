import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

class AccountsRepository {
  AccountsRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<AccountData>> watchAll() {
    return (_db.select(_db.accounts)
          ..where((tbl) => tbl.isArchived.equals(false))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]))
        .watch();
  }

  Future<List<AccountData>> getAll() {
    return (_db.select(_db.accounts)
          ..where((tbl) => tbl.isArchived.equals(false)))
        .get();
  }

  Future<AccountData?> getById(String id) {
    return (_db.select(_db.accounts)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<String> create({
    required String name,
    required double balance,
    required int colorValue,
    required int iconCode,
    required String type,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.accounts).insert(
          AccountsCompanion.insert(
            id: id,
            name: name,
            balance: Value(balance),
            colorValue: colorValue,
            iconCode: iconCode,
            type: type,
          ),
        );
    return id;
  }

  Future<void> update(AccountData account) {
    return _db.update(_db.accounts).replace(account);
  }

  Future<void> adjustBalance(String accountId, double delta) async {
    final account = await getById(accountId);
    if (account == null) return;
    await (_db.update(_db.accounts)..where((tbl) => tbl.id.equals(accountId)))
        .write(AccountsCompanion(balance: Value(account.balance + delta)));
  }

  Future<void> archive(String id) {
    return (_db.update(_db.accounts)..where((tbl) => tbl.id.equals(id)))
        .write(const AccountsCompanion(isArchived: Value(true)));
  }

  Future<bool> isUsedByTransactions(String id) async {
    final query = _db.select(_db.transactions)
      ..where((tbl) =>
          tbl.accountId.equals(id) | tbl.toAccountId.equals(id));
    final result = await query.get();
    return result.isNotEmpty;
  }
}
