import '../bank_parser.dart';
import '../parsed_txn.dart';
import 'generic_parser.dart';

/// Kotak SMS parser. Message layouts are handled by the shared
/// [GenericParser] pattern set (amount, account digits, reference, balance,
/// payee for each bank's UPI / card / NEFT formats).
class KotakParser extends BankParser {
  const KotakParser();

  static final _senderPattern = RegExp(r'KOTAK', caseSensitive: false);

  @override
  bool matches(String sender) => _senderPattern.hasMatch(sender);

  @override
  ParsedTxn? parse(String body, DateTime at) =>
      const GenericParser().parse(body, at);
}
