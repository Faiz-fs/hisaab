// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payee_rules_dao.dart';

// ignore_for_file: type=lint
mixin _$PayeeRulesDaoMixin on DatabaseAccessor<AppDatabase> {
  $PayeeRulesTable get payeeRules => attachedDatabase.payeeRules;
  PayeeRulesDaoManager get managers => PayeeRulesDaoManager(this);
}

class PayeeRulesDaoManager {
  final _$PayeeRulesDaoMixin _db;
  PayeeRulesDaoManager(this._db);
  $$PayeeRulesTableTableManager get payeeRules =>
      $$PayeeRulesTableTableManager(_db.attachedDatabase, _db.payeeRules);
}
