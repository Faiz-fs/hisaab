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
/// Collects monthly take-home income, monthly commitments,
/// and salary pay day. Previews the flexible daily budget
/// and persists the values before bank account setup.
class IncomeScreen extends ConsumerStatefulWidget {
  const IncomeScreen({super.key});

  @override
  ConsumerState<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends ConsumerState<IncomeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _incomeController = TextEditingController();
  final _commitmentsController = TextEditingController();

  bool _saving = false;
  bool _loaded = false;

  int _incomeRupees = 0;
  int _commitmentsRupees = 0;
  int _payDay = 1;

  final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  String _money(num amount) => _currency.format(amount);

  int _parseAmount(String value) {
    return int.tryParse(value.replaceAll(',', '').trim()) ?? 0;
  }

  int get _flexiblePool {
    final amount = _incomeRupees - _commitmentsRupees;
    return amount < 0 ? 0 : amount;
  }

  bool get _commitmentsExceedIncome => _commitmentsRupees > _incomeRupees;

  int get _cycleDays {
    final now = DateTime.now();

    if (_payDay == 1) {
      return DateTime(now.year, now.month + 1, 0).day;
    }

    // A pay-day cycle can cross calendar months.
    final thisMonthPayDay = DateTime(now.year, now.month, _payDay);

    final start = now.isBefore(thisMonthPayDay)
        ? DateTime(now.year, now.month - 1, _payDay)
        : thisMonthPayDay;

    final end = DateTime(start.year, start.month + 1, _payDay);

    return end.difference(start).inDays;
  }

