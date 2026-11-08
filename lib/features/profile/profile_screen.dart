import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/sms/sms_backfill_service.dart';
import '../../providers/db_provider.dart';
import '../../providers/today_provider.dart';
import '../today/today_data.dart';
import '../accounts/balance_mismatch_dialog.dart';
import '../../providers/repo_providers.dart';
import '../../domain/budget/daily_budget.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/settings.dart' as domain;
import '../../providers/settings_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _saving = false;

  final _moneyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  String _money(int paise) => _moneyFormat.format(paise / 100);

  TextStyle _heading(double size, {Color? color}) {
    return GoogleFonts.spaceGrotesk(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.textPrimary,
    );
  }

  TextStyle _body(double size, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: size,
      color: color ?? AppColors.textSecondary,
    );
  }

  Widget _panel(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Future<void> _save(domain.Settings updated) async {
    if (_saving) return;

    setState(() => _saving = true);

    try {
      await ref.read(settingsRepoProvider).save(updated);
      ref.invalidate(settingsProvider);
      ref.invalidate(todayBudgetProvider);
      ref.invalidate(todayDataProvider);
      ref.invalidate(todayVerdictProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save settings: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  // The dialog owns its TextEditingController.
  // This prevents disposing the controller before the dialog
  // has finished leaving the Flutter widget tree.
  Future<void> _editIncome(domain.Settings settings) async {
    final result = await showDialog<List<int>>(
      context: context,
      builder: (dialogContext) {
        return _IncomeEditDialog(
          initialIncomePaise: settings.monthlyIncomePaise,
          initialCommitmentsPaise: settings.monthlyCommitmentsPaise,
          initialPayDay: settings.payDay,
        );
      },
    );

    if (!mounted || result == null) return;

    await _save(
      settings.copyWith(
        monthlyIncomePaise: result[0],
        monthlyCommitmentsPaise: result[1],
        payDay: result[2],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(title, style: _heading(17)),
        ],
      ),
    );
  }

  Future<void> _editProfile(domain.Settings settings) async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (_) => _ProfileEditDialog(
        initialName: settings.displayName,
        initialEmail: settings.email,
      ),
    );
    if (!mounted || result == null) return;
    await _save(settings.copyWith(displayName: result[0], email: result[1]));
  }

  Widget _profileHeader(domain.Settings settings) {
    return _panel(
      Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35),
              ),
            ),
            child: const Icon(
              Icons.person_outline,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settings.displayName.isEmpty
                      ? 'Hisaab member'
                      : settings.displayName,
                  style: _heading(21),
                ),
                const SizedBox(height: 5),
                Text(
                  settings.email.isEmpty
                      ? 'Profile stored on this device'
                      : settings.email,
                  style: _body(12),
                ),
                const SizedBox(height: 7),
                Text(
                  'ACTIVE BURNER 🔥',
                  style: _heading(10, color: AppColors.primary),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit profile',
            onPressed: _saving ? null : () => _editProfile(settings),
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _incomeCard(domain.Settings settings) {
    final income = settings.monthlyIncomePaise;
    final commitments = settings.monthlyCommitmentsPaise;
    final flexible = settings.flexiblePoolPaise;
    final days = BudgetCycle.forDate(DateTime.now(), settings.payDay).totalDays;
    final daily = days > 0 ? (flexible / days).round() : 0;

    Widget line(String label, String value, {Color? color}) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: _body(12))),
          Text(value, style: _heading(13, color: color)),
        ],
      ),
    );

    return _panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Monthly Take-Home', style: _body(12))),
              TextButton.icon(
                onPressed: _saving ? null : () => _editIncome(settings),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(_money(income), style: _heading(34)),
          const SizedBox(height: 17),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.nested,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                line('Income', _money(income)),
                line('Monthly commitments', '- ${_money(commitments)}'),
                line('Free to spend', _money(flexible)),
                const Divider(height: 18, color: AppColors.border),
                Row(
                  children: [
                    const Icon(
                      Icons.calculate_outlined,
                      color: AppColors.primary,
                      size: 21,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${_money(flexible)} / $days days = ${_money(daily)} / day',
                        style: _heading(13, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  settings.payDay == 1
                      ? 'Cycle: calendar month'
                      : 'Cycle starts on day ${settings.payDay} (pay day)',
                  style: _body(11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _choice({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _saving ? null : onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.nested : AppColors.background,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: _heading(
                14,
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 5),
            Text(subtitle, style: _body(10)),
          ],
        ),
      ),
    );
  }

  Widget _cadenceCard(domain.Settings settings) {
    return _panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Budget Cadence', style: _heading(15))),
              Text('LIVE METRIC', style: _heading(10, color: AppColors.mint)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _choice(
                  title: 'Daily',
                  subtitle: '24h reset',
                  selected: settings.budgetMode == BudgetMode.daily,
                  onTap: () =>
                      _save(settings.copyWith(budgetMode: BudgetMode.daily)),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _choice(
                  title: 'Weekly',
                  subtitle: '7-day pool',
                  selected: settings.budgetMode == BudgetMode.weekly,
                  onTap: () =>
                      _save(settings.copyWith(budgetMode: BudgetMode.weekly)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Daily is Hisaab’s default. Weekly cadence is '
            'saved as a preference; weekly spending is shown in Today.',
            style: _body(11),
          ),
        ],
      ),
    );
  }

  Widget _roastCard(domain.Settings settings) {
    final level = settings.roastLevel;

    final quote = switch (level) {
      RoastLevel.gentle =>
        '“A little treat is fine. Just leave some room '
            'for tomorrow.”',
      RoastLevel.honest =>
        '“You spent money on convenience again. '
            'Your savings noticed.”',
      RoastLevel.savage =>
        '“Your wallet needs a restraining order '
            'against your UPI app.”',
    };

    final pill = switch (level) {
      RoastLevel.gentle => 'Soft Nudge 🌱',
      RoastLevel.honest => 'Balanced Bite ⚖️',
      RoastLevel.savage => 'Emotional Damage 🔥',
    };

    return _panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Roast Intensity', style: _heading(16)),
          const SizedBox(height: 6),
          Text(
            'How brutally honest should your night verdict be?',
            style: _body(12),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              for (final option in RoastLevel.values) ...[
                if (option != RoastLevel.gentle) const SizedBox(width: 8),
                Expanded(
                  child: _choice(
                    title:
                        option.name[0].toUpperCase() + option.name.substring(1),
                    subtitle: switch (option) {
                      RoastLevel.gentle => '🌱',
                      RoastLevel.honest => '⚖️',
                      RoastLevel.savage => '🔥',
                    },
                    selected: level == option,
                    onTap: () => _save(settings.copyWith(roastLevel: option)),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 17),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.nested,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pill, style: _heading(12, color: AppColors.primary)),
                const SizedBox(height: 11),
                Text(
                  quote,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.nested,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: _heading(13)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: _body(11)),
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  /// Offers to update stored balances when the latest SMS shows a different one.
  Future<void> _reconcileBalances(SmsImportResult result) async {
    final repo = ref.read(accountRepoProvider);
    final accounts = await repo.getAll();
    for (final a in accounts) {
      final seen = result.balances[a.id];
      if (seen == null ||
          seen.balancePaise == a.balancePaise ||
          !seen.at.isAfter(a.updatedAt))
        continue;
      if (!mounted) return;
      final use = await showDialog<bool>(
        context: context,
        builder: (_) => BalanceMismatchDialog(
          bankName: a.bankName,
          smsBalance: seen.balancePaise / 100,
          storedBalance: a.balancePaise / 100,
        ),
      );
      if (use == true) await repo.updateBalance(a.id, seen.balancePaise);
    }
    ref.invalidate(accountsProvider);
  }

  Future<void> _manageSms(domain.Settings settings) async {
    final status = await Permission.sms.status;
    if (!mounted) return;
    final granted = status.isGranted;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Automatic SMS Tracking'),
        content: Text(
          granted
              ? 'SMS access granted. Import the last 15 days of bank transactions, or manage access in Android settings.'
              : 'SMS access is not granted. You can request it or manage access in Android Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final result = await Permission.sms.request();
              if (!mounted) return;
              await _save(settings.copyWith(smsEnabled: result.isGranted));
              if (!result.isGranted && result.isPermanentlyDenied) {
                await openAppSettings();
              }
            },
            child: Text(granted ? 'Check access' : 'Request access'),
          ),
          if (granted)
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  final result = await SmsBackfillService(ref.read(dbProvider))
                      .run();
                  ref.invalidate(todayBudgetProvider);
                  ref.invalidate(todayDataProvider);
                  await _reconcileBalances(result);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Scanned ${result.scanned} SMS; imported ${result.imported} new transactions.${result.skippedSummary.isEmpty ? '' : ' Skipped: ${result.skippedSummary}.'}',
                      ),
                    ),
                  );
                } catch (error) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('SMS import failed: $error')),
                  );
                }
              },
              child: const Text('Rescan 15 days'),
            ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await openAppSettings();
            },
            child: const Text('App settings'),
          ),
        ],
      ),
    );
  }

  Widget _trackingCard(domain.Settings settings) {
    return _panel(
      Column(
        children: [
          _settingsTile(
            icon: Icons.account_balance_outlined,
            title: 'Linked Bank Accounts',
            subtitle: 'View your connected accounts',
            onTap: () => context.push('/accounts'),
          ),
          const Divider(color: AppColors.border),
          _settingsTile(
            icon: Icons.category_outlined,
            title: 'Categorise Spending',
            subtitle: 'Fix uncategorised UPI & card transactions',
            onTap: () => context.push('/upi'),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ),
          const Divider(color: AppColors.border),
          _settingsTile(
            icon: Icons.sms_outlined,
            title: 'Automatic SMS Tracking',
            subtitle: settings.smsEnabled
                ? 'Enabled · reads bank SMS automatically'
                : 'Not configured',
            onTap: () => _manageSms(settings),
            trailing: Icon(
              settings.smsEnabled
                  ? Icons.check_circle_outline
                  : Icons.chevron_right,
              color: settings.smsEnabled
                  ? AppColors.mint
                  : AppColors.textSecondary,
            ),
          ),
          const Divider(color: AppColors.border),
          _settingsTile(
            icon: Icons.notifications_outlined,
            title: 'Night Verdict',
            subtitle: 'Daily summary at 11:45 PM · tap to view today',
            onTap: () => context.push('/verdict'),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _privacyCard() {
    return _panel(
      Column(
        children: [
          _settingsTile(
            icon: Icons.lock_outline,
            title: 'Privacy First',
            subtitle: 'Local-first transaction processing',
            trailing: const Icon(
              Icons.verified_user_outlined,
              color: AppColors.mint,
            ),
          ),
          const Divider(color: AppColors.border),
          _settingsTile(
            icon: Icons.storage_outlined,
            title: 'Data Storage',
            subtitle: 'Stored locally on this device',
            trailing: const Icon(
              Icons.phone_android,
              color: AppColors.textSecondary,
            ),
          ),
          const Divider(color: AppColors.border),
          _settingsTile(
            icon: Icons.file_download_outlined,
            title: 'Export Expense CSV',
            subtitle: 'Share your transactions as a spreadsheet',
            onTap: () => context.push('/export'),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ),
          const Divider(color: AppColors.border),
          _settingsTile(
            icon: Icons.feedback_outlined,
            title: 'Send Feedback',
            subtitle: 'Report a problem or suggest an idea',
            onTap: () => context.push('/feedback'),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncSettings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: asyncSettings.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Could not load settings: $error',
                style: _body(13),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (settings) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              children: [
                Row(
                  children: [
                    Text('Profile', style: _heading(26)),
                    const Spacer(),
                    const Icon(
                      Icons.settings_outlined,
                      color: AppColors.primary,
                      size: 25,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _profileHeader(settings),
                const SizedBox(height: 24),
                _sectionTitle('Income Engine & Quota', Icons.currency_rupee),
                _incomeCard(settings),
                const SizedBox(height: 12),
                _cadenceCard(settings),
                const SizedBox(height: 24),
                _sectionTitle('Personality Engine', Icons.psychology_outlined),
                _roastCard(settings),
                const SizedBox(height: 24),
                _sectionTitle('Tracking & Alerts', Icons.radar),
                _trackingCard(settings),
                const SizedBox(height: 24),
                _sectionTitle('Data & Privacy', Icons.shield_outlined),
                _privacyCard(),
                const SizedBox(height: 28),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'HISAAB',
                        style: _heading(17, color: AppColors.primary),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'No manual entries. Just cold truths.',
                        style: _body(11),
                      ),
                      const SizedBox(height: 5),
                      Text('Built for Indian high-burners ⚡', style: _body(10)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// INCOME EDIT DIALOG
//
// This widget owns the TextEditingController.
// Flutter disposes it only after the dialog is unmounted.
// ============================================================

class _IncomeEditDialog extends StatefulWidget {
  final int initialIncomePaise;
  final int initialCommitmentsPaise;
  final int initialPayDay;

  const _IncomeEditDialog({
    required this.initialIncomePaise,
    required this.initialCommitmentsPaise,
    required this.initialPayDay,
  });

  @override
  State<_IncomeEditDialog> createState() => _IncomeEditDialogState();
}

class _IncomeEditDialogState extends State<_IncomeEditDialog> {
  late final TextEditingController _income;
  late final TextEditingController _commitments;
  late int _payDay;
  String? _error;

  @override
  void initState() {
    super.initState();
    _income = TextEditingController(
      text: widget.initialIncomePaise == 0
          ? ''
          : (widget.initialIncomePaise ~/ 100).toString(),
    );
    _commitments = TextEditingController(
      text: widget.initialCommitmentsPaise == 0
          ? ''
          : (widget.initialCommitmentsPaise ~/ 100).toString(),
    );
    _payDay = widget.initialPayDay < 1
        ? 1
        : (widget.initialPayDay > 28 ? 28 : widget.initialPayDay);
  }

  @override
  void dispose() {
    _income.dispose();
    _commitments.dispose();
    super.dispose();
  }

  void _submit() {
    final income = int.tryParse(_income.text.replaceAll(',', '').trim());
    final commitText = _commitments.text.replaceAll(',', '').trim();
    final commitments = commitText.isEmpty ? 0 : int.tryParse(commitText);

    if (income == null || income <= 0 || income > 100000000) {
      setState(() => _error = 'Enter a valid positive monthly income');
      return;
    }
    if (commitments == null || commitments < 0) {
      setState(() => _error = 'Commitments must be 0 or more');
      return;
    }
    if (commitments > income) {
      setState(() => _error = 'Commitments cannot be more than income');
      return;
    }
    Navigator.of(context).pop(<int>[income * 100, commitments * 100, _payDay]);
  }

  @override
  Widget build(BuildContext context) {
    final label = GoogleFonts.inter(
      fontSize: 12,
      color: AppColors.textSecondary,
    );
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Income & commitments',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _income,
              autofocus: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                prefixText: '₹ ',
                labelText: 'Monthly income',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _commitments,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                prefixText: '₹ ',
                labelText: 'Monthly commitments',
                helperText: 'Family support, rent, EMI, SIP, chit...',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              value: _payDay,
              decoration: const InputDecoration(
                labelText: 'Pay day (cycle starts)',
                border: OutlineInputBorder(),
              ),
              items: [
                for (var d = 1; d <= 28; d++)
                  DropdownMenuItem(
                    value: d,
                    child: Text(d == 1 ? '1 (calendar month)' : 'Day $d'),
                  ),
              ],
              onChanged: (v) => setState(() => _payDay = v ?? 1),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.red),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Daily budget = (income − commitments) ÷ days in cycle.',
              style: label,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _ProfileEditDialog extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  const _ProfileEditDialog({
    required this.initialName,
    required this.initialEmail,
  });
  @override
  State<_ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<_ProfileEditDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(
    text: widget.initialName,
  );
  late final TextEditingController _email = TextEditingController(
    text: widget.initialEmail,
  );
  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit profile'),
    content: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _name,
            maxLength: 40,
            decoration: const InputDecoration(labelText: 'Display name'),
            validator: (v) => (v?.trim().length ?? 0) < 2
                ? 'Enter at least two characters'
                : null,
          ),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email (optional)'),
            validator: (v) {
              final e = v?.trim() ?? '';
              return e.isNotEmpty &&
                      !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(e)
                  ? 'Enter a valid email'
                  : null;
            },
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (_form.currentState?.validate() ?? false) {
            Navigator.pop(context, [_name.text.trim(), _email.text.trim()]);
          }
        },
        child: const Text('Save'),
      ),
    ],
  );
}
