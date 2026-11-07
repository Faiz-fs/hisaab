import 'package:drift/drift.dart' as drift;
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

/// Bottom sheet for categorising a transaction.
/// Picking "apply to all" also saves a payee rule so future SMS from the same
/// payee are categorised automatically.
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
  String? _selected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(dbProvider);
    final row = await (db.select(db.txns)..where((t) => t.id.equals(widget.txnId))).getSingleOrNull();
    if (!mounted) return;
    setState(() {
      _txn = row;
      _selected = row?.category;
      _loading = false;
    });
  }

  Future<void> _save(String category) async {
    final txn = _txn;
    if (txn == null) return;
    final db = ref.read(dbProvider);
    final payee = txn.payee?.trim();
    if (_applyAll && payee != null && payee.isNotEmpty) {
      await db.payeeRulesDao.insertRule(PayeeRulesCompanion.insert(
        pattern: payee,
        category: category,
        isRegex: const drift.Value(false),
      ));
      await db.txnsDao.setCategoryForPayee(payee, category);
    } else {
      await db.txnsDao.setCategory(txn.id, category);
    }
    ref.invalidate(todayDataProvider);
    ref.invalidate(todayBudgetProvider);
    ref.invalidate(upiTxnsProvider);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final txn = _txn;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: _loading
            ? const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()))
            : txn == null
                ? const SizedBox(height: 120, child: Center(child: Text('Transaction not found')))
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40, height: 4,
                          decoration: BoxDecoration(color: AppColors.borderInteractive, borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Categorise', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      Text(
                        '${txn.payee ?? 'Unknown merchant'} · ${inr(txn.amount / 100)}',
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final c in kCategories)
                            ChoiceChip(
                              label: Text(c),
                              selected: _selected == c,
                              onSelected: (_) {
                                setState(() => _selected = c);
                                _save(c);
                              },
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.nested,
                              labelStyle: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _selected == c ? AppColors.onPrimary : AppColors.textPrimary,
                              ),
                              side: const BorderSide(color: AppColors.border),
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
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
                          ),
                          subtitle: Text(
                            'Also updates past transactions from this payee',
                            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ],
                  ),
      ),
    );
  }
}
