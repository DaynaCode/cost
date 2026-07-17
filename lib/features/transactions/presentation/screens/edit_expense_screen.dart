import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/persian_date_formatter.dart';
import '../../../../shared/models/transaction_type.dart';
import '../../../../shared/widgets/amount_input_field.dart';
import '../../../accounts/application/accounts_providers.dart';
import '../../../categories/application/categories_providers.dart';
import '../../application/transactions_providers.dart';
import '../widgets/category_picker_field.dart';

class EditExpenseScreen extends ConsumerStatefulWidget {
  const EditExpenseScreen({super.key, this.transactionId});

  final String? transactionId;

  @override
  ConsumerState<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends ConsumerState<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _categoryId;
  String? _accountId;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  DateTime _date = DateTime.now();
  bool _isSaving = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.transactionId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    if (widget.transactionId == null || _isLoaded) return;
    final repository = ref.read(transactionsRepositoryProvider);
    final transaction = await repository.getById(widget.transactionId!);
    if (transaction == null || !mounted) return;
    setState(() {
      _titleController.text = transaction.title;
      _amountController.text = transaction.amount.toStringAsFixed(0);
      _descriptionController.text = transaction.description;
      _categoryId = transaction.categoryId;
      _accountId = transaction.accountId;
      _paymentMethod = PaymentMethodX.fromStorage(transaction.paymentMethod);
      _date = transaction.date;
      _isLoaded = true;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2015),
      lastDate: DateTime(2045),
    );
    if (picked != null) setState(() => _date = picked);
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
    final repository = ref.read(transactionsRepositoryProvider);
    final amount = parseAmount(_amountController.text);

    try {
      if (widget.transactionId != null) {
        final original = await repository.getById(widget.transactionId!);
        if (original != null) {
          await repository.updateTransaction(
            original: original,
            title: _titleController.text.trim(),
            amount: amount,
            categoryId: _categoryId!,
            accountId: _accountId!,
            date: _date,
            description: _descriptionController.text.trim(),
            paymentMethod: _paymentMethod.storageValue,
          );
        }
      } else {
        await repository.addExpense(
          title: _titleController.text.trim(),
          amount: amount,
          categoryId: _categoryId!,
          accountId: _accountId!,
          date: _date,
          description: _descriptionController.text.trim(),
          paymentMethod: _paymentMethod.storageValue,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(expenseCategoriesProvider).valueOrNull ?? [];
    final accounts = ref.watch(accountsListProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.transactionId != null ? 'ویرایش هزینه' : 'افزودن هزینه'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
            DropdownButtonFormField<PaymentMethod>(
              initialValue: _paymentMethod,
              decoration: const InputDecoration(labelText: 'روش پرداخت'),
              items: PaymentMethod.values
                  .map((method) => DropdownMenuItem(
                        value: method,
                        child: Text(method.label),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _paymentMethod = value);
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('تاریخ'),
              subtitle: Text(PersianDateFormatter.formatDate(_date)),
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
