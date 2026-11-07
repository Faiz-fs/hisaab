import '../bank_parser.dart';
import '../parsed_txn.dart';
import 'generic_parser.dart';

/// Icici SMS parser. Message layouts are handled by the shared
/// [GenericParser] pattern set (amount, account digits, reference, balance,
/// payee for each bank's UPI / card / NEFT formats).
class IciciParser extends BankParser {
  const IciciParser();

  static final _senderPattern = RegExp(r'ICICI', caseSensitive: false);

  @override
  bool matches(String sender) => _senderPattern.hasMatch(sender);

  @override
  ParsedTxn? parse(String body, DateTime at) =>
      const GenericParser().parse(body, at);
}
