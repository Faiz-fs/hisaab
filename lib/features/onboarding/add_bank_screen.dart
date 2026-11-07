import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/models/account.dart';
import '../../data/sms/sms_backfill_service.dart';
import '../../providers/db_provider.dart';
import '../../providers/repo_providers.dart';
import '../../providers/today_provider.dart';
import '../today/today_data.dart';

/// Step 3 of Hisaab onboarding.
///
/// Users can add one or more bank accounts.
/// Data is stored locally using Drift + SQLite.
class AddBankScreen extends ConsumerStatefulWidget {
  const AddBankScreen({super.key});

  @override
  ConsumerState<AddBankScreen> createState() => _AddBankScreenState();
}

class _AddBankScreenState extends ConsumerState<AddBankScreen> {
  final _formKey = GlobalKey<FormState>();

  final _last4Controller = TextEditingController();
  final _balanceController = TextEditingController();

  bool _saving = false;
  String _selectedBank = 'HDFC Bank';

  final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  final List<String> _banks = const [
    'HDFC Bank',
    'State Bank of India',
    'ICICI Bank',
    'Axis Bank',
    'Indian Bank',
    'Canara Bank',
    'Kotak Mahindra Bank',
    'Punjab National Bank',
    'Bank of Baroda',
    'Union Bank of India',
    'IDFC FIRST Bank',
    'Federal Bank',
    'IndusInd Bank',
    'Other Bank',
  ];

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

  @override
  void dispose() {
    _last4Controller.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  /// Convert rupees to integer paise without floating
  /// point rounding errors.
  int? _parsePaise(String input) {
    final value = input.replaceAll(',', '').trim();

    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) {
      return null;
    }

    final parts = value.split('.');
    final rupees = int.tryParse(parts[0]);

    if (rupees == null || rupees > 100000000) {
      return null;
    }

    final fraction = parts.length == 2 ? parts[1].padRight(2, '0') : '00';

    final paise = int.tryParse(fraction);

    if (paise == null) return null;

    return rupees * 100 + paise;
  }

  /// Save a new bank account to SQLite.
  Future<void> _addAccount() async {
    if (_saving) return;

    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() => _saving = true);

    try {
      final repo = ref.read(accountRepoProvider);

      final existing = await repo.getAll();

      if (!mounted) return;

      final last4 = _last4Controller.text.trim();

      final duplicate = existing.any(
        (account) =>
            account.bankName == _selectedBank && account.last4 == last4,
      );

      if (duplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This bank account is already added.')),
        );
        return;
      }

      final balancePaise = _parsePaise(_balanceController.text);

      if (balancePaise == null) return;

      final account = AccountModel(
        id: '${DateTime.now().microsecondsSinceEpoch}',
        bankName: _selectedBank,
        last4: last4,
        balancePaise: balancePaise,
        updatedAt: DateTime.now(),
      );

      await repo.upsert(account);

      ref.invalidate(accountsProvider);

      // Import the last 15 days of SMS now that this account exists.
      try {
        final result = await SmsBackfillService(ref.read(dbProvider)).run();
        if (result.imported > 0) {
          ref.invalidate(todayBudgetProvider);
          ref.invalidate(todayDataProvider);
          ref.invalidate(accountsProvider);
        }
      } catch (_) {
        // SMS permission/bridge may be unavailable; app launch will retry.
      }

      if (!mounted) return;

