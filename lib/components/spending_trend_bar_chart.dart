import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/*
* A bar chart displaying spending trends for each day.
* */
class SpendingTrendBarChart extends StatelessWidget {
  // A map of date strings (keys) and corresponding income and expense amounts (values).
  final Map<String, Map<String, double>> dailyData;

  const SpendingTrendBarChart({
    super.key,
    required this.dailyData,
  });

  // Helper function to format number with K (thousands) or M (Millions) suffix.
  String formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(number % 1000000 == 0 ? 0 : 1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(number % 1000 == 0 ? 0 : 1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // List that holds the data for each group of bars in the chart.
    List<BarChartGroupData> barGroups = [];
    int index = 0; // Index for the x-axis (date positions).

    /*
     * Constructs bar chart groups from daily income and expense data.
     * For each day, creates a group with income (green) and expense (red) bars.
     * Missing income/expense values are treated as zero.
     */
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
        barGroups: barGroups, // list of the bar groups (data).
        titlesData: FlTitlesData(
          // y-axis title.
          leftTitles: AxisTitles(
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
          // x-axis title.
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              /*
              * Convert index to int, check if it's within the range of keys
              * in dailyData, If yes display the date, otherwise return empty text.
              * */
              getTitlesWidget: (double value, TitleMeta meta) {
                int index = value.toInt();
                if (index < dailyData.keys.length) {
                  return Text(dailyData.keys.elementAt(index));
                }
                return const Text('');
              },
            ),
          ),
          // Remove top and right titles.
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        // Showing border around the chart.
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
