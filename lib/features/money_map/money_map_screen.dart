import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../today/today_data.dart';
import 'money_flow_toggle.dart';

enum MoneyPeriod { day, week, month }

class MoneyCategory {
  final String name;
  final int amountPaise;
  final int count;
  final Color color;
  final IconData icon;

  const MoneyCategory({
    required this.name,
    required this.amountPaise,
    required this.count,
    required this.color,
    required this.icon,
  });

  double get rupees => amountPaise / 100;
}

class MoneyMapScreen extends ConsumerStatefulWidget {
  const MoneyMapScreen({super.key});

  @override
  ConsumerState<MoneyMapScreen> createState() => _MoneyMapScreenState();
}

class _MoneyMapScreenState extends ConsumerState<MoneyMapScreen> {
  MoneyPeriod _period = MoneyPeriod.month;
  MoneyFlowType _flow = MoneyFlowType.spend;

  int _selectedCategory = 0;
  bool _descending = true;

  bool get _isIncome => _flow == MoneyFlowType.income;

  static const _palette = [
    AppColors.primary,
    AppColors.amber,
    Color(0xFF9299A8),
    Color(0xFFB77BFF),
    Color(0xFF60A5FA),
    AppColors.red,
    AppColors.mint,
  ];

  final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  String _money(int paise) => _currency.format(paise / 100);

  Color get _accent => _isIncome ? AppColors.mint : AppColors.primary;

  void _changeFlow(MoneyFlowType flow) {
    setState(() {
      _flow = flow;
      _selectedCategory = 0;
      _descending = true;
    });
  }

  List<TodayTxn> _transactions(TodayData data) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final DateTime start;

    switch (_period) {
      case MoneyPeriod.day:
        start = today;
      case MoneyPeriod.week:
        start = today.subtract(Duration(days: now.weekday - 1));
      case MoneyPeriod.month:
        start = DateTime(now.year, now.month);
    }

    final source = _isIncome ? data.historyIncomeTxns : data.historyTxns;

