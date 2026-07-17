import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../shared/utils/icon_catalog.dart';
import '../../domain/transaction_model.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({
    super.key,
    required this.initialFilter,
    required this.categories,
    required this.accounts,
  });

  final TransactionFilter initialFilter;
  final List<CategoryData> categories;
  final List<AccountData> accounts;

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late TransactionDateFilter _dateFilter;
  late Set<String> _categoryIds;
  late Set<String> _accountIds;
  String? _typeFilter;

  @override
  void initState() {
    super.initState();
    _dateFilter = widget.initialFilter.dateFilter;
    _categoryIds = {...widget.initialFilter.categoryIds};
    _accountIds = {...widget.initialFilter.accountIds};
    _typeFilter = widget.initialFilter.typeFilter;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('فیلتر تراکنش ها',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _dateFilter = TransactionDateFilter.all;
                        _categoryIds = {};
                        _accountIds = {};
                        _typeFilter = null;
                      });
                    },
                    child: const Text('پاک کردن'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('نوع تراکنش',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('درآمد'),
                    selected: _typeFilter == 'income',
                    onSelected: (selected) => setState(
                        () => _typeFilter = selected ? 'income' : null),
                  ),
                  ChoiceChip(
                    label: const Text('هزینه'),
                    selected: _typeFilter == 'expense',
                    onSelected: (selected) => setState(
                        () => _typeFilter = selected ? 'expense' : null),
                  ),
                  ChoiceChip(
                    label: const Text('انتقال'),
                    selected: _typeFilter == 'transfer',
                    onSelected: (selected) => setState(
                        () => _typeFilter = selected ? 'transfer' : null),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('بازه زمانی',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _dateChip('همه', TransactionDateFilter.all),
                  _dateChip('امروز', TransactionDateFilter.today),
                  _dateChip('این هفته', TransactionDateFilter.thisWeek),
                  _dateChip('این ماه', TransactionDateFilter.thisMonth),
                  _dateChip('امسال', TransactionDateFilter.thisYear),
                ],
              ),
              const SizedBox(height: 16),
              Text('دسته بندی',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.categories.map((category) {
                  final selected = _categoryIds.contains(category.id);
                  return FilterChip(
                    avatar: Icon(iconFromCodePoint(category.iconCode),
                        size: 16, color: Color(category.colorValue)),
                    label: Text(category.name),
                    selected: selected,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _categoryIds.add(category.id);
                        } else {
                          _categoryIds.remove(category.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text('حساب',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.accounts.map((account) {
                  final selected = _accountIds.contains(account.id);
                  return FilterChip(
                    label: Text(account.name),
                    selected: selected,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _accountIds.add(account.id);
                        } else {
                          _accountIds.remove(account.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    TransactionFilter(
                      dateFilter: _dateFilter,
                      categoryIds: _categoryIds,
                      accountIds: _accountIds,
                      typeFilter: _typeFilter,
                    ),
                  );
                },
                child: const SizedBox(
                  width: double.infinity,
                  child: Text('اعمال فیلتر', textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dateChip(String label, TransactionDateFilter filter) {
    return ChoiceChip(
      label: Text(label),
      selected: _dateFilter == filter,
      onSelected: (selected) {
        if (selected) setState(() => _dateFilter = filter);
      },
    );
  }
}
