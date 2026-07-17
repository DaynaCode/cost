import 'package:drift/drift.dart';

@DataClassName('AccountData')
class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get balance => real().withDefault(const Constant(0))();
  IntColumn get colorValue => integer()();
  IntColumn get iconCode => integer()();
  TextColumn get type => text()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CategoryData')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  IntColumn get colorValue => integer()();
  IntColumn get iconCode => integer()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TransactionData')
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  TextColumn get type => text()();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get accountId => text().references(Accounts, #id)();
  TextColumn get toAccountId =>
      text().nullable().references(Accounts, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get paymentMethod => text().nullable()();
  TextColumn get recurringId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('BudgetData')
class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().references(Categories, #id)();
  RealColumn get amount => real()();
  TextColumn get period => text()();
  DateTimeColumn get startDate => dateTime()();
  IntColumn get notifiedThreshold => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RecurringTransactionData')
class RecurringTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  TextColumn get type => text()();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get accountId => text().references(Accounts, #id)();
  TextColumn get frequency => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get nextOccurrence => dateTime()();
  TextColumn get description => text().withDefault(const Constant(''))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('GoalData')
class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  RealColumn get targetAmount => real()();
  RealColumn get currentAmount => real().withDefault(const Constant(0))();
  DateTimeColumn get deadline => dateTime().nullable()();
  IntColumn get colorValue => integer()();
  IntColumn get iconCode => integer()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