      _last4Controller.clear();
      _balanceController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_selectedBank account added successfully'),
          backgroundColor: AppColors.card,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('AddBankScreen save error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save account: $error'),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Widget _progress() {
    return Row(
      children: [
        for (int i = 0; i < 5; i++) ...[
          Expanded(
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: i <= 2 ? AppColors.primary : AppColors.nested,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          if (i != 4) const SizedBox(width: 7),
        ],
      ],
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

  Widget _bankSelector() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedBank,
      isExpanded: true,
      dropdownColor: AppColors.nested,
      style: _heading(14),
      decoration: InputDecoration(
        labelText: 'SELECT YOUR BANK',
        labelStyle: _body(12),
        prefixIcon: const Icon(
          Icons.account_balance_outlined,
          color: AppColors.primary,
        ),
        filled: true,
        fillColor: AppColors.nested,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
      ),
      items: _banks.map((bank) {
        return DropdownMenuItem<String>(
          value: bank,
          child: Text(bank, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: _saving
          ? null
          : (value) {
              if (value != null) {
                setState(() => _selectedBank = value);
              }
            },
    );
  }

  Widget _accountForm() {
    return _panel(
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ADD A BANK ACCOUNT', style: _heading(15)),
            const SizedBox(height: 7),
            Text(
              'We only need a few details to track '
              'your money.',
              style: _body(12),
            ),
            const SizedBox(height: 23),
            _bankSelector(),
            const SizedBox(height: 17),
            TextFormField(
              controller: _last4Controller,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              maxLength: 4,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: _heading(17),
              decoration: InputDecoration(
                labelText: 'LAST 4 ACCOUNT DIGITS',
                hintText: '1234',
                counterText: '',
                prefixIcon: const Icon(Icons.numbers, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.nested,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              validator: (value) {
                if (value == null || !RegExp(r'^\d{4}$').hasMatch(value)) {
                  return 'Enter exactly 4 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 17),
            TextFormField(
              controller: _balanceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _addAccount(),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                LengthLimitingTextInputFormatter(12),
              ],
              style: _heading(17),
              decoration: InputDecoration(
                labelText: 'CURRENT BALANCE',
                hintText: '25000.00',
                prefixIcon: const Icon(
                  Icons.currency_rupee,
                  color: AppColors.primary,
                ),
                filled: true,
                fillColor: AppColors.nested,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              validator: (value) {
                if (_parsePaise(value ?? '') == null) {
                  return 'Enter a valid balance, e.g. 25000.50';
                }
                return null;
              },
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                const Icon(Icons.lock_outline, size: 16, color: AppColors.mint),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No full account number, PIN or password.',
                    style: _body(11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 51,
              child: OutlinedButton.icon(
                onPressed: _saving ? null : _addAccount,
                icon: const Icon(Icons.add_circle_outline),
                label: Text(
                  _saving ? 'SAVING...' : 'ADD THIS ACCOUNT',
                  style: _heading(13, color: AppColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _savedAccounts(List<AccountModel> accounts) {
    if (accounts.isEmpty) {
      return _panel(
        Column(
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 34,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text('NO ACCOUNTS YET', style: _heading(14)),
            const SizedBox(height: 7),
            Text('Add your first bank account above.', style: _body(12)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ADDED ACCOUNTS (${accounts.length})',
          style: _heading(12, color: AppColors.primary),
        ),
        const SizedBox(height: 13),
        for (final account in accounts) ...[
          _panel(
            Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppColors.nested,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.account_balance,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(account.bankName, style: _heading(14)),
                      const SizedBox(height: 5),
                      Text('•••• ${account.last4}', style: _body(12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _currency.format(account.balancePaise / 100),
                      style: _heading(14),
                    ),
                    const SizedBox(height: 5),
                    Text('Current balance', style: _body(10)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: _saving
                            ? null
                            : () => context.go('/onboarding/income'),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'STEP 03 / 05',
                        style: _heading(11, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _progress(),
                  const SizedBox(height: 30),
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(
                      Icons.account_balance_outlined,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('WHERE DOES\nIT LIVE?', style: _heading(35)),
                  const SizedBox(height: 12),
                  Text(
                    'Add the bank accounts you use for '
                    'UPI and everyday spending.',
                    style: _body(13),
                  ),
                  const SizedBox(height: 27),
                  _accountForm(),
                  const SizedBox(height: 27),
                  accountsAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                    error: (error, stack) => _panel(
                      Text('Unable to load accounts: $error', style: _body(12)),
                    ),
                    data: _savedAccounts,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saving
                          ? null
                          : () => context.go('/onboarding/sms-permission'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'CONTINUE',
                            style: _heading(15, color: AppColors.onPrimary),
                          ),
                          const SizedBox(width: 11),
                          const Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('You can add more accounts later.', style: _body(11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
