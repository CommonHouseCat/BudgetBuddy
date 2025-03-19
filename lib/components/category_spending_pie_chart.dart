import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/*
* Display a pie chart for spending data based on category.
* */
class CategorySpendingPieChart extends StatelessWidget {
  // A map of category names (keys) and corresponding amounts (values).
  final Map<String, double> categoryData;

  const CategorySpendingPieChart({
    super.key,
    required this.categoryData,
  });

  @override
  Widget build(BuildContext context) {

    /*
    * A list of PieChartSectionData objects, based on the categoryData map.
    * For each entry in the map, creates a pie chart section with
    * the section size defined by the value,
    * the section title defined by the key,
    * and the section color defined by the hash category.
    * */
    List<PieChartSectionData> sections = categoryData.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value,
        title: entry.key,
        color: Colors.primaries[entry.key.hashCode % Colors.primaries.length],
      );
    }).toList();

    // Return a PieChart widget with the provided sections.
    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 80,
        sectionsSpace: 2,
      ),
    );
  }
}
