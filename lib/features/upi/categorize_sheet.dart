import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/format/inr_format.dart';
import '../../core/theme/app_colors.dart';
import '../../data/db/app_database.dart';
import '../../domain/categorizer/merchant_rules.dart';
import '../../providers/db_provider.dart';
import '../../providers/today_provider.dart';
import '../today/today_data.dart';
import 'upi_tracker_screen.dart';

/// Choices that are NOT everyday spending (excluded from the daily limit).
const _specials = <({String label, String category, String kind})>[
  (label: 'Family', category: 'Family', kind: 'family'),
  (label: 'Savings / SIP', category: 'Savings', kind: 'savings'),
  (label: 'EMI / Loan', category: 'EMI', kind: 'emi'),
];

/// Bottom sheet for categorising a transaction.
/// "Always use for this payee" saves a payee rule (category + kind), updates the
/// payee's past transactions (except ones set manually) and applies to future SMS.
class CategorizeSheet extends ConsumerStatefulWidget {
  final String txnId;
  const CategorizeSheet({super.key, required this.txnId});

  static Future<void> show(BuildContext context, String txnId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CategorizeSheet(txnId: txnId),
    );
  }

  @override
  ConsumerState<CategorizeSheet> createState() => _CategorizeSheetState();
}

class _CategorizeSheetState extends ConsumerState<CategorizeSheet> {
  Txn? _txn;
  bool _loading = true;
  bool _applyAll = true;
  String? _selected; // category name for spend chips, label for special chips

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(dbProvider);
    final row = await (db.select(
      db.txns,
    )..where((t) => t.id.equals(widget.txnId))).getSingleOrNull();
    if (!mounted) return;
    String? selected = row?.category;
    if (row != null && row.kind != 'spend') {
      for (final s in _specials) {
        if (s.kind == row.kind) selected = s.label;
      }
    }
    setState(() {
      _txn = row;
      _selected = selected;
      _loading = false;
    });
  }

  Future<void> _save(String selectedKey, String category, String kind) async {
    final txn = _txn;
    if (txn == null) return;
    setState(() => _selected = selectedKey);
    final db = ref.read(dbProvider);
    final payee = txn.payee?.trim();
    if (_applyAll && payee != null && payee.isNotEmpty) {
      await db.payeeRulesDao.upsertByPattern(
        pattern: payee,
        category: category,
        kind: kind,
      );
      // The tapped row follows the rule; other manual rows of this payee stay as they are.
      await db.txnsDao.setCategory(
        txn.id,
        category,
        kind: kind,
        source: 'auto',
      );
      await db.txnsDao.applyRuleToPayee(payee, category, kind);
    } else {
      await db.txnsDao.setCategory(
        txn.id,
        category,
        kind: kind,
        source: 'user',
      );
    }
    ref.invalidate(todayDataProvider);
    ref.invalidate(todayBudgetProvider);
    ref.invalidate(upiTxnsProvider);
    if (mounted) Navigator.pop(context);
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.nested,
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: selected ? AppColors.onPrimary : AppColors.textPrimary,
      ),
      side: const BorderSide(color: AppColors.border),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.6,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final txn = _txn;
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: _loading
              ? const SizedBox(
                  height: 160,
                  child: Center(child: CircularProgressIndicator()),
                )
              : txn == null
              ? const SizedBox(
                  height: 120,
                  child: Center(child: Text('Transaction not found')),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.borderInteractive,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Categorise',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${txn.payee ?? 'Unknown merchant'} · ${inr(txn.amount / 100)}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _sectionLabel('COUNTS AS SPENDING'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in kCategories)
                          _chip(c, _selected == c, () => _save(c, c, 'spend')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _sectionLabel('NOT SPENDING (excluded from daily limit)'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in _specials)
                          _chip(
                            s.label,
                            _selected == s.label,
                            () => _save(s.label, s.category, s.kind),
                          ),
                      ],
                    ),
                    if (txn.payee != null && txn.payee!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _applyAll,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _applyAll = v),
                        title: Text(
                          'Always use this for “${txn.payee}”',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          'Updates past transactions and future SMS from this payee',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
