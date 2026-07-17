import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../shared/models/transaction_type.dart';
import '../../../../shared/widgets/amount_input_field.dart';
import '../../../categories/application/categories_providers.dart';
import '../../../transactions/presentation/widgets/category_picker_field.dart';
import '../../application/budgets_providers.dart';

class EditBudgetScreen extends ConsumerStatefulWidget {
  const EditBudgetScreen({super.key, this.budget});

  final BudgetData? budget;

  @override
  ConsumerState<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends ConsumerState<EditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  String? _categoryId;
  BudgetPeriod _period = BudgetPeriod.monthly;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final budget = widget.budget;
    _amountController =
        TextEditingController(text: budget?.amount.toStringAsFixed(0) ?? '');
    _categoryId = budget?.categoryId;
    _period = budget != null
        ? BudgetPeriodX.fromStorage(budget.period)
        : BudgetPeriod.monthly;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _categoryId == null) {
      if (_categoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('دسته بندی را انتخاب کنید')),
        );
      }
      return;
    }
    setState(() => _isSaving = true);
    final repository = ref.read(budgetsRepositoryProvider);
    try {
      if (widget.budget != null) {
        await repository.update(widget.budget!.copyWith(
          categoryId: _categoryId!,
          amount: parseAmount(_amountController.text),
          period: _period.storageValue,
        ));
      } else {
        await repository.create(
          categoryId: _categoryId!,
          amount: parseAmount(_amountController.text),
          period: _period.storageValue,
          startDate: DateTime.now(),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    if (widget.budget == null) return;
    await ref.read(budgetsRepositoryProvider).delete(widget.budget!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(expenseCategoriesProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.budget != null ? 'ویرایش بودجه' : 'بودجه جدید'),
        actions: [
          if (widget.budget != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CategoryPickerField(
              categories: categories,
              selectedCategoryId: _categoryId,
              onChanged: (value) => setState(() => _categoryId = value),
            ),
            const SizedBox(height: 16),
            AmountInputField(controller: _amountController, label: 'مبلغ بودجه'),
            const SizedBox(height: 16),
            DropdownButtonFormField<BudgetPeriod>(
              initialValue: _period,
              decoration: const InputDecoration(labelText: 'دوره بودجه'),
              items: BudgetPeriod.values
                  .map((period) => DropdownMenuItem(
                        value: period,
                        child: Text(period.label),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _period = value);
              },
            ),
            const SizedBox(height: 8),
            Text(
              'در صورت رسیدن به ۵۰٪، ۷۵٪، ۹۰٪ و ۱۰۰٪ بودجه، اعلان دریافت خواهید کرد',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );
  }
}
