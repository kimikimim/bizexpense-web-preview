
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/monthly_forecast_service.dart';

class MonthlyForecastPage extends StatefulWidget {
  const MonthlyForecastPage({super.key});

  @override
  State<MonthlyForecastPage> createState() => _MonthlyForecastPageState();
}

class _MonthlyForecastPageState extends State<MonthlyForecastPage> {
  final MonthlyForecastService _service = MonthlyForecastService();

  bool _loading = true;
  MonthlyForecast? _forecast;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final f = await _service.getThisMonthForecast();
      if (!mounted) return;
      setState(() => _forecast = f);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatMoney(int value) {
    final formatter = NumberFormat('#,###');
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthStr = DateFormat('yyyy년 MM월').format(now);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: Text('$monthStr 정기 예상'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _forecast == null
              ? const Center(child: Text('정기 거래가 없습니다.'))
              : Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$monthStr 정기 거래 기준 예상 현금 흐름',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryCards(context, _forecast!),
                      const SizedBox(height: 32),
                      Text(
                        '정기 수입 / 지출 비교',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSimpleBarChart(context, _forecast!),
                      const SizedBox(height: 32),
                      Text(
                        '설명',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '이 화면은 등록한 정기 거래(월/주 기준)를 바탕으로 '
                        '이번 달에 반복될 수입/지출을 모두 합산한 예상값입니다.\n\n'
                        '실제 거래 내역과 합쳐서 더 정밀한 예측도 나중에 추가할 수 있습니다.',
                        style: TextStyle(color: textColor),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, MonthlyForecast f) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Row(
      children: [
        Expanded(
          child: _buildNumberCard(
            context: context,
            title: '예상 정기 수입',
            value: '+${_formatMoney(f.expectedIncome)}원',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNumberCard(
            context: context,
            title: '예상 정기 지출',
            value: '-${_formatMoney(f.expectedExpense)}원',
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberCard({
    required BuildContext context,
    required String title,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.white10 : Colors.white;
    final border = Theme.of(context).dividerColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).hintColor,
              )),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleBarChart(BuildContext context, MonthlyForecast f) {
    final maxValue = [
      f.expectedIncome,
      f.expectedExpense,
    ].reduce((a, b) => a > b ? a : b);

    if (maxValue <= 0) {
      return const Text('이번 달 정기 수입/지출 데이터가 없습니다.');
    }

    double _calcHeight(int value) {
      if (value <= 0) return 0;
      final ratio = value / maxValue;
      return 160 * ratio; 
    }

    final incomeHeight = _calcHeight(f.expectedIncome);
    final expenseHeight = _calcHeight(f.expectedExpense);

    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: incomeHeight,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.green.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('정기 수입'),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: expenseHeight,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.red.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('정기 지출'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
