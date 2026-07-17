import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'app_database.dart';

const _uuid = Uuid();

Future<void> seedDefaultData(AppDatabase db) async {
  final expenseCategories = <String, IconData>{
    'خوراک': Icons.restaurant,
    'قبوض': Icons.receipt_long,
    'حمل و نقل': Icons.directions_car,
    'تفریح': Icons.movie,
    'پوشاک': Icons.checkroom,
    'درمان': Icons.local_hospital,
    'آموزش': Icons.school,
    'خرید': Icons.shopping_bag,
    'خانه': Icons.home,
    'سفر': Icons.flight,
    'هدایا': Icons.card_giftcard,
    'مالیات': Icons.account_balance,
    'سایر': Icons.category,
  };

  final incomeCategories = <String, IconData>{
    'حقوق': Icons.work,
    'پاداش': Icons.emoji_events,
    'فروش': Icons.storefront,
    'سرمایه گذاری': Icons.trending_up,
    'هدیه': Icons.redeem,
    'سود بانکی': Icons.savings,
    'سایر': Icons.category,
  };

  const expenseColors = [
    0xFFE53935,
    0xFFFB8C00,
    0xFF3949AB,
    0xFF8E24AA,
    0xFF00897B,
    0xFF6D4C41,
    0xFF546E7A,
    0xFFD81B60,
    0xFF43A047,
    0xFF1E88E5,
    0xFFF4511E,
    0xFF757575,
    0xFF5E35B1,
  ];

  const incomeColors = [
    0xFF2E7D32,
    0xFF4CAF50,
    0xFF00ACC1,
    0xFF7CB342,
    0xFFFDD835,
    0xFF26A69A,
    0xFF9E9E9E,
  ];

  final companion = <CategoriesCompanion>[];
  var i = 0;
  for (final entry in expenseCategories.entries) {
    companion.add(CategoriesCompanion.insert(
      id: _uuid.v4(),
      name: entry.key,
      type: 'expense',
      colorValue: expenseColors[i % expenseColors.length],
      iconCode: entry.value.codePoint,
      isDefault: const Value(true),
    ));
    i++;
  }
  i = 0;
  for (final entry in incomeCategories.entries) {
    companion.add(CategoriesCompanion.insert(
      id: _uuid.v4(),
      name: entry.key,
      type: 'income',
      colorValue: incomeColors[i % incomeColors.length],
      iconCode: entry.value.codePoint,
      isDefault: const Value(true),
    ));
    i++;
  }

  await db.batch((batch) {
    batch.insertAll(db.categories, companion);
    batch.insertAll(db.accounts, [
      AccountsCompanion.insert(
        id: _uuid.v4(),
        name: 'نقدی',
        balance: const Value(0),
        colorValue: 0xFF2E7D32,
        iconCode: Icons.payments.codePoint,
        type: 'cash',
      ),
      AccountsCompanion.insert(
        id: _uuid.v4(),
        name: 'کارت بانکی',
        balance: const Value(0),
        colorValue: 0xFF1E88E5,
        iconCode: Icons.credit_card.codePoint,
        type: 'bank_card',
      ),
    ]);
  });
}
