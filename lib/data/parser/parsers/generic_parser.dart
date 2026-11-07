import '../bank_parser.dart';
import '../parsed_txn.dart';
import '../../../domain/models/enums.dart';

/// Robust fallback parser for Indian bank SMS alerts.
///
/// Handles formats such as:
///   "Rs.500.00 debited from A/c XX1234 on 03-11-26 ... Avl Bal Rs 1,000"
///   "Sent Rs.500 From HDFC Bank A/c *1234 To NAME On 03/11/26 Ref 123"
///   "A/c no. XXXXXXXX1234 credited by Rs 500 ..."
///   "ICICI Bank Acct XX123 debited for Rs 500 ...; NAME credited. UPI:123"
///
/// Always [matches] any sender — must be last in [ParserRegistry].
class GenericParser extends BankParser {
  const GenericParser();

  static final _amountRe = RegExp(
    r'(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d+)?)',
    caseSensitive: false,
  );
  // "Rs" is optional after "Bal" ("Avl Bal: 1,234.00", "Avl Bal Rs.1,234")
  // SBI style: "debited by 500.0" / "credited by 1,200.50" (no Rs prefix).
  static final _amountByRe = RegExp(
    r'(?:debited|credited)\s+(?:by|with|for)\s+([\d,]+(?:\.\d+)?)',
    caseSensitive: false,
  );
  static final _balRe = RegExp(
    r'(?:Avl\.?|Available|Total)?\s*Bal(?:ance)?(?:\s*is)?[\s:.\-]*(?:Rs\.?|INR|₹)?\s*([\d,]+(?:\.\d+)?)',
    caseSensitive: false,
  );
  // A/c XX1234, A/c *1234, A/c no. XXXXXXXX1234, Acct X1234, card ending 1234,
  // a/c ending with 1234, full number -> last 4 digits.
  static final _acctRe = RegExp(
    r'\b(?:a\/?c|acct?|account|card)\b(?:\s*(?:no|number|num))?[\s.:#\-]*(?:ending(?:\s*with)?[\s:]*)?[xX*\.\-]*\s*(\d{3,})',
    caseSensitive: false,
  );
  static final _maskedRe = RegExp(r'[xX*]{1,}\s*(\d{4})\b');
  static final _refRe = RegExp(
    r'(?:UPI[\s:\/\-]*(?:Ref(?:erence)?[\s.:#]*(?:No)?[\s.:#]*)?|P2[MAP]\/|Ref(?:erence)?\s*(?:No|Number|ID)?[\s.:#\-]*|Refno[\s.:#\-]*|UTR[\s.:#\-]*|RRN[\s.:#\-]*|IMPS[\s.:#\-]*|Txn\s*(?:ID|No)[\s.:#\-]*)(\d{6,})',
    caseSensitive: false,
  );

  /// Ordered payee patterns. They cover the different shapes banks use:
  ///   Axis   : "UPI/P2M/123456/SWIGGY"
  ///   HDFC   : "Sent Rs.1 from HDFC Bank A/C *1919 to NAME on 31/08/26 Ref ..."
  ///            "... to VPA x@ybl (UPI Ref no ...)", "... from VPA x@ybl (UPI ...)"
  ///   ICICI  : "Acct XX110 debited for Rs 1054.00 on 01-Nov-26; Amazon Pay Gift credited. UPI:123"
  ///            "Acct XX110 credited ... from NAME. UPI:123"
  ///   SBI    : "A/C X1234 debited by 500.0 ... trf to NAME Refno 123"
  ///   Kotak  : "Sent Rs.1 from Kotak Bank AC X1234 to NAME@upi on 01-11-26"
  ///   Cards  : "spent ... Card XX1234 at AMAZON on ..."
  static final List<RegExp> _payeePatterns = [
    RegExp(
      r'UPI\/P2[MAP]\/\d+\/([A-Za-z0-9@._& \-]+?)(?=\s{2,}|\s+(?:Not|If|Avl|Bal|SMS|Call)\b|$)',
      caseSensitive: false,
    ),
    RegExp(r';\s*([^;]+?)\s+credited\b', caseSensitive: false),
    RegExp(r'\bto\s+VPA\s+([^\s()]+)', caseSensitive: false),
    RegExp(r'\bfrom\s+VPA\s+([^\s()]+)', caseSensitive: false),
    RegExp(
      r'(?:trf|transfer(?:red)?)\s+to\s+(.+?)(?=\s+(?:Ref|Refno|UPI|on|Not|If)\b|[.,;]|$)',
      caseSensitive: false,
    ),
    RegExp(r'\bto\s+(.+?)\s+on\s+\d', caseSensitive: false),
    RegExp(
      r'\bat\s+(.+?)(?=\s+on\s+\d|\s+(?:Avl|Bal|Limit|Not|If)\b|[.;]|$)',
      caseSensitive: false,
    ),
    RegExp(
      r'\bfrom\s+([A-Za-z][^.;]*?)\s*\.\s*(?:UPI|IMPS|NEFT|Ref|Avl|Bal)',
      caseSensitive: false,
    ),
    RegExp(
      r'\bby\s+([A-Za-z][A-Za-z0-9@._ &\-]{2,30}?)(?=\s*\(|\s+(?:on|Ref|UPI)\b|[.;]|$)',
      caseSensitive: false,
    ),
    RegExp(r'\binfo[:\-]\s*([^\s.;]+)', caseSensitive: false),
  ];
  static final _badPayee = RegExp(
    r'^(?:a\/?c|acct?|account|hdfc|icici|sbi|axis|kotak|bank|your|card|no\b|rs\b|inr\b|\d)',
    caseSensitive: false,
  );