    return source.where((txn) {
      return !txn.at.isBefore(start) && !txn.at.isAfter(now);
    }).toList();
  }

  List<MoneyCategory> _categories(List<TodayTxn> txns) {
    final totals = <String, int>{};
    final counts = <String, int>{};

    for (final txn in txns) {
      // Credits currently have the generic Income category.
      // Use the credit payee for a useful income breakdown.
      final name = _isIncome
          ? (txn.merchant.trim().isEmpty ? 'Other income' : txn.merchant.trim())
          : (txn.category.trim().isEmpty
                ? 'Uncategorized'
                : txn.category.trim());

      totals.update(
        name,
        (value) => value + txn.amountPaise,
        ifAbsent: () => txn.amountPaise,
      );

      counts.update(name, (value) => value + 1, ifAbsent: () => 1);
    }

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return [
      for (int i = 0; i < sorted.length; i++)
        MoneyCategory(
          name: sorted[i].key,
          amountPaise: sorted[i].value,
          count: counts[sorted[i].key] ?? 0,
          color: _palette[i % _palette.length],
          icon: _categoryIcon(sorted[i].key),
        ),
    ];
  }

  IconData _categoryIcon(String name) {
    final value = name.toLowerCase();

    if (_isIncome) {
      if (value.contains('salary') || value.contains('payroll')) {
        return Icons.work_outline;
      }
      if (value.contains('refund')) {
        return Icons.currency_exchange;
      }
      if (value.contains('interest')) {
        return Icons.savings_outlined;
      }
      return Icons.south_west_rounded;
    }

    if (value.contains('food')) {
      return Icons.restaurant_outlined;
    }
    if (value.contains('commerce')) {
      return Icons.shopping_basket_outlined;
    }
    if (value.contains('shop')) {
      return Icons.shopping_bag_outlined;
    }
    if (value.contains('cafe')) {
      return Icons.local_cafe_outlined;
    }
    if (value.contains('transport')) {
      return Icons.directions_car_outlined;
    }
    if (value.contains('social')) {
      return Icons.local_bar_outlined;
    }

    return Icons.account_balance_wallet_outlined;
  }

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

  Widget _panel({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(18),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _periodSelector() {
    final periods = [
      ('Day', MoneyPeriod.day),
      ('Week', MoneyPeriod.week),
      ('Month (${DateFormat.MMM().format(DateTime.now())})', MoneyPeriod.month),
    ];

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: periods.map((entry) {
          final selected = _period == entry.$2;

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                setState(() {
                  _period = entry.$2;
                  _selectedCategory = 0;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? AppColors.nested : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  entry.$1,
                  textAlign: TextAlign.center,
                  style: _heading(
                    12,
                    color: selected ? _accent : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _insightCard(
    List<MoneyCategory> categories,
    int total,
    TodayData data,
  ) {
    if (categories.isEmpty) {
      return _panel(
        child: Text(
          _isIncome
              ? 'No income detected for this period yet.'
              : 'No spending detected for this period yet.',
          style: _body(14),
        ),
      );
    }

    final top = categories.first;
    final share = total == 0 ? 0.0 : top.amountPaise / total;

    if (_isIncome) {
      return _panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _insightBadge('INCOME INSIGHT', 'MONEY RECEIVED'),
            const SizedBox(height: 16),
            Text.rich(
              TextSpan(
                style: _heading(21),
                children: [
                  const TextSpan(text: 'You received '),
                  TextSpan(
                    text: _money(top.amountPaise),
                    style: _heading(21, color: AppColors.mint),
                  ),
                  TextSpan(text: ' from ${top.name}.'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${(share * 100).toStringAsFixed(1)}% '
              'of your tracked income came from this source.',
              style: _body(13),
            ),
            const SizedBox(height: 18),
            _shareIndicator('Share of tracked income', share, AppColors.mint),
          ],
        ),
      );
    }

    final flexiblePool = data.monthBudgetPaise;
    final poolShare = flexiblePool == 0
        ? 0.0
        : top.amountPaise / flexiblePool * 100;

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _insightBadge('⚡ HARSH TRUTH', 'BUDGET LEAK'),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              style: _heading(21),
              children: [
                const TextSpan(text: 'You spent '),
                TextSpan(
                  text: _money(top.amountPaise),
                  style: _heading(21, color: AppColors.primary),
                ),
                TextSpan(text: ' on ${top.name.toLowerCase()}.'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            flexiblePool > 0
                ? '${poolShare.toStringAsFixed(1)}% of '
                      'your flexible monthly budget went '
                      'to this category in the selected period.'
                : 'Set your flexible monthly budget '
                      'in Profile to compare spending.',
            style: _body(13),
          ),
          const SizedBox(height: 18),
          _shareIndicator(
            'Share of tracked spending',
            share,
            AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _insightBadge(String label, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: _accent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(label, style: _heading(11, color: AppColors.onPrimary)),
        ),
        Text(subtitle, style: _body(10)),
      ],
    );
  }

  Widget _shareIndicator(String label, double share, Color color) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.nested,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: _body(11))),
              Text(
                '${(share * 100).toStringAsFixed(1)}%',
                style: _heading(12, color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: share.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.border,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _donutCard(List<MoneyCategory> categories, int total) {
    final selected = categories.isEmpty
        ? null
        : categories[_selectedCategory.clamp(0, categories.length - 1)];

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isIncome ? 'Income Sources' : 'Category Proportions',
                      style: _heading(18),
                    ),
                    const SizedBox(height: 4),
                    Text('Tap a segment to inspect', style: _body(11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.nested,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  '${_money(total)} Total',
                  style: _heading(12, color: _accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),

          if (categories.isEmpty)
            SizedBox(
              height: 185,
              child: Center(
                child: Text(
                  _isIncome ? 'No income sources yet' : 'No categories yet',
                  style: _body(14),
                ),
              ),
            )
          else
            Center(
              child: SizedBox(
                width: 210,
                height: 210,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        centerSpaceRadius: 66,
                        sectionsSpace: 2,
                        startDegreeOffset: -90,
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            if (!event.isInterestedForInteractions ||
                                response?.touchedSection == null) {
                              return;
                            }

                            final index =
                                response!.touchedSection!.touchedSectionIndex;

                            if (index < 0 || index >= categories.length) {
                              return;
                            }

                            setState(() {
                              _selectedCategory = index;
                            });
                          },
                        ),
                        sections: [
                          for (int i = 0; i < categories.length; i++)
                            PieChartSectionData(
                              value: categories[i].amountPaise.toDouble(),
                              color: categories[i].color,
                              radius: i == _selectedCategory ? 24 : 19,
                              showTitle: false,
                            ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('SELECTED', style: _body(10)),
                        Text(
                          total > 0
                              ? '${(selected!.amountPaise / total * 100).toStringAsFixed(0)}%'
                              : '0%',
                          style: _heading(28),
                        ),
                        SizedBox(
                          width: 120,
                          child: Text(
                            selected!.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: _heading(11, color: selected.color),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),

          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - 8) / 2;

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (int i = 0; i < categories.length; i++)
                    InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategory = i;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: width,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.nested,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: i == _selectedCategory
                                ? categories[i].color
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 5,
                              backgroundColor: categories[i].color,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    categories[i].name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: _body(10),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _money(categories[i].amountPaise),
                                    style: _heading(12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _rankedLeaks(List<MoneyCategory> categories, int total) {
    final sorted = [...categories]
      ..sort(
        (a, b) => _descending
            ? b.amountPaise.compareTo(a.amountPaise)
            : a.amountPaise.compareTo(b.amountPaise),
      );

    return Column(
      children: [
        Row(
          children: [
            Text(
              _isIncome ? 'Ranked Income Sources' : 'Ranked Leaks',
              style: _heading(19),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${categories.length} ${_isIncome ? 'Sources' : 'Categories'}',
                style: _body(11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _descending = !_descending;
                });
              },
              icon: const Icon(Icons.tune, size: 17),
              label: Text(_descending ? 'Highest' : 'Lowest'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                backgroundColor: AppColors.nested,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (sorted.isEmpty)
          _panel(
            child: Text(
              _isIncome
                  ? 'Your income breakdown will appear here.'
                  : 'Your spending breakdown will appear here.',
              style: _body(13),
            ),
          ),

        for (int i = 0; i < sorted.length; i++) ...[
          _categoryTile(sorted[i], i + 1, total),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _categoryTile(MoneyCategory category, int rank, int total) {
    final share = total == 0 ? 0.0 : category.amountPaise / total * 100;

    return _panel(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: category.color.withValues(alpha: 0.15),
                child: Text(
                  '$rank',
                  style: _heading(18, color: category.color),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _heading(15),
                    ),
                    const SizedBox(height: 3),
                    Text('${category.count} transactions', style: _body(11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_money(category.amountPaise), style: _heading(16)),
                  Text(
                    '${share.toStringAsFixed(1)}% of ${_isIncome ? 'income' : 'spend'}',
                    style: _body(10, color: category.color),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: (share / 100).clamp(0.0, 1.0),
              backgroundColor: AppColors.nested,
              color: category.color,
              minHeight: 5,
            ),
          ),
        ],
      ),
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
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Unable to load Money Map data.\n$error',
                textAlign: TextAlign.center,
                style: _body(13),
              ),
            ),
          ),
          data: (data) {
            final txns = _transactions(data);
            final categories = _categories(txns);

            final total = txns.fold<int>(
              0,
              (sum, txn) => sum + txn.amountPaise,
            );

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 115),
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppColors.onPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('Money Map', style: _heading(23)),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        ref.invalidate(todayDataProvider);
                      },
                      tooltip: 'Refresh Money Map',
                      icon: const Icon(
                        Icons.refresh,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // A2: Spend / Income selector.
                MoneyFlowToggle(selected: _flow, onChanged: _changeFlow),
                const SizedBox(height: 16),

                // Shared period selector.
                _periodSelector(),
                const SizedBox(height: 16),

                // Total for the selected flow and period.
                _panel(
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _isIncome
                              ? Icons.south_west_rounded
                              : Icons.north_east_rounded,
                          color: _accent,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isIncome ? 'TOTAL RECEIVED' : 'TOTAL SPENT',
                              style: _body(11),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _money(total),
                              style: _heading(25, color: _accent),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${txns.length} transactions',
                              style: _body(11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _insightCard(categories, total, data),
                const SizedBox(height: 16),

                _donutCard(categories, total),
                const SizedBox(height: 22),

                _rankedLeaks(categories, total),
                const SizedBox(height: 18),

                Center(
                  child: Text(
                    _isIncome
                        ? 'Based on tracked incoming transactions'
                        : 'Based on everyday spending only',
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
