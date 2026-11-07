import 'parsed_txn.dart';

/// Abstract contract for all bank SMS parsers.
///
/// Implementations should be stateless and registered in [ParserRegistry].
abstract class BankParser {
  const BankParser();

  /// Returns true if this parser can handle the given SMS [sender] address.
  bool matches(String sender);

  /// Parses [body] and returns a [ParsedTxn] if the message is a recognised
  /// transaction, or null if the message should be ignored.
  ///
  /// [body] – raw SMS message text (NEVER stored after this call).
  /// [at]   – timestamp of the SMS.
  ParsedTxn? parse(String body, DateTime at);
}
