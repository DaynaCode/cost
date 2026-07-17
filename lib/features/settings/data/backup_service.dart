import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show InsertMode;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/database/app_database.dart';

class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  Future<File> exportToJson() async {
    final accounts = await _db.select(_db.accounts).get();
    final categories = await _db.select(_db.categories).get();
    final transactions = await _db.select(_db.transactions).get();
    final budgets = await _db.select(_db.budgets).get();
    final recurring = await _db.select(_db.recurringTransactions).get();
    final goals = await _db.select(_db.goals).get();

    final payload = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'accounts': accounts.map((e) => e.toJson()).toList(),
      'categories': categories.map((e) => e.toJson()).toList(),
      'transactions': transactions.map((e) => e.toJson()).toList(),
      'budgets': budgets.map((e) => e.toJson()).toList(),
      'recurringTransactions': recurring.map((e) => e.toJson()).toList(),
      'goals': goals.map((e) => e.toJson()).toList(),
    };

    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'cost-manager-backup-${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(jsonEncode(payload));
    return file;
  }

  Future<void> shareBackup(File file) async {
    await Share.shareXFiles([XFile(file.path)]);
  }

  Future<void> restoreFromJson(String content) async {
    final data = jsonDecode(content) as Map<String, dynamic>;

    await _db.transaction(() async {
      await _db.delete(_db.transactions).go();
      await _db.delete(_db.budgets).go();
      await _db.delete(_db.recurringTransactions).go();
      await _db.delete(_db.goals).go();
      await _db.delete(_db.categories).go();
      await _db.delete(_db.accounts).go();

      for (final item in (data['accounts'] as List? ?? [])) {
        await _db.into(_db.accounts).insert(
              AccountData.fromJson(item as Map<String, dynamic>).toCompanion(true),
              mode: InsertMode.insertOrReplace,
            );
      }
      for (final item in (data['categories'] as List? ?? [])) {
        await _db.into(_db.categories).insert(
              CategoryData.fromJson(item as Map<String, dynamic>).toCompanion(true),
              mode: InsertMode.insertOrReplace,
            );
      }
      for (final item in (data['transactions'] as List? ?? [])) {
        await _db.into(_db.transactions).insert(
              TransactionData.fromJson(item as Map<String, dynamic>)
                  .toCompanion(true),
              mode: InsertMode.insertOrReplace,
            );
      }
      for (final item in (data['budgets'] as List? ?? [])) {
        await _db.into(_db.budgets).insert(
              BudgetData.fromJson(item as Map<String, dynamic>).toCompanion(true),
              mode: InsertMode.insertOrReplace,
            );
      }
      for (final item in (data['recurringTransactions'] as List? ?? [])) {
        await _db.into(_db.recurringTransactions).insert(
              RecurringTransactionData.fromJson(item as Map<String, dynamic>)
                  .toCompanion(true),
              mode: InsertMode.insertOrReplace,
            );
      }
      for (final item in (data['goals'] as List? ?? [])) {
        await _db.into(_db.goals).insert(
              GoalData.fromJson(item as Map<String, dynamic>).toCompanion(true),
              mode: InsertMode.insertOrReplace,
            );
      }
    });
  }

  Future<void> deleteAllData() async {
    await _db.transaction(() async {
      await _db.delete(_db.transactions).go();
      await _db.delete(_db.budgets).go();
      await _db.delete(_db.recurringTransactions).go();
      await _db.delete(_db.goals).go();
      await _db.delete(_db.categories).go();
      await _db.delete(_db.accounts).go();
    });
  }
}
