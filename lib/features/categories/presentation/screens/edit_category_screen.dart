import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../shared/utils/icon_catalog.dart';
import '../../../../shared/widgets/color_icon_picker.dart';
import '../../application/categories_providers.dart';

class EditCategoryScreen extends ConsumerStatefulWidget {
  const EditCategoryScreen({super.key, this.category});

  final CategoryData? category;

  @override
  ConsumerState<EditCategoryScreen> createState() =>
      _EditCategoryScreenState();
}

class _EditCategoryScreenState extends ConsumerState<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _type;
  late int _colorValue;
  late int _iconCode;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    _nameController = TextEditingController(text: category?.name ?? '');
    _type = category?.type ?? 'expense';
    _colorValue = category?.colorValue ?? colorPalette.first;
    _iconCode = category?.iconCode ?? Icons.category.codePoint;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final repository = ref.read(categoriesRepositoryProvider);
    try {
      if (widget.category != null) {
        await repository.update(widget.category!.copyWith(
          name: _nameController.text.trim(),
          colorValue: _colorValue,
          iconCode: _iconCode,
        ));
      } else {
        await repository.create(
          name: _nameController.text.trim(),
          type: _type,
          colorValue: _colorValue,
          iconCode: _iconCode,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final category = widget.category;
    if (category == null) return;
    final repository = ref.read(categoriesRepositoryProvider);
    if (category.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('دسته بندی های پیش فرض قابل حذف نیستند')),
      );
      return;
    }
    final isUsed = await repository.isUsed(category.id);
    if (isUsed) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('این دسته بندی دارای تراکنش است و قابل حذف نیست')),
        );
      }
      return;
    }
    await repository.delete(category.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category != null ? 'ویرایش دسته بندی' : 'دسته بندی جدید'),
        actions: [
          if (widget.category != null && !widget.category!.isDefault)
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
              decoration: const InputDecoration(labelText: 'نام دسته بندی'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'نام را وارد کنید' : null,
            ),
            const SizedBox(height: 16),
            if (widget.category == null)
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'expense', label: Text('هزینه')),
                  ButtonSegment(value: 'income', label: Text('درآمد')),
                ],
                selected: {_type},
                onSelectionChanged: (selection) =>
                    setState(() => _type = selection.first),
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
