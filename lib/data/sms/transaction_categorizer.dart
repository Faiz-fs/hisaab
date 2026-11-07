/// Conservative SMS merchant categorization. No personal SMS text is stored.
class TransactionCategorizer {
  const TransactionCategorizer._();

  static String? categorize(String? payee, String body, {required bool debit}) {
    if (!debit) return 'Income';
    final text = '${payee ?? ''} $body'.toLowerCase();
    if (RegExp(r'amazon pay gift|gift card|gift voucher').hasMatch(text)) return 'Shopping';
    if (RegExp(r'swiggy|zomato|restaurant|cafe|food order').hasMatch(text)) return 'Food';
    if (RegExp(r'uber|ola cab|rapido|metro rail').hasMatch(text)) return 'Transport';
    if (RegExp(r'netflix|spotify|youtube premium|hotstar').hasMatch(text)) return 'Subscriptions';
    if (RegExp(r'electricity bill|water bill|broadband|mobile recharge').hasMatch(text)) return 'Bills';
    if (RegExp(r'pharmacy|medical store|hospital').hasMatch(text)) return 'Health';
    if (RegExp(r'amazon|flipkart|myntra|ajio').hasMatch(text)) return 'Shopping';
    if (RegExp(r'\b(?:sent|transfer(?:red)?|trf)\b').hasMatch(text)) return 'Transfers';
    return null; // Do not guess an unknown merchant's category.
  }
}
