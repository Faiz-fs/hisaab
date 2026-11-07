// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verdicts_dao.dart';

// ignore_for_file: type=lint
mixin _$VerdictsDaoMixin on DatabaseAccessor<AppDatabase> {
  $DailyVerdictsTable get dailyVerdicts => attachedDatabase.dailyVerdicts;
  VerdictsDaoManager get managers => VerdictsDaoManager(this);
}

class VerdictsDaoManager {
  final _$VerdictsDaoMixin _db;
  VerdictsDaoManager(this._db);
  $$DailyVerdictsTableTableManager get dailyVerdicts =>
      $$DailyVerdictsTableTableManager(_db.attachedDatabase, _db.dailyVerdicts);
}
