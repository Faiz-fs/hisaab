// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bankNameMeta = const VerificationMeta(
    'bankName',
  );
  @override
  late final GeneratedColumn<String> bankName = GeneratedColumn<String>(
    'bank_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _last4Meta = const VerificationMeta('last4');
  @override
  late final GeneratedColumn<String> last4 = GeneratedColumn<String>(
    'last4',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 4,
      maxTextLength: 4,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<int> balance = GeneratedColumn<int>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bankName,
    last4,
    balance,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Account> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('bank_name')) {
      context.handle(
        _bankNameMeta,
        bankName.isAcceptableOrUnknown(data['bank_name']!, _bankNameMeta),
      );
    } else if (isInserting) {
      context.missing(_bankNameMeta);
    }
    if (data.containsKey('last4')) {
      context.handle(
        _last4Meta,
        last4.isAcceptableOrUnknown(data['last4']!, _last4Meta),
      );
    } else if (isInserting) {
      context.missing(_last4Meta);
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bankName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_name'],
      )!,
      last4: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last4'],
      )!,
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final String id;
  final String bankName;
  final String last4;
  final int balance;
  final DateTime updatedAt;
  const Account({
    required this.id,
    required this.bankName,
    required this.last4,
    required this.balance,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['bank_name'] = Variable<String>(bankName);
    map['last4'] = Variable<String>(last4);
    map['balance'] = Variable<int>(balance);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      bankName: Value(bankName),
      last4: Value(last4),
      balance: Value(balance),
      updatedAt: Value(updatedAt),
    );
  }

  factory Account.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<String>(json['id']),
      bankName: serializer.fromJson<String>(json['bankName']),
      last4: serializer.fromJson<String>(json['last4']),
      balance: serializer.fromJson<int>(json['balance']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bankName': serializer.toJson<String>(bankName),
      'last4': serializer.toJson<String>(last4),
      'balance': serializer.toJson<int>(balance),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Account copyWith({
    String? id,
    String? bankName,
    String? last4,
    int? balance,
    DateTime? updatedAt,
  }) => Account(
    id: id ?? this.id,
    bankName: bankName ?? this.bankName,
    last4: last4 ?? this.last4,
    balance: balance ?? this.balance,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      bankName: data.bankName.present ? data.bankName.value : this.bankName,
      last4: data.last4.present ? data.last4.value : this.last4,
      balance: data.balance.present ? data.balance.value : this.balance,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('bankName: $bankName, ')
          ..write('last4: $last4, ')
          ..write('balance: $balance, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bankName, last4, balance, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.bankName == this.bankName &&
          other.last4 == this.last4 &&
          other.balance == this.balance &&
          other.updatedAt == this.updatedAt);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> id;
  final Value<String> bankName;
  final Value<String> last4;
  final Value<int> balance;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.bankName = const Value.absent(),
    this.last4 = const Value.absent(),
    this.balance = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String bankName,
    required String last4,
    this.balance = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bankName = Value(bankName),
       last4 = Value(last4),
       updatedAt = Value(updatedAt);
  static Insertable<Account> custom({
    Expression<String>? id,
    Expression<String>? bankName,
    Expression<String>? last4,
    Expression<int>? balance,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bankName != null) 'bank_name': bankName,
      if (last4 != null) 'last4': last4,
      if (balance != null) 'balance': balance,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? bankName,
    Value<String>? last4,
    Value<int>? balance,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      last4: last4 ?? this.last4,
      balance: balance ?? this.balance,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bankName.present) {
      map['bank_name'] = Variable<String>(bankName.value);
    }
    if (last4.present) {
      map['last4'] = Variable<String>(last4.value);
    }
    if (balance.present) {
      map['balance'] = Variable<int>(balance.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('bankName: $bankName, ')
          ..write('last4: $last4, ')
          ..write('balance: $balance, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TxnsTable extends Txns with TableInfo<$TxnsTable, Txn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TxnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payeeMeta = const VerificationMeta('payee');
  @override
  late final GeneratedColumn<String> payee = GeneratedColumn<String>(
    'payee',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refNoMeta = const VerificationMeta('refNo');
  @override
  late final GeneratedColumn<String> refNo = GeneratedColumn<String>(
    'ref_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _balanceAfterMeta = const VerificationMeta(
    'balanceAfter',
  );
  @override
  late final GeneratedColumn<int> balanceAfter = GeneratedColumn<int>(
    'balance_after',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    amount,
    direction,
    mode,
    payee,
    category,
    refNo,
    balanceAfter,
    at,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'txns';
  @override
  VerificationContext validateIntegrity(
    Insertable<Txn> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('payee')) {
      context.handle(
        _payeeMeta,
        payee.isAcceptableOrUnknown(data['payee']!, _payeeMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('ref_no')) {
      context.handle(
        _refNoMeta,
        refNo.isAcceptableOrUnknown(data['ref_no']!, _refNoMeta),
      );
    }
    if (data.containsKey('balance_after')) {
      context.handle(
        _balanceAfterMeta,
        balanceAfter.isAcceptableOrUnknown(
          data['balance_after']!,
          _balanceAfterMeta,
        ),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Txn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Txn(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      payee: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payee'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      refNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_no'],
      ),
      balanceAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance_after'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $TxnsTable createAlias(String alias) {
    return $TxnsTable(attachedDatabase, alias);
  }
}

class Txn extends DataClass implements Insertable<Txn> {
  final String id;
  final String accountId;
  final int amount;
  final String direction;
  final String mode;
  final String? payee;
  final String? category;
  final String? refNo;
  final int? balanceAfter;
  final DateTime at;
  const Txn({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.direction,
    required this.mode,
    this.payee,
    this.category,
    this.refNo,
    this.balanceAfter,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    map['amount'] = Variable<int>(amount);
    map['direction'] = Variable<String>(direction);
    map['mode'] = Variable<String>(mode);
    if (!nullToAbsent || payee != null) {
      map['payee'] = Variable<String>(payee);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || refNo != null) {
      map['ref_no'] = Variable<String>(refNo);
    }
    if (!nullToAbsent || balanceAfter != null) {
      map['balance_after'] = Variable<int>(balanceAfter);
    }
    map['at'] = Variable<DateTime>(at);
    return map;
  }

  TxnsCompanion toCompanion(bool nullToAbsent) {
    return TxnsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      amount: Value(amount),
      direction: Value(direction),
      mode: Value(mode),
      payee: payee == null && nullToAbsent
          ? const Value.absent()
          : Value(payee),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      refNo: refNo == null && nullToAbsent
          ? const Value.absent()
          : Value(refNo),
      balanceAfter: balanceAfter == null && nullToAbsent
          ? const Value.absent()
          : Value(balanceAfter),
      at: Value(at),
    );
  }

  factory Txn.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Txn(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      amount: serializer.fromJson<int>(json['amount']),
      direction: serializer.fromJson<String>(json['direction']),
      mode: serializer.fromJson<String>(json['mode']),
      payee: serializer.fromJson<String?>(json['payee']),
      category: serializer.fromJson<String?>(json['category']),
      refNo: serializer.fromJson<String?>(json['refNo']),
      balanceAfter: serializer.fromJson<int?>(json['balanceAfter']),
      at: serializer.fromJson<DateTime>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'amount': serializer.toJson<int>(amount),
      'direction': serializer.toJson<String>(direction),
      'mode': serializer.toJson<String>(mode),
      'payee': serializer.toJson<String?>(payee),
      'category': serializer.toJson<String?>(category),
      'refNo': serializer.toJson<String?>(refNo),
      'balanceAfter': serializer.toJson<int?>(balanceAfter),
      'at': serializer.toJson<DateTime>(at),
    };
  }

  Txn copyWith({
    String? id,
    String? accountId,
    int? amount,
    String? direction,
    String? mode,
    Value<String?> payee = const Value.absent(),
    Value<String?> category = const Value.absent(),
    Value<String?> refNo = const Value.absent(),
    Value<int?> balanceAfter = const Value.absent(),
    DateTime? at,
  }) => Txn(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    amount: amount ?? this.amount,
    direction: direction ?? this.direction,
    mode: mode ?? this.mode,
    payee: payee.present ? payee.value : this.payee,
    category: category.present ? category.value : this.category,
    refNo: refNo.present ? refNo.value : this.refNo,
    balanceAfter: balanceAfter.present ? balanceAfter.value : this.balanceAfter,
    at: at ?? this.at,
  );
  Txn copyWithCompanion(TxnsCompanion data) {
    return Txn(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      amount: data.amount.present ? data.amount.value : this.amount,
      direction: data.direction.present ? data.direction.value : this.direction,
      mode: data.mode.present ? data.mode.value : this.mode,
      payee: data.payee.present ? data.payee.value : this.payee,
      category: data.category.present ? data.category.value : this.category,
      refNo: data.refNo.present ? data.refNo.value : this.refNo,
      balanceAfter: data.balanceAfter.present
          ? data.balanceAfter.value
          : this.balanceAfter,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Txn(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('amount: $amount, ')
          ..write('direction: $direction, ')
          ..write('mode: $mode, ')
          ..write('payee: $payee, ')
          ..write('category: $category, ')
          ..write('refNo: $refNo, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    amount,
    direction,
    mode,
    payee,
    category,
    refNo,
    balanceAfter,
    at,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Txn &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.amount == this.amount &&
          other.direction == this.direction &&
          other.mode == this.mode &&
          other.payee == this.payee &&
          other.category == this.category &&
          other.refNo == this.refNo &&
          other.balanceAfter == this.balanceAfter &&
          other.at == this.at);
}

class TxnsCompanion extends UpdateCompanion<Txn> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<int> amount;
  final Value<String> direction;
  final Value<String> mode;
  final Value<String?> payee;
  final Value<String?> category;
  final Value<String?> refNo;
  final Value<int?> balanceAfter;
  final Value<DateTime> at;
  final Value<int> rowid;
  const TxnsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.amount = const Value.absent(),
    this.direction = const Value.absent(),
    this.mode = const Value.absent(),
    this.payee = const Value.absent(),
    this.category = const Value.absent(),
    this.refNo = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    this.at = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TxnsCompanion.insert({
    required String id,
    required String accountId,
    required int amount,
    required String direction,
    required String mode,
    this.payee = const Value.absent(),
    this.category = const Value.absent(),
    this.refNo = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    required DateTime at,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountId = Value(accountId),
       amount = Value(amount),
       direction = Value(direction),
       mode = Value(mode),
       at = Value(at);
  static Insertable<Txn> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<int>? amount,
    Expression<String>? direction,
    Expression<String>? mode,
    Expression<String>? payee,
    Expression<String>? category,
    Expression<String>? refNo,
    Expression<int>? balanceAfter,
    Expression<DateTime>? at,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (amount != null) 'amount': amount,
      if (direction != null) 'direction': direction,
      if (mode != null) 'mode': mode,
      if (payee != null) 'payee': payee,
      if (category != null) 'category': category,
      if (refNo != null) 'ref_no': refNo,
      if (balanceAfter != null) 'balance_after': balanceAfter,
      if (at != null) 'at': at,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TxnsCompanion copyWith({
    Value<String>? id,
    Value<String>? accountId,
    Value<int>? amount,
    Value<String>? direction,
    Value<String>? mode,
    Value<String?>? payee,
    Value<String?>? category,
    Value<String?>? refNo,
    Value<int?>? balanceAfter,
    Value<DateTime>? at,
    Value<int>? rowid,
  }) {
    return TxnsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      amount: amount ?? this.amount,
      direction: direction ?? this.direction,
      mode: mode ?? this.mode,
      payee: payee ?? this.payee,
      category: category ?? this.category,
      refNo: refNo ?? this.refNo,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      at: at ?? this.at,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (payee.present) {
      map['payee'] = Variable<String>(payee.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (refNo.present) {
      map['ref_no'] = Variable<String>(refNo.value);
    }
    if (balanceAfter.present) {
      map['balance_after'] = Variable<int>(balanceAfter.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TxnsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('amount: $amount, ')
          ..write('direction: $direction, ')
          ..write('mode: $mode, ')
          ..write('payee: $payee, ')
          ..write('category: $category, ')
          ..write('refNo: $refNo, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('at: $at, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PayeeRulesTable extends PayeeRules
    with TableInfo<$PayeeRulesTable, PayeeRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PayeeRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _patternMeta = const VerificationMeta(
    'pattern',
  );
  @override
  late final GeneratedColumn<String> pattern = GeneratedColumn<String>(
    'pattern',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isRegexMeta = const VerificationMeta(
    'isRegex',
  );
  @override
  late final GeneratedColumn<bool> isRegex = GeneratedColumn<bool>(
    'is_regex',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_regex" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, pattern, category, isRegex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payee_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<PayeeRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pattern')) {
      context.handle(
        _patternMeta,
        pattern.isAcceptableOrUnknown(data['pattern']!, _patternMeta),
      );
    } else if (isInserting) {
      context.missing(_patternMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('is_regex')) {
      context.handle(
        _isRegexMeta,
        isRegex.isAcceptableOrUnknown(data['is_regex']!, _isRegexMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PayeeRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PayeeRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pattern'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      isRegex: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_regex'],
      )!,
    );
  }

  @override
  $PayeeRulesTable createAlias(String alias) {
    return $PayeeRulesTable(attachedDatabase, alias);
  }
}

class PayeeRule extends DataClass implements Insertable<PayeeRule> {
  final int id;
  final String pattern;
  final String category;
  final bool isRegex;
  const PayeeRule({
    required this.id,
    required this.pattern,
    required this.category,
    required this.isRegex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pattern'] = Variable<String>(pattern);
    map['category'] = Variable<String>(category);
    map['is_regex'] = Variable<bool>(isRegex);
    return map;
  }

  PayeeRulesCompanion toCompanion(bool nullToAbsent) {
    return PayeeRulesCompanion(
      id: Value(id),
      pattern: Value(pattern),
      category: Value(category),
      isRegex: Value(isRegex),
    );
  }

  factory PayeeRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PayeeRule(
      id: serializer.fromJson<int>(json['id']),
      pattern: serializer.fromJson<String>(json['pattern']),
      category: serializer.fromJson<String>(json['category']),
      isRegex: serializer.fromJson<bool>(json['isRegex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pattern': serializer.toJson<String>(pattern),
      'category': serializer.toJson<String>(category),
      'isRegex': serializer.toJson<bool>(isRegex),
    };
  }

  PayeeRule copyWith({
    int? id,
    String? pattern,
    String? category,
    bool? isRegex,
  }) => PayeeRule(
    id: id ?? this.id,
    pattern: pattern ?? this.pattern,
    category: category ?? this.category,
    isRegex: isRegex ?? this.isRegex,
  );
  PayeeRule copyWithCompanion(PayeeRulesCompanion data) {
    return PayeeRule(
      id: data.id.present ? data.id.value : this.id,
      pattern: data.pattern.present ? data.pattern.value : this.pattern,
      category: data.category.present ? data.category.value : this.category,
      isRegex: data.isRegex.present ? data.isRegex.value : this.isRegex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PayeeRule(')
          ..write('id: $id, ')
          ..write('pattern: $pattern, ')
          ..write('category: $category, ')
          ..write('isRegex: $isRegex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, pattern, category, isRegex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PayeeRule &&
          other.id == this.id &&
          other.pattern == this.pattern &&
          other.category == this.category &&
          other.isRegex == this.isRegex);
}

class PayeeRulesCompanion extends UpdateCompanion<PayeeRule> {
  final Value<int> id;
  final Value<String> pattern;
  final Value<String> category;
  final Value<bool> isRegex;
  const PayeeRulesCompanion({
    this.id = const Value.absent(),
    this.pattern = const Value.absent(),
    this.category = const Value.absent(),
    this.isRegex = const Value.absent(),
  });
  PayeeRulesCompanion.insert({
    this.id = const Value.absent(),
    required String pattern,
    required String category,
    this.isRegex = const Value.absent(),
  }) : pattern = Value(pattern),
       category = Value(category);
  static Insertable<PayeeRule> custom({
    Expression<int>? id,
    Expression<String>? pattern,
    Expression<String>? category,
    Expression<bool>? isRegex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pattern != null) 'pattern': pattern,
      if (category != null) 'category': category,
      if (isRegex != null) 'is_regex': isRegex,
    });
  }

  PayeeRulesCompanion copyWith({
    Value<int>? id,
    Value<String>? pattern,
    Value<String>? category,
    Value<bool>? isRegex,
  }) {
    return PayeeRulesCompanion(
      id: id ?? this.id,
      pattern: pattern ?? this.pattern,
      category: category ?? this.category,
      isRegex: isRegex ?? this.isRegex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pattern.present) {
      map['pattern'] = Variable<String>(pattern.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (isRegex.present) {
      map['is_regex'] = Variable<bool>(isRegex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PayeeRulesCompanion(')
          ..write('id: $id, ')
          ..write('pattern: $pattern, ')
          ..write('category: $category, ')
          ..write('isRegex: $isRegex')
          ..write(')'))
        .toString();
  }
}

class $DailyVerdictsTable extends DailyVerdicts
    with TableInfo<$DailyVerdictsTable, DailyVerdict> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyVerdictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalSpentMeta = const VerificationMeta(
    'totalSpent',
  );
  @override
  late final GeneratedColumn<int> totalSpent = GeneratedColumn<int>(
    'total_spent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topCulpritsMeta = const VerificationMeta(
    'topCulprits',
  );
  @override
  late final GeneratedColumn<String> topCulprits = GeneratedColumn<String>(
    'top_culprits',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verdictJsonMeta = const VerificationMeta(
    'verdictJson',
  );
  @override
  late final GeneratedColumn<String> verdictJson = GeneratedColumn<String>(
    'verdict_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    rating,
    totalSpent,
    topCulprits,
    verdictJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_verdicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyVerdict> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('total_spent')) {
      context.handle(
        _totalSpentMeta,
        totalSpent.isAcceptableOrUnknown(data['total_spent']!, _totalSpentMeta),
      );
    } else if (isInserting) {
      context.missing(_totalSpentMeta);
    }
    if (data.containsKey('top_culprits')) {
      context.handle(
        _topCulpritsMeta,
        topCulprits.isAcceptableOrUnknown(
          data['top_culprits']!,
          _topCulpritsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_topCulpritsMeta);
    }
    if (data.containsKey('verdict_json')) {
      context.handle(
        _verdictJsonMeta,
        verdictJson.isAcceptableOrUnknown(
          data['verdict_json']!,
          _verdictJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_verdictJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyVerdict map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyVerdict(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      )!,
      totalSpent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_spent'],
      )!,
      topCulprits: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}top_culprits'],
      )!,
      verdictJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verdict_json'],
      )!,
    );
  }

  @override
  $DailyVerdictsTable createAlias(String alias) {
    return $DailyVerdictsTable(attachedDatabase, alias);
  }
}

class DailyVerdict extends DataClass implements Insertable<DailyVerdict> {
  final int id;
  final DateTime date;
  final int rating;
  final int totalSpent;
  final String topCulprits;
  final String verdictJson;
  const DailyVerdict({
    required this.id,
    required this.date,
    required this.rating,
    required this.totalSpent,
    required this.topCulprits,
    required this.verdictJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['rating'] = Variable<int>(rating);
    map['total_spent'] = Variable<int>(totalSpent);
    map['top_culprits'] = Variable<String>(topCulprits);
    map['verdict_json'] = Variable<String>(verdictJson);
    return map;
  }

  DailyVerdictsCompanion toCompanion(bool nullToAbsent) {
    return DailyVerdictsCompanion(
      id: Value(id),
      date: Value(date),
      rating: Value(rating),
      totalSpent: Value(totalSpent),
      topCulprits: Value(topCulprits),
      verdictJson: Value(verdictJson),
    );
  }

  factory DailyVerdict.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyVerdict(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      rating: serializer.fromJson<int>(json['rating']),
      totalSpent: serializer.fromJson<int>(json['totalSpent']),
      topCulprits: serializer.fromJson<String>(json['topCulprits']),
      verdictJson: serializer.fromJson<String>(json['verdictJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'rating': serializer.toJson<int>(rating),
      'totalSpent': serializer.toJson<int>(totalSpent),
      'topCulprits': serializer.toJson<String>(topCulprits),
      'verdictJson': serializer.toJson<String>(verdictJson),
    };
  }

  DailyVerdict copyWith({
    int? id,
    DateTime? date,
    int? rating,
    int? totalSpent,
    String? topCulprits,
    String? verdictJson,
  }) => DailyVerdict(
    id: id ?? this.id,
    date: date ?? this.date,
    rating: rating ?? this.rating,
    totalSpent: totalSpent ?? this.totalSpent,
    topCulprits: topCulprits ?? this.topCulprits,
    verdictJson: verdictJson ?? this.verdictJson,
  );
  DailyVerdict copyWithCompanion(DailyVerdictsCompanion data) {
    return DailyVerdict(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      rating: data.rating.present ? data.rating.value : this.rating,
      totalSpent: data.totalSpent.present
          ? data.totalSpent.value
          : this.totalSpent,
      topCulprits: data.topCulprits.present
          ? data.topCulprits.value
          : this.topCulprits,
      verdictJson: data.verdictJson.present
          ? data.verdictJson.value
          : this.verdictJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyVerdict(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('rating: $rating, ')
          ..write('totalSpent: $totalSpent, ')
          ..write('topCulprits: $topCulprits, ')
          ..write('verdictJson: $verdictJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, rating, totalSpent, topCulprits, verdictJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyVerdict &&
          other.id == this.id &&
          other.date == this.date &&
          other.rating == this.rating &&
          other.totalSpent == this.totalSpent &&
          other.topCulprits == this.topCulprits &&
          other.verdictJson == this.verdictJson);
}

class DailyVerdictsCompanion extends UpdateCompanion<DailyVerdict> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> rating;
  final Value<int> totalSpent;
  final Value<String> topCulprits;
  final Value<String> verdictJson;
  const DailyVerdictsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.rating = const Value.absent(),
    this.totalSpent = const Value.absent(),
    this.topCulprits = const Value.absent(),
    this.verdictJson = const Value.absent(),
  });
  DailyVerdictsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required int rating,
    required int totalSpent,
    required String topCulprits,
    required String verdictJson,
  }) : date = Value(date),
       rating = Value(rating),
       totalSpent = Value(totalSpent),
       topCulprits = Value(topCulprits),
       verdictJson = Value(verdictJson);
  static Insertable<DailyVerdict> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? rating,
    Expression<int>? totalSpent,
    Expression<String>? topCulprits,
    Expression<String>? verdictJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (rating != null) 'rating': rating,
      if (totalSpent != null) 'total_spent': totalSpent,
      if (topCulprits != null) 'top_culprits': topCulprits,
      if (verdictJson != null) 'verdict_json': verdictJson,
    });
  }

  DailyVerdictsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<int>? rating,
    Value<int>? totalSpent,
    Value<String>? topCulprits,
    Value<String>? verdictJson,
  }) {
    return DailyVerdictsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      rating: rating ?? this.rating,
      totalSpent: totalSpent ?? this.totalSpent,
      topCulprits: topCulprits ?? this.topCulprits,
      verdictJson: verdictJson ?? this.verdictJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (totalSpent.present) {
      map['total_spent'] = Variable<int>(totalSpent.value);
    }
    if (topCulprits.present) {
      map['top_culprits'] = Variable<String>(topCulprits.value);
    }
    if (verdictJson.present) {
      map['verdict_json'] = Variable<String>(verdictJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyVerdictsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('rating: $rating, ')
          ..write('totalSpent: $totalSpent, ')
          ..write('topCulprits: $topCulprits, ')
          ..write('verdictJson: $verdictJson')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $TxnsTable txns = $TxnsTable(this);
  late final $PayeeRulesTable payeeRules = $PayeeRulesTable(this);
  late final $DailyVerdictsTable dailyVerdicts = $DailyVerdictsTable(this);
  late final AccountsDao accountsDao = AccountsDao(this as AppDatabase);
  late final TxnsDao txnsDao = TxnsDao(this as AppDatabase);
  late final PayeeRulesDao payeeRulesDao = PayeeRulesDao(this as AppDatabase);
  late final VerdictsDao verdictsDao = VerdictsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    txns,
    payeeRules,
    dailyVerdicts,
  ];
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  required String id,
  required String bankName,
  required String last4,
  Value<int> balance,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> id,
  Value<String> bankName,
  Value<String> last4,
  Value<int> balance,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankName => $composableBuilder(
    column: $table.bankName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get last4 => $composableBuilder(
    column: $table.last4,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankName => $composableBuilder(
    column: $table.bankName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get last4 => $composableBuilder(
    column: $table.last4,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bankName =>
      $composableBuilder(column: $table.bankName, builder: (column) => column);

  GeneratedColumn<String> get last4 =>
      $composableBuilder(column: $table.last4, builder: (column) => column);

  GeneratedColumn<int> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          Account,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
          Account,
          PrefetchHooks Function()
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bankName = const Value.absent(),
                Value<String> last4 = const Value.absent(),
                Value<int> balance = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                bankName: bankName,
                last4: last4,
                balance: balance,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bankName,
                required String last4,
                Value<int> balance = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                bankName: bankName,
                last4: last4,
                balance: balance,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountsTable, Account>(table),
                  BaseReferences<_$AppDatabase, $AccountsTable, Account>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      Account,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
      Account,
      PrefetchHooks Function()
    >;
typedef $$TxnsTableCreateCompanionBuilder = TxnsCompanion Function({
  required String id,
  required String accountId,
  required int amount,
  required String direction,
  required String mode,
  Value<String?> payee,
  Value<String?> category,
  Value<String?> refNo,
  Value<int?> balanceAfter,
  required DateTime at,
  Value<int> rowid,
});
typedef $$TxnsTableUpdateCompanionBuilder = TxnsCompanion Function({
  Value<String> id,
  Value<String> accountId,
  Value<int> amount,
  Value<String> direction,
  Value<String> mode,
  Value<String?> payee,
  Value<String?> category,
  Value<String?> refNo,
  Value<int?> balanceAfter,
  Value<DateTime> at,
  Value<int> rowid,
});

class $$TxnsTableFilterComposer extends Composer<_$AppDatabase, $TxnsTable> {
  $$TxnsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payee => $composableBuilder(
    column: $table.payee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refNo => $composableBuilder(
    column: $table.refNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TxnsTableOrderingComposer extends Composer<_$AppDatabase, $TxnsTable> {
  $$TxnsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payee => $composableBuilder(
    column: $table.payee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refNo => $composableBuilder(
    column: $table.refNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TxnsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TxnsTable> {
  $$TxnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get payee =>
      $composableBuilder(column: $table.payee, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get refNo =>
      $composableBuilder(column: $table.refNo, builder: (column) => column);

  GeneratedColumn<int> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $$TxnsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TxnsTable,
          Txn,
          $$TxnsTableFilterComposer,
          $$TxnsTableOrderingComposer,
          $$TxnsTableAnnotationComposer,
          $$TxnsTableCreateCompanionBuilder,
          $$TxnsTableUpdateCompanionBuilder,
          (Txn, BaseReferences<_$AppDatabase, $TxnsTable, Txn>),
          Txn,
          PrefetchHooks Function()
        > {
  $$TxnsTableTableManager(_$AppDatabase db, $TxnsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TxnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TxnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TxnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String?> payee = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> refNo = const Value.absent(),
                Value<int?> balanceAfter = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TxnsCompanion(
                id: id,
                accountId: accountId,
                amount: amount,
                direction: direction,
                mode: mode,
                payee: payee,
                category: category,
                refNo: refNo,
                balanceAfter: balanceAfter,
                at: at,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String accountId,
                required int amount,
                required String direction,
                required String mode,
                Value<String?> payee = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> refNo = const Value.absent(),
                Value<int?> balanceAfter = const Value.absent(),
                required DateTime at,
                Value<int> rowid = const Value.absent(),
              }) => TxnsCompanion.insert(
                id: id,
                accountId: accountId,
                amount: amount,
                direction: direction,
                mode: mode,
                payee: payee,
                category: category,
                refNo: refNo,
                balanceAfter: balanceAfter,
                at: at,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TxnsTable, Txn>(table),
                  BaseReferences<_$AppDatabase, $TxnsTable, Txn>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TxnsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TxnsTable,
      Txn,
      $$TxnsTableFilterComposer,
      $$TxnsTableOrderingComposer,
      $$TxnsTableAnnotationComposer,
      $$TxnsTableCreateCompanionBuilder,
      $$TxnsTableUpdateCompanionBuilder,
      (Txn, BaseReferences<_$AppDatabase, $TxnsTable, Txn>),
      Txn,
      PrefetchHooks Function()
    >;
typedef $$PayeeRulesTableCreateCompanionBuilder = PayeeRulesCompanion Function({
  Value<int> id,
  required String pattern,
  required String category,
  Value<bool> isRegex,
});
typedef $$PayeeRulesTableUpdateCompanionBuilder = PayeeRulesCompanion Function({
  Value<int> id,
  Value<String> pattern,
  Value<String> category,
  Value<bool> isRegex,
});

class $$PayeeRulesTableFilterComposer
    extends Composer<_$AppDatabase, $PayeeRulesTable> {
  $$PayeeRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRegex => $composableBuilder(
    column: $table.isRegex,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PayeeRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $PayeeRulesTable> {
  $$PayeeRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRegex => $composableBuilder(
    column: $table.isRegex,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PayeeRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PayeeRulesTable> {
  $$PayeeRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pattern =>
      $composableBuilder(column: $table.pattern, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get isRegex =>
      $composableBuilder(column: $table.isRegex, builder: (column) => column);
}

class $$PayeeRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PayeeRulesTable,
          PayeeRule,
          $$PayeeRulesTableFilterComposer,
          $$PayeeRulesTableOrderingComposer,
          $$PayeeRulesTableAnnotationComposer,
          $$PayeeRulesTableCreateCompanionBuilder,
          $$PayeeRulesTableUpdateCompanionBuilder,
          (
            PayeeRule,
            BaseReferences<_$AppDatabase, $PayeeRulesTable, PayeeRule>,
          ),
          PayeeRule,
          PrefetchHooks Function()
        > {
  $$PayeeRulesTableTableManager(_$AppDatabase db, $PayeeRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PayeeRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PayeeRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PayeeRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> pattern = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<bool> isRegex = const Value.absent(),
              }) => PayeeRulesCompanion(
                id: id,
                pattern: pattern,
                category: category,
                isRegex: isRegex,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String pattern,
                required String category,
                Value<bool> isRegex = const Value.absent(),
              }) => PayeeRulesCompanion.insert(
                id: id,
                pattern: pattern,
                category: category,
                isRegex: isRegex,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PayeeRulesTable, PayeeRule>(table),
                  BaseReferences<_$AppDatabase, $PayeeRulesTable, PayeeRule>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PayeeRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PayeeRulesTable,
      PayeeRule,
      $$PayeeRulesTableFilterComposer,
      $$PayeeRulesTableOrderingComposer,
      $$PayeeRulesTableAnnotationComposer,
      $$PayeeRulesTableCreateCompanionBuilder,
      $$PayeeRulesTableUpdateCompanionBuilder,
      (PayeeRule, BaseReferences<_$AppDatabase, $PayeeRulesTable, PayeeRule>),
      PayeeRule,
      PrefetchHooks Function()
    >;
typedef $$DailyVerdictsTableCreateCompanionBuilder =
    DailyVerdictsCompanion Function({
      Value<int> id,
      required DateTime date,
      required int rating,
      required int totalSpent,
      required String topCulprits,
      required String verdictJson,
    });
typedef $$DailyVerdictsTableUpdateCompanionBuilder =
    DailyVerdictsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<int> rating,
      Value<int> totalSpent,
      Value<String> topCulprits,
      Value<String> verdictJson,
    });

class $$DailyVerdictsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyVerdictsTable> {
  $$DailyVerdictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalSpent => $composableBuilder(
    column: $table.totalSpent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topCulprits => $composableBuilder(
    column: $table.topCulprits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verdictJson => $composableBuilder(
    column: $table.verdictJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyVerdictsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyVerdictsTable> {
  $$DailyVerdictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalSpent => $composableBuilder(
    column: $table.totalSpent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topCulprits => $composableBuilder(
    column: $table.topCulprits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verdictJson => $composableBuilder(
    column: $table.verdictJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyVerdictsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyVerdictsTable> {
  $$DailyVerdictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<int> get totalSpent => $composableBuilder(
    column: $table.totalSpent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get topCulprits => $composableBuilder(
    column: $table.topCulprits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get verdictJson => $composableBuilder(
    column: $table.verdictJson,
    builder: (column) => column,
  );
}

class $$DailyVerdictsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyVerdictsTable,
          DailyVerdict,
          $$DailyVerdictsTableFilterComposer,
          $$DailyVerdictsTableOrderingComposer,
          $$DailyVerdictsTableAnnotationComposer,
          $$DailyVerdictsTableCreateCompanionBuilder,
          $$DailyVerdictsTableUpdateCompanionBuilder,
          (
            DailyVerdict,
            BaseReferences<_$AppDatabase, $DailyVerdictsTable, DailyVerdict>,
          ),
          DailyVerdict,
          PrefetchHooks Function()
        > {
  $$DailyVerdictsTableTableManager(_$AppDatabase db, $DailyVerdictsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyVerdictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyVerdictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyVerdictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<int> totalSpent = const Value.absent(),
                Value<String> topCulprits = const Value.absent(),
                Value<String> verdictJson = const Value.absent(),
              }) => DailyVerdictsCompanion(
                id: id,
                date: date,
                rating: rating,
                totalSpent: totalSpent,
                topCulprits: topCulprits,
                verdictJson: verdictJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required int rating,
                required int totalSpent,
                required String topCulprits,
                required String verdictJson,
              }) => DailyVerdictsCompanion.insert(
                id: id,
                date: date,
                rating: rating,
                totalSpent: totalSpent,
                topCulprits: topCulprits,
                verdictJson: verdictJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DailyVerdictsTable, DailyVerdict>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DailyVerdictsTable,
                    DailyVerdict
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyVerdictsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyVerdictsTable,
      DailyVerdict,
      $$DailyVerdictsTableFilterComposer,
      $$DailyVerdictsTableOrderingComposer,
      $$DailyVerdictsTableAnnotationComposer,
      $$DailyVerdictsTableCreateCompanionBuilder,
      $$DailyVerdictsTableUpdateCompanionBuilder,
      (
        DailyVerdict,
        BaseReferences<_$AppDatabase, $DailyVerdictsTable, DailyVerdict>,
      ),
      DailyVerdict,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$TxnsTableTableManager get txns => $$TxnsTableTableManager(_db, _db.txns);
  $$PayeeRulesTableTableManager get payeeRules =>
      $$PayeeRulesTableTableManager(_db, _db.payeeRules);
  $$DailyVerdictsTableTableManager get dailyVerdicts =>
      $$DailyVerdictsTableTableManager(_db, _db.dailyVerdicts);
}
