// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'txns_dao.dart';

// ignore_for_file: type=lint
mixin _$TxnsDaoMixin on DatabaseAccessor<AppDatabase> {
  $TxnsTable get txns => attachedDatabase.txns;
  TxnsDaoManager get managers => TxnsDaoManager(this);
}

class TxnsDaoManager {
  final _$TxnsDaoMixin _db;
  TxnsDaoManager(this._db);
  $$TxnsTableTableManager get txns =>
      $$TxnsTableTableManager(_db.attachedDatabase, _db.txns);
}
