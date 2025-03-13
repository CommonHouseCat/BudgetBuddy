import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SpendingTrendBarChart extends StatelessWidget {
  final Map<String, Map<String, double>> dailyData;

  const SpendingTrendBarChart({
    super.key,
    required this.dailyData,
  });

  // ================= Add this ==========================
  String formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(number % 1000000 == 0 ? 0 : 1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(number % 1000 == 0 ? 0 : 1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }
  // ===================================================

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> barGroups = [];
    int index = 0;

    dailyData.forEach((date, values) {
      double income = values['income'] ?? 0.0;
      double expense = values['expense'] ?? 0.0;

      barGroups.add(
        BarChartGroupData(
          x: index++,
          barRods: [
            BarChartRodData(
              toY: income,
              color: Colors.green,
              width: 5,
            ),
            BarChartRodData(
              toY: expense,
              color: Colors.red,
              width: 5,
            ),
          ],
        ),
      );
    });

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            // =============== Modify This ===========================
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  formatNumber(value),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          // ========================================================
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                int index = value.toInt();
                if (index < dailyData.keys.length) {
                  return Text(dailyData.keys.elementAt(index));
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: const Color(0xff37434d),
            width: 1,
          ),
        ),
      ),
    );
  }
}
