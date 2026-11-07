import 'package:drift/drift.dart';

/// Bank account table.
/// [id] – UUID primary key.
/// [bankName] – e.g. "HDFC", "SBI".
/// [last4] – last 4 digits of the account/card.
/// [balance] – current known balance in paise (integer to avoid float errors).
class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get bankName => text()();
  TextColumn get last4 => text().withLength(min: 4, max: 4)();
  IntColumn get balance => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Transaction table.
/// Raw SMS text is NEVER stored here – only parsed, hashed fields.
/// [id] – SHA-256 hash for deduplication.
/// [accountId] – FK → Accounts.id.
/// [amount] – in paise.
/// [direction] – "debit" | "credit".
/// [mode] – PayMode enum string.
/// [payee] – merchant/payee name (null if unknown).
/// [category] – categorised merchant bucket.
/// [refNo] – reference number from SMS.
/// [balanceAfter] – in paise.
/// [at] – transaction timestamp.
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

  @override
  Set<Column> get primaryKey => {id};
}

/// Payee rules table for custom categorisation overrides.
/// [pattern] – substring or regex to match merchant strings.
/// [category] – the category to assign.
class PayeeRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get pattern => text()();
  TextColumn get category => text()();
  BoolColumn get isRegex => boolean().withDefault(const Constant(false))();
}

/// Daily verdict summaries.
/// One row per calendar day per account context.
/// [date] – day (stored as midnight UTC).
/// [rating] – 0–10 score.
/// [totalSpent] – in paise.
/// [topCulprits] – JSON array of category strings.
/// [verdictJson] – full serialised DailyVerdict model.
class DailyVerdicts extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get rating => integer()();
  IntColumn get totalSpent => integer()();
  TextColumn get topCulprits => text()();
  TextColumn get verdictJson => text()();

  @override
  List<Set<Column>> get uniqueKeys => [{date}];
}
