import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../data/export/csv_export_service.dart';
import '../../domain/categorizer/merchant_rules.dart';
import '../../providers/db_provider.dart';
import '../../providers/repo_providers.dart';

/// Profile -> Export CSV. Pick a date range and filters, see the row count,
/// then share the file through the Android share sheet.
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  ExportRange _range = ExportRange.last30;
  DateTimeRange? _custom;
  ExportType _type = ExportType.all;
  String? _accountId;
  String? _category;

  int? _count; // null while counting
  bool _exporting = false;
  int _reqId = 0;

  static const _extraCategories = ['Family', 'Savings', 'EMI'];

  ExportFilter get _filter => ExportFilter(
    range: _range,
    customStart: _custom?.start,
    customEnd: _custom?.end,
    type: _type,
    accountId: _accountId,
    category: _category,
  );

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final id = ++_reqId;
    setState(() => _count = null);
    try {
      final rows = await CsvExportService(ref.read(dbProvider)).fetch(_filter);
      if (!mounted || id != _reqId) return;
      setState(() => _count = rows.length);
    } catch (_) {
      if (!mounted || id != _reqId) return;
      setState(() => _count = 0);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickCustom() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: _custom,
    );
    if (picked == null) return;
    setState(() {
      _custom = picked;
      _range = ExportRange.custom;
    });
    _reload();
  }

  Future<void> _export() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final svc = CsvExportService(ref.read(dbProvider));
      final rows = await svc.fetch(_filter);
      if (rows.isEmpty) {
        _snack('Nothing to export for these filters');
        return;
      }
      final file = await svc.writeCsv(rows);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/csv')],
          subject: 'Hisaab transactions',
          text: 'Hisaab export · ${rows.length} transactions',
        ),
      );
    } catch (e) {
      _snack('Export failed: $e');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  String get _rangeLabel {
    final f = DateFormat('d MMM y');
    final (s, e) = _filter.bounds;
    if (s == null && e == null) return 'All time';
    if (s == null)
      return 'Until ${f.format(e!.subtract(const Duration(days: 1)))}';
    final end = e == null
        ? DateTime.now()
        : e.subtract(const Duration(days: 1));
    return '${f.format(s)} – ${f.format(end)}';
  }

  TextStyle _label() => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    letterSpacing: 0.6,
  );

  Widget _section(String title, Widget child) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _label()),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );

  Widget _chip(String label, bool selected, VoidCallback onTap) => ChoiceChip(
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

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider).asData?.value ?? const [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/profile'),
        ),
        title: Text(
          'Export CSV',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _section(
            'DATE RANGE',
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip('This month', _range == ExportRange.thisMonth, () {
                  setState(() => _range = ExportRange.thisMonth);
                  _reload();
                }),
                _chip('Last 30 days', _range == ExportRange.last30, () {
                  setState(() => _range = ExportRange.last30);
                  _reload();
                }),
                _chip('All', _range == ExportRange.all, () {
                  setState(() => _range = ExportRange.all);
                  _reload();
                }),
                _chip(
                  _range == ExportRange.custom && _custom != null
                      ? 'Custom ✓'
                      : 'Custom…',
                  _range == ExportRange.custom,
                  _pickCustom,
                ),
              ],
            ),
          ),
          _section(
            'TYPE',
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ExportType>(
                segments: const [
                  ButtonSegment(value: ExportType.all, label: Text('All')),
                  ButtonSegment(value: ExportType.spend, label: Text('Spend')),
                  ButtonSegment(
                    value: ExportType.income,
                    label: Text('Income'),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (s) {
                  setState(() => _type = s.first);
                  _reload();
                },
              ),
            ),
          ),
          _section(
            'ACCOUNT',
            DropdownButtonFormField<String?>(
              initialValue: _accountId,
              isExpanded: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All accounts'),
                ),
                for (final a in accounts)
                  DropdownMenuItem<String?>(
                    value: a.id,
                    child: Text('${a.bankName} •••• ${a.last4}'),
                  ),
              ],
              onChanged: (v) {
                setState(() => _accountId = v);
                _reload();
              },
            ),
          ),
          _section(
            'CATEGORY',
            DropdownButtonFormField<String?>(
              initialValue: _category,
              isExpanded: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All categories'),
                ),
                const DropdownMenuItem<String?>(
                  value: kUncategorisedFilter,
                  child: Text('Uncategorised'),
                ),
                for (final c in [...kCategories, ..._extraCategories])
                  DropdownMenuItem<String?>(value: c, child: Text(c)),
              ],
              onChanged: (v) {
                setState(() => _category = v);
                _reload();
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.table_chart_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _count == null
                            ? 'Counting…'
                            : '$_count transaction${_count == 1 ? '' : 's'} will be exported',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _rangeLabel,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: (_exporting || _count == null || _count == 0)
                  ? null
                  : _export,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: _exporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.ios_share),
              label: Text(
                _exporting ? 'Preparing…' : 'Export & share',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Columns: Date, Time, Account, Bank, Direction, Kind, Amount, Payee, '
            'Category, Mode, Ref, Balance after. Spend = debits, Income = credits; '
            'the Kind column separates family, savings and EMI payments.',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
