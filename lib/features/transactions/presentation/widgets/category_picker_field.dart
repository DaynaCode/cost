import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../shared/utils/icon_catalog.dart';

class CategoryPickerField extends StatelessWidget {
  const CategoryPickerField({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  final List<CategoryData> categories;
  final String? selectedCategoryId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedCategoryId,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'دسته بندی'),
      items: categories.map((category) {
        return DropdownMenuItem(
          value: category.id,
          child: Row(
            children: [
              Icon(iconFromCodePoint(category.iconCode),
                  size: 18, color: Color(category.colorValue)),
              const SizedBox(width: 8),
              Text(category.name),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      validator: (value) => value == null ? 'دسته بندی را انتخاب کنید' : null,
    );
  }
}

class AccountPickerField extends StatelessWidget {
  const AccountPickerField({
    super.key,
    required this.accounts,
    required this.selectedAccountId,
    required this.onChanged,
    this.label = 'حساب',
  });

  final List<AccountData> accounts;
  final String? selectedAccountId;
  final ValueChanged<String> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedAccountId,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: accounts.map((account) {
        return DropdownMenuItem(
          value: account.id,
          child: Row(
            children: [
              Icon(iconFromCodePoint(account.iconCode),
                  size: 18, color: Color(account.colorValue)),
              const SizedBox(width: 8),
              Text(account.name),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      validator: (value) => value == null ? 'حساب را انتخاب کنید' : null,
    );
  }
}