  static String? extractPayee(String body) {
    for (final re in _payeePatterns) {
      final m = re.firstMatch(body);
      if (m == null) continue;
      var p = (m.group(1) ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
      p = p.replaceAll(RegExp(r'^[\s.,;:\-]+|[\s.,;:\-]+$'), '');
      if (p.length < 2 || _badPayee.hasMatch(p)) continue;
      if (p.length > 40) p = p.substring(0, 40).trim();
      return p;
    }
    return null;
  }

  @override
  bool matches(String sender) => true; // fallback – always matches

  static int _toPaise(String s) =>
      (double.parse(s.replaceAll(',', '')) * 100).round();

  @override
  ParsedTxn? parse(String body, DateTime at) {
    final lower = body.toLowerCase();

    // First amount that is not the balance / limit figure.
    int? amountPaise;
    for (final m in _amountRe.allMatches(body)) {
      final from = m.start - 14 < 0 ? 0 : m.start - 14;
      final before = lower.substring(from, m.start);
      if (before.contains('bal') || before.contains('limit')) continue;
      try {
        amountPaise = _toPaise(m.group(1)!);
      } catch (_) {
        continue;
      }
      break;
    }
    if (amountPaise == null) {
      final by = _amountByRe.firstMatch(body)?.group(1);
      if (by != null) {
        try {
          amountPaise = _toPaise(by);
        } catch (_) {}
      }
    }
    if (amountPaise == null) return null;

    final di = _firstIndex(
      lower,
      RegExp(r'debited|deducted|withdrawn|spent|sent|paid|purchase'),
    );
    final ci = _firstIndex(lower, RegExp(r'credited|received|deposited'));
    final isDebit = di != -1 && (ci == -1 || di < ci);

    // 3 or 4 trailing digits (ICICI masks to "XX110"); full numbers -> last 4.
    String? last4;
    final a = _acctRe.firstMatch(body)?.group(1);
    if (a != null) {
      last4 = a.length >= 4 ? a.substring(a.length - 4) : a;
    } else {
      last4 = _maskedRe.firstMatch(body)?.group(1);
    }

    final refNo = _refRe.firstMatch(body)?.group(1);

    int? balPaise;
    final balStr = _balRe.firstMatch(body)?.group(1);
    if (balStr != null) {
      try {
        balPaise = _toPaise(balStr);
      } catch (_) {}
    }

    final payee = extractPayee(body);

    final mode = lower.contains('upi') || lower.contains('vpa')
        ? PayMode.upi
        : lower.contains('atm')
        ? PayMode.atm
        : lower.contains('neft') ||
              lower.contains('imps') ||
              lower.contains('rtgs')
        ? PayMode.netBanking
        : lower.contains('card')
        ? PayMode.card
        : PayMode.other;

    return ParsedTxn(
      amountPaise: amountPaise,
      direction: isDebit ? Direction.debit : Direction.credit,
      mode: mode,
      payee: payee,
      last4: last4,
      refNo: refNo,
      balanceAfterPaise: balPaise,
      at: at,
    );
  }

  static int _firstIndex(String s, RegExp re) => re.firstMatch(s)?.start ?? -1;
}
