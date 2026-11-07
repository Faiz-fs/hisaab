import 'package:drift/drift.dart';

/// Bank account table.
class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get bankName => text()();
  TextColumn get last4 => text().withLength(min: 4, max: 4)();
  IntColumn get balance => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Transaction table. Raw SMS text is NEVER stored here.
/// [kind]           spend | family | savings | emi | income | internal | refund
/// [categorySource] auto (rule/parser) | user (set manually, never overwritten)
class Txns extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text()();
  IntColumn get amount => integer()();
  TextColumn get direction => text()();
  TextColumn get mode => text()();
  TextColumn get payee => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get refNo => text().nullable()();
  IntColumn get balanceAfter => integer().nullable()();
  DateTimeColumn get at => dateTime()();
  TextColumn get kind => text().withDefault(const Constant('spend'))();
  TextColumn get categorySource => text().withDefault(const Constant('auto'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Payee rules: pattern -> category + kind.
class PayeeRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get pattern => text()();
  TextColumn get category => text()();
  BoolColumn get isRegex => boolean().withDefault(const Constant(false))();
  TextColumn get kind => text().withDefault(const Constant('spend'))();
}

/// Daily verdict table.
class DailyVerdicts extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get rating => integer()();
  IntColumn get totalSpent => integer()();
  TextColumn get topCulprits => text()();
  TextColumn get verdictJson => text()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {date},
  ];
}
