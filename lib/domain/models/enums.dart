/// Payment mode for a transaction.
enum PayMode { upi, netBanking, atm, card, other }

/// Transaction direction.
enum Direction { debit, credit }

/// What a transaction means for the budget.
/// Only [spend] counts toward the daily limit, ring, verdict and Money Map.
enum TxnKind { spend, family, savings, emi, income, internal, refund }

/// Budget cycle granularity.
enum BudgetMode { daily, weekly }

/// Roast severity level.
enum RoastLevel { gentle, honest, savage }