  double get _dailyBudget => _cycleDays > 0 ? _flexiblePool / _cycleDays : 0;

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
    _incomeController.dispose();
    _commitmentsController.dispose();
    super.dispose();
  }

  /// Loads previously saved values only once.
  ///
  /// Prevents settings refreshes from overwriting user input.
  void _loadSavedValues(int incomePaise, int commitmentsPaise, int payDay) {
    if (_loaded) return;

    _loaded = true;

    _incomeRupees = incomePaise ~/ 100;
    _commitmentsRupees = commitmentsPaise ~/ 100;
    _payDay = payDay.clamp(1, 28).toInt();

    if (_incomeRupees > 0) {
      _incomeController.text = _incomeRupees.toString();
    }

    if (_commitmentsRupees > 0) {
      _commitmentsController.text = _commitmentsRupees.toString();
    }
  }

  /// Validates and saves the complete budget setup.
  Future<void> _continue() async {
    if (_saving) return;

    final form = _formKey.currentState;

    if (form == null || !form.validate()) return;

    final income = _parseAmount(_incomeController.text);
    final commitments = _parseAmount(_commitmentsController.text);

    if (income <= 0 || commitments > income) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _saving = true;
    });

    try {
      final repo = ref.read(settingsRepoProvider);
      final settings = await repo.load();

      // Preserve every unrelated setting.
      await repo.save(
        settings.copyWith(
          monthlyIncomePaise: income * 100,
          monthlyCommitmentsPaise: commitments * 100,
          payDay: _payDay,
        ),
      );

      ref.invalidate(settingsProvider);

      if (!mounted) return;

      context.go('/onboarding/add-bank');
    } catch (error, stackTrace) {
      debugPrint('IncomeScreen: Save failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save budget: $error'),
          backgroundColor: AppColors.red,
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

  Widget _amountField({
    required String title,
    required String hint,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required String? Function(String?) validator,
    String? description,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _heading(11, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
            onChanged: onChanged,
            validator: validator,
            style: _heading(29),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: _heading(26, color: AppColors.primary),
              hintText: hint,
              hintStyle: _heading(27, color: AppColors.textSecondary),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorMaxLines: 3,
            ),
          ),
          if (description != null) ...[
            const Divider(color: AppColors.border, height: 22),
            Text(description, style: _body(11)),
          ],
        ],
      ),
    );
  }

  Widget _incomeField() {
    return _amountField(
      title: 'MONTHLY TAKE-HOME INCOME',
      hint: '39,000',
      controller: _incomeController,
      description: 'Your salary after tax and deductions.',
      onChanged: (value) {
        setState(() {
          _incomeRupees = _parseAmount(value);
        });
      },
      validator: (value) {
        final amount = _parseAmount(value ?? '');

        if (amount <= 0) {
          return 'Enter your monthly income';
        }

        if (amount > 100000000) {
          return 'Income must be ₹10 crore or less';
        }

        return null;
      },
    );
  }

  Widget _commitmentsField() {
    return _amountField(
      title: 'MONTHLY COMMITMENTS',
      hint: '25,000',
      controller: _commitmentsController,
      description:
          'Family support, rent, EMI, SIP, chit, '
          'insurance and other fixed payments. '
          'Enter 0 if none.',
      onChanged: (value) {
        setState(() {
          _commitmentsRupees = _parseAmount(value);
        });
      },
      validator: (value) {
        final amount = _parseAmount(value ?? '');
        final income = _parseAmount(_incomeController.text);

        if (amount > 100000000) {
          return 'Commitments must be ₹10 crore or less';
        }

        if (amount > income) {
          return 'Commitments cannot exceed income';
        }

        return null;
      },
    );
  }

  Widget _payDayField() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SALARY PAY DAY',
            style: _heading(11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            key: ValueKey(_payDay),
            initialValue: _payDay,
            dropdownColor: AppColors.card,
            decoration: const InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.calendar_month_outlined,
                color: AppColors.primary,
              ),
            ),
            items: [
              for (int day = 1; day <= 28; day++)
                DropdownMenuItem(
                  value: day,
                  child: Text(
                    day == 1
                        ? '1st (Calendar month)'
                        : 'Day $day of each month',
                    style: _body(14, color: AppColors.textPrimary),
                  ),
                ),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _payDay = value;
              });
            },
          ),
          const SizedBox(height: 5),
          Text('Your budget resets on this day every month.', style: _body(11)),
        ],
      ),
    );
  }

  Widget _breakdownRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: _body(12))),
          Text(
            value,
            style: _heading(
              14,
              color: highlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _budgetPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _commitmentsExceedIncome
              ? AppColors.red
              : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bolt_rounded,
                color: AppColors.primary,
                size: 23,
              ),
              const SizedBox(width: 9),
              Text(
                'YOUR DAILY BUDGET',
                style: _heading(12, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            _money(_dailyBudget),
            style: _heading(38, color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text('Available for everyday spending.', style: _body(12)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.nested,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _breakdownRow('Monthly income', _money(_incomeRupees)),
                _breakdownRow(
                  'Monthly commitments',
                  '- ${_money(_commitmentsRupees)}',
                ),
                const Divider(color: AppColors.border),
                _breakdownRow(
                  'Flexible budget',
                  _money(_flexiblePool),
                  highlight: true,
                ),
                _breakdownRow('Days in budget cycle', '$_cycleDays'),
              ],
            ),
          ),
          if (_commitmentsExceedIncome) ...[
            const SizedBox(height: 12),
            Text(
              'Your commitments exceed your income. '
              'Please adjust the amounts.',
              style: _body(12, color: AppColors.red),
            ),
          ],
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
            'Hisaab first sets aside your monthly '
            'commitments. Only the remaining flexible '
            'budget is used for your daily spending limit. '
            'You can update your income and commitments '
            'later in Profile.',
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
        const SizedBox(height: 12),
        Text(
          'Your financial details stay on your device.',
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
            _loadSavedValues(
              settings.monthlyIncomePaise,
              settings.monthlyCommitmentsPaise,
              settings.payDay,
            );

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
                                  : () => context.go('/onboarding'),
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
                        const SizedBox(height: 30),
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
                        const SizedBox(height: 24),
                        Text('LET\'S PLAN\nYOUR MONEY.', style: _heading(35)),
                        const SizedBox(height: 12),
                        Text(
                          'Tell us what you earn and what '
                          'you need to set aside each month.',
                          style: _body(14),
                        ),
                        const SizedBox(height: 27),
                        _incomeField(),
                        const SizedBox(height: 16),
                        _commitmentsField(),
                        const SizedBox(height: 16),
                        _payDayField(),
                        const SizedBox(height: 20),
                        _budgetPreview(),
                        const SizedBox(height: 20),
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
