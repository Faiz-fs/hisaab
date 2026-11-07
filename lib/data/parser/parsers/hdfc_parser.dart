import '../bank_parser.dart';
import '../parsed_txn.dart';
import 'generic_parser.dart';

/// Hdfc SMS parser. Message layouts are handled by the shared
/// [GenericParser] pattern set (amount, account digits, reference, balance,
/// payee for each bank's UPI / card / NEFT formats).
class HdfcParser extends BankParser {
  const HdfcParser();

  static final _senderPattern = RegExp(r'HDFCBK', caseSensitive: false);

  @override
  bool matches(String sender) => _senderPattern.hasMatch(sender);

  @override
  ParsedTxn? parse(String body, DateTime at) =>
      const GenericParser().parse(body, at);
}
