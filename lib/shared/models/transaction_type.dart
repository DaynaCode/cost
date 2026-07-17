enum TransactionType { income, expense, transfer }

extension TransactionTypeX on TransactionType {
  String get storageValue => name;

  String get label {
    switch (this) {
      case TransactionType.income:
        return 'درآمد';
      case TransactionType.expense:
        return 'هزینه';
      case TransactionType.transfer:
        return 'انتقال';
    }
  }

  static TransactionType fromStorage(String value) {
    return TransactionType.values.firstWhere((e) => e.name == value);
  }
}

enum AccountType { cash, bankCard, wallet, savings }

extension AccountTypeX on AccountType {
  String get storageValue {
    switch (this) {
      case AccountType.cash:
        return 'cash';
      case AccountType.bankCard:
        return 'bank_card';
      case AccountType.wallet:
        return 'wallet';
      case AccountType.savings:
        return 'savings';
    }
  }

  String get label {
    switch (this) {
      case AccountType.cash:
        return 'نقدی';
      case AccountType.bankCard:
        return 'کارت بانکی';
      case AccountType.wallet:
        return 'کیف پول';
      case AccountType.savings:
        return 'پس انداز';
    }
  }

  static AccountType fromStorage(String value) {
    switch (value) {
      case 'cash':
        return AccountType.cash;
      case 'bank_card':
        return AccountType.bankCard;
      case 'wallet':
        return AccountType.wallet;
      case 'savings':
        return AccountType.savings;
      default:
        return AccountType.cash;
    }
  }
}

enum PaymentMethod { cash, card, online, cheque }

extension PaymentMethodX on PaymentMethod {
  String get storageValue => name;

  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'نقدی';
      case PaymentMethod.card:
        return 'کارت بانکی';
      case PaymentMethod.online:
        return 'پرداخت آنلاین';
      case PaymentMethod.cheque:
        return 'چک';
    }
  }

  static PaymentMethod fromStorage(String? value) {
    if (value == null) return PaymentMethod.cash;
    return PaymentMethod.values.firstWhere((e) => e.name == value,
        orElse: () => PaymentMethod.cash);
  }
}

enum BudgetPeriod { monthly, weekly, yearly }

extension BudgetPeriodX on BudgetPeriod {
  String get storageValue => name;

  String get label {
    switch (this) {
      case BudgetPeriod.monthly:
        return 'ماهانه';
      case BudgetPeriod.weekly:
        return 'هفتگی';
      case BudgetPeriod.yearly:
        return 'سالانه';
    }
  }

  static BudgetPeriod fromStorage(String value) {
    return BudgetPeriod.values.firstWhere((e) => e.name == value,
        orElse: () => BudgetPeriod.monthly);
  }
}

enum RecurringFrequency { daily, weekly, monthly, yearly }

extension RecurringFrequencyX on RecurringFrequency {
  String get storageValue => name;

  String get label {
    switch (this) {
      case RecurringFrequency.daily:
        return 'روزانه';
      case RecurringFrequency.weekly:
        return 'هفتگی';
      case RecurringFrequency.monthly:
        return 'ماهانه';
      case RecurringFrequency.yearly:
        return 'سالانه';
    }
  }

  static RecurringFrequency fromStorage(String value) {
    return RecurringFrequency.values.firstWhere((e) => e.name == value,
        orElse: () => RecurringFrequency.monthly);
  }

  DateTime nextOccurrenceFrom(DateTime date) {
    switch (this) {
      case RecurringFrequency.daily:
        return date.add(const Duration(days: 1));
      case RecurringFrequency.weekly:
        return date.add(const Duration(days: 7));
      case RecurringFrequency.monthly:
        return DateTime(date.year, date.month + 1, date.day, date.hour,
            date.minute);
      case RecurringFrequency.yearly:
        return DateTime(
            date.year + 1, date.month, date.day, date.hour, date.minute);
    }
  }
}

enum SortOption { newest, oldest, highestAmount, lowestAmount }

extension SortOptionX on SortOption {
  String get label {
    switch (this) {
      case SortOption.newest:
        return 'جدیدترین';
      case SortOption.oldest:
        return 'قدیمی ترین';
      case SortOption.highestAmount:
        return 'بیشترین مبلغ';
      case SortOption.lowestAmount:
        return 'کمترین مبلغ';
    }
  }
}
