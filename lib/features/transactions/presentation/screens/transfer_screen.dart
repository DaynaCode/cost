import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/persian_date_formatter.dart';
import '../../../../shared/widgets/amount_input_field.dart';
import '../../../accounts/application/accounts_providers.dart';
import '../../../categories/application/categories_providers.dart';
import '../../application/transactions_providers.dart';
import '../widgets/category_picker_field.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _fromAccountId;
  String? _toAccountId;
  DateTime _date = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
    if (!_formKey.currentState!.validate()) return;
    if (_fromAccountId == null || _toAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفا حساب مبدا و مقصد را انتخاب کنید')),
      );
      return;
    }
    if (_fromAccountId == _toAccountId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حساب مبدا و مقصد نمی توانند یکسان باشند')),
      );
      return;
    }

    final categories = ref.read(allCategoriesProvider).valueOrNull ?? [];
    final transferCategory = categories.firstWhere(
      (category) => category.name == 'سایر',
      orElse: () => categories.first,
    );

    setState(() => _isSaving = true);
    try {
      await ref.read(transactionsRepositoryProvider).addTransfer(
            amount: parseAmount(_amountController.text),
            fromAccountId: _fromAccountId!,
            toAccountId: _toAccountId!,
            transferCategoryId: transferCategory.id,
            date: _date,
            description: _descriptionController.text.trim(),
          );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsListProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('انتقال وجه')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AccountPickerField(
              accounts: accounts,
              selectedAccountId: _fromAccountId,
              label: 'از حساب',
              onChanged: (value) => setState(() => _fromAccountId = value),
            ),
            const SizedBox(height: 16),
            const Center(child: Icon(Icons.arrow_downward)),
            const SizedBox(height: 16),
            AccountPickerField(
              accounts: accounts,
              selectedAccountId: _toAccountId,
              label: 'به حساب',
              onChanged: (value) => setState(() => _toAccountId = value),
            ),
            const SizedBox(height: 16),
            AmountInputField(controller: _amountController),
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
                  : const Text('انتقال'),
            ),
          ],
        ),
      ),
    );
  }
}
