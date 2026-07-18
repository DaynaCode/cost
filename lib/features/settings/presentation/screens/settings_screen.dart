import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final settings = ref.watch(settingsServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات')),
      body: ListView(
        children: [
          const _SectionLabel('ظاهر برنامه'),
          RadioGroup<AppThemeMode>(
            groupValue: themeMode,
            onChanged: (value) =>
                ref.read(themeModeProvider.notifier).setMode(value!),
            child: const Column(
              children: [
                RadioListTile<AppThemeMode>(
                  title: Text('پیروی از سیستم'),
                  value: AppThemeMode.system,
                ),
                RadioListTile<AppThemeMode>(
                  title: Text('روشن'),
                  value: AppThemeMode.light,
                ),
                RadioListTile<AppThemeMode>(
                  title: Text('تیره'),
                  value: AppThemeMode.dark,
                ),
              ],
            ),
          ),
          const Divider(),
          const _SectionLabel('مدیریت داده ها'),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('حساب ها'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => context.push('/accounts'),
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('دسته بندی ها'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => context.push('/categories'),
          ),
          ListTile(
            leading: const Icon(Icons.pie_chart_outline),
            title: const Text('بودجه بندی'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => context.push('/budgets'),
          ),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: const Text('تراکنش های تکرارشونده'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => context.push('/recurring'),
          ),
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: const Text('اهداف مالی'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => context.push('/goals'),
          ),
          const Divider(),
          const _SectionLabel('یادآوری ها'),
          SwitchListTile(
            title: const Text('یادآوری روزانه ثبت هزینه'),
            subtitle: Text(
                'ساعت ${settings.dailyReminderHour}:${settings.dailyReminderMinute.toString().padLeft(2, '0')}'),
            value: settings.isDailyReminderEnabled,
            onChanged: (value) async {
              await settings.setDailyReminderEnabled(value);
              final notificationService = ref.read(notificationServiceProvider);
              if (value) {
                await notificationService.scheduleDailyReminder(
                  hour: settings.dailyReminderHour,
                  minute: settings.dailyReminderMinute,
                );
              } else {
                await notificationService.cancelDailyReminder();
              }
              setState(() {});
            },
          ),
          if (settings.isDailyReminderEnabled)
            ListTile(
              title: const Text('زمان یادآوری'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: settings.dailyReminderHour,
                    minute: settings.dailyReminderMinute,
                  ),
                );
                if (picked != null) {
                  await settings.setDailyReminderTime(picked.hour, picked.minute);
                  await ref.read(notificationServiceProvider).scheduleDailyReminder(
                        hour: picked.hour,
                        minute: picked.minute,
                      );
                  setState(() {});
                }
              },
            ),
          const Divider(),
          const _SectionLabel('امنیت و پشتیبان گیری'),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('امنیت'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => context.push('/security-settings'),
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('پشتیبان گیری و بازیابی'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => context.push('/backup-restore'),
          ),
          const Divider(),
          const _SectionLabel('درباره'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('درباره برنامه'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => context.push('/about'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
