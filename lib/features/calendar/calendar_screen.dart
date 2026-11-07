import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../today/today_data.dart';
import 'day_detail_sheet.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _month;
  late DateTime _selectedDate;

  final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  String _money(int paise) => _currency.format(paise / 100);

  String _shortMoney(int paise) {
    final value = paise / 100;
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }

  TextStyle _title(double size, {Color? color}) {
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
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _changeMonth(int offset) {
    final next = DateTime(_month.year, _month.month + offset);
    final now = DateTime.now();

    if (next.isAfter(DateTime(now.year, now.month))) {
      return;
    }

    setState(() {
      _month = next;

      if (next.year == now.year && next.month == now.month) {
        _selectedDate = DateTime(now.year, now.month, now.day);
      } else {
        _selectedDate = DateTime(next.year, next.month, 1);
      }
    });
  }

  Map<DateTime, List<TodayTxn>> _groupTransactions(List<TodayTxn> txns) {
    final grouped = <DateTime, List<TodayTxn>>{};

    for (final txn in txns) {
      final day = DateTime(txn.at.year, txn.at.month, txn.at.day);
      grouped.putIfAbsent(day, () => []).add(txn);
    }

    return grouped;
  }

  int _spentOn(DateTime date, Map<DateTime, List<TodayTxn>> grouped) {
    return (grouped[date] ?? []).fold<int>(
      0,
      (sum, txn) => sum + txn.amountPaise,
    );
  }

  Color _heatColor(int spent, int budget) {
    if (spent <= 0) return AppColors.nested;
    if (budget <= 0) return AppColors.red;

    final ratio = spent / budget;

    if (ratio < 0.8) return AppColors.mint;
    if (ratio <= 1.0) return AppColors.amber;
    return AppColors.red;
  }

  Color _heatBackground(int spent, int budget) {
    if (spent <= 0) return AppColors.nested;

    final color = _heatColor(spent, budget);
    return color.withValues(alpha: 0.16);
  }

  Widget _statPill(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 6),
        Flexible(child: Text('$count $label', style: _title(11), maxLines: 1)),
      ],
    );
  }

  Widget _summary(TodayData data, Map<DateTime, List<TodayTxn>> grouped) {
    final now = DateTime.now();
    final currentMonth = _month.year == now.year && _month.month == now.month;

    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;

    final lastDay = currentMonth ? now.day : daysInMonth;
    final dailyBudget = data.budget.dailyBudgetPaise;
    final monthBudget = dailyBudget * daysInMonth;

    var spent = 0;
    var clean = 0;
    var danger = 0;
    var cooked = 0;

    for (int day = 1; day <= lastDay; day++) {
      final date = DateTime(_month.year, _month.month, day);
      final amount = _spentOn(date, grouped);

      spent += amount;

      // Days without transaction history are not counted as clean.
      if (!grouped.containsKey(date)) continue;

      if (amount > dailyBudget) {
        cooked++;
      } else if (amount >= dailyBudget * 0.8) {
        danger++;
      } else {
        clean++;
      }
    }

    final remaining = monthBudget - spent;
    final progress = monthBudget == 0
        ? 0.0
        : (spent / monthBudget).clamp(0.0, 1.0);

    return _panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('MMMM yyyy').format(_month),
                  style: _title(23),
                ),
              ),
              if (currentMonth)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.nested,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'LIVE',
                    style: _title(10, color: AppColors.primary),
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left),
                color: AppColors.textPrimary,
              ),
              IconButton(
                onPressed: currentMonth ? null : () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right),
                color: AppColors.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text('${_money(spent)} spent', style: _title(13)),
              ),
              Text(
                remaining >= 0
                    ? '${_money(remaining)} left'
                    : '${_money(-remaining)} over',
                style: _title(
                  13,
                  color: remaining >= 0 ? AppColors.mint : AppColors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              color: remaining >= 0 ? AppColors.mint : AppColors.red,
              backgroundColor: AppColors.nested,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statPill('Clean', clean, AppColors.mint),
                _statPill('Danger', danger, AppColors.amber),
                _statPill('Cooked', cooked, AppColors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heatmap(TodayData data, Map<DateTime, List<TodayTxn>> grouped) {
    final now = DateTime.now();
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;

    final firstWeekday = DateTime(_month.year, _month.month, 1).weekday;

    final cells = <Widget>[];

    for (int i = 1; i < firstWeekday; i++) {
      cells.add(const SizedBox.shrink());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_month.year, _month.month, day);
      final spent = _spentOn(date, grouped);
      final future = date.isAfter(DateTime(now.year, now.month, now.day));
      final selected = _sameDay(date, _selectedDate);
      final color = _heatColor(spent, data.budget.dailyBudgetPaise);

      cells.add(
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: future ? null : () => setState(() => _selectedDate = date),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary
                  : future
                  ? Colors.transparent
                  : _heatBackground(spent, data.budget.dailyBudgetPaise),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: _title(
                    14,
                    color: selected
                        ? AppColors.onPrimary
                        : future
                        ? AppColors.textSecondary.withValues(alpha: 0.35)
                        : spent > 0
                        ? color
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  future
                      ? '–'
                      : spent > 0
                      ? _shortMoney(spent)
                      : '–',
                  style: _title(
                    9,
                    color: selected
                        ? AppColors.onPrimary
                        : future
                        ? AppColors.textSecondary.withValues(alpha: 0.3)
                        : spent > 0
                        ? color
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('DAILY HEATMAP', style: _title(13))),
              const Icon(
                Icons.touch_app_outlined,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 5),
              Text(
                'Tap to inspect',
                style: _body(11, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${_money(data.budget.dailyBudgetPaise)} daily limit',
            style: _body(11),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              for (final weekday in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                Expanded(
                  child: Center(
                    child: Text(
                      weekday,
                      style: _title(11, color: AppColors.textSecondary),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 0.78,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: cells,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legend('Under 80%', AppColors.mint),
              const SizedBox(width: 13),
              _legend('80–100%', AppColors.amber),
              const SizedBox(width: 13),
              _legend('Over', AppColors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: _body(9)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(todayDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: asyncData.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, stack) => Center(
            child: Text(
              'Could not load calendar: $error',
              style: _body(13),
              textAlign: TextAlign.center,
            ),
          ),
          data: (data) {
            final grouped = _groupTransactions(data.historyTxns);
            final selectedTransactions = grouped[_selectedDate] ?? <TodayTxn>[];

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 115),
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Text('Calendar', style: _title(23)),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: () {
                        ref.invalidate(todayDataProvider);
                      },
                      icon: const Icon(
                        Icons.refresh,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _summary(data, grouped),
                const SizedBox(height: 18),
                _heatmap(data, grouped),
                const SizedBox(height: 18),
                DayDetailSheet(
                  date: _selectedDate,
                  transactions: selectedTransactions,
                  dailyBudgetPaise: data.budget.dailyBudgetPaise,
                ),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    'Only days with available transaction history are scored.',
                    textAlign: TextAlign.center,
                    style: _body(11),
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
