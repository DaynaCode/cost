import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/persian_date_formatter.dart';
import '../../../../shared/models/transaction_type.dart';
import '../../../../shared/widgets/amount_input_field.dart';
import '../../../accounts/application/accounts_providers.dart';
import '../../../categories/application/categories_providers.dart';
import '../../../transactions/presentation/widgets/category_picker_field.dart';
import '../../application/recurring_providers.dart';

class EditRecurringScreen extends ConsumerStatefulWidget {
  const EditRecurringScreen({super.key, this.recurring});

  final RecurringTransactionData? recurring;

  @override
  ConsumerState<EditRecurringScreen> createState() =>
      _EditRecurringScreenState();
}

class _EditRecurringScreenState extends ConsumerState<EditRecurringScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  TransactionType _type = TransactionType.expense;
  String? _categoryId;
  String? _accountId;
  RecurringFrequency _frequency = RecurringFrequency.monthly;
  DateTime _startDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final recurring = widget.recurring;
    _titleController = TextEditingController(text: recurring?.title ?? '');
    _amountController = TextEditingController(
        text: recurring?.amount.toStringAsFixed(0) ?? '');
    _descriptionController =
        TextEditingController(text: recurring?.description ?? '');
    if (recurring != null) {
      _type = TransactionTypeX.fromStorage(recurring.type);
      _categoryId = recurring.categoryId;
      _accountId = recurring.accountId;
      _frequency = RecurringFrequencyX.fromStorage(recurring.frequency);
      _startDate = recurring.startDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2015),
      lastDate: DateTime(2045),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() ||
        _categoryId == null ||
        _accountId == null) {
      if (_categoryId == null || _accountId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لطفا دسته بندی و حساب را انتخاب کنید')),
        );
      }
      return;
    }
    setState(() => _isSaving = true);
    final repository = ref.read(recurringRepositoryProvider);
    try {
      if (widget.recurring != null) {
        await repository.update(widget.recurring!.copyWith(
          title: _titleController.text.trim(),
          amount: parseAmount(_amountController.text),
          type: _type.storageValue,
          categoryId: _categoryId!,
          accountId: _accountId!,
          frequency: _frequency.storageValue,
          startDate: _startDate,
          description: _descriptionController.text.trim(),
        ));
      } else {
        await repository.create(
          title: _titleController.text.trim(),
          amount: parseAmount(_amountController.text),
          type: _type.storageValue,
          categoryId: _categoryId!,
          accountId: _accountId!,
          frequency: _frequency.storageValue,
          startDate: _startDate,
          description: _descriptionController.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    if (widget.recurring == null) return;
    await ref.read(recurringRepositoryProvider).delete(widget.recurring!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _type == TransactionType.income
        ? ref.watch(incomeCategoriesProvider).valueOrNull ?? []
        : ref.watch(expenseCategoriesProvider).valueOrNull ?? [];
    final accounts = ref.watch(accountsListProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recurring != null
            ? 'ویرایش تراکنش تکرارشونده'
            : 'تراکنش تکرارشونده جدید'),
        actions: [
          if (widget.recurring != null)
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
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                    value: TransactionType.income, label: Text('درآمد')),
                ButtonSegment(
                    value: TransactionType.expense, label: Text('هزینه')),
              ],
              selected: {_type},
              onSelectionChanged: (selection) => setState(() {
                _type = selection.first;
                _categoryId = null;
              }),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'عنوان'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'عنوان را وارد کنید' : null,
            ),
            const SizedBox(height: 16),
            AmountInputField(controller: _amountController),
            const SizedBox(height: 16),
            CategoryPickerField(
              categories: categories,
              selectedCategoryId: _categoryId,
              onChanged: (value) => setState(() => _categoryId = value),
            ),
            const SizedBox(height: 16),
            AccountPickerField(
              accounts: accounts,
              selectedAccountId: _accountId,
              onChanged: (value) => setState(() => _accountId = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<RecurringFrequency>(
              initialValue: _frequency,
              decoration: const InputDecoration(labelText: 'دوره تکرار'),
              items: RecurringFrequency.values
                  .map((frequency) => DropdownMenuItem(
                        value: frequency,
                        child: Text(frequency.label),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _frequency = value);
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('تاریخ شروع'),
              subtitle: Text(PersianDateFormatter.formatDate(_startDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'توضیحات'),
              maxLines: 3,
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
