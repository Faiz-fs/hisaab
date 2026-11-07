import 'package:flutter_test/flutter_test.dart';

import 'package:hisaab/data/parser/parsers/hdfc_parser.dart';
import 'package:hisaab/domain/models/enums.dart';

void main() {
  const parser = HdfcParser();
  final now = DateTime(2026, 11, 1, 14, 30);

  group('HdfcParser.matches', () {
    test('matches HDFCBK sender', () {
      expect(parser.matches('HDFCBK'), isTrue);
    });

    test('matches VK-HDFCBK sender', () {
      expect(parser.matches('VK-HDFCBK'), isTrue);
    });

    test('does not match SBI sender', () {
      expect(parser.matches('SBIINB'), isFalse);
    });
  });

  group('HdfcParser.parse – debit via UPI', () {
    const sms =
        'Your a/c XX4321 has been debited for Rs.500.00 on 01-11-26. '
        'UPI:Swiggy Order. Avl Bal:Rs.14,230.50. -HDFC Bank';

    test('returns non-null ParsedTxn', () {
      final txn = parser.parse(sms, now);
      expect(txn, isNotNull);
    });

    test('amount is 50000 paise', () {
      final txn = parser.parse(sms, now)!;
      expect(txn.amountPaise, equals(50000));
    });

    test('direction is debit', () {
      final txn = parser.parse(sms, now)!;
      expect(txn.direction, equals(Direction.debit));
    });

    test('mode is UPI', () {
      final txn = parser.parse(sms, now)!;
      expect(txn.mode, equals(PayMode.upi));
    });

    test('last4 is 4321', () {
      final txn = parser.parse(sms, now)!;
      expect(txn.last4, equals('4321'));
    });

    test('balanceAfter is 1423050 paise', () {
      final txn = parser.parse(sms, now)!;
      expect(txn.balanceAfterPaise, equals(1423050));
    });
  });
}
