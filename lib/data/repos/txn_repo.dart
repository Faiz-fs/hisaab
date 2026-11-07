import 'package:drift/drift.dart' as drift;

import '../../domain/models/enums.dart';
import '../../domain/models/txn.dart';
import '../db/app_database.dart';

/// Repository interface for transaction persistence.
abstract class TxnRepo {
  Future<void> insert(TxnModel txn);
  Future<List<TxnModel>> getForDay(DateTime day);
  Future<int> totalDebitForDay(DateTime day);
}

/// SQLite-backed [TxnRepo].
class DriftTxnRepo implements TxnRepo {
  final AppDatabase db;
  DriftTxnRepo(this.db);

  static TxnModel toModel(Txn r) => TxnModel(
        id: r.id,
        accountId: r.accountId,
        amountPaise: r.amount,
        direction: r.direction == 'credit' ? Direction.credit : Direction.debit,
        mode: PayMode.values.asNameMap()[r.mode] ?? PayMode.other,
        payee: r.payee,
        category: r.category,
        refNo: r.refNo,
        balanceAfterPaise: r.balanceAfter,
        at: r.at,
      );

  @override
  Future<void> insert(TxnModel t) => db.txnsDao.insertTxn(TxnsCompanion.insert(
        id: t.id,
        accountId: t.accountId,
        amount: t.amountPaise,
        direction: t.direction.name,
        mode: t.mode.name,
        payee: drift.Value(t.payee),
        category: drift.Value(t.category),
        refNo: drift.Value(t.refNo),
        balanceAfter: drift.Value(t.balanceAfterPaise),
        at: t.at,
      ));

  @override
  Future<List<TxnModel>> getForDay(DateTime day) async =>
      (await db.txnsDao.getTxnsForDay(day)).map(toModel).toList();

  @override
  Future<int> totalDebitForDay(DateTime day) => db.txnsDao.totalDebitForDay(day);
}
