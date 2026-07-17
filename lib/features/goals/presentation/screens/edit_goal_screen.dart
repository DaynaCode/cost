import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/persian_date_formatter.dart';
import '../../../../shared/utils/icon_catalog.dart';
import '../../../../shared/widgets/amount_input_field.dart';
import '../../../../shared/widgets/color_icon_picker.dart';
import '../../application/goals_providers.dart';

class EditGoalScreen extends ConsumerStatefulWidget {
  const EditGoalScreen({super.key, this.goal});

  final GoalData? goal;

  @override
  ConsumerState<EditGoalScreen> createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends ConsumerState<EditGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _targetController;
  DateTime? _deadline;
  late int _colorValue;
  late int _iconCode;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final goal = widget.goal;
    _titleController = TextEditingController(text: goal?.title ?? '');
    _targetController =
        TextEditingController(text: goal?.targetAmount.toStringAsFixed(0) ?? '');
    _deadline = goal?.deadline;
    _colorValue = goal?.colorValue ?? colorPalette.first;
    _iconCode = goal?.iconCode ?? Icons.flag.codePoint;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2060),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final repository = ref.read(goalsRepositoryProvider);
    try {
      if (widget.goal != null) {
        await repository.update(widget.goal!.copyWith(
          title: _titleController.text.trim(),
          targetAmount: parseAmount(_targetController.text),
          colorValue: _colorValue,
          iconCode: _iconCode,
          deadline: Value(_deadline),
        ));
      } else {
        await repository.create(
          title: _titleController.text.trim(),
          targetAmount: parseAmount(_targetController.text),
          colorValue: _colorValue,
          iconCode: _iconCode,
          deadline: _deadline,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    if (widget.goal == null) return;
    await ref.read(goalsRepositoryProvider).delete(widget.goal!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal != null ? 'ویرایش هدف' : 'هدف جدید'),
        actions: [
          if (widget.goal != null)
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
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'عنوان هدف'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'عنوان را وارد کنید' : null,
            ),
            const SizedBox(height: 16),
            AmountInputField(controller: _targetController, label: 'مبلغ هدف'),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('مهلت (اختیاری)'),
              subtitle: Text(_deadline != null
                  ? PersianDateFormatter.formatDate(_deadline!)
                  : 'انتخاب نشده'),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDeadline,
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
