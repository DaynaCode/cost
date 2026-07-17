import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../shared/models/transaction_type.dart';
import '../../../../shared/utils/icon_catalog.dart';
import '../../../../shared/widgets/amount_input_field.dart';
import '../../../../shared/widgets/color_icon_picker.dart';
import '../../application/accounts_providers.dart';

class EditAccountScreen extends ConsumerStatefulWidget {
  const EditAccountScreen({super.key, this.account});

  final AccountData? account;

  @override
  ConsumerState<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends ConsumerState<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late AccountType _type;
  late int _colorValue;
  late int _iconCode;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final account = widget.account;
    _nameController = TextEditingController(text: account?.name ?? '');
    _balanceController =
        TextEditingController(text: account?.balance.toStringAsFixed(0) ?? '0');
    _type = AccountTypeX.fromStorage(account?.type ?? 'cash');
    _colorValue = account?.colorValue ?? colorPalette.first;
    _iconCode = account?.iconCode ?? Icons.payments.codePoint;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final repository = ref.read(accountsRepositoryProvider);
    try {
      if (widget.account != null) {
        await repository.update(widget.account!.copyWith(
          name: _nameController.text.trim(),
          colorValue: _colorValue,
          iconCode: _iconCode,
          type: _type.storageValue,
        ));
      } else {
        await repository.create(
          name: _nameController.text.trim(),
          balance: parseAmount(_balanceController.text),
          colorValue: _colorValue,
          iconCode: _iconCode,
          type: _type.storageValue,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final account = widget.account;
    if (account == null) return;
    final repository = ref.read(accountsRepositoryProvider);
    final isUsed = await repository.isUsedByTransactions(account.id);
    if (isUsed) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('این حساب دارای تراکنش است و قابل حذف نیست')),
        );
      }
      return;
    }
    await repository.archive(account.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account != null ? 'ویرایش حساب' : 'حساب جدید'),
        actions: [
          if (widget.account != null)
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
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'نام حساب'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'نام را وارد کنید' : null,
            ),
            const SizedBox(height: 16),
            if (widget.account == null) ...[
              AmountInputField(controller: _balanceController, label: 'موجودی اولیه'),
              const SizedBox(height: 16),
            ],
            DropdownButtonFormField<AccountType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'نوع حساب'),
              items: AccountType.values
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _type = value);
              },
            ),
            const SizedBox(height: 20),
            Text('رنگ', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ColorPickerGrid(
              selectedColor: _colorValue,
              onColorSelected: (value) => setState(() => _colorValue = value),
            ),
            const SizedBox(height: 20),
            Text('آیکون', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            IconPickerGrid(
              selectedIconCodePoint: _iconCode,
              color: Color(_colorValue),
              onIconSelected: (value) => setState(() => _iconCode = value),
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
