import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_card.dart';
import '../../../accounts/application/accounts_providers.dart';
import '../../../categories/application/categories_providers.dart';
import '../../../transactions/application/transactions_providers.dart';
import '../../application/settings_providers.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _isBusy = false;

  Future<void> _exportBackup() async {
    setState(() => _isBusy = true);
    try {
      final service = ref.read(backupServiceProvider);
      final file = await service.exportToJson();
      await service.shareBackup(file);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('پشتیبان گیری با موفقیت انجام شد')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _restoreBackup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('بازیابی اطلاعات'),
        content: const Text(
            'با بازیابی، تمام اطلاعات فعلی جایگزین خواهند شد. آیا ادامه می دهید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('بازیابی'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = result?.files.single.path;
    if (path == null) return;

    setState(() => _isBusy = true);
    try {
      final content = await File(path).readAsString();
      await ref.read(backupServiceProvider).restoreFromJson(content);
      ref.invalidate(accountsListProvider);
      ref.invalidate(allCategoriesProvider);
      ref.invalidate(allTransactionsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('بازیابی اطلاعات با موفقیت انجام شد')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فایل انتخاب شده معتبر نیست')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _export(String format) async {
    setState(() => _isBusy = true);
    try {
      final transactions = ref.read(allTransactionsProvider).valueOrNull ?? [];
      final categoriesById = ref.read(categoriesByIdProvider);
      final accountsById = ref.read(accountsByIdProvider);
      final service = ref.read(exportServiceProvider);

      final file = switch (format) {
        'csv' => await service.exportCsv(
            transactions: transactions,
            categoriesById: categoriesById,
            accountsById: accountsById,
          ),
        'excel' => await service.exportExcel(
            transactions: transactions,
            categoriesById: categoriesById,
            accountsById: accountsById,
          ),
        _ => await service.exportPdf(
            transactions: transactions,
            categoriesById: categoriesById,
            accountsById: accountsById,
          ),
      };
      await service.shareFile(file);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _deleteAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف تمام اطلاعات'),
        content: const Text(
            'این عملیات غیرقابل بازگشت است و تمام تراکنش ها، حساب ها و بودجه ها حذف خواهند شد. ادامه می دهید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف همه'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(backupServiceProvider).deleteAllData();
    ref.invalidate(accountsListProvider);
    ref.invalidate(allCategoriesProvider);
    ref.invalidate(allTransactionsProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمام اطلاعات حذف شد')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پشتیبان گیری و بازیابی')),
      body: AbsorbPointer(
        absorbing: _isBusy,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('پشتیبان گیری',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    'از تمام اطلاعات خود یک فایل پشتیبان JSON تهیه کنید',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _isBusy ? null : _exportBackup,
                    icon: const Icon(Icons.backup),
                    label: const Text('تهیه پشتیبان'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('بازیابی اطلاعات',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    'اطلاعات را از یک فایل پشتیبان JSON بازیابی کنید',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _isBusy ? null : _restoreBackup,
                    icon: const Icon(Icons.restore),
                    label: const Text('بازیابی از فایل'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('خروجی گزارش',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: _isBusy ? null : () => _export('csv'),
                        child: const Text('CSV'),
                      ),
                      OutlinedButton(
                        onPressed: _isBusy ? null : () => _export('excel'),
                        child: const Text('Excel'),
                      ),
                      OutlinedButton(
                        onPressed: _isBusy ? null : () => _export('pdf'),
                        child: const Text('PDF'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('حذف تمام اطلاعات',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFE53935))),
                  const SizedBox(height: 8),
                  Text(
                    'تمام تراکنش ها، حساب ها، بودجه ها و اهداف حذف خواهند شد',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE53935)),
                    onPressed: _isBusy ? null : _deleteAllData,
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('حذف همه اطلاعات'),
                  ),
                ],
              ),
            ),
            if (_isBusy) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
