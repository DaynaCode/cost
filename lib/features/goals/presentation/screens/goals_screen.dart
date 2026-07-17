import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/persian_number_formatter.dart';
import '../../../../shared/widgets/amount_input_field.dart';
import '../../../../shared/utils/icon_catalog.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../application/goals_providers.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsListProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('اهداف مالی')),
      body: goals.isEmpty
          ? const EmptyState(
              icon: Icons.flag,
              title: 'هنوز هدفی تعریف نشده است',
              subtitle: 'برای پس انداز هدفمند یک هدف جدید ایجاد کنید',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                final progress = goal.targetAmount <= 0
                    ? 0.0
                    : (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
                final color = Color(goal.colorValue);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    onTap: () => context.push('/goals/edit', extra: goal),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(iconFromCodePoint(goal.iconCode),
                                  color: color),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(goal.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                            ),
                            if (goal.isCompleted)
                              const Icon(Icons.check_circle,
                                  color: Color(0xFF2E7D32)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            color: color,
                            backgroundColor: color.withValues(alpha: 0.12),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${PersianNumberFormatter.formatAmount(goal.currentAmount)} از ${PersianNumberFormatter.formatAmount(goal.targetAmount)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '${PersianNumberFormatter.toPersianDigits((progress * 100).toStringAsFixed(0))}٪',
                              style: TextStyle(
                                  color: color, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => _showContributeDialog(context, ref, goal.id),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('افزودن مبلغ'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/goals/edit'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showContributeDialog(BuildContext context, WidgetRef ref, String goalId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('افزودن به هدف'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'مبلغ', suffixText: 'تومان'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () async {
              final amount = parseAmount(controller.text);
              if (amount > 0) {
                await ref.read(goalsRepositoryProvider).addContribution(goalId, amount);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('ثبت'),
          ),
        ],
      ),
    );
  }
}
