import '../bank_parser.dart';
import '../parsed_txn.dart';
import 'generic_parser.dart';

/// Sbi SMS parser. Message layouts are handled by the shared
/// [GenericParser] pattern set (amount, account digits, reference, balance,
/// payee for each bank's UPI / card / NEFT formats).
class SbiParser extends BankParser {
  const SbiParser();

  static final _senderPattern = RegExp(r'SBI', caseSensitive: false);

  @override
  bool matches(String sender) => _senderPattern.hasMatch(sender);

  @override
  ParsedTxn? parse(String body, DateTime at) =>
      const GenericParser().parse(body, at);
}
