import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/settings_provider.dart';

/// Second step of Hisaab onboarding.
///
/// Collects monthly take-home income, previews the daily
/// budget, and persists the value before bank account setup.
class IncomeScreen extends ConsumerStatefulWidget {
  const IncomeScreen({super.key});

  @override
  ConsumerState<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends ConsumerState<IncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  bool _saving = false;
  bool _loaded = false;
  int _incomeRupees = 0;

  final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  String _money(num amount) => _currency.format(amount);

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
    _controller.dispose();
    super.dispose();
  }

  int _parseIncome(String value) {
    return int.tryParse(value.replaceAll(',', '').trim()) ?? 0;
  }

  /// Load previously saved income only once.
  ///
  /// Avoids resetting the user's input during rebuilds.
  void _loadSavedIncome(int paise) {
    if (_loaded) return;

    _loaded = true;

    if (paise > 0) {
      final rupees = paise ~/ 100;

      _controller.text = rupees.toString();
      _incomeRupees = rupees;
    }
  }

  /// Validate, save income and navigate to bank setup.
  Future<void> _continue() async {
    if (_saving) return;

    // FIX: Safely access the FormState.
    final form = _formKey.currentState;

    if (form == null) {
      debugPrint('IncomeScreen: FormState is not available.');
      return;
    }

    if (!form.validate()) return;

    final rupees = _parseIncome(_controller.text);

    if (rupees <= 0) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _saving = true;
    });

    try {
      final repo = ref.read(settingsRepoProvider);

      // Load existing settings to preserve other preferences.
      final settings = await repo.load();

      // Store money in paise.
      await repo.save(settings.copyWith(monthlyIncomePaise: rupees * 100));

      // Refresh settings used by Profile and other screens.
      ref.invalidate(settingsProvider);

      if (!mounted) return;

      // Continue to bank account setup.
      context.go('/onboarding/add-bank');
    } catch (error, stackTrace) {
      debugPrint('IncomeScreen: Failed to save income: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save income: $error'),
          backgroundColor: AppColors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
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
                color: i <= 1 ? AppColors.primary : AppColors.nested,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          if (i != 4) const SizedBox(width: 7),
        ],
      ],
    );
  }

  Widget _incomeField() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MONTHLY TAKE-HOME',
            style: _heading(11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _controller,
            autofocus: false,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
            onChanged: (value) {
              setState(() {
                _incomeRupees = _parseIncome(value);
              });
            },
            onFieldSubmitted: (_) => _continue(),
            validator: (value) {
              final income = _parseIncome(value ?? '');

              if (income <= 0) {
                return 'Enter your monthly take-home income';
              }

              if (income > 100000000) {
                return 'Income must be ₹10 crore or less';
              }

              return null;
            },
            style: _heading(33),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: _heading(30, color: AppColors.primary),
              hintText: '50,000',
              hintStyle: _heading(33, color: AppColors.textSecondary),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorMaxLines: 2,
            ),
          ),
          const Divider(color: AppColors.border, height: 25),
          Row(
            children: [
              const Icon(Icons.lock_outline, color: AppColors.mint, size: 16),
              const SizedBox(width: 7),
              Expanded(
                child: Text('Saved privately on your device', style: _body(11)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _budgetPreview() {
    final daily = _incomeRupees / 30;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              Text(
                'YOUR DAILY BUDGET',
                style: _heading(12, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 21),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _money(daily),
              key: ValueKey(_incomeRupees),
              style: _heading(39, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 5),
          Text('Every single day.', style: _body(13)),
          const SizedBox(height: 19),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.nested,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calculate_outlined,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    '${_money(_incomeRupees)} ÷ 30 days '
                    '= ${_money(daily)} / day',
                    style: _body(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _explanation() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, color: AppColors.amber, size: 19),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Hisaab divides your monthly income by 30 to set '
            'your daily spending limit. Every tracked expense '
            'counts against this budget.',
            style: _body(12),
          ),
        ),
      ],
    );
  }

  Widget _footer() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _saving ? null : _continue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              disabledBackgroundColor: AppColors.nested,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'SET MY BUDGET',
                        style: _heading(15, color: AppColors.onPrimary),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward_rounded, size: 21),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 13),
        Text(
          'You can change your income later in Profile.',
          textAlign: TextAlign.center,
          style: _body(11),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: settingsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Unable to load settings: $error',
                textAlign: TextAlign.center,
                style: _body(13),
              ),
            ),
          ),
          data: (settings) {
            _loadSavedIncome(settings.monthlyIncomePaise);

            // FIX: The Form widget is now attached to
            // _formKey so validation works correctly.
            return Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: _saving
                                  ? null
                                  : () {
                                      context.go('/onboarding');
                                    },
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'STEP 02 / 05',
                              style: _heading(11, color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _progress(),
                        const SizedBox(height: 35),
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: AppColors.primary,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 25),
                        Text('FIRST, THE\nNUMBERS.', style: _heading(36)),
                        const SizedBox(height: 13),
                        Text(
                          'How much do you actually take home '
                          'every month?',
                          style: _body(14),
                        ),
                        const SizedBox(height: 30),
                        _incomeField(),
                        const SizedBox(height: 19),
                        _budgetPreview(),
                        const SizedBox(height: 23),
                        _explanation(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
                    child: _footer(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
