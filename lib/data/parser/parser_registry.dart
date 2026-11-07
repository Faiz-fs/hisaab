import 'bank_parser.dart';
import 'parsed_txn.dart';
import 'parsers/hdfc_parser.dart';
import 'parsers/sbi_parser.dart';
import 'parsers/icici_parser.dart';
import 'parsers/axis_parser.dart';
import 'parsers/kotak_parser.dart';
import 'parsers/generic_parser.dart';

/// Registry of all [BankParser] implementations.
/// Bank-specific parser runs first; [GenericParser] is used whenever the
/// specific parser returns null (e.g. stubs) or cannot find the account digits.
class ParserRegistry {
  ParserRegistry._();

  static const _generic = GenericParser();

  static final List<BankParser> _parsers = [
    const HdfcParser(),
    const SbiParser(),
    const IciciParser(),
    const AxisParser(),
    const KotakParser(),
  ];

  static ParsedTxn? parse(String sender, String body, DateTime at) {
    ParsedTxn? specific;
    for (final parser in _parsers) {
      if (parser.matches(sender)) {
        try {
          specific = parser.parse(body, at);
        } catch (_) {
          specific = null;
        }
        break;
      }
    }
    final fallback = _generic.parse(body, at);
    if (specific == null) return fallback;
    if (fallback == null) return specific;
    // Merge: keep specific values, fill gaps from the generic parser.
    return ParsedTxn(
      amountPaise: specific.amountPaise,
      direction: specific.direction,
      mode: specific.mode,
      payee: specific.payee ?? fallback.payee,
      refNo: specific.refNo ?? fallback.refNo,
      last4: specific.last4 ?? fallback.last4,
      balanceAfterPaise: specific.balanceAfterPaise ?? fallback.balanceAfterPaise,
      at: at,
    );
  }
}
